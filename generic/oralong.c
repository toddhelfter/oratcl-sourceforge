#include "oratclExt.h"
#include "oratclInt.h"
#include "oratcl.h"
#include <tcl.h>

int
Oralong_Init (interp)
	Tcl_Interp	*interp;
{
	CONST84 char	*proc;
	int		tcl_return = TCL_OK;
	int		tcl_rc;

	Tcl_SetVar(interp, 
		   "::oratcl::longidx", 
		   "0", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::sql", 
		   "longraw_write", 
		   "update %s set %s = :lng where rowid = '%s'", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::sql", 
		   "longraw_read", 
		   "select %s from %s where rowid = '%s'", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::sql", 
		   "long_write", 
		   "update %s set %s = :lng where rowid = '%s'", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::sql", 
		   "long_read", 
		   "select %s from %s where rowid = '%s'", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::oralong", 
		   "script", 
		   "/home/flare/a/tmh/work/oratcl-head/library/oralong.tcl", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::oralong", 
		   "oratcl_ok", 
		   "0", 
		   0);

	Tcl_SetVar2(interp, 
		   "::oratcl::oralong", 
		   "oratcl_error", 
		   "1", 
		   0);

	/*
	 *  Create the oralong proc.
	 */
	proc = "proc oralong {command handle args} { "
		"	global errorInfo; "
		"	foreach idx [list rowid table column datavar] { "
		"		set ::oratcl::oralong($idx) {}; "
		"	}; "
		"	set tcl_res {}; "
		"	set cm(alloc)	[list ::oratcl::long_alloc $handle $args]; "
		"	set cm(free)	[list ::oratcl::long_free $handle]; "
		"	set cm(read)	[list ::oratcl::long_read $handle $args]; "
		"	set cm(write)   [list ::oratcl::long_write $handle $args]; "
		"	if {! [info exists cm($command)]} { "
		"		 set err_txt \"oralong: unknown command option '$command'\"; "
		"		 return -code error $err_txt ; "
		"	}; "
		"	set tcl_rc [catch {eval $cm($command)} tcl_res]; "
		"	if {$tcl_rc} { "
		"		return -code error \"$tcl_res\"; "
		"	}; "
		"	return $tcl_res; "
		"} ";

	Tcl_Eval(interp, proc);

	/*
	 *  Create the ::oratcl::parse_long_args proc.
	 */
	proc = "proc ::oratcl::parse_long_args {args} { "
		"	set argv [lindex $args 0]; "
		"	set argc [llength $argv]; "
		"	for {set argx 0} {$argx < $argc} {incr argx} { "
		"		set option [lindex $argv $argx]; "
		"		if {[incr argx] >= $argc} { "
		"			set err_txt \"oralong: value parameter to $option is missing.\"; "
		"			return -code error $err_txt ; "
		"		}; "
		"		set value [lindex $argv $argx]; "
		"		if {[regexp ^- $option]} { "
		"			set index [string range $option 1 end]; "
		"			set ::oratcl::oralong($index) $value ; "
		"		}; "
		"	}; "
		"} ";

	Tcl_Eval(interp, proc);

	/*
	 *  Create the ::oratcl::long_alloc proc.
	 */
	proc = "proc ::oratcl::long_alloc {handle args} { "
		"	global errorInfo; "
		"	variable longidx ; "
		"	variable longlst; "
		"	variable oralong; "
		"	set fn alloc; "
		"	set tcl_rc [catch {eval ::oratcl::parse_long_args $args} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {[string is space $oralong(rowid)]} { "
		"		set err_txt \"oralong $fn: invalid rowid value.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {[string is space $oralong(table)]} { "
		"		set err_txt \"oralong $fn: invalid table value.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {[string is space $oralong(column)]} { "
		"		set err_txt \"oralong $fn: invalid column value.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set tcl_rc [catch {orainfo loginhandle $handle} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: [oramsg $handle error] $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set loghandle $tcl_res; "
		"	set tcl_rc [catch {oradesc $loghandle $oralong(table)} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: [oramsg $handle error] $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set autotype {}; "
		"	foreach row $tcl_res { "
		"		if {[string equal [lindex $row 0] [string toupper $oralong(column)]]} { "
		"			set autotype [lindex $row 2]; "
		"			::break; "
		"		}; "
		"	}; "
		"	if {[string is space $autotype]} { "
		"		set err_txt \"oralong $fn: error column '$oralong(column)' not found.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {[string equal $autotype LONG]} { "
		"		set longtype long; "
		"	} elseif {[string equal $autotype {LONG RAW}]} { "
		"		set longtype longraw; "
		"	} else { "
		"		set err_txt \"oralong $fn: error unsuported long type '$autotype'.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set lng oralong.$longidx; "
		"	incr longidx; "
		"	set longlst($lng) [list $handle $oralong(table) $oralong(column) $oralong(rowid) $longtype]; "
		"	return $lng; "
		"} ";

	Tcl_Eval(interp, proc);

	/*
	 *  Create the ::oratcl::long_free proc.
	 */
	proc = "proc ::oratcl::long_free {handle} { "
		"	variable oralong; "
		"	variable longlst; "
		"	set fn free; "
		"	if {![info exists longlst($handle)]} { "
		"		set err_txt \"oralong $fn: handle $handle not open.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set tcl_rc [catch {unset longlst($handle)} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set err_txt \"oralong $fn: $tcl_res\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	return -code ok $oralong(oratcl_ok); "
		"} ";

	Tcl_Eval(interp, proc);

	/*
	 *  Create the ::oratcl::long_read proc.
	 */
	proc = "proc ::oratcl::long_read {handle args} { "
		"	global errorInfo; "
		"	variable longlst; "
		"	variable oralong; "
		"	set fn read; "
		"	set tcl_rc [catch {eval ::oratcl::parse_long_args $args} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {![info exists longlst($handle)]} { "
		"		set err_txt \"oralong $fn: handle $handle not open.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set stm [lindex $longlst($handle) 0]; "
		"	set table [lindex $longlst($handle) 1]; "
		"	set column [lindex $longlst($handle) 2]; "
		"	set rowid [lindex $longlst($handle) 3]; "
		"	set longtype [lindex $longlst($handle) 4]; "
		"	upvar 2 $oralong(datavar) read_res; "
		"	set read_res {}; "
		"	set sql [format $::oratcl::sql(${longtype}_read) $column $table $rowid]; "
		"	set tcl_rc [catch {::oratcl::longread $stm  $sql  read_res  $longtype}  tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: [oramsg $handle error] $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	return -code ok $oralong(oratcl_ok); "
		"} ";

	Tcl_Eval(interp, proc);

	/*
	 *  Create the ::oratcl::long_write proc.
	 */
	proc = "proc ::oratcl::long_write {handle args} { "
		"	global errorInfo; "
		"	variable longlst; "
		"	variable oralong; "
		"	set fn write; "
		"	set tcl_rc [catch {eval ::oratcl::parse_long_args $args} tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	if {![info exists longlst($handle)]} { "
		"		set err_txt \"oralong $fn: handle $handle not open.\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	set stm [lindex $longlst($handle) 0]; "
		"	set table [lindex $longlst($handle) 1]; "
		"	set column [lindex $longlst($handle) 2]; "
		"	set rowid [lindex $longlst($handle) 3]; "
		"	set longtype [lindex $longlst($handle) 4]; "
		"	upvar 2 $oralong(datavar) datavar; "
		"	set writevar $datavar; "
		"	set sql [format $::oratcl::sql(${longtype}_write) $table $column $rowid]; "
		"	set tcl_rc [catch {::oratcl::longwrite $stm  $sql  writevar  $longtype}  tcl_res]; "
		"	if {$tcl_rc} { "
		"		set info $errorInfo; "
		"		set err_txt \"oralong $fn: [oramsg $handle error] $info\"; "
		"		return -code error $err_txt; "
		"	}; "
		"	return -code ok $oralong(oratcl_ok); "
		"} ";

	Tcl_Eval(interp, proc);

	return tcl_return;
}
