/* 
 *	externs.h
 */
#ifndef ORATCL_EXTERNS_H
#define ORATCL_EXTERNS_H

/* prototypes for TCL visible functions */

extern Tcl_ObjCmdProc  Oratcl_Logon;
extern Tcl_ObjCmdProc  Oratcl_Logoff;
extern Tcl_ObjCmdProc  Oratcl_Commit;
extern Tcl_ObjCmdProc  Oratcl_Roll;
extern Tcl_ObjCmdProc  Oratcl_Autocom;
extern Tcl_ObjCmdProc  Oratcl_Lda_List;
extern Tcl_ObjCmdProc  Oratcl_Info;
extern Tcl_ObjCmdProc  Oratcl_Describe;

extern Tcl_ObjCmdProc  Oratcl_Open;
extern Tcl_ObjCmdProc  Oratcl_Close;
extern Tcl_ObjCmdProc  Oratcl_Stm_List;
extern Tcl_ObjCmdProc  Oratcl_Sql;
extern Tcl_ObjCmdProc  Oratcl_Cols;
extern Tcl_ObjCmdProc  Oratcl_Bindexec;
extern Tcl_ObjCmdProc  Oratcl_Fetch;
extern Tcl_ObjCmdProc  Oratcl_PLexec;
extern Tcl_ObjCmdProc  Oratcl_Config;

extern Tcl_ObjCmdProc  Oratcl_Lob;
extern Tcl_ObjCmdProc  Oratcl_LobParse;
extern Tcl_ObjCmdProc  Oratcl_LobRead;
extern Tcl_ObjCmdProc  Oratcl_LobWrite;
extern Tcl_ObjCmdProc  Oratcl_LobOpen;
extern Tcl_ObjCmdProc  Oratcl_LobClose;

extern Tcl_ExitProc Oratcl_Kill;

#endif /* ORATCL_EXTERNS_H */
