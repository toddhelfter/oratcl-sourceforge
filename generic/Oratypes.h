/* Copyright (c) Oracle Corporation 1986, 1990, 1995, 1996, 1997.  All Rights Reserved. */

/* The following included files are standard ANSI C library headers which    **
** must be included on all ports.  If any of these files do not exist on a   **
** particular port, then the porter must produce Oracle equivalents for them */

#ifndef ORASTDDEF
# include <stddef.h>
# define ORASTDDEF
#endif

#ifndef ORALIMITS
# include <limits.h>
# define ORALIMITS
#endif

#ifndef  SX_ORACLE
#define  SX_ORACLE
#define  SX
#define  ORATYPES


/* define TRUE/FALSE;  defined in some stdio's */
#ifndef TRUE
# define TRUE  1
# define FALSE 0
#endif

/* Bug 193100 */
/* Define signed to nothing if lint is defined */
#ifdef lint
# ifndef mips
#  define signed
# endif /* mips */
#endif /* lint */

#ifdef ENCORE_88K
# ifndef signed
#  define signed
# endif /* signed */
#endif /* ENCORE_88K */

#if defined(SYSV_386) || defined(SUN_OS)
# ifdef signed
#  undef signed
# endif /* signed */
# define signed
#endif /* SYSV_386 */

/* fundamental types used  in  most  oracle  programs.	 ORACORP programs **
** should almost never declare variables of native types,  but should use **
** the following types. 						  **
** eword, eb1, eb2, and eb4 ("Either") are intended to hold non-negative  **
** values and be used in algorithms where sign is not important.	  **
** They may be implemented by either signed or unsigned values, depending **
** on which the porter chooses as being the more efficient.		  */

/* The -MAXVAL and -MINVAL constants represent the numerical range of the **
** relevant data type on the current port, i.e. the value of such symbol  **
** may change from one port to another. 				  **
** The MIN-MAXVAL and MAX-MINVAL constants represent the numerical range  **
** of the relevant data type across all ports, i.e. the value of these	  **
** should never be changed by porters.					  **
** Note that MAXSB1MINVAL is -127, instead of -128, to support one's      **
** complement arithmetic architectures. 				  */

#ifndef lint
typedef 	 int eword;		     /* use where sign not important */
typedef unsigned int uword;		     /* use where unsigned important */
typedef   signed int sword;		     /* use where   signed important */
#else
#define eword int
#define uword unsigned int
#define sword signed int
#endif /*LINT */

#define  EWORDMAXVAL  ((eword) INT_MAX)
#define  EWORDMINVAL  ((eword)	     0)
#define  UWORDMAXVAL  ((uword)UINT_MAX)
#define  UWORDMINVAL  ((uword)	     0)
#define  SWORDMAXVAL  ((sword) INT_MAX)
#define  SWORDMINVAL  ((sword) INT_MIN)
#define  MINEWORDMAXVAL  ((eword)  32767)
#define  MAXEWORDMINVAL  ((eword)      0)
#define  MINUWORDMAXVAL  ((uword)  65535)
#define  MAXUWORDMINVAL  ((uword)      0)
#define  MINSWORDMAXVAL  ((sword)  32767)
#define  MAXSWORDMINVAL  ((sword) -32767)


#ifndef lint
# ifdef mips
typedef   signed char  eb1;
# else
typedef 	 char  eb1;		     /* use where sign not important */
# endif /* mips */
typedef unsigned char  ub1;		     /* use where unsigned important */
typedef   signed char  sb1;		     /* use where   signed important */
#else
#define eb1 char
#define ub1 unsigned char
#define sb1 signed char
#endif /* LINT */

#define EB1MAXVAL ((eb1)SCHAR_MAX)
#define EB1MINVAL ((eb1)	0)
#if defined(mips)		      /* mips compilers barf on x[UB1MAXVAL] */
# ifndef lint
#  define UB1MAXVAL (UCHAR_MAX)
# endif
#endif
#ifndef UB1MAXVAL
# ifdef SCO_UNIX
# define UB1MAXVAL (UCHAR_MAX)
# else
# define UB1MAXVAL ((ub1)UCHAR_MAX)
# endif /* SCO_UNIX */
#endif
#define UB1MINVAL ((ub1)	0)
#define SB1MAXVAL ((sb1)SCHAR_MAX)
#define SB1MINVAL ((sb1)SCHAR_MIN)
#define MINEB1MAXVAL ((eb1)  127)
#define MAXEB1MINVAL ((eb1)    0)
#define MINUB1MAXVAL ((ub1)  255)
#define MAXUB1MINVAL ((ub1)    0)
#define MINSB1MAXVAL ((sb1)  127)
#define MAXSB1MINVAL ((sb1) -127)
/* number of bits in a byte */
#define UB1BITS 	 CHAR_BIT
#define UB1MASK 	 ((1 << ((uword)CHAR_BIT)) - 1)

/* human readable (printable) characters */
/*
 * Update for C++ design: change text to OraText
 * typedef  unsigned char text;
 */

typedef  unsigned char OraText;

#ifndef LUSEMFC
# define text OraText
#endif


#ifndef lint
typedef 	 short	  eb2;		     /* use where sign not important */
typedef unsigned short	  ub2;		     /* use where unsigned important */
typedef   signed short	  sb2;		     /* use where   signed important */
#else
#define eb2  short
#define ub2  unsigned short
#define sb2  signed short
#endif /* LINT */

#define EB2MAXVAL ((eb2) SHRT_MAX)
#define EB2MINVAL ((eb2)	0)
#define UB2MAXVAL ((ub2)USHRT_MAX)
#define UB2MINVAL ((ub2)	0)
#define SB2MAXVAL ((sb2) SHRT_MAX)
#define SB2MINVAL ((sb2) SHRT_MIN)
#define MINEB2MAXVAL ((eb2) 32767)
#define MAXEB2MINVAL ((eb2)	0)
#define MINUB2MAXVAL ((ub2) 65535)
#define MAXUB2MINVAL ((ub2)	0)
#define MINSB2MAXVAL ((sb2) 32767)
#define MAXSB2MINVAL ((sb2)-32767)

#if defined(A_OSF)

#ifndef lint
typedef 	 int  eb4;		    /* use where sign not important */
typedef unsigned int  ub4;		    /* use where unsigned important */
typedef   signed int  sb4;		    /* use where   signed important */
#else
#define eb4 int
#define ub4 unsigned int
#define sb4 signed int
#endif /* LINT */

#define EB4MAXVAL ((eb4)  INT_MAX)
#define EB4MINVAL ((eb4)	0)
#define UB4MAXVAL ((ub4) UINT_MAX)
#define UB4MINVAL ((ub4)	0)
#define SB4MAXVAL ((sb4)  INT_MAX)
#define SB4MINVAL ((sb4)  INT_MIN)
#define MINEB4MAXVAL ((eb4) 2147483647)
#define MAXEB4MINVAL ((eb4)	     0)
#define MINUB4MAXVAL ((ub4) 4294967295)
#define MAXUB4MINVAL ((ub4)	     0)
#define MINSB4MAXVAL ((sb4) 2147483647)
#define MAXSB4MINVAL ((sb4)-2147483647)

#else  /* A_OSF */


#ifndef lint
typedef 	 long  eb4;		     /* use where sign not important */
typedef unsigned long  ub4;		     /* use where unsigned important */
typedef   signed long  sb4;		     /* use where   signed important */
#else
#define eb4 long
#define ub4 unsigned long
#define sb4 signed long
#endif /* LINT */

#define EB4MAXVAL ((eb4) LONG_MAX)
#define EB4MINVAL ((eb4)	0)
#define UB4MAXVAL ((ub4)ULONG_MAX)
#define UB4MINVAL ((ub4)	0)
#define SB4MAXVAL ((sb4) LONG_MAX)
#define SB4MINVAL ((sb4) LONG_MIN)
#define MINEB4MAXVAL ((eb4) 2147483647)
#define MAXEB4MINVAL ((eb4)	     0)
#define MINUB4MAXVAL ((ub4) 4294967295)
#define MAXUB4MINVAL ((ub4)	     0)
#define MINSB4MAXVAL ((sb4) 2147483647)
#define MAXSB4MINVAL ((sb4)-2147483647)
#endif /* A_OSF */



#ifndef lint
typedef unsigned long  ubig_ora;	     /* use where unsigned important */
typedef   signed long  sbig_ora;	     /* use where   signed important */
#else
#define ubig_ora unsigned long
#define sbig_ora signed long
#endif /* LINT */

#define UBIG_ORAMAXVAL ((ubig_ora)ULONG_MAX)
#define UBIG_ORAMINVAL ((ubig_ora)	  0)
#define SBIG_ORAMAXVAL ((sbig_ora) LONG_MAX)
#define SBIG_ORAMINVAL ((sbig_ora) LONG_MIN)
#define MINUBIG_ORAMAXVAL ((ubig_ora) 4294967295)
#define MAXUBIG_ORAMINVAL ((ubig_ora)	       0)
#define MINSBIG_ORAMAXVAL ((sbig_ora) 2147483647)
#define MAXSBIG_ORAMINVAL ((sbig_ora)-2147483647)
/* number of bits in a big_ora */
#define UBIGORABITS	 (UB1BITS * sizeof(ubig_ora))



#if defined(SLU8NATIVE) || defined(WIN32COMMON)

/* Porters: Change this typedef to the name of your platform's unsigned */
/*	    8-byte integer type and set the bounds accordingly. 	*/

#if defined(WIN32COMMON)

#ifndef lint
typedef unsigned _int64 ub8;
#else
#define ub8 unsigned _int64
#endif /* LINT */

#define UB8ZERO      ((ub8)0)

#define UB8MINVAL ((ub8)0)
#define UB8MAXVAL ((ub8)_UI64_MAX)

#define MAXUB8MINVAL ((ub8)0)
#define MINUB8MAXVAL ((ub8)_UI64_MAX)

#endif /* WIN32COMMON */

#if defined(SUN_OS5)

#ifndef lint
typedef unsigned long long ub8;
#else
#define ub8 unsigned long long
#endif /* LINT */

#define UB8ZERO      ((ub8)0)

#define UB8MINVAL    ((ub8)0)
#define UB8MAXVAL    ((ub8)18446744073709551615)

#define MAXUB8MINVAL ((ub8)0)
#define MINUB8MAXVAL ((ub8)18446744073709551615)

#endif /* SUN_OS5 */

#endif /* SLU8NATIVE */

#if defined(SLS8NATIVE) || defined(WIN32COMMON)

/* Porters: Change this typedef to the name of your platform's signed */
/*	    8-byte integer type and set the bounds accordingly.       */

#if defined(WIN32COMMON)

#ifndef lint
typedef   signed _int64 sb8;
#else
#define sb8 signed _int64
#endif /* LINT */

#define SB8ZERO      ((sb8)0)

#define SB8MINVAL ((sb8) _I64_MIN)
#define SB8MAXVAL ((sb8) _I64_MAX)

#define MAXSB8MINVAL ((sb8) _I64_MIN)
#define MINSB8MAXVAL ((sb8) _I64_MAX)

#endif /* WIN32COMMON */

#if defined(SUN_OS5)

#ifndef lint
typedef signed long long sb8;
#else
#define sb8 signed long long
#endif /* LINT */

#define SB8ZERO      ((sb8)0)

#define SB8MINVAL    ((sb8)-9223372036854775808)
#define SB8MAXVAL    ((sb8) 9223372036854775807)

#define MAXSB8MINVAL ((sb8)-9223372036854775807)
#define MINSB8MAXVAL ((sb8) 9223372036854775807)

#endif /* SUN_OS5 */

#endif /* SLS8NATIVE */



/* CONST:  use CONST as a replacement for the ANSI type qualifier 'const'. */

#undef CONST

#ifdef _olint
# define CONST const
#else
#if defined(PMAX) && defined(__STDC__)
#   define CONST const
#else
# ifdef M88OPEN
#  define CONST const
# else /* M88OPEN */
#  if defined(SEQ_PSX) && defined(__STDC__)
#    define CONST const
#  else /* SEQ_PSX && __STDC__ */
#    ifdef A_OSF
#      if defined(__STDC__)
#	 define CONST const
#      else
#	 define CONST
#      endif
#    else
#     ifdef WIN32COMMON
#      define CONST const
#     else
#      define CONST
#     endif
#    endif /* A_OSF */
#  endif /* SEQ_PSX && __STDC__ */
# endif /* M88OPEN */
#endif /* PMAX and !ULTRIX_MLS */
#endif /* _olint */


/* dvoid: base type for pointer to arbitrary block of memory	**
** use as "dvoid *"; in ansi environments, dvoid should be void **
** If your compiler doesn't support void *, dvoid * should match**
** the return type from memcpy()/memset(), i.e. probably char * **
** VMS defines (as opposed to typedefing) dvoid when linting to **
** allow dvoid* to match void* while being strict about other	**
** typedefs (i.e. short not matching ub2).			*/

#ifdef lint
# define dvoid void
#else

# ifdef UTS2
#  define dvoid char
# else
# define dvoid void
# endif /* UTS2 */

#endif /* lint */


/*
** lgenfp_t, a generic function pointer type.  (It's too bad that a level
** of indirection is hidden, as with the dearly departed ptr_t, but
** typedef'ing a function isn't portable.)
*/
typedef void (*lgenfp_t)( void );


/* type boolean, for TRUE/FALSE function local variables and parameters;     **
** defined as int for efficient processing and to match the natural type for **
** C boolean expressions.  Do not use where space efficiency is important.   */

#ifndef ORASYSTYPES
# include <sys/types.h>
# define ORASYSTYPES
#endif /* !ORAUSRINCLUDESYSTYPES */
#define boolean int


/* SIZE_TMAXVAL is the largest amount of memory that the current platform
** is capable of allocating in one single block. The constant MINSIZE_TMAXVAL
** is the largest allocation across all platforms. */

#ifdef sparc
# define SIZE_TMAXVAL SB4MAXVAL 	       /* This case applies for sun4 */
#else
# define SIZE_TMAXVAL UB4MAXVAL 	     /* This case applies for others */
#endif /* sparc */

#define MINSIZE_TMAXVAL (size_t)65535



#endif /* SX_ORACLE */
