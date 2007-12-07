/*
 * orainfo.c
 *
 * Oracle interface to Tcl
 *
 * Copyright 2007 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */


#include "oratclInt.h"
#include "oratclTypes.h"
#include "oratclExtern.h"

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
	ub4		serverStatus = 0;

	/* note that 'loginhandle' is a typo.  This will be deprecated in the next version */
	CONST84 char *options[] = {"server",
				   "client",
				   "status",
				   "version",
				   "logonhandle",
				   "loginhandle",
				   NULL};

	enum		optindex {OPT_SERVER,
				  OPT_CLIENT,
				  OPT_STATUS,
				  OPT_VERSION,
				  OPT_LOGONHANDLE,
				  OPT_LOGINHANDLE};

	int		index = 0;
	int		tcl_return = TCL_OK;

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
			Tcl_SetObjResult(interp, Tcl_NewIntObj(OCI_SERVER_NORMAL));
			break;
		case OCI_SERVER_NOT_CONNECTED:
			Tcl_SetObjResult(interp, Tcl_NewIntObj(OCI_SERVER_NOT_CONNECTED));
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


		if (rc != OCI_SUCCESS) {
			Oratcl_Checkerr(interp,
					LogPtr->errhp,
					rc,
					1,
					&LogPtr->ora_rc,
					&LogPtr->ora_err);
			tcl_return = TCL_ERROR;
			goto common_exit;
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj((char *) svr, -1));

	}

	if (index == OPT_CLIENT) {
		sword	major_version = 0;
		sword	minor_version = 0;
		sword 	update_num = 0;
		sword	patch_num = 0;
		sword	port_update_num = 0;

		if (OCI_ClientVersion != NULL) {
			rc = OCI_ClientVersion(&major_version,
					       &minor_version,
					       &update_num,
					       &patch_num,
					       &port_update_num);
		}
		sprintf( (char *) svr,
			"%d.%d.%d.%d.%d",
			(int) major_version,
			(int) minor_version,
			(int) update_num,
			(int) patch_num,
			(int) port_update_num);
		Tcl_SetObjResult(interp, Tcl_NewStringObj((char *) svr, -1));

	}

	if (index == OPT_LOGONHANDLE || index == OPT_LOGINHANDLE) {
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
		Tcl_SetObjResult(interp, Tcl_NewStringObj((char *) logHashKey, -1));
	}

common_exit:

	return tcl_return;
}
