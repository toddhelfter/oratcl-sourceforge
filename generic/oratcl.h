#ifndef __oratcl__h 
#define __oratcl__h

#include "tcl.h"

/*
	TMH NEED TO PICK 6,7,or 8
*/

/* support for version 6 or version 7; if not 7 assume 6  */
#ifndef VERSION7
#ifndef VERSION6
#define VERSION6
#endif
#endif

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


/* 
 * 64 bit architectures need larger hda size and different cda struct
 */

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
   unsigned short ft;           /* function type */
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
   unsigned short ft;           /* function type */
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


/* 
 * prototypes for oci function
 */

#ifdef VERSION7

/* version 7 has a few extra functions */

int odescr _ANSI_ARGS_((struct cda_def *, int, unsigned long *, short *, char *,
         unsigned long *, unsigned long *, short *, short *, short *));

int oflng _ANSI_ARGS_((struct cda_def *, int, char *, long, int,
         unsigned long *, long));

int oparse _ANSI_ARGS_((struct cda_def *, char *, long, int, unsigned long));

#else

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

int oopen _ANSI_ARGS_((struct cda_def *, struct lda_def *, char *, int, int, char *, int));

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
#define ORATCLLDAS      50      /* default number of ldas available */
#define ORATCLCURS      100     /* default number of curs available */
#define ORA_HOST_AREA   HDA_SIZE /* Oracle host data area length */
#define ORA_BUFF_SIZE   4096    /* conversion buffer size for various needs*/
#define ORA_MSG_SIZE    1000    /* oracle error message max size*/
#define ORA_BIND_SIZE   255     /* conversion buffer size for binding */
#define ORA_CACHE       10      /* number of rows to fetch each time */

/* parse_cols defines */
#define NO_MORE_COLUMNS 1007    /* oracle error code # during odescr */
#define EXT_STRING_TYPE 5       /* oracle external data type for string */
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
#define LNG_FLAG        NORM_BEHAVIOR   /* normal treatment of data types */



/* append_cols defines */
#define OUT_OF_SEQUENCE 1002    /* oracle error # fetch out of sequence */
#define NO_STMT_PARSED  1003    /* oracle error # no statement parsed */
#define NO_DATA_FOUND   1403    /* oracle error # no data for this fetch */
#define NULL_VALUE      1405    /* oracle error # column returned null */
#define COL_TRUNCATED   1406    /* oracle error # column truncated */
#define NUMBER_TYPE     2       /* oracle internal data type for number */
#define LONG_TYPE       8       /* oracle internal data type for long   */
#define LONGRAW_TYPE    24      /* oracle internal data type for long raw */

/* pl exec error */
#define PL_EXEC_ERR     6503    /* oracle error # pl block error */




/* db long column max size */
#ifdef VERSION6
#define MAX_LONG_SIZE   65536           /* v6 */
#else
#define MAX_LONG_SIZE   2147483647      /* v7 */
#endif

#define LONG_BUFF_SIZE  32768   /* chunks to get via oflng() */




/* ColBufs holds information and data of SELECT columns */

struct ColBufs {
    struct ColBufs  *next_buf;  /* pointer to next ColBufs in list */
    short       dbtype;         /* column type */
    char        dbname[256];    /* column name */
#ifdef VERSION7
    unsigned long
#else
    unsigned short
#endif
                dbname_len,     /* column name length */
                disp_size,      /* column display size */
                dbsize;         /* column internal size */

    short       prec;           /* precision of numeric */
    short       scale;          /* scale of numeric */
    short       nullok;         /* if null ok */
    long        col_len;        /* length of column data */
    char       *col_data;       /* pointer to acutal column data */
    int         bind_cursor;    /* if cursor variable bound during oraplexec*/
    unsigned short rlen[ORA_CACHE];       /* actual column length */
    unsigned short rcode[ORA_CACHE];      /* actual column code */
};

typedef struct ColBufs ColBufs;


/* OraTclLdas - oracle logon struct et.al. */

typedef struct OraTclLdas {     /* struct for lda entries */
    int         lda_in_use;     /* if this entry is opened */
    lda_def    *lda;            /* Oracle Logon Data Area */
    char       *hda;            /* Oracle Host Data Area */
    int         async;          /* if lda is in non-block mode */
    Tcl_Interp  *interp;        /* Tcl interp assigned */
} OraTclLdas;

/* OraTclCurs - oracle cursor + ColBufs head list ptr */

typedef struct OraTclCurs {     /* struct for cursor entries */
    int         cur_in_use;     /* if this entry is opened */
    int         lda_num;        /* entry in lda table for this cursor */
    cda_def    *cda;            /* Oracle Cursor Area */
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


#ifndef VERSION7DB
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

static OCIEnv     *p_env[ORATCLLDAS];
static OCIError   *p_err[ORATCLLDAS];
static OCISvcCtx  *p_svc[ORATCLLDAS];

#define OCI_HTYPE_ERROR 2                                    /* error handle */
#define OCI_HTYPE_SVCCTX 3                                 /* service handle */
#endif

#endif

