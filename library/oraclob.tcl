# oraclob:
# Process clob commands.
#
# RCS: @(#) $Id: oraclob.tcl,v 1.4 2000-09-18 15:26:51 tmh Exp $
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

	foreach idx [list rowid table column length start amount pattern datavar] {
		set oraclob($idx) {}
	}
	foreach idx [list offset nth] {
		set oraclob($idx) 1
	}

	set argc [llength $args]
	for {set argx 0} {$argx < $argc} {incr argx} {
		set option [lindex $args $argx]
		if {[incr argx] >= $argc} {
			error "missing argument to $option"
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
		}
	}		

	set result {}
	switch $command {

		read	{
			set result [eval [list oratcl::clob_read $stm \
								 $oraclob(rowid) \
								 $oraclob(table) \
								 $oraclob(column) \
								 $oraclob(datavar)]]
		}

		write	{
			set result [eval [list oratcl::clob_write $stm \
							 	  $oraclob(rowid) \
							 	  $oraclob(table) \
							 	  $oraclob(column) \
							 	  $oraclob(datavar)]]
		}

		length	{
			set result [eval [list oratcl::clob_length $stm \
								   $oraclob(rowid) \
								   $oraclob(table) \
								   $oraclob(column)]]
		}

		trim	{
			set result [eval [list oratcl::clob_trim $stm \
							 	 $oraclob(rowid) \
							 	 $oraclob(table) \
							 	 $oraclob(column) \
							 	 $oraclob(length)]]
		}

		erase	{
			set result [eval [list oratcl::clob_erase $stm \
							 	  $oraclob(rowid) \
							 	  $oraclob(table) \
							 	  $oraclob(column) \
								  $oraclob(amount) \
								  $oraclob(offset)]]
		}

		substr	{
			set result [eval [list oratcl::clob_substr $stm \
							 	   $oraclob(rowid) \
							 	   $oraclob(table) \
							 	   $oraclob(column) \
								   $oraclob(offset) \
							 	   $oraclob(amount)]]
		}

		instr	{
			set result [eval [list oratcl::clob_instr $stm \
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
#  return then length of a lob field.
#
proc oratcl::clob_length {stm rowid table column} {

	global oramsg

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for length option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for length option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for length option."
	}

	set pl [format $oratcl::plsql(getlength) $column $table]
	set len [lindex [oraplexec $stm \
				   $pl \
				   :rid $rowid \
				   :rlen {}] \
		 1]
	return $len
}

#
#  read the contents of a lob field.
#
proc oratcl::clob_read {stm rowid table column datavar} {

	global oramsg

	if {[string is space $datavar]} {
		error "oraclob :: invalid datavar value for read option."
	}
	upvar 2 $datavar result
	set result {}

	##
	# Need to test cursor for validity??
	##

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for read option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for read option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for read option."
	}

	set len [oratcl::clob_length $stm $rowid $table $column]
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

	global oramsg

	if {[string is space $datavar]} {
		error "oraclob :: invalid datavar value for write option."
	}

	upvar 2 $datavar data

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for write option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for write option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for write option."
	}

	set tot [string length $data]
	set pos 1
	set siz [oraconfig $stm lobpsize]

	while {$pos < $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		set pl [format $oratcl::plsql(write) $column $table]
		oraplexec $stm \
			  $pl \
			  :rid $rowid \
			  :lob_amt $amt \
			  :lob_pos $pos \
			  :lob_str $str
		incr pos $amt
	}

	oratcl::clob_trim $stm $rowid $table $column $tot

}

#
#  trim a lob field.
#
proc oratcl::clob_trim {stm rowid table column length} {

	global oramsg

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for trim option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for trim option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for trim option."
	}

	if {! [string is integer $length]} {
		error "oraclob :: invalid length value for trim option."
	}

	set pl [format $oratcl::plsql(trim) $column $table]

	oraplexec $stm \
		  $pl \
		  :rid $rowid \
		  :lob_len $length 

}

#
#  erase a lob field.
#
proc oratcl::clob_erase {stm rowid table column amount offset} {

	global oramsg

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for erase option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for erase option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for erase option."
	}

	if {! [string is integer $amount]} {
		error "oraclob :: invalid amount value for erase option."
	}

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for erase option."
	}

	set pl [format $oratcl::plsql(erase) $column $table]

	oraplexec $stm \
		  $pl \
		  :rid $rowid \
		  :lob_amt $amount \
		  :lob_off $offset

}

#
#  substr a lob field.
#
proc oratcl::clob_substr {stm rowid table column offset amount} {

	global oramsg

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for substr option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for substr option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for substr option."
	}

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for substr option."
	}

	if {! [string is integer $amount]} {
		error "oraclob :: invalid amount value for substr option."
	}

	set pl [format $oratcl::plsql(substr) $column $table]

	set res [lindex [oraplexec $stm \
				   $pl \
				   :rid $rowid \
				   :sub_str {} \
				   :lob_amt $amount \
				   :lob_off $offset] \
			1]

	return $res
}

#
#  instr a lob field.
#
proc oratcl::clob_instr {stm rowid table column pattern offset nth} {

	global oramsg

	if {[string is space $rowid]} {
		error "oraclob :: invalid rowid value for instr option."
	}

	if {[string is space $table]} {
		error "oraclob :: invalid table value for instr option."
	}

	if {[string is space $column]} {
		error "oraclob :: invalid column value for instr option."
	}

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for instr option."
	}

	if {! [string is integer $nth]} {
		error "oraclob :: invalid nth value for instr option."
	}

	set pl [format $oratcl::plsql(instr) $column $table]

	set res [lindex [oraplexec $stm \
				   $pl \
				   :rid $rowid \
				   :ins_pos {} \
				   :lob_ptn $pattern \
				   :lob_off $offset \
				   :lob_nth $nth] \
			1]

	return $res
}
