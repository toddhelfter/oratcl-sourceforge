/*
 * oratclExt.h
 *
 * Copyright 2000-2004 Todd M. Helfter
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * These CONSTANTS and TYPEDEFS are derived from Oracle include files.
 */

#ifndef _ORATCLEXT_H
#define _ORATCLEXT_H

#include <tcl.h>
#include <limits.h>

#if defined(SYSV_386) || defined(SUN_OS)
# ifdef signed
#  undef signed
# endif 
# define signed
#endif 

/* --- Signed/Unsigned one-byte scalar (sb1/ub1) --- */

typedef unsigned char ub1;
typedef   signed char sb1;
typedef          char eb1;

/* --- Signed/Unsigned two-byte scalar (sb2/ub2) --- */

typedef unsigned short ub2;
typedef   signed short sb2;
typedef          short eb2;

/* --- Signed/Unsigned four-byte scalar (sb4/ub4) --- */

typedef unsigned int ub4;
typedef   signed int sb4;
typedef          int eb4;

/* --- Bits, masks, bit vectors --- */

typedef ub1   bitvec;    
#define BITVEC(n) (((n)+(UB1BITS-1))>>3)

#ifndef uiXT
  typedef  ub1 BITS8;
  typedef  ub2 BITS16;
  typedef  ub4 BITS32;
#endif

/* --- Character pointer --- */

typedef unsigned char oratext;

#if !defined(LUSEMFC)
   typedef oratext text;
   typedef oratext OraText;
#endif

typedef unsigned short utext;

/* --- Backwards compatibility scalars --- */

typedef   signed int sword;

# define dvoid void

typedef void (*lgenfp_t)( void );

/* Oracle Defined Constants Used by Oratcl */

#define OCI_HTYPE_ENV            1                     /* environment handle */
#define OCI_HTYPE_ERROR          2                           /* error handle */
#define OCI_HTYPE_SVCCTX         3                         /* service handle */
#define OCI_HTYPE_STMT           4                       /* statement handle */
#define OCI_HTYPE_BIND           5                            /* bind handle */
#define OCI_HTYPE_DEFINE         6                          /* define handle */
#define OCI_HTYPE_DESCRIBE       7                        /* describe handle */
#define OCI_HTYPE_SERVER         8                          /* server handle */
#define OCI_HTYPE_SESSION        9                  /* authentication handle */

#define OCI_DTYPE_PARAM 53  /* a parameter descriptor */

#define OCI_OTYPE_NAME 1	/* object name */
#define OCI_OTYPE_REF  2	/* REF to TDO */
#define OCI_OTYPE_PTR  3	/* PTR to TDO */

#define OCI_ATTR_NONBLOCKING_MODE	3	/* non blocking mode */
#define OCI_ATTR_SERVER			6	/* the server handle */
#define OCI_ATTR_SESSION		7	/* the user session handle */
#define OCI_ATTR_ROW_COUNT		9	/* the rows processed so far */
#define OCI_ATTR_SQLFNCODE		10	/* the SQL verb of the statement */
#define OCI_ATTR_PARAM_COUNT		18	/* number of column in the select list */
#define OCI_ATTR_USERNAME		22	/* username attribute */
#define OCI_ATTR_PASSWORD		23	/* password attribute */
#define OCI_ATTR_STMT_TYPE		24	/* statement type */

#define OCI_ATTR_NUM_COLS		102	/* number of columns */
#define OCI_ATTR_LIST_COLUMNS		103	/* parameter of the column list */
#define OCI_ATTR_LINK			111	/* the database link name */
#define OCI_ATTR_PARAM			124	/* parameter descriptor */

#define OCI_ATTR_SERVER_STATUS		143	/* state of the server handle */

#define OCI_SERVER_NOT_CONNECTED        0x0 
#define OCI_SERVER_NORMAL               0x1 

/* Credential Types */
#define OCI_CRED_RDBMS      1                  /* database username/password */
#define OCI_CRED_EXT        2             /* externally provided credentials */
#define OCI_CRED_PROXY      3                        /* proxy authentication */
#define OCI_CRED_RESERVED_1 4                                    /* reserved */

/* Error Return Values */
#define OCI_SUCCESS 0                      /* maps to SQL_SUCCESS of SAG CLI */
#define OCI_SUCCESS_WITH_INFO 1             /* maps to SQL_SUCCESS_WITH_INFO */
#define OCI_RESERVED_FOR_INT_USE 200                            /* reserved */ 
#define OCI_NO_DATA 100                               /* maps to SQL_NO_DATA */
#define OCI_ERROR -1                                    /* maps to SQL_ERROR */
#define OCI_INVALID_HANDLE -2                  /* maps to SQL_INVALID_HANDLE */
#define OCI_NEED_DATA 99                            /* maps to SQL_NEED_DATA */
#define OCI_STILL_EXECUTING -3123                   /* OCI would block error */
#define OCI_CONTINUE -24200    /* Continue with the body of the OCI function */

#define OCI_NTV_SYNTAX 1    

#define OCI_FETCH_CURRENT	0x01               /* refetching current position  */
#define OCI_FETCH_NEXT		0x02                                      /* next row */
#define OCI_FETCH_FIRST		0x04                  /* first row of the result set */
#define OCI_FETCH_LAST		0x08                /* the last row of the result set */
#define OCI_FETCH_PRIOR		0x10         /* the previous row relative to current */
#define OCI_FETCH_ABSOLUTE	0x20                /* absolute offset from first */
#define OCI_FETCH_RELATIVE	0x40                /* offset relative to current */
#define OCI_FETCH_RESERVED_1	0x80                                /* reserved */

#define OCI_DATA_AT_EXEC	0x02	/* data at execute time */
#define OCI_DYNAMIC_FETCH	0x02	/* fetch dynamically */

#define OCI_DEFAULT         0x00000000 

#define OCI_THREADED        0x00000001      /* appl. in threaded environment */
#define OCI_OBJECT          0x00000002  /* application in object environment */
#define OCI_EVENTS          0x00000004  /* application is enabled for events */
#define OCI_CACHE           0x00000200                  /* turn on  DB Cache */
#define OCI_ALWAYS_BLOCKING 0x00000400    /* all connections always blocking */
#define OCI_NO_CACHE        0x00000800             /* turn off DB Cache mode */

#define OCI_DESCRIBE_ONLY     0x10            /* only describe the statement */
#define OCI_COMMIT_ON_SUCCESS 0x20        /* commit, if successful execution */

#define OCI_SYSDBA          0x0002               /* for SYSDBA authorization */
#define OCI_SYSOPER         0x0004              /* for SYSOPER authorization */

#define OCI_ATTR_DATA_SIZE      1	/* maximum size of the data */
#define OCI_ATTR_DATA_TYPE      2	/* the SQL type of the column/argument */
#define OCI_ATTR_DISP_SIZE      3	/* the display size */
#define OCI_ATTR_NAME		4	/* the name of the column/argument */
#define OCI_ATTR_PRECISION      5	/* precision if number type */
#define OCI_ATTR_SCALE          6	/* scale if number type */
#define OCI_ATTR_IS_NULL        7	/* is it null ? */
#define OCI_ATTR_TYPE_NAME      8	/* name of the named data type */
#define OCI_ATTR_SCHEMA_NAME	9	/* the schema name */

#define OCI_ATTR_DESC_PUBLIC	250	/* public object */

typedef struct OCIEnv           OCIEnv;			/* OCI environment handle */
typedef struct OCIError         OCIError;		/* OCI error handle */
typedef struct OCISvcCtx        OCISvcCtx;		/* OCI service handle */
typedef struct OCIStmt          OCIStmt;		/* OCI statement handle */
typedef struct OCIBind          OCIBind;		/* OCI bind handle */
typedef struct OCIDefine        OCIDefine;		/* OCI Define handle */
typedef struct OCIDescribe      OCIDescribe;		/* OCI Describe handle */
typedef struct OCIServer        OCIServer;		/* OCI Server handle */
typedef struct OCISession       OCISession;		/* OCI Authentication handle */
typedef struct OCIComplexObject OCIComplexObject;	/* OCI COR handle */
typedef struct OCITrans         OCITrans;		/* OCI Transaction handle */
typedef struct OCISecurity      OCISecurity;		/* OCI Security handle */
typedef struct OCISubscription  OCISubscription;	/* subscription handle */

typedef struct OCISnapshot      OCISnapshot;		/* OCI snapshot descriptor */
typedef struct OCILobLocator    OCILobLocator;		/* OCI Lob Locator descriptor */
typedef struct OCIParam         OCIParam;		/* OCI PARameter descriptor */
typedef struct OCIResult        OCIResult;		/* OCI Result Set Descriptor */

/* OCI Statement Types */
#define  OCI_STMT_SELECT	1	/* select statement */
#define  OCI_STMT_UPDATE	2	/* update statement */
#define  OCI_STMT_DELETE 	3	/* delete statement */
#define  OCI_STMT_INSERT	4	/* Insert Statement */
#define  OCI_STMT_CREATE	5	/* create statement */
#define  OCI_STMT_DROP		6	/* drop statement */
#define  OCI_STMT_ALTER		7	/* alter statement */
#define  OCI_STMT_BEGIN		8	/* begin ... (pl/sql statement)*/
#define  OCI_STMT_DECLARE	9	/* declare .. (pl/sql statement ) */

/* OCI Parameter Types Constants */ 
#define OCI_PTYPE_TABLE         1                               /* table     */
#define OCI_PTYPE_VIEW          2                               /* view      */
#define OCI_PTYPE_SYN           7                               /* synonym   */

/* OCI_*_PIECE defines the piece types that are returned or set */
#define OCI_ONE_PIECE		0	/* there or this is the only piece */
#define OCI_FIRST_PIECE		1	/* the first of many pieces */
#define OCI_NEXT_PIECE		2	/* the next of many pieces */
#define OCI_LAST_PIECE		3	/* the last piece of this column */

/* Oracle data types */
#define SQLT_CHR		1	/* (ORANET TYPE) character string */
#define SQLT_NUM		2	/* (ORANET TYPE) oracle numeric */
#define SQLT_STR		5	/* zero terminated string */
#define SQLT_LNG		8	/* long */
#define SQLT_RID		11	/* rowid */
#define SQLT_DAT		12	/* date in oracle format */
#define SQLT_VBI		15	/* binary in VCS format */
#define SQLT_BIN		23	/* binary data(DTYBIN) */
#define SQLT_LBI		24	/* long binary */
#define SQLT_AFC		96	/* Ansi fixed char */
#define SQLT_CUR		102	/* cursor  type */
#define SQLT_RDD		104	/* rowid descriptor */
#define SQLT_NTY		108	/* named object type */
#define SQLT_CLOB		112	/* character lob */
#define SQLT_BLOB		113	/* binary lob */
#define SQLT_RSET		116	/* result set type */
#define SQLT_DATE		184	/* ANSI Date */
#define SQLT_TIME		185	/* TIME */
#define SQLT_TIME_TZ		186	/* TIME WITH TIME ZONE */
#define SQLT_TIMESTAMP		187	/* TIMESTAMP */
#define SQLT_TIMESTAMP_TZ	188	/* TIMESTAMP WITH TIME ZONE */
#define SQLT_INTERVAL_YM	189	/* INTERVAL YEAR TO MONTH */
#define SQLT_INTERVAL_DS	190	/* INTERVAL DAY TO SECOND */
#define SQLT_TIMESTAMP_LTZ	232	/* TIMESTAMP WITH LOCAL TZ */

#endif
