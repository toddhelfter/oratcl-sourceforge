/*
 * oratclExtern.h
 *
 * Oracle interface to Tcl
 *
 * Copyright 2007 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _ORATCL_EXTERN_H
#define _ORATCL_EXTERN_H


extern void Oratcl_ErrorMsg	_ANSI_ARGS_((Tcl_Interp 	*interp,
					     Tcl_Obj    	*obj0,
					     char       	*msg0,
					     Tcl_Obj		*obj1,
					     char		*msg1));
extern void Oratcl_Checkerr	_ANSI_ARGS_((Tcl_Interp		*interp,
					     OCIError		*errhp,
					     sword		rc,
					     int		flag,
					     int		*rcPtr,
					     Tcl_DString	*errPtr));
extern void Oratcl_StmFree	_ANSI_ARGS_((OratclStms		*StmPtr));

#endif /* _ORATCL_H */
