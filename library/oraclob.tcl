
namespace eval oratcl {

	variable plsql

	set plsql(getlength) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

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

	set plsql(trim) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
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

	set plsql(erase) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}
}


proc oraclob {stmhndl command args} {

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

		length	{
			set result [eval [list oratcl::clob_length $stmhndl \
								   $oraclob(rowid) \
								   $oraclob(table) \
								   $oraclob(column)]]
		}

		read	{
			set result [eval [list oratcl::clob_read $stmhndl \
								 $oraclob(rowid) \
								 $oraclob(table) \
								 $oraclob(column) \
								 $oraclob(datavar)]]
		}

		write	{
			set result [eval [list oratcl::clob_write $stmhndl \
							 	  $oraclob(rowid) \
							 	  $oraclob(table) \
							 	  $oraclob(column) \
							 	  $oraclob(datavar)]]
		}

		trim	{
			set result [eval [list oratcl::clob_trim $stmhndl \
							 	 $oraclob(rowid) \
							 	 $oraclob(table) \
							 	 $oraclob(column) \
							 	 $oraclob(length)]]
		}
		substr	{
			set result [eval [list oratcl::clob_substr $stmhndl \
							 	   $oraclob(rowid) \
							 	   $oraclob(table) \
							 	   $oraclob(column) \
								   $oraclob(offset) \
							 	   $oraclob(amount)]]
		}
		instr	{
			set result [eval [list oratcl::clob_instr $stmhndl \
							 	  $oraclob(rowid) \
							 	  $oraclob(table) \
							 	  $oraclob(column) \
								  $oraclob(pattern) \
								  $oraclob(offset) \
							 	  $oraclob(nth)]]
		}
		erase	{
			set result [eval [list oratcl::clob_erase $stmhndl \
							 	  $oraclob(rowid) \
							 	  $oraclob(table) \
							 	  $oraclob(column) \
								  $oraclob(amount) \
								  $oraclob(offset)]]
		}

	}

	return $result
}


#
#  return then length of a lob field.
#
proc oratcl::clob_length {cur rowid table column} {

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
	set len [lindex [oraplexec $cur \
				   $pl \
				   :rid $rowid \
				   :rlen {}] \
		 1]
	return $len
}

#
#  read the contents of a lob field.
#
proc oratcl::clob_read {cur rowid table column datavar} {

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

	set len [oratcl::clob_length $cur $rowid $table $column]
	set siz [oraconfig $cur lobpsize]

	set pos 1
	while {$pos < $len} {

		set pl [format $oratcl::plsql(read) $column $table]
		set out [lindex [oraplexec $cur \
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
proc oratcl::clob_write {cur rowid table column datavar} {

	global oramsg

	if {[string is space $datavar]} {
		error "oraclob :: invalid datavar value for write option."
	}

puts "datavar = $datavar"
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
	set siz [oraconfig $cur lobpsize]

	while {$pos < $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		set pl [format $oratcl::plsql(write) $column $table]
		oraplexec $cur $pl \
			:rid	 $rowid \
			:lob_amt $amt \
			:lob_pos $pos \
			:lob_str $str
		incr pos $amt
	}

}

#
#  trim a lob field.
#
proc oratcl::clob_trim {cur rowid table column length} {

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

	oraplexec $cur $pl \
			:rid	 $rowid \
			:lob_len $length 

}


#
#  substr a lob field.
#
proc oratcl::clob_substr {cur rowid table column offset amount} {

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

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for trim option."
	}

	if {! [string is integer $amount]} {
		error "oraclob :: invalid amount value for trim option."
	}

	set pl [format $oratcl::plsql(substr) $column $table]

	set res [lindex [oraplexec $cur $pl \
					:rid	 $rowid \
					:sub_str {} \
					:lob_amt $amount \
					:lob_off $offset] \
			1]

	return $res
}

#
#  instr a lob field.
#
proc oratcl::clob_instr {cur rowid table column pattern offset nth} {

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

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for trim option."
	}

	if {! [string is integer $nth]} {
		error "oraclob :: invalid nth value for trim option."
	}

	set pl [format $oratcl::plsql(instr) $column $table]

	set res [lindex [oraplexec $cur $pl \
					:rid	 $rowid \
					:ins_pos {} \
					:lob_ptn $pattern \
					:lob_off $offset \
					:lob_nth $nth] \
			1]

	return $res
}

#
#  erase a lob field.
#
proc oratcl::clob_erase {cur rowid table column amount offset} {

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

	if {! [string is integer $amount]} {
		error "oraclob :: invalid amount value for trim option."
	}

	if {! [string is integer $offset]} {
		error "oraclob :: invalid offset value for trim option."
	}

	set pl [format $oratcl::plsql(erase) $column $table]

	oraplexec $cur $pl \
			:rid	 $rowid \
			:lob_amt $amount \
			:lob_off $offset

}
