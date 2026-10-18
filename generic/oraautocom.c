/*
 * oraautocom.c
 *
 * Oracle interface to Tcl
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
Oratcl_Autocom(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	OratclState	*OratclStatePtr = (OratclState *) clientData;
	Tcl_HashEntry	*logHashPtr;
	OratclLogs	*LogPtr;

	int		boolval;
	int		tcl_return = TCL_OK;

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

	Tcl_GetBooleanFromObj(interp, objv[2], &boolval);
	LogPtr->autocom = boolval;

	Tcl_SetObjResult(interp, Tcl_NewIntObj(boolval));

common_exit:

	return tcl_return;
}
