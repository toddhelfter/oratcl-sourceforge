# oraclob:
# Process clob commands.
#
# RCS: @(#) $Id: oraclob.tcl,v 1.14 2000-09-21 20:40:32 tmh Exp $
#
# Copyright (c) 2000 Todd M. Helfter
#

namespace eval oratcl {

	variable plsql
	variable loblst
	variable lobidx 0

	set plsql(read) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			DBMS_LOB.READ(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(write) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.WRITE(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(getlength) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

	set plsql(trim) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
		end; \
	}

	set plsql(erase) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(substr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:sub_str := DBMS_LOB.SUBSTR(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(instr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:ins_pos := DBMS_LOB.INSTR(lob_loc, :lob_ptn, :lob_off, :lob_nth); \
		end; \
	}

}


proc oraclob {command handle args} {

	foreach idx [list rowid table column length pattern datavar] {
		set oraclob($idx) {}
	}
	foreach idx [list start stop] {
		set oraclob($idx) 0
	}
	foreach idx [list nth] {
		set oraclob($idx) 1
	}

	set argc [llength $args]
	for {set argx 0} {$argx < $argc} {incr argx} {
		set option [lindex $args $argx]
		if {[incr argx] >= $argc} {
			error "oraclob: argument to $option is missing."
		}
		set value [lindex $args $argx]

		switch -- $option {
			-rowid	 { set oraclob(rowid) $value }
			-table	 { set oraclob(table) $value }
			-column	 { set oraclob(column) $value }
			-datavar { set oraclob(datavar) $value }
			-length	 { set oraclob(length) $value }
			-pattern { set oraclob(pattern) $value }
			-nth	 { set oraclob(nth) $value }
			-start	 { set oraclob(start) $value }
			-stop	 { set oraclob(stop) $value }
		}
	}		

	set result {}
	switch $command {

		alloc 	{
			set result [eval [list ::oratcl::clob_alloc \
					       $handle \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(rowid)]]
		}

		free 	{
			set result [eval [list ::oratcl::clob_free \
					       $handle]]
		}

		read	{
			set result [eval [list ::oratcl::clob_read \
					       $handle \
					       $oraclob(datavar)]]
		}

		write	{
			set result [eval [list ::oratcl::clob_write \
					       $handle \
					       $oraclob(datavar)]]
		}

		length	{
			set result [eval [list ::oratcl::clob_length \
					       $handle]]
		}

		trim	{
			set result [eval [list ::oratcl::clob_trim \
					       $handle \
					       $oraclob(length)]]
		}

		erase	{
			set result [eval [list ::oratcl::clob_erase \
					       $handle \
					       $oraclob(start) \
					       $oraclob(stop)]]
		}

		substr	{
			set result [eval [list ::oratcl::clob_substr \
					       $handle \
					       $oraclob(start) \
					       $oraclob(stop) \
					       $oraclob(datavar)]]
		}

		instr	{
			set result [eval [list ::oratcl::clob_instr \
					       $handle \
					       $oraclob(pattern) \
					       $oraclob(start) \
					       $oraclob(nth)]]
		}

	}

	return $result
}


#
#  allocate a clob identifier
#
proc ::oratcl::clob_alloc {handle table column rowid} {

	global oramsg errorInfo

	variable lobidx 
	variable loblst

	if {[string is space $rowid]} {
		error "oraclob alloc :: invalid rowid value."
	}

	if {[string is space $table]} {
		error "oraclob alloc :: invalid table value."
	}

	if {[string is space $column]} {
		error "oraclob alloc :: invalid column value."
	}

	set pl [format $::oratcl::plsql(getlength) $column $table]
	set tcl_rc [catch {oraplexec $handle \
				     $pl \
				     :rid $rowid \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob alloc: error \n$info"
	}

	set lob oralob.$lobidx
	incr lobidx
	set loblst($lob) [list $handle $table $column $rowid]

	return $lob
}

#
#  free a clob identifier
#
proc ::oratcl::clob_free {handle} {

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob free: handle $handle not open."
	}

	set tcl_rc [catch {unset loblst($handle)} tcl_res]
	if {$tcl_rc} {
		error "oraclob free: handle $handle not open."
	}

	return -code ok
}


#
#  read the contents of a lob field.
#
proc ::oratcl::clob_read {handle datavar} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob read: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	upvar 2 $datavar result
	set result {}

	set tcl_rc [catch {::oratcl::clob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob read: value error \n$info"
	}
	set len $tcl_res

	set siz [oraconfig $stm lobpsize]

	set pos 1
	while {$pos < $len} {

		set pl [format $::oratcl::plsql(read) $column $table]
		set out [lindex [oraplexec $stm \
					   $pl \
					   :rid $rowid \
					   :lob_amt $siz \
					   :lob_pos $pos \
					   :lob_str {}] \
			 3]

		append result $out
		set amt [string length $out]
		incr pos $amt
	}
}

#
#  write data to a lob field.
#
proc ::oratcl::clob_write {handle datavar} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob write: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	upvar 2 $datavar data

	set tot [string length $data]
	set pos 1
	set siz [oraconfig $stm lobpsize]

	while {$pos < $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		set pl [format $::oratcl::plsql(write) $column $table]
		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :lob_amt $amt \
					     :lob_pos $pos \
					     :lob_str $str } \
				  tcl_res]
		if {$tcl_rc} {
			set info "$oramsg(errortxt) $errorInfo"
			error "oraclob trim: value error \n$info"
		}

		incr pos $amt
	}

	set tcl_rc [catch {::oratcl::clob_trim $handle $tot} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob read: value error \n$info"
	}

}

#
#  return then length of a lob field.
#
proc ::oratcl::clob_length {handle} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob length: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	set pl [format $::oratcl::plsql(getlength) $column $table]
	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob trim: value error \n$info"
	}

	return [lindex $tcl_res 1]
}

#
#  trim a lob field.
#
proc ::oratcl::clob_trim {handle length} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	set pl [format $::oratcl::plsql(trim) $column $table]
	set tcl_rc [catch {oraplexec $stm \
			             $pl \
			             :rid $rowid \
			             :lob_len $length}]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob trim: value error \n$info"
	}
	return -code ok
}

#
#  erase a lob field.
#
proc ::oratcl::clob_erase {handle start stop} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	if {![string is integer $start] || $start < 0} {
		error "oraclob erase: value error\n \
			-start value must be a non negative integer"
	}

	if {![string is integer $stop] || $stop < $start} {
		error "oraclob erase: value error\n \
			-stop value must be a non negative integer\n \
			-stop value may not be less than -start value"
	}

	set amt [expr {$stop - $start + 1}]
	set off [expr {$start + 1}]

	set pl [format $::oratcl::plsql(erase) $column $table]

	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :lob_amt $amt \
				     :lob_off $off}]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob erase: value error \n$info"
	}
	return -code ok
}

#
#  substr a lob field.
#
proc ::oratcl::clob_substr {handle start stop datavar} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob substr: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	upvar 2 $datavar result
	set result {}

	if {![string is integer $start] || $start < 0} {
		error "oraclob substr: value error\n \
			-start value must be a non negative integer"
	}

	if {![string is integer $stop] || $stop < $start} {
		error "oraclob substr: value error\n \
			-stop value must be a non negative integer\n \
			-stop value may not be less than -start value"
	}

	set tcl_rc [catch {::oratcl::clob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob substr: value error \n$info"
	}

	if {$tcl_res > $stop} {
		set stop $tcl_res
	}

	set rem [expr {$stop - $start + 1}]
	set off [expr {$start + 1}]

	set pl [format $::oratcl::plsql(substr) $column $table]

	while {$rem > 0} {

		if {$rem > 2000} {
			set par 2000
		} else {
			set par $rem
		}

		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :sub_str {} \
					     :lob_amt $par \
					     :lob_off $off} \
				  tcl_res] 
		if {$tcl_rc} {
			set info "$oramsg(errortxt) $errorInfo"
			error "oraclob substr: value error \n$info" 
		}

		set rem [expr {$rem - $par}]
		incr off $par
		append result [lindex $tcl_res 1]
	}
}

#
#  instr a lob field.
#
proc ::oratcl::clob_instr {handle pattern start nth} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oraclob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]

	if {![string is integer $start] || $start < 0} {
		error "oraclob instr: value error\n \
			-start value must be a non negative integer"
	}

	set offset [expr {$start + 1}]

	set pl [format $::oratcl::plsql(instr) $column $table]
	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :ins_pos {} \
				     :lob_ptn $pattern \
				     :lob_off $offset \
				     :lob_nth $nth} \
			  tcl_res] 
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob instr: value error \n$info"
	}

	return [expr [lindex $tcl_res 1] - 1]
}
