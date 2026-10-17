/*
 * oratclExtern.h
 *
 * Oracle interface to Tcl
 *
 * Copyright 2017 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _ORATCL_EXTERN_H
#define _ORATCL_EXTERN_H

extern void	  Oratcl_ErrorMsg(Tcl_Interp *interp,
				  Tcl_Obj *obj0,
				  char *msg0,
				  Tcl_Obj *obj1,
				  char *msg1);
extern void	  Oratcl_Checkerr(Tcl_Interp *interp,
				  OCIError *errhp,
				  sword rc,
				  int flag,
				  int *rcPtr,
				  Tcl_DString *errPtr);
extern void	  Oratcl_StmFree(OratclStms *StmPtr);
extern void	  Oratcl_LogFree(OratclLogs *LogPtr);
extern sword	  Oratcl_Attributes(Tcl_Interp *interp,
				    OCIError *errhp,
				    OCIParam *parmh,
				    OratclDesc *column,
				    int explicit);
extern int	  Oratcl_ColAppend(Tcl_Interp *interp,
				   OratclStms *StmPtr,
				   Tcl_Obj *listvar,
				   Tcl_Obj *arrayvar,
				   int hashType);
extern void	  Oratcl_ColFree(OratclCols *ColPtr);

extern int	  Oratcl_ColDescribe(Tcl_Interp *interp,
				     OratclStms *StmPtr);
extern OratclCols *Oratcl_ColAlloc(int fetchrows);


#endif /* _ORATCL_EXTERN_H */
