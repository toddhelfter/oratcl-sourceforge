/*
 *	oratcl.c
 */

/*
 * Oracle interface to Tcl
 *
 * Copyright 1993 Tom Poindexter and U S WEST Advanced Technologies, Inc.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies.
 * Tom Poindexter and U S WEST make no representations about the suitability
 * of this software for any purpose.  It is provided "as is" without express or
 * implied warranty.  By use of this software the user agrees to
 * indemnify and hold harmless Tom Poindexter and U S WEST from any
 * claims or liability for loss arising out of such use.
 */

#if defined(_WIN32) || defined(__WIN32__)
#include <windows.h>
#endif
#include <oci.h>
#include "oratcl.h"
#include "externs.h"
#include <fcntl.h>
#include <sys/stat.h>

#ifdef NO_STRING_H
#include <strings.h>
#else
#include <string.h>
#endif

#include <ctype.h>
#include <stdlib.h>

/* rip off from example.c: defines plus .dll entry point function */
 
#ifdef __WIN32__
#if defined(__WIN32__)
#   if defined(_MSC_VER)
#       define DllEntryPoint DllMain
#   endif   
#endif

#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT

BOOL APIENTRY
DllEntryPoint(hInst, reason, reserved)
HINSTANCE hInst;            /* Library instance handle. */
DWORD reason;               /* Reason this function is being called. */
LPVOID reserved;            /* Not used. */
{
    return TRUE;
}
 

#define strncasecmp strnicmp
 
#else
 
 
/* Windows binary flag for sybreadtext/sybwritetext,unix doesn't need anything*/
 
#define _O_BINARY    0
 
/* prototype for malloc */
extern void * malloc();
 
#endif


EXTERN int Oratcl_Init		_ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int Oratcl_SafeInit	_ANSI_ARGS_((Tcl_Interp *interp));
/* 
 *----------------------------------------------------------------------
 * oTcl_ErrorMsg
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
oTcl_ErrorMsg(interp, obj0, msg0, obj1, msg1) 
	Tcl_Interp	*interp;
	Tcl_Obj 	*obj0, *obj1;
	char		*msg0, *msg1;
{
	Tcl_Obj		*newPtr;

	newPtr = Tcl_DuplicateObj(OMV_null);
	if (obj0) {
		Tcl_IncrRefCount(obj0);
		Tcl_AppendStringsToObj(newPtr, Tcl_GetString(obj0), (char *) NULL);
		Tcl_DecrRefCount(obj0);
	}
	if (msg0) {
		Tcl_AppendToObj(newPtr, msg0, -1);
	}
	if (obj1) {
		Tcl_IncrRefCount(obj1);
		Tcl_AppendStringsToObj(newPtr, Tcl_GetString(obj1), (char *) NULL);
		Tcl_DecrRefCount(obj1);
	}
	if (msg1) {
		Tcl_AppendToObj(newPtr, msg1, -1);
	}
	Tcl_SetObjResult(interp, newPtr);
}


/* 
 *----------------------------------------------------------------------
 * get_ora_lda_handle
 *    authenticate an lda handle string 
 *
 *  return: OraLdas index number or -1 on error;
 *----------------------------------------------------------------------
 */

static int
get_ora_lda_handle (interp, handle) 
	Tcl_Interp	*interp;
	Tcl_Obj		*handle;
{
	int prefix_len = strlen(OraHandlePrefix);
	int lda_h;
	char *lda_s;
	int lda_c;
	int rc = -1;

	lda_s = Tcl_GetStringFromObj(handle, &lda_c);

	if ( (lda_c > prefix_len) &&
		(strncmp(lda_s,OraHandlePrefix,prefix_len) == 0)  &&
		(isdigit((int) *(lda_s + prefix_len))) 
	) {

		lda_h = atoi((lda_s + prefix_len));
		if (lda_h < 0 || lda_h >= ORATCLLDAS) {
			rc = -1;
		}
		if (OraLdas[lda_h].lda_in_use && 
			OraLdas[lda_h].interp == interp) 
		{
			rc = lda_h;
		} else {
			rc = -1;
		}
	} 

	return rc;
}


/* 
 *----------------------------------------------------------------------
 * get_ora_stm_handle
 *    authenticate a statement handle string 
 *
 *  return: OraStms index number or -1 on error;
 *----------------------------------------------------------------------
 */

static int
get_ora_stm_handle (interp, handle) 
	Tcl_Interp	*interp;
	Tcl_Obj		*handle;
{
	char	*lda_s;
	int	lda_c;
	int	lda_h;
	int	stm_h;
	char	*p;
	int	rc = -1;

	lda_h = get_ora_lda_handle(interp, handle);
	if (lda_h >= 0) {

		lda_s = Tcl_GetStringFromObj(handle, &lda_c);
		if ( ((p = strchr(lda_s,'.')) != NULL) 
				&& (isdigit((int) *(p+1))) ) {

			stm_h = atoi((p + 1));
			if (stm_h < 0 || stm_h >= ORATCLSTMS) {
				rc = -1;
			}
			if (OraStms[stm_h].stm_in_use) {
				rc = stm_h;
			} else {
				rc = -1;
			}
		} 
	}
	return rc;
}


/*
 *----------------------------------------------------------------------
 * set_ora_rc
 *   set the oracle return code and error message
 *----------------------------------------------------------------------
 */

int
set_ora_rc (interp, errhp, rc)
	Tcl_Interp	*interp;
	OCIError	*errhp;
	sword		rc;
{

	static text	errbuf[ORA_MSG_SIZE];
	sb4		errcode = 0;

	switch (rc) {

		case OCI_SUCCESS:
			errbuf[0] = '\0';
			break;
		case OCI_SUCCESS_WITH_INFO:
			strcpy(errbuf, "Error - OCI_SUCCESS_WITH_INFO");
			break;
		case OCI_NEED_DATA:
			strcpy(errbuf, "Error - OCI_NEED_DATA");
			break;
		case OCI_NO_DATA:
			strcpy(errbuf, "Error - OCI_NO_DATA");
			errcode = NO_DATA_FOUND;
			break;
		case OCI_ERROR:
			OCIErrorGet ( (dvoid *) errhp,
				      (ub4) 1,
				      (text *) NULL,
				      &errcode,
				      errbuf,
				      (ub4) sizeof(errbuf),
				      (ub4) OCI_HTYPE_ERROR);
			break;
		case OCI_INVALID_HANDLE:
			strcpy(errbuf, "Error - OCI_INVALID_HANDLE");
			break;
		case OCI_STILL_EXECUTING:
			strcpy(errbuf, "Error - OCI_STILL_EXECUTING");
			break;
		case OCI_CONTINUE:
			strcpy(errbuf, "Error - OCI_CONTINUE");
			break;
		default:
			strcpy(errbuf, "Error - Unknown");
	}

	Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_errortxt,
			Tcl_NewStringObj(errbuf, -1),
			TCL_GLOBAL_ONLY);
#if DEBUG
fprintf(stderr, "OM_rc = %d on line %d\n", errcode, __LINE__);
#endif
	Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_rc,
			Tcl_NewIntObj(errcode),
			TCL_GLOBAL_ONLY);
	return errcode;
}


/*
 *----------------------------------------------------------------------
 * clear_msg --
 *
 * clears all error and message elements in the global array variable
 *----------------------------------------------------------------------
 */

static void
clear_msg(interp)
	Tcl_Interp *interp;
{

#if DEBUG
fprintf(stderr, "OM_rc set = NULL on line %d\n", __LINE__);
#endif

	/* index "rc" - return code from last oratcl call */
	Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_rc,
			OMV_null,
			TCL_GLOBAL_ONLY);

	/* index "sqlfunc" - sql function code of last sql */
	Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_sqlfunc,
			OMV_null,
			TCL_GLOBAL_ONLY);

#if 0
	/* index "ocifunc" - oci function code of last call */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_ocifunc, OMV_null, TCL_GLOBAL_ONLY);
#endif

	/* index "errortxt" - text from last rc */
	Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_errortxt,
			OMV_null,
			TCL_GLOBAL_ONLY);

#if 0
	/* index "rowid" - rowid of last row maniuplated */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rowid, OMV_null, TCL_GLOBAL_ONLY);
#endif

	/*
	 * index "collengths", "coltypes", "colprecs", and "colscales" are
	 * only meaningful after an oracols command.
	 */
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_collengths,
		       OMV_null,
		       TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_coltypes,
		       OMV_null,
		       TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_colprecs,
		       OMV_null,
		       TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_colscales,
		       OMV_null,
		       TCL_GLOBAL_ONLY);
}


/*
 *----------------------------------------------------------------------
 * ora_prologue
 *    does most of standard command prologue, assumes handle is objv[1]
 *
 * returns: statement handle index  or -1 on failure
 * 
 *----------------------------------------------------------------------
 */

static int
ora_prologue (interp, objc, objv, num_args, err_msg)
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
	int		num_args;
	char		*err_msg;
{
	int		stm_hand;

	/* check number of minimum args*/
	if (objc < num_args) {
		Tcl_WrongNumArgs(interp, objc, objv, err_msg);
		return (-1);
	}

	clear_msg(interp);

	/* parse the handle */
	stm_hand = get_ora_stm_handle(interp, objv[1]);

	if (stm_hand == -1) {
		oTcl_ErrorMsg(interp,
		       objv[0],
		       ": handle ",
		       objv[1],
		       " not open");
		return (-1);
	}

	/* clear oramsg array for new messages & errors */
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_handle,
		       objv[1],
		       TCL_GLOBAL_ONLY);
	return (stm_hand);
}


/*
 *----------------------------------------------------------------------
 * free_cols
 *   free all ColBufs in a list
 *----------------------------------------------------------------------
 */

static void
free_cols (col_list_ptr)
	ColBufs  *col_list_ptr;
{
	ColBufs  *next;

	while (col_list_ptr != NULL) {
		next = col_list_ptr->next;
		if (col_list_ptr->name != NULL) {
			ckfree(col_list_ptr->name);
		}
		if (col_list_ptr->valuep != NULL) {
			ckfree(col_list_ptr->valuep);
		}
		ckfree((char *) col_list_ptr);
		col_list_ptr = next;
	}
}


/*
 *----------------------------------------------------------------------
 * free_stms
 *   free all statement handles belonging to an lda
 *----------------------------------------------------------------------
 */

static void
free_stms (lda_owner)
	int  lda_owner;
{
	int  i;

	for (i = 0; i < ORATCLSTMS; i++) {
		if (OraStms[i].stm_in_use && (OraStms[i].lda_num==lda_owner)) {
			OraStms[i].stm_in_use = 0;
			OraStms[i].lda_num    = 0;
			OCIHandleFree( (dvoid *) OraStms[i].stmhp,
				       (ub4) OCI_HTYPE_STMT);
			OraStms[i].stmhp      = NULL;
			free_cols(OraStms[i].col_list);
			OraStms[i].col_list   = NULL;;
			free_cols(OraStms[i].bind_list);
			OraStms[i].bind_list  = NULL;;
		}
	}
}


/*
 *----------------------------------------------------------------------
 * alloc_col
 *   return a new ColBufs with nulled pointers and zeroed fields
 *----------------------------------------------------------------------
 */

static ColBufs *
alloc_col()
{
	ColBufs *new_col;

	if ((new_col = (ColBufs *) ckalloc(sizeof (ColBufs))) != NULL) {
		new_col->next		= NULL;
		new_col->type		= 0;
		new_col->size		= 0;
		new_col->name		= NULL;
		new_col->namesz		= 0;
		new_col->valuep 	= NULL;
		new_col->valuesz	= 0;
		new_col->prec		= 0;
		new_col->scale		= 0;
		new_col->defnp		= NULL;
		new_col->bindp		= NULL;
		new_col->colnum		= 0;
		new_col->isnull		= 0;
		new_col->bind_cursor	= -1;
		new_col->indp[0]	= 0;
		new_col->rlenp[0]	= 0;
		new_col->rcodep[0]	= 0;
	}
	return new_col;
}


/*
 *----------------------------------------------------------------------
 * parse_columns
 *   parse result columns, allocate memory for fetches
 *   return -1 on error, 1 if ok
 *----------------------------------------------------------------------
 */

static int
parse_columns (interp, stm_hand)
	Tcl_Interp 	*interp;
	int         	stm_hand;
{
	int		lda_hand;
	sword		rc;
	long		long_size;

	ColBufs		*new_col_head;
	ColBufs		*new_col;
	ColBufs		*last_col;

	OCIParam	*parmdp;
	ub4		parmcnt;
	ub4		parmix;

	text		*namep;

	ub2		peo;
	ub2		fcd;

	new_col_head = alloc_col();
	if (new_col_head == NULL) {
		return -1;
	}
	new_col      = new_col_head;
	last_col     = new_col_head;

	/* get max long size */
	Tcl_GetLongFromObj(
		interp,
		Tcl_ObjGetVar2(interp, OraMsgArray, OM_maxlong, TCL_GLOBAL_ONLY),
		&long_size);

	if (long_size < 0 ) {
		long_size = 0;
	}

	if (long_size > MAX_LONG_SIZE) {
		long_size = MAX_LONG_SIZE;
	}
    
	/* start with initial cache size of ORA_CACHE; may be reduced to 1 */
	OraStms[stm_hand].cache_size = ORA_CACHE;

	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_peo,
		       OMV_zero,
		       TCL_GLOBAL_ONLY);

	lda_hand = OraStms[stm_hand].lda_num;

	rc = OCIStmtExecute(OraLdas[lda_hand].svchp,
				OraStms[stm_hand].stmhp,
				OraLdas[lda_hand].errhp,
				(ub4) 0,
				(ub4) 0,
				(OCISnapshot *) NULL,
				(OCISnapshot *) NULL,
				OCI_DESCRIBE_ONLY);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {

		OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
			    (ub4) OCI_HTYPE_STMT,
			    (ub2 *) &peo,
			    (ub4) 0,
			    OCI_ATTR_PARSE_ERROR_OFFSET,
			    OraLdas[lda_hand].errhp);
		Tcl_ObjSetVar2(interp,
			       OraMsgArray,
			       OM_peo,
			       Tcl_NewIntObj(peo),
			       TCL_GLOBAL_ONLY);
		free_cols(new_col_head);
		return -1;

	}

	OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
		    (ub4) OCI_HTYPE_STMT,
		    (ub2 *) &fcd,
		    (ub4) 0,
		    OCI_ATTR_SQLFNCODE,
		    OraLdas[lda_hand].errhp);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_sqlfunc,
		       Tcl_NewIntObj(fcd),
		       TCL_GLOBAL_ONLY);

	/* get the parameter count info */
	parmcnt = 0;
	rc = OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
			 (ub4) OCI_HTYPE_STMT,
			 (ub4 *) &parmcnt,
			 (ub4) 0,
			 OCI_ATTR_PARAM_COUNT,
			 OraLdas[lda_hand].errhp);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		free_cols(new_col_head);
		return -1;
	}

	for (parmix = 1; parmix <= parmcnt; parmix++) {

		new_col->colnum = parmix;

		rc = OCIParamGet( (dvoid *) OraStms[stm_hand].stmhp,
				  (ub4) OCI_HTYPE_STMT, 
				  (OCIError *) OraLdas[lda_hand].errhp,
				  (dvoid *) &parmdp,
				  (ub4) parmix);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}

		/* get the column data size */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (ub2 *) &new_col->size,
				 (ub4 *) 0,
				 (ub4) OCI_ATTR_DATA_SIZE,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}

		/* get the column data type */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (ub2 *) &new_col->type,
				 (ub4 *) 0,
				 (ub4) OCI_ATTR_DATA_TYPE,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}
	
		/* get the column precision */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (ub1 *) &new_col->prec,
				 (ub4 *) 0,
				 (ub4) OCI_ATTR_PRECISION,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}
	
		/* get the column scale */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (sb1 *) &new_col->scale,
				 (ub4 *) 0,
				 (ub4) OCI_ATTR_SCALE,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}
	
		/* get the null allowed */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (ub1 *) &new_col->isnull,
				 (ub4 *) 0,
				 (ub4) OCI_ATTR_IS_NULL,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}
	
		/* get the column name */
		rc = OCIAttrGet( (dvoid*) parmdp,
				 (ub4) OCI_DTYPE_PARAM,
				 (dvoid *) &namep,
				 (ub4 *) &new_col->namesz,
				 (ub4) OCI_ATTR_NAME,
				 (OCIError *) OraLdas[lda_hand].errhp);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}

		new_col->name = (text *) ckalloc ((size_t) new_col->namesz + 1);
		memcpy(new_col->name, namep, (size_t) new_col->namesz);
		new_col->name[new_col->namesz] = '\0';

		/* make sure this is all the types */
		switch (new_col->type) {
		case SQLT_CHR:
		case SQLT_AFC:
			new_col->valuesz = new_col->size;
			break;
		case SQLT_BIN:
			new_col->valuesz = new_col->size * 2;
			break;
		case SQLT_LBI:
			new_col->valuesz = long_size;
			break;
		case SQLT_NUM:
			/* precision is 0 for floats */
			if (new_col->prec == 0)
				new_col->prec = 38;
			new_col->valuesz = 40;
			break;
		case SQLT_DAT:
			new_col->valuesz = 75;
			break;
		case SQLT_RID:
		case SQLT_RDD:
			new_col->valuesz = 20;
			break;
		default:
			new_col->valuesz = new_col->size;
		}
		new_col->valuesz = new_col->valuesz + 1;

		new_col->valuep = 
			ckalloc (new_col->valuesz * OraStms[stm_hand].cache_size);
	
		rc = OCIDefineByPos(OraStms[stm_hand].stmhp,
				    &new_col->defnp,
				    OraLdas[lda_hand].errhp,
				    (ub4) parmix,
				    (dvoid *) new_col->valuep,
				    (sb4) new_col->valuesz,
				    SQLT_STR,
				    (sb2 *) &new_col->indp,
				    (ub2 *) &new_col->rlenp,
				    (ub2 *) &new_col->rcodep,
				    (ub4) OCI_DEFAULT);

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			return -1;
		}

		last_col           = new_col;
		new_col            = alloc_col();
		if (new_col == NULL) {
			free_cols(new_col_head);
			return -1;
		}
		last_col->next = new_col;

	}

	last_col->next = NULL;
	ckfree((char *) new_col);

	OraStms[stm_hand].col_list = new_col_head;

	return (parmcnt);
}


/*
 *----------------------------------------------------------------------
 * append_cols
 *      appends column results to tcl result
 *----------------------------------------------------------------------
 */

static void
append_cols (interp, stm_hand)
	Tcl_Interp  *interp;
	int          stm_hand;
{
	int		lda_hand;
	int		rn;
	ColBufs		*col;
	char		*null_str;
	Tcl_Obj		*data_obj, *null_obj;
	int		oColsc = 0;


	/* quick sanity check */
	rn = OraStms[stm_hand].row_num;
	if (rn < 0 || rn >= OraStms[stm_hand].cache_size) {
		return;
	}

	lda_hand = OraStms[stm_hand].lda_num;

	null_obj = Tcl_ObjGetVar2(interp,
				  OraMsgArray,
				  OM_nullvalue,
				  TCL_GLOBAL_ONLY);

	null_str = Tcl_GetStringFromObj(null_obj, NULL);

	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {
      
		/* for cursor type, just return a null */
		/* get pointer to next row column data buffer */


		if ((sb2) col->indp[rn] == -1) {
			if (col->type == SQLT_CUR) {
				data_obj = OMV_null;
			} else {
				/* default :: if number "0" else "" */
				if (*null_str == 'd' 
				   && strcmp(null_str,"default") == 0) {

					if (col->type == NUMBER_TYPE) {
						data_obj = OMV_zero;
					} else {
						data_obj = OMV_null;
					}
				} else {
					/* return user defined nullvalue */
					data_obj = null_obj;
				}
			}
		} else {
			if (col->valuesz > 0) {
				data_obj = Tcl_NewStringObj(
					col->valuep + (rn * col->valuesz),
					-1);
			} else {
				data_obj = OMV_null;
			}
		}

		if (oColsc >= oColslen) {
			oColslen += 10;
			oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
		}
		oColsv[oColsc++] = data_obj;

	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	OraStms[stm_hand].row_num += 1;
	OraStms[stm_hand].append_cnt += 1;

#if DEBUG
fprintf(stderr, "OM_rc set = 0 on line %d\n", __LINE__);
#endif
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_rc,
		       OMV_zero,
		       TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_rows,
		       Tcl_NewLongObj(OraStms[stm_hand].append_cnt),
		       TCL_GLOBAL_ONLY);

	fetch_ok = 1;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Kill --
 *   perform all cleanup upon any command deletion
 *----------------------------------------------------------------------
 */

void
Oratcl_Kill (clientData)
	ClientData clientData;
{
	int lda_hand;

	ckfree ((char *) oColsv);
	ckfree ((char *) ColSubs);

	for (lda_hand = 0; lda_hand < ORATCLLDAS; lda_hand++) {
		if (OraLdas[lda_hand].lda_in_use) {
			free_stms(lda_hand);
			OraLdas[lda_hand].lda_in_use = 0;
			OraLdas[lda_hand].interp = NULL;
			OCILogoff(OraLdas[lda_hand].svchp,
				  OraLdas[lda_hand].errhp);
		}
	}

	Tcl_DecrRefCount(OraMsgArray);
	Tcl_DecrRefCount(OMV_null);
	Tcl_DecrRefCount(OMV_zero);
	Tcl_DecrRefCount(OM_rc);
	Tcl_DecrRefCount(OM_rows);
	Tcl_DecrRefCount(OM_peo);
	Tcl_DecrRefCount(OM_rowid);
	Tcl_DecrRefCount(OM_sqlfunc);
	Tcl_DecrRefCount(OM_ocifunc);
	Tcl_DecrRefCount(OM_errortxt);
	Tcl_DecrRefCount(OM_collengths);
	Tcl_DecrRefCount(OM_coltypes);
	Tcl_DecrRefCount(OM_colprecs);
	Tcl_DecrRefCount(OM_colscales);
	Tcl_DecrRefCount(OM_handle);
	Tcl_DecrRefCount(OM_maxlong);
	Tcl_DecrRefCount(OM_nullvalue);
	Tcl_DecrRefCount(OM_version);

	MY_STATS_DUMP;
	Tcl_DumpActiveMemory("/tmp/tmh_dump");
}


/*
 *----------------------------------------------------------------------
 * Oratcl_DeleteInterp --
 *   close any dbprocs left open when an interpreter is deleted
 *   and clear interp level options
 *----------------------------------------------------------------------
 */

void
Oratcl_DeleteInterp (clientData, interp)
    ClientData clientData;
    Tcl_Interp *interp;
{
	int lda_hand;

	for (lda_hand = 0; lda_hand < ORATCLLDAS; lda_hand++) {
		if (OraLdas[lda_hand].lda_in_use 
		    && OraLdas[lda_hand].interp == interp) {
			free_stms(lda_hand);
			OraLdas[lda_hand].lda_in_use = 0;
			OraLdas[lda_hand].interp = NULL;
			OCILogoff(OraLdas[lda_hand].svchp,
				  OraLdas[lda_hand].errhp);
		}
	}
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
	int		i;
	static int	OratclInitFlag = 0;    /* initialization flag */
	Tcl_Obj		*tmp_obj;

#ifdef USE_TCL_STUBS
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
		return TCL_ERROR;
	}
#endif

	/* check if already initialized */
	if (!OratclInitFlag) {

		MY_STATS_INIT;

		/*
		 * Initialize oratcl structures 
		 */

		for (i = 0; i < ORATCLLDAS; i++) {
			OraLdas[i].lda_in_use    = 0;
			OraLdas[i].autocom	 = 0;
		}

		for (i = 0; i < ORATCLSTMS; i++) {
			OraStms[i].lda_num       = 0;
			OraStms[i].col_list      = NULL;
			OraStms[i].cache_size    = ORA_CACHE;
			OraStms[i].row_num       = 0;
			OraStms[i].fetch_end     = 1;
			OraStms[i].fetch_cnt     = 0;
			OraStms[i].append_cnt	 = 0;
			OraStms[i].oexec_done    = 0;
			OraStms[i].first_fetch   = 0;
			OraStms[i].sqltype	 = -1;
		}

		OratclInitFlag = 1;

		Tcl_CreateExitHandler ((Tcl_ExitProc *)Oratcl_Kill,
				       (ClientData) interp);

		OMV_null	= Tcl_NewStringObj("",	-1);
		OMV_zero	= Tcl_NewIntObj(0);

		Tcl_IncrRefCount(OMV_null);
		Tcl_IncrRefCount(OMV_zero);

		/*
		 * Initialize oramsg global array, inital null elements
		 */

		OraMsgArray	= Tcl_NewStringObj("oramsg",	-1);
		OM_rc		= Tcl_NewStringObj("rc",	-1);
		OM_rows		= Tcl_NewStringObj("rows",	-1);
		OM_peo		= Tcl_NewStringObj("peo",	-1);
		OM_rowid	= Tcl_NewStringObj("rowid",	-1);
		OM_sqlfunc	= Tcl_NewStringObj("sqlfunc",	-1);
		OM_ocifunc	= Tcl_NewStringObj("ocifunc",	-1);
		OM_errortxt	= Tcl_NewStringObj("errortxt",	-1);
		OM_collengths	= Tcl_NewStringObj("collengths", -1);
		OM_coltypes	= Tcl_NewStringObj("coltypes",	-1);
		OM_colprecs	= Tcl_NewStringObj("colprecs",	-1);
		OM_colscales	= Tcl_NewStringObj("colscales",	-1);
		OM_handle	= Tcl_NewStringObj("handle",	-1);
		OM_maxlong	= Tcl_NewStringObj("maxlong",	-1);
		OM_nullvalue	= Tcl_NewStringObj("nullvalue",	-1);
		OM_version	= Tcl_NewStringObj("version",	-1);
		tListObjType	= Tcl_GetObjType("list");

		Tcl_IncrRefCount(OraMsgArray);
		Tcl_IncrRefCount(OM_rc);
		Tcl_IncrRefCount(OM_rows);
		Tcl_IncrRefCount(OM_peo);
		Tcl_IncrRefCount(OM_rowid);
		Tcl_IncrRefCount(OM_sqlfunc);
		Tcl_IncrRefCount(OM_ocifunc);
		Tcl_IncrRefCount(OM_errortxt);
		Tcl_IncrRefCount(OM_collengths);
		Tcl_IncrRefCount(OM_coltypes);
		Tcl_IncrRefCount(OM_colprecs);
		Tcl_IncrRefCount(OM_colscales);
		Tcl_IncrRefCount(OM_handle);
		Tcl_IncrRefCount(OM_maxlong);
		Tcl_IncrRefCount(OM_nullvalue);
		Tcl_IncrRefCount(OM_version);

		/* Preallocate some reusable data structures */
		if (oColsv == NULL) {
			oColslen = 10;
			oColsv = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oColsv));
		}

		if (ColSubs == NULL) {
			ColSubsLen = COL_INC;
			ColSubs = (struct colsubd *) ckalloc (ColSubsLen * sizeof(struct colsubd));
		}

	}

	/*
	* Initialize the new Tcl commands
	*/
	Tcl_CreateObjCommand (interp, "oralogon", Oratcl_Logon,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oralogoff", Oratcl_Logoff,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracommit", Oratcl_Commit,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraroll", Oratcl_Roll,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraautocom", Oratcl_Autocom,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraopen", Oratcl_Open,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraclose", Oratcl_Close,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orasql", Oratcl_Sql,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orafetch", Oratcl_Fetch,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracols", Oratcl_Cols,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orabindexec", Oratcl_Bindexec,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraplexec",  Oratcl_PLexec,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orastmlist", Oratcl_Stm_List,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraldalist", Oratcl_Lda_List,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orainfo", Oratcl_Info,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

	/*
	* Initialize oramsg global array, inital null elements
	*/
    
	/* index "version" - oratcl verison number */
	
	tmp_obj = Tcl_NewStringObj(VERSION, -1);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_version,
		       tmp_obj,
		       TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	/* index "handle" - the last handle that set any other elements */
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_handle,
		       OMV_null,
		       TCL_GLOBAL_ONLY);

	/* index "nullvalue" - what to return if column is null		*/
	/* user should set this value if something else is wanted	*/
	tmp_obj = Tcl_NewStringObj("default", -1);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_nullvalue,
		       tmp_obj,
		       TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	/* index "maxlong" - the maximum size of a long column to return */
	/* in a select. Can be set by user                               */
	tmp_obj = Tcl_NewIntObj(BUF_LONG_SIZE);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_maxlong,
		       tmp_obj,
		       TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_peo,
		       OMV_zero,
		       TCL_GLOBAL_ONLY);

	/* other indices - correspond to error and message handler arguments */
	clear_msg(interp);

	/* callback - clean up procs left open on interpreter deletetion */
	Tcl_CallWhenDeleted(interp,
			    (Tcl_InterpDeleteProc *) Oratcl_DeleteInterp,
			    (ClientData) NULL);

	if (Tcl_PkgProvide(interp, "Oratcl", VERSION) != TCL_OK) {
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
 * Oratcl_Logon --
 *    Implements the oralogon command:
 *    usage: oralogon connect_str
 *       connect_str should be a valid oracle logon string, consisting of:
 *         name
 *         name/password
 *         name@d:dbname
 *         name/password@d:dbname
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
	int		lda_hand;
	char 		*con_str, *cpy_str;
	int		con_len;
	sword		rc;
	int		namelen, pwlen, connlen;
	char		*name;
	char		*pword;
	char		*conn;

	char		buf[ORA_MSG_SIZE];
	Tcl_Obj		*buf_obj;


	/* can't use ora_prologue, oralogon creates a logon handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "connect_str");
		return TCL_ERROR;
	}

	/* find an unused handle */
	for (lda_hand = 0; lda_hand < ORATCLLDAS; lda_hand++) {
		if (OraLdas[lda_hand].lda_in_use == 0) {
			break;
		}
	}

	if (lda_hand >= ORATCLLDAS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": no lda handles available",
			      NULL,
			      NULL);
		return TCL_ERROR;
	}

        /*
         * Use Oracle 8 API call OCILogon.
         * orlon does not seen to work with later versions of Oracle 8i
         */

        Tcl_IncrRefCount(objv[1]);
        con_str = Tcl_GetStringFromObj(objv[1], &con_len);
	cpy_str = ckalloc (con_len + 1);
	memcpy (cpy_str, con_str, con_len);
	cpy_str[con_len] = '\0';

        rc = OCIInitialize((ub4) OCI_DEFAULT,
                           (dvoid *)0,
                           (dvoid * (*)(dvoid *, size_t)) 0,
                           (dvoid * (*)(dvoid *, dvoid *, size_t))0,
                           (void (*)(dvoid *, dvoid *)) 0 );

        rc = OCIEnvInit((OCIEnv **) &OraLdas[lda_hand].envhp,
                        OCI_DEFAULT,
                        (size_t) 0,
                        (dvoid **) 0);

        rc = OCIHandleAlloc((dvoid *) OraLdas[lda_hand].envhp,
                            (dvoid **) &OraLdas[lda_hand].errhp,
                            OCI_HTYPE_ERROR,
                            (size_t) 0,
                            (dvoid **) 0);

        rc = OCIHandleAlloc((dvoid *) OraLdas[lda_hand].envhp,
                            (dvoid **) &OraLdas[lda_hand].svchp,
                            OCI_HTYPE_SVCCTX,
                            (size_t) 0,
                            (dvoid **) 0);

        name = strtok(cpy_str, "/@");
        pword = strtok(NULL, "/@");
        conn = strtok(NULL, "/@");

        if (name != NULL)
                namelen = strlen(name);
        else
                namelen = 0;

        if (pword != NULL)
                pwlen = strlen(pword);
        else
                pwlen = 0;

        if (conn != NULL)
                connlen = strlen(conn);
        else
                connlen = 0;

        rc = OCILogon(OraLdas[lda_hand].envhp,
		      OraLdas[lda_hand].errhp,
		      &OraLdas[lda_hand].svchp,
		      name,
		      namelen,
		      pword,
		      pwlen,
		      conn,
		      connlen);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	ckfree(cpy_str);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": invalid username/password; logon denied",
			      NULL,
			      NULL);
		return TCL_ERROR;
	}

        rc = OCIAttrGet((dvoid *) OraLdas[lda_hand].svchp,
                        (ub4) OCI_HTYPE_SVCCTX,
                        (dvoid *) &OraLdas[lda_hand].srvrp,
                        (ub4) 0,
                        (ub4) OCI_ATTR_SERVER,
                        (OCIError *) OraLdas[lda_hand].errhp);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": could not determine server handle.",
			      NULL,
			      NULL);
		return TCL_ERROR;
	}

        Tcl_DecrRefCount(objv[1]);

	OraLdas[lda_hand].lda_in_use = 1;	/* handle ok, set in use flag */
	OraLdas[lda_hand].interp = interp;	/* handle ok, set interp */

	/* construct logon handle and return */
	sprintf(buf,"%s%d",OraHandlePrefix,lda_hand);
	buf_obj = Tcl_NewStringObj(buf, -1);
	Tcl_IncrRefCount(buf_obj);
	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_handle,
		       buf_obj,
		       TCL_GLOBAL_ONLY);
	clear_msg(interp);
	Tcl_SetObjResult(interp, buf_obj);
	Tcl_DecrRefCount(buf_obj);
	return TCL_OK;
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
	int		lda_hand;
	int		rc;

	/* can't use ora_prologue, oralogoff just uses an lda handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": lda_handle ",
			      objv[1],
			      " not valid");
		return TCL_ERROR;
	}

	/* close the open statement handles for this connection */
	free_stms(lda_hand);

	/* logoff and free data areas */
	OraLdas[lda_hand].lda_in_use = 0;
	OraLdas[lda_hand].interp     = NULL;

        rc = OCILogoff(OraLdas[lda_hand].svchp,
		       OraLdas[lda_hand].errhp);

	return TCL_OK;
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
	int		lda_hand;
	sword		rc;

	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	/* can't use ora_prologue, oraroll just uses an lda handle */
	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": lda_handle ",
			      objv[1],
			      " not valid");
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_handle,
		       objv[1],
		       TCL_GLOBAL_ONLY);

	rc = OCITransRollback( (dvoid *) OraLdas[lda_hand].svchp,
			       (dvoid *) OraLdas[lda_hand].errhp,
			       (ub4) OCI_DEFAULT);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": rollback failed",
			      NULL,
			      NULL);
		return TCL_ERROR;
	}

	return TCL_OK;
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
	int		lda_hand;
	sword		rc;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	/* get the lda handle */
	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": lda_handle ",
			      objv[1],
			      " not valid");
		return TCL_ERROR;
	}

	clear_msg(interp);

	Tcl_ObjSetVar2(interp,
		       OraMsgArray,
		       OM_handle,
		       objv[1],
		       TCL_GLOBAL_ONLY);

	rc = OCITransCommit( (dvoid *) OraLdas[lda_hand].svchp,
			     (dvoid *) OraLdas[lda_hand].errhp,
			     (ub4) OCI_DEFAULT);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": commit failed",
			      NULL,
			      NULL);
		return TCL_ERROR;
	}

	return TCL_OK;
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
 *      TCL_OK - OCIAllocHandle successful
 *      TCL_ERROR - OCIAllocHandle not successful - error message returned
 *----------------------------------------------------------------------
 */

int
Oratcl_Info (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int		lda_hand = -1;
	int		stm_hand = -1;
	sword		rc;

	static text	svr[ORA_MSG_SIZE];
	Tcl_Obj		*svr_obj;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	Tcl_IncrRefCount(objv[0]);
	Tcl_IncrRefCount(objv[1]);

	/* get the lda handle */
	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": lda_handle ",
			      objv[1],
			      " not valid");
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	clear_msg(interp);

	rc = OCIServerVersion(OraLdas[lda_hand].svchp,
			      OraLdas[lda_hand].errhp,
			      (text *) &svr,
			      ORA_MSG_SIZE,
			      OCI_HTYPE_SVCCTX);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": commit failed",
			      NULL,
			      NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	svr_obj = Tcl_NewStringObj(svr, -1);
	Tcl_IncrRefCount(svr_obj);
	Tcl_SetObjResult(interp, svr_obj);
	Tcl_DecrRefCount(svr_obj);

	Tcl_DecrRefCount(objv[0]);
	Tcl_DecrRefCount(objv[1]);

	return TCL_OK;
};


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
	int		lda_hand, stm_hand = -1;
	int		i;
	char		buf[ORA_MSG_SIZE];
	Tcl_Obj		*buf_obj;
	sword		rc;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	Tcl_IncrRefCount(objv[0]);
	Tcl_IncrRefCount(objv[1]);

	/* get the lda handle */
	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": lda_handle ",
			      objv[1],
			      " not valid");
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	clear_msg(interp);

	/* find an unused statement handle */
	for (i = 0; i < ORATCLSTMS; i++) {
		if (OraStms[i].stm_in_use == 0) {
			stm_hand = i;
			break;
		}
	}

	if (stm_hand == -1) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": no statement handles available",
			      NULL,
			      NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}
    
	rc = OCIHandleAlloc( (dvoid *) OraLdas[lda_hand].envhp,
				 (dvoid **) &OraStms[stm_hand].stmhp,
				 (ub4) OCI_HTYPE_STMT,
				 (size_t) 0,
				 (dvoid **) 0);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": handle allocation failed",
			      NULL,
			      NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	/* cursor open ok */
	OraStms[stm_hand].stm_in_use	= 1;
	OraStms[stm_hand].lda_num	= lda_hand;
	OraStms[stm_hand].col_list	= NULL;
	OraStms[stm_hand].bind_list	= NULL;
	OraStms[stm_hand].cache_size	= ORA_CACHE;
	OraStms[stm_hand].row_num	= 0;
	OraStms[stm_hand].fetch_end	= 1;
	OraStms[stm_hand].fetch_cnt	= 0;
	OraStms[stm_hand].append_cnt	= 0;
	OraStms[stm_hand].oexec_done	= 0;
	OraStms[stm_hand].first_fetch	= 0;
	OraStms[stm_hand].sqltype	= -1;

	/* construct and return a statement handle */
	sprintf(buf,"%s%d.%d",OraHandlePrefix,lda_hand,stm_hand);  
	buf_obj = Tcl_NewStringObj(buf, -1);
	Tcl_IncrRefCount(buf_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, buf_obj, TCL_GLOBAL_ONLY);
	clear_msg(interp);
	Tcl_SetObjResult(interp, buf_obj);
	Tcl_DecrRefCount(buf_obj);

	Tcl_DecrRefCount(objv[0]);
	Tcl_DecrRefCount(objv[1]);

	return TCL_OK;
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
	int     	stm_hand = -1;
	int     	lda_hand = -1;
	sword		rc;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "stm_handle");
		return TCL_ERROR;
	}

	Tcl_IncrRefCount(objv[0]);
	Tcl_IncrRefCount(objv[1]);

	if ((stm_hand = ora_prologue(interp,objc, objv, 2," stm_handle")) == -1) {
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	lda_hand = OraStms[stm_hand].lda_num;

	rc = OCIHandleFree( (dvoid *) OraStms[stm_hand].stmhp,
				(ub4) OCI_HTYPE_STMT);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc != OCI_SUCCESS) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": handle free failed",
			      NULL,
			      NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	OraStms[stm_hand].stm_in_use 	= 0;
	OraStms[stm_hand].lda_num    	= 0;
	OraStms[stm_hand].stmhp      	= NULL;
	free_cols(OraStms[stm_hand].col_list);
	OraStms[stm_hand].col_list   	= NULL;
	free_cols(OraStms[stm_hand].bind_list);
	OraStms[stm_hand].bind_list  	= NULL;
	OraStms[stm_hand].bind_list  	= 0;
	OraStms[stm_hand].cache_size 	= ORA_CACHE;
	OraStms[stm_hand].row_num    	= 0;
	OraStms[stm_hand].fetch_end  	= 1;
	OraStms[stm_hand].fetch_cnt  	= 0;
	OraStms[stm_hand].append_cnt  	= 0;
	OraStms[stm_hand].oexec_done 	= 0;
	OraStms[stm_hand].first_fetch	= 0;
	OraStms[stm_hand].sqltype	= -1;

	Tcl_DecrRefCount(objv[0]);
	Tcl_DecrRefCount(objv[1]);

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Sql --
 *    Implements the orasql command:
 *    usage: orasql cur_handle sql_string ?-parseonly?
 *	                
 *    results:
 *	return code from oexec
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

	int		lda_hand;
	int		stm_hand = -1;
	sword		rc;

	int		parseonly = 0;
	int		ix;
	int		cols;

	ub4		oci_mode = OCI_DEFAULT;
	ub4		iters = 0;

	char		*p;

	text		*stmt;
	ub4		stmtlen;

	ub4		rowcnt;

	for (ix=0; ix<objc; ix++) {
		Tcl_IncrRefCount(objv[ix]);
	}

	if ((stm_hand = ora_prologue(interp, objc, objv, 3,
		" stm_handle sql_str  ?-parseonly? | ?-commit? ")) ==-1) {
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, OMV_zero, TCL_GLOBAL_ONLY);

	lda_hand = OraStms[stm_hand].lda_num;

	/* check for options and deprecated keywords */
	if (objc >= 4) {
		p = Tcl_GetStringFromObj(objv[3], NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"commit") == 0) {
			oci_mode = OCI_COMMIT_ON_SUCCESS;
		}
		if (strcmp(p,"parseonly") == 0) {
			parseonly = 1;
		}
	}

	if (OraLdas[lda_hand].autocom) {
		oci_mode = OCI_COMMIT_ON_SUCCESS;
	}

	stmt = Tcl_GetStringFromObj(objv[2], &stmtlen);

	/* clear any previous results */
	free_cols(OraStms[stm_hand].col_list);
	OraStms[stm_hand].col_list   = NULL;
	free_cols(OraStms[stm_hand].bind_list);
	OraStms[stm_hand].bind_list  = NULL;
	OraStms[stm_hand].cache_size = ORA_CACHE;
	OraStms[stm_hand].row_num    = 0;
	OraStms[stm_hand].fetch_end  = 1;
	OraStms[stm_hand].fetch_cnt  = 0;
	OraStms[stm_hand].append_cnt  = 0;
	OraStms[stm_hand].oexec_done = 0;
	OraStms[stm_hand].first_fetch= 0;
	OraStms[stm_hand].sqltype	= -1;

	rc = OCIStmtPrepare( (dvoid *) OraStms[stm_hand].stmhp,
				 OraLdas[lda_hand].errhp,
				 (text *) stmt,
				 (ub4) stmtlen,
				 (ub4) OCI_NTV_SYNTAX,
				 (ub4) OCI_DEFAULT);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": OCIStmtPrepare of SQL failed",
			      NULL,
			      NULL);
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}


	/* get sql type */
	OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
		    (ub4) OCI_HTYPE_STMT,
		    (ub2 *) &OraStms[stm_hand].sqltype,
		    (ub4) 0,
		    OCI_ATTR_STMT_TYPE,
		    OraLdas[lda_hand].errhp);

	if (OraStms[stm_hand].sqltype == OCI_STMT_SELECT) {
		iters = 0;

		cols = parse_columns(interp, stm_hand);

		if (cols < 0) {
			fprintf(stderr, "cols = %d\n", cols);
		}

		/* cause first orafetch to fetch */
		OraStms[stm_hand].row_num   = OraStms[stm_hand].cache_size;
		OraStms[stm_hand].fetch_end = 0;
		OraStms[stm_hand].fetch_cnt = 0;
		OraStms[stm_hand].append_cnt = 0;

	} else {
		iters = 1;
	}

	if (parseonly) {
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_OK;
	}

	rc = OCIStmtExecute(OraLdas[lda_hand].svchp,
				OraStms[stm_hand].stmhp,
				OraLdas[lda_hand].errhp,
				(ub4) iters,
				(ub4) 0,
				(OCISnapshot *) NULL,
				(OCISnapshot *) NULL,
				oci_mode);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp, objv[0], ": OCIStmtExecute of SQL failed", NULL, NULL);
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	Tcl_SetObjResult(interp, Tcl_NewIntObj(rc));

	rowcnt = -1;
	rc = (OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
			      (ub4) OCI_HTYPE_STMT,
			      (ub4 *) &rowcnt,
			      (ub4) 0,
			      OCI_ATTR_ROW_COUNT,
			      OraLdas[lda_hand].errhp));

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp, objv[0], ": OCIAttrGet failed", NULL, NULL);
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	/* set "rows" to rpc (rows processed count) */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(rowcnt), TCL_GLOBAL_ONLY);

	for (ix=0; ix<objc; ix++) {
		Tcl_DecrRefCount(objv[ix]);
	}

	return TCL_OK;
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
	int		stm_hand;
	int		lda_hand;
	int		parm_cnt;
	ub4		oci_mode = OCI_DEFAULT;
	ub4		iters = 0;
	ub4		rowcnt;
	sword		rc;

	ColBufs		*tmp_col_head;
	ColBufs		*tmp_col;
	ColBufs		*head_col;

	char		*arg_pcc, *arg_pcp, *p;
	int		arg_pcc_len, arg_pcp_len;

	if ((stm_hand = ora_prologue(interp,objc, objv, 2,
		" stm_handle ?-commit?  [ :varname value ] ...")) == -1) {
		return TCL_ERROR;
	}
	lda_hand = OraStms[stm_hand].lda_num;

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, OMV_zero, TCL_GLOBAL_ONLY);

	OraStms[stm_hand].oexec_done = 0;
	OraStms[stm_hand].first_fetch= 0;

	parm_cnt = 2;

	/* check for option and deprecated keywords */
	if (objc >= 3) {
		p = Tcl_GetStringFromObj(objv[2], (int *) NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"commit") == 0) {
			oci_mode = OCI_COMMIT_ON_SUCCESS;
			parm_cnt++;
		}
	}

	/* if first time in, allocate bind_list */
	if (OraStms[stm_hand].bind_list == NULL) {

		if (objc > parm_cnt + 1) {
			tmp_col_head = alloc_col();
			if (tmp_col_head == NULL) {
				oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
				return TCL_ERROR;
			}
			tmp_col      = tmp_col_head;
			head_col     = tmp_col_head;
			OraStms[stm_hand].bind_list = tmp_col_head;
		} else {
			tmp_col_head = NULL;
		}

		while (objc > parm_cnt + 1) {       /* always in pairs of two */

			/* get two arg strings */
			arg_pcc = Tcl_GetStringFromObj(objv[parm_cnt], &arg_pcc_len);
			arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);

			/* make sure bind variable name has a leading ':' */
			if (*arg_pcc != ':') {
				free_cols(OraStms[stm_hand].col_list);
				OraStms[stm_hand].col_list = NULL;
				free_cols(OraStms[stm_hand].bind_list);
				OraStms[stm_hand].bind_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": bind variable ", objv[parm_cnt], "does not begin with ':'");
				return TCL_ERROR;
			}

			tmp_col->name = ckalloc(arg_pcc_len + 1);
			memcpy(tmp_col->name, arg_pcc, arg_pcc_len);
			tmp_col->name[arg_pcc_len] = '\0';

			tmp_col->rlenp[0] = 0;
			tmp_col->rcodep[0] = 0;

			tmp_col->valuesz = ORA_BIND_SIZE;
			tmp_col->valuep   = ckalloc(tmp_col->valuesz + 1);
			memcpy(tmp_col->valuep, arg_pcp, arg_pcp_len);
			tmp_col->valuep[arg_pcp_len] = '\0';

			tmp_col->bindp = (OCIBind *) 0;

			rc = OCIBindByName(OraStms[stm_hand].stmhp,
					   (OCIBind **) &tmp_col->bindp,
					   OraLdas[lda_hand].errhp,
					   (text *) tmp_col->name,
					   (sb4) -1,
					   (dvoid *) tmp_col->valuep,
					   (sb4) tmp_col->valuesz + 1,
					   (ub2) SQLT_STR,
					   (dvoid *) &tmp_col->indp[0],
					   (ub2 *) 0,
					   (ub2 *) 0,
					   (ub4) 0,
					   (ub4 *) 0,
					   (ub4) OCI_DEFAULT);

			set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

			if (rc != OCI_SUCCESS) {
				free_cols(OraStms[stm_hand].col_list);
				OraStms[stm_hand].col_list = NULL;
				free_cols(OraStms[stm_hand].bind_list);
				OraStms[stm_hand].bind_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": bind failed for ", objv[parm_cnt], NULL);
				return TCL_ERROR;
			}

			parm_cnt += 2;

			if (objc > parm_cnt + 1) {       /* more args? alloc new colbufs */
				head_col           = tmp_col;
				tmp_col            = alloc_col();
				if (tmp_col == NULL) {
					free_cols(OraStms[stm_hand].col_list);
					OraStms[stm_hand].col_list = NULL;
					free_cols(OraStms[stm_hand].bind_list);
					OraStms[stm_hand].bind_list = NULL;
					oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
					return TCL_ERROR;
				}
				head_col->next = tmp_col;
			}
		}

	} else {
		/* else, binds have been done, just copy in new data */
		while (objc > parm_cnt + 1) {       /* always in pairs of two */
			tmp_col = OraStms[stm_hand].bind_list;
			while (tmp_col != NULL) {
				if (strncmp(tmp_col->name, Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL), 255) == 0) {
					arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);
					memcpy(tmp_col->valuep, arg_pcp, arg_pcp_len);
					tmp_col->valuep[arg_pcp_len] = '\0';
					break;
				}
				tmp_col = tmp_col->next;
			}
			parm_cnt += 2;
		}
	}
  
	if (OraLdas[lda_hand].autocom) {
		oci_mode = OCI_COMMIT_ON_SUCCESS;
	}

	if (OraStms[stm_hand].sqltype == OCI_STMT_SELECT) {
		iters = 0;
		/* cause first orafetch to fetch */
		OraStms[stm_hand].row_num   = OraStms[stm_hand].cache_size;
		OraStms[stm_hand].fetch_end = 0;        /* try to fetch */
		OraStms[stm_hand].fetch_cnt = 0;        /* start fetch cnt at zero */
		OraStms[stm_hand].append_cnt = 0;       /* start append cnt at zero */
	} else {
		iters = 1;
	}

	rc = OCIStmtExecute(OraLdas[lda_hand].svchp,
			    OraStms[stm_hand].stmhp,
			    OraLdas[lda_hand].errhp,
			    (ub4) iters,
			    (ub4) 0,
			    (OCISnapshot *) NULL,
			    (OCISnapshot *) NULL,
			    oci_mode);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp,
			      objv[0],
			      ": OCIStmtExecute of SQL failed",
			      NULL,
			      NULL);
		free_cols(OraStms[stm_hand].col_list);
		OraStms[stm_hand].col_list = NULL;
		free_cols(OraStms[stm_hand].bind_list);
		OraStms[stm_hand].bind_list = NULL;
		return TCL_ERROR;
	}

	if (OraStms[stm_hand].sqltype == OCI_STMT_UPDATE ||
	    OraStms[stm_hand].sqltype == OCI_STMT_DELETE ||
	    OraStms[stm_hand].sqltype == OCI_STMT_INSERT) {

		rowcnt = -1;
		rc = (OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
				      (ub4) OCI_HTYPE_STMT,
				      (ub4 *) &rowcnt,
				      (ub4) 0,
				      OCI_ATTR_ROW_COUNT,
				      OraLdas[lda_hand].errhp));

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
			oTcl_ErrorMsg(interp,
				      objv[0],
				      ": OCIAttrGet failed",
				      NULL,
				      NULL);
			return TCL_ERROR;
		}

		/* set "rows" to rpc (rows processed count) */
		Tcl_ObjSetVar2(interp,
			       OraMsgArray,
			       OM_rows,
			       Tcl_NewLongObj(rowcnt),
			       TCL_GLOBAL_ONLY);
	}

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Fetch --
 *    Implements the orafetch command:
 *    usage: orafetch cur_handle 
 *	                
 * Results:
 *	next row from latest results as tcl list, or null list
 *	sets message array element "rc" with value of fetch rcode
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

	int		stm_hand;
	int		lda_hand;
	sword		rc;

	ColBufs 	*col;
	int      	i;


	if ((stm_hand = ora_prologue(interp, objc, objv, 2, 
		" stm_handle  ?commands? ?subtitution_char?")) == -1) {
		return TCL_ERROR;
	}

	/* if there's a third argument, let next proc do the work */
	if (objc >= 3) {
		return (Oratcl_FetchAll(clientData,
					interp,
					objc,
					objv,
					stm_hand));
	}

	fetch_ok = 0;

	/* check if already exahusted */


	if (OraStms[stm_hand].fetch_end 
	    && OraStms[stm_hand].append_cnt >= OraStms[stm_hand].fetch_cnt
	    && OraStms[stm_hand].fetch_cnt >  0) {

		/* need some way to remember the return codes */
		
#if 0
		Tcl_SetObjResult(interp, Tcl_NewIntObj(NO_DATA_FOUND));
#endif
		Tcl_SetObjResult(interp, OMV_null);

#if DEBUG
fprintf(stderr, "OM_rc = %d on line %d\n", NO_DATA_FOUND, __LINE__);
#endif
		Tcl_ObjSetVar2(interp,
				OraMsgArray,
				OM_rc,
				Tcl_NewIntObj(NO_DATA_FOUND),
				TCL_GLOBAL_ONLY);
		return TCL_OK;
	}

	lda_hand = OraStms[stm_hand].lda_num;

	if (OraStms[stm_hand].row_num >= OraStms[stm_hand].cache_size) {

		for (col=OraStms[stm_hand].col_list; col != NULL; col=col->next) {
			for (i=0; i < OraStms[stm_hand].cache_size; i++) {
				col->rcodep[i] = 0;
				col->rlenp[i] = 0;
			}
		}

		/* Orapoll may perform the first fetch */

		rc = OCIStmtFetch(OraStms[stm_hand].stmhp,
					OraLdas[lda_hand].errhp,
					OraStms[stm_hand].cache_size,
					OCI_FETCH_NEXT,
					OCI_DEFAULT);

		OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
			    (ub4) OCI_HTYPE_STMT,
			    (ub4 *) &OraStms[stm_hand].fetch_cnt,
			    (ub4) 0,
			    OCI_ATTR_ROW_COUNT,
			    OraLdas[lda_hand].errhp);

		Tcl_ObjSetVar2(interp,
				OraMsgArray,
				OM_rc,
				Tcl_NewIntObj(NO_DATA_FOUND),
				TCL_GLOBAL_ONLY);

		if (rc == OCI_NO_DATA) {
			OraStms[stm_hand].fetch_end = 1;
			if (OraStms[stm_hand].append_cnt >= OraStms[stm_hand].fetch_cnt) {
				return TCL_OK;
			}

		} else if (rc != OCI_SUCCESS) {
			OraStms[stm_hand].fetch_cnt = 0;
			OraStms[stm_hand].row_num  = 0;
			OraStms[stm_hand].fetch_end = 1;
			set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);
			oTcl_ErrorMsg(interp,
				      objv[0],
				      ": OCIStmtFetch failed",
				      NULL,
				      NULL);
			return TCL_ERROR;
		}

		OraStms[stm_hand].row_num = 0;
	}

	append_cols(interp, stm_hand);
	return TCL_OK;

}


/*
 *----------------------------------------------------------------------
 * Oratcl_FetchAll --
 *    Implements the orafetch with iterative commands:
 *    usage: orafetch cur_handle tcl_stmts substitution_char ?tclvar colnum ..?
 *	                
 * Results:
 *	fetch all rows from existing query, execute tcl_stmt on each row
 *	sets message array element "rc" with value of final fetch rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened, tcl_stmt failed,
 *                  or wrong number of columns
 *----------------------------------------------------------------------
 */

int
Oratcl_FetchAll (clientData, interp, objc, objv, stm_hand)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
        int		stm_hand;
{
	int		ix;
	char    	*s, *p, *token;
	int		ch, nch;

#define SUBCHAR '@'		/* default substitution character */

	char     subchar = SUBCHAR; /* substitution character */
	int      num_str = 0;	/* number of strings to concat */

	char		*cmd_str;
	int		cmd_len;

	Tcl_DString	evalStr;	/* dynamic string for building eval */
	int		parm_cnt;
	int		inum, jnum;
	int		tcl_rc;

	Tcl_Obj		*oResult;
        Tcl_Obj		**infoObjv, **varsObjv;
        int		infoObjc, varsObjc;

	/* nothing to fetch */
	if (OraStms[stm_hand].col_list == NULL) {   
		return TCL_OK;			
	}

	if (objc >= 4) {
		p = Tcl_GetStringFromObj(objv[3], NULL);
		if ((ch = *p) == ' ') {
			subchar = '\0';
		} else if (ch != '\0') {
			subchar = ch;
		}
	}

	cmd_str = Tcl_GetStringFromObj(objv[2], &cmd_len);

	if (cmd_str == NULL) {
		return TCL_OK;			/* nothing to fetch */
	}

	token = p = cmd_str;
	num_str = 0;
	while ((ch = *p++) != '\0') {
		if (ch == subchar) {
			if ((nch = *p) == subchar) {
				if (num_str >= ColSubsLen) {
					ColSubsLen += COL_INC;
					ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
				}
				ColSubs[num_str].strlen = p - token;
				ColSubs[num_str].strpos = token;
				ColSubs[num_str++].column = -1;
				token = ++p;
			} else if (isdigit(nch)) {
				if (num_str + 1 >= ColSubsLen) {
					ColSubsLen += COL_INC;
					ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
				}
				if ((ColSubs[num_str].strlen = p - 1 - token) > 0) {
					ColSubs[num_str].strpos = token;
					ColSubs[num_str++].column = -1;
				}
				ColSubs[num_str++].column = strtol(p, &s, 10);
				token = p = s;
			}
		}
	}


	if (num_str >= ColSubsLen) {
		ColSubsLen += COL_INC;
		ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
	}
	if ((ColSubs[num_str].strlen = p - 1 - token) > 0) {
		ColSubs[num_str].strpos = token;
		ColSubs[num_str++].column = -1;
	}

	/* loop until fetch exhausted */

	if (Oratcl_Fetch(clientData, interp, 2, objv) == TCL_ERROR) {
		oTcl_ErrorMsg(interp, objv[0], ": orafetch failed", NULL, NULL);
		return TCL_ERROR;
	}

	while (fetch_ok) {

		oResult = Tcl_GetObjResult(interp);
		if (Tcl_IsShared(oResult) && oResult->typePtr != tListObjType) {
			oResult = Tcl_DuplicateObj(oResult);
		}
		Tcl_IncrRefCount(oResult);
		tcl_rc = Tcl_ListObjGetElements(interp, oResult, &infoObjc, &infoObjv);

		if (tcl_rc != TCL_OK) {
			oTcl_ErrorMsg(interp, objv[0], ": Tcl_ListObjGetElements failed", NULL, NULL);
			Tcl_DecrRefCount(oResult);
			return TCL_ERROR;
		}

		/* build eval string from literals and columns */
		Tcl_DStringInit(&evalStr);
		for (inum=0; inum < num_str; inum++) {
			if (ColSubs[inum].column > -1) {
				if (ColSubs[inum].column == 0) {    /* col 0 is entire result */
					Tcl_DStringStartSublist(&evalStr);
					for (jnum=0; jnum < infoObjc; jnum++) {
						Tcl_DStringAppendElement(&evalStr, Tcl_GetStringFromObj(infoObjv[jnum], NULL));
					}
					Tcl_DStringEndSublist(&evalStr);
				} else {
					if (ColSubs[inum].column > infoObjc) {/* another sanity chk*/
						Tcl_DStringFree(&evalStr); 	/* free eval string */
						oTcl_ErrorMsg(interp, objv[0], ": column sanity failed on column sub", NULL, NULL);
						Tcl_DecrRefCount(oResult);
						return TCL_ERROR;
					}
					Tcl_DStringAppendElement(&evalStr, Tcl_GetStringFromObj(infoObjv[ColSubs[inum].column -1], NULL)); 
				}
			} else {
				Tcl_DStringAppend(&evalStr, ColSubs[inum].strpos, ColSubs[inum].strlen);
			}
		}

		/* handle tclvar colnum pairs passed as a single  arg */
		if (objc == 5) {
			tcl_rc = Tcl_ListObjGetElements(interp, objv[objc - 1], &varsObjc, &varsObjv);
			if (tcl_rc != TCL_OK) {
				oTcl_ErrorMsg(interp, objv[0], ": Tcl_ListObjGetElements failed", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			} 
		} else {
			varsObjc = objc - 4;
			varsObjv = (Tcl_Obj **) objv + 4;
		}

		/* handle tclvar colnum pairs passed as individual args */
		for (parm_cnt = 0; parm_cnt < varsObjc; parm_cnt += 2) {
			if (parm_cnt + 1 >= varsObjc) {
				Tcl_DStringFree(&evalStr); 	/* free eval string */
				oTcl_ErrorMsg(interp, objv[0], ": column sanity failed on tclvar bind", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			}
			tcl_rc = Tcl_GetIntFromObj(interp, varsObjv[parm_cnt + 1], &ix);
			if (tcl_rc != TCL_OK || ix < 0 || ix > infoObjc) {
				Tcl_DStringFree(&evalStr); 	/* free eval string */
				oTcl_ErrorMsg(interp, objv[0], ": invalid integer column", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			}
			if (ix == 0) {
				Tcl_ObjSetVar2(interp, varsObjv[parm_cnt], NULL, Tcl_NewListObj(infoObjc, infoObjv), 0);
			} else {
				Tcl_ObjSetVar2(interp, varsObjv[parm_cnt], NULL, infoObjv[ix - 1], 0);
			}
		}
		Tcl_DecrRefCount(oResult);

		if (Tcl_DStringLength(&evalStr) > 0) {
			tcl_rc = Tcl_Eval(interp, (char *) Tcl_DStringValue(&evalStr));
		} else {
			tcl_rc = TCL_OK;
		}

		Tcl_DStringFree(&evalStr);

		switch (tcl_rc) {
			case TCL_ERROR:
				oTcl_ErrorMsg(interp, objv[0], ": eval failed while in ", objv[0], NULL);
				return TCL_ERROR;
				break;

			case TCL_BREAK:		/* return sooner */
				return TCL_OK;
				break;

			default:
				break;
		}

		/*
		 * I wonder why we need this (Todd Helfter) TMH
		 */
#if 0
		Tcl_ResetResult(interp);	/* reset interp result for next */
#endif
 
		/* next fetch */
		if (Oratcl_Fetch(clientData, interp, 2, objv) == TCL_ERROR) {
			oTcl_ErrorMsg(interp, objv[0], ": orafetch failed", NULL, NULL);
			return TCL_ERROR;
		}
	}

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Cols --
 *    Implements the oracols command:
 *    usage: oracols stm_handle 
 *	                
 *    results:
 *	latest column names as tcl list
 *      also set oramsg(collengths) and oramsg(coltypes) as tcl list
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
	int		stm_hand;
	ColBufs		*col;
	char		*type_ptr;
	int		oColsc;
	Tcl_Obj		*buf_obj;

	if ((stm_hand = ora_prologue(interp,objc, objv, 2," stm_handle")) == -1) {
		return TCL_ERROR;
	}

	oColsc = 0;

	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {
		if (oColsc >= oColslen) {
			oColslen += 10;
			oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
		}
		oColsv[oColsc++] = Tcl_NewStringObj(col->name, -1);
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	oColsc = 0;
	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {
		oColsv[oColsc++] = Tcl_NewIntObj(col->valuesz - 1);
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp,
			      OraMsgArray,
			      OM_collengths,
			      Tcl_NewListObj(oColsc, oColsv),
			      TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {
		/* get the column type and append to "coltypes" */
		switch (col->type) {
			case 1:
				type_ptr = "varchar2";
				break;
			case 2:
				type_ptr = "number";
				break;
			case 8:
				type_ptr = "long";
				break;
			case 11:
				type_ptr = "rowid";
				break;
			case 12:
				type_ptr = "date";
				break;
			case 23:
				type_ptr = "raw";
				break;
			case 24:
				type_ptr = "long_raw";
				break;
			case 96:
				type_ptr = "char";
				break;
			case 102:
				type_ptr = "cursor";
				break;
			case 104:
				type_ptr = "rowid";
				break;
			case 105:
				type_ptr = "mlslabel";
				break;
			case 106:
				type_ptr = "raw_mlslabel";
				break;
			default:
				type_ptr = "unknown";
				break;
		}
		oColsv[oColsc++] = Tcl_NewStringObj(type_ptr, -1);
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_coltypes,
			Tcl_NewListObj(oColsc, oColsv),
			TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {

		/* format precision and scale for numeric data */
		if (col->type == 2) {
			buf_obj = Tcl_NewIntObj(col->prec);
		} else {
			buf_obj = OMV_null;
		}
		oColsv[oColsc++] = buf_obj;
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp,
			      OraMsgArray,
			      OM_colprecs,
			      Tcl_NewListObj(oColsc, oColsv),
			      TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraStms[stm_hand].col_list; col != NULL; col = col->next) {
		if (col->type == 2) {
			buf_obj = Tcl_NewIntObj(col->scale);
		} else {
			buf_obj = OMV_null;
		}
		oColsv[oColsc++] = buf_obj;
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp,
			      OraMsgArray,
			      OM_colscales,
			      Tcl_NewListObj(oColsc, oColsv),
			      TCL_GLOBAL_ONLY);
	}

	return TCL_OK;
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
	int	stm_hand;
	int	lda_hand;
	int	parm_cnt;
	sword	rc;

	ColBufs	*new_col_head = NULL;
	ColBufs	*new_col = NULL;
	ColBufs	*last_col = NULL;

	int	cursor_hand = -1;

	char	*pl_str;
	int	pl_len;

	ub4		oci_mode = OCI_DEFAULT;

	char		*arg_pcc, *arg_pcp;
	int		arg_pcc_len, arg_pcp_len;
	
	/* prologue */
	if ((stm_hand = ora_prologue(interp,objc, objv, 3,
	    " stm_handle pl_block [ :varname value ] ...")) == -1) {
		return TCL_ERROR;
	}
	lda_hand = OraStms[stm_hand].lda_num;

	if (OraLdas[lda_hand].autocom) {
		oci_mode = OCI_COMMIT_ON_SUCCESS;
	}

	/* free existing columns, if any */
	free_cols(OraStms[stm_hand].col_list);
	OraStms[stm_hand].col_list   = NULL;
	free_cols(OraStms[stm_hand].bind_list);
	OraStms[stm_hand].bind_list   = NULL;
	OraStms[stm_hand].fetch_end  = 1;
	OraStms[stm_hand].fetch_cnt  = 0;
	OraStms[stm_hand].append_cnt  = 0;
	OraStms[stm_hand].cache_size = ORA_CACHE;
	OraStms[stm_hand].row_num    = ORA_CACHE;

	pl_str = Tcl_GetStringFromObj(objv[2], &pl_len);

	rc = OCIStmtPrepare( (dvoid *) OraStms[stm_hand].stmhp,
				 OraLdas[lda_hand].errhp,
				 (text *) pl_str,
				 (ub4) pl_len,
				 (ub4) OCI_NTV_SYNTAX,
				 (ub4) OCI_DEFAULT);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp, objv[0], ": OCIStmtPrepare of PL/SQL failed", NULL, NULL);
		return TCL_ERROR;
	}

	/* get sql type */
	OCIAttrGet( (dvoid *) OraStms[stm_hand].stmhp,
		    (ub4) OCI_HTYPE_STMT,
		    (ub2 *) &OraStms[stm_hand].sqltype,
		    (ub4) 0,
		    OCI_ATTR_STMT_TYPE,
		    OraLdas[lda_hand].errhp);

	/* bind :colon_parms following arg, alloc large enough return space (?)*/
	parm_cnt = 3;      

	/* only alloc new col if one or more valid arg for :var */
	if (objc > parm_cnt + 1) {        
		new_col_head = alloc_col();
		if (new_col_head == NULL) {
			oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
			return TCL_ERROR;
		}
		new_col      = new_col_head;
		last_col     = new_col_head;
	} else {
		new_col_head = NULL;
	}

	while (objc > parm_cnt + 1) {       /* always in pairs of two */

		/* make sure bind variable name has a leading ':' */
		arg_pcc = Tcl_GetStringFromObj(objv[parm_cnt], &arg_pcc_len);
		arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);

		/* make sure bind variable name has a leading ':' */
		if (*arg_pcc != ':') {
			free_cols(new_col_head);
			OraStms[stm_hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": bind variable ", objv[parm_cnt], " does not begin with ':'");
			return TCL_ERROR;
		}


		if ((cursor_hand = get_ora_stm_handle(interp, objv[parm_cnt+1])) >= 0) {

			if (stm_hand == cursor_hand) {
				free_cols(new_col_head);
				OraStms[stm_hand].col_list = NULL;
				oTcl_ErrorMsg(interp,
					      objv[0],
					      ": bind cursor for ",
					      objv[parm_cnt],
					      " same as cursor_handle");
				return TCL_ERROR;
			}

			if (OraStms[stm_hand].lda_num != OraStms[cursor_hand].lda_num) {
				free_cols(new_col_head);
				OraStms[stm_hand].col_list = NULL;
				oTcl_ErrorMsg(interp,
					      objv[0],
					      ": bind cursor for ",
					      objv[parm_cnt],
					      " not from same login handle as cursor_handle");
				return TCL_ERROR;
			}

			free_cols(OraStms[cursor_hand].col_list);
			OraStms[cursor_hand].col_list	= NULL;
			free_cols(OraStms[cursor_hand].bind_list);
			OraStms[cursor_hand].bind_list	= NULL;
			OraStms[cursor_hand].cache_size	= ORA_CACHE;
			OraStms[cursor_hand].row_num   = OraStms[cursor_hand].cache_size;
			OraStms[cursor_hand].fetch_end = 0;        /* try to fetch */
			OraStms[cursor_hand].fetch_cnt = 0;        /* start fetch cnt at zero */
			OraStms[cursor_hand].append_cnt = 0;       /* start append cnt at zero */

			new_col->bind_cursor = cursor_hand;
		} else {
			new_col->bind_cursor = -1;
		}

		new_col->valuesz = ORA_BUFF_SIZE;
		new_col->valuep = ckalloc(new_col->valuesz + 1);
		if (new_col->valuep == NULL) {
			free_cols(new_col_head);
			OraStms[stm_hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": allocation failure", objv[parm_cnt], NULL);
			return TCL_ERROR;
		}
		memcpy(new_col->valuep, arg_pcp, arg_pcp_len);
		new_col->valuep[arg_pcp_len] = '\0';

		new_col->rlenp[0] = 0;
		new_col->rcodep[0] = 0;

		new_col->name = ckalloc(arg_pcc_len + 1);
		if (new_col->name == NULL) {
			free_cols(new_col_head);
			OraStms[stm_hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": allocation failure", objv[parm_cnt+1], NULL);
			return TCL_ERROR;
		}
		memcpy(new_col->name, arg_pcc, arg_pcc_len);
		new_col->name[arg_pcc_len] = '\0';
		new_col->namesz = arg_pcc_len;

		if (cursor_hand == -1) {

			/* string data type */
			new_col->type = SQLT_STR;

			rc = OCIBindByName(OraStms[stm_hand].stmhp,
					   (OCIBind **) &new_col->bindp,
					   OraLdas[lda_hand].errhp,
					   (text *) new_col->name,
					   (sb4) strlen((char *)new_col->name),
					   (dvoid *) new_col->valuep,
					   (sb4) new_col->valuesz + 1,
					   (ub2) SQLT_STR,
					   (dvoid *) &new_col->indp[0],
					   (ub2 *) 0,
					   (ub2 *) 0,
					   (ub4) 0,
					   (ub4 *) 0,
					   (ub4) OCI_DEFAULT);

		} else {

			/* cursor data type */
			new_col->type = SQLT_CUR;

			rc = OCIBindByName(OraStms[stm_hand].stmhp,
					   (OCIBind **) &new_col->bindp,
					   OraLdas[lda_hand].errhp,
					   (text *) new_col->name,
					   (sb4) strlen((char *)new_col->name),
					   (dvoid *) &OraStms[cursor_hand].stmhp,
					   (sb4) 0,
					   (ub2) SQLT_RSET,
					   (dvoid *) 0,
					   (ub2 *) 0,
					   (ub2 *) 0,
					   (ub4) 0,
					   (ub4 *) 0,
					   (ub4) OCI_DEFAULT);
		}

		set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

		if (rc != OCI_SUCCESS) {
			free_cols(new_col_head);
			OraStms[stm_hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": bind failed for ", objv[parm_cnt], NULL);
			return TCL_ERROR;
		}

		parm_cnt += 2;

		if (objc > parm_cnt + 1) {        /* more args? alloc new colbufs */
			last_col           = new_col;
			new_col            = alloc_col();
			if (new_col == NULL) {
				free_cols(new_col_head);
				OraStms[stm_hand].col_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col ", NULL, NULL);
				return TCL_ERROR;
			}
			last_col->next = new_col;
		}
	}

	OraStms[stm_hand].col_list   = new_col_head;

	rc = OCIStmtExecute(OraLdas[lda_hand].svchp,
			    OraStms[stm_hand].stmhp,
			    OraLdas[lda_hand].errhp,
			    (ub4) 1,
			    (ub4) 0,
			    (OCISnapshot *) NULL,
			    (OCISnapshot *) NULL,
			    oci_mode);

	set_ora_rc(interp, OraLdas[lda_hand].errhp, rc);

	if (rc == OCI_ERROR || rc == OCI_INVALID_HANDLE) {
		oTcl_ErrorMsg(interp, objv[0], ": OCIStmtExecute of PL/SQL failed", NULL, NULL);
		return TCL_ERROR;
	}

	/* for all cursor_hands, parse results */
	new_col = new_col_head;
	while (new_col != NULL) {
		if (new_col->type == SQLT_CUR) {
			cursor_hand = new_col->bind_cursor;
			if (cursor_hand >= 0) {
				if (parse_columns(interp, cursor_hand) == -1) {
					oTcl_ErrorMsg(interp,
						      objv[0],
						      ": parse_columns failed for ",
						      NULL,
						      new_col->name);
					return TCL_ERROR;
				}
				OraStms[cursor_hand].append_cnt = 0; /* cursors lie about rpc */
				OraStms[cursor_hand].row_num = OraStms[cursor_hand].cache_size;
				OraStms[cursor_hand].fetch_end = 0;
				OraStms[cursor_hand].fetch_cnt = 0; 
			}
		}
		new_col = new_col->next;
	}

	OraStms[stm_hand].fetch_end  = 0;        /* let append_cols work */
	OraStms[stm_hand].fetch_cnt  = 0;        
	OraStms[stm_hand].append_cnt = 0;        
	OraStms[stm_hand].row_num    = 0;

	/* get results, same as orafetch */
	append_cols(interp, stm_hand);
   
	OraStms[stm_hand].fetch_end  = 1;
	OraStms[stm_hand].fetch_cnt  = 1;
	OraStms[stm_hand].append_cnt = 0;        
	OraStms[stm_hand].row_num    = 0;
	OraStms[stm_hand].cache_size = 1;

	/* don't free col_list yet; allow oracols to fetch info */

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Autocom --
 *    Implements the oraautocom command:
 *    usage: oraroll lda_handle on|off
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
	int		lda_hand;
	int		ix;

	/* can't use ora_prologue, oraautocom just uses an lda handle */
	clear_msg(interp);

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle on|off");
		return TCL_ERROR;
	}

	for (ix=0; ix<objc; ix++) {
		Tcl_IncrRefCount(objv[ix]);
	}

	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, objv[1], TCL_GLOBAL_ONLY);

	/* case insensitive compare */
	if (strncasecmp(
		Tcl_GetStringFromObj(objv[2], (int *) NULL),"on",2) == 0
	) {
		OraLdas[lda_hand].autocom = 1;
	} else {
		OraLdas[lda_hand].autocom = 0;
	}

	for (ix=0; ix<objc; ix++) {
		Tcl_DecrRefCount(objv[ix]);
	}

	return TCL_OK;
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
	int	hand;
	int	oColsc;
	char	buf[ORA_MSG_SIZE];

	oColsc = 0;
	for (hand = 0; hand < ORATCLLDAS; hand++) {
		if (OraLdas[hand].lda_in_use) {
			if (oColsc >= oColslen) {
				oColslen += 10;
				oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
			}
			sprintf(buf, "%s%d", OraHandlePrefix, hand);
			oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		}
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	return TCL_OK;
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
	int	stm_hand, lda_hand;
	int	oColsc;
	char	buf[ORA_MSG_SIZE];

	/* can't use ora_prologue, oracurlist just uses an lda handle */
	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		return TCL_ERROR;
	}

	oColsc = 0;
	for (stm_hand = 0; stm_hand < ORATCLSTMS; stm_hand++) {
		if (OraStms[stm_hand].stm_in_use && (OraStms[stm_hand].lda_num == lda_hand)) {
			if (oColsc >= oColslen) {
				oColslen += 10;
				oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
			}
			sprintf(buf, "%s.%d", Tcl_GetStringFromObj(objv[1], NULL), stm_hand);
			oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		}
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	return TCL_OK;
}

/* finis */
