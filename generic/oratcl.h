/*
 *	oratcl.h
 */

#ifndef __oratcl__h 
#define __oratcl__h

#include "tcl.h"

/* 
 * simple memory debugging, to make sure we alloc and free the same amount 
 */

#ifdef ORATCL_MEM_DEBUG
#include <stdio.h>
#undef ckalloc
#undef ckfree
#undef ckrealloc

static long my_alloc = 0; /* alloc'ed in this module, free'ed in this module */
static long my_realloc = 0; /* alloc'ed in this module, free'ed in this module */
static long my_tcl_alloc= 0;    /* alloc'ed by tcl, free'ed in this module */
static long my_free  = 0;       /* free'ed in this module */
FILE *my_file;          /* file to dump stats */
#ifdef ORATCL_MEM_FULL_DEBUG
#define WHERE_ALLOC fprintf(my_file,"ckalloc  %d\n",__LINE__),
#define WHERE_REALLOC fprintf(my_file,"ckrealloc  %d\n",__LINE__),
#define WHERE_FREE   fprintf(my_file,"ckfree   %d\n",__LINE__),
#else
#define WHERE_ALLOC
#define WHERE_REALLOC
#define WHERE_FREE
#endif

#define ckalloc(x) (WHERE_ALLOC my_alloc++, Tcl_Alloc(x))
#define ckrealloc(p,s) (WHERE_ALLOC my_realloc++, Tcl_Realloc((p),(s)))
#define ckfree(x)  (WHERE_FREE   my_free++,  Tcl_Free(x))

#define MY_STATS_INIT my_file=fopen("alloc.stats","w")
#define MY_STATS_DUMP fprintf(my_file,\
  "ckalloc   = %8ld\nckrealloc = %8ld\ntcl alloc = %8ld\nall alloc = %8ld\nckfree    = %8ld\n",\
  my_alloc,my_realloc,my_tcl_alloc,my_alloc+my_tcl_alloc,my_free);fclose(my_file)
#else
static long my_alloc = 0;
static long my_realloc = 0;
#define MY_STATS_INIT my_alloc=0
#define MY_STATS_DUMP my_alloc=my_alloc
#endif


/* _ANSI_ARGS_ should be defined by tcl.h; ignore if not defined */
#ifndef _ANSI_ARGS_
#define _ANSI_ARGS_() ()
#endif


/* various limits for arrays of structures, default buffer sizes */
#define ORATCLLDAS      50      /* default number of ldas available */
#define ORATCLSTMS      200     /* default number of statement handles available */
#define ORA_BUFF_SIZE   4096    /* conversion buffer size for various needs*/
#define ORA_MSG_SIZE    1000    /* oracle error message max size*/
#define ORA_BIND_SIZE   255     /* conversion buffer size for binding */
#define ORA_CACHE       10      /* number of rows to fetch each time */


/* version 7 db / oci 2.0 oparse() has some options */
/* DEF_FLAG should be IMMED_PARSE, otherwise oparse will lie about ft */
#define IMMED_PARSE     0
#define DEFER_PARSE     1
#define DEF_FLAG        IMMED_PARSE

#define LNG_FLAG        NORM_BEHAVIOR   /* normal treatment of data types */

/* append_cols defines */
#define NO_DATA_FOUND   1403    /* oracle error # no data for this fetch */
#define COL_TRUNCATED   1406    /* oracle error # column truncated */
#define NUMBER_TYPE     2       /* oracle internal data type for number */

/* pl exec error */
#define PL_EXEC_ERR     6503    /* oracle error # pl block error */

#define BUF_LONG_SIZE	32768
#define MAX_LONG_SIZE	2147483647

/* ColBufs holds information and data of SELECT columns */
struct ColBufs {
    struct ColBufs  	*next;	 		/* pointer to next ColBufs in list */
    ub2			type;			/* column type */
    ub2			size;        		/* column internal size */
    text        	*name;			/* column name */
    unsigned long	namesz; 		/* column name length */
    char		*valuep;		/* Column data pointer */
    unsigned long	valuesz;		/* column display size */
    ub1			prec;			/* precision of numeric */
    sb1			scale;			/* scale of numeric */
    OCIDefine   	*defnp;			/* define pointer */
    OCIBind		*bindp;			/* bind pointer */
    int			colnum;			/* column number */
    ub1			isnull; 		/* ok if null */
    int         	bind_cursor;    	/* if cursor variable bound during oraplexec*/
    sb2			indp[ORA_CACHE];	/* null indicator pointer */
    ub2			rlenp[ORA_CACHE];	/* actual column length */
    ub2			rcodep[ORA_CACHE];	/* actual column code */
};
typedef struct ColBufs ColBufs;


/* OraTclLdas - oracle logon struct et.al. */
typedef struct OraTclLdas {     /* struct for lda entries */
	Tcl_Interp		*interp;        /* Tcl interp assigned */
	OCIEnv			*envhp;
	OCIError		*errhp;
	OCISvcCtx		*svchp;
	OCIServer		*srvrp;
	int			lda_in_use;     /* if this entry is opened */
	int			autocom;	/* if lda is in autocommit mode */
} OraTclLdas;

/* OraTclLdas - oracle statement struct */
typedef struct OraTclStms {     /* struct for statement entries */
    int         stm_in_use;     /* if this entry is opened */
    int         lda_num;        /* entry in lda table for this cursor */
    OCIStmt    *stmhp;            /* Oracle Statment Handle Area */
    ColBufs    *col_list;       /* list of select columns */
    ColBufs    *bind_list;      /* list of bind variables/values */
    int         cache_size;     /* cache size of this cursor */
    int         row_num;        /* current row in cache to fetch */
    int         fetch_end;      /* true when fetches exhausted */
    ub4         fetch_cnt;      /* total number of rows fetched so far */
    ub2		sqltype;	/* the sql type attribute */
    int		append_cnt;	/* total number of rows appended so far */
    int         oexec_done;     /* if oexec finished for async cursor */
    int         first_fetch;    /* if fetch has been performed by orapoll */
} OraTclStms;

/* static tables for lda & cda */
static OraTclLdas   OraLdas[ORATCLLDAS];
static OraTclStms   OraStms[ORATCLSTMS];

/* quick fetch flag */
static int  fetch_ok;

static char *OraHandlePrefix = "oratcl";  /* prefix used to identify handles*/
/* lda handles are:  prefix , lda index          e.g.  oratcl0    */
/* stm handles are:  lda handle , '.', cur index e.g.  oratcl0.0  */
/* a statement handle could be passed to a proc that needs an lda handle */

static int      oColslen = 0;
static Tcl_Obj  **oColsv = NULL;

#define COL_INC 10
struct colsubd {
        int     column;         /* column number index */
        char    *strpos;        /* str location */
        int     strlen;         /* str length */
} *ColSubs;
static int      ColSubsLen;

/* tcl objs for oramsg array name and all indices */
static Tcl_Obj  *OraMsgArray;

static Tcl_Obj  *OMV_null;
static Tcl_Obj  *OMV_zero;
static Tcl_Obj  *OMV_oraver;

static Tcl_Obj  *OM_errortxt;
static Tcl_Obj  *OM_handle;
static Tcl_Obj  *OM_maxlong;
static Tcl_Obj  *OM_nullvalue;
static Tcl_Obj  *OM_version;
static Tcl_Obj  *OM_rc;
static Tcl_Obj  *OM_rows;
static Tcl_Obj  *OM_peo;
static Tcl_Obj  *OM_rowid;
static Tcl_Obj  *OM_sqlfunc;
static Tcl_Obj  *OM_ocifunc;
static Tcl_Obj  *OM_ociinfo;
static Tcl_Obj  *OM_collengths;
static Tcl_Obj  *OM_coltypes;
static Tcl_Obj  *OM_colprecs;
static Tcl_Obj  *OM_colscales;
static Tcl_ObjType      *tListObjType;

#endif
