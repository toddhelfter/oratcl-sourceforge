# oralob:
# Process lob commands.
#
# RCS: @(#) $Id: oralob.tcl,v 1.1 2000-09-22 20:50:03 tmh Exp $
#
# Copyright (c) 2000 Todd M. Helfter
#

namespace eval oratcl {

	variable plsql
	variable loblst
	variable lobidx 0

	set plsql(clob_read) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			DBMS_LOB.READ(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(blob_read) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			DBMS_LOB.READ(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(clob_write) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.WRITE(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(blob_write) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.WRITE(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(clob_getlength) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

	set plsql(blob_getlength) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

	set plsql(clob_trim) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
		end; \
	}

	set plsql(blob_trim) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
		end; \
	}

	set plsql(clob_erase) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(blob_erase) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(clob_substr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:sub_str := DBMS_LOB.SUBSTR(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(blob_substr) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:sub_str := DBMS_LOB.SUBSTR(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(clob_instr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:ins_pos := DBMS_LOB.INSTR(lob_loc, :lob_ptn, :lob_off, :lob_nth); \
		end; \
	}

	set plsql(blob_instr) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:ins_pos := DBMS_LOB.INSTR(lob_loc, :lob_ptn, :lob_off, :lob_nth); \
		end; \
	}

}


proc oralob {command handle args} {

	foreach idx [list rowid table column length pattern datavar] {
		set oralob($idx) {}
	}
	foreach idx [list start stop] {
		set oralob($idx) 0
	}
	foreach idx [list nth] {
		set oralob($idx) 1
	}

	set argc [llength $args]
	for {set argx 0} {$argx < $argc} {incr argx} {
		set option [lindex $args $argx]
		if {[incr argx] >= $argc} {
			error "oralob: argument to $option is missing."
		}
		set value [lindex $args $argx]

		switch -- $option {
			-rowid	 { set oralob(rowid) $value }
			-table	 { set oralob(table) $value }
			-column	 { set oralob(column) $value }
			-datavar { set oralob(datavar) $value }
			-length	 { set oralob(length) $value }
			-pattern { set oralob(pattern) $value }
			-nth	 { set oralob(nth) $value }
			-start	 { set oralob(start) $value }
			-stop	 { set oralob(stop) $value }
		}
	}		

	set result {}
	switch $command {

		alloc 	{
			set result [eval [list ::oratcl::lob_alloc \
					       $handle \
					       $oralob(table) \
					       $oralob(column) \
					       $oralob(rowid)]]
		}

		free 	{
			set result [eval [list ::oratcl::lob_free \
					       $handle]]
		}

		read	{
			set result [eval [list ::oratcl::lob_read \
					       $handle \
					       $oralob(datavar)]]
		}

		write	{
			set result [eval [list ::oratcl::lob_write \
					       $handle \
					       $oralob(datavar)]]
		}

		length	{
			set result [eval [list ::oratcl::lob_length \
					       $handle]]
		}

		trim	{
			set result [eval [list ::oratcl::lob_trim \
					       $handle \
					       $oralob(length)]]
		}

		erase	{
			set result [eval [list ::oratcl::lob_erase \
					       $handle \
					       $oralob(start) \
					       $oralob(stop)]]
		}

		substr	{
			set result [eval [list ::oratcl::lob_substr \
					       $handle \
					       $oralob(start) \
					       $oralob(stop) \
					       $oralob(datavar)]]
		}

		instr	{
			set result [eval [list ::oratcl::lob_instr \
					       $handle \
					       $oralob(pattern) \
					       $oralob(start) \
					       $oralob(nth)]]
		}

	}

	return $result
}


#
#  allocate a lob identifier
#
proc ::oratcl::lob_alloc {handle table column rowid} {

	global oramsg errorInfo

	variable lobidx 
	variable loblst

	if {[string is space $rowid]} {
		error "oralob alloc :: invalid rowid value."
	}

	if {[string is space $table]} {
		error "oralob alloc :: invalid table value."
	}

	if {[string is space $column]} {
		error "oralob alloc :: invalid column value."
	}

	set tcl_rc [catch {orainfo loginhandle $handle} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob alloc: error \n$info"
	}

	set loghandle $tcl_res

	set tcl_rc [catch {oradesc $loghandle $table} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob alloc: error \n$info"
	}

	set autotype {}
	foreach row $tcl_res {
		if {[string equal [lindex $row 0] [string toupper $column]]} {
			set autotype [lindex $row 2]
			break
		}
	}

	if {[string is space $autotype]} {
		error "oralob alloc: error $column not found."
	}

	switch $autotype {
		CLOB 	{set lobtype clob}
		BLOB	{set lobtype blob}
		default {error "oralob alloc :: invalid lob type $lobtype."}
	}

	set pl [format $::oratcl::plsql(${lobtype}_getlength) $column $table]

	set tcl_rc [catch {oraplexec $handle \
				     $pl \
				     :rid $rowid \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob alloc: error \n$info"
	}

	set lob oralob.$lobidx
	incr lobidx
	set loblst($lob) [list $handle $table $column $rowid $lobtype]

	return $lob
}

#
#  free a lob identifier
#
proc ::oratcl::lob_free {handle} {

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oralob free: handle $handle not open."
	}

	set tcl_rc [catch {unset loblst($handle)} tcl_res]
	if {$tcl_rc} {
		error "oralob free: handle $handle not open."
	}

	return -code ok
}


#
#  read the contents of a lob field.
#
proc ::oratcl::lob_read {handle datavar} {

	global oramsg errorInfo
	variable loblst

	set fn read

	if {![info exists loblst($handle)]} {
		error "oralob $fn: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $datavar result
	set result {}

	set tcl_rc [catch {::oratcl::lob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob $fn: value error \n$info"
	}
	set len $tcl_res

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set tcl_err 0
	set err_txt {}

	set pos 1
	while {$pos < $len} {

		set pl [format $::oratcl::plsql(${lobtype}_read) $column $table]

		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :lob_amt $siz \
					     :lob_pos $pos \
					     :lob_str {} } \
				  tcl_res] 
		if {$tcl_rc} {
			set tcl_err 1
			set err_txt "oralob $fn: value error \n$oramsg(errortxt) $errorInfo" 
			break
		}
		set out [lindex $tcl_res 3]

		if {[string equal $lobtype blob]} {
			set out [binary format H* $out]
		}

		append result $out
		set amt [string length $out]
		incr pos $amt
	}

	catch {oraconfig $stm bindsize $bsz}

	if {$tcl_err} {
		return -code error -errorinfo $err_txt
	}

	return -code ok
}

#
#  write data to a lob field.
#
proc ::oratcl::lob_write {handle datavar} {

	global oramsg errorInfo
	variable loblst

	set fn write

	if {![info exists loblst($handle)]} {
		error "oralob $fn: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $datavar data
	set tot [string length $data]

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set tcl_err 0
	set err_txt {}

	set pos 1
	while {$pos < $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		if {[string equal $lobtype blob]} {
			binary scan $str H* str
		}

		set pl [format $::oratcl::plsql(${lobtype}_write) $column $table]
		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :lob_amt $amt \
					     :lob_pos $pos \
					     :lob_str $str } \
				  tcl_res]
		if {$tcl_rc} {
			set err_txt "oralob $fn: value error \n$oramsg(errortxt) $errorInfo"
			set tcl_err 1
			break
		}

		incr pos $amt
	}

	if {! $tcl_err} {
		set tcl_rc [catch {::oratcl::lob_trim $handle $tot} tcl_res]
		if {$tcl_rc} {
			set err_txt "oralob $fn: value error \n$oramsg(errortxt) $errorInfo"
			set tcl_err 1
		}
	}

	catch {oraconfig $stm bindsize $bsz}

	if {$tcl_err} {
		return -code error -errorinfo $err_txt
	}

	return -code ok
}

#
#  return then length of a lob field.
#
proc ::oratcl::lob_length {handle} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oralob length: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	set pl [format $::oratcl::plsql(${lobtype}_getlength) $column $table]
	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob trim: value error \n$info"
	}

	return [lindex $tcl_res 1]
}

#
#  trim a lob field.
#
proc ::oratcl::lob_trim {handle length} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oralob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	set pl [format $::oratcl::plsql(${lobtype}_trim) $column $table]
	set tcl_rc [catch {oraplexec $stm \
			             $pl \
			             :rid $rowid \
			             :lob_len $length}]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob trim: value error \n$info"
	}
	return -code ok
}

#
#  erase a lob field.
#
proc ::oratcl::lob_erase {handle start stop} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oralob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	if {![string is integer $start] || $start < 0} {
		error "oralob erase: value error\n \
			-start value must be a non negative integer"
	}

	if {![string is integer $stop] || $stop < $start} {
		error "oralob erase: value error\n \
			-stop value must be a non negative integer\n \
			-stop value may not be less than -start value"
	}

	set amt [expr {$stop - $start + 1}]
	set off [expr {$start + 1}]

	set pl [format $::oratcl::plsql(${lobtype}_erase) $column $table]

	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :lob_amt $amt \
				     :lob_off $off}]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob erase: value error \n$info"
	}
	return -code ok
}

#
#  substr a lob field.
#
proc ::oratcl::lob_substr {handle start stop datavar} {

	global oramsg errorInfo

	variable loblst

	if {![info exists loblst($handle)]} {
		error "oralob substr: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $datavar result
	set result {}

	if {![string is integer $start] || $start < 0} {
		error "oralob substr: value error\n \
			-start value must be a non negative integer"
	}

	if {![string is integer $stop] || $stop < $start} {
		error "oralob substr: value error\n \
			-stop value must be a non negative integer\n \
			-stop value may not be less than -start value"
	}

	set tcl_rc [catch {::oratcl::lob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oralob substr: value error \n$info"
	}

	if {$stop > $tcl_res} {
		set stop $tcl_res
	}

	set rem [expr {$stop - $start + 1}]
	set off [expr {$start + 1}]

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set pl [format $::oratcl::plsql(${lobtype}_substr) $column $table]

	while {$rem > 0} {

		if {$rem > $siz} {
			set par $siz
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
			error "oralob substr: value error \n$info" 
		}

		set rem [expr {$rem - $par}]
		incr off $par
	
		set out [lindex $tcl_res 1]
		if {[string equal $lobtype blob]} {
			set out [binary format H* $out]
		}
		append result $out
	}

	catch {oraconfig $stm bindsize $bsz}
}

#
#  instr a lob field.
#
proc ::oratcl::lob_instr {handle pattern start nth} {

	global oramsg errorInfo

	variable loblst

	set fn instr

	if {![info exists loblst($handle)]} {
		error "oralob trim: handle $handle not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	#
	#  Need to set bindsize or test pattern to fit.  Or both says Ben
	#
	if {[string length $pattern] > [oraconfig $stm lobpsize] 
	 || [string length $pattern] > [oraconfig $stm bindsize] * 2} {
		set err_txt "oralob $fn: pattern error\n \
			     -pattern value too large for bindsize or lobpsize."
		return -code error -errorinfo $err_txt
	}

	if {![string is integer $start] || $start < 0} {
		error "oralob $fn: value error\n \
			-start value must be a non negative integer"
	}

	set offset [expr {$start + 1}]

	if {[string equal $lobtype blob]} {
		binary scan $pattern H* pattern
	}

	set pl [format $::oratcl::plsql(${lobtype}_instr) $column $table]
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
		error "oralob $fn: value error \n$info"
	}

	return [expr [lindex $tcl_res 1] - 1]
}
