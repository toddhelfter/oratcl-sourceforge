/*
 * oralob2.c
 *
 * Oracle LOB operations using OCI C API (OCILobRead2)
 * Parallel implementation to oralob for testing/validation.
 *
 * Copyright 2017 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "oratclInt.h"
#include "oratclTypes.h"
#include "oratclExtern.h"

#include <string.h>

/*
 *----------------------------------------------------------------------
 * Oratcl_Lob2 --
 *
 *   oralob2 read stm_handle -table T -column C -rowid R -datavariable V
 *
 *   Reads a CLOB or BLOB using OCILobRead2 and returns the content
 *   via the datavariable.
 *
 *----------------------------------------------------------------------
 */

int
Oratcl_Lob2(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*stmHashPtr;
	Tcl_HashEntry	*logHashPtr;
	OratclStms	*StmPtr;
	OratclLogs	*LogPtr;

	const char	*subcmd;
	const char	*stmName;
	const char	*table = NULL;
	const char	*column = NULL;
	const char	*rowid = NULL;
	const char	*datavar = NULL;
	const char	*lobtypestr = NULL;
	int		isBlob = 0;
	int		i;
	int		tcl_return = TCL_OK;

	OCIStmt		*selStmhp = NULL;
	OCIDefine	*defnp = NULL;
	OCIBind		*bndp = NULL;
	OCILobLocator	*lobp = NULL;
	sword		rc;
	oraub8		lobLen = 0;
	oraub8		byte_amt;
	oraub8		char_amt;
	oraub8		offset;
	ub1		piece;
	sb2		ind = 0;

	char		*buf = NULL;
	Tcl_DString	result;
	char		sqlbuf[512];

	if (objc < 4) {
		Tcl_WrongNumArgs(interp, 1, objv,
			"read stm_handle -table T -column C -rowid R -lobtype clob|blob -datavariable V");
		return TCL_ERROR;
	}

	subcmd = Tcl_GetStringFromObj(objv[1], NULL);
	if (strcmp(subcmd, "read") != 0) {
		Oratcl_ErrorMsg(interp, objv[0],
			": unknown subcommand '", objv[1], "'");
		return TCL_ERROR;
	}

	stmName = Tcl_GetStringFromObj(objv[2], NULL);

	/* parse named arguments */
	for (i = 3; i < objc - 1; i += 2) {
		const char *opt = Tcl_GetStringFromObj(objv[i], NULL);
		const char *val = Tcl_GetStringFromObj(objv[i+1], NULL);

		if (strcmp(opt, "-table") == 0) {
			table = val;
		} else if (strcmp(opt, "-column") == 0) {
			column = val;
		} else if (strcmp(opt, "-rowid") == 0) {
			rowid = val;
		} else if (strcmp(opt, "-lobtype") == 0) {
			lobtypestr = val;
		} else if (strcmp(opt, "-datavariable") == 0) {
			datavar = val;
		} else {
			Oratcl_ErrorMsg(interp, objv[0],
				": unknown option '", objv[i], "'");
			return TCL_ERROR;
		}
	}

	if (table == NULL || column == NULL || rowid == NULL
	    || datavar == NULL || lobtypestr == NULL) {
		Oratcl_ErrorMsg(interp, objv[0],
			": -table, -column, -rowid, -lobtype, and -datavariable are required",
			(Tcl_Obj *) NULL, (char *) NULL);
		return TCL_ERROR;
	}

	if (strcmp(lobtypestr, "blob") == 0) {
		isBlob = 1;
	} else if (strcmp(lobtypestr, "clob") == 0) {
		isBlob = 0;
	} else {
		Oratcl_ErrorMsg(interp, objv[0],
			": -lobtype must be 'clob' or 'blob'",
			(Tcl_Obj *) NULL, (char *) NULL);
		return TCL_ERROR;
	}

	/* look up the statement handle */
	stmHashPtr = Tcl_FindHashEntry(OratclStatePtr->stmHash, stmName);
	if (stmHashPtr == NULL) {
		Oratcl_ErrorMsg(interp, objv[0],
			": handle ", objv[2], " not open");
		return TCL_ERROR;
	}
	StmPtr = (OratclStms *) Tcl_GetHashValue(stmHashPtr);

	/* look up the login handle */
	logHashPtr = StmPtr->logHashPtr;
	if (logHashPtr == NULL) {
		Oratcl_ErrorMsg(interp, objv[0],
			": login handle not found",
			(Tcl_Obj *) NULL, (char *) NULL);
		return TCL_ERROR;
	}
	LogPtr = (OratclLogs *) Tcl_GetHashValue(logHashPtr);

	/* build SELECT to get the LOB locator */
	snprintf(sqlbuf, sizeof(sqlbuf),
		 "SELECT %s FROM %s WHERE ROWID = :rid",
		 column, table);

	/* allocate a statement handle for the LOB select */
	rc = OCI_HandleAlloc((dvoid *) LogPtr->envhp,
			     (dvoid **) &selStmhp,
			     (ub4) OCI_HTYPE_STMT,
			     (size_t) 0,
			     (dvoid **) 0);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* prepare the statement */
	rc = OCI_StmtPrepare(selStmhp,
			     LogPtr->errhp,
			     (text *) sqlbuf,
			     (ub4) strlen(sqlbuf),
			     (ub4) OCI_NTV_SYNTAX,
			     (ub4) OCI_DEFAULT);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* allocate a LOB locator descriptor */
	rc = OCI_DescriptorAlloc((dvoid *) LogPtr->envhp,
				 (dvoid **) &lobp,
				 (ub4) OCI_DTYPE_LOB,
				 (size_t) 0,
				 (dvoid **) 0);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* bind the rowid parameter */
	rc = OCI_BindByName(selStmhp,
			    &bndp,
			    LogPtr->errhp,
			    (text *) ":rid",
			    (sb4) 4,
			    (dvoid *) rowid,
			    (sb4) strlen(rowid) + 1,
			    (ub2) SQLT_STR,
			    (dvoid *) 0,
			    (ub2 *) 0,
			    (ub2 *) 0,
			    (ub4) 0,
			    (ub4 *) 0,
			    (ub4) OCI_DEFAULT);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* define the LOB output */
	rc = OCI_DefineByPos(selStmhp,
			     &defnp,
			     LogPtr->errhp,
			     (ub4) 1,
			     (dvoid *) &lobp,
			     (sb4) sizeof(OCILobLocator *),
			     isBlob ? (ub2) SQLT_BLOB : (ub2) SQLT_CLOB,
			     (sb2 *) &ind,
			     (ub2 *) 0,
			     (ub2 *) 0,
			     (ub4) OCI_DEFAULT);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* execute the SELECT */
	rc = OCI_StmtExecute(LogPtr->svchp,
			     selStmhp,
			     LogPtr->errhp,
			     (ub4) 0,		/* iters=0 for SELECT */
			     (ub4) 0,
			     (CONST OCISnapshot *) NULL,
			     (OCISnapshot *) NULL,
			     (ub4) OCI_DEFAULT);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* fetch the row */
	rc = OCI_StmtFetch(selStmhp,
			   LogPtr->errhp,
			   (ub4) 1,
			   (ub2) OCI_FETCH_NEXT,
			   (ub4) OCI_DEFAULT);
	if (rc != OCI_SUCCESS && rc != OCI_SUCCESS_WITH_INFO) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	/* check for NULL */
	if (ind == -1) {
		Tcl_ObjSetVar2(interp,
			       Tcl_NewStringObj(datavar, -1),
			       NULL,
			       Tcl_NewStringObj("", 0),
			       0);
		goto cleanup;
	}

	/* get LOB length */
	rc = OCI_LobGetLength2(LogPtr->svchp,
			       LogPtr->errhp,
			       lobp,
			       &lobLen);
	if (rc != OCI_SUCCESS) {
		Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
				&StmPtr->ora_rc, &StmPtr->ora_err);
		tcl_return = TCL_ERROR;
		goto cleanup;
	}

	Tcl_DStringInit(&result);

	if (lobLen > 0) {
		ub4 bufsz = StmPtr->lobpsize;
		if (bufsz < 1) {
			bufsz = 32768;
		}

		buf = (char *) ckalloc(bufsz + 1);
		if (buf == NULL) {
			Oratcl_ErrorMsg(interp, objv[0],
				": allocation failure",
				(Tcl_Obj *) NULL, (char *) NULL);
			Tcl_DStringFree(&result);
			tcl_return = TCL_ERROR;
			goto cleanup;
		}

		offset = 1;	/* Oracle 1-based */

		do {
			byte_amt = 0;
			char_amt = bufsz;
			piece = OCI_ONE_PIECE;

			rc = OCI_LobRead2(LogPtr->svchp,
					  LogPtr->errhp,
					  lobp,
					  &byte_amt,
					  &char_amt,
					  offset,
					  (dvoid *) buf,
					  (oraub8) bufsz,
					  piece,
					  (dvoid *) 0,
					  (sb4 (*)(dvoid *, CONST dvoid *, oraub8, ub1, dvoid **, oraub8 *)) 0,
					  (ub2) 0,
					  (ub1) SQLCS_IMPLICIT);

			if (rc != OCI_SUCCESS && rc != OCI_NEED_DATA) {
				if (rc == OCI_ERROR) {
					Oratcl_Checkerr(interp, LogPtr->errhp, rc, 1,
							&StmPtr->ora_rc, &StmPtr->ora_err);
				}
				break;
			}

			if (byte_amt > 0) {
				Tcl_DStringAppend(&result, buf, (int) byte_amt);
				offset += char_amt;
			}

		} while (rc == OCI_NEED_DATA);

		ckfree(buf);
		buf = NULL;

		if (rc != OCI_SUCCESS && rc != OCI_NEED_DATA) {
			Tcl_DStringFree(&result);
			tcl_return = TCL_ERROR;
			goto cleanup;
		}
	}

	/* set the datavariable — for BLOBs, set as byte array */
	if (isBlob) {
		Tcl_ObjSetVar2(interp,
			       Tcl_NewStringObj(datavar, -1),
			       NULL,
			       Tcl_NewByteArrayObj(
				       (const unsigned char *) Tcl_DStringValue(&result),
				       Tcl_DStringLength(&result)),
			       0);
	} else {
		/* CLOB: set as string */
		Tcl_ObjSetVar2(interp,
			       Tcl_NewStringObj(datavar, -1),
			       NULL,
			       Tcl_NewStringObj(
				       Tcl_DStringValue(&result),
				       Tcl_DStringLength(&result)),
			       0);
	}

	Tcl_DStringFree(&result);
	Tcl_SetObjResult(interp, Tcl_NewIntObj(0));

cleanup:
	if (lobp != NULL) {
		OCI_DescriptorFree((dvoid *) lobp, (ub4) OCI_DTYPE_LOB);
	}
	if (selStmhp != NULL) {
		OCI_HandleFree((dvoid *) selStmhp, (ub4) OCI_HTYPE_STMT);
	}

	return tcl_return;
}
