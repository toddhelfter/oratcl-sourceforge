proc busy { cmds } {

  global errorInfo
  set objs "Frame RowColumn ListBoxWithScroll ListBoxWithHeader DialogBox"

  set list [winfo children .]
  while {$list != "" } {
    set next {}
    foreach w $list {
      if { [lsearch $objs [winfo class $w]] == -1 } {
        catch {lappend busy [list $w [lindex [$w config -cursor] 4]]}
      }
      set next [concat $next [winfo children $w]]
    }
    set list $next
  }
  foreach w $busy {
    catch { if { [winfo ismapped [lindex $w 0]] && 
                 [cequal [wm state [winfo toplevel [lindex $w 0]]] normal] } {
              catch { [lindex $w 0] config -cursor {watch} }
            }
    }
  }
  update idletasks

  set error [catch { uplevel eval [list $cmds] } result]
  if { [info exists errorInfo] } { set ei $errorInfo } else { set ei "" }

  foreach w $busy {
    catch { [lindex $w 0] config -cursor [lindex $w 1] }
  }

  if { $error } {
    error $result $ei
  }  else {
    return $result
  }
}
