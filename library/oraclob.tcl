# oraclob:
# Process clob commands.
#
# RCS: @(#) $Id: oraclob.tcl,v 1.7 2000-09-21 04:31:14 tmh Exp $
#
# Copyright (c) 2000 Todd M. Helfter
#

namespace eval oratcl {

	variable plsql

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


proc oraclob {stm command args} {

	foreach idx [list rowid table column length start stop amount pattern datavar] {
		set oraclob($idx) {}
	}
	foreach idx [list offset nth] {
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
			-offset	 { set oraclob(offset) $value }
			-amount	 { set oraclob(amount) $value }
			-pattern { set oraclob(pattern) $value }
			-nth	 { set oraclob(nth) $value }
			-start	 { set oraclob(start) $value }
			-stop	 { set oraclob(stop) $value }
		}
	}		

	if {[string is space $oraclob(rowid)]} {
		error "oraclob :: invalid rowid value."
	}

	if {[string is space $oraclob(table)]} {
		error "oraclob :: invalid table value."
	}

	if {[string is space $oraclob(column)]} {
		error "oraclob :: invalid column value."
	}

	set result {}
	switch $command {

		read	{
			set result [eval [list oratcl::clob_read \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(datavar)]]
		}

		write	{
			set result [eval [list oratcl::clob_write \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(datavar)]]
		}

		length	{
			set result [eval [list oratcl::clob_length \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column)]]
		}

		trim	{
			set result [eval [list oratcl::clob_trim \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(length)]]
		}

		erase	{
			set result [eval [list oratcl::clob_erase \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(amount) \
					       $oraclob(offset)]]
		}

		substr	{
			set result [eval [list oratcl::clob_substr \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(start) \
					       $oraclob(stop) \
					       $oraclob(datavar)]]
		}

		instr	{
			set result [eval [list oratcl::clob_instr \
					       $stm \
					       $oraclob(rowid) \
					       $oraclob(table) \
					       $oraclob(column) \
					       $oraclob(pattern) \
					       $oraclob(offset) \
					       $oraclob(nth)]]
		}

	}

	return $result
}


#
#  read the contents of a lob field.
#
proc oratcl::clob_read {stm rowid table column datavar} {

	global oramsg errorInfo

	upvar 2 $datavar result
	set result {}

	set tcl_rc [catch {oratcl::clob_length $stm $rowid $table $column} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob instr: value error \n$info"
	}
	set len $tcl_res

	set siz [oraconfig $stm lobpsize]

	set pos 1
	while {$pos < $len} {

		set pl [format $oratcl::plsql(read) $column $table]
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
proc oratcl::clob_write {stm rowid table column datavar} {

	global oramsg errorInfo

	upvar 2 $datavar data

	set tot [string length $data]
	set pos 1
	set siz [oraconfig $stm lobpsize]

	while {$pos < $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		set pl [format $oratcl::plsql(write) $column $table]
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

	set tcl_rc [catch {oratcl::clob_trim $stm $rowid $table $column $tot} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob instr: value error \n$info"
	}

}

#
#  return then length of a lob field.
#
proc oratcl::clob_length {stm rowid table column} {

	global oramsg errorInfo

	set pl [format $oratcl::plsql(getlength) $column $table]
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
proc oratcl::clob_trim {stm rowid table column length} {

	global oramsg errorInfo

	set pl [format $oratcl::plsql(trim) $column $table]

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
proc oratcl::clob_erase {stm rowid table column amount offset} {

	global oramsg errorInfo

	set pl [format $oratcl::plsql(erase) $column $table]

	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :lob_amt $amount \
				     :lob_off $offset}]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob erase: value error \n$info"
	}
	return -code ok
}

#
#  substr a lob field.
#
proc oratcl::clob_substr {stm rowid table column start stop datavar} {

	global oramsg errorInfo

	upvar 2 $datavar result
	set result {}

	set amount [expr {$stop - $start + 1}]
	set offset [expr {$start + 1}]

	if {![string is integer $amount]} {
		error "oraclob instr: value error\n \
			numeric or value error: character to number conversion error"
	}

	set pl [format $oratcl::plsql(substr) $column $table]

	set tcl_rc [catch {oratcl::clob_length $stm $rowid $table $column} tcl_res]
	if {$tcl_rc} {
		set info "$oramsg(errortxt) $errorInfo"
		error "oraclob instr: value error \n$info"
	}
	set len $tcl_res

	set off $offset
	set rem $amount

	if {[string is integer $off] \
	  && $len + $off - 1 < $amount} {
		set rem [expr {$len + $off - 1}]
	}

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
			error "oraclob instr: value error \n$info" 
		}

		set rem [expr {$rem - $par}]
		incr off $par
		append result [lindex $tcl_res 1]
	}
}

#
#  instr a lob field.
#
proc oratcl::clob_instr {stm rowid table column pattern offset nth} {

	global oramsg errorInfo

	set pl [format $oratcl::plsql(instr) $column $table]
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

	return [lindex $tcl_res 1]
}
