#------------------------------------------------------------------------------#
#	Database and data manipulation procedures


proc ologin { dbproc uid pw } {

  global oramsg

  set oramsg(nullvalue) "NULL"
  upvar $dbproc dbp 
  if { [catch { oralogon $uid/$pw } dbp] != 0 } {
    catch { puts stderr "Error logging into database server." }
    catch { puts stderr "Error No. $oramsg(rc):  $oramsg(errortxt)" }
    return -1
  }
  return 0

}


proc ologout { dbproc } {

  global oramsg

  if { [catch { oralogoff $dbproc }] != 0 } {
    catch { puts stderr "Error logging out of database server." }
    catch { puts stderr "Error No. $oramsg(rc):  $oramsg(errortxt)" }
    return -1
  }
  return 0

}

proc oopen { dbproc } {

  global oramsg

  if { [catch { oraopen $dbproc } dbh] != 0 } {
    catch { puts stderr "Error opening database cursor $dbproc." }
    catch { puts stderr "Error No. $oramsg(rc):  $oramsg(errortxt)" }
    return -1
  }
  return $dbh

}


proc oclose { dbproc } {

  global oramsg

  if { [catch { oraclose $dbproc }] != 0 } {
    catch { puts stderr "Error closing database cursor $dbproc." }
    catch { puts stderr "Error No. $oramsg(rc):  $oramsg(errortxt)" }
    return -1
  }
  return 0

}


#------------------------------------------------------------------------------#
#	Execute a SQL command and return the rows as a list

proc orasqlGetRowList { dbHandle sql } {

  global oramsg sqlColLens sqlColNames sqlColTypes sqlColPrecs sqlColScales

  set rtrnList ""
  if { [catch {orasql $dbHandle $sql}] != 0 } {
    catch { puts stderr "****************************************" }
    catch { puts stderr "[fmtclock [getclock]]" }
    catch { puts stderr "Error executing SQL statement:\n  $sql" }
    catch { puts stderr "Error No. $oramsg(rc):  $oramsg(errortxt)" }
    catch { puts stderr "****************************************" }
    return {**SQLERROR**}
  }
  if { $oramsg(sqlfunc) != 3 && $oramsg(sqlfunc) != 4 && $oramsg(sqlfunc) != 5
       && $oramsg(sqlfunc) != 9 } {
    set rtrnList {{{Action Performed}}}
    set sqlColNames {{DDL Result}}
    set sqlColLens {20}
    set sqlColTypes {char}
    set sqlColPrecs {}
    set sqlColScales {}
  } else {
    set i 0
    while { [set row [orafetch $dbHandle]] != "" &&
            ![cequal $oramsg(rc) NO_DATA_FOUND] } {
      lappend rtrnList $row
      if { !$i } {
        set sqlColNames [oracols $dbHandle]
        set sqlColLens $oramsg(collengths)
        set sqlColTypes $oramsg(coltypes)
        set sqlColPrecs $oramsg(colprecs)
        set sqlColScales $oramsg(colscales)
        set i 1
      }
    }
  }
  return $rtrnList
}

proc orasql_format { list } {

  global dbHandle sqlColLens sqlColNames sqlColTypes oramsg _sqlHeader
  if { "$list" == "" } { set _sqlHeader ""; return "\{No Rows Returned\}" }
  set i 0
  foreach c $sqlColLens {
    incr i
    set ctype($i) [lindex $sqlColTypes [expr $i-1]]
    if { "$ctype($i)" == "number" } {
      set cl($i) [max 12 [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) d
      set fmt($i) ""
    } elseif { "$ctype($i)" == "float" } {
      set cl($i) [max 12 [clength [lindex $sqlColNames [expr $i-1]]]]
      set cl($i) [expr $cl($i)+6].5
      set ct($i) f
      set fmt($i) ""
    } elseif { $ctype($i) == "smallint" } {
      set cl($i) [max 6 [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) d
      set fmt($i) ""
    } elseif { $ctype($i) == "tinyint" } {
      set cl($i) [max 3 [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) d
      set fmt($i) ""
    } elseif { $ctype($i) == "date" } {
      set cl($i) [max 26 [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) s
      set fmt($i) "-"
    } else {
      set cl($i) [max $c [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) s
      set fmt($i) "-"
    }
  }
  foreach row $list {
    set output ""
    set i 0
    foreach item $row {
      incr i
      if { "$item" == "NULL" } {
        if { $ct($i) == "f" } {
	  set l [lindex [split $cl($i) .] 0]
	} else {
	  set l $cl($i)
	}
	set output [format "%s  %-[set l]s" $output $item]
      } else {
        set output [format "%s  %$fmt($i)$cl($i)$ct($i)" $output $item]
      }
    }
    lappend rtrn $output
  }
  set _sqlHeader ""
  set i 0
  foreach n $sqlColNames {
    set _sqlHeader [format "%s  %-$cl([incr i])s" $_sqlHeader $n]
  }
  if { [set l1 [clength $_sqlHeader]] < [set l2 [clength [lindex $rtrn 0]]] } {
    set blank " "
    set _sqlHeader "$_sqlHeader[replicate $blank [expr $l2-$l1]]"
  }
  return $rtrn
}
