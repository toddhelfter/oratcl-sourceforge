#ifndef ORATCL_EXTERNS_H
#define ORATCL_EXTERNS_H

/* prototypes for all TCL visible functions */

extern Tcl_ObjCmdProc  Oratcl_Logon;
extern Tcl_ObjCmdProc  Oratcl_Logoff;
extern Tcl_ObjCmdProc  Oratcl_Commit;
extern Tcl_ObjCmdProc  Oratcl_Roll;
extern Tcl_ObjCmdProc  Oratcl_Autocom;
extern Tcl_ObjCmdProc  Oratcl_Lda_List;
extern Tcl_ObjCmdProc  Oratcl_Info;

extern Tcl_ObjCmdProc  Oratcl_Open;
extern Tcl_ObjCmdProc  Oratcl_Close;
extern Tcl_ObjCmdProc  Oratcl_Stm_List;
extern Tcl_ObjCmdProc  Oratcl_Sql;
extern Tcl_ObjCmdProc  Oratcl_Cols;
extern Tcl_ObjCmdProc  Oratcl_Bindexec;
extern Tcl_ObjCmdProc  Oratcl_Fetch;
extern Tcl_ObjCmdProc  Oratcl_PLexec;

#ifdef VERSION7DB
extern Tcl_ObjCmdProc  Oratcl_Wrlong;
extern Tcl_ObjCmdProc  Oratcl_Rdlong;
extern Tcl_ObjCmdProc  Oratcl_Poll;
extern Tcl_ObjCmdProc  Oratcl_Break;
#endif

extern Tcl_ExitProc Oratcl_Kill;

#endif /* ORATCL_EXTERNS_H */


