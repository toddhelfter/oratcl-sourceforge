#include "oratcl-capi.h"

#include <stdio.h>

main(argc, argv) 
int argc;
char *argv[];
{

  Tcl_Interp 	*interp;
  char 		log_handle[20];
  char 		handle[20];
  int		result;
  int 		i;

  if (argc < 3) {
     printf("usage: %s connect-str sql-string\n",argv[0]);
     exit(0);
  }


  interp = Oratcl_MkInterp();
  Oratcl_Init(interp);

  result = Oralogon(interp, argv[1]);
  printf("oraconnect = %d, result = %s\n", result, RESULT(interp));

  if (result != TCL_OK) exit();
  /* save the logon handle */
  strcpy(log_handle, RESULT(interp));

  result = Oraopen(interp, log_handle);
  if (result != TCL_OK) exit();
  /* save the cursor handle */
  strcpy(handle, RESULT(interp));

  result = Orasql(interp, handle, argv[2]);
  printf("orasql = %d, result = %s\n", result, RESULT(interp));

  while (strcmp(GET_STATUS(interp,Rc),"0")==0) {
    result = Orafetch(interp, handle);
    printf("orafetch = %d, result = %s\n", result, RESULT(interp));
    for (i = 0; i < NUMCOLS(interp); i++) {
      printf("column %d value is: %s\n", i, COLUMN(interp,i));
    }
  }

  result = Oracols(interp, handle);
  printf("oracols = %d, colnames = ", result);
  for (i = 0; i < NUMCOLS(interp); i++) {
    printf("%s ", COLUMN(interp,i));
  }
  printf("\ntypes = %s\n",GET_STATUS(interp,Coltypes));
  printf("lengths = %s\n",GET_STATUS(interp,Collengths));


  result = Oraclose(interp, handle); 
  result = Oralogoff(interp, log_handle); 

  Oratcl_FreeInterp(interp);

}


