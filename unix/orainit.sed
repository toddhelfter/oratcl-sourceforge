/if.*Tcl[X]*_Init.*interp.*==.*TCL_ERROR/{
n
n
n
i\
\
\ \ \ \ if (Oratcl_Init (interp) == TCL_ERROR) {\
\ \ \ \     return TCL_ERROR;\
\ \ \ \ }\
\ \ \ \ Tcl_StaticPackage (interp, "Oratcl", Oratcl_Init, (Tcl_PackageInitProc *) NULL);

}
