/*
 * oratcl.c
 *
 * Oracle interface to Tcl
 *
 * Copyright 2004 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */


#if defined(WIN32) || defined(_WIN32)
#ifndef __WIN32__
#define __WIN32__
#endif
#endif

#if defined(__WIN32__)
#include <windows.h>
#endif

#include "oratclInt.h"
#include "oratcl.h"
#include <tcl.h>
#include <fcntl.h>
#include <sys/stat.h>

#ifdef NO_STRING_H
#include <strings.h>
#else
#include <string.h>
#endif

#include <ctype.h>
#include <stdlib.h>

#ifdef __WIN32__
#undef  TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS  DLLEXPORT

EXTERN Oratcl_Init	_ANSI_ARGS_((Tcl_Interp *interp));
EXTERN Oratcl_SafeInit	_ANSI_ARGS_((Tcl_Interp *interp));

BOOL APIENTRY
DllEntryPoint(hInst, reason, reserved)
HINSTANCE hInst;            /* Library instance handle. */
DWORD reason;               /* Reason this function is being called. */
LPVOID reserved;            /* Not used. */
{
    return TRUE;
}

#define strncasecmp strnicmp
#define strcasecmp stricmp

#define DLOPEN(libname, flags)	LoadLibrary(libname)
#define DLCLOSE(path)		((void *) FreeLibrary((HMODULE) path))
#define DLSYM(handle, symbol, proc, type) \
	(proc = (type) GetProcAddress((HINSTANCE) handle, symbol))

#else			/* __WIN32__ */

#if defined(__hpux)

/* HPUX requires shl_* routines */
#include <dl.h>
#define HMODULE shl_t
#define DLOPEN(libname, flags)	shl_load(libname, \
	BIND_DEFERRED|BIND_VERBOSE|DYNAMIC_PATH, 0L)
#define DLCLOSE(path)		shl_unload((shl_t) path)
#define DLERROR ""
#define DLSYM(handle, symbol, proc, type) \
	if (shl_findsym(&handle, symbol, (short) TYPE_PROCEDURE, \
		(void *) &proc) != 0) { proc = NULL; }

#else			/* __hpux */

#ifdef HAVE_DLFCN_H
#include <dlfcn.h>
#endif
#define HMODULE void *
#define DLOPEN	dlopen
#define DLCLOSE	dlclose
#define DLERROR dlerror()
#define DLSYM(handle, symbol, proc, type) \
	(proc = (type) dlsym(handle, symbol))

#endif			/* __hpux */

#endif			/* __WIN32__ */

#include "oratclTypes.h"

/*
 * prefix is used to identify handles
 * login handles are:  prefix , login index                     e.g. oratcl0
 * statement handles are:  login handle , '.', statement index  e.g. oratcl0.0
 */

static char *OraHandlePrefix = "oratcl";

Tcl_Obj *OMV_zero = NULL;

OratclStateList	*OratclSLP = NULL;

extern int	  Oratcl_Init		_ANSI_ARGS_((Tcl_Interp	*interp));
extern int	  Oratcl_SafeInit	_ANSI_ARGS_((Tcl_Interp	*interp));
extern void    	  Oratcl_StmFree	_ANSI_ARGS_((OratclStms	*StmPtr));
extern void    	  Oratcl_LogFree	_ANSI_ARGS_((OratclLogs	*LogPtr));
extern void	  Oratcl_ColFree	_ANSI_ARGS_((OratclCols *ColPtr));
extern OratclCols *Oratcl_ColAlloc	_ANSI_ARGS_((int 	fetchrows));
extern sword	  Oratcl_Attributes	_ANSI_ARGS_((Tcl_Interp	*interp,
						     OCIError	*errhp,
						     OCIParam	*parmh,
						     OratclDesc	*column,
						     int	explicit));
extern int	  Oratcl_ColDescribe	_ANSI_ARGS_((Tcl_Interp *interp,
						     OratclStms	*StmPtr));
extern int	  Oratcl_ColAppend 	_ANSI_ARGS_((Tcl_Interp	*interp,
						     OratclStms	*StmPtr,
						     Tcl_Obj	*listvar,
						     Tcl_Obj	*arrayvar,
						     int	hashType));
extern int	  Oralob_Init		_ANSI_ARGS_((Tcl_Interp	*interp));
extern int	  Oralong_Init		_ANSI_ARGS_((Tcl_Interp	*interp));

/* 
 *----------------------------------------------------------------------
 * TAF Callback
 *----------------------------------------------------------------------
 */
sb4 callback_fn(svchp, envhp, fo_ctx, fo_type, fo_event)
	dvoid		*svchp;
	dvoid		*envhp;
	dvoid		*fo_ctx;
	ub4		fo_type;
	ub4		fo_event;
{
	int		res;

	OratclLogs *LogPtr = (OratclLogs*)fo_ctx;
	char buffer[100];

	sprintf(buffer,
		"%s %d %d",
		LogPtr->failovercallback,
		fo_type,
		fo_event);
	res = Tcl_Eval(LogPtr->interp, buffer);
	if (res != TCL_OK) {
		Tcl_BackgroundError(LogPtr->interp);
	}

	return 0;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_ErrorMsg
 *    This procedure generates a Oratcl error message in interpreter.
 *
 * Results: None
 *
 * Side effects:
 *      An error message is generated in interp's result object to
 *      indicate that a command was invoked that resulted in an error.
 *      The message has the form
 *              "obj0 msg0 obj1 msg1"
 *
 *----------------------------------------------------------------------
 */

void
Oratcl_ErrorMsg(interp, obj0, msg0, obj1, msg1)
	Tcl_Interp	*interp;
	Tcl_Obj 	*obj0, *obj1;
	char		*msg0, *msg1;
{
	Tcl_Obj		*newPtr;

	newPtr = Tcl_NewStringObj("",	-1);
	if (obj0) {
		Tcl_IncrRefCount(obj0);
		Tcl_AppendObjToObj(newPtr, obj0);
		Tcl_DecrRefCount(obj0);
	}
	if (msg0) {
		Tcl_AppendToObj(newPtr, msg0, -1);
	}
	if (obj1) {
		Tcl_IncrRefCount(obj1);
		Tcl_AppendObjToObj(newPtr, obj1);
		Tcl_DecrRefCount(obj1);
	}
	if (msg1) {
		Tcl_AppendToObj(newPtr, msg1, -1);
	}
	Tcl_SetObjResult(interp, newPtr);
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Clean --
 *   utility function to close all handles.
 *----------------------------------------------------------------------
 */

void
Oratcl_Clean (clientData)
	ClientData clientData;
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	OratclLogs	*LogPtr;
	OratclStms	*StmPtr;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	Tcl_HashSearch  srch;

	OratclStateList *StateListPtr;
	int		found = 0;

	for (StateListPtr = OratclSLP; StateListPtr != NULL; StateListPtr = StateListPtr->next) {
		if (StateListPtr->state == OratclStatePtr) {
			if (StateListPtr->prev == NULL) {
				OratclSLP = StateListPtr->next;
				if (StateListPtr->next) {
					OratclSLP->prev = NULL;
				}
			} else if (StateListPtr->next == NULL) {
				StateListPtr->prev->next = NULL;
			} else {
				StateListPtr->prev->next = StateListPtr->next;
				StateListPtr->next->prev = StateListPtr->prev;
			}
			ckfree ((char *) StateListPtr);
			found = 1;
			break;
		}
	}

	if (!found) {
		return;
	}

	/*
	 * Close all open statement handles.
	 */
	for (stmHashPtr = Tcl_FirstHashEntry(OratclStatePtr->stmHash, &srch);
	     stmHashPtr != (Tcl_HashEntry *)NULL;
	     stmHashPtr = Tcl_FirstHashEntry(OratclStatePtr->stmHash, &srch)) {

		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
		Oratcl_StmFree(StmPtr);
		Tcl_DeleteHashEntry(stmHashPtr);
	}

	Tcl_DeleteHashTable(OratclStatePtr->stmHash);
	ckfree((char *) OratclStatePtr->stmHash);
	OratclStatePtr->stmHash = NULL;

	/*
	 * Close all open logon handles.
	 */
	for (logHashPtr = Tcl_FirstHashEntry(OratclStatePtr->logHash, &srch);
	     logHashPtr != (Tcl_HashEntry *)NULL;
	     logHashPtr = Tcl_FirstHashEntry(OratclStatePtr->logHash, &srch)) {

		LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
		OCI_SessionEnd(LogPtr->svchp,
			       LogPtr->errhp,
			       LogPtr->usrhp,
			       OCI_DEFAULT);
		OCI_ServerDetach(LogPtr->srvhp,
				 LogPtr->errhp,
				 (ub4) OCI_DEFAULT);
		Oratcl_LogFree(LogPtr);
		Tcl_DeleteHashEntry(logHashPtr);
	}

	Tcl_DeleteHashTable(OratclStatePtr->logHash);
	ckfree((char *) OratclStatePtr->logHash);
	OratclStatePtr->logHash = NULL;

	/*
	 *  Free the hash table.
	 */
	if (OratclStatePtr != NULL) {
		ckfree((char *) OratclStatePtr);
	}
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Exit --
 *   Oratcl exit handler
 *----------------------------------------------------------------------
 */

void
Oratcl_Exit (clientData)
	ClientData clientData;
{
	Oratcl_Clean(clientData);

	Tcl_DecrRefCount(OMV_zero);

#ifndef __WIN32__
#ifdef TCL_MEM_DEBUG
	Tcl_DumpActiveMemory("/tmp/oratcl_memdump");
#endif
#endif
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Delete --
 *   close any handles left open when an interpreter is deleted
 *----------------------------------------------------------------------
 */

void
Oratcl_Delete (clientData, interp)
    ClientData clientData;
    Tcl_Interp *interp;
{
	Oratcl_Clean(clientData);
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Init --
 *   perform all initialization for the Oracle - Tcl interface.
 *   adds additional commands to interp, creates message array
 *
 *   a call to Oratcl_Init should exist in Tcl_CreateInterp or
 *   Tcl_CreateExtendedInterp.
 *----------------------------------------------------------------------
 */

int
Oratcl_Init (interp)
	Tcl_Interp	*interp;
{
	static int	OratclInitFlag = 0;    /* initialization flag */
	OratclState	*OratclStatePtr;
	OratclStateList *StateListPtr;

	int		rc = 0;

	HMODULE		handle;

#ifdef __WIN32__
	DWORD		last_error;
#else							/* __WIN32__ */
	CONST char	*native;

	Tcl_Obj		*env_obj;
#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
	Tcl_Obj		*tmp_obj = NULL;
#endif
	Tcl_Obj		*pt1_obj = NULL;
	Tcl_Obj		*pt2_obj = NULL;
	Tcl_Obj		*pt3_obj = NULL;

#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
	Tcl_Obj		**pathObjv;
	int		pathObjc;
	Tcl_Obj		*pathList;
#elif ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION == 3))
	char		**pathObjv;
	int		pathObjc;
	Tcl_DString	result;
#endif
	CONST char	*ora_lib = NULL;

#endif							/* __WIN32__ */

#ifdef USE_TCL_STUBS
	if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}
#endif

#ifndef __WIN32__

	/* Load the oracle client library:
	 * if env(ORACLE_LIBRARY) is defined use it.
	 * else use $env(ORACLE_HOME)/lib/libclntsh.SHLIB_SUFFIX
	 */

	ora_lib = Tcl_GetVar2(interp, "env", "ORACLE_LIBRARY", TCL_GLOBAL_ONLY);

	if (ora_lib) {
		native = ora_lib;
	} else {

#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
		pathObjv = (Tcl_Obj **) ckalloc (3 * sizeof(*pathObjv));
#elif ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION == 3))
		Tcl_DStringInit(&result);
		pathObjv = (char **) ckalloc (3 * sizeof(char *));
#endif
		pathObjc = 0;

		env_obj = Tcl_NewStringObj("env(ORACLE_HOME)", -1);
		Tcl_IncrRefCount(env_obj);

		pt1_obj = Tcl_ObjGetVar2(interp,
					env_obj,
					NULL,
					TCL_LEAVE_ERR_MSG);
		if (pt1_obj == NULL) {
			return TCL_ERROR;
		}
		pt2_obj = Tcl_NewStringObj("lib", -1);
		pt3_obj = Tcl_NewStringObj("libclntsh"SHLIB_SUFFIX, -1);

		Tcl_IncrRefCount(pt1_obj);
		Tcl_IncrRefCount(pt2_obj);
		Tcl_IncrRefCount(pt3_obj);

#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
		pathObjv[pathObjc++] = pt1_obj;
		pathObjv[pathObjc++] = pt2_obj;
		pathObjv[pathObjc++] = pt3_obj;

		pathList = Tcl_NewListObj(pathObjc, pathObjv);
		Tcl_IncrRefCount(pathList);

		ckfree((char *)pathObjv);
		Tcl_DecrRefCount(pt1_obj);
		Tcl_DecrRefCount(pt2_obj);
		Tcl_DecrRefCount(pt3_obj);
		Tcl_DecrRefCount(env_obj);

		tmp_obj = Tcl_FSJoinPath(pathList, -1);
		Tcl_IncrRefCount(tmp_obj);
		Tcl_DecrRefCount(pathList);
		native = Tcl_FSGetNativePath(tmp_obj);

#elif ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION == 3))
		pathObjv[pathObjc++] = Tcl_GetString(pt1_obj);
		pathObjv[pathObjc++] = Tcl_GetString(pt2_obj);
		pathObjv[pathObjc++] = Tcl_GetString(pt3_obj);

		Tcl_JoinPath(pathObjc, pathObjv, &result);

		ckfree((char *)pathObjv);
		Tcl_DecrRefCount(pt1_obj);
		Tcl_DecrRefCount(pt2_obj);
		Tcl_DecrRefCount(pt3_obj);
		Tcl_DecrRefCount(env_obj);
		native = Tcl_DStringValue(&result);
#endif

	}

	handle = DLOPEN(native, RTLD_NOW | RTLD_GLOBAL);

	if (handle == NULL) {
		fprintf(stderr, "%s(): Failed to load %s with error %s\n",
			"Oratcl_Init",
			native,
			DLERROR);
		if (ora_lib) {
			fprintf(stderr, 
				"%s(): ORACLE_LIBRARY = %s : file not found.\n",
				"Oratcl_Init",
				native);
		}

		if (ora_lib == NULL) {
#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
			Tcl_DecrRefCount(tmp_obj);
#elif ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION == 3))
			Tcl_DStringFree(&result);
#endif
		} else {
			ckfree((char *) ora_lib);
		}
		return TCL_ERROR;
	}

	if (ora_lib == NULL) {
#if ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION > 3))
		Tcl_DecrRefCount(tmp_obj);
#elif ((TCL_MAJOR_VERSION == 8) && (TCL_MINOR_VERSION == 3))
		Tcl_DStringFree(&result);
#endif
	} else {
		ckfree((char *) ora_lib);
	}

#else

	handle = LoadLibrary(TEXT("OCI.DLL"));
	if (handle == NULL || handle == INVALID_HANDLE_VALUE) {
		last_error = GetLastError();
		fprintf(stderr, "%s(): %s with error %lu",
			"Oratcl_Init",
			"Failed loading oci.dll symbols",
			(unsigned long) last_error);
		return TCL_ERROR;
	}

#endif	/* WIN32 */

	DLSYM(handle, "OCIEnvCreate",	OCI_EnvCreate,	     OCIENVCREATE);
	DLSYM(handle, "OCIInitialize",	OCI_Initialize,	     OCIINITIALIZE);
	DLSYM(handle, "OCIEnvInit",	OCI_EnvInit,	     OCIENVINIT);
	DLSYM(handle, "OCIHandleAlloc",	OCI_HandleAlloc,     OCIHANDLEALLOC);
	DLSYM(handle, "OCIHandleFree",	OCI_HandleFree,	     OCIHANDLEFREE);
	DLSYM(handle, "OCIAttrGet",	OCI_AttrGet,	     OCIATTRGET);
	DLSYM(handle, "OCIAttrSet",	OCI_AttrSet,	     OCIATTRSET);
	DLSYM(handle, "OCIServerAttach", OCI_ServerAttach,   OCISERVERATTACH);
	DLSYM(handle, "OCIServerDetach", OCI_ServerDetach,   OCISERVERDETACH);
	DLSYM(handle, "OCISessionBegin", OCI_SessionBegin,   OCISESSIONBEGIN);
	DLSYM(handle, "OCISessionEnd",	OCI_SessionEnd,	     OCISESSIONEND);
	DLSYM(handle, "OCIErrorGet",	OCI_ErrorGet,	     OCIERRORGET);
	DLSYM(handle, "OCITransCommit",	OCI_TransCommit,     OCITRANSCOMMIT);
	DLSYM(handle, "OCITransRollback", OCI_TransRollback, OCITRANSROLLBACK);
	DLSYM(handle, "OCIServerVersion", OCI_ServerVersion, OCISERVERVERSION);
	DLSYM(handle, "OCITerminate",	OCI_Terminate,	     OCITERMINATE);
	DLSYM(handle, "OCIParamGet",	OCI_ParamGet,	     OCIPARAMGET);
	DLSYM(handle, "OCIParamSet",	OCI_ParamSet,	     OCIPARAMSET);
	DLSYM(handle, "OCIDescribeAny",	OCI_DescribeAny,     OCIDESCRIBEANY);
	DLSYM(handle, "OCIBreak",	OCI_Break,	     OCIBREAK);
	DLSYM(handle, "OCIReset",	OCI_Reset,	     OCIRESET);
	DLSYM(handle, "OCIDefineByPos",	OCI_DefineByPos,     OCIDEFINEBYPOS);
	DLSYM(handle, "OCIBindByName",	OCI_BindByName,	     OCIBINDBYNAME);
	DLSYM(handle, "OCIStmtPrepare",	OCI_StmtPrepare,     OCISTMTPREPARE);
	DLSYM(handle, "OCIStmtExecute",	OCI_StmtExecute,     OCISTMTEXECUTE);
	DLSYM(handle, "OCIStmtFetch",	OCI_StmtFetch,	     OCISTMTFETCH);

	DLSYM(handle, "OCIStmtGetPieceInfo", OCI_StmtGetPieceInfo,
		OCISTMTGETPIECEINFO);
	DLSYM(handle, "OCIStmtSetPieceInfo", OCI_StmtSetPieceInfo,
		OCISTMTSETPIECEINFO);
	DLSYM(handle, "OCIDescriptorAlloc",  OCI_DescriptorAlloc, 
		OCIDESCRIPTORALLOC);
	DLSYM(handle, "OCIDescriptorFree",   OCI_DescriptorFree, 
		OCIDESCRIPTORFREE);
	DLSYM(handle, "OCILobRead",          OCI_LobRead, 
		OCILOBREAD);
	DLSYM(handle, "OCILobGetLength",     OCI_LobGetLength, 
		OCILOBGETLENGTH);

	/* sanity check at least one symbol */
	if (OCI_Initialize == NULL) {
	    DLCLOSE(handle);
	    Tcl_AppendResult(interp,
		    "Oratcl_Init failed to find symbols in dll",
		    (char *) NULL);
	    return TCL_ERROR;
	}

	OratclStatePtr = (OratclState *) ckalloc (sizeof(OratclState));
	StateListPtr = (OratclStateList *) ckalloc (sizeof(OratclStateList));

	StateListPtr->state = OratclStatePtr;
	StateListPtr->next = NULL;
	StateListPtr->prev = NULL;

	/* insert at head of list */
	if (OratclSLP == NULL) {
		OratclSLP = StateListPtr;
	} else {
		StateListPtr->next = OratclSLP;
		OratclSLP->prev = StateListPtr;
		OratclSLP = StateListPtr;
	}

	OratclStatePtr->logHash = (Tcl_HashTable *) ckalloc(sizeof(Tcl_HashTable));
	Tcl_InitHashTable(OratclStatePtr->logHash, TCL_STRING_KEYS);
	OratclStatePtr->logid = -1;

	OratclStatePtr->stmHash = (Tcl_HashTable *) ckalloc(sizeof(Tcl_HashTable));
	Tcl_InitHashTable(OratclStatePtr->stmHash, TCL_STRING_KEYS);
	OratclStatePtr->stmid = -1;

	/* check if already initialized */
	if (!OratclInitFlag) {

		OratclInitFlag = 1;

		OMV_zero	= Tcl_NewIntObj(0);
		Tcl_IncrRefCount(OMV_zero);

		Tcl_CreateExitHandler ((Tcl_ExitProc *) Oratcl_Exit,
				       (ClientData) OratclStatePtr);
	}

	/*
	 * Initialize the new Tcl commands
	 */

	Tcl_CreateObjCommand (interp,
			      "oralogon",
			      Oratcl_Logon,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oralogoff",
			      Oratcl_Logoff,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oracommit",
			      Oratcl_Commit,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraroll",
			      Oratcl_Roll,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraautocom",
			      Oratcl_Autocom,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orainfo",
			      Oratcl_Info,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oramsg",
			      Oratcl_Message,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oradesc",
			      Oratcl_Describe,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraldalist",
			      Oratcl_Lda_List,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraopen",
			      Oratcl_Open,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraclose",
			      Oratcl_Close,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orasql",
			      Oratcl_Sql,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oracols",
			      Oratcl_Cols,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orabindexec",
			      Oratcl_Bindexec,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraplexec",
			      Oratcl_PLexec,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orastmlist",
			      Oratcl_Stm_List,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraconfig",
			      Oratcl_Config,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::longread",
			      Oratcl_LongRead,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::longwrite",
			      Oratcl_LongWrite,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraparse",
			      Oratcl_Parse,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::oraparse",
			      Oratcl_Parse,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orabind",
			      Oratcl_Bind,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::orabind",
			      Oratcl_Bind,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "oraexec",
			      Oratcl_Exec,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::oraexec",
			      Oratcl_Exec,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orafetch",
			      Oratcl_Fetch,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::orafetch",
			      Oratcl_Fetch,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "orabreak",
			      Oratcl_Break,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateObjCommand (interp,
			      "::oratcl::orabreak",
			      Oratcl_Break,
			      (ClientData) OratclStatePtr,
			      (Tcl_CmdDeleteProc *) NULL);

	/* set some OCI constants for ease of use */

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		    "OCI_SUCCESS",
		    STR_OCI_SUCCESS,
		    TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		    "OCI_SUCCESS_WITH_INFO",
		    STR_OCI_SUCCESS_WITH_INFO,
		    TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		     "OCI_ERROR",
		     STR_OCI_ERROR,
		     TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		    "OCI_INVALID_HANDLE",
		    STR_OCI_INVALID_HANDLE,
		    TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		     "OCI_STILL_EXECUTING",
		     STR_OCI_STILL_EXECUTING,
		     TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		    "OCI_NO_DATA",
		    STR_OCI_NO_DATA,
		    TCL_LEAVE_ERR_MSG);

	Tcl_SetVar2(interp,
		    "::oratcl::codes",
		    "OCI_NEED_DATA",
		    STR_OCI_NEED_DATA,
		    TCL_LEAVE_ERR_MSG);

	/* callback - clean up procs left open on interpreter deletetion */
	Tcl_CallWhenDeleted(interp,
			    (Tcl_InterpDeleteProc *) Oratcl_Delete,
			    (ClientData) OratclStatePtr);

	rc = Oralob_Init(interp);
	rc = Oralong_Init(interp);

	if (Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION) != TCL_OK) {
		return TCL_ERROR;
	}

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_SafeInit --
 *	call the standard init point.
 *----------------------------------------------------------------------
 */

int
Oratcl_SafeInit (interp)
	Tcl_Interp *interp;
{
	int result;

	result = Oratcl_Init(interp);
	return (result);
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Checkerr
 *   set the oracle return code and error message
 *----------------------------------------------------------------------
 */

void
Oratcl_Checkerr (interp, errhp, rc, flag, rcPtr, errPtr)
	Tcl_Interp	*interp;
	OCIError	*errhp;
	sword		rc;
	int		flag;
	int		*rcPtr;
	Tcl_DString	*errPtr;
{

	Tcl_DString	errStr;
	char		*errstr = NULL;
	sb4		errcode = 0;
	Tcl_Obj		*tmp_obj;

	Tcl_DStringInit(&errStr);

	switch (rc) {
		case OCI_SUCCESS_WITH_INFO:
		case OCI_NEED_DATA:
		case OCI_NO_DATA:
		case OCI_ERROR:
		case OCI_STILL_EXECUTING:
			if ((errstr = (char *) ckalloc(ORA_MSG_SIZE)) != NULL) {
				errstr[0] = '\0';
				OCI_ErrorGet ((dvoid *) errhp,
					      (ub4) 1,
					      (text *) NULL,
					      &errcode,
					      (text *) errstr,
					      (ub4) ORA_MSG_SIZE,
					      (ub4) OCI_HTYPE_ERROR); 
				/* remove trailing carriage return from Oracle string */
				errstr[strlen(errstr) - 1] = '\0';
				Tcl_DStringAppend(&errStr, errstr, -1);
				ckfree (errstr);
			}
			break;
		case OCI_SUCCESS:
		case OCI_INVALID_HANDLE:
		case OCI_CONTINUE:
			errcode = rc;
			break;
		default:
			Tcl_DStringAppend(&errStr, "Error - Unknown", -1);
	}

	if (flag==1) {
		tmp_obj = Tcl_NewStringObj(Tcl_DStringValue(&errStr),
					   Tcl_DStringLength(&errStr));
		Tcl_IncrRefCount(tmp_obj);
		Tcl_SetObjResult(interp, tmp_obj);
		Tcl_DecrRefCount(tmp_obj);
	}

	if (rcPtr) {
		*rcPtr = errcode;
	}

	if (errPtr) {
		Tcl_DStringAppend(errPtr,
				  Tcl_DStringValue(&errStr),
				  Tcl_DStringLength(&errStr));
	}

	Tcl_DStringFree(&errStr);
}


/*
 *----------------------------------------------------------------------
 * Oratcl_ColAlloc
 *   return a new OratclCols with nulled pointers and zeroed fields
 *----------------------------------------------------------------------
 */

OratclCols *
Oratcl_ColAlloc(fetchrows)
	int	fetchrows;
{
	OratclCols *ColPtr;

	if ((ColPtr = (OratclCols *) ckalloc(sizeof (OratclCols))) != NULL) {
		ColPtr->next = NULL;
		ColPtr->column.typecode = 0;
		Tcl_DStringInit(&ColPtr->column.typename);
		ColPtr->column.size = 0;
		ColPtr->column.name = NULL;
		ColPtr->column.namesz = 0;
		ColPtr->column.prec = 0;
		ColPtr->column.scale = 0;
		ColPtr->column.nullok = 0;
		ColPtr->column.valuep = NULL;
		ColPtr->column.valuesz	= 0;
		ColPtr->defnp = NULL;
		ColPtr->bindp = NULL;
		ColPtr->nFetchRows = fetchrows;
		if ((ColPtr->indp = (sb2 *) ckalloc (sizeof(ColPtr->indp) * fetchrows)) == NULL) {
			fprintf(stderr, "ColPtr->indp is NULL\n");
		}
		if ((ColPtr->rlenp = (ub2 *) ckalloc (sizeof(ColPtr->rlenp) * fetchrows)) == NULL) {
			fprintf(stderr, "ColPtr->rlenp is NULL\n");
		}
		if ((ColPtr->rcodep = (ub2 *) ckalloc (sizeof(ColPtr->rcodep) * fetchrows)) == NULL) {
			fprintf(stderr, "ColPtr->rcodep is NULL\n");
		}
		ColPtr->indp[0] = 0;
		ColPtr->rlenp[0] = 0;
		ColPtr->rcodep[0] = 0;
		ColPtr->bindPtr = NULL;
	}
	return ColPtr;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_ColFree
 *      free elements of OratclCols or list of OratclCols
 *----------------------------------------------------------------------
 */

void
Oratcl_ColFree (ColPtr)
	OratclCols  *ColPtr;
{
	OratclCols  *next;

	while (ColPtr != NULL) {
		next = ColPtr->next;
		if (ColPtr->column.name != NULL) {
			ckfree((char *) ColPtr->column.name);
		}

		if (ColPtr->column.valuep != NULL) {

			/* 
			 * if column is a LOB, the LobLocator has been stored in valuep
			 */
			if( ( ColPtr->dty == SQLT_CLOB ) || ( ColPtr->dty == SQLT_BLOB ) ){
				int    nRow;
				for( nRow = 0; nRow < ColPtr->nFetchRows; nRow++) {
					OCILobLocator  **pLocator;
					pLocator = (OCILobLocator**)(ColPtr->column.valuep
								   + ColPtr->column.valuesz * nRow);
					OCI_DescriptorFree((dvoid*)*pLocator,
							   (ub4) OCI_DTYPE_LOB);
				}
			}

			ckfree(ColPtr->column.valuep);

		}

		Tcl_DStringFree(&ColPtr->column.typename);
		
		if (ColPtr->indp) {
			ckfree ((char *) ColPtr->indp);
		}

		if (ColPtr->rlenp) {
			ckfree ((char *) ColPtr->rlenp);
		}

		if (ColPtr->rcodep) {
			ckfree ((char *) ColPtr->rcodep);
		}

		ckfree((char *) ColPtr);
		ColPtr = next;
	}
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Stmfree
 *      free elements of OratclStms
 *----------------------------------------------------------------------
 */

void
Oratcl_StmFree (StmPtr)
	OratclStms	*StmPtr;
{
	if (StmPtr != NULL) {

		OCI_HandleFree((dvoid *) StmPtr->stmhp,
			       (ub4) OCI_HTYPE_STMT);

		Oratcl_ColFree(StmPtr->col_list);
		Oratcl_ColFree(StmPtr->bind_list);

		Tcl_DecrRefCount(StmPtr->nullvalue);
		Tcl_DStringFree(&StmPtr->ora_err);
		Tcl_DStringFree(&StmPtr->datavar);

		if (StmPtr->sub_list != NULL)
			ckfree((char *) StmPtr->sub_list);

		ckfree((char *) StmPtr);

	}
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Logfree
 *      free elements of OratclLogs
 *----------------------------------------------------------------------
 */

void
Oratcl_LogFree (LogPtr)
	OratclLogs	*LogPtr;
{
	if (LogPtr != NULL) {

		if (LogPtr->usrhp)
			(void) OCI_HandleFree((dvoid *) LogPtr->usrhp,
					      (ub4) OCI_HTYPE_SESSION);
		if (LogPtr->svchp)
			(void) OCI_HandleFree((dvoid *) LogPtr->svchp,
					      (ub4) OCI_HTYPE_SVCCTX);
		if (LogPtr->srvhp)
			(void) OCI_HandleFree((dvoid *) LogPtr->srvhp,
					      (ub4) OCI_HTYPE_SERVER);
		if (LogPtr->errhp)
			(void) OCI_HandleFree((dvoid *) LogPtr->errhp,
					      (ub4) OCI_HTYPE_ERROR);
		if (LogPtr->envhp)
			(void) OCI_HandleFree((dvoid *) LogPtr->envhp,
					      (ub4) OCI_HTYPE_ENV);
		if (LogPtr->failovercallback != NULL) {
			ckfree(LogPtr->failovercallback);
			LogPtr->failovercallback = NULL;
		}

		ckfree((char *) LogPtr);
	}
}


/*
 *----------------------------------------------------------------------
 * Oratcl_ColAppend
 *      appends column results to tcl result
 *----------------------------------------------------------------------
 */

int
Oratcl_ColAppend (interp, StmPtr, listvar, arrayvar, hashType)
	Tcl_Interp	*interp;
	OratclStms	*StmPtr;
	Tcl_Obj		*listvar;
	Tcl_Obj		*arrayvar;
	int		hashType;
{
	int		rn;
	OratclCols 	*ColPtr;
	OratclCols	*col;
	char		*null_str;
	int		idx;
	int		iTcl;

	Tcl_DString	uniStr;
	Tcl_DString	lobStr;
	char 		*tmp = NULL;
	char		*pValue = NULL;
	Tcl_Obj		*val_obj;
	Tcl_Obj		*tmp_obj;
	Tcl_Obj		*lst_obj;
	OratclLogs	*LogPtr;

	/* quick sanity check */
	rn = StmPtr->fetchidx;
	if (rn < 0 || rn >= StmPtr->fetchmem) {
		/* TMH Does this ever happen ??? if so can it be tested for? */
		return 0;
	}

	if (arrayvar) {
		iTcl = Tcl_UnsetVar2(interp,
				     Tcl_GetStringFromObj(arrayvar, NULL),
				     (char *) NULL,
				     0);
	}

	if (StmPtr->sqltype == OCI_STMT_BEGIN ||
	    StmPtr->sqltype == OCI_STMT_DECLARE) {
		ColPtr = StmPtr->bind_list;
	} else {
		ColPtr = StmPtr->col_list;
	}

	null_str = Tcl_GetStringFromObj(StmPtr->nullvalue, NULL);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);
	Tcl_DStringSetLength(&StmPtr->datavar, 0);

	/* 
	 * Check for a LOB column and allocate a buffer piece.
	 * The buffer piece can be used for multiple columns.
	 */
	for (col = ColPtr, idx = 1; col != NULL; col = col->next, idx++) {
		if (( col->dty == SQLT_BLOB ) || ( col->dty == SQLT_CLOB )) {
			pValue = ckalloc( StmPtr->lobpsize + 1 );
			if( pValue == NULL ) {
				fprintf(stderr, "error:: pValue is NULL return -1\n");
				return -1;
			}
			pValue[0] = '\0';
			break;
		}
	}

	for (col = ColPtr, idx = 1; col != NULL; col = col->next, idx++) {
      
		Tcl_DStringInit(&uniStr);
		Tcl_DStringInit(&lobStr);

		/* for cursor type, just return a null */
		/* get pointer to next row column data buffer */

		if ((sb2) col->indp[rn] == -1) {
			if (col->column.typecode == SQLT_CUR) {
				tmp = "";
			} else {
				/* default :: if number "0" else "" */
				if (*null_str == 'd'
				   && strcmp(null_str,"default") == 0) {

					if (col->column.typecode == SQLT_NUM) {
						tmp = "0";
					} else {
						tmp = "";
					}
				} else {
					/* return user defined nullvalue */
					tmp = null_str;
				}
			}
		} else if (col->column.valuesz > 0) {

			/*
			 *  Read the LOB value
			 */

			if (( col->dty == SQLT_BLOB ) || ( col->dty == SQLT_CLOB )) {
				OCILobLocator** pLocator;
				ub4             nLength = 0;
				ub4             nAMTP;
				sword           nStatus;                    
				ub4             nOffset       = 1;

				pLocator = (OCILobLocator**)(col->column.valuep + (rn * col->column.valuesz));

				(void)OCI_LobGetLength( LogPtr->svchp,
							LogPtr->errhp,
							*pLocator,
							&nLength );

				if( nLength > 0 ) {

					nAMTP = nLength;

					do{

						nStatus = OCI_LobRead(LogPtr->svchp,
								      LogPtr->errhp,
								      *pLocator,
								      &nAMTP,
								      (ub4)nOffset,
								      (dvoid*)(pValue),
								      StmPtr->lobpsize,
								      (dvoid *)0,
								      (sb4 (*)(dvoid *, CONST dvoid *, ub4, ub1)) 0,
								      (ub2) 0,
								      (ub1) SQLCS_IMPLICIT);

						if( ( nStatus != OCI_SUCCESS ) && ( nStatus != OCI_NEED_DATA ) ) {
							fprintf(stderr, "nStatus = %d\n", nStatus);
							fprintf(stderr, "error:: return -3\n");
							ckfree(pValue);
							Tcl_DStringFree(&lobStr);
							return -3;
						}

						if( nAMTP == 0 ) {
							fprintf(stderr, "error:: return -4\n");
							ckfree(pValue);
							Tcl_DStringFree(&lobStr);
							return -4;
						}


						Tcl_DStringAppend(&lobStr, pValue, nAMTP);

					} while ( nStatus == OCI_NEED_DATA );

					tmp = Tcl_DStringValue(&lobStr);

				} else {
					tmp = "";
				}                


			} else {
				tmp = col->column.valuep + (rn * col->column.valuesz);
			}

			if (StmPtr->utfmode) {
				Tcl_ExternalToUtfDString(NULL,
							 tmp,
							 -1,
							 &uniStr);
				tmp = Tcl_DStringValue(&uniStr);
			}

		} else {
			tmp = "";
		}

		if (arrayvar) {

			val_obj = Tcl_NewStringObj((char *) tmp, -1);
			Tcl_IncrRefCount(val_obj);

			if (hashType) {
				tmp_obj = Tcl_NewStringObj((char *) col->column.name,
							   (int) col->column.namesz);
			} else {
				tmp_obj = Tcl_NewIntObj(idx);
			}

			Tcl_IncrRefCount(tmp_obj);
			Tcl_ObjSetVar2(interp,
					arrayvar,
					tmp_obj,
					val_obj,
					TCL_LEAVE_ERR_MSG);
			Tcl_DecrRefCount(tmp_obj);

			Tcl_DecrRefCount(val_obj);
		}

		if (listvar) {
			Tcl_DStringAppendElement(&StmPtr->datavar, tmp);
		}

		Tcl_DStringFree(&uniStr);
		Tcl_DStringFree(&lobStr);
	}

	if (listvar) {
		lst_obj = Tcl_NewStringObj(Tcl_DStringValue(&StmPtr->datavar),
					   Tcl_DStringLength(&StmPtr->datavar));
		Tcl_IncrRefCount(lst_obj);
		Tcl_ObjSetVar2(interp, listvar, NULL, lst_obj, 0);
		Tcl_DecrRefCount(lst_obj);
	}

	if (pValue) {
		ckfree(pValue);
	}

	StmPtr->fetchidx += 1;
	StmPtr->append_cnt += 1;
	StmPtr->ora_rc = 0;
	Tcl_SetObjResult(interp, OMV_zero);
	StmPtr->ora_row = StmPtr->append_cnt;
	StmPtr->fetch_ok = 1;
	return 0;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_ColDescribe
 *   parse result columns, allocate memory for fetches
 *   return -1 on error, 1 if ok
 *----------------------------------------------------------------------
 */

int
Oratcl_ColDescribe (interp, StmPtr)
	Tcl_Interp 	*interp;
	OratclStms	*StmPtr;
{
	OratclLogs	*LogPtr;

	sword		rc;

	OratclCols	*new_col_head;
	OratclCols	*new_col;
	OratclCols	*last_col;

	OCIParam	*parmdp;
	ub4		parmcnt;
	ub4		parmix;

	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	/* get the parameter count info */
	parmcnt = 0;
	rc = OCI_AttrGet( (dvoid *) StmPtr->stmhp,
			 (ub4) OCI_HTYPE_STMT,
			 (ub4 *) &parmcnt,
			 (ub4) 0,
			 OCI_ATTR_PARAM_COUNT,
			 LogPtr->errhp);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc != OCI_SUCCESS) {
		return -1;
	}

	new_col_head = Oratcl_ColAlloc(StmPtr->fetchrows);
	if (new_col_head == NULL) {
		return -1;
	}
	new_col      = new_col_head;
	last_col     = new_col_head;

	for (parmix = 1; parmix <= parmcnt; parmix++) {

		rc = OCI_ParamGet((dvoid *) StmPtr->stmhp,
				  (ub4) OCI_HTYPE_STMT,
				  (OCIError *) LogPtr->errhp,
				  (dvoid *) &parmdp,
				  (ub4) parmix);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc != OCI_SUCCESS) {
			Oratcl_ColFree(new_col_head);
			return -1;
		}

		rc = Oratcl_Attributes(interp,
				       LogPtr->errhp,
				       parmdp,
				       &new_col->column,
				       0);
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			Oratcl_ColFree(new_col_head);
			return -1;
		}

		new_col->dty = SQLT_STR;
		new_col->column.valuesz = new_col->column.size;
		
		switch (new_col->column.typecode) {
		case SQLT_CHR:					/* 1	*/
		case SQLT_CUR:					/* 102	*/
			break;
		case SQLT_LNG:					/* 8	*/
		case SQLT_LBI:					/* 24	*/
			new_col->column.valuesz = StmPtr->longsize;
			break;
		case SQLT_BIN:					/* 23	*/
			new_col->column.valuesz = new_col->column.size * 2;
			break;
		case SQLT_NUM:					/* 2	*/
			new_col->column.valuesz = StmPtr->numbsize;
			break;
		case SQLT_DAT:					/* 12	*/
			new_col->column.valuesz = StmPtr->datesize;
			break;
		case SQLT_RID:					/* 11	*/
		case SQLT_RDD:					/* 104	*/
			new_col->column.valuesz = 140;
			break;
		case SQLT_TIMESTAMP:				/* 187	*/
		case SQLT_TIMESTAMP_TZ:				/* 188  */
		case SQLT_INTERVAL_YM:				/* 189  */
		case SQLT_INTERVAL_DS:				/* 190  */
		case SQLT_TIMESTAMP_LTZ:			/* 232  */
			new_col->column.valuesz = 75;
			break;
		case SQLT_CLOB:                                 /* 112  */
		case SQLT_BLOB:                                 /* 113  */
			new_col->column.valuesz = sizeof(OCILobLocator*);
			new_col->dty = new_col->column.typecode;
			break;
		default:
			/* Should not be reached */
			break;
		}

		StmPtr->fetchmem = StmPtr->fetchrows;

		if ( ( new_col->dty == SQLT_BLOB ) || (new_col->dty == SQLT_CLOB ) ) {
			
			int nRow;
			char *pLocators;
			pLocators = ckalloc (new_col->column.valuesz * StmPtr->fetchrows);
			for (nRow = 0; nRow < StmPtr->fetchrows; nRow++ ) {
				OCILobLocator **pLocator;
				pLocator = (OCILobLocator**)(pLocators + nRow * new_col->column.valuesz);
				rc = OCI_DescriptorAlloc( (dvoid *)LogPtr->envhp,
							 (dvoid **)pLocator,
							 (ub4)OCI_DTYPE_LOB,
							 (size_t) 0,
							 (dvoid **) 0 );

				Oratcl_Checkerr(interp,
						LogPtr->errhp,
						rc,
						1,
						&StmPtr->ora_rc,
						&StmPtr->ora_err);

				if (rc != OCI_SUCCESS) {
					Oratcl_ColFree(new_col_head);
					return -1;
				}

			}

			new_col->column.valuep = pLocators;
			rc = OCI_DefineByPos(StmPtr->stmhp,
					     &new_col->defnp,
					     LogPtr->errhp,
					     (ub4) parmix,
					     (dvoid *) new_col->column.valuep,
					     (sb4) 0,
					     new_col->dty,
					     (sb2 *) new_col->indp,
					     (ub2 *) new_col->rlenp,
					     (ub2 *) new_col->rcodep,
					     (ub4) OCI_DEFAULT);

		} else {

			new_col->column.valuesz = new_col->column.valuesz + 1;
			new_col->column.valuep =
				ckalloc (new_col->column.valuesz * StmPtr->fetchrows);

			rc = OCI_DefineByPos(StmPtr->stmhp,
					     &new_col->defnp,
					     LogPtr->errhp,
					     (ub4) parmix,
					     (dvoid *) new_col->column.valuep,
					     (sb4) new_col->column.valuesz,
					     new_col->dty,
					     (sb2 *) new_col->indp,
					     (ub2 *) new_col->rlenp,
					     (ub2 *) new_col->rcodep,
					     (ub4) OCI_DEFAULT);
		}

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc != OCI_SUCCESS) {
			Oratcl_ColFree(new_col_head);
			return -1;
		}

		last_col = new_col;
		new_col = Oratcl_ColAlloc(StmPtr->fetchrows);
		if (new_col == NULL) {
			Oratcl_ColFree(new_col_head);
			return -1;
		}
		last_col->next = new_col;

	}

	last_col->next = NULL;
	Oratcl_ColFree(new_col);
	Oratcl_ColFree(StmPtr->col_list);
	StmPtr->col_list = new_col_head;

	return (parmcnt);
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Logon --
 *    Implements the oralogon command:
 *    usage: oralogon connect_string ?-async? ?-failovercallback <procname>?
 *    connect_string should be a valid oracle logon string:
 *         name
 *         name/password
 *         name@d:dbname
 *         name/password@d:dbname
 *	   sysdba
 *	   sysoper
 *
 *    results:
 *	handle - a character string of newly open logon handle
 *      TCL_OK - connect successful
 *      TCL_ERROR - connect not successful - error message returned
 *----------------------------------------------------------------------
 */

int
Oratcl_Logon (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	OCIFocbkStruct	failover;
	int		i;
	Tcl_HashEntry	*logHashPtr = NULL;
	OratclLogs	*LogPtr = NULL;
	int		new;

	int		objix;
	int		tcl_return = TCL_OK;

	char 		*con_str = NULL;
	char		*cpy_str = NULL;
	char		*cpy_pos1 = NULL;
	char		*cpy_pos2 = NULL;
	int		con_len;
	sword		rc = 0;

	int		attached = 0;

	char		*ora_name = NULL;
	char		*ora_pass = NULL;
	char		*ora_conn = NULL;

	int		ora_namelen = 0;
	int		ora_passlen = 0;
	int		ora_connlen = 0;

	ub4		oci_cred = OCI_CRED_RDBMS;
	ub4		oci_conn = OCI_DEFAULT;

	Tcl_Obj		*handlep1 = NULL;
	Tcl_Obj		*handlep2 = NULL;

	char		*p = NULL;
	char		*tbuf = NULL;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "connect_string ?-async?");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) ckalloc (sizeof (OratclLogs));

	/* generate an lda name and put it in the hash table. */
	OratclStatePtr->logid++;

	handlep1 = Tcl_NewStringObj(OraHandlePrefix, -1);
	Tcl_IncrRefCount(handlep1);

	handlep2 = Tcl_NewIntObj(OratclStatePtr->logid);
	Tcl_IncrRefCount(handlep2);
	Tcl_AppendObjToObj(handlep1, handlep2);
	Tcl_DecrRefCount(handlep2);

	logHashPtr = Tcl_CreateHashEntry(OratclStatePtr->logHash,
					 Tcl_GetStringFromObj(handlep1 ,NULL),
					 &new);

	LogPtr->envhp = NULL;
	LogPtr->errhp = NULL;
	LogPtr->svchp = NULL;
	LogPtr->srvhp = NULL;
	LogPtr->usrhp = (OCISession *) 0;
	LogPtr->autocom = 0;
	LogPtr->async = 0;
	LogPtr->ora_rc = OCI_SUCCESS;
	LogPtr->failovercallback = NULL;
	Tcl_DStringInit(&LogPtr->ora_err);
	LogPtr->logid = OratclStatePtr->logid;

	Tcl_SetHashValue(logHashPtr,  LogPtr);

	con_str = Tcl_GetStringFromObj(objv[1], &con_len);
	cpy_str = ckalloc (con_len + 1);
	memcpy (cpy_str, con_str, con_len);
	cpy_str[con_len] = '\0';

	/* break the connect string into components. */
	cpy_pos1 = strchr(cpy_str, '/');
	cpy_pos2 = strchr(cpy_str, '@');

	if (cpy_pos1 != NULL && cpy_pos2 != NULL) {
		*cpy_pos1 = '\0';
		*cpy_pos2 = '\0';
		ora_name = cpy_str;
		ora_pass = cpy_pos1 + 1;
		ora_conn = cpy_pos2 + 1;
	} else if (cpy_pos1 != NULL) {
		*cpy_pos1 = '\0';
		ora_name = cpy_str;
		ora_pass = cpy_pos1 + 1;
	} else if (cpy_pos2 != NULL) {
		*cpy_pos2 = '\0';
		ora_name = cpy_str;
		ora_conn = cpy_pos2 + 1;
	} else {
		if (strcasecmp(cpy_str, "sysdba") == 0) {
			oci_conn = OCI_SYSDBA;
			ora_name = "";
			ora_pass = "";
		} else if (strcasecmp(cpy_str, "sysoper") == 0) {
			oci_conn = OCI_SYSOPER;
			ora_name = "";
			ora_pass = "";
		} else {
			ora_name = cpy_str;
		}
	}

	if (ora_name)
		ora_namelen = strlen(ora_name);

	if (ora_pass)
		ora_passlen = strlen(ora_pass);

	if (ora_conn)
		ora_connlen = strlen(ora_conn);

	rc = OCI_EnvCreate ((OCIEnv **) &LogPtr->envhp,
#ifdef TCL_THREADS
			    OCI_OBJECT | OCI_THREADED,
#else
			    OCI_OBJECT,
#endif
			    (dvoid *)0,
			    NULL,
			    NULL,
			    NULL,
			    0,
			    (dvoid *) 0 );

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	(void) OCI_HandleAlloc( (dvoid *) LogPtr->envhp,
			       (dvoid **) &LogPtr->errhp,
			       OCI_HTYPE_ERROR,
			       (size_t) 0,
			       (dvoid **) 0);

	/* server contexts */
	(void) OCI_HandleAlloc( (dvoid *) LogPtr->envhp,
			       (dvoid **) &LogPtr->srvhp,
			       OCI_HTYPE_SERVER,
			       (size_t) 0,
			       (dvoid **) 0);

	(void) OCI_HandleAlloc( (dvoid *) LogPtr->envhp,
			       (dvoid **) &LogPtr->svchp,
			       OCI_HTYPE_SVCCTX,
			       (size_t) 0,
			       (dvoid **) 0);


	/*
	 * Attach to Server
	 */

	rc = OCI_ServerAttach(LogPtr->srvhp,
			      LogPtr->errhp,
			      (text *) ora_conn,
			      ora_connlen,
			      0);

	if (rc != OCI_SUCCESS) {
		attached = 1;
		tcl_return = TCL_ERROR;
		goto common_exit;
	}


	/*
	 * set attribute server context in the service context
	 */

	rc = OCI_AttrSet( (dvoid *) LogPtr->svchp,
			   OCI_HTYPE_SVCCTX,
			   (dvoid *)LogPtr->srvhp,
			   (ub4) 0,
			   OCI_ATTR_SERVER,
			   (OCIError *) LogPtr->errhp);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}


	/* 
	 * allocate a session handle
	 */

	rc = OCI_HandleAlloc((dvoid *) LogPtr->envhp,
			     (dvoid **)&LogPtr->usrhp,
			     (ub4) OCI_HTYPE_SESSION,
			     (size_t) 0,
			     (dvoid **) 0);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}


	/*
	 * set the username attribute
	 */

	rc = OCI_AttrSet((dvoid *) LogPtr->usrhp,
			 (ub4) OCI_HTYPE_SESSION,
			 (dvoid *) ora_name,
			 (ub4) ora_namelen,
			 (ub4) OCI_ATTR_USERNAME,
			 LogPtr->errhp);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/*
	 * set the password attribute
	 */

	rc = OCI_AttrSet((dvoid *) LogPtr->usrhp,
			 (ub4) OCI_HTYPE_SESSION,
			 (dvoid *) ora_pass,
			 (ub4) ora_passlen,
			 (ub4) OCI_ATTR_PASSWORD,
			 LogPtr->errhp);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if ((ora_namelen + ora_passlen) == 0) {
		oci_cred = OCI_CRED_EXT;
	}

	rc = OCI_SessionBegin (LogPtr->svchp,
			       LogPtr->errhp,
			       LogPtr->usrhp,
			       (ub4) oci_cred,
			       (ub4) oci_conn);

	if (rc == OCI_SUCCESS_WITH_INFO) {
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				0,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
	} else if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* check for options and deprecated keywords */
	for (i = 2; i < objc; i++) {
		p = Tcl_GetStringFromObj(objv[2], NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"async") == 0) {
			LogPtr->async = 1;
		}
		if (strcmp(p,"failovercallback") == 0) {
			if (objc > i) {
				i++;
				p = Tcl_GetStringFromObj(objv[i], NULL);

				tbuf = Tcl_GetStringFromObj(handlep1, NULL);

				/* append oralogon handle string */
				LogPtr->failovercallback = ckalloc(strlen(p) + strlen(tbuf) +2);
				sprintf(LogPtr->failovercallback, "%s %s", p, tbuf);
				LogPtr->interp = interp;
				failover.fo_ctx = (dvoid *)LogPtr;
				failover.callback_function = &callback_fn;

				/* OCI callback registration */
				rc = OCI_AttrSet(LogPtr->srvhp,
						 (ub4) OCI_HTYPE_SERVER,
						 (dvoid *) &failover,
						 (ub4) 0,
						 (ub4) OCI_ATTR_FOCBK,
						 LogPtr->errhp);

				if (rc != OCI_SUCCESS) {
					tcl_return = TCL_ERROR;
					goto common_exit;
				}
			}
		}
	}

	if (LogPtr->async == 1) {
		rc = OCI_AttrSet((dvoid *) LogPtr->srvhp,
				 (ub4) OCI_HTYPE_SERVER,
				 (dvoid *) 0,
				 (ub4) 0,
				 (ub4) OCI_ATTR_NONBLOCKING_MODE,
				 LogPtr->errhp);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
	}

	rc = OCI_AttrSet((dvoid *) LogPtr->svchp,
			 (ub4) OCI_HTYPE_SVCCTX,
			 (dvoid *) LogPtr->usrhp,
			 (ub4) 0,
			 (ub4) OCI_ATTR_SESSION,
			 LogPtr->errhp);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	Tcl_SetObjResult(interp, handlep1);

common_exit:

	if (tcl_return == TCL_ERROR) {

		if (rc != OCI_SUCCESS) {
			Oratcl_Checkerr(interp,
					LogPtr->errhp,
					rc,
					1,
					&LogPtr->ora_rc,
					&LogPtr->ora_err);
		}

		if (attached) {
			(void) OCI_ServerDetach(LogPtr->srvhp,
						LogPtr->errhp,
						(ub4) OCI_DEFAULT);
		}

		if (logHashPtr) {
			Tcl_DeleteHashEntry(logHashPtr);
		}

		if (LogPtr) {
			Oratcl_LogFree(LogPtr);
		}

	}

	if (handlep1)
		Tcl_DecrRefCount(handlep1);

	ckfree(cpy_str);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Logoff --
 *    Implements the oralogoff command:
 *    usage: oralogon lda_handle
 *       lda_handle should be a valid, open lda handle from oralogon
 *
 *    results:
 *	null string
 *      TCL_OK - logoff successful
 *      TCL_ERROR - logoff not successful - error message returned
 *----------------------------------------------------------------------
 */

int
Oratcl_Logoff (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	OratclLogs	*LogPtr;
	OratclStms	*StmPtr;
	Tcl_HashSearch  search;
	
	sword		rc;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
	Tcl_DStringInit(&LogPtr->ora_err);

	/* close the open statement handles for this connection */
	stmHashPtr = Tcl_FirstHashEntry(OratclStatePtr->stmHash, &search);
	while (stmHashPtr != NULL) {
		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
		if (StmPtr->logid == LogPtr->logid) {
			Oratcl_StmFree(StmPtr);
			Tcl_DeleteHashEntry(stmHashPtr);
			stmHashPtr = Tcl_FirstHashEntry(OratclStatePtr->stmHash, &search);
		} else {
			stmHashPtr = Tcl_NextHashEntry(&search);
		}
	}

	rc = OCI_SessionEnd(LogPtr->svchp,
			    LogPtr->errhp,
			    LogPtr->usrhp,
			    OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	rc = OCI_ServerDetach(LogPtr->srvhp,
			      LogPtr->errhp,
			      (ub4) OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	Oratcl_LogFree(LogPtr);

	Tcl_DeleteHashEntry(logHashPtr);

	Tcl_SetObjResult(interp, Tcl_NewIntObj(rc));

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Commit --
 *    Implements the oracommit command:
 *    usage: oracommit lda_handle
 *
 *    results:
 *	null string
 *      TCL_OK - transactions commited
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Commit (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	OratclLogs	*LogPtr;
	sword		rc;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
	Tcl_DStringInit(&LogPtr->ora_err);

	rc = OCI_TransCommit((dvoid *) LogPtr->svchp,
			     (dvoid *) LogPtr->errhp,
			     (ub4) OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Roll --
 *    Implements the oraroll command:
 *    usage: oraroll lda_handle
 *
 *    results:
 *	null string
 *      TCL_OK - transactions rolled back
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Roll (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	OratclLogs	*LogPtr;
	sword		rc;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
	Tcl_DStringInit(&LogPtr->ora_err);

	rc = OCI_TransRollback((dvoid *) LogPtr->svchp,
			       (dvoid *) LogPtr->errhp,
			       (ub4) OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Autocom --
 *    Implements the oraautocom command:
 *    usage: oraautocom lda_handle on|off
 *
 *    results:
 *	null string
 *      TCL_OK - auto commit set on or off
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Autocom (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	OratclLogs	*LogPtr;

	int		bool;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle on|off");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);

	Tcl_GetBooleanFromObj(interp, objv[2], &bool);
	LogPtr->autocom = bool;

	Tcl_SetObjResult(interp, Tcl_NewIntObj(bool));

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Info --
 *    Implements the orainfo command:
 *    usage: orainfo lda_handle
 *
 *    results:
 *	server information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_Info (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	OratclLogs	*LogPtr;
	OratclStms	*StmPtr;
	char		*logHashKey;

	sword		rc;
	static text	svr[ORA_MSG_SIZE];
	Tcl_Obj		*res_obj;
	ub4		serverStatus = 0;

	CONST84 char *options[] = {"server",
				   "status",
				   "version",
				   "loginhandle",
				   NULL};

	enum		optindex {OPT_SERVER,
				  OPT_STATUS,
				  OPT_VERSION,
				  OPT_LOGINHANDLE};

	int		index = 0;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "option ?args?");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if (Tcl_GetIndexFromObj(interp,
				objv[1],
				(CONST84 char **)options,
				"option",
				0,
				&index)) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if (index == OPT_VERSION) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(PACKAGE_VERSION, -1));
	}

	if (index == OPT_STATUS) {
		if (objc < 3) {
			Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
					       Tcl_GetStringFromObj(objv[2],
								    NULL));

		if (logHashPtr == NULL) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": lda_handle ",
					objv[2],
					" not valid");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);

		rc = OCI_AttrGet (LogPtr->srvhp,
				 OCI_HTYPE_SERVER,
				 (dvoid *)&serverStatus,
				 (ub4 *) 0,
				 OCI_ATTR_SERVER_STATUS,
				 LogPtr->errhp);

		switch (serverStatus) {
		case OCI_SERVER_NORMAL:
			res_obj = Tcl_NewIntObj(OCI_SERVER_NORMAL);
			break;
		case OCI_SERVER_NOT_CONNECTED:
			res_obj = Tcl_NewIntObj(OCI_SERVER_NOT_CONNECTED);
			break;
		default:
			Oratcl_ErrorMsg(interp,
					objv[0],
					": server status request failed",
					(Tcl_Obj *) NULL,
					(char *) NULL);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
		Tcl_IncrRefCount(res_obj);
		Tcl_SetObjResult(interp, res_obj);
		Tcl_DecrRefCount(res_obj);
	}

	if (index == OPT_SERVER) {
		if (objc < 3) {
			Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
					       Tcl_GetStringFromObj(objv[2],
								    NULL));

		if (logHashPtr == NULL) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": lda_handle ",
					objv[2],
					" not valid");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
		Tcl_DStringInit(&LogPtr->ora_err);

		rc = OCI_ServerVersion(LogPtr->svchp,
				       LogPtr->errhp,
				       (text *) &svr,
				       ORA_MSG_SIZE,
				       OCI_HTYPE_SVCCTX);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				0,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);

		if (rc != OCI_SUCCESS) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": server version request failed",
					(Tcl_Obj *) NULL,
					(char *) NULL);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		res_obj = Tcl_NewStringObj((char *) svr, -1);
		Tcl_IncrRefCount(res_obj);
		Tcl_SetObjResult(interp, res_obj);
		Tcl_DecrRefCount(res_obj);

	}

	if (index == OPT_LOGINHANDLE) {
		if (objc < 3) {
			Tcl_WrongNumArgs(interp, objc, objv, "stm_handle");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
					       Tcl_GetStringFromObj(objv[2],
								    NULL));

		if (stmHashPtr == NULL) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": stm_handle ",
					objv[2],
					" not open");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
		logHashKey = Tcl_GetHashKey(OratclStatePtr->logHash,
					    StmPtr->logHashPtr);

		res_obj = Tcl_NewStringObj((char *) logHashKey, -1);
		Tcl_IncrRefCount(res_obj);
		Tcl_SetObjResult(interp, res_obj);
		Tcl_DecrRefCount(res_obj);
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Open --
 *    Implements the oraopen command:
 *    usage: oralogon lda_handle
 *
 *    results:
 *	stm_handle
 *      TCL_OK - OCIAllocHandle successful
 *      TCL_ERROR - OCIAllocHandle not successful - error message returned
 *----------------------------------------------------------------------
 */

int
Oratcl_Open (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{

	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	char		*logHashKey = NULL;
	OratclLogs	*LogPtr;
	OratclStms	*StmPtr;

	Tcl_Obj		*handlep1 = NULL;
	Tcl_Obj		*handlep2 = NULL;

	sword		rc;
	int		new;

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
	logHashKey = Tcl_GetHashKey(OratclStatePtr->logHash, logHashPtr);

	StmPtr = (OratclStms *) ckalloc (sizeof (OratclStms));

	/* generate an lda name and put it in the hash table. */
	OratclStatePtr->stmid++;

	handlep1 = Tcl_NewStringObj((char *)logHashKey, -1);
	Tcl_IncrRefCount(handlep1);
	Tcl_AppendStringsToObj(handlep1, ".", NULL);

	handlep2 = Tcl_NewIntObj(OratclStatePtr->stmid);
	Tcl_IncrRefCount(handlep2);
	Tcl_AppendObjToObj(handlep1, handlep2);
	Tcl_DecrRefCount(handlep2);

	stmHashPtr = Tcl_CreateHashEntry(OratclStatePtr->stmHash,
					 Tcl_GetStringFromObj(handlep1 ,NULL),
					 &new);

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": no statement handles available",
				(Tcl_Obj *) NULL,
				(char *) NULL);
		ckfree ((char *)StmPtr);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	Tcl_SetHashValue(stmHashPtr, StmPtr);

	StmPtr->stmid = OratclStatePtr->stmid;
	StmPtr->ora_rc		= 0;
	Tcl_DStringInit(&StmPtr->ora_err);
	StmPtr->ora_row		= 0;
	StmPtr->ora_peo		= 0;
	StmPtr->ora_fcd		= 0;

	rc = OCI_HandleAlloc((dvoid *) LogPtr->envhp,
			     (dvoid **) &StmPtr->stmhp,
			     (ub4) OCI_HTYPE_STMT,
			     (size_t) 0,
			     (dvoid **) 0);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc != OCI_SUCCESS) {
		Oratcl_StmFree(StmPtr);
		Tcl_DeleteHashEntry(stmHashPtr);

		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle allocation failed",
				(Tcl_Obj *) NULL,
				(char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* cursor open ok */
	StmPtr->col_list	= NULL;
	StmPtr->bind_list	= NULL;
	StmPtr->fetchrows	= ORA_FETCH_ROWS;
	StmPtr->fetchmem	= ORA_FETCH_ROWS;
	StmPtr->longsize	= ORA_LONG_SIZE;
	StmPtr->lobpsize	= ORA_LOBP_SIZE;
	StmPtr->longpsize	= ORA_LONGP_SIZE;
	StmPtr->bindsize	= ORA_BIND_SIZE;
	StmPtr->numbsize	= ORA_NUMB_SIZE;
	StmPtr->datesize	= ORA_DATE_SIZE;
	StmPtr->nullvalue	= Tcl_NewStringObj("default", -1);
	Tcl_IncrRefCount(StmPtr->nullvalue);
	StmPtr->fetchidx		= 0;
	StmPtr->fetch_end	= 1;
	StmPtr->fetch_cnt	= 0;
	StmPtr->append_cnt	= 0;
	StmPtr->sqltype		= 0;
	StmPtr->logHashPtr	= logHashPtr;
	StmPtr->logid		= LogPtr->logid;
	Tcl_DStringInit(&StmPtr->datavar);
	StmPtr->sub_list	= NULL;
	StmPtr->sub_len		= 0;
	StmPtr->utfmode		= 0;

	Tcl_SetObjResult(interp, handlep1);

common_exit:

	if (handlep1)
		Tcl_DecrRefCount(handlep1);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Message --
 *    Implements the oramsg command:
 *    usage: oramsg stm_handle
 *
 *    results:
 *	oracle message information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_Message (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	OratclLogs	*LogPtr = NULL;
	OratclStms	*StmPtr = NULL;

	int		mode = 1;

	int		oColsc;
	Tcl_Obj		**oCols = NULL;
	int		oColslen = 6;
	Tcl_Obj		*oResult;

	CONST84 char *options[] = {"all",
				   "rc",
				   "error",
				   "rows",
				   "peo",
				   "ocicode",
				   "sqltype",
				   NULL};

	enum		optindex {OPT_ALL,
				  OPT_RC,
				  OPT_ERR,
				  OPT_ROW,
				  OPT_PEO,
				  OPT_FCD,
				  OPT_SQL};

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc == 1 || objc > 3 ) {
		Tcl_WrongNumArgs(interp, objc, objv, "stm_handle ?-option?");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if (objc == 3) {
		if (Tcl_GetIndexFromObj(interp,
					objv[2],
					(CONST84 char **)options,
					"option",
					0,
					&mode)) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
	}

	/*
	 *  We will accept either a logon handle or statement handle.
	 */
	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {

		logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
					       Tcl_GetStringFromObj(objv[1], NULL));

		if (logHashPtr == NULL) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": handle ",
					objv[1],
					" not valid");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);

	} else {

		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);

	}

	oResult = Tcl_GetObjResult(interp);
	oCols = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oCols));

	oColsc = 0;
	if (mode == OPT_ALL || mode == OPT_RC) {
		if (LogPtr) {
			oCols[oColsc++] = Tcl_NewIntObj(LogPtr->ora_rc);
		} else if (StmPtr) {
			oCols[oColsc++] = Tcl_NewIntObj(StmPtr->ora_rc);
		} else {
			oCols[oColsc++] = Tcl_NewIntObj(0);
		}
	}
	if (mode == OPT_ALL || mode == OPT_ERR) {
		if (LogPtr) {
			oCols[oColsc++] = Tcl_NewStringObj(LogPtr->ora_err.string, LogPtr->ora_err.length);
		} else if (StmPtr) {
			oCols[oColsc++] = Tcl_NewStringObj(StmPtr->ora_err.string, StmPtr->ora_err.length);
		} else {
			oCols[oColsc++] = Tcl_NewStringObj("", -1);;
		}
	}
	if (mode == OPT_ALL || mode == OPT_ROW) {
		if (StmPtr) {
			oCols[oColsc++] = Tcl_NewLongObj(StmPtr->ora_row);
		} else {
			oCols[oColsc++] = Tcl_NewStringObj("", -1);;
		}
	}
	if (mode == OPT_ALL || mode == OPT_PEO) {
		if (StmPtr) {
			oCols[oColsc++] = Tcl_NewIntObj(StmPtr->ora_peo);
		} else {
			oCols[oColsc++] = Tcl_NewStringObj("", -1);;
		}
	}
	if (mode == OPT_ALL || mode == OPT_FCD) {
		if (StmPtr) {
			oCols[oColsc++] = Tcl_NewIntObj(StmPtr->ora_fcd);
		} else {
			oCols[oColsc++] = Tcl_NewStringObj("", -1);;
		}
	}
	if (mode == OPT_ALL || mode == OPT_SQL) {
		if (StmPtr) {
			oCols[oColsc++] = Tcl_NewIntObj(StmPtr->sqltype);
		} else {
			oCols[oColsc++] = Tcl_NewStringObj("", -1);;
		}
	}

	if (mode == OPT_ALL) {
		Tcl_ListObjAppendElement(interp, oResult, Tcl_NewListObj(oColslen, oCols));
	} else {
		Tcl_ListObjAppendElement(interp, oResult, oCols[0]);
	}

common_exit:

	if (oCols)
		ckfree((char *) oCols);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Close --
 *    Implements the oraclose command:
 *    usage: oraclose stm_handle
 *
 *    results:
 *	null string
 *      TCL_OK - statement handle closed successfully
 *      TCL_ERROR - wrong # args, or stm_handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Close (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "stm_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);

	Oratcl_StmFree(StmPtr);
	Tcl_DeleteHashEntry(stmHashPtr);

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Sql --
 *    Implements the orasql command:
 *    usage: orasql stm_handle sql_string ?-parseonly? ?-commit?
 *
 *    results:
 *	return code from OCI_StmtExecute
 *      TCL_OK - handle is opened, sql executed ok
 *      TCL_ERROR - wrong # args, or handle not opened,  bad sql stmt
 *----------------------------------------------------------------------
 */

int
Oratcl_Sql (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	int		parseonly = 0;
	char		*p;

	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	int		postcommit = 0;
	int		commitObjc = 0;
	Tcl_Obj		**commitObjv = NULL;
	char		*logHashKey;
	Tcl_Obj		*res_obj;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 3) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle sql_str ?-parseonly? | ?-commit?");
		return TCL_ERROR;
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	/* check for options and deprecated keywords */
	if (objc >= 4) {
		p = Tcl_GetStringFromObj(objv[3], NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"parseonly") == 0) {
			parseonly = 1;
		}
		if (strcmp(p,"commit") == 0) {
			postcommit = 1;
		}
	}

	tcl_return = Oratcl_Parse(clientData, interp, objc, objv);
	if (tcl_return != TCL_OK) {
		goto common_exit;
	}

	if (parseonly) {
		goto common_exit;
	}

	tcl_return = Oratcl_Exec(clientData, interp, objc, objv);

	if (postcommit) {
		stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
					       Tcl_GetStringFromObj(objv[1],
								    NULL));

		if (stmHashPtr == NULL) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": stm_handle ",
					objv[1],
					" not open");
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
		logHashKey = Tcl_GetHashKey(OratclStatePtr->logHash,
					    StmPtr->logHashPtr);

		res_obj = Tcl_NewStringObj((char *) logHashKey, -1);
		Tcl_IncrRefCount(res_obj);
		commitObjc = 2;	
		commitObjv = (Tcl_Obj **) ckalloc(commitObjc * sizeof(Tcl_Obj *));
		commitObjv[0] = objv[0];
		commitObjv[1] = res_obj;
		Oratcl_Commit (clientData, interp, commitObjc, commitObjv);
		Tcl_DecrRefCount(res_obj);
	}
common_exit:

	if (commitObjv) {
		ckfree ((char *) commitObjv);
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Bindexec --
 *    Implements the orabindexec command:
 *    usage: orabindexec cur_handle ?-commit? :varname value
 *
 *    results:
 *	bind :varname value pairs, execute sql
 *	sets message array element "rc" with value of exec rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Bindexec (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{

	int		bindObjc = 0;
	Tcl_Obj		**bindObjv = NULL;
	int		execObjc = 0;
	Tcl_Obj		**execObjv = NULL;

	int		i;
	char		*p;

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle ?-commit? [ :varname value ] ...");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* reorganise arguments for Oratcl_Bind and Oratcl_Exec */
	execObjc = 2;
	bindObjc = objc;

	/* check for option and deprecated keywords */
	if (objc >= 3) {
		p = Tcl_GetStringFromObj(objv[2], (int *) NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"commit") == 0) {
			bindObjc--;
			execObjc++;
		}
	}

	bindObjv = (Tcl_Obj **) ckalloc(bindObjc * sizeof(Tcl_Obj *));
	execObjv = (Tcl_Obj **) ckalloc(execObjc * sizeof(Tcl_Obj *));

	bindObjv[0] = objv[0];
	execObjv[0] = objv[0];
	bindObjv[1] = objv[1];
	execObjv[1] = objv[1];

	/* pass commit along */
	if (execObjc == 3) {
		execObjv[2] = objv[2];
		for (i = 3;  i < objc;  i++) {
			bindObjv[i-1] = objv[i];
		}
	} else {
		for (i = 2;  i < objc;  i++) {
			bindObjv[i] = objv[i];
		}
	}

	tcl_return = Oratcl_Bind(clientData, interp, bindObjc, bindObjv);
	if (tcl_return != TCL_OK) {
		goto common_exit;
	}

	tcl_return = Oratcl_Exec(clientData, interp, execObjc, execObjv);

common_exit:

	if (bindObjv) {
		ckfree ((char *) bindObjv);
	}
	
	if (execObjv) {
		ckfree ((char *) execObjv);
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Cols --
 *    Implements the oracols command:
 *    usage: oracols stm_handle
 *
 *    results:
 *	latest column names as tcl list
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Cols (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;

	int		mode = 1;

	OratclCols	*col;
	int		oColsc;
	Tcl_Obj		**oCols = NULL;
	int		oColslen = 6;
	Tcl_Obj		*oResult;

	CONST84 char *options[] = {"all",
				   "name",
				   "size",
				   "type",
				   "precision",
				   "scale",
				   "nullok",
				   NULL};

	enum		optindex {OPT_ALL,
				  OPT_NAME,
				  OPT_SIZE,
				  OPT_TYPE,
				  OPT_PREC,
				  OPT_SCALE,
				  OPT_NULLOK};

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc == 1 || objc > 3 ) {
		Tcl_WrongNumArgs(interp, objc, objv, "stm_handle ?-option?");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if (objc == 3) {
		if (Tcl_GetIndexFromObj(interp,
					objv[2],
					(CONST84 char **)options,
					"option",
					0,
					&mode)) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);

	oResult = Tcl_GetObjResult(interp);
	oCols = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oCols));
	for (col = StmPtr->col_list; col != NULL; col = col->next) {

		oColsc = 0;
		if (mode == OPT_ALL || mode == OPT_NAME) {
			oCols[oColsc++] = Tcl_NewStringObj((char *) col->column.name, -1);
		}
		if (mode == OPT_ALL || mode == OPT_SIZE) {
			oCols[oColsc++] = Tcl_NewIntObj(col->column.size);
		}

		if (mode == OPT_ALL || mode == OPT_TYPE) {
			oCols[oColsc++] = Tcl_NewStringObj(Tcl_DStringValue(&col->column.typename),
							   Tcl_DStringLength(&col->column.typename));
		}

		if (mode == OPT_ALL || mode == OPT_PREC) {
			if (col->column.typecode == 2) {
				oCols[oColsc++] = Tcl_NewIntObj(col->column.prec);
			} else {
				oCols[oColsc++] = Tcl_NewStringObj("",   -1);;
			}
		}

		if (mode == OPT_ALL || mode == OPT_SCALE) {
			if (col->column.typecode == 2) {
				oCols[oColsc++] = Tcl_NewIntObj(col->column.scale);
			} else {
				oCols[oColsc++] = Tcl_NewStringObj("",   -1);;
			}
		}

		if (mode == OPT_ALL || mode == OPT_NULLOK) {
			oCols[oColsc++] = Tcl_NewIntObj(col->column.nullok);
		}

		if (mode == OPT_ALL) {
			Tcl_ListObjAppendElement(interp, oResult, Tcl_NewListObj(oColslen, oCols));
		} else {
			Tcl_ListObjAppendElement(interp, oResult, oCols[0]);
		}
	}

common_exit:

	if (oCols)
		ckfree((char *) oCols);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_PLexec --
 *    Implements the oraplexec command:
 *    usage: oraplexec cur_handle pl_block [ :varname value ]  [ .... ]
 *
 *    results:
 *	return parms in tcl list form
 *      TCL_OK - proc executed
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_PLexec (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{

	int		bindObjc = 0;
	Tcl_Obj		**bindObjv = NULL;

	int		i;
	
	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 3) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle pl_block [ :varname value ] ...");
		return TCL_ERROR;
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	tcl_return = Oratcl_Parse(clientData, interp, 3, objv);
	if (tcl_return != TCL_OK) {
		goto common_exit;
	}

	/* reorganise arguments for Oratcl_Bind */
	bindObjc = objc - 1;
	bindObjv = (Tcl_Obj **) ckalloc(bindObjc * sizeof(Tcl_Obj *));

	bindObjv[0] = objv[0];
	bindObjv[1] = objv[1];

	for (i = 3;  i < objc;  i++) {
		bindObjv[i-1] = objv[i];
	}

	tcl_return = Oratcl_Bind(clientData, interp, bindObjc, bindObjv);
	if (tcl_return != TCL_OK) {
		goto common_exit;
	}

	tcl_return = Oratcl_Exec(clientData, interp, 3, objv);

common_exit:

	if (bindObjv) {
		ckfree ((char *) bindObjv);
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Lda_List --
 *    Implements the oraldalist command:
 *    usage: oraldalist
 *
 *    results:
 *	null string
 *      TCL_OK - list if built
 *      TCL_ERROR - wrong # args
 *----------------------------------------------------------------------
 */

int
Oratcl_Lda_List (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	char		*logHashKey;
	Tcl_HashSearch	search;

	int		oColsc;
	int		oColslen = 0;
	Tcl_Obj		**oColsv = NULL;

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	/* Preallocate some list elements */
	if (oColsv == NULL) {
		oColslen = 10;
		oColsv = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oColsv));
	}

	oColsc = 0;

	logHashPtr = Tcl_FirstHashEntry(OratclStatePtr->logHash, &search);
	while (logHashPtr != NULL) {
		logHashKey = Tcl_GetHashKey(OratclStatePtr->logHash, logHashPtr);
		if (oColsc >= oColslen) {
			oColslen += 10;
			oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
		}
		oColsv[oColsc++] = Tcl_NewStringObj(logHashKey, -1);
		logHashPtr = Tcl_NextHashEntry(&search);
	}

	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	if (oColsv)
		ckfree((char *) oColsv);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Stm_List --
 *    Implements the orastmlist command:
 *    usage: orastmlist lda_handle
 *
 *    results:
 *	null string
 *      TCL_OK - list if built
 *      TCL_ERROR - wrong # args
 *----------------------------------------------------------------------
 */

int
Oratcl_Stm_List (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	OratclLogs	*LogPtr;
	OratclStms	*StmPtr;
	Tcl_HashEntry	*logHashPtr;
	Tcl_HashEntry	*stmHashPtr;
	char		*stmHashKey;
	Tcl_HashSearch	search;

	int		oColsc;
	int		oColslen = 0;
	Tcl_Obj		**oColsv = NULL;

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* Preallocate some list elements */
	if (oColsv == NULL) {
		oColslen = 10;
		oColsv = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oColsv));
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);

	oColsc = 0;
	stmHashPtr = Tcl_FirstHashEntry(OratclStatePtr->stmHash, &search);
	while (stmHashPtr != NULL) {
		StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
		if (StmPtr->logid == LogPtr->logid) {
			stmHashKey = Tcl_GetHashKey(OratclStatePtr->stmHash, stmHashPtr);
			if (oColsc >= oColslen) {
				oColslen += 10;
				oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
			}
			oColsv[oColsc++] = Tcl_NewStringObj(stmHashKey, -1);
		}
		stmHashPtr = Tcl_NextHashEntry(&search);
	}

	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

common_exit:

	if (oColsv)
		ckfree((char *) oColsv);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


sword
Oratcl_Attributes (interp, errhp, parmh, column, explicit)
	Tcl_Interp	*interp;
	OCIError	*errhp;
	OCIParam	*parmh;
	OratclDesc	*column;
	int		explicit;
{
	text		*namep;
	ub4		namesz;
	sword		rc;
	ub1		prec_ub1;	
	sb2		prec_sb2;	

	/* column name */
	rc = OCI_AttrGet((dvoid*) parmh,
			(ub4) OCI_DTYPE_PARAM,
			(dvoid*) &namep,
			(ub4 *) &column->namesz,
			(ub4) OCI_ATTR_NAME,
			(OCIError *) errhp);

	if (rc != OCI_SUCCESS) {
		return rc;
	}

	column->name = (text *) ckalloc ((size_t) column->namesz + 1);
	memcpy(column->name, namep, (size_t) column->namesz);
	column->name[column->namesz] = '\0';

	/* column length */
	rc = OCI_AttrGet((dvoid*) parmh,
			(ub4) OCI_DTYPE_PARAM,
			(dvoid*) &column->size,
			(ub4 *) 0,
			(ub4) OCI_ATTR_DATA_SIZE,
			(OCIError *) errhp);

	if (rc != OCI_SUCCESS) {
		return rc;
	}

	/* data type code */
	rc = OCI_AttrGet((dvoid*) parmh,
			(ub4) OCI_DTYPE_PARAM,
			(dvoid*) &column->typecode,
			(ub4 *) 0,
			(ub4) OCI_ATTR_DATA_TYPE,
			(OCIError *) errhp);

	if (rc != OCI_SUCCESS) {
		return rc;
	}

	/* precision */
	if (explicit) {
		rc = OCI_AttrGet((dvoid*) parmh,
				(ub4) OCI_DTYPE_PARAM,
				(dvoid*) &prec_ub1,
				(ub4 *) 0,
				(ub4) OCI_ATTR_PRECISION,
				(OCIError *) errhp);

		if (rc != OCI_SUCCESS) {
			return rc;
		}
		column->prec = prec_ub1;
	} else {
		rc = OCI_AttrGet((dvoid*) parmh,
				(ub4) OCI_DTYPE_PARAM,
				(dvoid*) &prec_sb2,
				(ub4 *) 0,
				(ub4) OCI_ATTR_PRECISION,
				(OCIError *) errhp);

		if (rc != OCI_SUCCESS) {
			return rc;
		}

		column->prec = prec_sb2;
	}

	/* scale */
	rc = OCI_AttrGet((dvoid*) parmh,
			(ub4) OCI_DTYPE_PARAM,
			(dvoid*) &column->scale,
			(ub4 *) 0,
			(ub4) OCI_ATTR_SCALE,
			(OCIError *) errhp);

	if (rc != OCI_SUCCESS) {
		return rc;
	}

	/* null allowed */
	rc = OCI_AttrGet( (dvoid*) parmh,
			 (ub4) OCI_DTYPE_PARAM,
			 (ub1 *) &column->nullok,
			 (ub4 *) 0,
			 (ub4) OCI_ATTR_IS_NULL,
			 (OCIError *) errhp);

	if (rc != OCI_SUCCESS) {
		return rc;
	}

	/* data type name */
	switch (column->typecode) {
	case SQLT_CHR:					/* 1	*/
		Tcl_DStringAppend(&column->typename, "VARCHAR2", -1);
		break;
	case SQLT_AFC:					/* 96	*/
		Tcl_DStringAppend(&column->typename, "CHAR", -1);
		break;
	case SQLT_LNG:					/* 8	*/
		Tcl_DStringAppend(&column->typename, "LONG", -1);
		break;
	case SQLT_BIN:					/* 23	*/
		Tcl_DStringAppend(&column->typename, "RAW", -1);
		break;
	case SQLT_LBI:					/* 24	*/
		Tcl_DStringAppend(&column->typename, "LONG RAW", -1);
		break;
	case SQLT_NUM:					/* 2	*/
		Tcl_DStringAppend(&column->typename, "NUMBER", -1);
		break;
	case SQLT_DAT:					/* 12	*/
		Tcl_DStringAppend(&column->typename, "DATE", -1);
		break;
	case SQLT_RID:					/* 11	*/
	case SQLT_RDD:					/* 104	*/
		Tcl_DStringAppend(&column->typename, "ROWID", -1);
		break;
	case SQLT_CUR:					/* 102	*/
		Tcl_DStringAppend(&column->typename, "CURSOR", -1);
		break;
	case SQLT_CLOB:
		Tcl_DStringAppend(&column->typename, "CLOB", -1);
		break;
	case SQLT_BLOB:
		Tcl_DStringAppend(&column->typename, "BLOB", -1);
		break;
	case 105:
		Tcl_DStringAppend(&column->typename, "MSLABEL", -1);
		break;
	case 106:
		Tcl_DStringAppend(&column->typename, "RAW MSLABEL", -1);
		break;
	case SQLT_TIMESTAMP:
		Tcl_DStringAppend(&column->typename, "TIMESTAMP", -1);
		break;
	case SQLT_TIMESTAMP_TZ:
		Tcl_DStringAppend(&column->typename, "TIMESTAMP WITH TIME ZONE", -1);
		break;
	case SQLT_INTERVAL_YM:
		Tcl_DStringAppend(&column->typename, "INTERVAL YEAR TO MONTH", -1);
		break;
	case SQLT_INTERVAL_DS:
		Tcl_DStringAppend(&column->typename, "INTERVAL DAY TO SECOND", -1);
		break;
	case SQLT_TIMESTAMP_LTZ:
		Tcl_DStringAppend(&column->typename, "TIMESTAMP WITH LOCAL TIME ZONE", -1);
		break;
	case SQLT_NTY:
		/* named type - get the name */
		rc = OCI_AttrGet((dvoid*) parmh,
				(ub4) OCI_DTYPE_PARAM,
				(dvoid*) &namep,
				(ub4 *) &namesz,
				(ub4) OCI_ATTR_TYPE_NAME,
				(OCIError *) errhp);
		if (rc != OCI_SUCCESS) {
			return rc;
		}
		Tcl_DStringAppend(&column->typename, (char *)namep, namesz);
		break;
	default:
		Tcl_DStringAppend(&column->typename, "UNKNOWN", -1);
	}

	return rc;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Describe --
 *    Implements the oradesc command:
 *    usage: oradesc lda_handle table_name
 *
 *    results:
 *	table information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_Describe (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	OratclLogs	*LogPtr;

	sword		rc;

	OCIDescribe	*dschp = (OCIDescribe *)0;

	char		*tmp_str;
	int		tmp_len;

	text		*syn_st1 = NULL, *syn_st2 = NULL, *syn_st3 = NULL;
	ub4		syn_ln1, syn_ln2, syn_ln3;

	Tcl_DString	tblStr, resStr;
	Tcl_Obj		*tmp_obj;

	OCIParam	*parmp, *collst, *parmh;
	ub2		numcols;
	int		pos;

	OratclDesc	column;

	int		objix;
	int		tcl_return = TCL_OK;

	Tcl_DStringInit(&tblStr);
	Tcl_DStringInit(&resStr);

	/* Initialize the column structure */
	column.typecode = 0;
	Tcl_DStringInit(&column.typename);
	column.size = 0;
	column.name = NULL;
	column.namesz = 0;
	column.prec = 0;
	column.scale = 0;
	column.nullok = 0;
	column.valuep = NULL;
	column.valuesz	= 0;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	logHashPtr = Tcl_FindHashEntry(OratclStatePtr->logHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": lda_handle ",
				objv[1],
				" not valid");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);
	Tcl_DStringInit(&LogPtr->ora_err);

	rc = OCI_HandleAlloc((dvoid *) LogPtr->envhp,
			     (dvoid **) &dschp,
			     (ub4) OCI_HTYPE_DESCRIBE,
			     (size_t) 0,
			     (dvoid **) 0);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	if (rc != OCI_SUCCESS) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle allocation failed",
				(Tcl_Obj *) NULL,
				(char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	tmp_str = Tcl_GetStringFromObj(objv[2], &tmp_len);
	Tcl_DStringAppend(&tblStr, tmp_str, tmp_len);

	rc = OCI_DescribeAny(LogPtr->svchp,
			     LogPtr->errhp,
			     (dvoid *) tblStr.string,
			     (ub4) tblStr.length,
			     OCI_OTYPE_NAME,
			     (ub1)0,
			     OCI_PTYPE_TABLE,
			     dschp);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);

	/* check for a private synonym */
	while (LogPtr->ora_rc == 4043) {

		rc = OCI_AttrSet((dvoid *) dschp,
				 (ub4) OCI_HTYPE_DESCRIBE,
				 (dvoid *) NULL,
				 (ub4) 0,
				 (ub4) OCI_ATTR_DESC_PUBLIC,
				 (OCIError *) LogPtr->errhp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		rc = OCI_DescribeAny(LogPtr->svchp,
				     LogPtr->errhp,
				     (dvoid *) tblStr.string,
				     (ub4) tblStr.length,
				     OCI_OTYPE_NAME,
				     (ub1)0,
				     OCI_PTYPE_SYN,
				     dschp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		/* get the parameter descriptor */
		rc = OCI_AttrGet((dvoid *)dschp,
				 (ub4)OCI_HTYPE_DESCRIBE,
				 (dvoid *) &parmp,
				 (ub4 *)0,
				 (ub4)OCI_ATTR_PARAM,
				 (OCIError *)LogPtr->errhp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		Tcl_DStringInit(&tblStr);

		/* retrieve the synonym schema name attribute */
		tmp_str = NULL;
		rc = OCI_AttrGet((dvoid*) parmp,
				 (ub4) OCI_DTYPE_PARAM,
				 (dvoid*) &syn_st1,
				 (ub4 *) &syn_ln1,
				 (ub4) OCI_ATTR_SCHEMA_NAME,
				 (OCIError *)LogPtr->errhp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		if (syn_st1) {
			Tcl_DStringAppend(&tblStr, (char *) syn_st1, syn_ln1);
			Tcl_DStringAppend(&tblStr, ".", 1);
		}

		/* retrieve the synonym name attribute */
		rc = OCI_AttrGet((dvoid*) parmp,
				 (ub4) OCI_DTYPE_PARAM,
				 (dvoid*) &syn_st2,
				 (ub4 *) &syn_ln2,
				 (ub4) OCI_ATTR_NAME,
				 (OCIError *)LogPtr->errhp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		if (syn_st2) {
			Tcl_DStringAppend(&tblStr, (char *) syn_st2, syn_ln2);
		}

		/* retrieve the synonym dblink attribute */
		rc = OCI_AttrGet((dvoid*) parmp,
				 (ub4) OCI_DTYPE_PARAM,
				 (dvoid*) &syn_st3,
				 (ub4 *) &syn_ln3,
				 (ub4) OCI_ATTR_LINK,
				 (OCIError *)LogPtr->errhp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		if (syn_st3) {
			Tcl_DStringAppend(&tblStr, "@", 1);
			Tcl_DStringAppend(&tblStr, (char *) syn_st3, syn_ln3);
		}

		/* describe the table pointed to by the synonym */
		rc = OCI_DescribeAny(LogPtr->svchp,
				     LogPtr->errhp,
				     (dvoid *)tblStr.string,
				     (ub4) tblStr.length,
				     OCI_OTYPE_NAME,
				     (ub1)0,
				     OCI_PTYPE_TABLE,
				     dschp);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);

	}

	if (rc != OCI_SUCCESS) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* get the parameter descriptor */
	rc = OCI_AttrGet((dvoid *)dschp,
			 (ub4)OCI_HTYPE_DESCRIBE,
			 (dvoid *) &parmp,
			 (ub4 *)0,
			 (ub4)OCI_ATTR_PARAM,
			 (OCIError *)LogPtr->errhp);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);
	if (rc != OCI_SUCCESS) {
		Oratcl_ErrorMsg(interp, objv[0], " error ", objv[1], (char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* number of columns */
	rc = OCI_AttrGet((dvoid*) parmp,
			 (ub4) OCI_DTYPE_PARAM,
			 (dvoid*) &numcols,
			 (ub4 *) 0,
			 (ub4) OCI_ATTR_NUM_COLS,
			 (OCIError *)LogPtr->errhp);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);
	if (rc != OCI_SUCCESS) {
		Oratcl_ErrorMsg(interp, objv[0], " error ", objv[1], (char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* column list of the table */
	rc = OCI_AttrGet((dvoid*) parmp,
			 (ub4) OCI_DTYPE_PARAM,
			 (dvoid*) &collst,
			 (ub4 *) 0,
			 (ub4) OCI_ATTR_LIST_COLUMNS,
			 (OCIError *)LogPtr->errhp);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&LogPtr->ora_rc,
			&LogPtr->ora_err);
	if (rc != OCI_SUCCESS) {
		Oratcl_ErrorMsg(interp, objv[0], " error ", objv[1], (char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* now describe each column */
	for (pos = 1; pos <= numcols; pos++) {

		/* get the parameter descriptor for each column */
		rc = OCI_ParamGet((dvoid *)collst,
				  (ub4)OCI_DTYPE_PARAM,
				  LogPtr->errhp,
				  (dvoid *)&parmh,
				  (ub4) pos);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				0,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			Oratcl_ErrorMsg(interp, objv[0], " error ", objv[1], (char *) NULL);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		Tcl_DStringSetLength(&column.typename, 0);

		rc = Oratcl_Attributes(interp, LogPtr->errhp, parmh, &column, 1);
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);
		if (rc != OCI_SUCCESS) {
			Oratcl_ErrorMsg(interp, objv[0], " error ", objv[1], (char *) NULL);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		Tcl_DStringStartSublist(&resStr);
		Tcl_DStringAppendElement(&resStr,
					 (char *) column.name);

		tmp_obj = Tcl_NewIntObj(column.size);
		Tcl_IncrRefCount(tmp_obj);
		Tcl_DStringAppendElement(&resStr,
					  Tcl_GetStringFromObj(tmp_obj, NULL));
		Tcl_DecrRefCount(tmp_obj);

		Tcl_DStringAppendElement(&resStr,
					  Tcl_DStringValue(&column.typename));

		tmp_obj = Tcl_NewIntObj(column.prec);
		Tcl_IncrRefCount(tmp_obj);
		Tcl_DStringAppendElement(&resStr,
					  Tcl_GetStringFromObj(tmp_obj, NULL));
		Tcl_DecrRefCount(tmp_obj);

		tmp_obj = Tcl_NewIntObj(column.scale);
		Tcl_IncrRefCount(tmp_obj);
		Tcl_DStringAppendElement(&resStr,
					  Tcl_GetStringFromObj(tmp_obj, NULL));
		Tcl_DecrRefCount(tmp_obj);

		tmp_obj = Tcl_NewIntObj(column.nullok);
		Tcl_IncrRefCount(tmp_obj);
		Tcl_DStringAppendElement(&resStr,
					  Tcl_GetStringFromObj(tmp_obj, NULL));
		Tcl_DecrRefCount(tmp_obj);

		Tcl_DStringEndSublist(&resStr);

		ckfree((char *)column.name);
	}

	Tcl_SetObjResult(interp, Tcl_NewStringObj(resStr.string, resStr.length));

common_exit:

	(void) OCI_HandleFree((dvoid *) dschp,
			      (ub4) OCI_HTYPE_DESCRIBE);

	Tcl_DStringFree(&tblStr);
	Tcl_DStringFree(&resStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Config --
 *    Implements the oraconfig command:
 *    usage: oraconfig stm_handle field value
 *
 *    results:
 *	table information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_Config (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;

	CONST84 char *options[] = {"longsize",
				   "bindsize",
				   "nullvalue",
				   "fetchrows",
				   "lobpsize",
				   "longpsize",
				   "utfmode",
				   "numbsize",
				   "datesize",
				   NULL};

	enum		optindex {OPT_LONG,
				  OPT_BIND,
				  OPT_NULL,
				  OPT_CACHE,
				  OPT_LOBP,
				  OPT_LONGP,
				  OPT_UTFMODE,
				  OPT_NUMB,
				  OPT_DATE};
	int		optlength = 18;

	int		option;
	int		value;
	int		i;
	int		tcl_rc;

	Tcl_Obj		**infoObjv;
	int		infoObjc;

	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if ((objc < 2) || (((objc % 2) == 1) && (objc != 3))) {
		Tcl_WrongNumArgs(interp,
				 1,
				 objv,
				 "stm_handle optionName value ?optionName value? ...");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);

	if (objc == 2) {
		/* return list of alternating option names and values */
		infoObjv = (Tcl_Obj **) ckalloc (optlength * sizeof(*infoObjv));
		infoObjc = 0;
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[0], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->longsize);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[1], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->bindsize);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[2], -1);
		infoObjv[infoObjc++] = Tcl_DuplicateObj(StmPtr->nullvalue);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[3], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->fetchrows);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[4], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->lobpsize);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[5], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->longpsize);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[6], -1);
		infoObjv[infoObjc++] = Tcl_NewBooleanObj(StmPtr->utfmode);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[7], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->numbsize);
		infoObjv[infoObjc++] = Tcl_NewStringObj(options[8], -1);
		infoObjv[infoObjc++] = Tcl_NewIntObj(StmPtr->datesize);
		Tcl_SetObjResult(interp, Tcl_NewListObj(infoObjc, infoObjv));
		ckfree((char *) infoObjv);
		tcl_return = TCL_OK;
		goto common_exit;
	}

	if (objc == 3) {
		/* return current value of given option */
		if (Tcl_GetIndexFromObj(interp,
					objv[2],
					(CONST84 char **)options,
					"optionName",
					0,
					&option)) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		if (option == OPT_LONG) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->longsize));
		}
		if (option == OPT_BIND) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->bindsize));
		}
		if (option == OPT_NULL) {
			Tcl_SetObjResult(interp,
					 Tcl_DuplicateObj(StmPtr->nullvalue));
		}
		if (option == OPT_CACHE) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->fetchrows));
		}
		if (option == OPT_LOBP) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->lobpsize));
		}
		if (option == OPT_LONGP) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->longpsize));
		}
		if (option == OPT_UTFMODE) {
			Tcl_SetObjResult(interp,
					 Tcl_NewBooleanObj(StmPtr->utfmode));
		}
		if (option == OPT_NUMB) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->numbsize));
		}
		if (option == OPT_DATE) {
			Tcl_SetObjResult(interp,
					 Tcl_NewIntObj(StmPtr->datesize));
		}
		tcl_return = TCL_OK;
		goto common_exit;
	}

	for (i = 3; i < objc; i += 2) {
		if (Tcl_GetIndexFromObj(interp,
					objv[i-1],
					(CONST84 char **)options,
					"optionName",
					0,
					&option)) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		if (option == OPT_LONG) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 0 || value > MAX_LONG_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->longsize = value;
		}
		if (option == OPT_BIND) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 0 || value > MAX_BIND_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->bindsize = value;
		}
		if (option == OPT_NULL) {
			StmPtr->nullvalue = Tcl_DuplicateObj(objv[i]);
		}
		if (option == OPT_CACHE) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 0) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->fetchrows = value;
		}
		if (option == OPT_LOBP) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 0 || value > MAX_LOBP_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->lobpsize = value;
		}
		if (option == OPT_LONGP) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 0 || value > MAX_LONGP_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->longpsize = value;
		}
		if (option == OPT_UTFMODE) {
			tcl_rc = Tcl_GetBooleanFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->utfmode = value;
		}
		if (option == OPT_NUMB) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 1 || value > MAX_NUMB_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->numbsize = value;
		}
		if (option == OPT_DATE) {
			tcl_rc = Tcl_GetIntFromObj(interp, objv[i], &value);
			/* test for valid integer */
			if (tcl_rc != TCL_OK || value < 1 || value > MAX_DATE_SIZE) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": invalid value",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			StmPtr->datesize = value;
		}
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 *
 * Oratcl_LongRead --
 *    Implements the ::oratcl::longread command:
 *    usage: oradesc stm_handle sql_stmt data_var data_type
 *
 *    results:
 *	table information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_LongRead (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	OCIDefine       *defnp;		/* define pointer */

	char		*sql;
	int		sql_len = 0;

	char		*btype;
	int		btype_len = 0;

	int		rc, frc, prc;

	ub4		type;
	ub4		p_type;
	ub4		iteration;
	ub4		table;

	int		rowcnt;

	ub1		piece;
	ub4		piece_size;

	char		*piece_data = NULL;
	ub4		piece_len;
	ub2		piece_rcode;

	ub2		bind_type = SQLT_LNG;

	Tcl_DString	uniStr;
	Tcl_DString	resStr;
	Tcl_Obj		*res_obj;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 5) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle sql_str datavar");
		return TCL_ERROR;
	}

	Tcl_DStringInit(&resStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	sql = Tcl_GetStringFromObj(objv[2], &sql_len);
	btype = Tcl_GetStringFromObj(objv[4], &btype_len);
	if (*btype == 'l'
	   && strcmp(btype,"longraw") == 0) {
		bind_type = SQLT_LBI;
	}


	piece_data = ckalloc (StmPtr->longpsize + 1);

	piece_data[StmPtr->longpsize] = '\0';
	piece_size = StmPtr->longpsize;
	piece_len = StmPtr->longpsize;

	rc = OCI_StmtPrepare((dvoid *) StmPtr->stmhp,
			     LogPtr->errhp,
			     (text *) sql,
			     (ub4) strlen( (char *) sql),
			     (ub4) OCI_NTV_SYNTAX,
			     (ub4) OCI_DEFAULT);

	Tcl_DStringInit(&StmPtr->ora_err);
	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	rc = OCI_StmtExecute(LogPtr->svchp,
			     StmPtr->stmhp,
			     LogPtr->errhp,
			     (ub4) 0,
			     (ub4) 0,
			     (OCISnapshot *) NULL,
			     (OCISnapshot *) NULL,
			     OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	rc = OCI_DefineByPos(StmPtr->stmhp,
			     &defnp,
			     LogPtr->errhp,
			     (ub4) 1,
			     (dvoid *) 0,
			     (sb4) INT_MAX,
			     (ub2) bind_type,
			     (dvoid *) 0,
			     (ub2 *) &piece_size,
			     (ub2 *) &piece_rcode,
			     (ub4) OCI_DYNAMIC_FETCH);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	frc = OCI_StmtFetch(StmPtr->stmhp,
			  LogPtr->errhp,
			  1,
			  (ub2) OCI_FETCH_NEXT,
			  (ub4) OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			frc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (frc != OCI_NEED_DATA && frc != 0) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	while (frc == OCI_NEED_DATA) {

		prc = OCI_StmtGetPieceInfo(StmPtr->stmhp,
					   LogPtr->errhp,
					   (dvoid **) &defnp,
					   (ub4 *) &type,
					   (ub1 *) &p_type,
					   (ub4 *) &iteration,
					   (ub4 *) &table,	
					   (ub1 *) &piece);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				prc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (prc == OCI_ERROR || prc == OCI_INVALID_HANDLE) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		prc = OCI_StmtSetPieceInfo(defnp,
					   OCI_HTYPE_DEFINE,
					   LogPtr->errhp,
					   (dvoid *) piece_data,
					   (ub4 *) &piece_len,
					   (ub1) piece,
					   (CONST dvoid *) 0,		/* no indicator */
					   (ub2 *) NULL);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				prc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (prc == OCI_ERROR || prc == OCI_INVALID_HANDLE) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		frc = OCI_StmtFetch(StmPtr->stmhp,
				  LogPtr->errhp,
				  1,
				  (ub2) OCI_FETCH_NEXT,
				  (ub4) OCI_DEFAULT);

		piece_data[piece_len] = '\0';

		Tcl_DStringAppend(&resStr, piece_data, piece_len);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				frc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (frc != OCI_NEED_DATA && frc != 0) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

	}

	/*
	 * Convert the result to UTF from external encoding
	 */
	if (StmPtr->utfmode) {
		Tcl_DStringInit(&uniStr);
		Tcl_ExternalToUtfDString(NULL,
					Tcl_DStringValue(&resStr),
					Tcl_DStringLength(&resStr),
					&uniStr);
		res_obj = Tcl_NewStringObj(Tcl_DStringValue(&uniStr),
					   Tcl_DStringLength(&uniStr));
		Tcl_DStringFree(&uniStr);
	} else {
		res_obj = Tcl_NewStringObj(Tcl_DStringValue(&resStr),
					   Tcl_DStringLength(&resStr));
	}

	Tcl_IncrRefCount(res_obj);
	Tcl_ObjSetVar2(interp, objv[3], NULL, res_obj, TCL_LEAVE_ERR_MSG);
	Tcl_DecrRefCount(res_obj);

	rowcnt = 0;
	rc = (OCI_AttrGet( (dvoid *) StmPtr->stmhp,
			  (ub4) OCI_HTYPE_STMT,
			  (ub4 *) &rowcnt,
			  (ub4) 0,
			  OCI_ATTR_ROW_COUNT,
			  LogPtr->errhp));

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": OCIAttrGet failed",
				(Tcl_Obj *) NULL,
				(char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* set "rows" to rpc (rows processed count) */
	StmPtr->ora_row = rowcnt;

common_exit:

	Tcl_DStringFree(&resStr);

	if (piece_data != NULL) {
		ckfree ((char *) piece_data);
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_LongWrite --
 *    Implements the ::oratcl::longwrite command:
 *    usage: oradesc stm_handle sql_stmt data_var data_type
 *
 *    results:
 *	table information
 *      TCL_OK -
 *      TCL_ERROR -
 *----------------------------------------------------------------------
 */

int
Oratcl_LongWrite (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	OCIBind		*bindp;		/* bind pointer */

	int		rc;

	char		*sql;
	int		sql_len = 0;

	Tcl_DString	outStr;
	char		*pre_data;
	int		pre_data_len = 0;

	char		*type;
	int		type_len = 0;

	char		*pData;
	char		*pLast;
	ub4		pSize, pLen;

	int		buffer_size;
	ub2		buffer_rcode;

	int		rowcnt;

	ub1		piece;
	sb2		piece_indp;

	ub2		bind_type = SQLT_LNG;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 5) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle sql_str datavar");
		return TCL_ERROR;
	}

	Tcl_DStringInit(&outStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);
	Tcl_DStringInit(&StmPtr->ora_err);
	Tcl_DStringInit(&LogPtr->ora_err);

	sql = Tcl_GetStringFromObj(objv[2], &sql_len);

	pre_data = Tcl_GetStringFromObj(Tcl_ObjGetVar2(interp,
						       objv[3],
						       NULL,
						       TCL_LEAVE_ERR_MSG),
					&pre_data_len);

	if (StmPtr->utfmode) {
		Tcl_UtfToExternalDString(NULL, pre_data, pre_data_len, &outStr);
	} else {
		Tcl_DStringAppend(&outStr, pre_data, pre_data_len);
	}

	type = Tcl_GetStringFromObj(objv[4], &type_len);
	if (*type == 'l'
	   && strcmp(type,"longraw") == 0) {
		bind_type = SQLT_LBI;
	}

	rc = OCI_StmtPrepare((dvoid *) StmPtr->stmhp,
			      LogPtr->errhp,
			      (text *) sql,
			      (ub4) strlen( (char *) sql),
			      (ub4) OCI_NTV_SYNTAX,
			      (ub4) OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	rc = OCI_BindByName((OCIStmt *) StmPtr->stmhp,
			    (OCIBind **) &bindp,
			    (OCIError *) LogPtr->errhp,
			    (text *) ":lng",
			    (sb4) 4,
			    (dvoid *) 0,
			    (sb4) INT_MAX,
			    (ub2) bind_type,
			    (dvoid *) &piece_indp,
			    (ub2 *) &buffer_size,
			    (ub2 *) &buffer_rcode,
			    (ub4) NULL,
			    (ub4 *) NULL,
			    (ub4) OCI_DATA_AT_EXEC);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	rc = OCI_StmtExecute(LogPtr->svchp,
			     StmPtr->stmhp,
			     LogPtr->errhp,
			     (ub4) 1,
			     (ub4) 0,
			     (OCISnapshot *) NULL,
			     (OCISnapshot *) NULL,
			     OCI_DEFAULT);

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			1,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	piece = OCI_FIRST_PIECE;

	pData = outStr.string;
	pLen = outStr.length;
	pLast = pData + pLen - 1;

	while (piece != OCI_LAST_PIECE) {

		if (pLen > StmPtr->longpsize) {
			pSize = StmPtr->longpsize;
		} else {
			pSize = pLen;
			piece = OCI_LAST_PIECE;
		}

		rc = OCI_StmtSetPieceInfo((dvoid *) bindp,
					  OCI_HTYPE_BIND,
					  LogPtr->errhp,
					  (dvoid *) pData,
					  (ub4 *) &pSize,
					  (ub1) piece,
					  (dvoid *) NULL,
					  (ub2 *) NULL);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&LogPtr->ora_rc,
				&LogPtr->ora_err);

		if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		rc = OCI_StmtExecute(LogPtr->svchp,
				     StmPtr->stmhp,
				     LogPtr->errhp,
				     (ub4) 1,
				     (ub4) 0,
				     (OCISnapshot *) NULL,
				     (OCISnapshot *) NULL,
				     OCI_DEFAULT);

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		pData += pSize;
		pLen -= pSize;
		if (piece != OCI_LAST_PIECE) {
			piece = OCI_NEXT_PIECE;
		}

	}

	rowcnt = 0;
	rc = (OCI_AttrGet( (dvoid *) StmPtr->stmhp,
			  (ub4) OCI_HTYPE_STMT,
			  (ub4 *) &rowcnt,
			  (ub4) 0,
			  OCI_ATTR_ROW_COUNT,
			  LogPtr->errhp));

	Oratcl_Checkerr(interp,
			LogPtr->errhp,
			rc,
			0,
			&StmPtr->ora_rc,
			&StmPtr->ora_err);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": OCIAttrGet failed",
				(Tcl_Obj *) NULL,
				(char *) NULL);
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* set "rows" to rpc (rows processed count) */
	StmPtr->ora_row = rowcnt;

common_exit:

	Tcl_DStringFree(&outStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Parse --
 *    Implements the ::oratcl::oraparse command:
 *    usage: ::oratcl::oraparse stm_handle sql_string
 *
 *    results:
 *	return code from OCIStmtPrepare or OCI_StmtExecute
 *      TCL_OK - handle is opened, sql executed ok
 *      TCL_ERROR - wrong # args, or handle not opened,  bad sql stmt
 *----------------------------------------------------------------------
 */

int
Oratcl_Parse (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	Tcl_DString	stmStr;
	sword		rc;
	int		cols;
	Tcl_Obj		*res_obj;

	char		*stmt;
	ub4		stln;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, objc, objv, "stm_handle sql_str");
		return TCL_ERROR;
	}

	Tcl_DStringInit(&stmStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	stmt = Tcl_GetStringFromObj(objv[2], (int *) &stln);
	if (StmPtr->utfmode) {
		Tcl_UtfToExternalDString(NULL, stmt, stln, &stmStr);
	} else {
		Tcl_DStringAppend(&stmStr, stmt, stln);
	}

	if (LogPtr->async == 1 && StmPtr->ora_rc == OCI_STILL_EXECUTING) {
		/* NULL Statement */
	} else {

		/* clear any previous results */
		StmPtr->ora_rc = 0;
		Tcl_DStringInit(&StmPtr->ora_err);
		StmPtr->ora_row = 0;
		Oratcl_ColFree(StmPtr->col_list);
		StmPtr->col_list   	= NULL;
		Oratcl_ColFree(StmPtr->bind_list);
		StmPtr->bind_list	= NULL;

		/* prepare the new statement */
		rc = OCI_StmtPrepare((dvoid *) StmPtr->stmhp,
				     LogPtr->errhp,
				     (text *) Tcl_DStringValue(&stmStr),
				     (ub4) Tcl_DStringLength(&stmStr),
				     (ub4) OCI_NTV_SYNTAX,
				     (ub4) OCI_DEFAULT);

		if (rc != OCI_SUCCESS && rc != OCI_SUCCESS_WITH_INFO) {
			Oratcl_Checkerr(interp,
					LogPtr->errhp,
					rc,
					1,
					&StmPtr->ora_rc,
					&StmPtr->ora_err);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
	}

	/* get sql type */
	OCI_AttrGet( (dvoid *) StmPtr->stmhp,
		    (ub4) OCI_HTYPE_STMT,
		    (ub2 *) &StmPtr->sqltype,
		    (ub4) 0,
		    OCI_ATTR_STMT_TYPE,
		    LogPtr->errhp);

	if (StmPtr->sqltype == OCI_STMT_SELECT) {
		StmPtr->iters = 0;
		StmPtr->ora_peo = 0;
		/* need to describe the sql to get the select columns */
		rc = OCI_StmtExecute(LogPtr->svchp,
				     StmPtr->stmhp,
				     LogPtr->errhp,
				     (ub4) StmPtr->iters,
				     (ub4) 0,
				     (OCISnapshot *) NULL,
				     (OCISnapshot *) NULL,
				     OCI_DESCRIBE_ONLY);

		if (rc == OCI_STILL_EXECUTING) {
			res_obj = Tcl_NewIntObj(rc);
			Tcl_IncrRefCount(res_obj);
			Tcl_SetObjResult(interp, res_obj);
			Tcl_DecrRefCount(res_obj);
			StmPtr->ora_rc = rc;
			if (LogPtr->async == 1) {
				tcl_return = TCL_OK;
			} else {
				tcl_return = TCL_ERROR;
			}
			goto common_exit;
		}

		if (rc != OCI_SUCCESS && rc != OCI_SUCCESS_WITH_INFO) {
#ifdef OCI_ATTR_PARSE_ERROR_OFFSET
			OCI_AttrGet( (dvoid *) StmPtr->stmhp,
				    (ub4) OCI_HTYPE_STMT,
				    (ub2 *) &StmPtr->ora_peo,
				    (ub4) 0,
				    OCI_ATTR_PARSE_ERROR_OFFSET,
				    LogPtr->errhp);
#endif
			Oratcl_Checkerr(interp,
					LogPtr->errhp,
					rc,
					1,
					&StmPtr->ora_rc,
					&StmPtr->ora_err);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		OCI_AttrGet( (dvoid *) StmPtr->stmhp,
			    (ub4) OCI_HTYPE_STMT,
			    (ub2 *) &StmPtr->ora_fcd,
			    (ub4) 0,
			    OCI_ATTR_SQLFNCODE,
			    LogPtr->errhp);

		cols = Oratcl_ColDescribe(interp, StmPtr);
		if (cols < 0) {
			tcl_return = TCL_ERROR;
			goto common_exit;	
		}

	} else {
		StmPtr->iters = 1;
	}

	StmPtr->ora_rc = 0;
	res_obj = Tcl_NewIntObj(0);
	Tcl_IncrRefCount(res_obj);
	Tcl_SetObjResult(interp, res_obj);
	Tcl_DecrRefCount(res_obj);

common_exit:

	Tcl_DStringFree(&stmStr);

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Bind --
 *    Implements the orabind command:
 *    usage: orabind stm_handle :bindname value ...
 *    usage: ::oratcl::orabind stm_handle :bindname value ...
 *
 *    results:
 *	return code from OCIBindByName
 *      TCL_OK - binding successful
 *      TCL_ERROR - wrong # args, handle not opened, or OCI error
 *----------------------------------------------------------------------
 */
int
Oratcl_Bind (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	Tcl_HashEntry	*refHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;
	OratclStms	*RefPtr = NULL;

	int		parm_cnt;
	sword		rc;

	OratclCols	*tmp_col_head = NULL;
	OratclCols	*tmp_col = NULL;
	OratclCols	*head_col = NULL;

	Tcl_DString	argStr;
	char		*arg_pcc, *arg_pcp;
	int		arg_pcc_len, arg_pcp_len;
	int		objix;
	int		tcl_return = TCL_OK;

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle [ :varname value ] ...");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	StmPtr->ora_rc  = 0;
	Tcl_DStringInit(&StmPtr->ora_err);
	StmPtr->ora_row = 0;

	parm_cnt = 2;

	/* if first time in, allocate bind_list */
	if (StmPtr->bind_list == NULL) {

		if (objc > parm_cnt + 1) {
			tmp_col_head = Oratcl_ColAlloc(StmPtr->fetchmem);
			if (tmp_col_head == NULL) {
				Oratcl_ErrorMsg(interp,
						objv[0],
						": cannot malloc new col",
						(Tcl_Obj *) NULL,
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			tmp_col      = tmp_col_head;
			head_col     = tmp_col_head;
			StmPtr->bind_list = tmp_col_head;
		} else {
			tmp_col_head = NULL;
		}

		while (objc > parm_cnt + 1) {       /* always in pairs of two */

			/* get two arg strings */
			arg_pcc = Tcl_GetStringFromObj(objv[parm_cnt], &arg_pcc_len);
			arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);

			/* make sure bind variable name has a leading ':' */
			if (*arg_pcc != ':') {
				Oratcl_ColFree(StmPtr->col_list);
				StmPtr->col_list = NULL;
				Oratcl_ColFree(StmPtr->bind_list);
				StmPtr->bind_list = NULL;
				Oratcl_ErrorMsg(interp,
						objv[0],
						": bind variable '",
						objv[parm_cnt],
						"' does not begin with ':'");
				tcl_return = TCL_ERROR;
				goto common_exit;
			}

			refHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
						       Tcl_GetStringFromObj(objv[parm_cnt+1], NULL));
			if (refHashPtr != NULL) {
				RefPtr = (OratclStms *) Tcl_GetHashValue(refHashPtr);

				if (stmHashPtr == refHashPtr) {
					Oratcl_ColFree(tmp_col_head);
					StmPtr->bind_list = NULL;
					Oratcl_ErrorMsg(interp,
							objv[0],
							": bind cursor for ",
							objv[parm_cnt],
							" same as cursor_handle");
					tcl_return = TCL_ERROR;
					goto common_exit;
				}

				if (StmPtr->logid != LogPtr->logid) {
					Oratcl_ColFree(tmp_col_head);
					StmPtr->bind_list = NULL;
					Oratcl_ErrorMsg(interp,
							objv[0],
							": bind cursor for ",
							objv[parm_cnt],
							" not from same login handle as statement handle");
					tcl_return = TCL_ERROR;
					goto common_exit;
				}

				Oratcl_ColFree(RefPtr->col_list);
				RefPtr->col_list	= NULL;
				Oratcl_ColFree(RefPtr->bind_list);
				RefPtr->bind_list	= NULL;
				RefPtr->fetchidx	= RefPtr->fetchmem;
				RefPtr->fetch_end       = 0;    /* try to fetch */
				RefPtr->fetch_cnt       = 0;    /* start fetch cnt at zero */
				RefPtr->append_cnt      = 0;    /* start append cnt at zero */

				tmp_col->bindPtr	= refHashPtr;
			} else {
				tmp_col->bindPtr	= NULL;
			}

			if (arg_pcp_len > StmPtr->bindsize) {
				Oratcl_ColFree(StmPtr->col_list);
				StmPtr->col_list = NULL;
				Oratcl_ColFree(StmPtr->bind_list);
				StmPtr->bind_list = NULL;
				Oratcl_ErrorMsg(interp,
						objv[0],
						": bind value ",
						objv[parm_cnt+1],
						"too large for bindsize");
				tcl_return = TCL_ERROR;
				goto common_exit;
			}

			/* allocate adequate space for reuse */
			tmp_col->column.valuesz = StmPtr->bindsize;
			tmp_col->column.valuep   = ckalloc(tmp_col->column.valuesz + 1);
			if (tmp_col->column.valuep == NULL) {
				Oratcl_ColFree(tmp_col_head);
				StmPtr->bind_list = NULL;
				Oratcl_ErrorMsg(interp,
						objv[0],
						": allocation failure",
						objv[parm_cnt],
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}

			if (StmPtr->utfmode) {
				Tcl_DStringInit(&argStr);
				Tcl_UtfToExternalDString(NULL,
							 arg_pcp,
							 arg_pcp_len,
							 &argStr);
				memcpy(tmp_col->column.valuep,
				       Tcl_DStringValue(&argStr),
				       Tcl_DStringLength(&argStr));
				tmp_col->column.valuep[argStr.length] = '\0';
				Tcl_DStringFree(&argStr);
			} else {
				memcpy(tmp_col->column.valuep,
				       arg_pcp,
				       arg_pcp_len);
				tmp_col->column.valuep[arg_pcp_len] = '\0';
			}

			tmp_col->rlenp[0] = 0;
			tmp_col->rcodep[0] = 0;

			tmp_col->column.name = (text *) ckalloc(arg_pcc_len + 1);
			if (tmp_col->column.name == NULL) {
				Oratcl_ColFree(tmp_col_head);
				StmPtr->bind_list = NULL;
				Oratcl_ErrorMsg(interp,
						objv[0],
						": allocation failure",
						objv[parm_cnt+1],
						(char *) NULL);
				tcl_return = TCL_ERROR;
				goto common_exit;
			}
			memcpy(tmp_col->column.name, arg_pcc, arg_pcc_len);
			tmp_col->column.name[arg_pcc_len] = '\0';
			tmp_col->column.namesz = arg_pcc_len;

			tmp_col->bindp = (OCIBind *) 0;

			if (tmp_col->bindPtr == NULL) {

				/* string data type */
				tmp_col->column.typecode = SQLT_STR;

				rc = OCI_BindByName(StmPtr->stmhp,
						    (OCIBind **) &tmp_col->bindp,
						    LogPtr->errhp,
						    (text *) tmp_col->column.name,
						    (sb4) tmp_col->column.namesz,
						    (dvoid *) tmp_col->column.valuep,
						    (sb4) tmp_col->column.valuesz + 1,
						    (ub2) SQLT_STR,
						    (dvoid *) &tmp_col->indp[0],
						    (ub2 *) 0,
						    (ub2 *) 0,
						    (ub4) 0,
						    (ub4 *) 0,
						    (ub4) OCI_DEFAULT);

			} else {

				/* cursor data type */
				tmp_col->column.typecode = SQLT_CUR;

				rc = OCI_BindByName(StmPtr->stmhp,
						    (OCIBind **) &tmp_col->bindp,
						    LogPtr->errhp,
						    (text *) tmp_col->column.name,
						    (sb4) tmp_col->column.namesz,
						    (dvoid *) &RefPtr->stmhp,
						    (sb4) 0,
						    (ub2) SQLT_RSET,
						    (dvoid *) 0,
						    (ub2 *) 0,
						    (ub2 *) 0,
						    (ub4) 0,
						    (ub4 *) 0,
						    (ub4) OCI_DEFAULT);

			}

			if (rc != OCI_SUCCESS) {
				Oratcl_Checkerr(interp,
						LogPtr->errhp,
						rc,
						1,
						&StmPtr->ora_rc,
						&StmPtr->ora_err);
				Oratcl_ColFree(tmp_col_head);
				StmPtr->bind_list = NULL;
				tcl_return = TCL_ERROR;
				goto common_exit;
			}


			parm_cnt += 2;

			if (objc > parm_cnt + 1) {       /* more args? alloc new colbufs */
				head_col = tmp_col;
				tmp_col = Oratcl_ColAlloc(StmPtr->fetchmem);
				if (tmp_col == NULL) {
					Oratcl_ColFree(StmPtr->col_list);
					StmPtr->col_list = NULL;
					Oratcl_ColFree(StmPtr->bind_list);
					StmPtr->bind_list = NULL;
					Oratcl_ErrorMsg(interp,
						objv[0],
						": cannot malloc new col",
						(Tcl_Obj *) NULL,
						(char *) NULL);
					tcl_return = TCL_ERROR;
					goto common_exit;
				}
				head_col->next = tmp_col;
			}
		}

	} else {
		/* else, binds have been done, just copy in new data */
		while (objc > parm_cnt + 1) {       /* always in pairs of two */
			tmp_col = StmPtr->bind_list;
			while (tmp_col != NULL) {
				if (strncmp((char *) tmp_col->column.name, Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL), 255) == 0) {
					arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);

					if (StmPtr->utfmode) {
						Tcl_DStringInit(&argStr);
						Tcl_UtfToExternalDString(NULL,
									 arg_pcp,
									 arg_pcp_len,
									 &argStr);
						memcpy(tmp_col->column.valuep,
						       Tcl_DStringValue(&argStr),
						       Tcl_DStringLength(&argStr));
						tmp_col->column.valuep[argStr.length] = '\0';
						Tcl_DStringFree(&argStr);
					} else {
						memcpy(tmp_col->column.valuep,
						       arg_pcp,
						       arg_pcp_len);
						tmp_col->column.valuep[arg_pcp_len] = '\0';
					}

					break;
				}
				tmp_col = tmp_col->next;
			}
			parm_cnt += 2;
		}
	}
	Tcl_SetObjResult(interp, OMV_zero);

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Exec --
 *    Implements the oraexec command:
 *    usage: oraexec stm_handle
 *    usage: ::oratcl::oraexec stm_handle
 *
 *    results:
 *	return code from OCI_StmtExecute
 *      TCL_OK - execution successful
 *      TCL_ERROR - wrong # args, handle not opened, or OCI error
 *----------------------------------------------------------------------
 */

int
Oratcl_Exec (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;
	OratclStms	*RefPtr;
	OratclCols	*tmp_col;

	char		*p;
	ub4		oci_mode = OCI_DEFAULT;
	ub4		rowcnt;
	sword		rc;
	int		ca = 0;

	int		objix;
	int		tcl_return = TCL_OK;
	Tcl_Obj		*rc_obj;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle ?-commit?");
		return TCL_ERROR;
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	StmPtr->ora_rc  = 0;
	Tcl_DStringInit(&StmPtr->ora_err);

	/* cause first orafetch to fetch */
	StmPtr->fetchidx   = StmPtr->fetchmem;
	StmPtr->fetch_end = 0;		/* try to fetch */
	StmPtr->fetch_cnt = 0;		/* start fetch cnt at zero */
	StmPtr->append_cnt = 0;		/* start append cnt at zero */

	if (StmPtr->sqltype == OCI_STMT_SELECT) {
		StmPtr->iters = 0;
	} else {
		StmPtr->iters = 1;
	}

	/* check for option and deprecated keywords */
	if (objc >= 3) {
		p = Tcl_GetStringFromObj(objv[2], (int *) NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"commit") == 0) {
			oci_mode = OCI_COMMIT_ON_SUCCESS;
		}
	}

	if (LogPtr->autocom) {
		oci_mode = OCI_COMMIT_ON_SUCCESS;
	}

	rc = OCI_StmtExecute(LogPtr->svchp,
			     StmPtr->stmhp,
			     LogPtr->errhp,
			     (ub4) StmPtr->iters,
			     (ub4) 0,
			     (OCISnapshot *) NULL,
			     (OCISnapshot *) NULL,
			     oci_mode);


	StmPtr->ora_rc = rc;

	rc_obj = Tcl_NewIntObj(rc);
	Tcl_IncrRefCount(rc_obj);
	Tcl_SetObjResult(interp, rc_obj);
	Tcl_DecrRefCount(rc_obj);

	if (rc == OCI_STILL_EXECUTING) {
		if (LogPtr->async == 1) {
			tcl_return = TCL_OK;
		} else {
			tcl_return = TCL_ERROR;
		}
		goto common_exit;
	}

	if (rc != OCI_SUCCESS && rc != OCI_SUCCESS_WITH_INFO) {
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);
		Oratcl_ColFree(StmPtr->col_list);
		StmPtr->col_list = NULL;
		Oratcl_ColFree(StmPtr->bind_list);
		StmPtr->bind_list = NULL;
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	if (StmPtr->sqltype == OCI_STMT_UPDATE ||
	    StmPtr->sqltype == OCI_STMT_DELETE ||
	    StmPtr->sqltype == OCI_STMT_INSERT) {

		rowcnt = 0;
		rc = (OCI_AttrGet( (dvoid *) StmPtr->stmhp,
				  (ub4) OCI_HTYPE_STMT,
				  (ub4 *) &rowcnt,
				  (ub4) 0,
				  OCI_ATTR_ROW_COUNT,
				  LogPtr->errhp));

		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				0,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
			Oratcl_ErrorMsg(interp,
					objv[0],
					": OCIAttrGet failed",
					(Tcl_Obj *) NULL,
					(char *) NULL);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		/* set "rows" to rpc (rows processed count) */
		StmPtr->ora_row = rowcnt;
	}

	if (StmPtr->sqltype == OCI_STMT_BEGIN ||
	    StmPtr->sqltype == OCI_STMT_DECLARE) {

		if (StmPtr->bind_list) {

			/* for all ref_cursor columns, parse results */
			tmp_col = StmPtr->bind_list;
			while (tmp_col != NULL) {

				if (tmp_col->column.typecode == SQLT_CUR) {
					if (tmp_col->bindPtr != NULL) {
						RefPtr = (OratclStms *) Tcl_GetHashValue(tmp_col->bindPtr);
						Tcl_DStringInit(&RefPtr->ora_err);

						while ((rc = OCI_StmtExecute(LogPtr->svchp,
									     RefPtr->stmhp,
									     LogPtr->errhp,
									     (ub4) 0,
									     (ub4) 0,
									     (OCISnapshot *) NULL,
									     (OCISnapshot *) NULL,
									     OCI_DESCRIBE_ONLY)) == OCI_STILL_EXECUTING) {
							/* NULL statement */
						}

						if (rc != OCI_SUCCESS) {
#ifdef OCI_ATTR_PARSE_ERROR_OFFSET
							OCI_AttrGet( (dvoid *) RefPtr->stmhp,
								    (ub4) OCI_HTYPE_STMT,
								    (ub2 *) &RefPtr->ora_peo,
								    (ub4) 0,
								    OCI_ATTR_PARSE_ERROR_OFFSET,
								    LogPtr->errhp);
#endif
							Oratcl_Checkerr(interp,
									LogPtr->errhp,
									rc,
									1,
									&RefPtr->ora_rc,
									&RefPtr->ora_err);
							tcl_return = TCL_ERROR;
							goto common_exit;
						}

						OCI_AttrGet( (dvoid *) RefPtr->stmhp,
							    (ub4) OCI_HTYPE_STMT,
							    (ub2 *) &RefPtr->ora_fcd,
							    (ub4) 0,
							    OCI_ATTR_SQLFNCODE,
							    LogPtr->errhp);

						if (Oratcl_ColDescribe(interp, RefPtr) == -1) {
							Oratcl_ErrorMsg(interp,
									objv[0],
									": Oratcl_ColDescribe failed for ",
									(Tcl_Obj *) NULL,
									(char *) tmp_col->column.name);
							tcl_return = TCL_ERROR;
							goto common_exit;
						}
						RefPtr->append_cnt = 0;
						RefPtr->fetchidx = RefPtr->fetchmem;
						RefPtr->fetch_end = 0;
						RefPtr->fetch_cnt = 0;
					}
				}

				tmp_col = tmp_col->next;
			}

			StmPtr->fetch_end  = 0;		/* let Oratcl_ColAppend work */
			StmPtr->fetch_cnt  = 0;
			StmPtr->append_cnt = 0;
			StmPtr->fetchidx   = 0;

			/* set results, same as orafetch */
			ca = Oratcl_ColAppend(interp, StmPtr, NULL, NULL, 0);
			if (ca == -1) {
				tcl_return = TCL_ERROR;
				goto common_exit;
			}

			StmPtr->fetch_end  = 1;
			StmPtr->fetch_cnt  = 1;
			StmPtr->append_cnt = 0;
			StmPtr->fetchidx   = 0;
		}
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Break --
 *    Implements the orabreak command:
 *    usage: orabreak stm_handle
 *    usage: ::oratcl::orabreak stm_handle
 *
 *    results:
 *	return code from OCIBreak or OCIReset
 *      TCL_OK - handle is reset
 *      TCL_ERROR - wrong # args, or handle not opened,  OCI error
 *----------------------------------------------------------------------
 */

int
Oratcl_Break (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	sword		rc;
	Tcl_Obj		*rc_obj;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "stm_handle");
		return TCL_ERROR;
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	StmPtr->ora_rc  = 0;
	Tcl_DStringInit(&StmPtr->ora_err);

	if (LogPtr->async == 1) {
		rc = OCI_Break((dvoid *) LogPtr->srvhp,
			       LogPtr->errhp);
		rc_obj = Tcl_NewIntObj(rc);
		Tcl_IncrRefCount(rc_obj);
		Tcl_SetObjResult(interp, rc_obj);
		Tcl_DecrRefCount(rc_obj);
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		rc = OCI_Reset((dvoid *) LogPtr->srvhp,
			       LogPtr->errhp);
		rc_obj = Tcl_NewIntObj(rc);
		Tcl_IncrRefCount(rc_obj);
		Tcl_SetObjResult(interp, rc_obj);
		Tcl_DecrRefCount(rc_obj);
		Oratcl_Checkerr(interp,
				LogPtr->errhp,
				rc,
				1,
				&StmPtr->ora_rc,
				&StmPtr->ora_err);

		if (rc != OCI_SUCCESS) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
	}

common_exit:

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}

	return tcl_return;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Fetch --
 *    Implements the orafetch command:
 *    usage: orafetch statement-handle ?options? ...
 *
 * Results:
 *	return code from OCI_StmtFetch
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Fetch (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
	Tcl_Obj		*CONST objv[];
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	int		ca = 0;
	int		i;
	OratclCols 	*ColPtr;
	OratclCols	*col;
	sword		rc;
	Tcl_Obj		*rc_obj;
	int		hashType = 1;	/* default use column name for array index */
	Tcl_Obj		*oResult;

	int		option;
	CONST84 char *options[] = {"-datavariable",
				   "-dataarray",
				   "-command",
				   "-indexbyname",
				   "-indexbynumber",
				   NULL};
	enum		optindex {OPT_DVAR,
				  OPT_DARR,
				  OPT_EVAL,
				  OPT_IBNA,
				  OPT_IBNU};

	Tcl_Obj		*dvarObjPtr = NULL;
	Tcl_Obj		*avarObjPtr = NULL;
	Tcl_Obj		*evalObjPtr = NULL;

	int		objix;
	int		tcl_return = TCL_OK;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp,
				 objc,
				 objv,
				 "statement-handle ?options ...?");
		return TCL_ERROR;
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_IncrRefCount(objv[objix]);
	}

	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash,
				       Tcl_GetStringFromObj(objv[1], NULL));

	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp,
				objv[0],
				": handle ",
				objv[1],
				" not open");
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);
	LogPtr = (OratclLogs *) Tcl_GetHashValue(StmPtr->logHashPtr);

	for (objix=2; objix<objc; objix++) {
		if (Tcl_GetIndexFromObj(interp,
					objv[objix],
					(CONST84 char **)options,
					"option",
					0,
					&option)) {
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
		switch (option) {
			case OPT_IBNA:
				hashType = 1;
				break;
			case OPT_IBNU:
				hashType = 0;
				break;
			case OPT_DVAR:
				objix++;
				if (objix < objc) {
					dvarObjPtr = objv[objix];
					Tcl_IncrRefCount(dvarObjPtr);
				}
				break;
			case OPT_DARR:
				objix++;
				if (objix < objc) {
					avarObjPtr = objv[objix];
					Tcl_IncrRefCount(avarObjPtr);
				}
				break;
			case OPT_EVAL:
				objix++;
				if (objix < objc) {
					evalObjPtr = objv[objix];
					Tcl_IncrRefCount(evalObjPtr);
				}
				break;
			default:
				/*NOTREACHED*/
				break;
		}

	}

	/*
	 * If PL/SQL, use bind_list else use col_list.
	 */
	if (StmPtr->sqltype == OCI_STMT_BEGIN ||
	    StmPtr->sqltype == OCI_STMT_DECLARE) {
		ColPtr = StmPtr->bind_list;
	} else {
		ColPtr = StmPtr->col_list;
	}

	StmPtr->ora_rc = 0;
	Tcl_DStringInit(&StmPtr->ora_err);
	StmPtr->fetch_ok = 0;

	/* check if already exhausted */

	if (StmPtr->fetch_end
	    && StmPtr->append_cnt >= StmPtr->fetch_cnt
	    && StmPtr->fetch_cnt >  0) {
		rc_obj = Tcl_NewIntObj(NO_DATA_FOUND);
		Tcl_IncrRefCount(rc_obj);
		Tcl_SetObjResult(interp, rc_obj);
		Tcl_DecrRefCount(rc_obj);
		StmPtr->ora_rc = NO_DATA_FOUND;
		tcl_return = TCL_OK;
		goto common_exit;
	}

	if (StmPtr->fetchidx >= StmPtr->fetchmem) {

		for (col=ColPtr; col != NULL; col=col->next) {
			for (i=0; i < StmPtr->fetchmem; i++) {
				col->rcodep[i] = 0;
				col->rlenp[i] = 0;
			}
		}

		rc = OCI_StmtFetch(StmPtr->stmhp,
				  LogPtr->errhp,
				  StmPtr->fetchmem,
				  OCI_FETCH_NEXT,
				  OCI_DEFAULT);


		if (rc == OCI_STILL_EXECUTING) {
			StmPtr->ora_rc = rc;
			Tcl_SetObjResult(interp, Tcl_NewIntObj(rc));
			tcl_return = TCL_OK;
			goto common_exit;
		}

		OCI_AttrGet( (dvoid *) StmPtr->stmhp,
			    (ub4) OCI_HTYPE_STMT,
			    (ub4 *) &StmPtr->fetch_cnt,
			    (ub4) 0,
			    OCI_ATTR_ROW_COUNT,
			    LogPtr->errhp);

		if (rc == OCI_NO_DATA) {
			StmPtr->fetch_end = 1;
			if (StmPtr->append_cnt >= StmPtr->fetch_cnt) {
				rc_obj = Tcl_NewIntObj(NO_DATA_FOUND);
				Tcl_IncrRefCount(rc_obj);
				Tcl_SetObjResult(interp, rc_obj);
				Tcl_DecrRefCount(rc_obj);
				StmPtr->ora_rc = NO_DATA_FOUND;
				tcl_return = TCL_OK;
				goto common_exit;
			}

		} else if (rc == OCI_SUCCESS || rc == OCI_SUCCESS_WITH_INFO) {
			/* Null Statement */
		} else {
			StmPtr->fetch_cnt = 0;
			StmPtr->fetchidx  = 0;
			StmPtr->fetch_end = 1;
			Oratcl_Checkerr(interp,
					LogPtr->errhp,
					rc,
					1,
					&StmPtr->ora_rc,
					&StmPtr->ora_err);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}

		StmPtr->fetchidx = 0;
	}

	ca = Oratcl_ColAppend(interp, StmPtr, dvarObjPtr, avarObjPtr, hashType);
	if (ca == -1) {
		tcl_return = TCL_ERROR;
		goto common_exit;
	}

	/* preserve the result we have set for this command */
	oResult = Tcl_GetObjResult(interp);

	if (evalObjPtr) {
		tcl_return = Tcl_EvalObjEx(interp, evalObjPtr, 0);
	}

	Tcl_SetObjResult(interp, oResult);

common_exit:

	if (dvarObjPtr) {
		Tcl_DecrRefCount(dvarObjPtr);
	}
	if (avarObjPtr) {
		Tcl_DecrRefCount(avarObjPtr);
	}
	if (evalObjPtr) {
		Tcl_DecrRefCount(evalObjPtr);
	}

	for (objix=0; objix<objc; objix++) {
		Tcl_DecrRefCount(objv[objix]);
	}
	return tcl_return;
}

/* finis */
