/* oratcl-capi - fake tcl core routines and other support */

/* Copyright Tom Poindexter, 1996 */

/* include our fake tcl.h & oratcl-api.h */

#include "oratcl-capi.h"  	


/* status indexes, normally in tcl oramsg array */
/* these must agree with defines in oratcl-capi.h !!    */

static char *OraStatus[] = {
	{  "handle"	},
	{  "rc"	        },
	{  "sqlfunc"	},
	{  "ocifunc"	},
	{  "errortxt"	},
	{  "rows"	},
	{  "collengths"	},
	{  "coltypes"	},
	{  "colprecs"	},
	{  "colscales"	},
	{  "ociinfo"	},
	{  "maxlong"	},
	{  "nullvalue"  },
	{  "version"    }
};

#define MAX_STATUS (sizeof OraStatus / sizeof (char *))


/* oratclc helper functions */

Tcl_Interp * Oratcl_MkInterp () 
{
  int i;
  Tcl_Interp *interp;

  interp = (Tcl_Interp *) malloc (sizeof(Tcl_Interp));
  interp->column = (char **) malloc ((sizeof (char *)) * 256); 
  for (i = 0; i < 256; i++) {
    interp->column[i] = (char *) NULL;
  }
  interp->result = (char *) NULL;

  interp->status = (char **) malloc ((sizeof (char *)) * MAX_STATUS); 
  for (i = 0; i < MAX_STATUS; i++) {
    interp->status[i] = (char *) NULL;
  }

  return interp;
}

void Oratcl_FreeInterp (interp)
  Tcl_Interp *interp;
{
  int i;
  for (i = 0; i < MAX_STATUS; i++) {
    if (interp->status[i] != NULL) {
      free (interp->status[i]);
    }
  }
  Tcl_ResetResult(interp);
  free(interp);
}



/* oratcl-capi emulated tcl functions */


void Tcl_ResetResult (interp) 
  Tcl_Interp *interp;
{
  int i;
  for (i = 0; i < 256; i++) {
    if (interp->column[i] != NULL) {
      free (interp->column[i]);
      interp->column[i] = (char *)NULL;
    }
  }
  interp->num_columns = 0;
}


void Tcl_SetResult (interp, buf, freeProc) 
  Tcl_Interp *interp;
  char *buf; 
  Tcl_FreeProc *freeProc; 
{
  Tcl_ResetResult(interp);
  interp->column[0] = (char *) malloc(strlen(buf)+1);
  strcpy(interp->column[interp->num_columns],buf);
  interp->num_columns = 1;
  interp->result = interp->column[0];
}



#ifndef lint
void
Tcl_AppendResult(va_alist)
#else
void
        /* VARARGS2 */ /* ARGSUSED */
Tcl_AppendResult(interp, p, va_alist)
    Tcl_Interp *interp;         /* Interpreter whose result is to be
                                 * extended. */
    char *p;                    /* One or more strings to add to the
                                 * result, terminated with NULL. */
#endif
    va_dcl
{
    va_list argList;
    register Tcl_Interp *iPtr;
    char *string;
    int newSpace;
    int oldSpace;
    char *buf2;
 
    /*
     * First, scan through all the arguments to see how much space is
     * needed.
     */
 
    va_start(argList);
    iPtr = va_arg(argList, Tcl_Interp *);
    newSpace = 0;
    while (1) {
        string = va_arg(argList, char *);
        if (string == NULL) {
            break;
        }
        newSpace += strlen(string);
    }
    va_end(argList);

    /*
     * If the append buffer isn't already setup and large enough
     * to hold the new data, set it up.
     */
 
    if (iPtr->column[0] != NULL) {
      oldSpace += strlen(iPtr->column[0]);
    } 

    newSpace += oldSpace + 1;
    buf2 = (char *) malloc (newSpace);
    if (iPtr->column[0] != NULL) {
      strcpy(buf2,iPtr->column[0]);
      free (iPtr->column[0]);
    } 
    iPtr->column[0] = buf2;
 
    /*
     * Final step:  go through all the argument strings again, copying
     * them into the buffer.
     */
 
    va_start(argList);
    (void) va_arg(argList, Tcl_Interp *);
    while (1) {
        string = va_arg(argList, char *);
        if (string == NULL) {
            break;
        }
        strcat(iPtr->column[0],string);
    }
    va_end(argList);
    iPtr->num_columns = 1;
    iPtr->result = iPtr->column[0];
}



void Tcl_AppendElement (interp, buf) 
  Tcl_Interp *interp; 
  char *buf;
{
  interp->column[interp->num_columns] = (char *) malloc(strlen(buf)+1);
  strcpy(interp->column[interp->num_columns],buf);
  interp->num_columns++;
  interp->result = interp->column[0];
}


char *Tcl_SetVar2 (interp, arrname, index, buf, flag) 
  Tcl_Interp *interp; 
  char *arrname; 
  char *index; 
  char *buf; 
  int flag; 
{
  int i;
  for (i = 0; i < MAX_STATUS; i++) {
    if (strcmp(index,OraStatus[i]) == 0) { 
      if (interp->status[i] != NULL) {
	free (interp->status[i]);
      }
      interp->status[i] = (char *) malloc (strlen(buf)+1);
      strcpy(interp->status[i],buf);
      return ( interp->status[i] );
    }
  }
  return "";
}
 
char *Tcl_GetVar2 (interp, arrname, index, flag) 
  Tcl_Interp *interp;
  char *arrname;
  char *index;
  int flag; 
{
  int i;
  for (i = 0; i < MAX_STATUS; i++) {
    if (strcmp(index,OraStatus[i]) == 0) { 
      return (interp->status[i] == NULL ? "" : interp->status[i]);
    }
  }
  return "";
}
 



/* now define the C api interfaces to oratcl */

/* count argv list, stop at first NULL */

static int count_args (argv, max)
char *argv[];
int   max;
{
  int i;
  for (i = 0; i < max; i++) {
    if (argv[i] == NULL) {
      break;
    }
  }
  return i;
}

int Oralogon (interp, connect_str)
  Tcl_Interp *interp;
  char *connect_str;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "oralogon";
  argv[1] = connect_str;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Logon (dummy, interp, argc, argv ) );
}


int Oralogoff (interp, lda_handle)
  Tcl_Interp *interp;
  char *lda_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "oralogoff";
  argv[1] = lda_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Logoff (dummy, interp, argc, argv ) );

}

int Oraopen (interp, lda_handle) 
  Tcl_Interp *interp;
  char *lda_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp);

  argv[0] = "oraopen";
  argv[1] = lda_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Open (dummy, interp, argc, argv ) );

}

int Oraclose (interp, cur_handle) 
  Tcl_Interp *interp;
  char *cur_handle;
{

  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp);

  argv[0] = "oraclose";
  argv[1] = cur_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Close (dummy, interp, argc, argv ) );

}

int Orasql (interp, cur_handle, sql_str, async_parseonly) 
  Tcl_Interp *interp;
  char *cur_handle;
  char *sql_str;
  char *async_parseonly;
{
  char *argv[4];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orasql";
  argv[1] = cur_handle;
  argv[2] = sql_str;
  argv[3] = async_parseonly;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Sql (dummy, interp, argc, argv ) );

}

int Orapoll (interp, cur_handle, all) 
  Tcl_Interp *interp;
  char *cur_handle;
  char *;all;
{
  char *argv[3];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orapoll";
  argv[1] = cur_handle;
  argv[3] = all;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Poll (dummy, interp, argc, argv ) );

}

int Orabreak (interp, cur_handle) 
  Tcl_Interp *interp;
  char *cur_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orapoll";
  argv[1] = cur_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Break (dummy, interp, argc, argv ) );

}

#ifndef lint
int
Orabindexec(va_alist)
#else
int
        /* VARARGS2 */ /* ARGSUSED */
Orabindexec (interp, cur_handle, va_alist) 
  Tcl_Interp *interp;
  char *cur_handle;
#endif
    va_dcl
{
  va_list argList;
  int  argc = 0;
  Tcl_Interp *iPtr;
  char  *cursor;
  char **argv;
  ClientData dummy;
  char  *string;
  int   retcode;
  int   i;


  /* first pass through to count args */
  va_start(argList);
  iPtr   = va_arg(argList, Tcl_Interp *);
  Tcl_ResetResult(iPtr);
  cursor = va_arg(argList, char *);
  argc = 2;
  while (1) {
      string = va_arg(argList, char *);
      if (string == NULL) {
          break;
      }
      argc++;
  }
  va_end(argList);

  /* got size, now alloc array of char pointers */
  argv    = (char **) malloc(argc * sizeof(char *));
  argv[0] = "orabindexec";
  argv[1] = cursor;

  /* second time through to assign pointers */
  va_start(argList);
  (void) va_arg(argList, Tcl_Interp *);
  (void) va_arg(argList, char *);
  for (i = 2; i < argc; i++) {
      string = va_arg(argList, char *);
      if (string == NULL) {
          break;
      }
      argv[i] = string;
  }
  va_end(argList);

  retcode = Oratcl_Bindexec (dummy, iPtr, argc, argv);
  free(argv);
  return (retcode);

}

int Orafetch (interp, cur_handle) 
  Tcl_Interp *interp;
  char *cur_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orafetch";
  argv[1] = cur_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Fetch (dummy, interp, argc, argv ) );

}

int Oracols (interp, cur_handle) 
  Tcl_Interp *interp;
  char *cur_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "oracols";
  argv[1] = cur_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Cols (dummy, interp, argc, argv ) );

}

int Oracancel (interp, cur_handle) 
  Tcl_Interp *interp;
  char *cur_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp);  

  argv[0] = "oracancel";
  argv[1] = cur_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Cancel (dummy, interp, argc, argv ) );

}


#ifndef lint
int
Oraplexec(va_alist)
#else
int
        /* VARARGS2 */ /* ARGSUSED */
Oraplexec (interp, cur_handle, va_alist) 
  Tcl_Interp *interp;
  char *cur_handle;
#endif
    va_dcl
{
  va_list argList;
  int  argc = 0;
  Tcl_Interp *iPtr;
  char  *cursor;
  char **argv;
  ClientData dummy;
  char  *string;
  int   retcode;
  int   i;


  /* first pass through to count args */
  va_start(argList);
  iPtr   = va_arg(argList, Tcl_Interp *);
  Tcl_ResetResult(iPtr);
  cursor = va_arg(argList, char *);
  argc = 2;
  while (1) {
      string = va_arg(argList, char *);
      if (string == NULL) {
          break;
      }
      argc++;
  }
  va_end(argList);

  /* got size, now alloc array of char pointers */
  argv    = (char **) malloc(argc * sizeof(char *));
  argv[0] = "oraplexec";
  argv[1] = cursor;

  /* second time through to assign pointers */
  va_start(argList);
  (void) va_arg(argList, Tcl_Interp *);
  (void) va_arg(argList, char *);
  for (i = 2; i < argc; i++) {
      string = va_arg(argList, char *);
      if (string == NULL) {
          break;
      }
      argv[i] = string;
  }
  va_end(argList);

  retcode = Oratcl_PLexec (dummy, iPtr, argc, argv);
  free(argv);
  return (retcode);

}

int Orawritelong (interp, cur_handle, rowid, table, column, file) 
  Tcl_Interp *interp;
  char *cur_handle;
  char *rowid;
  char *table;
  char *column;
  char *file;
{
  char *argv[6];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orawritelong";
  argv[1] = cur_handle;
  argv[2] = rowid;
  argv[3] = table;
  argv[4] = column;
  argv[5] = file;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Wrlong (dummy, interp, argc, argv ) );

}

int Orareadlong (interp, cur_handle, rowid, table, column, file) 
  Tcl_Interp *interp;
  char *cur_handle;
  char *rowid;
  char *table;
  char *column;
  char *file;
{
  char *argv[6];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orareadlong";
  argv[1] = cur_handle;
  argv[2] = rowid;
  argv[3] = table;
  argv[4] = column;
  argv[5] = file;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Rdlong (dummy, interp, argc, argv ) );

}

int Oracommit (interp, lda_handle) 
  Tcl_Interp *interp;
  char *lda_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orareadtext";
  argv[1] = lda_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Commit (dummy, interp, argc, argv ) );

}

int Oraroll (interp, lda_handle) 
  Tcl_Interp *interp;
  char *lda_handle;
{
  char *argv[2];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "oraroll";
  argv[1] = lda_handle;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Roll (dummy, interp, argc, argv ) );

}

int Oraautocom (interp, lda_handle, state) 
  Tcl_Interp *interp;
  char *lda_handle;
  char *state;
{
  char *argv[3];
  int  argc;
  ClientData dummy;

  Tcl_ResetResult(interp); 

  argv[0] = "orarollback";
  argv[1] = lda_handle;
  argv[2] = state;

  argc = count_args(argv, sizeof(argv) / sizeof (char *));

  return (Oratcl_Autocom (dummy, interp, argc, argv ) );

}




/* oratcl-capi dummied tcl functions */
/* these are referenced in oratcl.c, but will/should never be called */

Tcl_Command  Tcl_CreateCommand (interp, cmdName, proc, 
			clientData, deleteProc)
  Tcl_Interp *interp;
  char *cmdName; 
  Tcl_CmdProc *proc;
  ClientData clientData;
  Tcl_CmdDeleteProc *deleteProc;
{ return (Tcl_Command) NULL; }

char * Tcl_DStringAppend (dsPtr, string, length)
  Tcl_DString *dsPtr;
  char *string; 
  int length; 
{ return (char *) NULL; }

char * Tcl_DStringAppendElement (dsPtr, string)
  Tcl_DString *dsPtr;
  char *string;
{ return (char *) NULL;}

void Tcl_DStringFree (dsPtr)
  Tcl_DString *dsPtr;
{ return; }

void Tcl_DStringInit (dsPtr)
  Tcl_DString *dsPtr;
{ return;}

void Tcl_DStringResult (interp, dsPtr)
  Tcl_Interp *interp;
  Tcl_DString *dsPtr;
{ return; }

int Tcl_Eval (interp, cmd)
  Tcl_Interp *interp; 
  char *cmd;
{ return TCL_OK; }

int Tcl_SplitList (interp, list, argcPtr, argvPtr)
  Tcl_Interp *interp;
  char *list; 
  int *argcPtr;
  char ***argvPtr;
{ return TCL_OK;}


int Tcl_PkgProvide (interp, name, version)
  Tcl_Interp *interp;
  char *name;
  char *version;
{ return TCL_OK;}
 
