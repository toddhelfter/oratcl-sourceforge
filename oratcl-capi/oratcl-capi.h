/* oratcl-capi - C api to Oratcl */

/* oratcl-capi.h interface stuff */

#ifndef _ORATCL_CAPI
#define _ORATCL_CAPI

/* include our fake tcl.h */
#include "tcl.h"

/* make defines for each "element" of oramsg */
/* these must be in the same order as the index values !! */

#define Handle      0
#define Rc          1
#define Sqlfunc     2
#define Ocifunc     3
#define Errortxt    4
#define Rows        5
#define Collengths  6
#define Coltypes    7
#define Colprecs    8
#define Colscales   9
#define Ociinfo     10
#define Maxlong     11
#define Nullvalue   12
#define Version     13

/* make Maxstatus same as last status message */
#define Maxstatus   13

/*
"handle"    
"rc"        
"sqlfunc"    
"ocifunc"    
"errortxt"   
"rows"       
"collengths" 
"coltypes"   
"colprecs"   
"colscales"  
"ociinfo"  
"maxlong"    
"nullvalue"  
"version"  
*/


#ifndef NULL
#define NULL 0
#endif


/* macros to access status, results, columns, number of columns */

#define GET_STATUS(interp,i)     \
    (interp->status[i]==NULL||i<0||i>Maxstatus?"":interp->status[i])

#define RESULT(interp) 		 (interp->column[0]==NULL?"":interp->column[0])

#define COLUMN(interp,i) 	 \
    (interp->column[i]==NULL||i<0||i>=interp->num_columns?"":interp->column[i])

#define NUMCOLS(interp)		 (interp->num_columns)



/* the oratcl-capi functions */

EXTERN Tcl_Interp * Oratcl_MkInterp _ANSI_ARGS_((void));

EXTERN int  Oratcl_Init _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN void Oratcl_FreeInterp _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN int Oralogon _ANSI_ARGS_((Tcl_Interp *interp, char *connect_str));

EXTERN int Oralogoff _ANSI_ARGS_((Tcl_Interp *interp, char *lda_handle));

EXTERN int Oraopen _ANSI_ARGS_((Tcl_Interp *interp, char *lda_handle));

EXTERN int Oraclose _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle));

EXTERN int Orasql _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle, 
				char *sql_str, char *async_parseonly));

EXTERN int Orapoll _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle, 
				char *all));

EXTERN int Orabreak _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle));

EXTERN int Orabindexec _ANSI_ARGS_( 
			    VARARGS(Tcl_Interp *interp));

EXTERN int Orafetch _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle));

EXTERN int Oracols _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle));

EXTERN int Oracancel _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle));

EXTERN int Oraplexec _ANSI_ARGS_(
			    VARARGS(Tcl_Interp *interp));

EXTERN int Orawritelong _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle,
                	char *rowid, char *table, char *column, char *file));

EXTERN int Orareadlong _ANSI_ARGS_((Tcl_Interp *interp, char *cur_handle,
                	char *rowid, char *table, char *column, char *file));

EXTERN int Oracommit _ANSI_ARGS_((Tcl_Interp *interp, char *lda_handle));

EXTERN int Oraroll _ANSI_ARGS_((Tcl_Interp *interp, char *lda_handle));

EXTERN int Oraautocom _ANSI_ARGS_((Tcl_Interp *interp, char *lda_handle, 
				char *state));

#endif /* _ORATCL_CAPI */

