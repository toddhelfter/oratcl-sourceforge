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
 * -OCI 7 call called orlon does not work with some versions of Oracle 8i(e.g.
 *  version 8.1.5 on NT). So Oracle 8 OCILogon is used for logging in. The
 *  service context handle is then converted to an lda such that the Oracle
 *  7 calls can be used again. Default is to use OCILogon. If using an Oracle
 *  7 DB then -DVERSION7DB compile flag must be used to use orlon
 *-----------------------------------------------------------------------------
 * Version 2.7 August, 1999
 * -use Tcl_Obj type constructs for all commands
 * -2 new functions available in tcl as 
 *      oraldalist - return a list of all opened ldas
 *      oracurlist $lda - return a list of all opened curs for an lda
 *  -   Oratcl_Fetch (orafetch) returns the correct number of spaces between
 *      columns.  Because of Tcl list operations, this is still a valid list.
 *  -   Oratcl_FetchAll changed extensively.
 *        handle both of the following properly
 *        orafetch $cur {} {} foo 1 bar 2
 *        orafetch $cur {} {} {foo 1 bar 2}
 * -Greater tuning of the evaluation string.  No calls to strcpy, bcopy,
 *  for memset are used to find the replacement columns.  
 */

#include "Oratypes.h"
#include "oratcl.h"
#include "externs.h"
#include "tcl.h"
#include <fcntl.h>
#include <sys/stat.h>

#ifdef NO_STRING_H
#include <strings.h>
#else
#include <string.h>
#endif

#include <ctype.h>
#include <stdlib.h>

#ifdef __WIN32
#if defined(__WIN32__)
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#   undef WIN32_LEAN_AND_MEAN
#endif

#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT

EXTERN int	Oratcl_Init		_ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int	Oratcl_SafeInit		_ANSI_ARGS_((Tcl_Interp *interp));

#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLIMPORT
#define strncasecmp strnicmp

#else
 
/* 
 * Windows binary flag for Oratcl_Wrlong/Oratcl_Rdlong,
 * unix doesn't need anything
 */
#define _O_BINARY    0
/* prototype for malloc */
extern void * malloc();
 
#endif	/* __WIN32__ */


/* 
 *----------------------------------------------------------------------
 * oTcl_ErrorMsg
 *    This procedure generates a Oratcl error message in interpreter.
 *
 * Results: None
 *
 * Side effects:
 *      An error message is generated in interp's result object to
 *      indicate that a command was invoked with the wrong number of
 *      arguments.  The message has the form
 *              wrong # args: should be "foo bar additional stuff"
 *      where "foo" and "bar" are the initial objects in objv (objc
 *      determines how many of these are printed) and "additional stuff"
 *      is the contents of the message argument.
 *
 *----------------------------------------------------------------------
 */

void
oTcl_ErrorMsg(interp, obj0, msg0, obj1, msg1) 
	Tcl_Interp	*interp;
	Tcl_Obj 	*obj0, *obj1;
	char		*msg0, *msg1;
{
	Tcl_Obj		*newPtr;

	newPtr = Tcl_DuplicateObj(OMV_null);
	if (obj0) {
		Tcl_IncrRefCount(obj0);
		Tcl_AppendStringsToObj(newPtr, Tcl_GetString(obj0), (char *) NULL);
		Tcl_DecrRefCount(obj0);
	}
	if (msg0) {
		Tcl_AppendToObj(newPtr, msg0, -1);
	}
	if (obj1) {
		Tcl_IncrRefCount(obj1);
		Tcl_AppendStringsToObj(newPtr, Tcl_GetString(obj1), (char *) NULL);
		Tcl_DecrRefCount(obj1);
	}
	if (msg1) {
		Tcl_AppendToObj(newPtr, msg1, -1);
	}
	Tcl_SetObjResult(interp, newPtr);
}


/* 
 *----------------------------------------------------------------------
 * get_ora_lda_handle
 *    authenticate an lda handle string 
 *
 *  return: OraLdas index number or -1 on error;
 *----------------------------------------------------------------------
 */

static int
get_ora_lda_handle (interp, handle) 
	Tcl_Interp	*interp;
	Tcl_Obj		*handle;
{
	int prefix_len = strlen(OraHandlePrefix);
	int lda_h;
	char *lda_s;
	int lda_c;
	int rc = -1;

	lda_s = Tcl_GetStringFromObj(handle, &lda_c);

	if ( (lda_c > prefix_len) &&
		(strncmp(lda_s,OraHandlePrefix,prefix_len) == 0)  &&
		(isdigit((int) *(lda_s + prefix_len))) 
	) {

		lda_h = atoi((lda_s + prefix_len));
		if (lda_h < 0 || lda_h >= ORATCLLDAS) {
			rc = -1;
		}
		if (OraLdas[lda_h].lda_in_use && 
			OraLdas[lda_h].interp == interp) 
		{
			rc = lda_h;
		} else {
			rc = -1;
		}
	} 

	return rc;
}

/* 
 *----------------------------------------------------------------------
 * get_ora_handle
 *    authenticate a cursor handle string 
 *
 *  return: OraCurs index number or -1 on error;
 *----------------------------------------------------------------------
 */

static int
get_ora_handle (interp, handle) 
	Tcl_Interp	*interp;
	Tcl_Obj		*handle;
{
	char	*lda_s;
	int	lda_c;
	int	lda_h;
	int	cur_h;
	char	*p;
	int	rc = -1;

	lda_h = get_ora_lda_handle(interp, handle);
	if (lda_h >= 0) {

		lda_s = Tcl_GetStringFromObj(handle, &lda_c);
		if ( ((p = strchr(lda_s,'.')) != NULL) 
				&& (isdigit((int) *(p+1))) ) {

			cur_h = atoi((p + 1));
			if (cur_h < 0 || cur_h >= ORATCLCURS) {
				rc = -1;
			}
			if (OraCurs[cur_h].cur_in_use) {
				rc = cur_h;
			} else {
				rc = -1;
			}
		} 
	}
	return rc;
}

/*
 *----------------------------------------------------------------------
 * get_lda_err
 *   get the oracle return code and error message for an lda error
 *
 *----------------------------------------------------------------------
 */

static void
get_lda_err (interp, hand)
	Tcl_Interp *interp;
	int         hand;
{
	char buf[ORA_MSG_SIZE];

	Tcl_ObjSetVar2(interp,
		OraMsgArray,
		OM_rc,
		Tcl_NewIntObj(OraLdas[hand].lda->rc),
		TCL_GLOBAL_ONLY);

	if (OraLdas[hand].lda->rc == 0) {
		buf[0] = '\0';
	} else {
		oerhms (OraLdas[hand].lda, OraLdas[hand].lda->rc, 
			buf, sizeof(buf));
	}

	Tcl_ObjSetVar2(interp,
		OraMsgArray,
		OM_errortxt,
		Tcl_NewStringObj(buf, -1),
		TCL_GLOBAL_ONLY);
}


/*
 *----------------------------------------------------------------------
 * get_ora_err
 *   get the oracle return code and error message
 *----------------------------------------------------------------------
 */

static void
get_ora_err (interp, hand)
	Tcl_Interp *interp;
	int         hand;
{

	char buf[ORA_MSG_SIZE];

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(OraCurs[hand].cda->rc), TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_sqlfunc, Tcl_NewIntObj(OraCurs[hand].cda->ft), TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_ocifunc, Tcl_NewIntObj(OraCurs[hand].cda->fc), TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, Tcl_NewIntObj(OraCurs[hand].cda->peo), TCL_GLOBAL_ONLY);

	if (OraCurs[hand].cda->rc == 0) {
		buf[0] = '\0';
	} else {
		oerhms (OraLdas[OraCurs[hand].lda_num].lda, OraCurs[hand].cda->rc, 
			buf, sizeof(buf));
	}
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_errortxt, Tcl_NewStringObj(buf, -1), TCL_GLOBAL_ONLY);
}


/*
 *----------------------------------------------------------------------
 * clear_msg --
 *
 * clears all error and message elements in the global array variable
 *----------------------------------------------------------------------
 */

static void
clear_msg(interp)
	Tcl_Interp *interp;
{
	/* index "rc" - return code from last oratcl call */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, OMV_null, TCL_GLOBAL_ONLY);

	/* index "sqlfunc" - sql function code of last sql */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_sqlfunc, OMV_null, TCL_GLOBAL_ONLY);

	/* index "ocifunc" - oci function code of last call */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_ocifunc, OMV_null, TCL_GLOBAL_ONLY);

	/* index "errortxt" - text from last rc */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_errortxt, OMV_null, TCL_GLOBAL_ONLY);

	/* index "peo" - parse error offset from last oratcl call */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_null, TCL_GLOBAL_ONLY);

	/* index "rows" - rows processed count from oexec */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, OMV_null, TCL_GLOBAL_ONLY);

	/* index "rowid" - rowid of last row maniuplated */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rowid, OMV_null, TCL_GLOBAL_ONLY);

	/*
	 * index "collengths", "coltypes", "colprecs", and "colscales" are
	 * only meaningful after an oracols command.
	 */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_collengths, OMV_null, TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_coltypes, OMV_null, TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_colprecs, OMV_null, TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_colscales, OMV_null, TCL_GLOBAL_ONLY);
}


/*
 *----------------------------------------------------------------------
 * ora_prologue
 *    does most of standard command prologue, assumes handle is objv[1]
 *
 * returns: cursor handle index  or -1 on failure
 * 
 *----------------------------------------------------------------------
 */

static int
ora_prologue (interp, objc, objv, num_args, err_msg)
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
	int		num_args;
	char		*err_msg;
{
	int	hand;

	/* check number of minimum args*/
	if (objc < num_args) {
		Tcl_WrongNumArgs(interp, objc, objv, err_msg);
		return (-1);
	}

	clear_msg(interp);

	/* parse the handle */
	hand = get_ora_handle(interp, objv[1]);

	if (hand == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": handle ", objv[1], " not open");
		return (-1);
	}

	/* clear oramsg array for new messages & errors */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, objv[1], TCL_GLOBAL_ONLY);
	return (hand);
}

/*
 *----------------------------------------------------------------------
 * free_cols
 *   free all ColBufs in a list
 *----------------------------------------------------------------------
 */

static void
free_cols (col_list_ptr)
	ColBufs  *col_list_ptr;
{
	ColBufs  *next;

	while (col_list_ptr != NULL) {
		next = col_list_ptr->next_buf;
		if (col_list_ptr->col_data != NULL) {
			ckfree(col_list_ptr->col_data);
		}
		ckfree((char *) col_list_ptr);
		col_list_ptr = next;
	}
}


/*
 *----------------------------------------------------------------------
 * free_curs
 *   free all cursors belonging to an lda
 *
 */

static void
free_curs (lda_owner)
	int  lda_owner;
{
	int  i;

	for (i = 0; i < ORATCLCURS; i++) {
		if (OraCurs[i].cur_in_use && (OraCurs[i].lda_num==lda_owner)) {
			OraCurs[i].cur_in_use = 0;
			OraCurs[i].lda_num    = 0;
			oclose(OraCurs[i].cda);
			ckfree((char *) OraCurs[i].cda);
			OraCurs[i].cda        = NULL;
			free_cols(OraCurs[i].col_list);
			OraCurs[i].col_list   = NULL;;
			free_cols(OraCurs[i].bind_list);
			OraCurs[i].bind_list   = NULL;;
		}
	}
}

/*
 *----------------------------------------------------------------------
 * alloc_col
 *   return a new ColBufs with nulled pointers and zeroed fields
 *----------------------------------------------------------------------
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
 *----------------------------------------------------------------------
 */

static int
parse_columns (interp, hand)
	Tcl_Interp *interp;
	int         hand;
{
	ColBufs		*new_col_head;
	ColBufs		*new_col;
	ColBufs		*last_col;
	int		pos = 0;
	long		long_size;

	/* start by allocating column structures, and keep in linked list */
	new_col_head = alloc_col();
	if (new_col_head == NULL) {
		return -1;
	}
	new_col      = new_col_head;
	last_col     = new_col_head;

	/* get max long size */
	Tcl_GetLongFromObj(
		interp,
		Tcl_ObjGetVar2(interp, OraMsgArray, OM_maxlong, TCL_GLOBAL_ONLY),
		&long_size);

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
		odescr(OraCurs[hand].cda, (pos+1), &(new_col->dbsize),
			&(new_col->dbtype), new_col->dbname, 
			&(new_col->dbname_len), &(new_col->disp_size),
			&(new_col->prec), &(new_col->scale), 
			&(new_col->nullok)   );
       
		if (OraCurs[hand].cda->rc == NO_MORE_COLUMNS) {
			last_col->next_buf = NULL;
			ckfree((char *) new_col);
			break;
		}

		if (OraCurs[hand].cda->rc != 0) {
			get_ora_err(interp, hand);
			free_cols(new_col_head);
			return -1;
		}

		new_col->dbname[new_col->dbname_len] = '\0';

	       /*
		*	check for long (type 8) or long raw (type 24) 
		*	if long or long raw found, then set display size to 
		*	long_size and reduce cache to 1 for this cursor
		*/

		if (new_col->dbtype == LONG_TYPE 
				|| new_col->dbtype == LONGRAW_TYPE) {
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

		new_col->col_data = 
			ckalloc(new_col->disp_size *OraCurs[hand].cache_size);
		if (new_col->col_data == NULL) {
			free_cols(new_col_head);
			OraCurs[hand].col_list = NULL;
			return -1;
		}

		odefin(OraCurs[hand].cda, pos, new_col->col_data, 
		       (int) new_col->disp_size, EXT_STRING_TYPE,
			0, (short *) 0, NULL, 0, 0, new_col->rlen,
			new_col->rcode);

	}
	return (1);
}


/*
 *----------------------------------------------------------------------
 * append_cols
 *      appends column results to tcl result
 *----------------------------------------------------------------------
 */

static void
append_cols (interp, hand)
	Tcl_Interp  *interp;
	int          hand;
{
	int		rn;
	ColBufs		*col;
	char		*buf;
	Tcl_Obj		*data_obj, *buf_obj;
	int		oColsc = 0;

	/* quick sanity check */
	rn = OraCurs[hand].row_num;
	if (rn < 0 || rn >= OraCurs[hand].cache_size) {
		return;
	}

	buf_obj = Tcl_ObjGetVar2( interp, OraMsgArray, OM_nullvalue, TCL_GLOBAL_ONLY);

	buf = Tcl_GetStringFromObj(buf_obj, NULL);
	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
      
		/* for cursor type, just return a null */
		/* get pointer to next row column data buffer */

	       /*
		* null column?
		* except long (8) & long raw (24) may report null
		* in error, so check rlen for those types, for other 
		* types, just check rcode 
		*/

		if (col->dbtype == INT_CURSOR_TYPE) {
			data_obj = OMV_null;
		} else {
			if (((col->dbtype == LONG_TYPE 
				|| col->dbtype == LONGRAW_TYPE) 
				&& col->rlen[rn] == 0 ) 
			|| ((col->dbtype != LONG_TYPE 
				&& col->dbtype != LONGRAW_TYPE) && 
				col->rcode[rn] == NULL_VALUE)) {

				if (*buf == 'd' && strcmp(buf,"default") == 0) {
				       /* default-if number or money type,
					* then return "0", else ""
					*/
					if (col->dbtype == NUMBER_TYPE) {
						data_obj = OMV_zero;
					} else {
						data_obj = OMV_null;
					}
				} else {
					/* return user defined nullvalue */
					data_obj = buf_obj;
				}
			} else {
				/* make sure data is null terminated, just in case */
				if (col->disp_size > 0) {
					data_obj = Tcl_NewStringObj(
						col->col_data + (rn * col->disp_size),
						-1);
				} else {
					data_obj = OMV_null;
				}
			}
		}
		if (oColsc >= oColslen) {
			oColslen += 10;
			oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
		}
		oColsv[oColsc++] = data_obj;
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	OraCurs[hand].row_num += 1;
	OraCurs[hand].fetch_cnt += 1;

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, OMV_zero, TCL_GLOBAL_ONLY);
	fetch_ok = 1;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Kill --
 *   perform all cleanup upon any command deletion
 *----------------------------------------------------------------------
 */

void
Oratcl_Kill (clientData)
	ClientData clientData;
{
	int i;

	ckfree ((char *) oColsv);
	ckfree ((char *) ColSubs);

	for (i = 0; i < ORATCLLDAS; i++) {
		if (OraLdas[i].lda_in_use) {
			free_curs(i);
			OraLdas[i].lda_in_use = 0;
			OraLdas[i].interp = NULL;
#ifdef NONBLOCK_CURSOR
			if (OraLdas[i].async == 1) {
				obreak(OraLdas[i].lda);
				onbclr(OraLdas[i].lda);
			}
#endif
			ologof(OraLdas[i].lda);
			ckfree((char *) OraLdas[i].lda);
			ckfree(OraLdas[i].hda);
		}
	}

	Tcl_DecrRefCount(OraMsgArray);
	Tcl_DecrRefCount(OMV_null);
	Tcl_DecrRefCount(OMV_zero);
	Tcl_DecrRefCount(OM_rc);
	Tcl_DecrRefCount(OM_rows);
	Tcl_DecrRefCount(OM_peo);
	Tcl_DecrRefCount(OM_rowid);
	Tcl_DecrRefCount(OM_sqlfunc);
	Tcl_DecrRefCount(OM_ocifunc);
	Tcl_DecrRefCount(OM_ociinfo);
	Tcl_DecrRefCount(OM_errortxt);
	Tcl_DecrRefCount(OM_collengths);
	Tcl_DecrRefCount(OM_coltypes);
	Tcl_DecrRefCount(OM_colprecs);
	Tcl_DecrRefCount(OM_colscales);
	Tcl_DecrRefCount(OM_handle);
	Tcl_DecrRefCount(OM_maxlong);
	Tcl_DecrRefCount(OM_nullvalue);
	Tcl_DecrRefCount(OM_version);

	MY_STATS_DUMP;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_DeleteInterp --
 *   close any dbprocs left open when an interpreter is deleted
 *   and clear interp level options
 *----------------------------------------------------------------------
 */

void
Oratcl_DeleteInterp (clientData, interp)
    ClientData clientData;
    Tcl_Interp *interp;
{
	int i;

	for (i = 0; i < ORATCLLDAS; i++) {
		if (OraLdas[i].lda_in_use && OraLdas[i].interp == interp) {
			free_curs(i);
			OraLdas[i].lda_in_use = 0;
			OraLdas[i].interp = NULL;
#ifdef NONBLOCK_CURSOR
			if (OraLdas[i].async == 1) {
				obreak(OraLdas[i].lda);
				onbclr(OraLdas[i].lda);
			}
#endif
			ologof(OraLdas[i].lda);
			ckfree((char *) OraLdas[i].lda);
		}
	}
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Init --
 *   perform all initialization for the Oracle - Tcl interface.
 *   adds additional commands to interp, creates message array
 *
 *   a call to Oratcl_Init should exist in Tcl_CreateInterp or
 *   Tcl_CreateExtendedInterp.
 *----------------------------------------------------------------------
 */

int
Oratcl_Init (interp)
	Tcl_Interp *interp;
{
	int i;
	static int OratclInitFlag = 0;    /* check if already initialized */
	Tcl_Obj	*tmp_obj;

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

		Tcl_CreateExitHandler ((Tcl_ExitProc *)Oratcl_Kill, (ClientData) interp);


		OMV_null	= Tcl_NewStringObj("",	-1);
		OMV_zero	= Tcl_NewIntObj(0);

		Tcl_IncrRefCount(OMV_null);
		Tcl_IncrRefCount(OMV_zero);

		/*
		 * Initialize oramsg global array, inital null elements
		 */

		OraMsgArray	= Tcl_NewStringObj("oramsg",	-1);
		OM_rc		= Tcl_NewStringObj("rc",	-1);
		OM_rows		= Tcl_NewStringObj("rows",	-1);
		OM_peo		= Tcl_NewStringObj("peo",	-1);
		OM_rowid	= Tcl_NewStringObj("rowid",	-1);
		OM_sqlfunc	= Tcl_NewStringObj("sqlfunc",	-1);
		OM_ocifunc	= Tcl_NewStringObj("ocifunc",	-1);
		OM_ociinfo	= Tcl_NewStringObj("ociinfo",	-1);
		OM_errortxt	= Tcl_NewStringObj("errortxt",	-1);
		OM_collengths	= Tcl_NewStringObj("collengths", -1);
		OM_coltypes	= Tcl_NewStringObj("coltypes",	-1);
		OM_colprecs	= Tcl_NewStringObj("colprecs",	-1);
		OM_colscales	= Tcl_NewStringObj("colscales",	-1);
		OM_handle	= Tcl_NewStringObj("handle",	-1);
		OM_maxlong	= Tcl_NewStringObj("maxlong",	-1);
		OM_nullvalue	= Tcl_NewStringObj("nullvalue",	-1);
		OM_version	= Tcl_NewStringObj("version",	-1);
		tListObjType	= Tcl_GetObjType("list");

		Tcl_IncrRefCount(OraMsgArray);
		Tcl_IncrRefCount(OM_rc);
		Tcl_IncrRefCount(OM_rows);
		Tcl_IncrRefCount(OM_peo);
		Tcl_IncrRefCount(OM_rowid);
		Tcl_IncrRefCount(OM_sqlfunc);
		Tcl_IncrRefCount(OM_ocifunc);
		Tcl_IncrRefCount(OM_ociinfo);
		Tcl_IncrRefCount(OM_errortxt);
		Tcl_IncrRefCount(OM_collengths);
		Tcl_IncrRefCount(OM_coltypes);
		Tcl_IncrRefCount(OM_colprecs);
		Tcl_IncrRefCount(OM_colscales);
		Tcl_IncrRefCount(OM_handle);
		Tcl_IncrRefCount(OM_maxlong);
		Tcl_IncrRefCount(OM_nullvalue);
		Tcl_IncrRefCount(OM_version);

		/* Preallocate some reusable data structures */
		if (oColsv == NULL) {
			oColslen = 10;
			oColsv = (Tcl_Obj **) ckalloc (oColslen * sizeof(*oColsv));
		}

		if (ColSubs == NULL) {
			ColSubsLen = COL_INC;
			ColSubs = (struct colsubd *) ckalloc (ColSubsLen * sizeof(struct colsubd));
		}

	}

	/*
	* Initialize the new Tcl commands
	*/
	Tcl_CreateObjCommand (interp, "oralogon", Oratcl_Logon,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oralogoff", Oratcl_Logoff,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraopen", Oratcl_Open,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraclose", Oratcl_Close,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orasql", Oratcl_Sql,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orabindexec", Oratcl_Bindexec,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orafetch", Oratcl_Fetch,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracols", Oratcl_Cols,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracancel", Oratcl_Cancel,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraplexec",  Oratcl_PLexec,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orawritelong", Oratcl_Wrlong,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orareadlong", Oratcl_Rdlong,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracommit", Oratcl_Commit,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraroll", Oratcl_Roll,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraautocom", Oratcl_Autocom,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oracurlist", Oratcl_Cur_List,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "oraldalist", Oratcl_Lda_List,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
#ifdef NONBLOCK_CURSOR
	Tcl_CreateObjCommand (interp, "orapoll", Oratcl_Poll,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
	Tcl_CreateObjCommand (interp, "orabreak", Oratcl_Break,
			(ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
#endif

	/*
	* Initialize oramsg global array, inital null elements
	*/
    
	/* index "version" - oratcl verison number */
	
	tmp_obj = Tcl_NewStringObj(VERSION, -1);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_version, tmp_obj, TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	/* index "handle" - the last handle that set any other elements */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, OMV_null, TCL_GLOBAL_ONLY);

	/* index "nullvalue" - what to return if column is null */
	/* user should set this value if something else is wanted */
	tmp_obj = Tcl_NewStringObj("default", -1);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_nullvalue, tmp_obj, TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	/* index "maxlong" - the maximum length of a long column to return */
	/* in a select or oralong , can be set by user                 */
	tmp_obj = Tcl_NewStringObj("32768", -1);
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_maxlong, tmp_obj, TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);


	/* index "ociinfo" - information on how oratcl was compiled    */
#ifdef VERSION7
	tmp_obj = Tcl_NewStringObj("version_7", -1);
#ifdef NONBLOCK_CURSOR
	tmp_obj = Tcl_NewStringObj("version_7 non_blocking cursor_variables", -1);
#endif
#else
	tmp_obj = Tcl_NewStringObj("version_6", -1);
#endif
	Tcl_IncrRefCount(tmp_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_ociinfo, tmp_obj, TCL_GLOBAL_ONLY);
	Tcl_DecrRefCount(tmp_obj);

	/* other indices - correspond to error and message handler arguments */
	clear_msg(interp);

	/* callback to clean up any dbprocs left open on interpreter deletetion */
	Tcl_CallWhenDeleted(interp, (Tcl_InterpDeleteProc *) Oratcl_DeleteInterp,
		(ClientData) NULL);


	if (Tcl_PkgProvide(interp, "Oratcl", VERSION) != TCL_OK) {
		return TCL_ERROR;
	}

	return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 * Oratcl_SafeInit --
 *	call the standard init point.  
 *----------------------------------------------------------------------
 */

int
Oratcl_SafeInit (interp) 
	Tcl_Interp *interp;
{
	int result;

	result = Oratcl_Init(interp);
	Tcl_DeleteCommand(interp, "orawritelong");
	Tcl_DeleteCommand(interp, "orareadlong");
	return (result);
}

/*
 *----------------------------------------------------------------------
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
 *----------------------------------------------------------------------
 */

int
Oratcl_Logon (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int		hand;
	int		rc;
	char		buf[ORA_MSG_SIZE];
	char 		*con_str;
	int		con_len;
	Tcl_Obj		*buf_obj;

    int namelen, pwlen, connlen;
    char *name;
    char *pword;
    char *conn;

	/* can't use ora_prologue, oralogon creates a logon handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "connect_str");
		return TCL_ERROR;
	}

	/* find an unused handle */
	for (hand = 0; hand < ORATCLLDAS; hand++) {
		if (OraLdas[hand].lda_in_use == 0) {
			break;
		}
	}

	if (hand >= ORATCLLDAS) {
		oTcl_ErrorMsg(interp, objv[0], ": no lda handles available", NULL, NULL);
		return TCL_ERROR;
	}

	OraLdas[hand].async = 0;

	if ( (OraLdas[hand].lda = (lda_def *) ckalloc(sizeof (lda_def))) == NULL) {
		oTcl_ErrorMsg(interp, objv[0], ": oralogon failed in malloc(lda)", NULL, NULL);
		return TCL_ERROR;
	}

	if ( (OraLdas[hand].hda = ckalloc(ORA_HOST_AREA)) == NULL) {
		ckfree((char *) OraLdas[hand].lda);
		oTcl_ErrorMsg(interp, objv[0], ": oralogon failed in malloc(hda)", NULL, NULL);
		return TCL_ERROR;
	}

	/* safety - zero out lda and hda */
	memset(OraLdas[hand].lda, 0, sizeof (lda_def));
	memset(OraLdas[hand].hda, 0, ORA_HOST_AREA);

	/* orlon sometimes fails on first attempt, but then works on next */
	/* attempt in some cases.  try orlon 2nd time if fail on 1st try  */


#ifdef VERSION7DB
#if TMH
fprintf(stderr, "Using Oracle 7 API to orlon\n");
#endif

	Tcl_IncrRefCount(objv[1]);
	con_str = Tcl_GetStringFromObj(objv[1], &con_len);

	rc = orlon(OraLdas[hand].lda,
		   OraLdas[hand].hda,
		   con_str,
		   con_len,
		   NULL,
		   0,
		   0);
	if (rc != 0) {
		rc = orlon(OraLdas[hand].lda,
			   OraLdas[hand].hda,
			   con_str,
			   con_len,
			   NULL,
			   0,
			   0);
	}
	Tcl_DecrRefCount(objv[1]);
#endif

#ifndef VERSION7DB

        /*
         * Use Oracle 8 API call OCILogon.
         * orlon does not seen to work with later versions of Oracle 8i
         */

#if TMH
fprintf(stderr, "Using Oracle 8 API to OCILogon\n");
#endif

        Tcl_IncrRefCount(objv[1]);
        con_str = Tcl_GetStringFromObj(objv[1], &con_len);

        rc = OCIInitialize((ub4) OCI_DEFAULT,
                           (dvoid *)0,
                           (dvoid * (*)(dvoid *, size_t)) 0,
                           (dvoid * (*)(dvoid *, dvoid *, size_t))0,
                           (void (*)(dvoid *, dvoid *)) 0 );

        rc = OCIEnvInit((OCIEnv **) &p_env[hand],
                        OCI_DEFAULT,
                        (size_t) 0,
                        (dvoid **) 0);

        rc = OCIHandleAlloc((dvoid *) p_env[hand],
                            (dvoid **) &p_err[hand],
                            OCI_HTYPE_ERROR,
                            (size_t) 0,
                            (dvoid **) 0);

        rc = OCIHandleAlloc((dvoid *) p_env[hand],
                            (dvoid **) &p_svc[hand],
                            OCI_HTYPE_SVCCTX,
                            (size_t) 0,
                            (dvoid **) 0);

        name = strtok(con_str, "/@");
        pword = strtok(NULL, "/@");
        conn = strtok(NULL, "/@");

        if (name != NULL)
                namelen = strlen(name);
        else
                namelen = 0;

        if (pword != NULL)
                pwlen = strlen(pword);
        else
                pwlen = 0;

        if (conn != NULL)
                connlen = strlen(conn);
        else
                connlen = 0;

        rc = OCILogon(p_env[hand],
		      p_err[hand],
		      &p_svc[hand],
		      name,
		      namelen,
		      pword,
		      pwlen,
		      conn,
		      connlen);
        OCISvcCtxToLda (p_svc[hand],
		        p_err[hand],
			OraLdas[hand].lda);

        Tcl_DecrRefCount(objv[1]);

#endif

	if (rc != 0) {
		/* logon failed, cleanup */
		/* can't use get_lda_err(), may not have connected to server*/
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(OraLdas[hand].lda->rc), TCL_GLOBAL_ONLY);
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_errortxt,
			Tcl_NewStringObj("logon failed: invalid id/password or unable to connect to server", -1),
			TCL_GLOBAL_ONLY);
		ckfree((char *) OraLdas[hand].lda);
		ckfree(OraLdas[hand].hda);
		oTcl_ErrorMsg(interp, objv[0], ": oralogon failed in orlon", NULL, NULL);
		return TCL_ERROR;
	}

	OraLdas[hand].lda_in_use = 1;	/* handle ok, set in use flag */
	OraLdas[hand].interp = interp;	/* handle ok, set interp */

	/* construct logon handle and return */
	sprintf(buf,"%s%d",OraHandlePrefix,hand);
	buf_obj = Tcl_NewStringObj(buf, -1);
	Tcl_IncrRefCount(buf_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, buf_obj, TCL_GLOBAL_ONLY);
	clear_msg(interp);
	Tcl_SetObjResult(interp, buf_obj);
	Tcl_DecrRefCount(buf_obj);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Logoff --
 *    Implements the oralogoff command:
 *    usage: oralogon lda_handle
 *       lda_handle should be a valid, open lda handle from oralogon
 *	                
 *    results:
 *	null string
 *      TCL_OK - logoff successful
 *      TCL_ERROR - logoff not successful - error message returned
 *----------------------------------------------------------------------
 */

int
Oratcl_Logoff (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;

	/* can't use ora_prologue, oralogoff just uses an lda handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
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
	OraLdas[hand].interp     = NULL;
	OraLdas[hand].async      = 0;
	if (ologof(OraLdas[hand].lda) != 0) {
		/* logoff failed, get error msg */
		get_lda_err(interp,hand);
		ckfree((char *) OraLdas[hand].lda);
		ckfree(OraLdas[hand].hda);

		return TCL_ERROR;
	}
	ckfree((char *) OraLdas[hand].lda);
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
 *----------------------------------------------------------------------
 */

int
Oratcl_Open (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int		lda_hand, cur_hand = -1;
	int		i;
	char		buf[ORA_MSG_SIZE];
	Tcl_Obj		*buf_obj;

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	Tcl_IncrRefCount(objv[0]);
	Tcl_IncrRefCount(objv[1]);

	/* can't use ora_prologue, oraopen just uses an lda handle */
	if ((lda_hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	clear_msg(interp);

	/* find an unused cursor handle */

	for (i = 0; i < ORATCLCURS; i++) {
		if (OraCurs[i].cur_in_use == 0) {
			cur_hand = i;
			break;
		}
	}

	if (cur_hand == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": no cursor handles available", NULL, NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}


	if ( (OraCurs[cur_hand].cda = (cda_def *) ckalloc(sizeof (cda_def))) == NULL) {
		oTcl_ErrorMsg(interp, objv[0], ": oraopen failed in malloc(cda)", NULL, NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}
    
	if (oopen(OraCurs[cur_hand].cda,OraLdas[lda_hand].lda,NULL,-1,-1,NULL,-1) !=0) {
		/* open failed, cleanup */
		get_ora_err(interp,cur_hand);
		ckfree((char *) OraCurs[cur_hand].cda);
		oTcl_ErrorMsg(interp, objv[0], ": oraopen failed in oopen", NULL, NULL);
		Tcl_DecrRefCount(objv[0]);
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	/* cursor open ok */
	OraCurs[cur_hand].cur_in_use = 1;
	OraCurs[cur_hand].lda_num    = lda_hand;
	OraCurs[cur_hand].col_list   = NULL;
	OraCurs[cur_hand].bind_list  = NULL;
	OraCurs[cur_hand].cache_size = ORA_CACHE;
	OraCurs[cur_hand].row_num    = 0;
	OraCurs[cur_hand].fetch_end  = 1;
	OraCurs[cur_hand].fetch_cnt  = 0;
	OraCurs[cur_hand].oexec_done = 0;
	OraCurs[cur_hand].first_fetch= 0;
	OraCurs[cur_hand].async      = 0;

	/* construct and return a cursor handle */
	sprintf(buf,"%s%d.%d",OraHandlePrefix,lda_hand,cur_hand);  
	buf_obj = Tcl_NewStringObj(buf, -1);
	Tcl_IncrRefCount(buf_obj);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, buf_obj, TCL_GLOBAL_ONLY);
	clear_msg(interp);
	Tcl_SetObjResult(interp, buf_obj);
	Tcl_DecrRefCount(buf_obj);
	Tcl_DecrRefCount(objv[0]);
	Tcl_DecrRefCount(objv[1]);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Close --
 *    Implements the oraclose command:
 *    usage: oraclose cur_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - cursor closed successfully
 *      TCL_ERROR - wrong # args, or cur_handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Close (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int     hand;

	if ((hand = ora_prologue(interp,objc, objv, 2," cur_handle")) == -1) {
		return TCL_ERROR;
	}

	OraCurs[hand].cur_in_use = 0;
	OraCurs[hand].lda_num    = 0;
	oclose(OraCurs[hand].cda);
	memset(OraCurs[hand].cda, 0, sizeof(cda_def));
	ckfree((char *) OraCurs[hand].cda);
	OraCurs[hand].cda        = NULL;
	free_cols(OraCurs[hand].col_list);
	OraCurs[hand].col_list   = NULL;
	free_cols(OraCurs[hand].bind_list);
	OraCurs[hand].bind_list  = NULL;
	OraCurs[hand].bind_list  = 0;
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
 * Oratcl_Sql --
 *    Implements the orasql command:
 *    usage: orasql cur_handle sql_string ?-parseonly? | ?-async?
 *	                
 *    results:
 *	return code from oexec
 *      TCL_OK - handle is opened, sql executed ok
 *      TCL_ERROR - wrong # args, or handle not opened,  bad sql stmt
 *----------------------------------------------------------------------
 */

int
Oratcl_Sql (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;
	int	lda_hand;
	char	buf[ORA_MSG_SIZE];
	int	parseonly = 0;
	int	asyncmode = 0;
	char	*arg_v, *p;
	int	arg_c;
	int	ix;

	for (ix=0; ix<objc; ix++) {
		Tcl_IncrRefCount(objv[ix]);
	}

	if ((hand = ora_prologue(interp, objc, objv, 3,
		" cur_handle sql_str  ?-parseonly? | ?-async? ")) ==-1) {
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	/* check for options and deprecated keywords */
	if (objc >= 4) {
		p = Tcl_GetStringFromObj(objv[3], NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"parseonly") == 0) {
			parseonly = 1;
		}
#ifdef NONBLOCK_CURSOR
		if (strcmp(p,"async") == 0) {
			asyncmode = 1;
		}
#endif
	}

	/* cancel any pending usage of cursor */
	ocan(OraCurs[hand].cda);

	/* set up sql for execution */
	arg_v = Tcl_GetStringFromObj(objv[2], &arg_c);
	oparse(OraCurs[hand].cda, arg_v, ((long) -1), DEF_FLAG, LNG_FLAG);

	if (OraCurs[hand].cda->rc != 0) {
		get_ora_err(interp,hand);
		oTcl_ErrorMsg(interp, objv[0], ": oparse failed (bad sql ?)", NULL, NULL);
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_ERROR;
	}

	/* clear peo */
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_zero, TCL_GLOBAL_ONLY);

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
		Tcl_SetObjResult(interp, Tcl_NewIntObj(OraCurs[hand].cda->rc));
		get_ora_err(interp,hand);
		for (ix=0; ix<objc; ix++) {
			Tcl_DecrRefCount(objv[ix]);
		}
		return TCL_OK;
	}

	/* only call parse_columns after DML (insert,select,update,delete) */
	if (OraCurs[hand].cda->ft == 3 || OraCurs[hand].cda->ft == 4 ||
	    OraCurs[hand].cda->ft == 5 || OraCurs[hand].cda->ft == 9) {

		if (parse_columns(interp, hand) != -1) {
  
			if (parseonly) {
				Tcl_SetObjResult(interp, Tcl_NewIntObj(OraCurs[hand].cda->rc));
				get_ora_err(interp,hand);
				for (ix=0; ix<objc; ix++) {
					Tcl_DecrRefCount(objv[ix]);
				}
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
			Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
  
			/* set msg array variable "rowid" of any row manipulated */
			sprintf(buf,"%08.8lX.%04.4X.%04.4X",
				(long) OraCurs[hand].cda->rid.d4,
				OraCurs[hand].cda->rid.d5,
			/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
			/*      OraCurs[hand].cda->rid.rd.d1, */
			/*      OraCurs[hand].cda->rid.rd.d3, */
				OraCurs[hand].cda->rid.rd.d2);
			Tcl_ObjSetVar2(interp, OraMsgArray, OM_rowid, Tcl_NewStringObj(buf, -1), TCL_GLOBAL_ONLY);
  
			/* cause first orafetch to fetch */
			OraCurs[hand].row_num   = OraCurs[hand].cache_size;
			OraCurs[hand].fetch_end = 0;        /* try to fetch */
			OraCurs[hand].fetch_cnt = 0;        /* start fetch cnt at zero */
  
		} else {
			get_ora_err(interp,hand);
			oTcl_ErrorMsg(interp, objv[0], ": parse_columns failed", NULL, NULL);
			for (ix=0; ix<objc; ix++) {
				Tcl_DecrRefCount(objv[ix]);
			}
			return TCL_ERROR;
		}

	} else {
		oexec(OraCurs[hand].cda);

		if (OraCurs[hand].cda->rc != 0) {
			get_ora_err(interp,hand);
			oTcl_ErrorMsg(interp, objv[0], ": oexec of DDL failed", NULL, NULL);
			for (ix=0; ix<objc; ix++) {
				Tcl_DecrRefCount(objv[ix]);
			}
			return TCL_ERROR;
		}
		/* set msg array variable "rows" to rpc (rows processed count) */
		/* in case of insert, update, delete,                          */
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
	}

	get_ora_err(interp,hand);
	Tcl_SetObjResult(interp, Tcl_NewIntObj(OraCurs[hand].cda->rc));
	for (ix=0; ix<objc; ix++) {
		Tcl_DecrRefCount(objv[ix]);
	}
	return TCL_OK;
}

#ifdef NONBLOCK_CURSOR
/*
 *----------------------------------------------------------------------
 * Oratcl_Poll --
 *    Implements the orapoll command:
 *    usage: orapoll cur_handle ?-all?
 *	                
 *    results:
 *	return objv[1] handle if cursor is ready, null if still blocking
 *        optional "-all" returns list of all ready cursors
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Poll (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
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

	int	oColsc;
	char	*p;


	if ((hand = ora_prologue(interp,objc, objv, 2,
		" cur_handle ?-all?")) == -1) {
		return TCL_ERROR;
	}

	/* check for options and deprecated keywords */
	start = hand;
	max   = hand + 1;
	if (objc >= 3) {
		p = Tcl_GetStringFromObj(objv[2], (int *) NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"all") == 0) {
			/* test all open ldas */
			start = 0;
			max   = ORATCLCURS;
		}
	}

	oColsc = 0;


    for (i = start; i < max; i++) {
	if (OraCurs[i].cur_in_use) {
	    lda_hand = OraCurs[i].lda_num;
	    if (oColsc >= oColslen) {
		oColslen += 10;
		oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
	    }
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
		    oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		} 

	    } else {
	        /* check for non-async cursors that can still fetch */
		if (!OraCurs[i].fetch_end) {
		    sprintf(buf,"%s%d.%d",OraHandlePrefix,
						OraCurs[i].lda_num, i);
		    oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		}
	    }
	}
    }

    Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));
    get_ora_err(interp,hand);

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Break --
 *    Implements the orabreak command:
 *    usage: orabreak lda_handle 
 *	                
 * Results:
 *      sends break to lda in async mode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Break (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int        hand;

	/* can't use ora_prologue, orabreak just uses an lda handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
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
 * Oratcl_Bindexec --
 *    Implements the orabindexec command:
 *    usage: orabindexec cur_handle ?-async? :varname value 
 *	                
 *    results:
 *	bind :varname value pairs, execute sql
 *	sets message array element "rc" with value of exec rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Bindexec (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;
	int	lda_hand;
	char	buf[ORA_MSG_SIZE];
	int	parm_cnt;
	ColBufs	*tmp_col_head;
	ColBufs	*tmp_col;
	ColBufs	*head_col;
	int	asyncmode = 0;
	char	*arg_pcc, *arg_pcp, *p;
	int	arg_pcc_len, arg_pcp_len;

	if ((hand = ora_prologue(interp,objc, objv, 2,
		" cur_handle ?-async?  [ :varname value ] ...")) == -1) {
		return TCL_ERROR;
	}

	OraCurs[hand].oexec_done = 0;
	OraCurs[hand].first_fetch= 0;
	OraCurs[hand].async      = 0;

	parm_cnt = 2;

	/* check for option and deprecated keywords */
	if (objc >= 3) {
		p = Tcl_GetStringFromObj(objv[2], (int *) NULL);
		if (*p == '-') {
			p++;
		}
		if (strcmp(p,"async") == 0) {
#ifdef NONBLOCK_CURSOR
			asyncmode = 1;
#endif
			parm_cnt++;
		}
	}

	/* if first time in, allocate bind_list */

	if (OraCurs[hand].bind_list == NULL) {

		if (objc > parm_cnt + 1) {
			tmp_col_head = alloc_col();
			if (tmp_col_head == NULL) {
				oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
				return TCL_ERROR;
			}
			tmp_col      = tmp_col_head;
			head_col     = tmp_col_head;
			OraCurs[hand].bind_list = tmp_col_head;
		} else {
			tmp_col_head = NULL;
		}

		while (objc > parm_cnt + 1) {       /* always in pairs of two */

			/* get two arg strings */
			arg_pcc = Tcl_GetStringFromObj(objv[parm_cnt], &arg_pcc_len);
			arg_pcp = Tcl_GetStringFromObj(objv[parm_cnt + 1], &arg_pcp_len);

			/* make sure bind variable name has a leading ':' */
			if (*arg_pcc != ':') {
				free_cols(OraCurs[hand].col_list);
				OraCurs[hand].col_list = NULL;
				free_cols(OraCurs[hand].bind_list);
				OraCurs[hand].bind_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": bind variable ", objv[parm_cnt], "does not begin with ':'");
				return TCL_ERROR;
			}

			memcpy(tmp_col->dbname, arg_pcc, arg_pcc_len);
			tmp_col->dbname[arg_pcc_len] = '\0';

			tmp_col->disp_size  = ORA_BIND_SIZE;
			tmp_col->rlen[0] = 0;
			tmp_col->rcode[0] = 0;

			tmp_col->col_data   = ckalloc(tmp_col->disp_size + 1);
			memcpy(tmp_col->col_data, arg_pcp, arg_pcp_len);
			tmp_col->col_data[arg_pcp_len] = '\0';

			obndrv(OraCurs[hand].cda, tmp_col->dbname, -1, tmp_col->col_data, ORA_BIND_SIZE,
				EXT_STRING_TYPE, -1, NULL, NULL, -1, -1);

			if (OraCurs[hand].cda->rc != 0) {
				get_ora_err(interp, hand);
				free_cols(OraCurs[hand].col_list);
				OraCurs[hand].col_list = NULL;
				free_cols(OraCurs[hand].bind_list);
				OraCurs[hand].bind_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": bind failed for ", objv[parm_cnt], NULL);
				return TCL_ERROR;
			}

			parm_cnt += 2;

			if (objc > parm_cnt + 1) {       /* more args? alloc new colbufs */
				head_col           = tmp_col;
				tmp_col            = alloc_col();
				if (tmp_col == NULL) {
					free_cols(OraCurs[hand].col_list);
					OraCurs[hand].col_list = NULL;
					free_cols(OraCurs[hand].bind_list);
					OraCurs[hand].bind_list = NULL;
					oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
					return TCL_ERROR;
				}
				head_col->next_buf = tmp_col;
			}
		}

	} else {
		/* else, binds have been done, just copy in new data */
		while (objc > parm_cnt + 1) {       /* always in pairs of two */
			tmp_col = OraCurs[hand].bind_list;
			while (tmp_col != NULL) {
				if (strncmp(tmp_col->dbname, Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL), 255) == 0) {
				    strncpy(tmp_col->col_data, Tcl_GetStringFromObj(objv[parm_cnt + 1], (int *) NULL),
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
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
	/* set msg array variable "rowid" of any row manipulated */
	sprintf(buf,"%08.8lX.%04.4X.%04.4X",
                        (long) OraCurs[hand].cda->rid.d4,
                        OraCurs[hand].cda->rid.d5,
	/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
	/*              OraCurs[hand].cda->rid.rd.d1, */
	/*              OraCurs[hand].cda->rid.rd.d3, */
                        OraCurs[hand].cda->rid.rd.d2);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rowid, Tcl_NewStringObj(buf, -1), TCL_GLOBAL_ONLY);
  
	/* cause first orafetch to fetch */
	OraCurs[hand].row_num   = OraCurs[hand].cache_size;
	OraCurs[hand].fetch_end = 0;        /* try to fetch */
	OraCurs[hand].fetch_cnt = 0;        /* start fetch cnt at zero */
  
	get_ora_err(interp,hand);
	Tcl_SetObjResult(interp, Tcl_NewIntObj(OraCurs[hand].cda->rc));

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Fetch --
 *    Implements the orafetch command:
 *    usage: orafetch cur_handle 
 *	                
 * Results:
 *	next row from latest results as tcl list, or null list
 *	sets message array element "rc" with value of fetch rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened
 *----------------------------------------------------------------------
 */

int
Oratcl_Fetch (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int      hand;
	int      lda_hand;
	char     buf[ORA_MSG_SIZE];
	long     old_rpc;
	int      old_rc;
	ColBufs *col;
	int      i;
	int      Oratcl_FetchAll();

	fetch_ok = 0;

	if ((hand = ora_prologue(interp, objc, objv, 2, 
		" cur_handle  ?commands? ?subtitution_char?")) == -1) {
		return TCL_ERROR;
	}

	/* if there's a third argument, let next proc do the work */
	if (objc >= 3) {
		return (Oratcl_FetchAll(clientData, interp, objc, objv));
	}

	/* if this cursor hasn't performed SQL, return a 1403 */
	if (OraCurs[hand].fetch_end &&
		OraCurs[hand].fetch_cnt >= (long) OraCurs[hand].cda->rpc &&
		OraCurs[hand].fetch_cnt >  0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(NO_DATA_FOUND), TCL_GLOBAL_ONLY);
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
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
		OraCurs[hand].fetch_cnt >= (long) OraCurs[hand].cda->rpc &&
		OraCurs[hand].fetch_cnt >  0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(NO_DATA_FOUND), TCL_GLOBAL_ONLY);
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
		return TCL_OK;
	}

	/* check to see if next set of results */

	old_rpc = OraCurs[hand].cda->rpc;

	if (OraCurs[hand].row_num >= OraCurs[hand].cache_size  ||
		OraCurs[hand].fetch_cnt >= (long) OraCurs[hand].cda->rpc) {

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
			Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(OUT_OF_SEQUENCE), TCL_GLOBAL_ONLY);
			Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
			return TCL_OK;
		}

		if (OraCurs[hand].cda->rc == NO_DATA_FOUND) {
			OraCurs[hand].fetch_end = 1;
			/* if old_rpc equal current rpc, there are no more rows to */
			/* return, else ofen is ended, but rows are buffered to return */
			if (old_rpc == (long) OraCurs[hand].cda->rpc) {
				Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(OraCurs[hand].cda->rc), TCL_GLOBAL_ONLY);
				Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
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
				oTcl_ErrorMsg(interp, objv[0], ": ofen failed", NULL, NULL);
				return TCL_ERROR;
			}
		}

		OraCurs[hand].row_num = 0;
	}

	/* set msg array variable "rowid" of any row manipulated */
	sprintf(buf,"%08.8lX.%04.4X.%04.4X",
                        (long) OraCurs[hand].cda->rid.d4,
                        OraCurs[hand].cda->rid.d5,
	/* I dont know what is d1 and d2, in my oracle 7.3.2 for SCO always zero*/
	/*              OraCurs[hand].cda->rid.rd.d1, */
	/*              OraCurs[hand].cda->rid.rd.d3, */
                        OraCurs[hand].cda->rid.rd.d2);
	Tcl_ObjSetVar2(interp, OraMsgArray, OM_rowid, Tcl_NewStringObj(buf, -1), TCL_GLOBAL_ONLY);
  
	append_cols(interp, hand);

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_FetchAll --
 *    Implements the orafetch with iterative commands:
 *    usage: orafetch cur_handle tcl_stmts substitution_char ?tclvar colnum ..?
 *	                
 * Results:
 *	fetch all rows from existing query, execute tcl_stmt on each row
 *	sets message array element "rc" with value of final fetch rcode
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened, tcl_stmt failed,
 *                  or wrong number of columns
 *----------------------------------------------------------------------
 */

int
Oratcl_FetchAll (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int		ix;
	int      	hand;
	char    	*s, *p, *token;
	int		ch, nch;

#define NUMSTRS 300		/* number of individual strings to allow*/
#define SUBCHAR '@'		/* default substitution character */

	char     subchar = SUBCHAR; /* substitution character */
	int      num_str = 0;	/* number of strings to concat */

	char		*cmd_str;
	int		cmd_len;

	Tcl_DString	evalStr;	/* tcl dynamic string for building eval */
	int		parm_cnt;
	int		inum, jnum;
	int		tcl_rc;

	Tcl_Obj		*oResult;
        Tcl_Obj		**infoObjv, **varsObjv;
        int		infoObjc, varsObjc;

	if ((hand = ora_prologue(interp, objc, objv, 3, 
		" cur_handle  commands ?sub_char? ? [ tclvar colnum ] ... ?")) == -1) {
		return TCL_ERROR;
	}

	/* check if already exhausted or nothing to fetch */
	if (OraCurs[hand].fetch_end && 
		OraCurs[hand].fetch_cnt >= (long) OraCurs[hand].cda->rpc &&
		OraCurs[hand].fetch_cnt >  0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rc, Tcl_NewIntObj(NO_DATA_FOUND), TCL_GLOBAL_ONLY);
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_rows, Tcl_NewLongObj(OraCurs[hand].cda->rpc), TCL_GLOBAL_ONLY);
		return TCL_OK;
	}

	if (OraCurs[hand].col_list == NULL) {   
		return TCL_OK;			/* nothing to fetch */
	}

	if (objc >= 4) {
		p = Tcl_GetStringFromObj(objv[3], NULL);
		if ((ch = *p) == ' ') {
			subchar = '\0';
		} else if (ch != '\0') {
			subchar = ch;
		}
	}

	cmd_str = Tcl_GetStringFromObj(objv[2], &cmd_len);

	if (cmd_str == NULL) {
		return TCL_OK;			/* nothing to fetch */
	}

	token = p = cmd_str;
	num_str = 0;
	while ((ch = *p++) != '\0') {
		if (ch == subchar) {
			if ((nch = *p) == subchar) {
				if (num_str >= ColSubsLen) {
					ColSubsLen += COL_INC;
					ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
				}
				ColSubs[num_str].strlen = p - token;
				ColSubs[num_str].strpos = token;
				ColSubs[num_str++].column = -1;
				token = ++p;
			} else if (isdigit(nch)) {
				if (num_str + 1 >= ColSubsLen) {
					ColSubsLen += COL_INC;
					ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
				}
				if ((ColSubs[num_str].strlen = p - 1 - token) > 0) {
					ColSubs[num_str].strpos = token;
					ColSubs[num_str++].column = -1;
				}
				ColSubs[num_str++].column = strtol(p, &s, 10);
				token = p = s;
			}
		}
	}


	if (num_str >= ColSubsLen) {
		ColSubsLen += COL_INC;
		ColSubs = (struct colsubd *) ckrealloc ((char *) ColSubs, ColSubsLen * sizeof(struct colsubd));
	}
	if ((ColSubs[num_str].strlen = p - 1 - token) > 0) {
		ColSubs[num_str].strpos = token;
		ColSubs[num_str++].column = -1;
	}

	/* loop until fetch exhausted */

	if (Oratcl_Fetch(clientData, interp, 2, objv) == TCL_ERROR) {
		oTcl_ErrorMsg(interp, objv[0], ": orafetch failed", NULL, NULL);
		return TCL_ERROR;
	}

	while (fetch_ok) {

		oResult = Tcl_GetObjResult(interp);
		if (Tcl_IsShared(oResult) && oResult->typePtr != tListObjType) {
			oResult = Tcl_DuplicateObj(oResult);
		}
		Tcl_IncrRefCount(oResult);
		tcl_rc = Tcl_ListObjGetElements(interp, oResult, &infoObjc, &infoObjv);

		if (tcl_rc != TCL_OK) {
			oTcl_ErrorMsg(interp, objv[0], ": Tcl_ListObjGetElements failed", NULL, NULL);
			Tcl_DecrRefCount(oResult);
			return TCL_ERROR;
		}

		/* build eval string from literals and columns */
		Tcl_DStringInit(&evalStr);
		for (inum=0; inum < num_str; inum++) {
			if (ColSubs[inum].column > -1) {
				if (ColSubs[inum].column == 0) {    /* col 0 is entire result */
					Tcl_DStringStartSublist(&evalStr);
					for (jnum=0; jnum < infoObjc; jnum++) {
						Tcl_DStringAppendElement(&evalStr, Tcl_GetStringFromObj(infoObjv[jnum], NULL));
					}
					Tcl_DStringEndSublist(&evalStr);
				} else {
					if (ColSubs[inum].column > infoObjc) {/* another sanity chk*/
						Tcl_DStringFree(&evalStr); 	/* free eval string */
						oTcl_ErrorMsg(interp, objv[0], ": column sanity failed on column sub", NULL, NULL);
						Tcl_DecrRefCount(oResult);
						return TCL_ERROR;
					}
					Tcl_DStringAppendElement(&evalStr, Tcl_GetStringFromObj(infoObjv[ColSubs[inum].column -1], NULL)); 
				}
			} else {
				Tcl_DStringAppend(&evalStr, ColSubs[inum].strpos, ColSubs[inum].strlen);
			}
		}

		/* handle tclvar colnum pairs passed as a single  arg */
		if (objc == 5) {
			tcl_rc = Tcl_ListObjGetElements(interp, objv[objc - 1], &varsObjc, &varsObjv);
			if (tcl_rc != TCL_OK) {
				oTcl_ErrorMsg(interp, objv[0], ": Tcl_ListObjGetElements failed", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			} 
		} else {
			varsObjc = objc - 4;
			varsObjv = (Tcl_Obj **) objv + 4;
		}

		/* handle tclvar colnum pairs passed as individual args */
		for (parm_cnt = 0; parm_cnt < varsObjc; parm_cnt += 2) {
			if (parm_cnt + 1 >= varsObjc) {
				Tcl_DStringFree(&evalStr); 	/* free eval string */
				oTcl_ErrorMsg(interp, objv[0], ": column sanity failed on tclvar bind", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			}
			tcl_rc = Tcl_GetIntFromObj(interp, varsObjv[parm_cnt + 1], &ix);
			if (tcl_rc != TCL_OK || ix < 0 || ix > infoObjc) {
				Tcl_DStringFree(&evalStr); 	/* free eval string */
				oTcl_ErrorMsg(interp, objv[0], ": invalid integer column", NULL, NULL);
				Tcl_DecrRefCount(oResult);
				return TCL_ERROR;
			}
			if (ix == 0) {
				Tcl_ObjSetVar2(interp, varsObjv[parm_cnt], NULL, Tcl_NewListObj(infoObjc, infoObjv), 0);
			} else {
				Tcl_ObjSetVar2(interp, varsObjv[parm_cnt], NULL, infoObjv[ix - 1], 0);
			}
		}
		Tcl_DecrRefCount(oResult);

		if (Tcl_DStringLength(&evalStr) > 0) {
			tcl_rc = Tcl_Eval(interp, (char *) Tcl_DStringValue(&evalStr));
		} else {
			tcl_rc = TCL_OK;
		}

		Tcl_DStringFree(&evalStr);

		switch (tcl_rc) {
			case TCL_ERROR:
				oTcl_ErrorMsg(interp, objv[0], ": eval failed while in ", objv[0], NULL);
				return TCL_ERROR;
				break;

			case TCL_BREAK:		/* return sooner */
				return TCL_OK;
				break;

			default:
				break;
		}

		/*
		 * I wonder why we need this (Todd Helfter) TMH
		 */
		Tcl_ResetResult(interp);	/* reset interp result for next */
 
		/* next fetch */
		if (Oratcl_Fetch(clientData, interp, 2, objv) == TCL_ERROR) {
			oTcl_ErrorMsg(interp, objv[0], ": orafetch failed", NULL, NULL);
			return TCL_ERROR;
		}
	}

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Cols --
 *    Implements the oracols command:
 *    usage: oracols cur_handle 
 *	                
 *    results:
 *	latest column names as tcl list
 *      also set oramsg(collengths) and oramsg(coltypes) as tcl list
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Cols (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int		hand;
	ColBufs		*col;
	char		*type_ptr;
	int		oColsc;
	Tcl_Obj		*buf_obj;

	if ((hand = ora_prologue(interp,objc, objv, 2," cur_handle")) == -1) {
		return TCL_ERROR;
	}

	oColsc = 0;

	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
		if (oColsc >= oColslen) {
			oColslen += 10;
			oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
		}
		oColsv[oColsc++] = Tcl_NewStringObj(col->dbname, -1);
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	oColsc = 0;
	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
		oColsv[oColsc++] = Tcl_NewIntObj(col->disp_size - 1);
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_collengths, Tcl_NewListObj(oColsc, oColsv), TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
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
		oColsv[oColsc++] = Tcl_NewStringObj(type_ptr, -1);
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp,
			OraMsgArray,
			OM_coltypes,
			Tcl_NewListObj(oColsc, oColsv),
			TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {

		/* format precision and scale for numeric data */
		if (col->dbtype == 2) {
			buf_obj = Tcl_NewIntObj(col->prec);
		} else {
			buf_obj = OMV_null;
		}
		oColsv[oColsc++] = buf_obj;
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_colprecs, Tcl_NewListObj(oColsc, oColsv), TCL_GLOBAL_ONLY);
	}

	oColsc = 0;
	for (col = OraCurs[hand].col_list; col != NULL; col = col->next_buf) {
		if (col->dbtype == 2) {
			buf_obj = Tcl_NewIntObj(col->scale);
		} else {
			buf_obj = OMV_null;
		}
		oColsv[oColsc++] = buf_obj;
	}
	if (oColsc > 0) {
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_colscales, Tcl_NewListObj(oColsc, oColsv), TCL_GLOBAL_ONLY);
	}

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Cancel --
 *    Implements the oracancel command:
 *    usage: oracancel  cur_handle 
 *	                
 *    results:
 *	null string
 *      TCL_OK - handle is opened
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Cancel (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;

	if ((hand = ora_prologue(interp,objc, objv, 2," cur_handle")) == -1) {
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
 * Oratcl_PLexec --
 *    Implements the oraplexec command:
 *    usage: oraplexec cur_handle pl_block [ :varname value ]  [ .... ]
 *	                
 *    results:
 *	return parms in tcl list form
 *      TCL_OK - proc executed
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_PLexec (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;
	int	parm_cnt;
	ColBufs	*new_col_head = NULL;
	ColBufs	*new_col = NULL;
	ColBufs	*last_col = NULL;
	int	cursor_hand = -1;
	char	*p;
	char	*pl_str;
	int	pl_len;

	/* prologue */
	if ((hand = ora_prologue(interp,objc, objv, 3,
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

	pl_str = Tcl_GetStringFromObj(objv[2], &pl_len);
	/* parse pl_block */
	oparse(OraCurs[hand].cda, pl_str, ((long) pl_len), DEF_FLAG, LNG_FLAG);

	if (OraCurs[hand].cda->rc != 0) {
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": oraparse failed", NULL, NULL);
		return TCL_ERROR;
	} else {
		/* clear peo */
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_zero, TCL_GLOBAL_ONLY);
	}

	/* bind :colon_parms following arg, alloc large enough return space (?)*/
	parm_cnt = 3;      

	/* only alloc new col if one or more valid arg for :var */
	if (objc > parm_cnt + 1) {        
		new_col_head = alloc_col();
		if (new_col_head == NULL) {
			oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
			return TCL_ERROR;
		}
		new_col      = new_col_head;
		last_col     = new_col_head;
	} else {
		new_col_head = NULL;
	}

	while (objc > parm_cnt + 1) {       /* always in pairs of two */

		/* make sure bind variable name has a leading ':' */
		p = Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL);
		if (*p != ':') {
			free_cols(new_col_head);
			OraCurs[hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": bind variable ", objv[parm_cnt], " does not begin with ':'");
			return TCL_ERROR;
		}

		new_col->disp_size  = ORA_BUFF_SIZE;
		new_col->col_data   = ckalloc(new_col->disp_size + 1);
		if (new_col->col_data == NULL) {
			free_cols(new_col_head);
			OraCurs[hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col data for ", objv[parm_cnt], NULL);
			return TCL_ERROR;
		} else {
#ifdef NONBLOCK_CURSOR
			/* check for cursor binding */
			if ((cursor_hand = get_ora_handle(interp, objv[parm_cnt+1])) >= 0) {
				/* check if cursor same as command handle */
				if (hand == cursor_hand) {
					/* error */
					free_cols(new_col_head);
					OraCurs[hand].col_list = NULL;
					oTcl_ErrorMsg(interp, objv[0], ": bind cursor for ", objv[parm_cnt], " same as cursor_handle");
					return TCL_ERROR;
				}
				/* check if cursor from same login lda */
				if (get_ora_handle(interp, objv[parm_cnt+1])  !=
				    get_ora_handle(interp, objv[1])) {
					/* error */
					free_cols(new_col_head);
					OraCurs[hand].col_list = NULL;
					oTcl_ErrorMsg(interp, objv[0], ": bind cursor for ", objv[parm_cnt], " not from same login handle as cursor_handle");
					return TCL_ERROR;
				}
				/* check if cursor handle was previously opened */
				if (!OraCurs[cursor_hand].cur_in_use) {
					/* error */
					free_cols(new_col_head);
					OraCurs[hand].col_list = NULL;
					oTcl_ErrorMsg(interp, objv[0], ": bind cursor for ", objv[parm_cnt], " not previously opened");
					return TCL_ERROR;
				}
				/* close open cursor, but don't free memory for cda */
				oclose(OraCurs[cursor_hand].cda);
				memset(OraCurs[cursor_hand].cda, 0, sizeof(cda_def));
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
				strncpy(new_col->col_data, 
					Tcl_GetStringFromObj(objv[parm_cnt+1], (int *) NULL),
					ORA_BUFF_SIZE-1);
				/* save cursor handle */
				new_col->bind_cursor            = cursor_hand;
			} else {
				/* not a cursor, save bind value */
				strncpy(new_col->col_data, 
					Tcl_GetStringFromObj(objv[parm_cnt+1], (int *) NULL),
					ORA_BUFF_SIZE-1);
				new_col->bind_cursor = -1;
			}
#else
			strncpy(new_col->col_data, Tcl_GetStringFromObj(objv[parm_cnt + 1], NULL), ORA_BUFF_SIZE - 1);
			new_col->bind_cursor = -1;
#endif
		}

		new_col->rlen[0] = 0;
		new_col->rcode[0] = 0;

		/* if oracols is called after the exec, give it some info */

		if (cursor_hand == -1) {
			/* regular string data type */
			new_col->dbtype = 1;   /* internal type char/varchar*/
			strncpy(new_col->dbname,
				Tcl_GetStringFromObj(objv[parm_cnt], NULL),
				(sizeof new_col->dbname)-1);

			obndrv( OraCurs[hand].cda,
				Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL),
				-1, new_col->col_data,
				ORA_BUFF_SIZE, EXT_STRING_TYPE, -1, NULL, NULL, -1, -1);
			
		} else {
			/* cursor data type */
			new_col->dbtype = INT_CURSOR_TYPE; 
			strncpy(new_col->dbname,
				Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL),
				(sizeof new_col->dbname)-1);

			obndrv( OraCurs[hand].cda,
				Tcl_GetStringFromObj(objv[parm_cnt], (int *) NULL), -1, 
				(char *) OraCurs[cursor_hand].cda,  
				(sizeof (cda_def)), INT_CURSOR_TYPE, -1, NULL, NULL, -1, -1);
		}

		if (OraCurs[hand].cda->rc != 0) {
			get_ora_err(interp, hand);
			free_cols(new_col_head);
			OraCurs[hand].col_list = NULL;
			oTcl_ErrorMsg(interp, objv[0], ": bind failed for ", objv[parm_cnt], NULL);
			return TCL_ERROR;
		}

		parm_cnt += 2;

		if (objc > parm_cnt + 1) {        /* more args? alloc new colbufs */
			last_col           = new_col;
			new_col            = alloc_col();
			if (new_col == NULL) {
				free_cols(new_col_head);
				OraCurs[hand].col_list = NULL;
				oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col ", NULL, NULL);
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
					oTcl_ErrorMsg(interp, objv[0], ": parse_columns failed for ", NULL, new_col->dbname);
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
 * Oratcl_Commit --
 *    Implements the oracommit command:
 *    usage: oracommit lda_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - transactions commited
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Commit (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;

	/* can't use ora_prologue, oraroll just uses an lda handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, objv[1], TCL_GLOBAL_ONLY);

	ocom(OraLdas[hand].lda); 
	get_lda_err(interp, hand);

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Roll --
 *    Implements the oraroll command:
 *    usage: oraroll lda_handle
 *	                
 *    results:
 *	null string
 *      TCL_OK - transactions rolled back
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Roll (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;

	/* can't use ora_prologue, oraroll just uses an lda handle */
	clear_msg(interp);

	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, objv[1], TCL_GLOBAL_ONLY);
	orol(OraLdas[hand].lda); 
	get_lda_err(interp, hand);

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Autocom --
 *    Implements the oraautocom command:
 *    usage: oraroll lda_handle on|off
 *	                
 *    results:
 *	null string
 *      TCL_OK - auto commit set on or off
 *      TCL_ERROR - wrong # args, or handle not opened,
 *----------------------------------------------------------------------
 */

int
Oratcl_Autocom (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
	int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;

	/* can't use ora_prologue, oraautocom just uses an lda handle */
	clear_msg(interp);

	if (objc < 3) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle on|off");
		return TCL_ERROR;
	}

	Tcl_IncrRefCount(objv[1]);
	Tcl_IncrRefCount(objv[2]);

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		Tcl_DecrRefCount(objv[1]);
		return TCL_ERROR;
	}

	Tcl_ObjSetVar2(interp, OraMsgArray, OM_handle, objv[1], TCL_GLOBAL_ONLY);

	/* case insensitive compare */
	if (strncasecmp(
		Tcl_GetStringFromObj(objv[2], (int *) NULL),"on",2) == 0
	) {
		ocon(OraLdas[hand].lda); 
	} else {
		ocof(OraLdas[hand].lda); 
	}

	Tcl_DecrRefCount(objv[1]);
	Tcl_DecrRefCount(objv[2]);

	get_lda_err(interp, hand);
	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
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
 *----------------------------------------------------------------------
 */

int
Oratcl_Wrlong (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int     hand;
	int     fd;
	long    filesize;
	char    buf[ORA_MSG_SIZE];
	char    *data_ptr;
	struct  stat stat_buf;
	ColBufs *new_col;

	if ((hand = ora_prologue(interp,objc, objv, 6,
		" cur_handle rowid table column filename")) == -1) {
		return TCL_ERROR;
	}

	fd = open(Tcl_GetStringFromObj(objv[5], (int *) NULL), O_RDONLY | _O_BINARY, 0);
	if (fd < 0) {
		oTcl_ErrorMsg(interp, objv[0], ": file ", objv[5], " cannot be opened for reading");
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
		oTcl_ErrorMsg(interp, objv[0], ": cannot malloc memory for file", NULL, NULL);
		return TCL_ERROR;
	}

	if (filesize != read(fd,data_ptr,filesize)) {
		close(fd);
		ckfree(data_ptr);
		oTcl_ErrorMsg(interp, objv[0], ": cannot read file into memory", NULL, NULL);
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

	sprintf(buf,"select %s from %s where rowid = '%s'",
		Tcl_GetStringFromObj(objv[4], (int *) NULL),
		Tcl_GetStringFromObj(objv[3], (int *) NULL),
		Tcl_GetStringFromObj(objv[2], (int *) NULL)
	);

	/* parse sql stmt */
	oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

	if (OraCurs[hand].cda->rc != 0) {
		ckfree(data_ptr);
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": oparse failed for long select", NULL, NULL);
		return TCL_ERROR;
	} else {
		/* clear peo */
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_zero, TCL_GLOBAL_ONLY);
	}


	/* get description of column so we know which datatype we're dealing with */

	new_col = alloc_col();
	if (new_col == NULL) {
		ckfree(data_ptr);
		oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
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
		oTcl_ErrorMsg(interp, objv[0], ": odescr error", NULL, NULL);
		return TCL_ERROR;
	}


	/* compose update stmt */

	sprintf(buf,"update %s set %s = :1 where rowid = '%s' ",
		Tcl_GetStringFromObj(objv[3], (int *) NULL),
		Tcl_GetStringFromObj(objv[4], (int *) NULL),
		Tcl_GetStringFromObj(objv[2], (int *) NULL)
	);

	/* parse sql stmt */
	oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

	if (OraCurs[hand].cda->rc != 0) {
		ckfree(data_ptr);
		free_cols(new_col);
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": oparse failed for long update", NULL, NULL);
		return TCL_ERROR;
	} else {
		/* clear peo */
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_zero, TCL_GLOBAL_ONLY);
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
		oTcl_ErrorMsg(interp, objv[0], ": oexec error", NULL, NULL);
		return TCL_ERROR;
	}
	if (OraCurs[hand].cda->rpc != 1) {  /* not found, row process != 1 */
		ckfree(data_ptr);
		free_cols(new_col);
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": row not found", NULL, NULL);
		return TCL_ERROR;
	}

	/* free mem */
	ckfree(data_ptr);
	free_cols(new_col);

	get_ora_err(interp, hand);

	/* return total bytes sent */
	Tcl_SetObjResult(interp, Tcl_NewIntObj(filesize));

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Rdlong --
 *    Implements the orareadlong command:
 *    usage: orareadlong cur_handle rowid table column file 
 *
 *    results:
 *	null string
 *      TCL_OK - handle is closed
 *      TCL_ERROR - wrong # args, or handle not opened, can't open file,
 *                  or other error in text/image handling
 *----------------------------------------------------------------------
 */

int
Oratcl_Rdlong (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int     hand;
	int     fd;
	char    buf[ORA_MSG_SIZE];
	char    buf2[ORA_MSG_SIZE];
	char   *data_ptr;
	long    long_size = MAX_LONG_SIZE;
	unsigned long bytes_fetched = 0;
	long     offset = 0;
	ColBufs *new_col;
	int     rc;

#ifndef VERSION7
	short   fcode;
	unsigned short   fsize;
#endif

	if ((hand = ora_prologue(interp,objc, objv, 6,
		" cur_handle rowid table column filename")) == -1) {
		return TCL_ERROR;
	}

	fd = open(Tcl_GetStringFromObj(objv[5], (int *) NULL), O_WRONLY | O_TRUNC | O_CREAT | _O_BINARY, 0644);
	if (fd < 0) {
		oTcl_ErrorMsg(interp, objv[0], ": file ", objv[5], " cannot be opened for writing");
		return TCL_ERROR;
	}

	/* compose select stmt */
	sprintf(buf,"select %s from %s where rowid = '%s'",
		Tcl_GetStringFromObj(objv[4], (int *) NULL),
		Tcl_GetStringFromObj(objv[3], (int *) NULL),
		Tcl_GetStringFromObj(objv[2], (int *) NULL)
	);

	/* parse sql stmt */
	oparse(OraCurs[hand].cda, buf, ((long) -1), DEF_FLAG, LNG_FLAG);

	if (OraCurs[hand].cda->rc != 0) {
		close(fd);
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": oparse failed for select long", NULL, NULL);
		return TCL_ERROR;
	} else {
		/* clear peo */
		Tcl_ObjSetVar2(interp, OraMsgArray, OM_peo, OMV_zero, TCL_GLOBAL_ONLY);
	}

	/* get description of column so we know which datatype we're dealing with */

	new_col = alloc_col();
	if (new_col == NULL) {
		close(fd);
		oTcl_ErrorMsg(interp, objv[0], ": cannot malloc new col", NULL, NULL);
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
		oTcl_ErrorMsg(interp, objv[0], ": odescr error", NULL, NULL);
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
		oTcl_ErrorMsg(interp, objv[0], ": row not found for long", NULL, NULL);
		return TCL_ERROR;
	}

	if (OraCurs[hand].cda->rc != COL_TRUNCATED &&
                  OraCurs[hand].cda->rc != 0) {          /* problem */
		close(fd);
		free_cols(new_col);
		get_ora_err(interp, hand);
		oTcl_ErrorMsg(interp, objv[0], ": oexec/ofetch failed", NULL, NULL);
		return TCL_ERROR;
	}

#ifdef VERSION7
    
	/* at this point, the version 7 oflng() can be used since we */
	/* have retrieved the long column */

	if ((data_ptr = ckalloc(LONG_BUFF_SIZE)) == NULL) {
		close(fd);
		free_cols(new_col);
		oTcl_ErrorMsg(interp, objv[0], ": cannot malloc memory for column fetch", NULL, NULL);
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
		oTcl_ErrorMsg(interp, objv[0], ": cannot malloc memory for column fetch", NULL, NULL);
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
		oTcl_ErrorMsg(interp, objv[0], ": could not write data", NULL, NULL);
		return TCL_ERROR;
	}

	/* end of version 6 code */

#endif

	/* common cleanup & return code */
	close(fd);
	ckfree(data_ptr);
	free_cols(new_col);

	/* return total bytes sent */
	Tcl_SetObjResult(interp, Tcl_NewLongObj(long_size));

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Cur_List --
 *    Implements the oracurlist command:
 *    usage: oracurlist lda_handle
 *
 *    results:
 *	null string
 *      TCL_OK - list if built
 *      TCL_ERROR - wrong # args
 *----------------------------------------------------------------------
 */

int
Oratcl_Cur_List (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	cur, hand;
	int	oColsc;
	char	buf[ORA_MSG_SIZE];

	/* can't use ora_prologue, oracurlist just uses an lda handle */
	if (objc < 2) {
		Tcl_WrongNumArgs(interp, objc, objv, "lda_handle");
		return TCL_ERROR;
	}

	if ((hand = get_ora_lda_handle(interp, objv[1])) == -1) {
		oTcl_ErrorMsg(interp, objv[0], ": lda_handle ", objv[1], " not valid");
		return TCL_ERROR;
	}

	oColsc = 0;
	for (cur = 0; cur < ORATCLCURS; cur++) {
		if (OraCurs[cur].cur_in_use && (OraCurs[cur].lda_num == hand)) {
			if (oColsc >= oColslen) {
				oColslen += 10;
				oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
			}
			sprintf(buf, "%s.%d", Tcl_GetStringFromObj(objv[1], NULL), cur);
			oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		}
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 * Oratcl_Lda_List --
 *    Implements the oraldalist command:
 *    usage: oraldalist
 *
 *    results:
 *	null string
 *      TCL_OK - list if built
 *      TCL_ERROR - wrong # args
 *----------------------------------------------------------------------
 */

int
Oratcl_Lda_List (clientData, interp, objc, objv)
	ClientData	clientData;
	Tcl_Interp	*interp;
        int		objc;
        Tcl_Obj		*CONST objv[];
{
	int	hand;
	int	oColsc;
	char	buf[ORA_MSG_SIZE];

	oColsc = 0;
	for (hand = 0; hand < ORATCLLDAS; hand++) {
		if (OraLdas[hand].lda_in_use) {
			if (oColsc >= oColslen) {
				oColslen += 10;
				oColsv = (Tcl_Obj **) ckrealloc ((char *) oColsv, oColslen * sizeof(*oColsv));
			}
			sprintf(buf, "%s%d", OraHandlePrefix, hand);
			oColsv[oColsc++] = Tcl_NewStringObj(buf, -1);
		}
	}
	Tcl_SetObjResult(interp, Tcl_NewListObj(oColsc, oColsv));

	return TCL_OK;
}

/* finis */
