/*
 * oratcl.c --
 *
 * Oracle interface to Tcl
 *
 * Copyright 1993 Tom Poindexter and U S WEST Advanced Technologies, Inc.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies.  
 * Tom Poindexter and U S WEST make no representations about the suitability 
 * of this software for any purpose.  It is provided "as is" without express or
 * implied warranty.  By use of this software the user agrees to 
 * indemnify and hold harmless Tom Poindexter and U S WEST from any 
 * claims or liability for loss arising out of such use.
 *
 *-----------------------------------------------------------------------------
 * Version 1.0 July, 1993
 * Tom Poindexter, Boulder Colorado
 * tpoind@advtech.uswest.com  or tpoindex@nyx.cs.du.edu   
 *-----------------------------------------------------------------------------
 * Version 2.0 November, 1993
 * Tom Poindexter, Boulder Colorado
 * tpoind@advtech.uswest.com  or tpoindex@nyx.cs.du.edu   
 * -make changes to support Tcl 7.0 internal calls, init call changed
 * -remove dependence on TclX by #include tcl.h, tclUnix.h 
 * -change malloc/free to challoc/ckfree in case TCL_MEM_DEBUG
 *-----------------------------------------------------------------------------
 * Version 2.1 February, 1994
 * Tom Poindexter, Boulder Colorado
 * tpoind@advtech.uswest.com  or tpoindex@nyx.cs.du.edu   
 * -change Oratcl_Init to int and return ok
 * -add "colprec" and "colscales" to oracols (thanks-Dan R. Schenck)
 * -add optional repeat commands to orafetch command
 * -don't call get_lda_err from failed OraLogon, may not have good lda
 * -change way cur handles are made, don't use argv[1] anymore
 *-----------------------------------------------------------------------------
 * Version 2.11 April, 1994
 * Tom Poindexter, Boulder Colorado
 * tpoind@advtech.uswest.com  or tpoindex@nyx.cs.du.edu   
 * -don't call parse_columns after orsql DDL or DCL, caused error in V7 
 *-----------------------------------------------------------------------------
 * Version 2.2 October, 1994
 * Tom Poindexter, Boulder Colorado
 * tpoindex@nyx.cs.du.edu   
 * -allow numeric columns to have an actual null output (""),
 * -clean up remaining externs to Oratcl_
 * -change orlon() function def for backward compat -- caused connect problems
 *  for some (thanks Dan Janowski)
 *-----------------------------------------------------------------------------
 * Version 2.3 August, 1995
 * Tom Poindexter, Denver Colorado
 * tpoindex@nyx.cs.du.edu   
 * -change hda def for 64 bits machines (dec alpha)
 * -change declare of Oratcl_FetchAll from 'static int' to just 'int'
 * -support of tcl7.4, remove need for tclUnix.h
 * -always set oramsg(rows) to cda->rpc after oexec() 
 * -fix intermittent bug in FetchAll that sometimes tries to reference
 *  beyond the number of columns (thanks Todd Rimmer)
 *-----------------------------------------------------------------------------
 * Version 2.4 September, 1996
 * Tom Poindexter, Denver Colorado
 * tpoindex@nyx.net  new address
 * -include call to Tcl_PkgProvide for tcl7.5+ package scheme
 * -fix orafetchall to quote two occurances of substitution char, and to
 *  accept a user defined substitution char
 * -add oramsg(ociinfo) for information on how oratcl was compiled
 * -add OratclInitFlag to prevent reinitializing 
 *-----------------------------------------------------------------------------
 * Version 2.41 December, 1996
 * Tom Poindexter, Denver Colorado
 * tpoindex@nyx.net 
 * -zero out lda and hda before logon
 *-----------------------------------------------------------------------------
 * Version 2.5 November, 1997
 * Tom Poindexter, Denver Colorado
 * tpoindex@nyx.net  
 * -windows support 
 * -add support for cursor variables returned by oraplexec
 * -add 'parseonly' option to orasql; add orabindexec command; based on code
 *  from Todd M. Helfter <tmh@cc.purdue.edu>
 * -add async support on orasql & orabindexec; new orapoll and orabreak 
 *  commands
 * -change Wrlong to allow writing of zero length file
 * -add version number to oramsg array
 * -change Oratcl_FetchAll to bind tcl variables to output columns per fetch
 * -keywords (async,parseonly,etc.) now also recognized as options (-async)
 * -fail orasql if rc anything but 0,1403,1405,1406
 * -call Oratcl_Kill at exit, not on each command deletion
 * -add peo (parse error offset) to oramsg-thanks to George A. Kiewicz
 * -better checking of dml during orasql-thanks to George A. Kiewicz
 * -fix bug in FetchAll where argv[] command string is manipulated, caused
 *  problems with Tcl 8.0
 * -add 'rowid' oramsg element, thanks to Dennis I. Urasov
 *-----------------------------------------------------------------------------
 * Version 2.6 September, 1999
 * Mariam Tariq, Scriptics Corporation
 * mtariq@scriptics.com
 * -Note: Oracle 7 OCI API is still used. Oracle 8 libraries still support
 *  the Oracle 7 calls. However, new Oracle 8 features such as functions
 *  to manipulate LOB's are not accessible by Oratcl. Oratcl needs to be
 *  rewritten with the new Oracle 8 API's to take advantage of the new
 *  features.
 * -add support for Internationalization features of Tcl8.1
 * -add stub awareness
 * -OCI 7 call called ologon does not work with some versions of Oracle 8i(e.g.
 *  version 8.1.5 on NT). So Oracle 8 OCILogon is used for logging in. The
 *  service context handle is then converted to an lda such that the Oracle
 *  7 calls can be used again.
 *-----------------------------------------------------------------------------
 */


#define ORATCL_VERSION "2.6"

/* support for version 6 or version 7; if not 7 assume 6  */
#ifndef VERSION7
#ifndef VERSION6
#define VERSION6
#endif
#endif

#include "tcl.h"
#include "Oratypes.h"

/* simple memory debugging, to make sure we alloc and free the same amount */ 
#ifdef ORATCL_MEM_DEBUG
#include <stdio.h>
#undef ckalloc
#undef ckfree
static long my_alloc = 0; /* alloc'ed in this module, free'ed in this module */
static long my_tcl_alloc= 0;    /* alloc'ed by tcl, free'ed in this module */
static long my_free  = 0;       /* free'ed in this module */
FILE *my_file;          /* file to dump stats */
#ifdef ORATCL_MEM_FULL_DEBUG
#define WHERE_ALLOC fprintf(my_file,"ckalloc  %d\n",__LINE__),
#define WHERE_FREE   fprintf(my_file,"ckfree   %d\n",__LINE__),
#else
#define WHERE_ALLOC
#define WHERE_FREE
#endif
#define ckalloc(x) (WHERE_ALLOC my_alloc++, Tcl_Alloc(x))
#define ckfree(x)  (WHERE_FREE   my_free++,  Tcl_Free(x))
/* the only place we get Tcl alloc'ed is from Tcl_SplitList, use wrapper */
static int MyTcl_SplitList(interp,list,argc,argv)
  Tcl_Interp *interp;
  char *list;
  int *argc;
  char ***argv;
{
#ifdef ORATCL_MEM_FULL_DEBUG
  fprintf(my_file,"tclalloc %d\n",__LINE__);
#endif
  my_tcl_alloc++;
  return Tcl_SplitList(interp,list,argc,argv);
}
#define Tcl_SplitList MyTcl_SplitList
#define MY_STATS_INIT my_file=fopen("alloc.stats","w")
#define MY_STATS_DUMP fprintf(my_file,\
  "ckalloc   = %8ld\ntcl alloc = %8ld\nall alloc = %8ld\nckfree    = %8ld\n",\
  my_alloc,my_tcl_alloc,my_alloc+my_tcl_alloc,my_free);fclose(my_file)
#else
static long my_alloc = 0;
#define MY_STATS_INIT my_alloc=0
#define MY_STATS_DUMP my_alloc=my_alloc
#endif


#include <fcntl.h>
#include <sys/stat.h>

#ifdef NO_STRING_H
#include <strings.h>
#else
#include <string.h>
#endif

#include <ctype.h>

#ifdef __WIN32__
#include <memory.h>
#include <stdlib.h>
#include <io.h>
#endif


#ifdef NO_BCOPY
#define bcopy(from, to, length)    memmove((to), (from), (length))
#define bzero(buf, length)	   memset((buf),(0),(length))
#endif

/* define oracle cursor (and logon) structures */

/* 64 bit architectures need larger hda size and different cda struct */

#if (defined(__osf__) && defined(__alpha)) || defined(CRAY) || defined(KSR)
#define HDA_SIZE 512
#else
#define HDA_SIZE 256
#define CDA_32_DEF 
#endif



#ifdef CDA_32_DEF

/* cda def that should support 16 and 32 bit architectures */
struct cda_def
{
   short          v2_rc;        /* v2 return code */
   unsigned short ft;    	/* function type */
   unsigned long  rpc;          /* rows processed count */
   unsigned short peo;          /* parse error offset */
   unsigned char  fc;           /* function code */
   unsigned char  fill1;        /* filler  */
   unsigned short rc;           /* v7 return code */
   unsigned char  wrn;          /* warning flags */
   unsigned char  flg;          /* error flags */
   unsigned int   d0;           /* cursor number */
   struct {                     /* rowid structure */
     struct {
        unsigned long   d1;
        unsigned short  d2;
        unsigned char   d3;
        } rd;
     unsigned long  d4;         /* rba of datablock */
     unsigned short d5;         /* sequence number of row in block */
     } rid;
   unsigned int   ose;          /* os dependent error code */
   unsigned char  sysparm[27];  /* private, reserved fill */
};

#else

/* cda def that should support 64 bit architectures */
struct cda_def
{
   signed   short v2_rc;        /* v2 return code */
   unsigned short ft;    	/* function type */
   signed   int   rpc;          /* rows processed count */
   unsigned short peo;          /* parse error offset */
   unsigned char  fc;           /* function code */
   unsigned char  fill1;        /* filler  */
   unsigned short rc;           /* v7 return code */
   unsigned char  wrn;          /* warning flags */
   unsigned char  flg;          /* error flags */
   signed   int   d0;           /* cursor number */
   struct {                     /* rowid structure */
     struct {
        signed   int    d1;
        unsigned short  d2;
        unsigned char   d3;
        } rd;
     signed   int   d4;         /* rba of datablock */
     unsigned short d5;         /* sequence number of row in block */
     } rid;
   signed   int   ose;          /* os dependent error code */
   unsigned char  sysparm[27];  /* private, reserved fill */
};
#endif

typedef struct cda_def cda_def;
/* this fails with some compilers: typedef struct cda_def lda_def; */
#define lda_def cda_def 


/* _ANSI_ARGS_ should be defined by tcl.h; ignore if not defined */
#ifndef _ANSI_ARGS_
#define _ANSI_ARGS_() ()
#endif 

/* prototypes for oci function  */

#ifdef VERSION7

/* version 7 has a few extra functions */

int odescr _ANSI_ARGS_((struct cda_def *, int, unsigned long *, short *, char *,
         unsigned long *, unsigned long *, short *, short *, short *));

int oflng _ANSI_ARGS_((struct cda_def *, int, char *, long, int, 
	 unsigned long *, long));

int oparse _ANSI_ARGS_((struct cda_def *, char *, long, int, unsigned long));

#else

/* fake version 7 odescr and oparse */

#define odescr(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10) \
	  odsc(p1,p2,p3,NULL,NULL,p4,p5,p6,p7)

#define oparse(p1,p2,p3,p4,p5)  osql3(p1,p2,(int) p3)

#endif


int obndrv _ANSI_ARGS_((struct cda_def *, char *, int, char *, int, int,
         int, short *, char *, int, int));

int obndrn _ANSI_ARGS_((struct cda_def *, int, char *, int, int,
         int, short *, char *, int, int));

int obreak _ANSI_ARGS_((struct lda_def *));

int ocan _ANSI_ARGS_((struct cda_def *));

int oclose _ANSI_ARGS_((struct cda_def *));

int ocof _ANSI_ARGS_((struct lda_def *));

int ocom _ANSI_ARGS_((struct lda_def *));

int ocon _ANSI_ARGS_((struct lda_def *));

int odefin _ANSI_ARGS_((struct cda_def *, int, char *, int, int, int, 
	 short *, char *, int, int, unsigned short *, unsigned short *));

int odsc _ANSI_ARGS_((struct cda_def *, int, short *, unsigned short *, short *,
         short *, char *, short *, short *));

int oerhms _ANSI_ARGS_((struct lda_def *, short, char *, int));

int oermsg _ANSI_ARGS_((short, char *));

int oexec _ANSI_ARGS_((struct cda_def *));

int oexn _ANSI_ARGS_((struct cda_def *, int, int));

int ofen _ANSI_ARGS_((struct cda_def *, int));

int ofetch _ANSI_ARGS_((struct cda_def *));

int ologof _ANSI_ARGS_((struct lda_def *));

int olon _ANSI_ARGS_((struct lda_def *, char *, int, char *, int, int));

int oopen _ANSI_ARGS_((struct cda_def *, struct lda_def *, char *, int,
         int, char *, int));

int oopt _ANSI_ARGS_((struct cda_def *, int, int));

int orlon _ANSI_ARGS_((struct lda_def *, char *, char *, int, char *, int,int));

int orol _ANSI_ARGS_((struct lda_def *));

int osql3 _ANSI_ARGS_((struct cda_def *, char *, int));


#ifdef NONBLOCK_CURSOR

int obreak _ANSI_ARGS_((struct lda_def *));

int onbset _ANSI_ARGS_((struct lda_def *));

int onbclr _ANSI_ARGS_((struct lda_def *));

int onbtst _ANSI_ARGS_((struct lda_def *));

#endif


/* various limits for arrays of structures, default buffer sizes */
#define ORATCLLDAS      50	/* default number of ldas available */
#define ORATCLCURS      100	/* default number of curs available */
#define ORA_HOST_AREA	HDA_SIZE /* Oracle host data area length */
#define ORA_BUFF_SIZE	4096	/* conversion buffer size for various needs*/
#define ORA_MSG_SIZE	1000	/* oracle error message max size*/
#define ORA_BIND_SIZE   255     /* conversion buffer size for binding */
#define ORA_CACHE       10      /* number of rows to fetch each time */

/* parse_cols defines */
#define NO_MORE_COLUMNS 1007	/* oracle error code # during odescr */
#define EXT_STRING_TYPE 5	/* oracle external data type for string */
#define INT_CURSOR_TYPE 102     /* oracle internal cursor data type */

/* version 7 db / oci 2.0 oparse() has some options */
/* DEF_FLAG should be IMMED_PARSE, otherwise oparse will lie about ft */
#define IMMED_PARSE     0 
#define DEFER_PARSE     1
#define DEF_FLAG        IMMED_PARSE	

/* orasql async/ orapoll will block code */
#define BLOCKED         3123

#define VER6_BEHAVIOR   0
#define NORM_BEHAVIOR   1
#define VER7_BEHAVIOR   2
#define LNG_FLAG        NORM_BEHAVIOR	/* normal treatment of data types */

/* append_cols defines */
#define OUT_OF_SEQUENCE 1002	/* oracle error # fetch out of sequence */
#define NO_STMT_PARSED  1003    /* oracle error # no statement parsed */
#define NO_DATA_FOUND   1403	/* oracle error # no data for this fetch */
#define NULL_VALUE      1405	/* oracle error # column returned null */
#define COL_TRUNCATED   1406	/* oracle error # column truncated */
#define NUMBER_TYPE     2 	/* oracle internal data type for number */
#define LONG_TYPE       8 	/* oracle internal data type for long   */
#define LONGRAW_TYPE    24	/* oracle internal data type for long raw */

/* pl exec error */
#define PL_EXEC_ERR     6503	/* oracle error # pl block error */

/* db long column max size */
#ifdef VERSION6
#define MAX_LONG_SIZE   65536 		/* v6 */
#else
#define MAX_LONG_SIZE   2147483647 	/* v7 */
#endif

#define LONG_BUFF_SIZE  32768   /* chunks to get via oflng() */




/* ColBufs holds information and data of SELECT columns */

struct ColBufs {
    struct ColBufs  *next_buf;	/* pointer to next ColBufs in list */
    short       dbtype;		/* column type */
    char        dbname[256];	/* column name */
#ifdef VERSION7
    unsigned long 
#else
    unsigned short   
#endif
                dbname_len,	/* column name length */
                disp_size,	/* column display size */
                dbsize;		/* column internal size */

    short       prec;		/* precision of numeric */
    short       scale;   	/* scale of numeric */
    short       nullok;         /* if null ok */
    long        col_len;        /* length of column data */
    char       *col_data;       /* pointer to acutal column data */
    int         bind_cursor;	/* if cursor variable bound during oraplexec*/
    unsigned short rlen[ORA_CACHE];       /* actual column length */
    unsigned short rcode[ORA_CACHE];      /* actual column code */
};

typedef struct ColBufs ColBufs;


/* OraTclLdas - oracle logon struct et.al. */

typedef struct OraTclLdas {	/* struct for lda entries */
    int         lda_in_use;	/* if this entry is opened */
    lda_def    *lda;		/* Oracle Logon Data Area */
    char       *hda;            /* Oracle Host Data Area */
    int		async;		/* if lda is in non-block mode */
} OraTclLdas;


/* OraTclCurs - oracle cursor + ColBufs head list ptr */

typedef struct OraTclCurs {	/* struct for cursor entries */
    int         cur_in_use;	/* if this entry is opened */
    int         lda_num;	/* entry in lda table for this cursor */
    cda_def    *cda;		/* Oracle Cursor Area */
    ColBufs    *col_list;       /* list of select columns */
    ColBufs    *bind_list;      /* list of bind variables/values */
    int         cache_size;     /* cache size of this cursor */
    int         row_num;        /* current row in cache to fetch */
    int         fetch_end;      /* true when fetches exhausted */
    long        fetch_cnt;      /* total number of rows fetched so far */
    int         oexec_done;     /* if oexec finished for async cursor */
    int         first_fetch;    /* if fetch has been performed by orapoll */
    int         async;          /* if cursor executed in async mode */
} OraTclCurs;

/* static tables for lda & cda */
static OraTclLdas   OraLdas[ORATCLLDAS];  
static OraTclCurs   OraCurs[ORATCLCURS];  

/* quick fetch flag */
static int  fetch_ok;

static char *OraHandlePrefix = "oratcl";  /* prefix used to identify handles*/
/* lda handles are:  prefix , lda index          e.g.  oratcl0    */
/* cur handles are:  lda handle , '.', cur index e.g.  oratcl0.0  */
/* a cursor handle could be passed to a proc that needs an lda handle */

static char *OraMsgArray = "oramsg";  /* array to place errors & messages */
static char *EnvArray = "env"; /* global Tcl array for environment vars */

/* rip off from example.c: defines plus .dll entry point function */
 
#ifdef __WIN32__
#if defined(__WIN32__)
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#   undef WIN32_LEAN_AND_MEAN
#endif
 
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
 
EXTERN int	Oratcl_Init _ANSI_ARGS_((Tcl_Interp *interp));

#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLIMPORT

#define strncasecmp strnicmp
 
#else
 
 
/* Windows binary flag for sybreadtext/sybwritetext,unix doesn't need anything*/
 
#define _O_BINARY    0
 
/* prototype for malloc */
extern void * malloc();
 
#endif


/* prototypes for all TCL visible functions */

extern Tcl_CmdProc  Oratcl_Logon;
extern Tcl_CmdProc  Oratcl_Logoff;
extern Tcl_CmdProc  Oratcl_Open;
extern Tcl_CmdProc  Oratcl_Close;
extern Tcl_CmdProc  Oratcl_Sql;
extern Tcl_CmdProc  Oratcl_Bindexec;
extern Tcl_CmdProc  Oratcl_Fetch;
extern Tcl_CmdProc  Oratcl_Cols;
extern Tcl_CmdProc  Oratcl_Cancel;
extern Tcl_CmdProc  Oratcl_PLexec;
extern Tcl_CmdProc  Oratcl_Commit;
extern Tcl_CmdProc  Oratcl_Roll;
extern Tcl_CmdProc  Oratcl_Autocom;
extern Tcl_CmdProc  Oratcl_Wrlong;
extern Tcl_CmdProc  Oratcl_Rdlong;

#ifdef NONBLOCK_CURSOR
extern Tcl_CmdProc  Oratcl_Poll;
extern Tcl_CmdProc  Oratcl_Break;
#endif

/*----------------------------------------------------------------------
*  Oracle 8 OCI API declarations
*/
typedef struct OCIEnv           OCIEnv;            /* OCI environment handle */
typedef struct OCIError         OCIError;                /* OCI error handle */
typedef struct OCISvcCtx        OCISvcCtx;             /* OCI service handle */

#define OCIEnv                     ocienvh
#define OCIError                   ocierrh
#define OCISvcCtx                  ocisvch

typedef struct ocienvh ocienvh;                    /* OCI environment handle */
typedef struct ocierrh ocierrh;                          /* OCI error handle */
typedef struct ocisvch ocisvch;                        /* OCI service handle */

#define ocienvh                         OCIEnv             
#define ocierrh                         OCIError 
#define ocisvch                         OCISvcCtx
            
#define OCI_DEFAULT  0x00 /* the default value for parameters and attributes */

static OCIEnv     *p_env;
static OCIError   *p_err;
static OCISvcCtx  *p_svc; 


#define OCI_HTYPE_ERROR 2                                    /* error handle */
#define OCI_HTYPE_SVCCTX 3                                 /* service handle */


/* 
 *----------------------------------------------------------------------
 * get_ora_lda_handle
 *    authenticate an lda handle string 
 *  return: OraLdas index number or -1 on error;
 */

static int
get_ora_lda_handle (handle) 
    char *handle;
{
    int prefix_len = strlen(OraHandlePrefix);
    int lda_h;

    if ( (strlen(handle) > prefix_len) &&
	 (strncmp(handle,OraHandlePrefix,prefix_len) == 0)  &&
	 (isdigit(*(handle + prefix_len))) 
       ) {

	 lda_h = atoi((handle + prefix_len));
	 if (lda_h < 0 || lda_h >= ORATCLLDAS) {
	   return (-1);
	 }
	 if (OraLdas[lda_h].lda_in_use) {
	   return (lda_h);
	 } else {
	   return (-1);
	 }
    } 

    return (-1);
}


/* 
 *----------------------------------------------------------------------
 * get_ora_handle
 *    authenticate a cursor handle string 
 *  return: OraCurs index number or -1 on error;
 */

static int
get_ora_handle (handle) 
    char *handle;
{
    int prefix_len = strlen(OraHandlePrefix);
    int lda_h      = get_ora_lda_handle(handle);
    int cur_h;
    char *p;

    if (lda_h == -1) {
	return (-1);
    }

    if ( ((p = strchr(handle,'.')) != NULL) && (isdigit(*(p+1))) ) {

	 cur_h = atoi((p + 1));
	 if (cur_h < 0 || cur_h >= ORATCLCURS) {
	   return (-1);
	 }
	 if (OraCurs[cur_h].cur_in_use) {
	   return (cur_h);
	 } else {
	   return (-1);
	 }
    } 

    return (-1);
}



/*
 *----------------------------------------------------------------------
 * get_lda_err
 *   get the oracle return code and error message for an lda error
 */

static void
get_lda_err (interp, hand)
    Tcl_Interp *interp;
    int         hand;
{

    char buf[ORA_MSG_SIZE];

    sprintf(buf,"%d",OraLdas[hand].lda->rc);
    Tcl_SetVar2(interp,OraMsgArray,"rc",buf,TCL_GLOBAL_ONLY);

    if (OraLdas[hand].lda->rc == 0) {
	buf[0] = '\0';
    } else {
        oerhms (OraLdas[hand].lda, OraLdas[hand].lda->rc, 
                  buf, ORA_MSG_SIZE);
    }
    Tcl_SetVar2(interp,OraMsgArray,"errortxt",buf,TCL_GLOBAL_ONLY);
}



/*
 *----------------------------------------------------------------------
 * get_ora_err
 *   get the oracle return code and error message
 */

static void
get_ora_err (interp, hand)
    Tcl_Interp *interp;
    int         hand;
{

    char buf[ORA_MSG_SIZE];


    sprintf(buf,"%d",OraCurs[hand].cda->rc);
    Tcl_SetVar2(interp,OraMsgArray,"rc",buf,TCL_GLOBAL_ONLY);

    sprintf(buf,"%d",OraCurs[hand].cda->ft);
    Tcl_SetVar2(interp,OraMsgArray,"sqlfunc",buf,TCL_GLOBAL_ONLY);

    sprintf(buf,"%d",OraCurs[hand].cda->fc);
    Tcl_SetVar2(interp,OraMsgArray,"ocifunc",buf,TCL_GLOBAL_ONLY);

    sprintf(buf,"%d",OraCurs[hand].cda->peo);
    Tcl_SetVar2(interp,OraMsgArray,"peo",buf,TCL_GLOBAL_ONLY);

    if (OraCurs[hand].cda->rc == 0) {
	buf[0] = '\0';
    } else {
        oerhms (OraLdas[OraCurs[hand].lda_num].lda, OraCurs[hand].cda->rc, 
	        buf, (int) ORA_MSG_SIZE);
    }

    Tcl_SetVar2(interp,OraMsgArray,"errortxt",buf,TCL_GLOBAL_ONLY);
	    
}




/*
 *----------------------------------------------------------------------
 * clear_msg --
 *
 * clears all error and message elements in the global array variable
 *
 */

static void
clear_msg(interp)
    Tcl_Interp *interp;
{
    /* index "rc" - return code from last oratcl call */
    Tcl_SetVar2(interp, OraMsgArray, "rc",       "", TCL_GLOBAL_ONLY);

    /* index "sqlfunc" - sql function code of last sql */
    Tcl_SetVar2(interp, OraMsgArray, "sqlfunc",  "", TCL_GLOBAL_ONLY);

    /* index "ocifunc" - oci function code of last call */
    Tcl_SetVar2(interp, OraMsgArray, "ocifunc",  "", TCL_GLOBAL_ONLY);

    /* index "errortxt" - text from last rc */
    Tcl_SetVar2(interp, OraMsgArray, "errortxt", "", TCL_GLOBAL_ONLY);

    /* index "peo" - parse error offset from last oratcl call */
    Tcl_SetVar2(interp, OraMsgArray, "peo",      "", TCL_GLOBAL_ONLY);

    /* index "rows" - rows processed count from oexec */
    Tcl_SetVar2(interp, OraMsgArray, "rows",     "", TCL_GLOBAL_ONLY);

    /* index "rowid" - rowid of last row maniuplated */
    Tcl_SetVar2(interp, OraMsgArray, "rowid",    "", TCL_GLOBAL_ONLY);

    /* index "collengths" & "coltypes" only meaningful after oracols command */
    /* same for "colprecs" and "colscales"                                   */
    Tcl_SetVar2(interp, OraMsgArray, "collengths","", TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, OraMsgArray, "coltypes",  "", TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, OraMsgArray, "colprecs",  "", TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, OraMsgArray, "colscales", "", TCL_GLOBAL_ONLY);


}



/*
 *----------------------------------------------------------------------
 * ora_prologue
 *
 * does most of standard command prologue, assumes handle is argv[1]
 * returns: cursor handle index  or -1 on failure
 * 
 */

static int
ora_prologue (interp, argc, argv, num_args, err_msg)
    Tcl_Interp *interp;
    int         argc;
    char      **argv;
    int         num_args;
    char       *err_msg;
{
    int         hand;

    clear_msg(interp);

    /* check number of minimum args*/

    if (argc < num_args) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  err_msg, (char *) NULL);
	return (-1);
    }

    /* parse the handle */
    hand = get_ora_handle(argv[1]);

    if (hand == -1) {
	Tcl_AppendResult (interp, argv[0], ": handle ", argv[1],
			 " not open ", (char *) NULL);
	return (-1);
    }

    /* clear oramsg array for new messages & errors */
    Tcl_SetVar2(interp, OraMsgArray, "handle",  argv[1], TCL_GLOBAL_ONLY);

    return (hand);
}



/*
 *----------------------------------------------------------------------
 * free_cols
 *   free all ColBufs in a list
 *
 */

static int
free_cols (col_list_ptr)
    ColBufs  *col_list_ptr;
{
    ColBufs  *next;

    while (col_list_ptr != NULL) {
        next = col_list_ptr->next_buf;
	if (col_list_ptr->col_data != NULL) {
	    ckfree(col_list_ptr->col_data);
	}
	ckfree((char *)col_list_ptr);
	col_list_ptr = next;
    }
    return 1;
}


/*
 *----------------------------------------------------------------------
 * free_curs
 *   free all cursors belonging to an lda
 *
 */

static int
free_curs (lda_owner)
    int  lda_owner;
{
    int  i;

    for (i = 0; i < ORATCLCURS; i++) {
	if (OraCurs[i].cur_in_use && (OraCurs[i].lda_num == lda_owner)) {
	    OraCurs[i].cur_in_use = 0;
	    OraCurs[i].lda_num    = 0;
	    oclose(OraCurs[i].cda);
	    ckfree((char *)OraCurs[i].cda);
	    OraCurs[i].cda        = NULL;
	    free_cols(OraCurs[i].col_list);
	    OraCurs[i].col_list   = NULL;;
	    free_cols(OraCurs[i].bind_list);
	    OraCurs[i].bind_list   = NULL;;
	}
    }
    return 1;
}




/*
 *----------------------------------------------------------------------
 * alloc_col
 *   return a new ColBufs with nulled pointers and zeroed fields
 */

static ColBufs *
alloc_col()
{
    ColBufs *new_col;

    if ((new_col = (ColBufs *) ckalloc(sizeof (ColBufs))) != NULL) {
	new_col->next_buf      = NULL;
	new_col->dbsize        = 0;
	new_col->dbtype        = 0;
	new_col->dbname[0]     = '\0';
	new_col->dbname_len    = sizeof new_col->dbname;
	new_col->disp_size     = 0;
	new_col->prec          = 0;
	new_col->scale         = 0;
	new_col->nullok        = 0;
	new_col->col_len       = 0;
	new_col->col_data      = NULL;
	new_col->bind_cursor   = -1;
	new_col->rlen[0]       = 0;
	new_col->rcode[0]      = 0;
    }

    return new_col;

}


/*
 *----------------------------------------------------------------------
 * parse_columns
 *   parse result columns, allocate memory for fetches
 *   return -1 on error, 1 if ok
 */

static int
parse_columns (interp, hand)
    Tcl_Interp *interp;
    int         hand;
{
    ColBufs    *new_col_head;
    ColBufs    *new_col;
    ColBufs    *last_col;
    int         pos = 0;
    long        long_size;
    int         i;

    /* start by allocating column structures, and keep in linked list */
    
    new_col_head = alloc_col();
    if (new_col_head == NULL) {
	return -1;
    }
    new_col      = new_col_head;
    last_col     = new_col_head;

    /* get max long size */
    long_size = atol(Tcl_GetVar2(interp, OraMsgArray, "maxlong",
                     TCL_GLOBAL_ONLY));

    if (long_size < 0 ) {
	long_size = 0;
    }
    if (long_size > MAX_LONG_SIZE) {
	long_size = MAX_LONG_SIZE;
    }
    
    /* start with initial cache size of ORA_CACHE; may be reduced to 1 */
    OraCurs[hand].cache_size = ORA_CACHE;

    while (1) {		/* loop breaks when no more result columns */

        /* get oracle description of column data */
	odescr(OraCurs[hand].cda,(pos+1),&(new_col->dbsize),&(new_col->dbtype),
          new_col->dbname, &(new_col->dbname_len), &(new_col->disp_size),
          &(new_col->prec), &(new_col->scale), &(new_col->nullok)   );


       
	if (OraCurs[hand].cda->rc == NO_MORE_COLUMNS) {
	    last_col->next_buf = NULL;
	    ckfree((char *)new_col);
	    break;
	}

	if (OraCurs[hand].cda->rc != 0) {
	    get_ora_err(interp, hand);
	    free_cols(new_col_head);
	    return -1;
	}

	/* trim trailing blanks from dbname */
        for (i = (sizeof new_col->dbname) - 1; i >= 0; i--) {
	    if (new_col->dbname[i] != ' ') {
		new_col->dbname[i+1] = '\0';
		break;
	    }
	}

	/* check for long (type 8) or long raw (type 24) */
	/* if long or long raw found, then set display size to long_size */
	/* and reduce cache to 1 for this cursor */

	if (new_col->dbtype == LONG_TYPE || new_col->dbtype == LONGRAW_TYPE) {
	    new_col->disp_size = long_size; 
	    OraCurs[hand].cache_size = 1;
	}

	pos++;
	last_col           = new_col;
	new_col            = alloc_col();
	if (new_col == NULL) {
	    free_cols(new_col_head);
	    return -1;
	}
	last_col->next_buf = new_col;

    }
     
    if (pos > 0) {
	OraCurs[hand].col_list = new_col_head;
    } else {
	/* no results, just return */
	OraCurs[hand].col_list = NULL;
	return 1;
    }

    /* now define the fetch areas */

    for (new_col = new_col_head, pos=1; new_col != NULL; 
				   new_col = new_col->next_buf, pos++) {
	new_col->disp_size += 1;   /* add room for null terminator */

	new_col->col_data=ckalloc(new_col->disp_size *OraCurs[hand].cache_size);
	if (new_col->col_data == NULL) {
	    free_cols(new_col_head);
	    OraCurs[hand].col_list = NULL;
	    return -1;
	}

	odefin(OraCurs[hand].cda, pos, new_col->col_data, 
	       (int) new_col->disp_size, EXT_STRING_TYPE, 0, (short *) 0, 
	       NULL, 0, 0, new_col->rlen, new_col->rcode);

    }

    return (1);

}


/*
 *----------------------------------------------------------------------
 *
 * append_cols
 *      appends column results to tcl result
 */

static void
append_cols (interp, hand)
    Tcl_Interp  *interp;
    int          hand;
{
    int      i;
    ColBufs *col;
    char    *data_ptr;
    char     buf[ORA_MSG_SIZE];
    char     buf2[ORA_MSG_SIZE];

    i = OraCurs[hand].row_num;

    if (i < 0 || i >= OraCurs[hand].cache_size) {	/* quick sanity check */
	return;
    }


    strncpy(buf2,Tcl_GetVar2(interp,OraMsgArray,"nullvalue",TCL_GLOBAL_ONLY),
	    (sizeof buf2) - 1);

    for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
      
	/* for cursor type, just return a null */

	if (col->dbtype == INT_CURSOR_TYPE) {
	   Tcl_AppendElement(interp, "");
	   continue;
	}

        /* get pointer to next row column data buffer */
	data_ptr = col->col_data + (i * col->disp_size);

        /* null column? except long (8) & long raw (24) may report null     */
	/*              in error, so check rlen for those types, for other  */
	/*              types, just check rcode                             */

	if ( ( (col->dbtype == LONG_TYPE || col->dbtype == LONGRAW_TYPE) && 
						  col->rlen[i] == 0 )        ||
	     ( (col->dbtype != LONG_TYPE && col->dbtype != LONGRAW_TYPE) && 
	        col->rcode[i] == NULL_VALUE ) ) {

            if (*buf2 == 'd' && strcmp(buf2,"default") == 0) {
                /* default-if number or money type, then return "0", else ""  */
		if (col->dbtype == NUMBER_TYPE) {
		    data_ptr = "0";
		} else {
		    data_ptr = "";
		}
	    } else {
		/* return user defined nullvalue */
		data_ptr = buf2;
	    }

	} else {

	    /* make sure data is null terminated, just in case */
	    if (col->disp_size > 0) {
		*(data_ptr + (col->disp_size) - 1) = '\0';
	    } else {
		data_ptr = "";
	    }
	}

        Tcl_AppendElement(interp, data_ptr);
    }


    OraCurs[hand].row_num += 1;
    OraCurs[hand].fetch_cnt += 1;
    sprintf(buf,"%ld",OraCurs[hand].fetch_cnt);
    Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, OraMsgArray, "rc",   "0", TCL_GLOBAL_ONLY);

    fetch_ok = 1;

}



/*
 *----------------------------------------------------------------------
 * Oratcl_Kill --
 *   perform all cleanup upon any command deletion
 *
 */

void
Oratcl_Kill (clientData)
    ClientData clientData;
{
    int i;


    for (i = 0; i < ORATCLLDAS; i++) {
	if (OraLdas[i].lda_in_use) {
	    free_curs(i);
	    OraLdas[i].lda_in_use = 0;
#ifdef NONBLOCK_CURSOR
	    if (OraLdas[i].async == 1) {
	      obreak(OraLdas[i].lda);
	      onbclr(OraLdas[i].lda);
	    }
#endif
	    ologof(OraLdas[i].lda);
	    ckfree((char *)OraLdas[i].lda);
	    ckfree(OraLdas[i].hda);
	}
    }

    MY_STATS_DUMP;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_Init --
 *   perform all initialization for the Oracle - Tcl interface.
 *   adds additional commands to interp, creates message array
 *
 *   a call to Oratcl_Init should exist in Tcl_CreateInterp or
 *   Tcl_CreateExtendedInterp.
 */

int
Oratcl_Init (interp)
    Tcl_Interp *interp;
{
    int i;
    char info[200];
    static int OratclInitFlag = 0;    /* check if already initialized */
    
#ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	return TCL_ERROR;
    }
#endif
    
    /* check if already initialized */
    if (!OratclInitFlag) {
 
        MY_STATS_INIT;

	/*
	 * Initialize oratcl structures 
	 */

	for (i = 0; i < ORATCLLDAS; i++) {
	    OraLdas[i].lda_in_use    = 0;
	    OraLdas[i].lda           = NULL;
	    OraLdas[i].hda           = NULL;
	    OraLdas[i].async         = 0;
	}

	for (i = 0; i < ORATCLCURS; i++) {
	    OraCurs[i].cur_in_use    = 0;
	    OraCurs[i].lda_num       = 0;
	    OraCurs[i].cda           = NULL;
	    OraCurs[i].col_list      = NULL;
	    OraCurs[i].cache_size    = ORA_CACHE;
	    OraCurs[i].row_num       = 0;
	    OraCurs[i].fetch_end     = 1;
	    OraCurs[i].fetch_cnt     = 0;
	    OraCurs[i].oexec_done    = 0;
	    OraCurs[i].first_fetch   = 0;
	    OraCurs[i].async         = 0;
	}

        OratclInitFlag = 1;

	Tcl_CreateExitHandler ((Tcl_ExitProc *)Oratcl_Kill, (ClientData)NULL);
    }

    /*
     * Initialize the new Tcl commands
     */

    Tcl_CreateCommand (interp, "oralogon",   Oratcl_Logon  , (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oralogoff",  Oratcl_Logoff,  (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oraopen",    Oratcl_Open,    (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oraclose",   Oratcl_Close,   (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orasql",     Oratcl_Sql,     (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orabindexec",Oratcl_Bindexec,(ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orafetch",   Oratcl_Fetch,   (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oracols",    Oratcl_Cols,    (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oracancel",  Oratcl_Cancel,  (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oraplexec",  Oratcl_PLexec,  (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oracommit",  Oratcl_Commit,  (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oraroll",    Oratcl_Roll,    (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "oraautocom", Oratcl_Autocom, (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orawritelong",Oratcl_Wrlong, (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orareadlong",Oratcl_Rdlong,  (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
#ifdef NONBLOCK_CURSOR
    Tcl_CreateCommand (interp, "orapoll",    Oratcl_Poll,    (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand (interp, "orabreak",   Oratcl_Break,   (ClientData)NULL,
		      (Tcl_CmdDeleteProc *) NULL);
#endif

#ifdef TCL81
    /* Set the Oracle environment variable NLS_LANG to UTF8. This tell Oracle
     * that data will be sent to it in UTF-8 format. This allows Oratcl
     * to be used with the internationalization features of TCL8.1
     */
     
      Tcl_SetVar2(interp, EnvArray, "NLS_LANG", "American_America.UTF8",TCL_GLOBAL_ONLY);
#endif      
    /*
     * Initialize oramsg global array, inital null elements
     */
    
    /* index "version" - oratcl verison number */
    Tcl_SetVar2(interp, OraMsgArray, "version", ORATCL_VERSION,TCL_GLOBAL_ONLY);

    /* index "handle" - the last handle that set any other elements */
    Tcl_SetVar2(interp, OraMsgArray, "handle",   "", TCL_GLOBAL_ONLY);

    /* index "nullvalue" - what to return if column is null */
    /* user should set this value if something else is wanted */
    Tcl_SetVar2(interp, OraMsgArray, "nullvalue", "default",TCL_GLOBAL_ONLY);

    /* index "maxlong" - the maximum length of a long column to return */
    /* in a select or oralong , can be set by user                 */
    Tcl_SetVar2(interp, OraMsgArray, "maxlong", "32768",TCL_GLOBAL_ONLY);

    /* index "ociinfo" - information on how oratcl was compiled    */
#ifdef VERSION7
    strcpy(info,"version_7");
#ifdef NONBLOCK_CURSOR
    strcat(info," non_blocking cursor_variables");
#endif
#else
    strcpy(info,"version_6");
#endif
    Tcl_SetVar2(interp, OraMsgArray, "ociinfo", info, TCL_GLOBAL_ONLY);

    /* other indices - correspond to error and message handler arguments */
    clear_msg(interp);


#if ((TCL_MAJOR_VERSION > 7) || ((TCL_MAJOR_VERSION == 7) && (TCL_MINOR_VERSION >= 5)))

    if (Tcl_PkgProvide(interp, "Oratcl", ORATCL_VERSION) != TCL_OK) {
	return TCL_ERROR;
    }

#endif

    return TCL_OK;
}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Logon --
 *    Implements the oralogon command:
 *    usage: oralogon connect_str
 *       connect_str should be a valid oracle logon string, consisting of:
 *         name
 *         name/password
 *         name@d:dbname
 *         name/password@d:dbname
 *	                
 *    results:
 *	handle - a character string of newly open logon handle
 *      TCL_OK - connect successful
 *      TCL_ERROR - connect not successful - error message returned
 */

int
Oratcl_Logon (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{

    int        hand = -1;
    int        i;
    int        rc;
    char       buf[ORA_MSG_SIZE];
    int namelen, pwlen, connlen;
    char *name;
    char *pword;
    char *conn;

    /* can't use ora_prologue, oralogon creates a logon handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " connect_str ", (char *) NULL);
	return TCL_ERROR;
    }

    /* find an unused handle */

    for (i = 0; i < ORATCLLDAS; i++) {
	if (OraLdas[i].lda_in_use == 0) {
            hand = i;
	    break;
	}
    }

    if (hand == -1) {
	Tcl_AppendResult (interp, argv[0], ": no lda handles available",
			  (char *) NULL);
	return TCL_ERROR;
    }

    OraLdas[i].async = 0;

    if ( (OraLdas[hand].lda = (lda_def *) ckalloc(sizeof (lda_def))) == NULL) {
	Tcl_AppendResult (interp, argv[0], ": oralogon failed in malloc(lda)",
			  (char *) NULL);
	return TCL_ERROR;
    }
    if ( (OraLdas[hand].hda = ckalloc(ORA_HOST_AREA)) == NULL) {
        ckfree((char *)OraLdas[hand].lda);
	Tcl_AppendResult (interp, argv[0], ": oralogon failed in malloc(hda)",
			  (char *) NULL);
	return TCL_ERROR;
    }

    /* safety - zero out lda and hda */
    bzero(OraLdas[hand].lda,sizeof (lda_def));
    bzero(OraLdas[hand].hda,ORA_HOST_AREA);

    /* orlon sometimes fails on first attempt, but then works on next */
    /* attempt in some cases.  try orlon 2nd time if fail on 1st try  */

#ifdef VERSION7DB
    rc = orlon(OraLdas[hand].lda, OraLdas[hand].hda,argv[1], -1, NULL, -1,0);
    if (rc != 0) {
      rc = orlon(OraLdas[hand].lda, OraLdas[hand].hda,argv[1], -1, NULL, -1,0);
    }
#endif

#ifndef VERSION7DB
   /* Use Oracle 8 API call OCILogon. orlon does not seen to work with later
      versions of Oracle 8i */   

   rc = OCIInitialize((ub4) OCI_DEFAULT, (dvoid *)0,
            (dvoid * (*)(dvoid *, size_t)) 0,
            (dvoid * (*)(dvoid *, dvoid *, size_t))0,
            (void (*)(dvoid *, dvoid *)) 0 );

   rc = OCIEnvInit( (OCIEnv **) &p_env, OCI_DEFAULT, (size_t) 0, (dvoid **) 0);

   rc = OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_err, OCI_HTYPE_ERROR,
         (size_t) 0, (dvoid **) 0);

   rc = OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_svc, OCI_HTYPE_SVCCTX,
         (size_t) 0, (dvoid **) 0);
 
    
    name = strtok(argv[1], "/@");
    pword = strtok(NULL, "/@");
    conn = strtok(NULL, "/@");
    if (name != NULL) 
      namelen = strlen(name);
    else namelen = 0;
    if (pword != NULL)
      pwlen = strlen(pword);
    else pwlen = 0;
    if (conn != NULL)
      connlen = strlen(conn);
    else connlen = 0;

    rc = OCILogon(p_env, p_err, &p_svc, name, namelen, pword, pwlen , conn, connlen);

    OCISvcCtxToLda (p_svc, p_err, OraLdas[hand].lda);
    
#endif
    
    if (rc != 0) {
	/* logon failed, cleanup */
	/* can't use get_lda_err(), may not have connected to server*/
        sprintf(buf,"%d",OraLdas[hand].lda->rc);
        Tcl_SetVar2(interp,OraMsgArray,"rc",buf,TCL_GLOBAL_ONLY);
        Tcl_SetVar2(interp,OraMsgArray,"errortxt",
           "logon failed: invalid id/password or unable to connect to server",
	    TCL_GLOBAL_ONLY);

        ckfree((char *)OraLdas[hand].lda);
        ckfree((char *)OraLdas[hand].hda);
	Tcl_AppendResult (interp, argv[0], ": oralogon failed in orlon",
			  (char *) NULL);
	return TCL_ERROR;
    }

    OraLdas[i].lda_in_use = 1;	/* handle ok, set in use flag */

    /* construct logon handle and return */
    sprintf(buf,"%s%d",OraHandlePrefix,hand);

    Tcl_SetVar2(interp, OraMsgArray, "handle",      buf, TCL_GLOBAL_ONLY);
    clear_msg(interp);

    Tcl_SetResult(interp,buf,TCL_VOLATILE);

    return TCL_OK;

}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Logoff --
 *    Implements the oralogoff command:
 *    usage: oralogon lda_handle
 *       lda_handle should be a valid, open lda handle from oralogon
 *	                
 *    results:
 *	null string
 *      TCL_OK - logoff successful
 *      TCL_ERROR - logoff not successful - error message returned
 */

int
Oratcl_Logoff (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{

    int        hand;
    int        i;
    char       buf[ORA_MSG_SIZE];


    /* can't use ora_prologue, oralogoff just uses an lda handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }

#ifdef NONBLOCK_CURSOR
    if (OraLdas[hand].async == 1) {
      obreak(OraLdas[hand].lda);
      onbclr(OraLdas[hand].lda);
    }
#endif

    /* close and free all open cursors through this connection */
    free_curs(hand);

    /* logoff and free data areas */
    OraLdas[hand].lda_in_use = 0;
    OraLdas[hand].async      = 0;
    if (ologof(OraLdas[hand].lda) != 0) {
	/* logoff failed, get error msg */
	get_lda_err(interp,hand);
        ckfree((char *)OraLdas[hand].lda);
        ckfree(OraLdas[hand].hda);

	return TCL_ERROR;
    }

    ckfree((char *)OraLdas[hand].lda);
    ckfree(OraLdas[hand].hda);

    return TCL_OK;
}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Open --
 *    Implements the oraopen command:
 *    usage: oralogon lda_handle
 *       lda_handle should be a valid, open lda handle from oralogon
 *	                
 *    results:
 *	cur_handle
 *      TCL_OK - oopen successful
 *      TCL_ERROR - oopen not successful - error message returned
 */

int
Oratcl_Open (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{

    int        lda_hand;
    int        hand = -1;
    int        i;
    char       buf[ORA_MSG_SIZE];


    /* can't use ora_prologue, oraopen just uses an lda handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((lda_hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }


    /* find an unused cursor handle */

    for (i = 0; i < ORATCLCURS; i++) {
	if (OraCurs[i].cur_in_use == 0) {
            hand = i;
	    break;
	}
    }

    if (hand == -1) {
	Tcl_AppendResult (interp, argv[0], ": no cursor handles available",
			  (char *) NULL);
	return TCL_ERROR;
    }


    if ( (OraCurs[hand].cda = (cda_def *) ckalloc(sizeof (cda_def))) == NULL) {
	Tcl_AppendResult (interp, argv[0], ": oraopen failed in malloc(cda)",
			  (char *) NULL);
	return TCL_ERROR;
    }
    
    if (oopen(OraCurs[hand].cda,OraLdas[lda_hand].lda,NULL,-1,-1,NULL,-1) !=0) {
	/* open failed, cleanup */
	get_ora_err(interp,hand);
        ckfree((char *)OraCurs[hand].cda);
	Tcl_AppendResult (interp, argv[0], ": oraopen failed in oopen",
			  (char *) NULL);
	return TCL_ERROR;
    }

    /* cursor open ok */
    OraCurs[hand].cur_in_use = 1;
    OraCurs[hand].lda_num    = lda_hand;
    OraCurs[hand].col_list   = NULL;
    OraCurs[hand].bind_list  = NULL;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = 0;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].oexec_done = 0;
    OraCurs[hand].first_fetch= 0;
    OraCurs[hand].async      = 0;


    /* construct and return a cursor handle */
    sprintf(buf,"%s%d.%d",OraHandlePrefix,lda_hand,hand);  

    Tcl_SetVar2(interp, OraMsgArray, "handle",      buf, TCL_GLOBAL_ONLY);
    clear_msg(interp);

    Tcl_SetResult(interp,buf,TCL_VOLATILE);

    return TCL_OK;

}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Close --
 *    Implements the oraclose command:
 *    usage: oraclose cur_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - cursor closed successfully
 *      TCL_ERROR - wrong # args, or cur_handle not opened
 */

Oratcl_Close (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;

    if ((hand = ora_prologue(interp,argc, argv, 2," cur_handle")) == -1) {
	return TCL_ERROR;
    }

    OraCurs[hand].cur_in_use = 0;
    OraCurs[hand].lda_num    = 0;
    oclose(OraCurs[hand].cda);
    bzero(OraCurs[hand].cda, sizeof(cda_def));
    ckfree((char *)OraCurs[hand].cda);
    OraCurs[hand].cda        = NULL;
    free_cols(OraCurs[hand].col_list);
    OraCurs[hand].col_list   = NULL;
    free_cols(OraCurs[hand].bind_list);
    OraCurs[hand].bind_list  = NULL;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = 0;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].oexec_done = 0;
    OraCurs[hand].first_fetch= 0;
    OraCurs[hand].async      = 0;

    return TCL_OK;

}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Sql --
 *    Implements the orasql command:
 *    usage: orasql cur_handle sql_string ?-parseonly? | ?-async?
 *	                
 *    results:
 *	return code from oexec
 *      TCL_OK - handle is opened, sql executed ok
 *      TCL_ERROR - wrong # args, or handle not opened,  bad sql stmt
 */

Oratcl_Sql (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    int     lda_hand;
    char    buf[ORA_MSG_SIZE];
    int     parseonly = 0;
    int     asyncmode = 0;


    if ((hand = ora_prologue(interp,argc, argv,3,
	    " cur_handle sql_str  ?-parseonly? | ?-async? ")) ==-1) {
	return TCL_ERROR;
    }

    /* check for options and deprecated keywords */
    if ((argc >= 4 && *argv[3] == 'p' && strcmp(argv[3],"parseonly") == 0) ||
        (argc >= 4 && *argv[3] == '-' && strcmp(argv[3],"-parseonly")== 0) ) {
	parseonly = 1;
    }

#ifdef NONBLOCK_CURSOR
    if ((argc >= 4 && *argv[3] == 'a' && strcmp(argv[3],"async") == 0) ||
        (argc >= 4 && *argv[3] == '-' && strcmp(argv[3],"-async")== 0) ) {
	asyncmode = 1;
    }
#endif

    /* cancel any pending usage of cursor */
    ocan(OraCurs[hand].cda);

    /* set up sql for execution */
    oparse(OraCurs[hand].cda, argv[2], ((long) -1), DEF_FLAG, LNG_FLAG);


    if (OraCurs[hand].cda->rc != 0) {
	get_ora_err(interp,hand);
	Tcl_AppendResult (interp, argv[0], ": oparse failed (bad sql ?) ", 
			  (char *) NULL);
	return TCL_ERROR;
    } else {
	/* clear peo */
	Tcl_SetVar2(interp, OraMsgArray, "peo",  "0", TCL_GLOBAL_ONLY);
    }

    /* clear any previous results */
    free_cols(OraCurs[hand].col_list);
    OraCurs[hand].col_list   = NULL;
    free_cols(OraCurs[hand].bind_list);
    OraCurs[hand].bind_list  = NULL;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = 0;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].oexec_done = 0;
    OraCurs[hand].first_fetch= 0;
    OraCurs[hand].async      = 0;
  
    if (parseonly && (OraCurs[hand].cda->ft == 3 ||
        OraCurs[hand].cda->ft == 5 || OraCurs[hand].cda->ft == 9)) {
        sprintf(buf,"%d",OraCurs[hand].cda->rc);
        get_ora_err(interp,hand);
        Tcl_SetResult(interp, buf, TCL_VOLATILE);
        return TCL_OK;
    }

    /* only call parse_columns after DML (insert,select,update,delete) */
    if (OraCurs[hand].cda->ft == 3 || OraCurs[hand].cda->ft == 4 ||
        OraCurs[hand].cda->ft == 5 || OraCurs[hand].cda->ft == 9) {

      if (parse_columns(interp, hand) != -1) {
  
          if (parseonly) {
              sprintf(buf,"%d",OraCurs[hand].cda->rc);
	      get_ora_err(interp,hand);
              Tcl_SetResult(interp, buf, TCL_VOLATILE);
              return TCL_OK;
          }

#ifdef NONBLOCK_CURSOR
          if (asyncmode) {
	    lda_hand = OraCurs[hand].lda_num;
	    OraCurs[hand].async     = 1;
	    OraLdas[lda_hand].async = 1;
	    onbset(OraLdas[lda_hand].lda);
	  }
#endif

          oexec(OraCurs[hand].cda);
  
          /* set msg array variable "rows" to rpc (rows processed count) */
          /* in case of insert, update, delete,                          */
          sprintf(buf,"%d",OraCurs[hand].cda->rpc);
          Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
  
          /* set msg array variable "rowid" of any row manipulated */
          sprintf(buf,"%08.8X.%04.4X.%04.4X",
                        OraCurs[hand].cda->rid.d4,
                        OraCurs[hand].cda->rid.d5,
/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
/*                      OraCurs[hand].cda->rid.rd.d1, */
/*                      OraCurs[hand].cda->rid.rd.d3, */
                        OraCurs[hand].cda->rid.rd.d2);
          Tcl_SetVar2(interp, OraMsgArray, "rowid", buf, TCL_GLOBAL_ONLY);
  
  	/* cause first orafetch to fetch */
  	OraCurs[hand].row_num   = OraCurs[hand].cache_size;
  	OraCurs[hand].fetch_end = 0;        /* try to fetch */
  	OraCurs[hand].fetch_cnt = 0;        /* start fetch cnt at zero */
  
      } else {
  	get_ora_err(interp,hand);
  	Tcl_AppendResult (interp, argv[0], ": parse_columns failed ", 
  			  (char *) NULL);
  	return TCL_ERROR;
      }

    } else {
      oexec(OraCurs[hand].cda);

      if (OraCurs[hand].cda->rc != 0) {
  	get_ora_err(interp,hand);
  	Tcl_AppendResult (interp, argv[0], ": oexec of DDL failed ",
  			  (char *) NULL);
  	return TCL_ERROR;
      }
      /* set msg array variable "rows" to rpc (rows processed count) */
      /* in case of insert, update, delete,                          */
      sprintf(buf,"%d",OraCurs[hand].cda->rpc);
      Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);

    }

    get_ora_err(interp,hand);

    sprintf(buf,"%d",OraCurs[hand].cda->rc);

    Tcl_SetResult(interp, buf, TCL_VOLATILE);

    return TCL_OK;
}


#ifdef NONBLOCK_CURSOR
/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Poll --
 *    Implements the orapoll command:
 *    usage: orapoll cur_handle ?-all?
 *	                
 *    results:
 *	return argv[1] handle if cursor is ready, null if still blocking
 *        optional "-all" returns list of all ready cursors
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 */

Oratcl_Poll (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int        hand;
    int        lda_hand;
    int        rc;
    int        old_rc;
    long       old_rpc;
    int        i;
    int        max;
    int        start;
    char       buf[ORA_MSG_SIZE];


    if ((hand = ora_prologue(interp,argc, argv,2, " cur_handle ?-all?")) ==-1) {
	return TCL_ERROR;
    }

    /* check for options and deprecated keywords */
    if ((argc >= 3 && *argv[2] == 'a' && strcmp(argv[2],"all") ==0) ||
        (argc >= 3 && *argv[2] == '-' && strcmp(argv[2],"-all")==0) ) {

        /* test all open ldas */
	start = 0;
	max   = ORATCLCURS;
    } else {
	start = hand;
	max   = hand + 1;
    }


    for (i = start; i < max; i++) {
	if (OraCurs[i].cur_in_use) {
	    lda_hand = OraCurs[i].lda_num;
	    if (OraCurs[i].async && OraLdas[lda_hand].async) {
		/* first try oexec, then ofen */
		if (! OraCurs[i].oexec_done ) {
		    oexec(OraCurs[i].cda);
		    rc = OraCurs[i].cda->rc;
		    if (rc == 0) {
			/* sql has finished, check for data ready */
			OraCurs[i].oexec_done = 1;
			rc = ofen(OraCurs[i].cda,OraCurs[i].cache_size);
			rc = OraCurs[i].cda->rc;
		    }
		} else {
		    ofen(OraCurs[i].cda, OraCurs[i].cache_size);
		    rc = OraCurs[i].cda->rc;
		}

		if (rc != BLOCKED) {
		    old_rc  = OraCurs[i].cda->rc;	/* don't let onbclr */
		    old_rpc = OraCurs[i].cda->rpc;	/* change rc & rpc  */
		    onbclr(OraLdas[lda_hand].lda);
		    OraCurs[i].cda->rc  = old_rc;
		    OraCurs[i].cda->rpc = old_rpc;
		    OraLdas[lda_hand].async = 0;
		    OraCurs[i].async = 0;
		    OraCurs[i].first_fetch = 1;
		    sprintf(buf,"%s%d.%d",OraHandlePrefix,
					       OraCurs[i].lda_num, i);
		    Tcl_AppendElement(interp, buf);
		} 

	    } else {
	        /* check for non-async cursors that can still fetch */
		if (!OraCurs[i].fetch_end) {
		    sprintf(buf,"%s%d.%d",OraHandlePrefix,
						OraCurs[i].lda_num, i);
		    Tcl_AppendElement(interp, buf);
		}
	    }
	}
    }

    get_ora_err(interp,hand);

    return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Break --
 *    Implements the orabreak command:
 *    usage: orapoll lda_handle 
 *	                
 *    results:
 *      sends break to lda in async mode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 */

Oratcl_Break (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int        hand;
    int        i;
    char       buf[ORA_MSG_SIZE];

    /* can't use ora_prologue, orabreak just uses an lda handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }

    if (OraLdas[hand].async) {
	obreak(OraLdas[hand].lda);
	onbclr(OraLdas[hand].lda);
	OraLdas[hand].async = 0;
    }

    return TCL_OK;
}
#endif

/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Bindexec --
 *    Implements the orabindexec command:
 *    usage: orabindexec cur_handle ?-async? :varname value 
 *	                
 *    results:
 *	bind :varname value pairs, execute sql
 *	sets message array element "rc" with value of exec rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 */

Oratcl_Bindexec (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int        hand;
    int        lda_hand;
    char       buf[ORA_MSG_SIZE];
    int        parm_cnt;
    ColBufs    *tmp_col_head;
    ColBufs    *tmp_col;
    ColBufs    *head_col;
    int        asyncmode = 0;


    if ((hand = ora_prologue(interp,argc, argv,2,
		  " cur_handle ?-async?  [ :varname value ] ...")) == -1) {
	return TCL_ERROR;
    }

    OraCurs[hand].oexec_done = 0;
    OraCurs[hand].first_fetch= 0;
    OraCurs[hand].async      = 0;

    parm_cnt = 2;

    /* check for option and deprecated keywords */
    if ((argc >= 3 && *argv[2] == 'a' && strcmp(argv[2],"async") == 0) ||
        (argc >= 3 && *argv[2] == '-' && strcmp(argv[2],"-async")== 0) ) {
#ifdef NONBLOCK_CURSOR
	asyncmode = 1;
#endif
	parm_cnt++;
    }

    /* if first time in, allocate bind_list */

    if (OraCurs[hand].bind_list == NULL ) {

	if (argc > parm_cnt + 1) {
	    tmp_col_head = alloc_col();
	    if (tmp_col_head == NULL) {
		Tcl_AppendResult(interp, argv[0], " cannot malloc new col ",
			(char *) NULL);
		return TCL_ERROR;
	    }
	    tmp_col      = tmp_col_head;
	    head_col     = tmp_col_head;
	    OraCurs[hand].bind_list = tmp_col_head;
	} else {
	    tmp_col_head = NULL;
	}

	while (argc > parm_cnt + 1) {       /* always in pairs of two */

	    /* make sure bind variable name has a leading ':' */
	    if (*argv[parm_cnt] != ':') {
		free_cols(OraCurs[hand].col_list);
		OraCurs[hand].col_list = NULL;
		free_cols(OraCurs[hand].bind_list);
		OraCurs[hand].bind_list = NULL;
		Tcl_AppendResult(interp, argv[0], " bind variable ", 
			argv[parm_cnt],
			" does not begin with ':' ", (char *) NULL);
		return TCL_ERROR;
	    }

	    strncpy(tmp_col->dbname, argv[parm_cnt], 255);
	    tmp_col->disp_size  = ORA_BIND_SIZE;
	    tmp_col->col_data   = ckalloc(tmp_col->disp_size + 1);

	    if (tmp_col->col_data == NULL) {
		free_cols(OraCurs[hand].col_list);
		OraCurs[hand].col_list = NULL;
		free_cols(OraCurs[hand].bind_list);
		OraCurs[hand].bind_list = NULL;
		Tcl_AppendResult(interp, argv[0],
		    " cannot malloc new col data for ", argv[parm_cnt],
		    (char *) NULL);
		return TCL_ERROR;
	    } else {
		strncpy(tmp_col->col_data,argv[parm_cnt + 1],ORA_BIND_SIZE - 1);
	    }

	    tmp_col->rlen[0] = 0;
	    tmp_col->rcode[0] = 0;
	    obndrv( OraCurs[hand].cda, argv[parm_cnt], -1, tmp_col->col_data,
		    ORA_BIND_SIZE, EXT_STRING_TYPE, -1, NULL, NULL, -1, -1);

	    if (OraCurs[hand].cda->rc != 0) {
		get_ora_err(interp, hand);
		free_cols(OraCurs[hand].col_list);
		OraCurs[hand].col_list = NULL;
		free_cols(OraCurs[hand].bind_list);
		OraCurs[hand].bind_list = NULL;
		Tcl_AppendResult(interp, argv[0], " bind failed for ",
		    argv[parm_cnt], (char *) NULL);
		return TCL_ERROR;
	    }

	    parm_cnt += 2;

	    if (argc > parm_cnt + 1) {       /* more args? alloc new colbufs */
		head_col           = tmp_col;
		tmp_col            = alloc_col();
		if (tmp_col == NULL) {
		    free_cols(OraCurs[hand].col_list);
		    OraCurs[hand].col_list = NULL;
		    free_cols(OraCurs[hand].bind_list);
		    OraCurs[hand].bind_list = NULL;
		    Tcl_AppendResult(interp, argv[0]," cannot malloc new col ",
			(char *) NULL);
		    return TCL_ERROR;
		}
		head_col->next_buf = tmp_col;
	    }
	}

    } else {

	/* else, binds have been done, just copy in new data */

	while (argc > parm_cnt + 1) {       /* always in pairs of two */
	    tmp_col = OraCurs[hand].bind_list;
	    while (tmp_col != NULL) {
		if (strncmp(tmp_col->dbname, argv[parm_cnt], 255) == 0) {
		    strncpy(tmp_col->col_data,argv[parm_cnt + 1],
			    ORA_BIND_SIZE - 1);    
		    break;
		}
		tmp_col = tmp_col->next_buf;
	    }
	    parm_cnt += 2;
	}

    }
  
#ifdef NONBLOCK_CURSOR
    if (asyncmode) {
        lda_hand = OraCurs[hand].lda_num;
        OraLdas[lda_hand].async = 1;
        OraCurs[hand].async     = 1;
        onbset(OraLdas[lda_hand].lda);
    }
#endif

    oexec(OraCurs[hand].cda);

    /* set msg array variable "rows" to rpc (rows processed count) */
    /* in case of insert, update, delete,                          */
    sprintf(buf,"%d",OraCurs[hand].cda->rpc);
    Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
  
    /* set msg array variable "rowid" of any row manipulated */
    sprintf(buf,"%08.8X.%04.4X.%04.4X",
                        OraCurs[hand].cda->rid.d4,
                        OraCurs[hand].cda->rid.d5,
/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
/*                      OraCurs[hand].cda->rid.rd.d1, */
/*                      OraCurs[hand].cda->rid.rd.d3, */
                        OraCurs[hand].cda->rid.rd.d2);
    Tcl_SetVar2(interp, OraMsgArray, "rowid", buf, TCL_GLOBAL_ONLY);
  
    /* cause first orafetch to fetch */
    OraCurs[hand].row_num   = OraCurs[hand].cache_size;
    OraCurs[hand].fetch_end = 0;        /* try to fetch */
    OraCurs[hand].fetch_cnt = 0;        /* start fetch cnt at zero */
  
    get_ora_err(interp,hand);

    sprintf(buf,"%d",OraCurs[hand].cda->rc);

    Tcl_SetResult(interp, buf, TCL_VOLATILE);

    return TCL_OK;


}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Fetch --
 *    Implements the orafetch command:
 *    usage: orafetch cur_handle 
 *	                
 *    results:
 *	next row from latest results as tcl list, or null list
 *	sets message array element "rc" with value of fetch rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 */

Oratcl_Fetch (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int      hand;
    int      lda_hand;
    char     buf[ORA_MSG_SIZE];
    char    *data_ptr;
    long     old_rpc;
    int      old_rc;
    ColBufs *col;
    int      i;
    int      Oratcl_FetchAll();


    fetch_ok = 0;

    if ((hand = ora_prologue(interp, argc, argv, 2, 
	 " cur_handle  ?commands? ?subtitution_char?")) == -1) {
	return TCL_ERROR;
    }

    /* if there's a third argument, let next proc do the work */
    if (argc >= 3) {
	return (Oratcl_FetchAll(clientData, interp, argc, argv));
    }

    /* if this cursor hasn't performed SQL, return a 1403 */
    if (OraCurs[hand].fetch_end &&
	OraCurs[hand].fetch_cnt >= OraCurs[hand].cda->rpc &&
	OraCurs[hand].fetch_cnt >  0) {

	sprintf(buf,"%d",NO_DATA_FOUND);
	Tcl_SetVar2(interp, OraMsgArray, "rc", buf, TCL_GLOBAL_ONLY);
	sprintf(buf,"%ld",OraCurs[hand].cda->rpc);
	Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
	return TCL_OK;
    }

#ifdef NONBLOCK_CURSOR
    /* if lda is aysnc, put it back in blocking mode */
    lda_hand = OraCurs[hand].lda_num;
    if (OraLdas[lda_hand].async == 1 || OraCurs[hand].async == 1) {
	/* save rc, rpc of first fetch that was done in orapoll */
	old_rc  = OraCurs[hand].cda->rc;
	old_rpc = OraCurs[hand].cda->rpc;
        onbclr(OraLdas[lda_hand].lda);
	OraLdas[lda_hand].async = 0;
	OraCurs[hand].async     = 0;
	if (! OraCurs[hand].oexec_done) {
	    oexec(OraCurs[hand].cda);
	    OraCurs[hand].oexec_done  = 1;
	    OraCurs[hand].first_fetch = 0;
	} else {
	    /* restore the rpc and rc from first fetch */
	    OraCurs[hand].cda->rc  = old_rc;
	    OraCurs[hand].cda->rpc = old_rpc;
	}
    }
#endif

    /* check if already exahusted */

    if (OraCurs[hand].fetch_end && 
	OraCurs[hand].fetch_cnt >= OraCurs[hand].cda->rpc &&
	OraCurs[hand].fetch_cnt >  0) {

	sprintf(buf,"%d",NO_DATA_FOUND);
        Tcl_SetVar2(interp, OraMsgArray, "rc",   buf, TCL_GLOBAL_ONLY);
        sprintf(buf,"%ld",OraCurs[hand].cda->rpc);
        Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
	return TCL_OK;
    }

    /* check to see if next set of results */

    old_rpc = OraCurs[hand].cda->rpc;

    if (OraCurs[hand].row_num >= OraCurs[hand].cache_size  ||
	OraCurs[hand].fetch_cnt >= OraCurs[hand].cda->rpc) {

        for (col=OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
	    for (i = 0; i < OraCurs[hand].cache_size; i++) {
                col->rcode[i] = 0;
                col->rlen[i] = 0;
	    }
	}

	if (! OraCurs[hand].first_fetch) {
	    ofen(OraCurs[hand].cda, OraCurs[hand].cache_size);
	}
	OraCurs[hand].first_fetch = 0;	/* always enter ofen() from now on */

	if (OraCurs[hand].cda->rc == OUT_OF_SEQUENCE) {
	    OraCurs[hand].fetch_cnt = 0;
	    OraCurs[hand].cda->rpc  = 0;
	    OraCurs[hand].fetch_end = 1;
	    OraCurs[hand].row_num   = OraCurs[hand].cache_size;
	    sprintf(buf,"%d",OUT_OF_SEQUENCE);
	    Tcl_SetVar2(interp, OraMsgArray, "rc", buf, TCL_GLOBAL_ONLY);
	    sprintf(buf,"%ld",OraCurs[hand].cda->rpc);
	    Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
	    return TCL_OK;
	}

	if (OraCurs[hand].cda->rc == NO_DATA_FOUND) {
	    OraCurs[hand].fetch_end = 1;
	    /* if old_rpc equal current rpc, there are no more rows to */
	    /* return, else ofen is ended, but rows are buffered to return */
	    if (old_rpc == OraCurs[hand].cda->rpc) {
	        sprintf(buf,"%d",OraCurs[hand].cda->rc);
                Tcl_SetVar2(interp, OraMsgArray, "rc", buf, TCL_GLOBAL_ONLY);
                sprintf(buf,"%ld",OraCurs[hand].cda->rpc);
                Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
	        return TCL_OK;
	    }
	} else {
	    if ((OraCurs[hand].cda->rc == 0              ) ||
	        (OraCurs[hand].cda->rc == NULL_VALUE     ) ||
		(OraCurs[hand].cda->rc == NO_STMT_PARSED ) ||
	        (OraCurs[hand].cda->rc == COL_TRUNCATED  ) ) {
		/* these are acceptable ofen codes, */
		/* so  drop through to append_cols */

	    } else {
	       /* some error has occured during fetch, perhaps 600? */
	       /* return error and cancel any subsequent fetching */
	       OraCurs[hand].fetch_cnt = 0;
	       OraCurs[hand].cda->rpc  = 0;
	       OraCurs[hand].fetch_end = 1;
  	       get_ora_err(interp,hand);
  	       Tcl_AppendResult (interp, argv[0], ": ofen failed ", 
  			  (char *) NULL);
  	       return TCL_ERROR;
	    }
	}

        OraCurs[hand].row_num = 0;
    }

    /* set msg array variable "rowid" of any row manipulated */
    sprintf(buf,"%08.8X.%04.4X.%04.4X",
                        OraCurs[hand].cda->rid.d4,
                        OraCurs[hand].cda->rid.d5,
/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
/*                      OraCurs[hand].cda->rid.rd.d1, */
/*                      OraCurs[hand].cda->rid.rd.d3, */
                        OraCurs[hand].cda->rid.rd.d2);
    Tcl_SetVar2(interp, OraMsgArray, "rowid", buf, TCL_GLOBAL_ONLY);
  
    append_cols(interp, hand);

    return TCL_OK;
}





/*
 *----------------------------------------------------------------------
 *
 * Oratcl_FetchAll --
 *    Implements the orafetch with iterative commands:
 *    usage: orafetch cur_handle tcl_stmts substitution_char ?tclvar colnum ..?
 *	                
 *    results:
 *	fetch all rows from existing query, execute tcl_stmt on each row
 *	sets message array element "rc" with value of final fetch rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened, tcl_stmt failed,
 *                  or wrong number of columns
 */

int
Oratcl_FetchAll (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int      hand;
    char     buf[ORA_MSG_SIZE];
    char    *eval_ptr;
    int      colsCnt;
    char   **colsPtr;
    int      i;
    char    *s;
    char    *s2;
    char    *p;
    ColBufs *col;
    int      max_col = 0;

#define NUMSTRS 300		/* number of individual strings to allow*/
#define SUBCHAR '@'		/* default substitution character */

    char     subchar = SUBCHAR; /* substitution character */
    int      num_str = 0;	/* number of strings to concat */
    char    *str[NUMSTRS];      /* strings to pass to concat   */

    int      colnum  = 0; 	/* number of colstr's used */

    struct {			
      int      column; 		/* column number index */
      int      strnum;          /* str array index */
    } colstr[NUMSTRS];

    char     static_command[ORA_BUFF_SIZE];
    char    *cmd_str;
 
#define FREE_CMD_STR  if (cmd_str != &static_command[0]) ckfree(cmd_str)

    Tcl_DString evalStr;	/* tcl dynamic string for building eval */
    Tcl_DString varStr;	        /* tcl dynamic string for building varname */
    Tcl_DString resStr;	        /* tcl dynamic string for prev interp result */
    int      parm_cnt;
    int      inum;
    int      icol;
    int      tcl_rc;


    if ((hand = ora_prologue(interp, argc, argv, 3, 
	 " cur_handle  commands ?sub_char? ? [ tclvar colnum ] ... ?")) == -1) {
	return TCL_ERROR;
    }

    /* check if already exahusted or nothing to fetch */

    if (OraCurs[hand].fetch_end && 
	OraCurs[hand].fetch_cnt >= OraCurs[hand].cda->rpc &&
	OraCurs[hand].fetch_cnt >  0) {

	sprintf(buf,"%d",NO_DATA_FOUND);
        Tcl_SetVar2(interp, OraMsgArray, "rc",   buf, TCL_GLOBAL_ONLY);
        sprintf(buf,"%ld",OraCurs[hand].cda->rpc);
        Tcl_SetVar2(interp, OraMsgArray, "rows", buf, TCL_GLOBAL_ONLY);
	return TCL_OK;
    }

    if (OraCurs[hand].col_list == NULL) {   
	return TCL_OK;			/* nothing to fetch */
    }

    if (argc >= 4) {
        subchar = *argv[3];
        /* don't let subchar be a space */
        if (subchar == ' ') {
	    subchar = '\0';
        }
    }

    /* make a copy of the command string, dont use a DString */
    i = strlen(argv[2]);
    if (i+1 < ORA_BUFF_SIZE) {
        cmd_str = &static_command[0];
    } else {
        cmd_str = ckalloc(i+1);
    }
    strcpy(cmd_str, argv[2]);


    /* parse tcl_stmt for all '@' substitutions */

    s  = cmd_str;			/* start of tcl_stmt */
    s2 = s;

    while ( (p = strchr(s2,subchar)) != NULL && subchar != '\0') {

      if (num_str >= NUMSTRS || colnum >= NUMSTRS) {
	  Tcl_AppendResult (interp, argv[0], 
			": too many column substitutions, 300 max", 
			  (char *) NULL);
	  FREE_CMD_STR;
  	  return TCL_ERROR;
      }

      if (isdigit(*(p+1))) {		/* it's a substituion value ! */

	  if (s != p) {			/* subchar not at the front of string?*/
	      str[num_str] = s;		/* save the current front of string */
	      *p = '\0';  		/* terminate the literal string     */
	      num_str++;		/* into str array and               */
	  }

          i = atoi(p + 1);		/* the column number */

	  max_col = (i > max_col) ? i : max_col;/* sanity check, max col num */

	  colstr[colnum].column = i;		/* save column number */
	  colstr[colnum].strnum = num_str;	/* and str positiion  */
	  str[num_str] = "";			/* sanity check       */
	  colnum++;
	  num_str++;
	  p++;				/* skip past col number */
	  while (isdigit(*p)) {
	      p++;
	  }
	  s  = p;			/* next point to look for subchar */
	  s2 = p;			


      } else {				/* it's a subchar without number */
	  s2 = p + 1;			/* ignore and keep searching     */
	  if (*s2 == subchar) {		/* another subchar? it's quoted  */
	      bcopy(s2+1,s2,strlen(s2)+1);  /* so collapse memory by one */
	      s2++;
	  }
      }

    }

    if (num_str == 0) {    		/* check if no substitutions */
	str[num_str] = cmd_str;	
	num_str = 1;	
    } else {		
	if (strlen(s) > 0) {		/* remainder of tcl_stmt string */
            str[num_str] = s;
	    num_str++;
	}
    }


    /* make sure there are enough columns in result */
    i = 0;
    for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
	i++;
    }
    if (max_col > i) {
	Tcl_AppendResult (interp, argv[0], ": @column number execeeds results", 
			  (char *) NULL);
	FREE_CMD_STR;
	return TCL_ERROR;
    }


    /* loop until fetch exhausted */

    if (Oratcl_Fetch(clientData, interp, 2, argv) == TCL_ERROR) {
	Tcl_AppendResult (interp, ": ", argv[0], ": orafetch failed", 
			  (char *) NULL);
	FREE_CMD_STR;
	return TCL_ERROR;
    }

    Tcl_DStringInit(&resStr);

    while (fetch_ok) {

        Tcl_DStringGetResult(interp, &resStr);

        /* split the result columns left in interp->result */
	if (Tcl_SplitList(interp,Tcl_DStringValue(&resStr),
	                                    &colsCnt,&colsPtr) == TCL_ERROR) {
	   Tcl_AppendResult (interp, argv[0], ": split columns failed", 
			      (char *) NULL);
           Tcl_DStringFree(&resStr);
	   FREE_CMD_STR;
	   return TCL_ERROR;
	}

        /* build eval string from literals and columns */
        Tcl_DStringInit(&evalStr);
	eval_ptr = "";
	for (inum=0, icol=0; inum < num_str; inum++) {
	    if (icol < colnum && inum == colstr[icol].strnum) {
	        eval_ptr = Tcl_DStringAppend(&evalStr, " ", -1);
		if (colstr[icol].column == 0) {    /* col 0 is entire result */
		    eval_ptr = Tcl_DStringAppendElement(&evalStr,
						Tcl_DStringValue(&resStr));
                } else {
		    if (colstr[icol].column > colsCnt) {/* another sanity chk*/
			Tcl_ResetResult(interp);
			Tcl_AppendResult (interp, argv[0], 
			 ": column sanity failed on column sub",(char *) NULL);
	                Tcl_DStringFree(&evalStr); 	/* free eval string */
	                ckfree((char *) colsPtr); 	/* free split array */
                        Tcl_DStringFree(&resStr);
			FREE_CMD_STR;
			return TCL_ERROR;
		    }
		    eval_ptr = Tcl_DStringAppendElement(&evalStr,
					  colsPtr[colstr[icol].column - 1]);
		}
	        eval_ptr = Tcl_DStringAppend(&evalStr, " ", -1);
	        icol++;
	    } else {
	        eval_ptr = Tcl_DStringAppend(&evalStr, str[inum], -1);
	    }
	}

	/* set any remaining "tclvar colnum" pairs as tcl variables */
	if (argc >= 5) {
	    Tcl_DStringInit(&varStr);
	    parm_cnt = 4;
	    while (argc > parm_cnt + 1) {       /* always in pairs of two */
		p    =  argv[parm_cnt];          /* variable name */
		icol =  atoi(argv[parm_cnt+1]);  /* column number */
		/* Tcl_SetVar can muck with varname, so save it off */
		Tcl_DStringAppend(&varStr, p, -1);
		if (icol == 0) {
		    Tcl_SetVar(interp, Tcl_DStringValue(&varStr), 
			   Tcl_DStringValue(&resStr), 0);  /* row as list */
		} else {
		    if (icol <= colsCnt + 1) {
		        Tcl_SetVar(interp, Tcl_DStringValue(&varStr), 
			   colsPtr[icol-1], 0); 
		    } else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult (interp, argv[0], 
			 ": column sanity failed on tclvar bind",(char *) NULL);
	                Tcl_DStringFree(&evalStr); 	/* free eval string */
	                ckfree((char *) colsPtr); 	/* free split array */
                        Tcl_DStringFree(&resStr);
			FREE_CMD_STR;
			return TCL_ERROR;
		    }
		}
		parm_cnt += 2;
		Tcl_DStringSetLength(&varStr,0);
	    }

	    Tcl_DStringFree(&varStr); 	/* free var string */
	}

        tcl_rc = Tcl_Eval(interp, eval_ptr);	/* do it! */

	Tcl_DStringFree(&evalStr); 	/* free eval string */

	ckfree((char *) colsPtr); 	/* free split array */

	switch (tcl_rc) {		/* check on eval return code */
	  case TCL_ERROR:
	    Tcl_AppendResult (interp, ": eval failed while in ", argv[0], 
			      (char *) NULL);
            Tcl_DStringFree(&resStr);
	    FREE_CMD_STR;
	    return TCL_ERROR;
	    break;

	  case TCL_BREAK:		/* return sooner */
            Tcl_DStringFree(&resStr);
	    FREE_CMD_STR;
	    return TCL_OK;
	    break;

	  default:
	    break;
	}

	Tcl_ResetResult(interp);	/* reset interp result for next */
	Tcl_DStringSetLength(&resStr,0);
 
        /* next fetch */
        if (Oratcl_Fetch(clientData, interp, 2, argv) == TCL_ERROR) {
	    Tcl_AppendResult (interp, ": ", argv[0], ": orafetch failed", 
			      (char *) NULL);
            Tcl_DStringFree(&resStr);
	    FREE_CMD_STR;
	    return TCL_ERROR;
        }

    }

    Tcl_DStringFree(&resStr);
    FREE_CMD_STR;

    return TCL_OK;

}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Cols --
 *    Implements the oracols command:
 *    usage: oracols cur_handle 
 *	                
 *    results:
 *	latest column names as tcl list
 *      also set oramsg(collengths) and oramsg(coltypes) as tcl list
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_Cols (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    int     i = 0;
    ColBufs *col;
    char   *type_ptr;
    char    len_buf[ORA_BUFF_SIZE];
    char    typ_buf[ORA_BUFF_SIZE];
    char    prec_buf[ORA_BUFF_SIZE];
    char    scale_buf[ORA_BUFF_SIZE];
    char    buf2[ORA_MSG_SIZE];

    if ((hand = ora_prologue(interp, argc, argv, 2, " cur_handle")) == -1) {
	return TCL_ERROR;
    }


    len_buf[0]   = '\0';   /* initial null buffers */
    typ_buf[0]   = '\0';   
    prec_buf[0]  = '\0';
    scale_buf[0] = '\0';
    buf2[0]      = '\0';   

    for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {

        i++;

        sprintf(buf2, "%s", col->dbname);
	Tcl_AppendElement(interp,buf2);

        /* get the display length and append to "collengths" */
	/* remember that we added one to disp_size in parse, so subtract it */
	sprintf(buf2, (i>1) ? " %u" : "%u", (int) col->disp_size - 1);
	strcat(len_buf,buf2);

	/* get the column type and append to "coltypes" */
	switch (col->dbtype) {
	    case 1:
#ifdef VERSION7
		type_ptr = "varchar2";
#else
		type_ptr = "char";
#endif
		break;
	    case 2:
		type_ptr = "number";
		break;
	    case 8:
		type_ptr = "long";
		break;
	    case 11:
		type_ptr = "rowid";
		break;
	    case 12:
		type_ptr = "date";
		break;
	    case 23:
		type_ptr = "raw";
		break;
	    case 24:
		type_ptr = "long_raw";
		break;
	    case 96:
		type_ptr = "char";
		break;
	    case 102:
		type_ptr = "cursor";
		break;
	    case 105:
		type_ptr = "mlslabel";
		break;
	    case 106:
		type_ptr = "raw_mlslabel";
		break;
	    default:
		type_ptr = "unknown";
		break;
	}
	sprintf(buf2, (i>1) ? " %s" : "%s",type_ptr);
	strcat(typ_buf,buf2);

        /* format precision and scale for numeric data */
	if (col->dbtype == 2) {
	  sprintf(buf2, (i>1) ? " %d" : "%d", col->prec);
	} else {
	  sprintf(buf2, (i>1) ? " %s" : "%s", "{}");
	}
	strcat(prec_buf,buf2);

	if (col->dbtype == 2) {
	  sprintf(buf2, (i>1) ? " %d" : "%d", col->scale);
	} else {
	  sprintf(buf2, (i>1) ? " %s" : "%s", "{}");
	}
	strcat(scale_buf,buf2);


    }

    if (i > 0) {
        Tcl_SetVar2(interp, OraMsgArray, "collengths", len_buf,TCL_GLOBAL_ONLY);
        Tcl_SetVar2(interp, OraMsgArray, "coltypes",   typ_buf,TCL_GLOBAL_ONLY);
        Tcl_SetVar2(interp, OraMsgArray, "colprecs",  prec_buf,TCL_GLOBAL_ONLY);
        Tcl_SetVar2(interp, OraMsgArray, "colscales",scale_buf,TCL_GLOBAL_ONLY);
    }


    return TCL_OK;
}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Cancel --
 *    Implements the oracancel command:
 *    usage: oracancel  cur_handle 
 *	                
 *    results:
 *	null string
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_Cancel (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;


    if ((hand = ora_prologue(interp, argc, argv, 2, " cur_handle")) == -1) {
	return TCL_ERROR;
    }

    ocan(OraCurs[hand].cda);

    get_ora_err(interp, hand);

    free_cols(OraCurs[hand].col_list);
    OraCurs[hand].col_list   = NULL;
    free_cols(OraCurs[hand].bind_list);
    OraCurs[hand].bind_list   = NULL;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = 0;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;


    return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_PLexec --
 *    Implements the oraplexec command:
 *    usage: oraplexec cur_handle pl_block [ :varname value ]  [ .... ]
 *	                
 *    results:
 *	return parms in tcl list form
 *      TCL_OK - proc executed
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_PLexec (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{

    int         hand;
    int         parm_cnt;
    ColBufs    *new_col_head = NULL;
    ColBufs    *new_col = NULL;
    ColBufs    *last_col = NULL;
    int         cursor_hand = -1;

    /* prologue */
    if ((hand = ora_prologue(interp, argc, argv, 3, 
	 " cur_handle pl_block [ :varname value ] ...")) == -1) {
	return TCL_ERROR;
    }

    /* cancel any pending usage of cursor */
    ocan(OraCurs[hand].cda);

    /* free existing columns, if any */
    free_cols(OraCurs[hand].col_list);
    OraCurs[hand].col_list   = NULL;
    free_cols(OraCurs[hand].bind_list);
    OraCurs[hand].bind_list   = NULL;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = ORA_CACHE;

    /* parse pl_block */
    oparse(OraCurs[hand].cda, argv[2], ((long) -1), DEF_FLAG, LNG_FLAG);

    if (OraCurs[hand].cda->rc != 0) {
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oparse failed ",
	                (char *) NULL);
	return TCL_ERROR;
    } else {
        /* clear peo */
	Tcl_SetVar2(interp, OraMsgArray, "peo",  "0", TCL_GLOBAL_ONLY);
    }

    /* bind :colon_parms following arg, alloc large enough return space (?)*/
    parm_cnt = 3;      

    /* only alloc new col if one or more valid arg for :var */
    if (argc > parm_cnt + 1) {        
        new_col_head = alloc_col();
        if (new_col_head == NULL) {
            Tcl_AppendResult(interp, argv[0], " cannot malloc new col ",
			     (char *) NULL);
	    return TCL_ERROR;
        }
        new_col      = new_col_head;
        last_col     = new_col_head;
    } else {
	new_col_head = NULL;
    }

    while (argc > parm_cnt + 1) {       /* always in pairs of two */

	/* make sure bind variable name has a leading ':' */
	if (*argv[parm_cnt] != ':') {
	    free_cols(new_col_head);
	    OraCurs[hand].col_list = NULL;
	    Tcl_AppendResult(interp, argv[0], " bind variable ", argv[parm_cnt],
			     " does not begin with ':' ", (char *) NULL);
	    return TCL_ERROR;
	}

	new_col->disp_size  = ORA_BUFF_SIZE;
	new_col->col_data   = ckalloc(new_col->disp_size + 1);
	if (new_col->col_data == NULL) {
	    free_cols(new_col_head);
	    OraCurs[hand].col_list = NULL;
            Tcl_AppendResult(interp, argv[0], 
			     " cannot malloc new col data for ", argv[parm_cnt],
			     (char *) NULL);
	    return TCL_ERROR;
	} else {
#ifdef NONBLOCK_CURSOR
	    /* check for cursor binding */
	    if ((cursor_hand = get_ora_handle(argv[parm_cnt+1])) >= 0) {
		/* check if cursor same as command handle */
		if (hand == cursor_hand) {
		    /* error */
	    	    free_cols(new_col_head);
	    	    OraCurs[hand].col_list = NULL;
            	    Tcl_AppendResult(interp, argv[0], 
			     " bind cursor for ", argv[parm_cnt],
			     " same as cursor_handle",
			     (char *) NULL);
	    	    return TCL_ERROR;
		}
		/* check if cursor from same login lda */
		if (get_ora_lda_handle(argv[parm_cnt+1]) != 
		                             get_ora_lda_handle(argv[1]) ) {
		    /* error */
	    	    free_cols(new_col_head);
	    	    OraCurs[hand].col_list = NULL;
            	    Tcl_AppendResult(interp, argv[0], 
			     " bind cursor for ", argv[parm_cnt],
			     " not from same login handle as cursor_handle",
			     (char *) NULL);
	    	    return TCL_ERROR;
		}
		/* check if cursor handle was previously opened */
		if (!OraCurs[cursor_hand].cur_in_use) {
		    /* error */
	    	    free_cols(new_col_head);
	    	    OraCurs[hand].col_list = NULL;
            	    Tcl_AppendResult(interp, argv[0], 
			     " bind cursor for ", argv[parm_cnt],
			     " not previously opened",
			     (char *) NULL);
	    	    return TCL_ERROR;
		}
		/* close open cursor, but don't free memory for cda */
    		oclose(OraCurs[cursor_hand].cda);
		bzero(OraCurs[cursor_hand].cda, sizeof(cda_def));
    		free_cols(OraCurs[cursor_hand].col_list);
    		OraCurs[cursor_hand].col_list   = NULL;
    		free_cols(OraCurs[hand].bind_list);
    		OraCurs[hand].bind_list         = NULL;
    		OraCurs[cursor_hand].cache_size = ORA_CACHE;
    		OraCurs[cursor_hand].row_num    = 0;
    		OraCurs[cursor_hand].fetch_end  = 1;
    		OraCurs[cursor_hand].fetch_cnt  = 0;
		OraCurs[cursor_hand].oexec_done = 0;
		OraCurs[cursor_hand].first_fetch= 0;
		OraCurs[cursor_hand].async      = 0;
		/* save cursor handle string name */
	        strncpy(new_col->col_data, argv[parm_cnt + 1], ORA_BUFF_SIZE-1);
		/* save cursor handle */
		new_col->bind_cursor            = cursor_hand;
	    } else {
		/* not a cursor, save bind value */
	        strncpy(new_col->col_data, argv[parm_cnt + 1], ORA_BUFF_SIZE-1);
		new_col->bind_cursor = -1;
	    }
#else
	    strncpy(new_col->col_data, argv[parm_cnt + 1], ORA_BUFF_SIZE - 1);
	    new_col->bind_cursor = -1;
#endif
	}

	new_col->rlen[0] = 0;
	new_col->rcode[0] = 0;

        /* if oracols is called after the exec, give it some info */

	if (cursor_hand == -1) {
	    /* regular string data type */
	    new_col->dbtype = 1;   /* internal type char/varchar*/
	    strncpy(new_col->dbname,argv[parm_cnt],(sizeof new_col->dbname)-1);

            obndrv( OraCurs[hand].cda, argv[parm_cnt], -1, new_col->col_data,
		ORA_BUFF_SIZE, EXT_STRING_TYPE, -1, NULL, NULL, -1, -1);
        } else {
	    /* cursor data type */
	    new_col->dbtype = INT_CURSOR_TYPE; 
	    strncpy(new_col->dbname,argv[parm_cnt], (sizeof new_col->dbname)-1);

            obndrv( OraCurs[hand].cda, argv[parm_cnt], -1, 
		(char *) OraCurs[cursor_hand].cda,  
		(sizeof (cda_def)), INT_CURSOR_TYPE, -1, NULL, NULL, -1, -1);
	}

	if (OraCurs[hand].cda->rc != 0) {
	    get_ora_err(interp, hand);
	    free_cols(new_col_head);
	    OraCurs[hand].col_list = NULL;
            Tcl_AppendResult(interp, argv[0], " bind failed for ",
			     argv[parm_cnt], (char *) NULL);
	    return TCL_ERROR;
	}

	parm_cnt += 2;

        if (argc > parm_cnt + 1) {        /* more args? alloc new colbufs */
	    last_col           = new_col;
	    new_col            = alloc_col();
	    if (new_col == NULL) {
		free_cols(new_col_head);
	        OraCurs[hand].col_list = NULL;
		Tcl_AppendResult(interp, argv[0], " cannot malloc new col ",
				 (char *) NULL);
		return TCL_ERROR;
	    }
	    last_col->next_buf = new_col;
	}

    }
     
    OraCurs[hand].col_list  = new_col_head;
    OraCurs[hand].fetch_end = 0;        /* let append_cols work */
    OraCurs[hand].fetch_cnt = 0;        
    OraCurs[hand].row_num   = 0;

    /* exec cursor */
    oexec(OraCurs[hand].cda);

    get_ora_err(interp, hand);

    /* for all cursor_hands, parse results */

    new_col = new_col_head;
    while (new_col != NULL) {
        if (new_col->dbtype == INT_CURSOR_TYPE) {
	    cursor_hand = new_col->bind_cursor;
	    if (cursor_hand >= 0) {
		if (parse_columns(interp, cursor_hand) == -1) {
		    get_ora_err(interp, cursor_hand);
		    Tcl_AppendResult(interp, argv[0],
		      " parse_columns failed for cursor var ", new_col->dbname,
		       (char *) NULL);
		    return TCL_ERROR;
		}
		OraCurs[cursor_hand].cda->rpc = 0; /* cursors lie about rpc */
  	        OraCurs[cursor_hand].row_num = OraCurs[cursor_hand].cache_size;
  	        OraCurs[cursor_hand].fetch_end = 0;
  	        OraCurs[cursor_hand].fetch_cnt = 0; 
	    }
	}
	new_col = new_col->next_buf;
    }

    /* get results, same as orafetch */

    append_cols(interp, hand);
   
    /* set cursor data */
    OraCurs[hand].fetch_end  = 0;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = 0;

    /* don't free col_list yet; allow oracols to fetch info */


    return TCL_OK;
}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Commit --
 *    Implements the oracommit command:
 *    usage: oracommit lda_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - transactions commited
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_Commit (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    char    buf[ORA_MSG_SIZE];

    /* can't use ora_prologue, oracommit just uses an lda handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }

    Tcl_SetVar2(interp, OraMsgArray, "handle",  argv[1], TCL_GLOBAL_ONLY);

    ocom(OraLdas[hand].lda); 

    get_lda_err(interp, hand);

    return TCL_OK;
}



/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Roll --
 *    Implements the oraroll command:
 *    usage: oraroll lda_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - transactions rolled back
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_Roll (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    char    buf[ORA_MSG_SIZE];

    /* can't use ora_prologue, oraroll just uses an lda handle */

    clear_msg(interp);

    if (argc < 2) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }

    Tcl_SetVar2(interp, OraMsgArray, "handle",  argv[1], TCL_GLOBAL_ONLY);

    orol(OraLdas[hand].lda); 

    get_lda_err(interp, hand);


    return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Autocom --
 *    Implements the oraautocom command:
 *    usage: oraroll lda_handle on|off
 *	                
 *    results:
 *	null string
 *      TCL_OK - auto commit set on or off
 *      TCL_ERROR - wrong # args, or handle not opened,
 */

Oratcl_Autocom (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    char    buf[ORA_MSG_SIZE];

    /* can't use ora_prologue, oraautocom just uses an lda handle */

    clear_msg(interp);

    if (argc < 3) {
	Tcl_AppendResult (interp, "wrong # args: ", argv[0],
			  " lda_handle on|off ", (char *) NULL);
	return TCL_ERROR;
    }

    if ((hand = get_ora_lda_handle(argv[1])) == -1) {
	Tcl_AppendResult (interp, argv[0], ": lda_handle ", argv[1],
			  " not valid ", (char *) NULL);
	return TCL_ERROR;
    }


    Tcl_SetVar2(interp, OraMsgArray, "handle",  argv[1], TCL_GLOBAL_ONLY);

    if (strncasecmp(argv[2],"on",2) == 0) {   /* case insensitive compare */
        ocon(OraLdas[hand].lda); 
    } else {
        ocof(OraLdas[hand].lda); 
    }

    get_lda_err(interp, hand);

    return TCL_OK;
}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Wrlong --
 *    Implements the orawritelong command:
 *    usage: orawritelong cur_handle rowid table column file
 *      where: cur_handle = open cursor handle
 *             rowid  = rowid of row to retrieve
 *             table  = table name
 *             column = column name of long or long raw
 *             file   = file in which to get text 
 *
 *    orawritelong should be preceded by a select that returns a rowid
 *	                
 *    results:
 *	null string
 *      TCL_OK - handle is closed
 *      TCL_ERROR - wrong # args, or handle not opened, file not found,
 */


Oratcl_Wrlong (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    int     fd;
    long    filesize;
    char    buf[ORA_MSG_SIZE];
    char   *data_ptr;
    struct  stat stat_buf;
    ColBufs *new_col;

    if ((hand = ora_prologue(interp, argc, argv, 6, 
	    " cur_handle rowid table column filename ")) == -1) {
	return TCL_ERROR;
    }


    fd = open(argv[5], O_RDONLY | _O_BINARY, 0);
    if (fd < 0) {
        Tcl_AppendResult (interp, argv[0], ": file ", argv[5],
		     " cannot be opened for reading ", (char *) NULL);
        return TCL_ERROR;
    }

    fstat(fd, &stat_buf);
    filesize = stat_buf.st_size;

    /* alloc memory for file, and read whole file */
    /* this sucks, oracle should have a "write long chunk" oci call */
    /* oops, 7.3 does now have 'piecewise' write routines, time to */
    /* put this in next version */
    if ((data_ptr = ckalloc(filesize)) == NULL) {
	close(fd);
        Tcl_AppendResult (interp, " cannot malloc memory for file ", 
				 (char *) NULL);
        return TCL_ERROR;
    }

    if (filesize != read(fd,data_ptr,filesize)) {
	close(fd);
	ckfree(data_ptr);
        Tcl_AppendResult (interp, " cannot read file into memory ", 
				 (char *) NULL);
        return TCL_ERROR;
    }
    close(fd);

    /* cancel any pending usage of cursor */
    ocan(OraCurs[hand].cda);

    /* free existing columns, if any */
    free_cols(OraCurs[hand].col_list);
    OraCurs[hand].col_list   = NULL;
    free_cols(OraCurs[hand].bind_list);
    OraCurs[hand].bind_list  = NULL;
    OraCurs[hand].fetch_end  = 1;
    OraCurs[hand].fetch_cnt  = 0;
    OraCurs[hand].cache_size = ORA_CACHE;
    OraCurs[hand].row_num    = ORA_CACHE;

    /* compose select stmt */

    sprintf(buf,"select %s from %s where rowid = '%s'",argv[4],argv[3],argv[2]);

    /* parse sql stmt */
    oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

    if (OraCurs[hand].cda->rc != 0) {
	ckfree(data_ptr);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oparse failed for long select",
	                (char *) NULL);
	return TCL_ERROR;
    } else {
        /* clear peo */
   	Tcl_SetVar2(interp, OraMsgArray, "peo",  "0", TCL_GLOBAL_ONLY);
    }


    /* get description of column so we know which datatype we're dealing with */

    new_col = alloc_col();
    if (new_col == NULL) {
	ckfree(data_ptr);
        Tcl_AppendResult(interp, argv[0], " cannot malloc new col ",
                         (char *) NULL);
        return TCL_ERROR;
    }

    new_col->disp_size  = 0;

    new_col->rlen[0] = 0;

    new_col->rcode[0] = 0;


    odescr(OraCurs[hand].cda, 1, &(new_col->dbsize),&(new_col->dbtype),
          &(new_col->dbname[0]), &(new_col->dbname_len), &(new_col->disp_size),
          &(new_col->prec), &(new_col->scale), &(new_col->nullok)   );


    if (OraCurs[hand].cda->rc != 0) {
	ckfree(data_ptr);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " odescr error ",
	                (char *) NULL);
	return TCL_ERROR;
    }


    /* compose update stmt */

    sprintf(buf,"update %s set %s = :1 where rowid = '%s' ",
		 argv[3],argv[4],argv[2]);

    /* parse sql stmt */
    oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

    if (OraCurs[hand].cda->rc != 0) {
	ckfree(data_ptr);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oparse failed for long update",
	                (char *) NULL);
	return TCL_ERROR;
    } else {
        /* clear peo */
        Tcl_SetVar2(interp, OraMsgArray, "peo",  "0", TCL_GLOBAL_ONLY);
    }

    /* bind filearea to column */

    obndrn( OraCurs[hand].cda, 1, data_ptr,
		filesize, new_col->dbtype, -1, NULL, NULL, -1, -1);
       
    /* exec stmt */

    oexec(OraCurs[hand].cda);
    if (OraCurs[hand].cda->rc != 0) {  /* oops, problem */
	ckfree(data_ptr);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oexec error ",
	                (char *) NULL);
	return TCL_ERROR;
    }
    if (OraCurs[hand].cda->rpc != 1) {  /* not found, row process != 1 */
	ckfree(data_ptr);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " row not found ",
	                (char *) NULL);
	return TCL_ERROR;
    }

    /* free mem */
    ckfree(data_ptr);
    free_cols(new_col);

    get_ora_err(interp, hand);

    /* return total bytes sent */
    sprintf(buf,"%d",filesize);
    Tcl_SetResult (interp,buf,TCL_VOLATILE);

    return TCL_OK;

}




/*
 *----------------------------------------------------------------------
 *
 * Oratcl_Rdlong --
 *    Implements the orareadlong command:
 *    usage: orareadlong cur_handle rowid table column file 
 *
 *    results:
 *	null string
 *      TCL_OK - handle is closed
 *      TCL_ERROR - wrong # args, or handle not opened, can't open file,
 *                  or other error in text/image handling
 */


Oratcl_Rdlong (clientData, interp, argc, argv)
    ClientData   clientData;
    Tcl_Interp  *interp;
    int          argc;
    char       **argv;
{
    int     hand;
    int     fd;
    int     s;
    int     total_bytes = 0;
    char    buf[ORA_MSG_SIZE];
    char    buf2[ORA_MSG_SIZE];
    char   *data_ptr;
    long    long_size = MAX_LONG_SIZE;
    unsigned long bytes_fetched = 0;
    long     offset = 0;
    ColBufs *new_col;
    unsigned short   fsize;
    short   fcode;
    int     rc;


    if ((hand = ora_prologue(interp, argc, argv, 6, 
	    " cur_handle rowid table column filename")) == -1) {
	return TCL_ERROR;
    }


    fd = open(argv[5], O_WRONLY | O_TRUNC | O_CREAT | _O_BINARY, 0644);
    if (fd == -1) {
        Tcl_AppendResult (interp, argv[0], ": file ", argv[5],
		     " could not be opened for writing ", (char *) NULL);
        return TCL_ERROR;
    }

    /* compose select stmt */

    sprintf(buf,"select %s from %s where rowid = '%s'",argv[4],argv[3],argv[2]);

    /* parse sql stmt */
    oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

    if (OraCurs[hand].cda->rc != 0) {
	close(fd);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oparse failed for select long",
	                (char *) NULL);
	return TCL_ERROR;
    } else {
        /* clear peo */
        Tcl_SetVar2(interp, OraMsgArray, "peo",  "0", TCL_GLOBAL_ONLY);
    }

    /* get description of column so we know which datatype we're dealing with */

    new_col = alloc_col();
    if (new_col == NULL) {
	close(fd);
        Tcl_AppendResult(interp, argv[0], " cannot malloc new col ",
                         (char *) NULL);
        return TCL_ERROR;
    }

    new_col->rlen[0] = 0;

    new_col->rcode[0] = 0;

    odescr(OraCurs[hand].cda, 1, &(new_col->dbsize),&(new_col->dbtype),
          &(new_col->dbname[0]), &(new_col->dbname_len), &(new_col->disp_size),
          &(new_col->prec), &(new_col->scale), &(new_col->nullok)   );

    if (OraCurs[hand].cda->rc != 0) {
	close(fd);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " odescr error ",
	                (char *) NULL);
	return TCL_ERROR;
    }

    /* define a one byte fetch buffer now, dbsize is erroneous until */
    /* first fetch is done, then do the whole process again */
    odefin(OraCurs[hand].cda, 1, buf2, 
	       (int) 1, new_col->dbtype, 0, (short *) 0, 
	       NULL, 0, 0, new_col->rlen, new_col->rcode);

    /* exec and fetch to find out actual length of column */
    oexec(OraCurs[hand].cda);

    ofetch(OraCurs[hand].cda);

    if (OraCurs[hand].cda->rc == NO_DATA_FOUND) {  /* not found */
	close(fd);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " row not found for long",
	                (char *) NULL);
	return TCL_ERROR;
    }

    if (OraCurs[hand].cda->rc != COL_TRUNCATED &&
                  OraCurs[hand].cda->rc != 0) {          /* problem */
	close(fd);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " oexec/ofetch failed",
	                (char *) NULL);
	return TCL_ERROR;
    }

#ifdef VERSION7
    
    /* at this point, the version 7 oflng() can be used since we */
    /* have retrieved the long column */

    if ((data_ptr = ckalloc(LONG_BUFF_SIZE)) == NULL) {
	close(fd);
	free_cols(new_col);
        Tcl_AppendResult (interp, " cannot malloc memory for column fetch", 
				 (char *) NULL);
        return TCL_ERROR;
    }

    rc = oflng(OraCurs[hand].cda, 1, data_ptr, LONG_BUFF_SIZE, 
	       new_col->dbtype, &bytes_fetched, offset);	
    
    while (bytes_fetched > 0 && rc == 0) {

      write(fd, data_ptr, bytes_fetched);

      offset += bytes_fetched;

      rc = oflng(OraCurs[hand].cda, 1, data_ptr, LONG_BUFF_SIZE, 
	         new_col->dbtype, &bytes_fetched, offset);	
    }

    /* save total number of bytes fetched */
    long_size = offset;

    /* end of v7 specific code */
    
#else 

    /* continue with v6 code */


    /* describe again to find actual size of long column returned */

    odsc(OraCurs[hand].cda, 1, &(new_col->dbsize),
	 &fsize, &fcode, &(new_col->dbtype),
         &(new_col->dbname[0]), &(new_col->dbname_len), &(new_col->disp_size));

    /* malloc an area to hold the column */
    long_size = fsize;

    if ((data_ptr = ckalloc(long_size)) == NULL) {
	close(fd);
	free_cols(new_col);
        Tcl_AppendResult (interp, " cannot malloc memory for column fetch", 
				 (char *) NULL);
        return TCL_ERROR;
    }

    /* now defin, exec, fetch again */

    odefin(OraCurs[hand].cda, 1, data_ptr, 
	       (int) long_size, new_col->dbtype, 0, (short *) 0,
	       NULL, 0, 0, new_col->rlen, new_col->rcode);

    oexec(OraCurs[hand].cda);

    ofetch(OraCurs[hand].cda);
	
    if (long_size != write(fd,data_ptr,long_size)) {
	ckfree(data_ptr);
	close(fd);
	free_cols(new_col);
	get_ora_err(interp, hand);
        Tcl_AppendResult(interp, argv[0], " could not write data ",
	                (char *) NULL);
	return TCL_ERROR;
    }

    /* end of version 6 code */

#endif

    /* common cleanup & return code */

    close(fd);
    ckfree(data_ptr);
    free_cols(new_col);

    /* return total bytes sent */
    sprintf(buf,"%ld",long_size);
    Tcl_SetResult (interp,buf,TCL_VOLATILE);

    return TCL_OK;

}


/* finis */
