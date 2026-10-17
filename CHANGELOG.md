# Oratcl ChangeLog

> Converted from the original `ChangeLog` (2004-2026) and `ChangeLog.2003`
> (1993-2003) into a single Markdown file, most recent changes first. Entry
> text is otherwise preserved as written at the time.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h`: define CONST84 fallback as 'const' for Tcl 9 compatibility.
- `generic/oratcl.c`, `generic/oraexec.c`, `generic/orafetch.c`, `generic/oralong.c`, `generic/oraparse.c`: replace (ub4) 0 with NULL in OCI_AttrGet calls to fix -Wnon-literal-null-conversion warnings.
- `generic/oratcl.c`: remove unused variable rc in Oratcl_Init.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/oraautocom.c`, `generic/orabind.c`, `generic/orabindexec.c`, `generic/orabreak.c`, `generic/oraclose.c`, `generic/oracommit.c`, `generic/oraconfig.c`, `generic/oradesc.c`, `generic/oraexec.c`, `generic/orafetch.c`, `generic/orainfo.c`, `generic/oralob.c`, `generic/oralogoff.c`, `generic/oralogon.c`, `generic/oralong.c`, `generic/oramsg.c`, `generic/oraopen.c`, `generic/oraparse.c`, `generic/oraplexec.c`, `generic/oraroll.c`, `generic/orasql.c`, `generic/oratcl.c`: convert all K&R style function definitions to ANSI C prototypes for C23 compatibility.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: remove unused variable iTcl in Oratcl_ColAppend.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`, `generic/orabindexec.c`, `generic/oradesc.c`, `generic/oraexec.c`, `generic/oralogon.c`, `generic/oralong.c`, `generic/oraparse.c`, `generic/oratcl.c`: fix Tcl_Size type mismatches for Tcl 9 where Tcl_Size changed from int to ptrdiff_t.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `tclconfig/tcl.m4`, `tclconfig/install-sh`: update TEA from 3.6 to 3.13.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h`: fix _ANSI_ARGS_ macro for Tcl 9.
- `generic/oratcl.c`: fix TCL_MAJOR_VERSION conditionals for Tcl 9, include dlfcn.h unconditionally on POSIX.
- `configure.in`: bump version to 5.0, update TEA_INIT to 3.13, add --with-oracle-directory option for Oracle SDK include path.

## 2026-02-17  Todd Helfter <thelfter@gmail.com>

- `generic/oralogon.c`: fix arg processing loop for -sysdba, -sysoper, -sysasm options. Was incorrectly using objv[2] instead of objv[i] causing only the first option to be checked repeatedly.

## 2017-10-12  Todd Helfter <thefter@gmail.com>

- `generic/oratcl.c`: sourceforge bug #71 - fix query results for 'long' column types that were not properly handling the 'oraconfig longsize' values.

## 2017-10-07  Todd Helfter <thefter@gmail.com>

- `orabind.c`: 
- `oraexec.c`: fix cast and type warnings

## 2017-10-04  Todd Helfter <thefter@gmail.com>

- `oralogon.c`: convert int to size_t

## 2017-10-02  Todd Helfter <thefter@gmail.com>

- `Makefile.in`: update to match the latest sampleextension

## 2017-09-29  Todd Helfter <thefter@gmail.com>

- `configure`, `configure.in`, `tclconfig/tcl.m4`: update to TEA 3.10

## 2017-09-24  Todd Helfter <thefter@gmail.com>

- `generic/oradefs.h`, `generic/oralogon.c`: set attribute for OCI_ATTR_DRIVER_NAME. This will show 'Oratcl' as the CLIENT_DRIVER field in v$session_connect_info view. Example: select osuser, client_driver from v$session_connect_info;
OSUSER                         CLIENT_DRIVER ------------------------------ ------------------------------ thelfter                       Oratcl thelfter                       Oratcl thelfter                       Oratcl oracle                         SQL*PLUS oracle                         SQL*PLUS oracle                         SQL*PLUS

## 2017-09-24  Todd Helfter <thefter@gmail.com>

- `generic/oralogon.c`: correct a parameter to :OCI_ServerAttach

## 2017-09-23  Todd Helfter <thefter@gmail.com>

- `tests/oralob.test`: use the new [orainfo nlsgetinfo] to compare NLS_CHARACTER_SET and skip certain lob tests that fail when the character sets do not match between the client and the server.

## 2017-09-22  Todd Helfter <thefter@gmail.com>

- `generic/oratcl.c`, `generic/orainfo.c`, `generic/oratclTypes.h`: expand the 'orainfo' command with 'release' to return server release string in #.#.#.#.# format. orainfo client and orainfo server now return the same format. orainfo version still returns the full oracle banner text.

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `generic/orainfo.c`: correct number conversion of wide int and code beautification.

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `generic/oratcl.c`, `generic/oratclTypes.h`: expand the 'orainfo nlsgetinfo' command with additional numberic NLS_PARAMETERS:  NLS_CHARSET_MAXBYTESZ, NLS_CHARSET_MAXBYTESZ

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `doc/oratcl.html`, `doc/oratcl.n`, `generic/oratcl.c`, `generic/orainfo.c`, `generic/oradefs.h`, `generic/oratclTypes.h`: expand the 'orainfo' command with 'nlsgetinfo' to return NLS_PARAMETER values such as NLS_CHARACTER_SET

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `update copyright dates`

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `tests/oralogon.test`: use regexp to detect oracle error codes instead of specific pattern matches.

## 2017-09-21  Todd Helfter <thefter@gmail.com>

- `update copyright dates`

## 2016-03-29  Todd Helfter <thefter@gmail.com>

- `doc/oratcl.html`, `doc/oratcl.n`, `generic/oralob.c`, `generic/oralong.c`, `library/oralob.tcl`, `library/oralong.tcl`, `tests/oralob.test`, `tests/oralong.test`: implement feature request #10  submitted by Andrew Martin.  oralong, oralob and orafetch should use -datavariable parameter consistently.  This change may not be backward compatible.

## 2016-03-29  Todd Helfter <thefter@gmail.com>

- `tests/oralogon.test`: update error codes for 12c

## 2012-07-18  Andreas Kupries <andreask@activestate.com>

- `generic/oraconfig.c`, `generic/orafetch.c`, `generic/orainfo.c`, `generic/oramsg.c`, `generic/oratcl.c`: add 'static' to declaration of elements in Tcl_GetIndexFromObj() calls;

## 2009-11-06  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: prettyDesc() - if number type has precision 0, do not print the precision and scale.

## 2009-11-06  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: removed a debugging print

## 2009-10-28  Todd Helfter <thelfter@gmail.com>

- `tests/slaveinterps.test`: use -exact instead of exact in package require.  Apparently newer versions of TCL are more forgiving on the exact syntax.

## 2009-10-27  Todd Helfter <thelfter@gmail.com>

- `tests/oradesc.test`: handle the case where OS authentication allows the username parameter in the test to be NULL.  If username is NULL, query the CURRENT_SCHEMA from the database.

## 2009-10-26  Todd Helfter <thelfter@gmail.com> <Andreas Kupries>

- `.cvsignore`: added teapot.txt

## 2009-10-26  Todd Helfter <thelfter@gmail.com> <Andreas Kupries>

- `teapot_oratcl.txt.in`: removed file
- `teapot.txt.in`: added file
- `configure.in`: add code for teapot.txt build
- `configure`: regenerated
- `makefile.in`: add code to install teapot.txt in package lib dir.

## 2009-10-22  Todd Helfter <thelfter@gmail.com> <Andreas Kupries>

- `configure.in`: generate teapot_oratcl.txt
- `configure`: regenerated
- `teapot_oratcl.txt.in`: added file

## 2009-10-22  Todd Helfter <thelfter@gmail.com>

- `tests/oradesc.test`: complete rewrite of the oradesc test script. The test now determines if the object creation was successful and only attempts the test if the object to be described could be created. This avoids a false error when the database user does not have a particular permission such as 'CREATE PUBLICY SYNONYM'.

## 2009-10-15  Andreas Kupries

- `generic/orabind.c`, `generic/oratcl.c`, `generic/oratclInt.h`, `generic/oratclTypes.h`: 1) remove c++ style comments // as AIX does not support them. : 2) move function pointer declarations into oratcl.c and creat declarations in oratclTypes.h - this ensures the variables are defined only once and shared by all and allows OSX builds to compile. : 3). mv strcasecmp -> strnicmp definition to oratclInt.h so that oralogon.c (which now uses it) can acces it properly.

## 2009-10-15  Todd Helfter <thelfter@gmail.com>

- `tests/fullrun.test`: use package require -exact
- `tests/slaveinterps.test`: 

## 2009-10-14  Todd Helfter <thelfter@gmail.com>

- `tests/defs.tcl`: [BUG 2878142] increase version number to 4.6 in CVS head

## 2009-10-07  Todd Helfter <thelfter@gmail.com>

- `library`: oratcl_utils.tcl - bump version to 4.5 and add new procedure prettyDesc
Version 4.5, Production

## 2009-10-02  Todd Helfter <thelfter@gmail.com>

- `all`: branched the oratcl-4-5-branch set the version to 4.6 in the CVS head for development

## 2009-09-30  Todd Helfter <thelfter@gmail.com>

- `tests/all.tcl`: remove printing of globals, using namespaces keeps the main interp clean.

## 2009-09-29  Todd Helfter <thelfter@gmail.com>

- `tests/orabind.test`: update for proper usage of ::tcltest
- `tests/oraexec.test`: 
- `tests/orabindexec.test`: 
- `tests/oraplexec.test`: 
- `tests/oracols.test`: 
- `tests/oralong.test`: 
- `tests/async.test`: 
- `tests/merge.test`: 
- `tests/oralob.test`: 
- `tests/unicode.test`: 

## 2009-09-29  Todd Helfter <thelfter@gmail.com>

- `tests/orafetch.test`: update for proper usage of ::tcltest

## 2009-09-29  Todd Helfter <thelfter@gmail.com>

- `tests/usertype.test`: update usertype.test tests for proper usage of ::tcltest

## 2009-09-29  Todd Helfter <thelfter@gmail.com>

- `tests/codes.test`: update codes.test tests for proper usage of ::tcltest

## 2009-09-29  Todd Helfter <thelfter@gmail.com>

- `tests/oratcl.c`: remove Oratcl_SafeInit : Tcl no longer exposes the '::env' global array to safe interps.  Oracle libraries require the env(ORACLE_HOME) to be set, so there is no longer any reason to support trying to load Oratcl into a safe interp.
- `tests/all.tcl`: remove call to safe.test, add call to slaveinterps.test
- `tests/safe.tcl`: file removed
- `tests/slaveinterps.test`: file added
since there is now only a single cleanup function.

## 2009-09-27  Todd Helfter <thelfter@gmail.com>

- `tests/oratcl.c`: [BUG 2817940] moved contents of Oratcl_Clean() into Oratcl_Delete since there is now only a single cleanup function.

## 2009-09-27  Todd Helfter <thelfter@gmail.com>

- `tests/oratcl.c`: [BUG 2817940] improve null pointer detection in Oratcl_Clean

## 2009-09-27  Todd Helfter <thelfter@gmail.com>

- `tests/oratcl.c`: [BUG 2817940] remove unnecessary exit handler Oratcl_Exit

## 2009-09-27  Todd Helfter <thelfter@gmail.com>

- `tests/oratcl.h`: [BUG 2817940] remove unused function header Oratcl_Kill

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oralogon.test`: Apply constraints that require oralogon and oralogoff procs.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/orainfo.test`: Improve error code testing and update to tcltest v2.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `generic/oraclose.test`: update oraclose to return 0 instead of null on success.
- `tests/oraopen.test`: 

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oraopen.test`: Improve error code testing and update to tcltest v2.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oralogon.test`: Improve error code testing and update to tcltest v2.

## 2009-06-24  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: BUG 2811878] Correct the [oracols $stm name] functionality for pl/sql.

## 2008-12-22  Todd Helfter <thelfter@gmail.com>

- `generic/oraparse.c`: Correct the [oramsg $stm ocicode] functionality.
- `generic/oraexec.c`: 

## 2008-12-21  Todd Helfter <thelfter@gmail.com>

- `generic/oramsg.c`: The ARRAYDML patch, caused core dumps in oramsg.c. This has been corrected.

## 2008-08-30  Todd Helfter <thelfter@gmail.com>

- `tests/safe.test`: BUG [2078194] Safe Interps can [package require] since Tcl 8.5.3.  The safe test will fail on Tcl older than 8.5.3

## 2008-08-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: BUG [2049761] remove an unneeded ckfree() call.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `generic/oraexec.c`: XOR the various oci_mode options together; such as OCI_COMMIT_ON_SUCCESS and OCI_BATCH_ERRORS.  This allows arraydml and autocommit to work properly in the same oraexec.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `tests/arraydml.test`: add additional tests for arraydml.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: allow caller to specify tile them as a parameter

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `tests/all.tcl, tests/arraydml.test`: new test file for array dml
- `generic/oraexec.c`: oraexec now returns oracle API error message for array dml operations instead of a pre-set value.

## 2007-12-16  Todd Helfter <thelfter@gmail.com>

- `Makefile.in`: 
- `configure, configure.in`: 
- `tclconfig/tcl.m4`: update to TEA 3.6

## 2007-12-16  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: correct the offset computation in the ColAppend to account for the '\0' null byte.

## 2007-12-14  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: new file
- `configure.in`, `configure`, `Makefile.in`: provide a new package 'Oratcl::utils' with additional features including GUI login dialog boxes.

## 2007-12-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h`: BUG [1708729] set the default LOBPSIZE back to 10000, a value that works with the pl/sql wrappers in the oralob command, but is too small for DML lob support performance.

## 2007-12-13  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`, `generic/oraexec.c`: correct issues with -arraydml flag to orabind. Poor logic in orabind.c caused abort.  List error handling part from original patch not applied to oraexec.c

## 2007-12-12  Todd Helfter <thelfter@gmail.com>

- `generic/oraplexec.c`, `generic/orabindexec.c`: #1725882 : memory leak in oralob alloc/free This was really a leak of Tcl_Obj from the objv duplication methods in		oraplexec and orabindexec.  Corrected this leak.

## 2007-12-11  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`, `generic/oratclTypes.h`: Slight correction of the OCIBindDynamic() prototype and some (dvoid *) castes to eliminate compile warning about changin pointer types in the new arraydml code.

## 2007-12-10  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `generic/orabind.c`, `generic/oramsg.c`, `generic/oraopen.c`, `generic/oratcl.c`, `generic/oratclInt.h`, `generic/oratclTypes.h`: Implement an array dml feature for bulk loading data (insert/update) using a patch submitted by Jeremy Collins about four years ago.  1000 row inserts using array dml execute in about 5% of the time as a traditional loop, bind, exec.

## 2007-12-09  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `doc/oratcl.html`: Correct a typo

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `generic/oralob.c`, `generic/oralong.c`, `generic/oratcl.c`, `generic/oratcl.h`, `generic/oratclInt.h`, `generic/oratypes.h`, `tests/async.test`, `tests/codes.test`, `tests/orabind.test`, `tests/orabindexec.test`, `tests/oracols.test`, `tests/oracommit.test`, `tests/oradesc.test`, `tests/oraexec.test`, `tests/orafetch.test`, `tests/orainfo.test`, `tests/oralob.test`, `tests/oralogin.test`, `tests/oralogon.test`, `tests/oralong.test`, `tests/oraopen.test`, `tests/oraparse.test`, `tests/oraplexec.test`, `tests/orasql.test`, `tests/safe.test`, `tests/usertype.test`: update copyright date

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `configure.in`, `configure`: reoganize .c modules build list for neatness

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `generic/oraparse.c`: new file
- `generic/orasql.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`: new file
- `generic/orabindexec.c`: new file
- `generic/orabreak.c`: new file
- `generic/oraconfig.c`: new file
- `generic/oradesc.c`: new file
- `generic/oraexec.c`: new file
- `generic/orafetch.c`: new file
- `generic/oraplexec.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oralogon.c`: remove unneeded code that was ifdef'd out.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oralogon.c`: new file
- `generic/oralogoff.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oraautocom.c`: new file
- `generic/oraclose.c`: new file
- `generic/oracommit.c`: new file
- `generic/orainfo.c`: new file
- `generic/oramsg.c`: new file
- `generic/oraopen.c`: new file
- `generic/oraroll.c`: new file
- `generic/oratclExtern.h`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`, `generic/oralob.c`, `generic/oralong.c`, `doc/oratcl.html`, `doc/oratcl.n`, `tests/orainfo.test`: standardize naming of a 'logonhandle'. Since the relevent function is 'oralogon' the item returned is a logonhandle.  The 'orainfo' command inccorectly had an option for the 'loginhandle' (misspelled).  'orainfo', now accepts 'logonhandle' and a future version of OraTcl will deprecate the 'loginhandle' option. ** Future code incompatibility

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `generic/oratcl.c`, `doc/oratcl.n`, `doc/oratcl.html`: add 3 new options to 'oralogon'.  -sysdba, -sysoper and -sysasm

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `doc/oratcl.html`: bump version number to 4.5 and unset release date.

## 2007-11-24  Todd Helfter <thelfter@gmail.com>

- `tests/all.tcl`, `tests/unicode.tcl`, `generic/oratcl.c`: add new unicode processing to orabind and orafetch triggered by the unicode flag which is set with oraconfig.

## 2007-10-29  Todd Helfter

- `generic/oratclInt.h`, `generic/oratcl.c`: add a unicode flag to the Statement Handle structure. allow oraconfig to set and get the unicode flag.

## 2007-10-27  Todd Helfter <thelfter@gmail.com>

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oraopen.test`: Apply constraints that require oraopen and oraclose procs.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oralogon.test`: Apply constraints that require oralogon and oralogoff procs.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/orainfo.test`: Improve error code testing and update to tcltest v2.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `generic/oraclose.test`: update oraclose to return 0 instead of null on success.
- `tests/oraopen.test`: 

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oraopen.test`: Improve error code testing and update to tcltest v2.

## 2009-09-22  Todd Helfter <thelfter@gmail.com>

- `tests/oralogon.test`: Improve error code testing and update to tcltest v2.

## 2009-06-24  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: BUG 2811878] Correct the [oracols $stm name] functionality for pl/sql.

## 2008-12-22  Todd Helfter <thelfter@gmail.com>

- `generic/oraparse.c`: Correct the [oramsg $stm ocicode] functionality.
- `generic/oraexec.c`: 

## 2008-12-21  Todd Helfter <thelfter@gmail.com>

- `generic/oramsg.c`: The ARRAYDML patch, caused core dumps in oramsg.c. This has been corrected.

## 2008-08-30  Todd Helfter <thelfter@gmail.com>

- `tests/safe.test`: BUG [2078194] Safe Interps can [package require] since Tcl 8.5.3.  The safe test will fail on Tcl older than 8.5.3

## 2008-08-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: BUG [2049761] remove an unneeded ckfree() call.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `generic/oraexec.c`: XOR the various oci_mode options together; such as OCI_COMMIT_ON_SUCCESS and OCI_BATCH_ERRORS.  This allows arraydml and autocommit to work properly in the same oraexec.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `tests/arraydml.test`: add additional tests for arraydml.

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: allow caller to specify tile them as a parameter

## 2007-12-17  Todd Helfter <thelfter@gmail.com>

- `tests/all.tcl, tests/arraydml.test`: new test file for array dml
- `generic/oraexec.c`: oraexec now returns oracle API error message for array dml operations instead of a pre-set value.

## 2007-12-16  Todd Helfter <thelfter@gmail.com>

- `Makefile.in`: 
- `configure, configure.in`: 
- `tclconfig/tcl.m4`: update to TEA 3.6

## 2007-12-16  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: correct the offset computation in the ColAppend to account for the '\0' null byte.

## 2007-12-14  Todd Helfter <thelfter@gmail.com>

- `library/oratcl_utils.tcl`: new file
- `configure.in`, `configure`, `Makefile.in`: provide a new package 'Oratcl::utils' with additional features including GUI login dialog boxes.

## 2007-12-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h`: BUG [1708729] set the default LOBPSIZE back to 10000, a value that works with the pl/sql wrappers in the oralob command, but is too small for DML lob support performance.

## 2007-12-13  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`, `generic/oraexec.c`: correct issues with -arraydml flag to orabind. Poor logic in orabind.c caused abort.  List error handling part from original patch not applied to oraexec.c

## 2007-12-12  Todd Helfter <thelfter@gmail.com>

- `generic/oraplexec.c`, `generic/orabindexec.c`: #1725882 : memory leak in oralob alloc/free This was really a leak of Tcl_Obj from the objv duplication methods in		oraplexec and orabindexec.  Corrected this leak.

## 2007-12-11  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`, `generic/oratclTypes.h`: Slight correction of the OCIBindDynamic() prototype and some (dvoid *) castes to eliminate compile warning about changin pointer types in the new arraydml code.

## 2007-12-10  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `generic/orabind.c`, `generic/oramsg.c`, `generic/oraopen.c`, `generic/oratcl.c`, `generic/oratclInt.h`, `generic/oratclTypes.h`: Implement an array dml feature for bulk loading data (insert/update) using a patch submitted by Jeremy Collins about four years ago.  1000 row inserts using array dml execute in about 5% of the time as a traditional loop, bind, exec.

## 2007-12-09  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `doc/oratcl.html`: Correct a typo

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `generic/oralob.c`, `generic/oralong.c`, `generic/oratcl.c`, `generic/oratcl.h`, `generic/oratclInt.h`, `generic/oratypes.h`, `tests/async.test`, `tests/codes.test`, `tests/orabind.test`, `tests/orabindexec.test`, `tests/oracols.test`, `tests/oracommit.test`, `tests/oradesc.test`, `tests/oraexec.test`, `tests/orafetch.test`, `tests/orainfo.test`, `tests/oralob.test`, `tests/oralogin.test`, `tests/oralogon.test`, `tests/oralong.test`, `tests/oraopen.test`, `tests/oraparse.test`, `tests/oraplexec.test`, `tests/orasql.test`, `tests/safe.test`, `tests/usertype.test`: update copyright date

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `configure.in`, `configure`: reoganize .c modules build list for neatness

## 2007-12-08  Todd Helfter <thelfter@gmail.com>

- `generic/oraparse.c`: new file
- `generic/orasql.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/orabind.c`: new file
- `generic/orabindexec.c`: new file
- `generic/orabreak.c`: new file
- `generic/oraconfig.c`: new file
- `generic/oradesc.c`: new file
- `generic/oraexec.c`: new file
- `generic/orafetch.c`: new file
- `generic/oraplexec.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oralogon.c`: remove unneeded code that was ifdef'd out.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oralogon.c`: new file
- `generic/oralogoff.c`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-12-07  Todd Helfter <thelfter@gmail.com>

- `generic/oraautocom.c`: new file
- `generic/oraclose.c`: new file
- `generic/oracommit.c`: new file
- `generic/orainfo.c`: new file
- `generic/oramsg.c`: new file
- `generic/oraopen.c`: new file
- `generic/oraroll.c`: new file
- `generic/oratclExtern.h`: new file
- `configure.in`, `configure`, `generic/oratcl.c`: Break up oratcl.c source file into smaller units for easier management and revision control.

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`, `generic/oralob.c`, `generic/oralong.c`, `doc/oratcl.html`, `doc/oratcl.n`, `tests/orainfo.test`: standardize naming of a 'logonhandle'. Since the relevent function is 'oralogon' the item returned is a logonhandle.  The 'orainfo' command inccorectly had an option for the 'loginhandle' (misspelled).  'orainfo', now accepts 'logonhandle' and a future version of OraTcl will deprecate the 'loginhandle' option. ** Future code incompatibility

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `generic/oratcl.c`, `doc/oratcl.n`, `doc/oratcl.html`: add 3 new options to 'oralogon'.  -sysdba, -sysoper and -sysasm

## 2007-11-29  Todd Helfter <thelfter@gmail.com>

- `doc/oratcl.n`, `doc/oratcl.html`: bump version number to 4.5 and unset release date.

## 2007-11-24  Todd Helfter <thelfter@gmail.com>

- `tests/all.tcl`, `tests/unicode.tcl`, `generic/oratcl.c`: add new unicode processing to orabind and orafetch triggered by the unicode flag which is set with oraconfig.

## 2007-10-29  Todd Helfter

- `generic/oratclInt.h`, `generic/oratcl.c`: add a unicode flag to the Statement Handle structure. allow oraconfig to set and get the unicode flag.

## 2007-10-27  Todd Helfter <thelfter@gmail.com>

- `tests/oradesc.test`, `generic/oratcl.c`: implemented #876838 : oradesc on views

## 2007-10-27  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: add BINARY_FLOAT and BINARY_DOUBLE to the list of known types

## 2007-10-27  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `tests/all.tcl`, `tests/merge.test`, `generic/oralob.c`: fixed #1815636 [oramsg rows] returns 0 after 'MERGE' statement

## 2007-10-27  Todd Helfter <thelfter@gmail.com>

- `generic/oralob.c`: fixed #1806291 regression: orafetch -command doesn't return rc code

## 2007-10-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`, `generic/oratclInt.h`, `generic/oratcl.n`, `generic/oratcl.html`: restoring the 'utfmode' configuration options.. Unicode will be added as a separate feature.

## 2007-10-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`, `generic/oratclInt.h`, `generic/oratcl.n`, `generic/oratcl.html`: converted the 'utfmode' configuration option to 'unicode' for oraconfig.  Oratcl finally can read and write Unicode objects in to and out of the database.  So far tested on RedHat EL 5, with Oracle 11g and Tcl 8.5b1.   Note that Unicode LOBS are not yet implemented.

## 2007-02-01  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`, `generic/oratcl.c`: add code to correctly report new 10g types SQLT_IBFLOAT and SQLT_IBDOUBLE as BINARY_FLOAT and BINARY_DOUBLE when describing columns or tables.  This change affects the 'oradesc' and 'oracols' functions.  Previously, these would have returned UNKNOWN as the type.

## 2006-06-30  Todd Helfter

- `doc/FAQ.html`: update FAQ

## 2006-05-11  Todd Helfter

- `changing version to 4.5 for cvs-head, development occurs here.`

## 2006-05-11  Todd Helfter

- `generic/oralob.c`, `generic/oralong.c`: Reorganize so variable declarations come before for loops

## 2006-04-13  Todd Helfter <

- `generic/oratcl.c`: initialize ColPtr->dty to SQLT_STR.

## 2006-03-23  Todd Helfter <

- `generic/oratcl.c`: 
- `generic/oratclInt.h`: Found that the entire global linked list of Oratcl state pointers OratclSLP was unnecessary, the interp delete callback is sufficient to clean up from slave interps..

## 2006-03-21  Todd Helfter <

- `generic/oratcl.c`: New [orainfo client] command will return 0.0.0.0.0 if the client version is not 10g or higher.  The OCI function does not exist in the 8i and 9i libraries.  Also added some Tcl_IsShared() tests to orasql and oraplexec.

## 2006-03-16  Todd Helfter <

- `generic/oratcl.c`: 
- `generic/oratclInt.h`: Massive cleanup of oratcl.c concerning Tcl_Objs and refCounts.

## 2006-03-16  Todd Helfter <

- `generic/oralob.c`: 
- `generic/oralong.c`: Fix error message format to use %zu for (size_t) and fix message typo.

## 2006-03-16  Todd Helfter <thelfter@gmail.com>

- `Oratcl is now able to execute the test suite aka. 'make test' using Tcl 8.5. The test suite works in both threaded and non-threaded 8.5a4 and 8.4.13`

## 2006-03-16  Todd Helfter <thelfter@gmail.com>

- `tests/oralong.test`: recode test so that write + read operations occur in the same test proc.  simultaneous read and write of the same row will result in an Oracle error being returned and the Tcl 8.5 test suite runs each test in a separate thread, concurrently.

## 2006-03-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: Fix 3 castes for OCI parameters to correct compiler warnings.

## 2006-03-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: Recode Oratcl_LongWrite() to work properly with 10g libraries.

## 2006-03-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: New functionality [orainfo client] returns the oracle client library
- `generic/oratclTypes.h`: version information.  I.E. 9.2.0.7.0 or 10.2.0.1.0
- `doc/oratcl.n`: 
- `doc/oratcl.html`: 

## 2006-03-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: 
- `generic/oratclInt.h    remove member sub_len from OratclStms.`

## 2006-03-15  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: 
- `generic/oratclInt.h    remove typedef OratclSubs and member sub_list from OratclStms.`

## 2006-03-14  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: check for ckalloc() returning NULL. only call ckfree() if object is not NULL.

## 2006-03-14  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: 
- `generic/oratclInt.h`: remove global Tcl_Obj OMV_null.

## 2006-03-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: 
- `generic/oratclInt.h`: remove unused tListObjType global variable

## 2006-03-13  Todd Helfter <thelfter@gmail.com>

- `generic/oradefs.h`: Add string representations of some numbers to avoid code conversions
- `generic/oratcl.c`: Use string rep. instead of number conversion to strings.
- `generic/oratcl.c`: Oratcl_Checkerr() Use dynamic string buffer, eliminate static char buffer.

## 2006-03-13  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h`: remove unused members lobid and lobHash from struct OratclState

## 2006-03-12  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: Oratcl_Checkerr() improve Tcl_Obj handling.
- `generic/oratcl.c`: Oratcl_Bind() correct error handling.

## 2006-03-11  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: Oratcl_Exec() will now return specific Oracle error message instead of the generic message it previously returned.

## 2006-03-11  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c Oratcl_Open() eliminated a memory leak caused by initializing the StmPtr->nullvalue twice.`

## 2006-03-11  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c Oratcl_ErrorMsg()  Use Tcl_AppendObjToObj() eliminating a needless string conversion.`

## 2006-03-10  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c improve handling of temporary Tcl_Obj with proper calls to Tcl_IncrRefCount and Tcl_DecrRefCount.`

## 2006-03-10  Todd Helfter <thelfter@gmail.com>

- `tests/codes.test tests/oracommit.test tests/orainfo.test test/oraopen.test test/oraparse.test  changes to use the features of the tcltest package.`

## 2006-03-09  Todd Helfter <thelfter@gmail.com>

- `generic/oralob.c correct several usages of the tcl 'return' function. -errorinfo is not a recognized parameter (anymore?)`, `tests/oralob.test I get an ORA-01460 error for lob pieces > 32500`, `tests/oralob.test Compare the results of 'oralob read' and 'select from table'`

## 2006-01-25  Jeff Hobbs  <jeffh@ActiveState.com>

- `Makefile.in`: 
- `configure, configure.in`: update to TEA 3.5
- `tclconfig/tcl.m4`: TEA rcs 1.89 2006/01/25 21:25:02

## 2005-12-16  Todd Helfter <thelfter@gmail.com>

- `generic/oratclInt.h Increase default value of ORA_LOBP_SIZE`

## 2005-12-16  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c Allow for the direct reading of LOBS using SQL select. maximum value of lobpsize (oraconfig) increased.  Original idea and sample code contributed by Peter Schindler with Synchronicity Inc. <pschindler@synchronicity.com>`

## 2005-11-18  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c Recognize a new environment variable ORACLE_LIBRARY. On platforms where libclntsh has to be loaded (WIN32 uses OCI.DLL), allow for an environment variable to specify where to find the file at load time.  Default behavior is to load this library: ORACLE_HOME/lib/libcltntsh.SHLIB_SUFFIX`
now if ORACLE_LIBRARY environment variable is set.  The contents of that variable will be passed to the dlopen() function call.

Example 1: For 10gR2 instant client on solaris. Bash:  export ORACLE_LIBRARY=/path/to/libclntsh.so.10.1 Csh:   setenv ORACLE_LIBRARY /path/to/libclntsh.so.10.1

Example 2: For 32 bit tcl on 64 bit solaris with 64 bit oracle. Bash:  export ORACLE_LIBRARY=$ORACLE_HOME/lib32/libclntsh.so Csh:   setenv ORACLE_LIBRARY $ORACLE_HOME/lib32/libclntsh.so

## 2005-06-21  Todd Helfter <thelfter@gmail.com>

- `generic/oralob.c Add a missing Tcl_DecrRefCount() to the error condition. Fixes BugID 1221820 Thanks to Markus Elfring <elfring@users.sourceforge.net> for the patch.`

## 2005-05-25  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c increase the amount of memory allocated for columns of type SQLT_RID and SQLT_RDD from 23 bytes to 140 bytes.`

## 2005-05-15  Todd Helfter <thelfter@gmail.com>

- `generic/oralong.c Add a missing Tcl_DecrRefCount() to the error condition. Fixes BugID 1221820 Thanks to Markus Elfring <elfring@users.sourceforge.net> for the patch.`

## 2005-04-22  Todd Helfter <thelfter@gmail.com>

- `generic/oralob.c  Handle return codes from Tcl_SetVar2(), replace calls to Tcl_Eval with Tcl_EvalObjEx()`
- `generic/oralong.c  Handle return codes from Tcl_SetVar2(), replace calls to Tcl_Eval with Tcl_EvalObjEx()`
Thanks to Markus Elfring <elfring@users.sourceforge.net> for the patch.

## 2005-03-23  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c  Fix path generation to work with Tcl 8.3`

## 2005-03-22  Todd Helfter <thelfter@gmail.com>

- `generic/oratcl.c`: Handle ORA-28002 'warning password is about to expire.  Allow login, but place message in oramsg buffer.

## 2005-03-18  Jeff Hobbs  <jeffh@ActiveState.com>

- `Makefile.in (AR)`: use @AR@
- `configure, configure.in, tclconfig/tcl.m4: TEA 3.2 update`

## Feb 14 2005

Relocate a Tcl_DecrRefCount() call to after the call to DLOPEN. Thanks to Miguel Bagnon (miguel@bagnon.com) for the patch.

## 2005-01-28  Jeff Hobbs  <jeffh@ActiveState.com>

- `generic/oratcl.c`: include dl.h on hpux
- `Makefile.in (pkgIndex.tcl)`: generate pkgIndex.tcl by hand instead of with pkg_mkIndex.  This ensures correct creation even when the oracle client libraries are not on the build machine.
Oratcl change history

Version 4.4,  Beta

Add support for information returned by the dlerror() system call. HPUX still needs to be supported. Thanks to Miguel Bagnon (miguel@bagnon.com) for the patch.

Version 4.3,  Nov, 2004

## Jan 06 2005

If configured with --enable-threads, the -DTCL_THREADS macro is defined. If TCL_THREADS is defined, call OCIEnvInit with multiple modes: OCI_OBJECT | OCI_THREADED

## Jan 06 2005

Streamlined and improved error handling and memory cleanup in Oratcl_Commit. Streamlined and improved error handling and memory cleanup in Oratcl_Rollback.

## Jan 05 2005

Streamlined and improved error handling and memory cleanup in Oratcl_Logon. Logon function pays more attention to return codes from OCI layer. Logon function returns Oracle error code and message.

I.E.

% oralogon log/bad_pass@good_db ORA-01017: invalid username/password; logon denied % oralogon log/good_pass@bad_db ORA-12154: TNS:could not resolve service name

## Dec 17 2004

Add code to obtain additional symbols in the oracle library: OCIDescriptorAlloc OCIDescriptorFree OCILobRead OCILobGetLength These library functions are not yet used but will be needed to read CLOB and BLOB columns directly with SQL.

## Nov 29 2004

**  Incorporate patches provided by Christian Traber (christian@traber-net.de) These patches add a new TAF failover functionality to Oratcl.. "Its a new option (-failovercallback <procanme>) for the oralogon command. The given procedure is called from OCI on TAF failover. I use it to reexecute "alter session" statements after the automatic reconnect in case of failover to another RAC node."

## Nov 29 2004

add .cvsignore file in root directory Renamed oraconst.h to oradefs.h Fix oratypes.h to work in windows and unix. Update COPYRIGHT info in each file Remove the RTLD_NODELETE flag from dlopen()

## Nov 22 2004

Improvements to the autoconf scripts provide more introspection.

## Nov 20 2004

- `Dynamic loading of oracle share library now builds a path containing these elements: env(ORACLE_HOME) lib libclntsh.so for unix.`, `Oratcl_Init() returns an error if env(ORACLE_HOME) is not defined for unix.`, `Removed all code supporting Oracle 8.0, I can not find a way to detect the Oracle version from the client library contents: API/symbols.`
**** Notice of potential incompatability *** slave interpreters need to have the env(ORACLE_HOME) set before Oratcl can be loaded.  See oratcl/tests/safe.test for an example.

## Nov 14 2004

Converted to TEA build system.

- `test directory moved to tests`, `comfig directory removed`, `tclconfig directory added`, `configure & configure.in replaced`

## Nov 14 2004

Converted to dynamic loading oracle share library.

- `hard coded to load 'oci.dll' for windows.`, `hard coded to load /opt/oracle/product/9.2.0/lib/libclntsh.so for unix.`

## Version 4.2 May, 2003

**08-MAY-2003**

- Corrected massive memory leak of column names in 'oradesc'. This decreases the memory loss in the 'oralong' and 'oralob' commands. Thanks to Manfred Frey (Manfred.Frey@ZF-Lenksysteme.com) for the alert.

**18-MAY-2003**

- Oralogon:: set char * initialization to NULL.  This fixes a core dump when multiple calls are mede to oralogon with no args (an error) when tcl is compiled with --enable-symbols=mem.

**11-Aug-2003**

- Correct compiler warnings with use of the Tcl_GetIndexFromObj(). These were introduced by the CONST prototypes introduced in Tcl 8.4. Thanks to Miguel Bagnon (miguel@bagnon.com) for the patch.
- Revised the error checking code to read the error messages for all the error conditions that the OCI programming guide tells about giving info. For example, OCI_SUCCESS_WITH_INFO is not an error, but still gives info. Thanks to Miguel Bagnon (miguel@bagnon.com) for the patch.

**20-Aug-2003**

- Added a test to the oraexec.test file for the new error detections. Thanks to Miguel Bagnon (miguel@bagnon.com) for the patch.

**01-SEP-2003**

- Added "oralob writeappend" wrapper around  DBMS_LOB.WRITEAPPEND. Thanks to Peter Schindler (pschindler@synchronicity.com) for contributing this enhancement.  Peter provides this comment: "We had a lot of serialization errors with just WRITE, the way oracle handles the storage of CLOBs. With this new function, we were able to reduce the likelihood of a serialization error."

**02-SEP-2003**

- Altered the "oralong read" command.   Changed the "indp" arguement to (void *) 0 in calls to OCIBindByName() and OCIStmtSetPieceInfo(). This fixes an oracle error encountered in "oralong read".

## Version 4.1 August, 2002

- The 'oralob' and 'oralong' commands have been implemented in 'C'. This will make those commands available in slave interps and in other situations where the old tcl file sourcing was made difficult due to auto_path idiosyncracies.  The files 'oralob.tcl' and 'oralong.tcl' will persist in the library directory as a baseline for the new 'oralob.c' and 'oralong.c' files which are created from them.
- Fixed a bug in oraparse that prevented asynchronous transactions from parsing properly with the supplied examples. Thanks to Miguel Bagnon (bagnonm@safelayer.com) for the alert.

**17-SEP-2002**

- Added support for describing user defined types to Oracols and Oradesc.  Began work for a test suite file. Thanks to Olly Stephens (ollystephens@sourceforge.net) for the patch.
- Changed a bogus error message in [orainfo server $lda].
- Added a 'status' option to 'orainfo' that returns the server status. Example: orainfo status $lda Returns 1 if server status is OCI_SERVER_NORMAL Returns 0 if server status is OCI_SERVER_NOT_CONNECTED This is useful for detected loss of server, due to crash or shutdown.
- Rebuilt Oratcl_ColAppend() to use a Tcl_DString instead of a Tcl_Obj ** in the building of the -datavariable option result. This eliminates a Tcl_Obj (24 byte) leak for each result column.

**22-NOV-2002**

- Added support for sysdba and sysoper connections to 'oralogon' usage: oralogon sysdba usage: oralogon sysoper Thanks to Aleksey Kurbatov (akurbatov@borlas.ru) for the patch.

**04-DEC-2002**

- Fixed a bug in orasql that prevented the commit option from working Thanks to Christian Traber (christian@traber-net.de) for the alert.

**12-DEC-2002**

- Changed 'oralogon' to pay attention to the return code from OCIInitialize.  If the return code is not OCI_SUCCESS raise an error. This will avoid a core dump if the ORACLE_HOME environment variable is not set on a unix platform.

**13-DEC-2002**

- Corrected an incorrect word in the documentation, the man page indicated a 'sqlcode' option to the oramsg command.  The option is really 'sqltype'

## Version 4.0 December, 2001

- `Thanks to Dionisios Pothos and Grid Intelligent Systems Ltd, UK for their financial sponsorship of this upgrade.`
- **** oramsg **** array has been removed.  This is not backwards compatible.  The remaining values that were accessed through the oramsg array can be obtained with the new _oramsg_ command.
- Oratcl is now thread safe.
- Added new commands: oraparse - ::oratcl::oraparse - Oratcl_Parse() orabind  - ::oratcl::orabind  - Oratcl_Bind() oraexec  - ::oratcl::oraexec  - Oratcl_Exec() orabreak - ::oratcl::orabreak - Oratcl_Break() These commands operate in normal and async mode. These commands operate on either SQL or PL/SQL statements.
- The commands: orasql, orabindexec, and oraplexec have new internals built out of the primitives Oratcl_Parse, Oratcl_Bind and Oratcl_Exec. Oratcl_Sql is implemented with: Oratcl_Parse() Oratcl_Exec() Oratcl_Bindexec is implemented with: Oratcl_Bind() Oratcl_Exec() Oratcl_Plexec is implemented with: Oratcl_Parse() Oratcl_Bind() Oratcl_Exec()
- **** oraplexec **** no longer returns the bind values as a list, but rather returns the return code like orasql and orabindexec. Use orafetch to retrieve the binded columns.
- **** orafetch **** has a completely new API.  See the man page for details.  This is not backwards compatible.  Also see the test suite for examples.
- Oratcl now works in 64 bit solaris with 64 bit Oracle.
- Correct oradesc to continue describing synonyms until the base table is reached.  Added nested synonym test to oradesc.test. Thanks to Lawrence Little for the alert.
- Reduce dependency on autodetection of EOL i.e. '\0' by using actual string lengths as arguements instead of relying on -1 behavior.
- Enabled proper behavior for new internal datatypes in Oracle 9i in the functions oradesc and oracols.  Since these types are defined in the 8i OCI files, this should be safe for all versions. TIMESTAMP TIMESTAMP WITH TIME ZONE INTERVAL YEAR TO MONTH INTERVAL DAY TO SECOND TIMESTAMP WITH LOCAL TIME ZONE
- Corrected a gaping memory leak in orafetch.  Use of the -dataarray option leaked memory for each column name or number used as the array hash.
- Correct a bug in the oraconfig command.  Attempting to query the fetchrows value incorrectly reports the bindsize. Thanks to Christian Traber (christian@traber-net.de) for the alert.
- Correct a bug in the oralob command that prevented reading or writing a one character string. Thanks to Christian Traber (christian@traber-net.de) for the alert.
- Add two new options to oraconfig:
- numbsize : amount of space to allocate for the data returned for number columns.  Default is 40.
- datesize : amount of space to allocate for the data returned for date columns.  Default is 75.
- Enable binding of clobs when compiled with Oracle 9i.
- 05-MAY-2002 (tmh) fixed compiler warnings about 'const' mismatches.
- 29-MAY-2002 (tmh) change Makefile.in to use TCL_LD_FLAGS.  This lets the --enable-64bit-vis options work when using 64 bit solaris, 64 bit Oracle and the same option in the tcl build.
- Place the new 9i columns inside a #define, not defined in oracle 8.1.5 TIMESTAMP TIMESTAMP WITH TIME ZONE INTERVAL YEAR TO MONTH INTERVAL DAY TO SECOND TIMESTAMP WITH LOCAL TIME ZONE Thanks to Miguel Bagnon (bagnonm@safelayer.com) for the alert.
- Removed several unused variables eliminating compile warnings. Thanks to Miguel Bagnon (bagnonm@safelayer.com) for the alert.

## Version 3.3 September, 2001

Todd M. Helfter, Purdue University tmh@purdue.edu

- fixed an oversight in oradesc that was not describing the table when given the name of a synonym.  This will also fix the problem in oralong, that prevented long operations on a synonym.
- Oracle 9i (9.0.1) returns a precision value for VARCHAR2 and CHAR datatypes.  Prior to this, the precision was always 0 for these datatypes.  /test/oradesc.test has been altered to allow for this.
- Attempt a different method of library directory detection.
- Alter configuration to detect and use Oracle 9i in a unix build.
- Corrected the eval of library files (oralob.tcl, oralong.tcl) from within the 'C' code.  This fixes crash when calling Tcl_GetNameOfExecutable() without having first called Tcl_Init(interp).
- Correct a bug affecting the oralong command.  Attempting to write a zero length string into a long column, put the statement handle in an unrecoverable state. Thanks to Ulrich Schoebel (SchoebelU@spardat.at) for the alert.

## Version 3.2 March, 2001

Todd M. Helfter, Purdue University tmh@purdue.edu

- changed Makefile.in to depend on generic/*.h files.
- changed package to eval library files (oralob.tcl, oralong.tcl) from within the 'C' code.  This change removes the source lines from the pkgIndex.tcl file.  This allows the commands implemented in these files to be available with [interp create] and to those linking directly to the library.  The files will not be sourced with the [interp create -safe] as file I/O has been restricted in this case.
- added statement handle option utfmode to the oraconfig command. Setting this option to true causes oratcl to use the functions: Tcl_UtfToExternalDstring and Tcl_ExternalToUtfDString on string values in orasql, orabindexec, oraplexec, orafetch and oralong. (Note :: oralob is implemented with oraplexec, so it to is affected.)
- fixed a bug in oracols that was not reporting the correct precision of number fields on big-endian systems.

## Version 3.1 October, 2000

Todd M. Helfter, Purdue University tmh@purdue.edu

- applied patches from Don Libes (libes@cme.nist.gov) that allow Oracle 8.0.x to be used with this library.  The basic problem is that Oracle 8.0.x OCI library does not seem to know about LOB types.
- updated oratcl.c to build clean on a windows system.
- relocated configuration files to be common to unix and windows.
- corrected bug in Oratcl_Logon preventing remote_os_authent access. Thanks to Cesar Perez Fernandez (cpf06@tid.es) for the correction.
- added "loginhandle" option to orainfo to facilitate conversions from statement handle back to loginhandle.
- added the library file oralob.tcl to implement a new oralob command.
- added "lobpsize" to oraconfig to manage the piece size in oralob read/writes.
- added the library file oralong.tcl to implement a new oralong command.
- added "longpsize" to oraconfig to manage the piece size in oralong read/writes.
- reorganized the windows prebuilt files directory once again.

## Version 3.0.1 August, 2000

Todd M. Helfter, Purdue University tmh@purdue.edu

- oraautocom change to accept any value acceptable to Tcl_GetBooleanFromObj and to return the setting as "0" for off and "1" for on. This is a fix for TR#3573 and TR#3583.
- all commands changed to use Tcl_Hash values and a clientData structure.
- Handle limits are now imposed by the database/hardware. Modified the test suite to match.
- The define variables ORATCLLDAS and ORATCLSMTS no longer exist.
- oracols now takes optional arguments, array variable no longer set.
- Change oracols to accept optional configuration settings to retrieve information formerly available in the oramsg() array.
- add new command oraconfig to allow memory management of long fields binding, and fetch rows and null values.
- add new command oradesc to allow table describes.
- changed oracols to return the oracle defined byte size instead of the oratcl defined storage size.
- fixed a memory management problem with Oratcl_Clean().

## Version 3.0 June, 2000

Todd M. Helfter, Purdue University tmh@purdue.edu

- OCI 8 calls used exclusively.
- All oracle 7 and 6 support removed entirely.
- async support removed completely. Thus the commands orabreak, oracancel and orapoll no longer exist.
- add -commit flag to orasql and orabindexec.
- add command orainfo to return the output from OCIServerVersion(). extended orainfo to return oratcl version information.
- modified test suite.
- renamed oracurlist to orastmlist

## Version 2.7 August, 1999

Todd M. Helfter, Purdue University tmh@purdue.edu

- use Tcl_Obj type constructs for all commands.
- 2 new functions available in tcl as oraldalist - return a list of all opened ldas oracurlist $lda - return a list of all opened curs for an lda
- Oratcl_Fetch (orafetch) returns the correct number of spaces between columns.  Because of Tcl list operations, this is still a valid list.
old "@0 @1 @2" "foo  bar  rod" new "@0 @1 @2" "foo bar rod"

- Oratcl_FetchAll changed extensively. handle both of the following properly orafetch $cur {} {} foo 1 bar 2 orafetch $cur {} {} {foo 1 bar 2}
Greater tuning of the evaluation string.  No calls to strcpy, bcopy, or memset are used to find the replacement columns. So all the following work more efficiently

orafetch $cur {puts "@0 @1 @2"} orafetch $cur {puts "@0 @1 @2"} {}

## Version 2.6 September, 1999

Mariam Tariq, Scriptics Corporation mtariq@scriptics.com -Note: Oracle 7 OCI API is still used. Oracle 8 libraries still support the Oracle 7 calls. However, new Oracle 8 features such as functions to manipulate LOB's are not accessible by Oratcl. Oratcl needs to be rewritten with the new Oracle 8 API's to take advantage of the new features. -add support for Internationalization features of Tcl8.1 -add stub awareness -OCI 7 call called orlon does not work with some versions of Oracle 8i(e.g. version 8.1.5 on NT). So Oracle 8 OCILogon is used for logging in. The service context handle is then converted to an lda such that the Oracle 7 calls can be used again. Default is to use OCILogon. If using an Oracle 7 DB then -DVERSION7DB compile flag must be used to use orlon

## Version 2.5, November 1997

Change oratcl.c - add support for cursor variables returned by oraplexec, add 'parseonly'  option to orasql, add 'orabindexec' command, add 'async' option for orasql, add 'orapoll' and 'orabreak' commands, add windows .dll support, change orawritelong to allow writing of zero length file, add 'version' element to oramsg.  add tclvars to be bound on orafetch /w commands.  former keywords (async,parseonly,all,etc.) are now recognized as options (-async,-parseonly,-all,etc.)  check orafetch rc code for errors, return tcl_error on failure.  add atexit handler to call Oratcl_Kill, remove call to Oratcl_Kill on command deletion. Fix a problem in FetchAll where the argv[] command string is manipulated, caused problems in Tcl 8.0  Added 'rowid' element to oramsg array, valid after insert, update, delete, or select for update SQL statements.

configure/makefile - configure: change default to --enable-shared, makefile:  now makes libOratcl with a version number.  reorganize distribution directory with generic,unix,mac,win,doc,misc,samples directories.  Add explicit link with '-lc', might fix some problems.

win directory - windows makefile, .dll

include Osql from Dan R. Schenck in samples

wosql - modified to run without requiring TclX, remove unix-only code to allow to run in windows also.

## Version 2.41, December 1996

Change oratcl.c - zero out lda and hda before logon

Configure/makefile - fix problem when --exec-prefix= is different from --prefix,  include extra paths in library search, include compile time lib search flag since linker may prefer shared libs over static when both are present.

Change wosql - add server names from ~/.tnsnames.ora and Oracle home $ORACLE_HOME/network/admin/tnsnames.ora

## Version 2.4, September 1996

Change oratcl.c - add support for Tcl 7.5 packages.  fix orafetchall to quote two occurance of substiution char, and to accept a user defined substitution char.  add oramsg(ociinfo) index for features of how oratcl was compiled.  add initialized flag check to prevent reinitializing on subsequent 'load'.

Change wosql - add 'package require' for TclX. Include ODDIS as sample program.

changes to Makefile/configure - nearly a total rewrite, should allow Oratcl to be nearly independent of Tcl/Tk/TclX source directories.  Relies on Tcl/Tk/TclX to be installed properly, using tclConfig.sh (et.al) to get version numbers, library info, tclAppInit.c files, etc.  Also build libOratcl.so on request, using Oracle shared lib also.  Installs or updates and pkgIndex.tcl files in lib/tcl7.5.  Support Oracle 7.3.2 libraries (libclient.a, etc.)

New! - oratcl-capi, a C interface for Oratcl.  Experimental.  Feedback is welcome.

## Version 2.3, August, 1995

Change oratcl.c - support Tcl 7.4 release, hda area to support 64 bit Dec Alpha.  Always set oramsg(rows) to row processed count after oexec.  Fix bug in FetchAll that sometimes tries to reference beyond actual columns.

Change wosql - support Tk 4.0 release.

Change make/install to use newer autoconf 2.2.  Check for __fstd.o on Solaris, and mili.exp on AIX.

## Version 2.2, October, 1994

Change oratcl.c - change default nullvalue to "default", which performs current behavior, set oramsg(nullvalue) "" will give true null elements even for numeric data (potential incompatibility.)  clean up left over public functions to Oratcl_xxxx.  add last parameter to orlon(), which caused connect problems for some.

Change make/install to use autoconf.

## Version 2.11, April, 1994

Change oratcl.c - fix orasql to only call parse_columns() after DML, fixes bogus error in V7 after DDL.

## Version 2.1, February, 1994

Change oratcl.c - add optional commands to "orafetch" command, add colprecs and colscales to oracols (thanks to Dan Schenck); change init function to (int); avoid possible core dump in oralogon when connect to server failed; change how cursor handles are made

Wosql - use new orafetch when possible

## Version 2.0, November, 1993

Change oratcl.c to support Tcl 7.0+.  Change wosql for new pack syntax in Tk 3.3. Add oracancel to man page, and fixed reference to "errortxt"

New - Makefile and appinit.sed script.

## Version 1.0,  July, 1993

First general release, borrowed on concepts from my Sybtcl package.
