
proc VSQL_msgList { id winTitle msgListTitle messageList args } {
  toplevel [set w .msgList_$id]
  wm withdraw $w
  wm title $w "$winTitle"
  wm protocol $w WM_DELETE_WINDOW "
    wm withdraw $w
    $w.f1.ml delete
    destroy $w
  "

  set x [expr [winfo rootx .]+20]
  set y [expr [winfo rooty .]+20]
  set listSize 80x5
  set bitmap ""
  
  set a(-x) {
    set x [lvarpop args]
  }
  set a(-y) {
    set y [lvarpop args]
  }
  set a(-listSize) {
    set listSize [lvarpop args]
  }
  set a(-bitmap) {
    set bitmap [lvarpop args]
  }

  while { [llength $args] > 0 } {
    if { [catch {eval $a([set curArg [lvarpop args]])} err] != 0 } {
      if { [lsearch -exact [array names a] $curArg] == -1 } {
      #-- Default behavior
        catch { puts stderr "Internal OSQL Error: Invalid Arg '$curArg' to VSQL_msgList" }
        return ""
      }
    }
  }

  set listWidth [lindex [split $listSize x] 0]
  set listHeight [lindex [split $listSize x] 1]
  wm geometry $w +${x}+$y

  if { ![cequal $bitmap ""] } {
    frame $w.f0 -relief raised -bd 1
    label $w.f0.error -bitmap $bitmap -fg red -width 20 -height 20
    pack $w.f0.error -side left -padx 20 -pady 5
    pack $w.f0 -expand 1 -fill x
  }
  
  frame $w.f1
  ListBoxWithScroll $w.f1.ml \
    -scrollx 1 \
    -scrolly 1 \
    -title "$msgListTitle" \
    -bd 2 \
    -width $listWidth \
    -height $listHeight

  frame $w.f2
  button $w.f2.done \
    -text "  Ok  " \
    -command "
      wm withdraw $w
      $w.f1.ml delete
      destroy $w
    "

  $w.f1.ml fill $messageList
  
  pack $w.f1.ml -expand 1 -fill both
  pack $w.f1 -expand 1
  pack $w.f2.done -pady 10
  pack $w.f2

  wm deiconify $w
  return $w
}
#<<>>


proc VSQL_yesNoDialog { title message yesAction noAction } {
  DialogBox .yn \
    -bitmap questhead \
    -grab true \
    -message "$message" \
    -title "$title" \
    -button-1 "  Yes  " \
    -button-2 "  No  " \
    -x [expr [winfo rootx .]+30] \
    -y [expr [winfo rooty .]+30]
  .yn command button-1 \
    " $yesAction
     .yn delete
    "
  .yn command button-2 \
    " $noAction
     .yn delete
    "
  .yn setfont \
    message "-adobe-times-bold-r-normal--18-180-75-75-p-99-iso8859-1"
  .yn display
  tkwait window .yn
}
#<<>>


proc VSQL_displayInfo { id message } {
  set w .display_info_$id
  set vsqlCancel($w) 0
  DialogBox $w \
    -message "$message" \
    -title "Information" \
    -bitmap info \
    -x [expr [winfo rootx .]+20] \
    -y [expr [winfo rooty .]-30]
    
  $w setfont \
    message "-adobe-times-bold-r-normal--18-180-75-75-p-99-iso8859-1"
  $w display
  update
  return $w
}
#<<>>


proc VSQL_getLogin { } {

  global _w env vsqlServers vsqlLoginDone vsqlCurrentUser env
  set w .getLogin
  set _w $w
  toplevel $w
  wm geometry $w +[expr ([winfo screenwidth .]/2)-135]+[expr ([winfo screenheight .]/2)-135]
  wm title $w "OSQL Login"
  wm withdraw $w

  if { [lsearch [array names env] USER] } {
    set user $env(USER)
  } else {
    set user ""
  }

  set instance $env(TWO_TASK)

  frame $w.f2 -bd {2}

  label $w.f2.labInst -text {Instance:} -anchor {e} \
    -font {*-courier-bold-r-normal--12-*}
  entry $w.f2.instance -relief {sunken} -width {20}
  bind $w.f2.instance <Key-Tab> " focus $w.f3.user "
  bind $w.f2.instance <Key-Return> " focus $w.f3.user "
  
  pack append $w.f2 \
    $w.f2.labInst { left frame e pady 10} \
    $w.f2.instance  { left frame w pady 10}

  $w.f2.instance insert 0 $instance

  frame $w.f3 -bd {2}

  label $w.f3.labUser  -text {    User:} -anchor {e} \
    -font {*-courier-bold-r-normal--12-*}
  entry $w.f3.user -relief {sunken} -width {20}
  bind $w.f3.user <Key-Tab> " focus $w.f4.pw "
  bind $w.f3.user <Key-Return> " focus $w.f4.pw "

  pack append $w.f3 \
    $w.f3.labUser { left frame e pady 10} \
    $w.f3.user  { left frame w pady 10}

  $w.f3.user insert 0 $user

  frame $w.f4 -bd {2}

  label $w.f4.labPw    -text {Password:} -anchor {e} \
    -font {*-courier-bold-r-normal--12-*}
  entry $w.f4.pw -relief {sunken} -width {20}
  bind $w.f4.pw <Button-1> "
    focus $w.f4.pw
  "
  bind $w.f4.pw <Any-KeyPress> "
    $_w.f4.blindPw insert insert %A
    $w.f4.pw insert insert *
  "
  bind $w.f4.pw <BackSpace> "
    tkEntryBackspace $_w.f4.blindPw
    tkEntryBackspace $w.f4.pw
  "
  bind $w.f4.pw <Delete> "
    $_w.f4.blindPw delete insert
    $w.f4.pw delete insert
  "
  bind $w.f4.pw <Return> { $_w.cntl.ok invoke }
  bindtags $w.f4.pw $w.f4.pw
  entry $w.f4.blindPw -width {20}
  pack append $w.f4 \
    $w.f4.labPw { left frame e pady 10} \
    $w.f4.pw  { left frame w pady 10}

  frame $w.sep1 -bd {2} -width 20 -height 5 -relief {sunken}

  frame $w.cntl -bd {2}

  button $w.cntl.ok -text { Ok } \
    -command { busy {
      global _w vsqlCurrentServer oramsg env
      if { [set newInst [$_w.f2.instance get]] != $env(TWO_TASK) } {
        set env(TWO_TASK) $newInst
      }
      if { [VSQL_login [set vsqlCurrentUser [$_w.f3.user get]] [$_w.f4.blindPw get]] } { 
        set vsqlLoginDone 1
      } else {
	grab release $_w
	grab [set ewin [VSQL_msgList [VSQL_unique getLogin] \
	  "Login Error" \
	  "ORACLE Error No:  $oramsg(rc)" \
	  [split $oramsg(errortxt) \n] \
	  -x [winfo rootx $_w] \
	  -y [winfo rooty $_w] \
	  -bitmap error]]
	tkwait window $ewin
	grab set $_w
      }
    }
    }

  button $w.cntl.cancel -text { Cancel } \
    -command {
      set vsqlLoginDone 0
    }

  pack append $w.cntl \
    $w.cntl.ok     { left frame center padx 30 pady 10 } \
    $w.cntl.cancel { right frame center padx 30 pady 10 }

  pack append $w \
    $w.f2   { top frame center } \
    $w.f3   { top frame center } \
    $w.f4   { top frame center } \
    $w.sep1 { top frame center fillx } \
    $w.cntl { top frame center fillx }

  wm deiconify $w
  tkwait visibility $w
  wm minsize $w [winfo width $w] [winfo height $w]
  grab set $w
  tkwait variable vsqlLoginDone
  grab release $w
  after 100 destroy $w
  return $vsqlLoginDone

}
#<<>>


proc VSQL_unique { name } {

  global vsqlName

  if { [lsearch [array names vsqlName] $name] == -1 } {
    set vsqlName($name) 0
  }
  return [set name]_[incr vsqlName($name)]
      
}
#<<>>


proc VSQL_updateXscroll { win args } {
  eval $win.bot.f0.f1.scrollx set $args
  $win.bot.f0.fH.header xview moveto [lindex $args 0]
}
#<<>>


proc VSQL_updateYscroll { win args } {
  eval $win.bot.f0.f1.scrolly set $args
  eval $win.bot.f0.f1.list yview moveto [lindex $args 0]
}
#<<>>


proc VSQL_updateXview { win args } {
  eval $win.bot.f0.f1.list xview $args
  eval $win.bot.f0.fH.header xview $args
}
#<<>>


proc VSQL_updateYview { win args } {
  eval $win.bot.f0.f1.list yview $args
  eval $win.bot.f0.f2.cnt yview $args
}
#<<>>


proc VSQL_getHeader { w } {
  return "[$w get 0]\n"
}
#<<>>


proc VSQL_getList { w } {
  set output ""
  loop i 0 [$w size] {
    set output "$output\n[$w get $i]"
  }
  return $output
}
#<<>>


proc VSQL_makeFile { sql head list f } {
  global vsqlLastSaveFile vsqlSaveFilePath
  if { [catch { set fout [open "$f" w] } errorCode] != 0 } {
    timedMsg "Error Opening '$f'.\nError: $errorCode" INFINITE -grab {true} \
    -x [winfo rootx .] -y [winfo rooty .]
  } else {
    if { [clength $sql] > 0 } {
      puts $fout "SQL Statement:"
      puts $fout "$sql\n"
      puts $fout "Output:"
    }
    if { [clength $head] > 0 } {
      puts -nonewline $fout $head
    }
    puts -nonewline $fout $list
    close $fout
  }
}
#<<>>


proc VSQL_loadSQL { f w } {
  if { [catch { set fin [open $f r]} errorCode] != 0 } {
    timedMsg "Error Opening File '$f'.\nError: $errorCode" INFINITE \
      -grab {true} -x [winfo rootx .] -y [winfo rooty .]
  } else {
    $w delete 0.0 end
    while { [gets $fin line] != -1 } {
      $w insert insert "$line\n"
    }
    close $fin
  }
}
#<<>>


proc VSQL_updateSQLsaveFile { f } {
  global vsqlLastSaveFile vsqlSaveFilePath
  set vsqlLastSaveFile [file tail $f]
  set vsqlSaveFilePath [file dirname $f]
  .fm.mb0.m entryconfigure 2 -state normal
}


proc VSQL_rePlace { w } {

  global locPart
  if { $locPart < .1 } {
    set locPart .1
  } elseif { $locPart > .9 } { set locPart .9 }
  place $w.top -in $w -x 0 -y 0 -relwidth 1 -relheight [expr $locPart-.02]
  place $w.pan -in $w -x 0 -rely $locPart -relwidth 1.0
  place $w.bot -in $w -x 0 -rely [expr $locPart+.02] \
    -relwidth 1 -relheight [expr "1.0 - $locPart - .02"]
  update idletasks
}
#<<>>


proc VSQL_computeLoc { w loc } {

  global dragStart locPart
  set locPart [expr "(($loc.0 - $dragStart.0)/[winfo height .]) + $locPart"]
  VSQL_rePlace $w
}
#<<>>


proc VSQL_saveResult { w } {
  busy {
    if { [set outfName [selectFile .fsWin1]] != "" } {
      if { [file exists $outfName] } {
	yesNo "Save File" "File $outfName Already Exists.  Overwrite?" \
	  "VSQL_makeFile \"\" \"[VSQL_getHeader $w.bot.f0.fH.header]\" \
	  \"[VSQL_getList $w.bot.f0.f1.list]\" \"$outfName\"" noop No
      } else {
	VSQL_makeFile "" [VSQL_getHeader $w.bot.f0.fH.header] \
	  [VSQL_getList $w.bot.f0.f1.list] $outfName
      }
    }
  }
}
#<<>>


proc VSQL_saveQuery { w } {
  busy {
    if { [set outfName [selectFile .fsWin1]] != "" } {
      if { [file exists $outfName] } {
	yesNo "Save File" "File $outfName Already Exists.  Overwrite?" \
	  "VSQL_makeFile \{\} \{\} \"[$w.top.ft.q get 0.0 end]\" \
	  \"$outfName\"" noop No
      } else {
	VSQL_makeFile "" "" [$w.top.ft.q get 0.0 end] $outfName
      }
    }
  }
}
#<<>>


proc VSQL_setPopupSize { w h } {
  global curPopupWidth curPopupHeight
  set curPopupWidth $w
  set curPopupHeight $h
}
#<<>>


proc VSQL_setCurPopupLoc { w id x y } {
  global vsqlPopupLoc$id
  set vsqlPopupLoc${id}(x) $x
  set vsqlPopupLoc${id}(y) $y
}
#<<>>


proc VSQL_searchList { w id args } {
  global ${w}_searchValue ${w}_double vsqlPopupLoc$id
  if { ![info exists ${w}_searchValue] } { set ${w}_searchValue "" }
  if { $args != "" } {
    set ${w}_double 1
  } else {
    set ${w}_double 0
  }
  set x [expr [set vsqlPopupLoc${id}(x)]+20]
  set y [expr [set vsqlPopupLoc${id}(y)]+20]
  if { [getEntryPopup $x $y "Search list" "Search String:" "[set ${w}_searchValue]" ${w}_searchValue] } {
    VSQL_searchNext $w
  }
}
#<<>>


proc VSQL_searchNext { w } {
  global ${w}_searchValue ${w}_double ${w}_last ${w}_found
  if { ![info exists ${w}_last] } { set ${w}_last "" }
  if { ![info exists ${w}_searchValue] } { return }
  if { [cequal [set ${w}_searchValue] [set ${w}_last]] } {
    if { ![set ${w}_found] } { return }
    set same 1
  } else {
    set same 0
    set ${w}_last [set ${w}_searchValue]
    set ${w}_found 0
  }
  set end [$w.bot.f0.f1.list size]
  if { $end < 1 } { return }
  if { [set cs [$w.bot.f0.f1.list curselection]] == "" } {
    set start 0
  } else {
    set start [expr [lindex $cs 0]+1-[set ${w}_double]]
    if { $start >= $end } { set start 0 }
  }
  set ${w}_double 0
  loop j 0 2 {
    loop i $start $end {
      if { [string first [set ${w}_searchValue] [$w.bot.f0.f1.list get $i]] != -1 } {
        $w.bot.f0.f1.list selection clear 0 end
        $w.bot.f0.f1.list selection set $i
        VSQL_updateYview $w $i
        set ${w}_found 1
        return
      }
    }
    if { !$same || $start == 0 } { return }
    set start 0
    set end [$w.bot.f0.f1.list size]
  }
}
#<<>>


proc VSQL_doAction { w id action } {
  global vsqlPopupLoc$id
  if { [llength [set sel [$w curselection]]] > 1 } {
    timedMsg "Select only one entry." INFINITE -grab {true} \
      -x [set vsqlPopupLoc${id}(x)] -y [set vsqlPopupLoc${id}(y)]
  } elseif { [llength $sel] == 0 } {
    timedMsg "Select an entry first." INFINITE -grab {true} \
      -x [set vsqlPopupLoc${id}(x)] -y [set vsqlPopupLoc${id}(y)]
  } else {
    $action [$w get [lindex [set sel] 0]]
  }
}
#<<>>


proc VSQL_toggleSqlVisible { w id } {
  set v visible$id
  global $v locPart
  if { [cequal [set ${v}(state)] showing] } {
    set ${v}(text) { Show Query }
    set ${v}(state) hidden
    pack unpack $w.top.ft.s
    pack unpack $w.top.ft.q
    set locPart .10
    VSQL_rePlace $w
  } else {
    set ${v}(text) { Hide Query }
    set ${v}(state) showing
    set locPart .23
    VSQL_packPopupQuery $w
    VSQL_rePlace $w
  }
}
#<<>>


proc VSQL_packPopupQuery { w } {
  pack append $w.top.ft \
    $w.top.ft.s    { right frame center filly } \
    $w.top.ft.q    { top frame center expand fill padx 10 pady 10 }
}
#<<>>


proc VSQL_printOutput { w id fout } {
busy {
global prntCmd vsqlPopupLoc$id
set fout /tmp/$fout
VSQL_makeFile [$w.top.ft.q get 0.0 end] [VSQL_getHeader $w.bot.f0.fH.header] \
  [VSQL_getList $w.bot.f0.f1.list] $fout
if { [catch {system "$prntCmd $fout"} errorCode] != 0 } {
  timedMsg "Error Printing Output.\nError: $errorCode" INFINITE -grab {true} \
    -x [set vsqlPopupLoc${id}(x)] -y [set vsqlPopupLoc${id}(y)]
}
unlink $fout
}
}
#<<>>



proc VSQL_popupList { stat_dpy winTitle query header list
                      listLabel offset args } {
  global ynDecision
  if { !$ynDecision } {return }
  if { [ctype space $query] } { return }
  set w .[VSQL_unique popupList]
  set id [lindex [split $w _] 1]
  global _pulWin$id locPart sybmsg curPopupWidth curPopupHeight visible$id \
    vsqlQvisibility vsqlPopupLoc$id
  set locPart .23
  set _pulWin$id $w
  catch { destroy $w }
  set visible${id}(text) " Hide Query "
  set visible${id}(state) showing
  toplevel $w
  set vsqlPopupLoc${id}(x) [expr [winfo rootx $w]+[winfo vrootx $w]]
  set vsqlPopupLoc${id}(y) [expr [winfo rooty $w]+[winfo vrooty $w]]
  bind $w <Configure> "
    if { \[cequal %W $w] } {
      VSQL_setPopupSize %w %h
      VSQL_setCurPopupLoc $w $id %x %y
    }
  "
  wm geometry $w \
    ${curPopupWidth}x${curPopupHeight}+[expr [winfo rootx .]+30+$offset]+[expr [winfo rooty .]+30+$offset]
  wm title $w "$winTitle"
  wm minsize $w 335 300
  wm withdraw $w

  if { $args != "" } {
    set args [lindex $args 0]
    set action [lindex $args 0]
    set actionTitle [lindex $args 1]
  } else {
    set action ""
  }

  frame $w.top -bd {2}
  frame $w.pan -relief {sunken} -width 20 -height 12 -bd {2}
  frame $w.pan.box -width 6 -height 6 -bd {0} -bg {black} -relief {raised}
  pack $w.pan.box -side right -padx 10
  bind $w.pan.box <Button-1> {
    global dragStart
    set dragStart %y
  }
  bind $w.pan.box <B1-Motion> " VSQL_computeLoc $w %y "
  bind $w.pan.box <B1-ButtonRelease> " VSQL_computeLoc $w %y "
  frame $w.bot -bd {2}

  frame $w.top.ft -bd {2}
  frame $w.top.ft.f2
  label $w.top.ft.f2.labQ -text "Query" -anchor {w}
  button $w.top.ft.f2.save -text { Save Query } \
    -command " VSQL_saveQuery [set _pulWin$id] "
  button $w.top.ft.f2.visibility -textvariable visible${id}(text) \
    -command " VSQL_toggleSqlVisible $w $id "
  pack append $w.top.ft.f2 \
    $w.top.ft.f2.labQ { left padx 10 pady 10 } \
    $w.top.ft.f2.save { right padx 20 pady 10 } \
    $w.top.ft.f2.visibility { right padx 20 pady 10 } 
  text $w.top.ft.q \
    -wrap {word} \
    -height {3} \
    -width {50} \
    -relief {sunken} \
    -bd {2} \
    -yscrollcommand " $w.top.ft.s set "
  scrollbar $w.top.ft.s -width {12} \
    -command " $w.top.ft.q yview"
  pack append $w.top.ft \
    $w.top.ft.f2   { top frame center fillx expand }
  if { [cequal [set visible${id}(state)] showing] } {
    VSQL_packPopupQuery $w
  }

  pack $w.top.ft $w.top -side top -expand 1 -fill both

  $w.top.ft.q insert 0.0 "$query"

  frame $w.bot.f0 -bd {2}
  frame $w.bot.f0.fH -bd {2}

  label $w.bot.f0.fH.labList -text "$listLabel" -anchor {w}

  listbox $w.bot.f0.fH.header
  $w.bot.f0.fH.header configure \
    -width 50 -height 1 \
    -xscrollcommand "$w.bot.f0.f1.scrollx set" \
    -relief {sunken} \
    -exportselection {true}

  frame $w.bot.f0.fH.dummy -width 46 -height 20 -relief {sunken}
  pack $w.bot.f0.fH.dummy -side left
  pack $w.bot.f0.fH.labList -side top -fill x
  pack $w.bot.f0.fH.header -side top -fill x

  frame $w.bot.f0.f1

  scrollbar $w.bot.f0.f1.scrolly
  $w.bot.f0.f1.scrolly configure \
    -command "$w.bot.f0.f1.list yview" \
    -command "VSQL_updateYview $w" \
    -relief {sunken} -width {12}

  scrollbar $w.bot.f0.f1.scrollx
  $w.bot.f0.f1.scrollx configure \
    -command "VSQL_updateXview $w" \
    -relief {sunken} -width {12} \
    -orient {horizontal}

  listbox $w.bot.f0.f1.list
  $w.bot.f0.f1.list configure \
    -width 50 -height 7 \
    -yscrollcommand "$w.bot.f0.f1.scrolly set" \
    -xscrollcommand "VSQL_updateXscroll $w" \
    -relief {sunken} \
    -exportselection {true}

  bind $w.bot.f0.f1.list <Double-1> "VSQL_searchList $w $id double "
  bind $w.bot.f0.f1.list <Control-s> "VSQL_searchNext $w"

  pack append $w.bot.f0.f1 \
    $w.bot.f0.f1.scrolly { right frame center filly } \
    $w.bot.f0.f1.list    { top frame center expand fill } \
    $w.bot.f0.f1.scrollx { bottom frame center fillx }

  frame $w.bot.f0.f2
  frame $w.bot.f0.f2.dummy -width 12 -height 16

  listbox $w.bot.f0.f2.cnt
  $w.bot.f0.f2.cnt configure \
    -width 6 -height 7 \
    -yscrollcommand "VSQL_updateYscroll $w" \
    -relief {sunken} \
    -exportselection {true}

  bind $w.bot.f0.f2.cnt <Button-1> { }

  pack $w.bot.f0.fH -side top -fill x
  pack $w.bot.f0.f2.dummy -side bottom 
  pack $w.bot.f0.f2.cnt -side top -fill y -expand 1
  pack $w.bot.f0.f2 -side left -fill y
  pack $w.bot.f0.f1 -side left -fill both -expand 1

  if { "$action" != "" } {
    frame $w.bot.action -bd {2} -width 20 -height 30
    button $w.bot.action.act -text "$actionTitle" \
      -command " VSQL_doAction $w.bot.f0.f1.list $id $action "
    if { [lindex $list 0] == "No Rows Returned" } {
      $w.bot.action.act configure -state disabled
    } 
    pack $w.bot.action.act -fill x
  }

  frame $w.bot.sep1 -bd {2} -width 20 -height 5 -relief {sunken}

  frame $w.bot.cntl -bd {2} -width 20 -height 30

  button $w.bot.cntl.ok -text {Ok} -width 5 \
    -command "
      wm withdraw $w
      unset _pulWin$id
      unset visible${id}
      unset vsqlPopupLoc${id}
      after 2 destroy $w " \
    -state disabled
  button $w.bot.cntl.print -text {Print} -width 5 \
    -command " VSQL_printOutput [set _pulWin$id] $id [translit { } {_} $winTitle] " \
    -state disabled
  button $w.bot.cntl.save -text {Save} -width 5 \
    -command " VSQL_saveResult [set _pulWin$id] " \
    -state disabled
  button $w.bot.cntl.search -text {Search} -width 5 \
    -command " busy \{ VSQL_searchList $w $id \}" \
    -state disabled
  button $w.bot.cntl.next -text {Next} -width 5 \
    -command " busy \{ VSQL_searchNext $w \}" \
    -state disabled

  pack $w.bot.cntl.ok $w.bot.cntl.print $w.bot.cntl.save $w.bot.cntl.search \
    $w.bot.cntl.next -side left -padx 5

  pack append $w.bot \
    $w.bot.f0   { top frame center expand fill }
  if { "$action" != "" } {
    pack append $w.bot $w.bot.action { top frame center fillx }
  }
  pack append $w.bot \
    $w.bot.sep1 { top frame center fillx pady 10 } \
    $w.bot.cntl { top frame center fillx expand }

  if { [cequal $vsqlQvisibility "hide"] } {
    VSQL_toggleSqlVisible $w $id
  }
  VSQL_rePlace $w
  wm deiconify $w

  set nLines [llength $list]
  if { $nLines > 500 } {
    set monitor 1
    set tenPercent [expr $nLines/10]
  } else {
    set monitor 0
  }
  set pctCount 0
  set updCount 0
  set cntr 0
  
  $w.bot.f0.fH.header insert end $header
  update
  
  foreach line $list {
    incr pctCount
    set isl 0
    incr cntr
    foreach subLine [split $line \n] {
      if { [string trim $subLine] != "" } {
        $w.bot.f0.f1.list insert end $subLine
        if { $isl == 0 } {
          $w.bot.f0.f2.cnt insert end $cntr
        } else {
          $w.bot.f0.f2.cnt insert end [format "%s" " .$isl"]
        }
        incr isl
        incr updCount
        if { $updCount >= 100 } {
          update
          set updCount 0
        }
      }
    }
    if { $monitor && ( $pctCount >= $tenPercent ) } {
      $stat_dpy config \
        -message "Preparing Results Display - [expr $cntr*100/$nLines]% Done"
      set pctCount 0
      update
    }
  }

  $w.bot.cntl.ok config -state normal
  $w.bot.cntl.print config -state normal
  $w.bot.cntl.save config -state normal
  $w.bot.cntl.search config -state normal
  $w.bot.cntl.next config -state normal
  
}
#<<>>


proc VSQL_login { user pwd } {

  global dbHandle env
  if { [ologin dbHandle $user $pwd] != -1 } {
    return 1
  } else {
    return 0
  }

}
#<<>>


proc VSQL_logout { { h "dbHandle" } { c {} } } {

  global $h env dbCursor $c vsqlMon
  if { [cequal $h "dbHandle"] && [info exists dbCursor] } {
    oclose $dbCursor
  } else {
    if { ![cequal $c ""] && [info exists $c] } {
      oclose [set $c]
    }
  }
  ologout [set $h]
  if { $vsqlMon } { catch { send Vsqlmon CML_exit } }

}
#<<>>


proc VSQL_format { stat_dpy list } {

  global dbHandle sqlColLens sqlColNames sqlColTypes oramsg \
    vsqlHeader sqlColPrecs sqlColScales
  if { "$list" == "" } { set vsqlHeader ""; return "\{No Rows Returned\}" }
  set i 0
  foreach c $sqlColLens {
    incr i
    set ctype($i) [lindex $sqlColTypes [expr $i-1]]
    set cprec($i) [lindex $sqlColPrecs [expr $i-1]]
    set cscale($i) [lindex $sqlColScales [expr $i-1]]
    if { [cequal $ctype($i) number] && $cprec($i) != 0 
         && $cscale($i) == 0 } { set ctype($i) int }
    if { "$ctype($i)" == "int" } {
      set cl($i) [max 12 [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) d
      set fmt($i) ""
    } elseif { "$ctype($i)" == "number" } {
      if { $cprec($i) <= 0 } {
        set cprec($i) 19
        set cscale($i) 7
      }
      if { $cscale($i) < 0 } {
        set cscale($i) 0
      }
      if { $cscale($i) == 0 } {
        set p $cprec($i)
      } else {
        set p [expr $cprec($i)+1]
      }
      set cl($i) [max $p [clength [lindex $sqlColNames [expr $i-1]]]].$cscale($i)
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
    } elseif { $ctype($i) == "long" } {
      set ct($i) T
      set cl($i) [max 30 [clength [lindex $sqlColNames [expr $i-1]]]]
    } else {
      set cl($i) [max $c [clength [lindex $sqlColNames [expr $i-1]]]]
      set ct($i) s
      set fmt($i) "-"
    }
  }
  set nRows [llength $list]
  set nCols $i
  if { [expr $nRows*$nCols] > 1000 } {
    set monitor 1
    set tenPercent [expr $nRows/10]
  } else {
    set monitor 0
  }
  set pctCount 0
  set n 0
  set textFlag 0
  foreach row $list {
    incr n
    incr pctCount
    set output ""
    set i 0
    set maxTlen 0
    foreach item $row {
    incr i
      if { [cequal "$item" "NULL"] } {
        if { "$ct($i)" == "f" } {
	  set l [lindex [split $cl($i) .] 0]
	} else {
	  set l $cl($i)
	}
        append output [format "  %-[set l]s" $item]
      } elseif { $ct($i) == "T" } {
        set textFlag 1
        set tmpout ""
        foreach piece [string trimright [split $item \n]] {
          if { [clength [string trim $piece]] > 0} {
            lappend tmpout $piece
            set maxTlen [max $maxTlen [clength $piece]]
          }
        }
        append output "  [join $tmpout \n]"
      } else {
        append output [format "  %$fmt($i)$cl($i)$ct($i)" "$item"]
      }
    }
    lappend rtrn $output
    if { $monitor && ($pctCount >= $tenPercent) } {
      $stat_dpy config \
        -message "Formatting Results - [expr $n*100/$nRows]% Done"
      set pctCount 0
    }
    update
  }
  set vsqlHeader ""
  set i 0
  foreach n $sqlColNames {
    incr i
    set fldLen [lindex [split $cl($i) .] 0]
    if { [set leftDiff [expr (($fldLen-[clength $n])/2)-1]] >= 0 } {
      set rightDiff [expr $fldLen-($leftDiff+2+[clength $n])]
      
      set n "<[replicate - $leftDiff]$n[replicate - $rightDiff]>"
    }
    set vsqlHeader [format "%s  %-${fldLen}s" $vsqlHeader $n]
  }
  if { [set l1 [clength $vsqlHeader]] < [set l2 [clength [lindex $rtrn 0]]] } {
    if { !$textFlag } {
      set vsqlHeader "$vsqlHeader[replicate { } [expr $l2-$l1]]"
    } else {
      set vsqlHeader "$vsqlHeader[replicate { } [expr $maxTlen-$l1]]"
    }
  }
  return $rtrn
}
#<<>>


proc VSQL_insertSelected { w } {
  catch { $w insert insert [selection get] }
  $w yview -pickplace insert
}
#<<>>


proc VSQL_getCurrentUser { } {
  global vsqlCurrentUser
  return $vsqlCurrentUser
}
#<<>>


proc VSQL_getMonitorStat { } {
  global vsqlMon
  return $vsqlMon
}
#<<>>

proc VSQL_lookForConditionals { s } {
  return $s
}
#<<>>


proc VSQL_doQuery { hflag stmt args } {
  global vsqlCurrentUser vsqlCurrentServer resultNo dbHandle oramsg vsqlHeader \
         history vsqlMaxDpyChars
  if { ![ctype space $stmt] && "$stmt" != "" } {
    if { $hflag } {
      if { [incr history(maxptr)] == 1 } { .fm.mb0.m entryconfigure 4 -state normal }
      set history(ptr) $history(maxptr)
      set history($history(maxptr)) "$stmt"
      set history($history(maxptr).args) [format "%s" "$args"]
    }
#    if { [string first {&} $stmt] != -1 } {
#      set stmt [VSQL_lookForConditionals $stmt]
#    }
    set history(result) "Pending..."
    incr resultNo
    set dpy [VSQL_displayInfo $resultNo "Executing Query"]
    if { [VSQL_getMonitorStat] } {
      set cu [VSQL_getCurrentUser]
      set stmt_txt [join [split $stmt {"}] {\"}]
      set stmt_txt [join [split $stmt {$}] {\$}]
      if { [catch {send Vsqlmon CML_send \"$cu on ORACLE is executing '$stmt_txt'\"} err] != 0 } {
        catch { puts stderr "VSQL:  send error: '$err'" }
      }
    }
    set dbCursor [oopen $dbHandle]
    set timeStart [getclock]
    set resultList [orasqlGetRowList $dbCursor "$stmt"]
    set elapsed [expr [getclock]-$timeStart]
    set resultLen [llength $resultList]
    set resultChars [clength $resultList]
    if { [cequal $resultList "**SQLERROR**"] } {
      set history($history(maxptr).result) "Error"
      $dpy delete
      VSQL_msgList \
        $resultNo \
        "SQL Error - Result $resultNo" \
        "ORACLE Error No:  $oramsg(rc)" \
        [split $oramsg(errortxt) \n] \
        -bitmap error
    } else {
      if { [cequal $resultList "\{\{Action Performed\}\}"] } {
        set history($history(maxptr).result) "DDL Ok"
      } else {
        if { $resultLen > 1 } {
          set history($history(maxptr).result) "[llength $resultList] Rows"
        } else {
          set history($history(maxptr).result) "[llength $resultList] Row"
        }
      }
      global ynDecision
      set ynDecision 1
      if { $resultLen > 5000 || $resultChars > $vsqlMaxDpyChars } {
	  VSQL_yesNoDialog "Save Raw Results?" "Results Set Too Large To Process!\nSave Raw Results To A File?" "" "global ynDecision; set ynDecision 0"
	  if { $ynDecision } {
	  set raw ""
	  foreach line $resultList {
	    append raw "$line\n"
	  }
        busy {
          if { [set outfName [selectFile .fsWin1]] != "" } {
            if { [file exists $outfName] } {
      	yesNo "Save File" "File $outfName Already Exists.  Overwrite?" \
      	  "VSQL_makeFile \"\" \"" \
      	  \"$raw\" \"$outfName\"" noop No
            } else {
      	VSQL_makeFile "" "" "$raw" $outfName
            }
          }
        }
        unset raw
        unset resultList
        }
	} else {
          $dpy config -message "Formatting Results"
          update
          set fmtResult [VSQL_format $dpy $resultList]
          $dpy config -message "Preparing Results Display"
          update
          unset resultList
          VSQL_popupList $dpy "OSQL Result $resultNo" \
  	  "$stmt" "$vsqlHeader" "$fmtResult" \
  	  "Result $resultNo - $resultLen Rows from ORACLE in $elapsed Seconds" 0 $args
          unset fmtResult
	}
	$dpy delete
    }
    set history(result) $history($history(ptr).result)
    oclose $dbCursor
  }
}
#<<>>


proc VSQL_attributes { owner_tab } { busy {
  set o [lindex $owner_tab 0]
  set t [lindex $owner_tab 1]
  VSQL_doQuery  1 "select column_name, data_type, data_length,
               data_precision, data_scale, nullable
	       from all_tab_columns
	       where  table_name = '$t' and owner = '$o'
	       order by column_id"
}
}
#<<>>


proc VSQL_getPrevQuery { w } {
  global history
  if { $history(maxptr) > 0 } {
    if { $history(ptr) > 1 } { incr history(ptr) -1 }
    set history(result) $history($history(ptr).result)
    $w delete 0.0 end
    $w insert 0.0 "$history($history(ptr))"
    $w yview -pickplace insert
    set history(newflag) 0
  }
}
#<<>>


proc VSQL_getNextQuery { w } {
  global history
  if { $history(maxptr) > 1 } {
    if { $history(ptr) < $history(maxptr) } { incr history(ptr) }
    set history(result) $history($history(ptr).result)
    $w delete 0.0 end
    $w insert 0.0 "$history($history(ptr))"
    $w yview -pickplace insert
    set history(newflag) 0
  }
}
#<<>>


proc VSQL_getViewTxt { owner_view } {
  set o [lindex $owner_view 0]
  set v [lindex $owner_view 1]
  VSQL_doQuery 1 "select text
	       from all_views
	       where  view_name = '$v' and owner = '$o'"
}
#<<>>


proc VSQL_getIndexTxt { owner_index } {
  set o [lindex $owner_index 0]
  set i [lindex $owner_index 1]
  VSQL_doQuery 1 "select *
	       from all_indexes
	       where  index_name = '$i' and owner = '$o'"
}
#<<>>


proc VSQL_getProcTxt { owner_source } {
  set o [lindex $owner_source 0]
  set s [lindex $owner_source 1]
  VSQL_doQuery 1 "select text from all_source
                where owner = '$o' and name = '$s'
                order by line"
}
#<<>>


proc VSQL_getTriggerTxt { owner_trigger } {
  set o [lindex $owner_trigger 0]
  set t [lindex $owner_trigger 1]
  VSQL_doQuery 1 "select
                owner, trigger_name, trigger_type, triggering_event, 
                table_owner, table_name, referencing_names, when_clause, 
                status, description, trigger_body
                from all_triggers
	         where  trigger_name = '$t' and owner = '$o'"
}
#<<>>


proc VSQL_clearSQLBuff { } {
  global history resultNo
  loop i 1 [expr $history(maxptr)+1] {
    unset history($i)
    unset history($i.args)
    unset history($i.result)
    set resultNo 0
  }
  set history(maxptr) 0
  set history(ptr) 0
  set history(result) $history($history(ptr).result)
  .sql.sqlText delete 0.0 end
  .fm.mb0.m entryconfigure 4 -state disabled
}
#<<>>


proc VSQL_stripComments { s } {
  upvar $s stmt
  set last_i 0
  while { [expr [clength $stmt]-$last_i] >= 4 } {
    if { $last_i > 0 } {
      set beginStmt [crange $stmt 0 $last_i]
      incr last_i
    } else {
      set beginStmt ""
    }
    set subStmt [crange $stmt $last_i end]
    set i1 [string first /* $subStmt]
    if { [set i1 [string first /* $subStmt]] != -1 &&
         [string index $subStmt [expr $i1+2]] != "+" } {
      if { [set i2 [string first */ $subStmt]] != -1 } {
        if { [incr i1 -1] > 0 } {
          set tmp [csubstr $subStmt 0 $i1]
        } else {
          set tmp ""
        }
        if { [incr i2 2] <= [clength $subStmt] } {
          set subStmt "$tmp[csubstr $subStmt $i2 end]"
        }
        set stmt "$beginStmt$subStmt"
      }
    } elseif { $i1 != -1 } {
      #This an Oracle sql parser hint - leave it in 
      set last_i [expr 1+[clength $beginStmt]+[string first */ $subStmt]]
    } else {
      break
    }
  } 
  set i 0
  foreach line [set tmp [split $stmt \n]] {
    if { [string match rem* \
           [string tolower [string range [string trimleft $line] 0 5]]] } {
      #-- This must be a sqlplus remark
      lvarpop tmp $i
      incr i -1
    }
    incr i
  }
  set stmt [join $tmp \n]
}
#<<>>


proc VSQL_stripSQLPlusCmds { s } {
  global vsqlSQLPlusCmds
  upvar $s stmt
  set sql $stmt
  set i 0
  foreach q [set tmp [split $sql \n]] {
    if { [VSQL_isSQLPlusCmd $q] } {
      #-- This is a SQL Plus command, so pop it out of the list
      lvarpop tmp $i
      incr i -1
    }
    incr i
  }
  set sql [join $tmp \n]
  foreach q [set tmp [split $sql {;}]] {
    if { [VSQL_isSQLPlusCmd $q] } {
      #-- This is a SQL Plus command, so pop it out of the list
      lvarpop tmp $i
      incr i -1
    }
    incr i
  }
  set stmt [join $tmp \;]
}
#<<>>


proc VSQL_isSQLPlusCmd { line } {
  #-- Returns 1 if sqlplus command; 0 if not
  global vsqlSQLPlusCmds
  set word0 [string tolower [lindex $line 0]]
  if { [clength $word0] >= 3 &&
       [lsearch -glob $vsqlSQLPlusCmds $word0*] > -1 } {
    #-- This is a SQL Plus command
    return 1
  }
  return 0
}
#<<>>


#------------------------------------------------------------------------------#
#  main begins here
set vsqlLib $vsqlHome/lib

lappend auto_path $vsqlHome
lappend auto_path $vsqlLib/objects/tk

#Forward Declaration of Objects
Widget
DialogBox

source $vsqlLib/orasqlprocs.tcl
source $vsqlLib/popups6.6.tcl
source $vsqlLib/busy.tcl
source $vsqlLib/hyperhelp.tcl
source $vsqlHome/plsql.tcl

#-- Initialize variables
set vsqlMon 0
set vsqlrc ".tk_vsqlrc"
set vsqlName(__VSQL) NULL
set resultNo 0
VSQL_setPopupSize 450 375
set vsqlCurrentUser ""
set vsqlPW ""
set vsqlLastSaveFile ""
set vsqlMaxDpyChars 1000000
set vsqlSQLPlusCmds { column remark whenever break btitle clear pattern compute spool title set }
set vsqlTokenSeps {.%'" ;
	}
set history(ptr) 0
set history(maxptr) 0
set history(0.result) ""
set history(result) ""
set history(newflag) 1

#-- Check for args
set sw(-monitor) {
  #-- Don't do this at POSC
  #set vsqlMon 1
}
set sw(-u) {
  set vsqlCurrentUser [lvarpop argv 0]
}
set sw(-p) {
  set vsqlPW [lvarpop argv 0]
}
set sw(-i) {
  set inputFile [lvarpop argv 0]
}
while { [llength $argv] > 0 } {
  if { [catch {eval $sw([set curArg [lvarpop argv]])} err] != 0 } {
    if { [lsearch -exact [array names sw] $curArg] == -1 } {
      #-- Default behavior
      catch { puts stderr "\nOSQL:  Unknown argument '$curArg'" }
      catch { puts stderr "Usage:  osql \[-u userid\] \[-p password\] \[-i inputfile\] \[-monitor\]" }
      exit 10
    } else {
      catch { puts stderr "\nOSQL:  Internal error processing args:" }
      catch { puts stderr "       Current argument = '$curArg'" }
      catch { puts stderr "       Stack Trace:\n$errorInfo" }
      exit 10
    }
  }
}
unset sw

#-- Start conference mailer if necessary
if { $vsqlMon && [catch { send Vsqlmon Respond }] != 0 } {
  exec $vsqlHome/vsqlmon $env(USER) VSQL {} &
}

#-- Build main window
wm geometry . 80x10
wm iconname . "OSQL"
wm minsize . 80 10
wm positionfrom . program
wm sizefrom . user
wm withdraw .
wm protocol . WM_DELETE_WINDOW {
  VSQL_logout
  destroy .
  exit
}

#-----Set the X Defaults-----
#  Presumes that wish sets the Tk Class to the capitalized name of the 
#  program, i.e.- if program file = "vsql", then Tk Class becomes "Vsql"
if { [file exists $vsqlHome/.osql_Xdefaults] } {
  option readfile $vsqlHome/.osql_Xdefaults
}

#-----Read the vsql rc file if it exists-----
if { ![file exists /home/$env(USER)/$vsqlrc] } {
  set prntCmd "lpr -l"
} else {
  set fin [open /home/$env(USER)/$vsqlrc r]
  while { [gets $fin line] != -1 } {
    case [lindex $line 0] in {
      PRINT { set prntCmd [lindex $line 1] }
    }
  }
  close $fin
}

#-- Check to see if user has given us a userid in the commandline args
set vsqlLoginDone 0
if { ![cequal $vsqlCurrentUser ""] } {
  #-- Login now
  if { [VSQL_login $vsqlCurrentUser $vsqlPW] } { 
    set vsqlLoginDone 1
  } else {
    grab [set ewin [VSQL_msgList \
      [VSQL_unique main] \
      "Login Error" \
      "ORACLE Error No:  $oramsg(rc)" \
      [split $oramsg(errortxt) \n] \
      -bitmap error]]
    tkwait window $ewin
  }
  unset vsqlPW
}

#-- Build menus
frame .fm -bd 2 -relief {raised}
menubutton .fm.mb0
.fm.mb0 configure \
  -menu {.fm.mb0.m} \
  -text " File " \
  -underline 1

menubutton .fm.mb1
.fm.mb1 configure \
  -menu {.fm.mb1.m} \
  -text " Props " \
  -underline 1

menubutton .fm.mb1a
.fm.mb1a configure \
  -menu {.fm.mb1a.m} \
  -text " DB Options " \
  -underline 1

menubutton .fm.mb2
.fm.mb2 configure \
  -menu {.fm.mb2.m} \
  -text " Objects " \
  -underline 1

menubutton .fm.mbHelp
.fm.mbHelp configure \
  -menu {.fm.mbHelp.m} \
  -text " Help " \
  -underline 1

tk_menuBar .fm .fm.mb0 .fm.mb1 .fm.mb1a .fm.mb2 .fm.mbHelp

menu .fm.mb0.m
# Menu widget code
.fm.mb0.m add command \
  -label " Load SQL... " \
  -underline 1 \
  -command { VSQL_loadText .sql.sqlText  }
.fm.mb0.m add command \
  -label " Save " \
  -underline 1 \
  -command {
    VSQL_saveText .sql.sqlText "$vsqlSaveFilePath" "$vsqlLastSaveFile"
  }
.fm.mb0.m add command \
  -label " Save SQL As... " \
  -underline 10 \
  -command {
    VSQL_saveTextAs .sql.sqlText
  }
.fm.mb0.m add command \
  -label " Clear SQL Stmt Buffer " \
  -underline 1 \
  -command { busy {
      VSQL_clearSQLBuff
    }
  }
.fm.mb0.m add command \
  -label " New Connection... " \
  -underline 1 \
  -command {
    global dbHandle saveHandle env
    set saveHandle $dbHandle
    if { [VSQL_getLogin] } {
      VSQL_logout "saveHandle" "saveCursor"
      wm title . "OSQL to $env(TWO_TASK) as $vsqlCurrentUser"
    } else {
      set dbHandle $saveHandle
    }
    focus .sql.sqlText
  }
.fm.mb0.m add separator
.fm.mb0.m add command \
  -label " Exit " \
  -underline 2 \
  -command { VSQL_logout; destroy .; exit}

menu .fm.mb1.m
# Menu widget code
.fm.mb1.m add command \
  -label " Print... " \
  -underline 1 \
  -command { busy {
    global prntCmd
    if { [getEntryPopup [expr [winfo rootx .]+20] [expr [winfo rooty .]+20] "Enter Print Cmd" "Command:" "$prntCmd" tmpCmd] } {
      if { "$tmpCmd" != "" } {
	set prntCmd "$tmpCmd"
	set fout [open /home/$env(USER)/$vsqlrc w]
	puts $fout "PRINT \{$prntCmd\}"
	close $fout
      }
    }
  }
  }
.fm.mb1.m add cascade \
  -label " Results Query Window " \
  -underline 1 \
  -menu .fm.mb1.m.t

menu .fm.mb1a.m
.fm.mb1a.m add cascade -label " Autocommit " \
  -menu .fm.mb1a.m.a \
  -underline 1
  
.fm.mb1a.m add command -label " Commit Now " \
  -underline 1 \
  -command {
    oracommit $dbHandle
    timedMsg "Transactions Committed" 10000
  }

.fm.mb1a.m add command -label " Rollback Now " \
  -underline 1 \
  -command {
    oraroll $dbHandle 
    timedMsg "Transactions Rolledback" 10000
  }

.fm.mb1a.m add separator

.fm.mb1a.m add cascade -label " SQL Trace " \
  -menu .fm.mb1a.m.t \
  -underline 1

.fm.mb1a.m add separator

.fm.mb1a.m add command -label " Execute PL/SQL " \
  -underline 1 \
  -command { VSQL_execPLSQL }

menu .fm.mb2.m
.fm.mb2.m add command \
  -label " Describe Table... " \
  -underline 1 \
  -command {
    set table ""
    set owner ""
    getEntryPopup \
      [expr [winfo rootx .]+20] \
      [expr [winfo rooty .]+20] \
      "Enter Table Name" "Table = " \
      "" \
      table
    if { [cequal $table ""] } { return }
    set table [translit a-z A-Z $table]
    getEntryPopup \
      [expr [winfo rootx .]+20] \
      [expr [winfo rooty .]+20] \
      "Enter Owner Name" "Owner = " \
      "" \
      owner
    if { [cequal $owner ""] } {
      busy {
      VSQL_doQuery 1 "select owner, table_name from all_tables 
                      where table_name like '$table' order by owner, 
                      table_name " VSQL_attributes {Show Attributes}
      }
    } else {
      VSQL_doQuery 1 "select column_name, data_type, data_length,
                      data_precision, data_scale, nullable
	               from all_tab_columns
	               where table_name like '$table' and
	                     owner = '[translit a-z A-Z $owner]'
	               order by column_id"
    }
  }

.fm.mb2.m add command \
  -label " Tables " \
  -underline 1 \
  -command { busy {
    VSQL_doQuery 1 {select owner, table_name from all_tables order by owner, 
                  table_name } VSQL_attributes {Show Attributes}
  }
  }

.fm.mb2.m add command \
  -label " Views " \
  -underline 1 \
  -command { busy {
    VSQL_doQuery 1 {select owner, view_name from all_views 
	          order by owner, view_name} VSQL_getViewTxt {Show Text}
  }
  }
  
.fm.mb2.m add command \
  -label " Indexes " \
  -underline 1 \
  -command { busy {
    VSQL_doQuery 1 {select distinct index_owner, index_name, table_owner,
	       table_name
	       from all_ind_columns
	       order by index_owner, index_name, table_owner, table_name} \
    VSQL_getIndexTxt {Show Text}
  }
  }
  
.fm.mb2.m add command \
  -label " Procedures " \
  -underline 1 \
  -command { busy {
    VSQL_doQuery 1 {select distinct owner, name, type from all_source
                  order by owner, name} \
    VSQL_getProcTxt {Show Text}
  }
  }
  
.fm.mb2.m add command \
  -label " Triggers " \
  -underline 1 \
  -command { busy {
    VSQL_doQuery 1 {select distinct owner, trigger_name, table_owner, table_name
		    from all_triggers
                    order by  owner, trigger_name, table_owner, table_name} \
    VSQL_getTriggerTxt {Show Text}
  }
  }

menu .fm.mbHelp.m
.fm.mbHelp.m add command \
  -label " Version... " \
  -underline 1 \
  -command { hyperhelp_file Version  }
.fm.mbHelp.m add command \
  -label " Application... " \
  -underline 1 \
  -command { hyperhelp_file Osql.intro }

menu .fm.mb1.m.t
.fm.mb1.m.t add radio -label " Show " -value show -variable vsqlQvisibility
.fm.mb1.m.t add radio -label " Hide " -value hide -variable vsqlQvisibility

menu .fm.mb1a.m.a
.fm.mb1a.m.a add radio -label " On " -value on -variable autocom \
  -command {
    oraautocom $dbHandle on
    .fm.mb1a.m entryconfigure 2 -state disabled
    .fm.mb1a.m entryconfigure 3 -state disabled
    .fm.mb1a.m.a entryconfigure 1 -state disabled
    .fm.mb1a.m.a entryconfigure 2 -state normal
    timedMsg "Autocommit Set On" 10000
  }
.fm.mb1a.m.a add radio -label " Off " -value off -variable autocom \
  -command {
    oraautocom $dbHandle on
    .fm.mb1a.m entryconfigure 2 -state normal
    .fm.mb1a.m entryconfigure 3 -state normal
    .fm.mb1a.m.a entryconfigure 2 -state disabled
    .fm.mb1a.m.a entryconfigure 1 -state normal
    timedMsg "Autocommit Set Off" 10000
  }

menu .fm.mb1a.m.t
.fm.mb1a.m.t add radio -label " On " \
  -value on \
  -variable sqlTrace \
  -command {
    set dbCursor [oraopen $dbHandle]
    if { [orasqlGetRowList $dbCursor {alter session set sql_trace = true}] ==
         "**SQLERROR**" } {
      VSQL_msgList [VSQL_unique main] "Trace On Error" \
        "ORACLE Error No:  $oramsg(rc)' \
        [split $oramsg(errortxt) \n] \
        -bitmap error
    } else {
      .fm.mb1a.m.t entryconfigure 1 -state disabled
      .fm.mb1a.m.t entryconfigure 2 -state normal
      timedMsg "SQL Trace Set On." 10000
    }
    oraclose $dbCursor
    unset dbCursor
  }

.fm.mb1a.m.t add radio -label " Off " \
  -value off \
  -variable sqlTrace \
  -command {
    set dbCursor [oraopen $dbHandle]
    if { [orasqlGetRowList $dbCursor {alter session set sql_trace = false}] ==
         "**SQLERROR**" } {
      VSQL_msgList [VSQL_unique main] "Trace Off Error" \
        "ORACLE Error No:  $oramsg(rc)' \
        [split $oramsg(errortxt) \n] \
        -bitmap error
    } else {
      .fm.mb1a.m.t entryconfigure 2 -state disabled
      .fm.mb1a.m.t entryconfigure 1 -state normal
      timedMsg "SQL Trace Set Off." 10000
    }
    oraclose $dbCursor
    unset dbCursor
  }
  
pack append .fm \
  .fm.mb0 { left frame center } \
  .fm.mb1 { left frame center } \
  .fm.mb1a { left frame center } \
  .fm.mb2 { left frame center } \
  .fm.mbHelp { right frame center }


#-- Build action buttons
frame .action
button .action.exec -text { Execute SQL } \
  -command {
    global history vsqlSQLPlusCmds
    #-- Escape any dollar signs in the query
    set sql [join [split [.sql.sqlText get 0.0 end] \$] \\$]
    set ok 1

    #-- Could this be a file to input? --> @filename as the first word
    if { [cequal [string index [set firstWord [lindex $sql 0]] 0] {@}] &&
         [clength $firstWord] > 1 } {
      VSQL_loadSQL [string range $firstWord 1 end] .sql.sqlText
      if { ![cequal [set sqlTmp [join [split [.sql.sqlText get 0.0 end] \$] \\$]] $sql] } {
        set sql $sqlTmp
      } else {
        #-- Got a bad filename
        set ok 0
      }
    }
    if { $ok } {  
    busy {
    if { [incr history(maxptr)] == 1 } {
      .fm.mb0.m entryconfigure 4 -state normal
    }
    set history(ptr) $history(maxptr)
    set history($history(maxptr)) [.sql.sqlText get 0.0 end]
    set history($history(maxptr).args) ""

    #-- Are there any multiple &&s?
    if { [string first && $sql] != -1 } {
      grab [set ewin [VSQL_msgList [VSQL_unique txtParse] \
        "SQL Parse Error" \
  	 "Variable Substitution Error" \
  	 {{Query Cannot Contain Multiple Ampersands}} \
  	 -x [winfo rootx .] \
  	 -y [winfo rooty .] \
  	 -bitmap error]]
      tkwait window $ewin
    } else {
    
    #-- Ignore any semicolons between single quotes
    set i 0
    set tmp_sql ""
    foreach p [split $sql '] {
      if { [expr $i-($i/2*2)] == 1 } {
        lappend tmp_sql [translit \; \x04 $p]
      } else {
        lappend tmp_sql $p
      }
      incr i
    }
    set sql [join $tmp_sql ']
    
    #-- Get rid of sqlplus comments & commands
    VSQL_stripComments sql
    VSQL_stripSQLPlusCmds sql

    #-- Execute individual queries one at a time
    foreach q [split $sql \;] {
      #-- Put back any semicolons we took out that were between single quotes
      set q [translit \x04 \; $q]
      #-- Look for \& (escaped ampersands) and temporarily ignore them
      set tmp_q ""
      foreach p [split $q \\] {
        if { [cequal [cindex $p 0] &] } {
          lappend tmp_q \x03[crange $p 1 end]
        } else {
          lappend tmp_q $p
        }
      }
      set q [join $tmp_q ""]
      
      #-- See if there any dynamic input variables
      set ix 0
      set term [expr [clength $q]-1]
      set subList ""
      set subListVal ""
      set subToken ""
      set subLen ""
      set n 0
      set splices ""
      while { $ix < $term } {
        if { [set iy [string first & [csubstr $q $ix end]]] != -1 } {
          #-- There is a substitution variable
          set ix_save $ix
          set ix [expr $ix+$iy+1] 
          set tmpstr [csubstr $q $ix end]
          set vname [ctoken tmpstr $vsqlTokenSeps]
          if { [set ii [lsearch $subList &$vname]] == -1 } {
            lappend subList "&$vname"
            lappend subLen [set curLen [clength $vname]]
            lappend subToken "@[incr n]@"
            set curToken "@$n@"
          } else {
            set curToken [lindex $subToken $ii]
            set curLen [lindex $subLen $ii]
          }
          lappend splices "[expr $ix-1] $curLen $curToken"
          set ix [expr $ix_save+$iy+$curLen]
        } else {
          break
        }
      }
      if { [llength $splices] != 0 } {
        #-- Splice the tokens into the original query string
        set i 0
        set newQ ""
        foreach splice $splices {
          set s [lindex $splice 0]
          set l [lindex $splice 1]
          set t [lindex $splice 2]
          if { [expr $s-1] > 0 } {
            set newQ "$newQ[crange $q $i [expr $s-1]]$t"
          }
          set i [expr $s+$l+1]
        }
        if { $i <= [expr [clength $q]-1] } {
          set newQ "$newQ[csubstr $q $i end]"
        }
        set q $newQ
      }
      set abort 0
      foreach v $subList {
        set tmpvar ""
        getEntryPopup \
          [expr [winfo rootx .]+20] \
          [expr [winfo rooty .]+20] \
          "Enter Variable" "$v = " \
          "" \
          tmpvar
        if { [cequal $tmpvar ""] } {
          set abort 1
          break
        } else {
          lappend subListVal $tmpvar
        }
      }
      if { !$abort } {
        set ix 0
        foreach t $subToken {
          regsub -all $t $q [lindex $subListVal $ix] q
          incr ix
        }        
        #-- replace any escaped &s
        set q [join [split $q \x03] &]
        
        if { !$history(newflag) } {
          if { ![cequal $sql $history($history(ptr))] } {
            set history(newflag) 1
          } else  {
            set xtra "$history($history(ptr).args)"
          }
        }
        eval VSQL_doQuery 0 \[set q\] \"\"
      } else {
        set history($history(maxptr).result) Aborted
        set history(result) Aborted
      }
    }
    }
  }
  }
  focus .sql.sqlText
  }
label .action.saveLab -text "     Current Save file:  "
label .action.saveFile -textvariable vsqlLastSaveFile

pack append .action \
  .action.exec { left frame center padx 10 pady 10 } \
  .action.saveLab { left frame center pady 10 } \
  .action.saveFile { left frame center pady 10 }

#-- A separator
frame .sep1 -relief {sunken} -bd {2} -width 20 -height 5

frame .sqlTitle
label .sqlTitle.labSQL -text {Current SQL Statement:  }
label .sqlTitle.labSQLno -textvariable history(ptr)
label .sqlTitle.labRes -text {     Result:  }
label .sqlTitle.labResult -textvariable history(result)
label .sqlTitle.labSQLmax -text {     Statements in Buffer:  }
label .sqlTitle.labSQLtotal -textvariable history(maxptr)

pack .sqlTitle.labSQL \
     .sqlTitle.labSQLno \
     .sqlTitle.labRes \
     .sqlTitle.labResult \
     .sqlTitle.labSQLmax \
     .sqlTitle.labSQLtotal -side left

#-- Build SQL text entry area
frame .sql
text  .sql.sqlText \
  -setgrid 1 \
  -wrap {word} \
  -relief {sunken} \
  -bd {2} \
  -height {10} \
  -yscrollcommand { .sql.yscroll set }
bind .sql.sqlText <Shift-Return> { .action.exec invoke }
bind .sql.sqlText <Shift-Meta-Return> { eval [.sql.sqlText get 0.0 end] }
bind .sql.sqlText <Meta-Up> { VSQL_getPrevQuery .sql.sqlText }
bind .sql.sqlText <Alt-Up> { VSQL_getPrevQuery .sql.sqlText }
bind .sql.sqlText <Meta-Down> { VSQL_getNextQuery .sql.sqlText }
bind .sql.sqlText <Alt-Down> { VSQL_getNextQuery .sql.sqlText }
bind .sql.sqlText <Shift-Delete> { .sql.sqlText delete 0.0 end }
scrollbar .sql.yscroll -width {12} \
  -command { .sql.sqlText yview }

pack append .sql \
  .sql.yscroll { right frame center filly } \
  .sql.sqlText { top frame center expand fill padx 10 pady 10 }

pack append . \
  .fm     { top frame center fillx } \
  .action { top frame center fillx } \
  .sep1   { top frame center fillx } \
  .sqlTitle { top frame center fillx } \
  .sql    { top frame center expand fill }

if { !$vsqlLoginDone } {
  if { ![VSQL_getLogin] } {
    catch { puts stdout "OSQL login terminated." }
    destroy .
    exit
  }
}

wm title . "OSQL to $env(TWO_TASK) as $vsqlCurrentUser"
if { [info exists inputFile] } {
  if { [catch {.sql.sqlText insert insert [exec cat $inputFile]} err] != 0} {
    timedMsg "Error reading input file.\nError: '$err'" INFINITE -grab {true}
  } else {
    .action.exec invoke
  }
}
focus .sql.sqlText

#- Add hyperhelp facility
hyperhelp_init "OSQL - ORACLE Query Tool" $vsqlHome/Help

#- Disable Save until we have set a file
.fm.mb0.m entryconfigure 2 -state disabled

#- Set autocommit on
oraautocom $dbHandle on
set autocom on
.fm.mb1a.m.a entryconfigure 1 -state disabled
.fm.mb1a.m entryconfigure 2 -state disabled
.fm.mb1a.m entryconfigure 3 -state disabled

#- Show SQL Trace as off
set sqlTrace off
.fm.mb1a.m.t entryconfigure 2 -state disabled

#- Disable Clear SQL Buffer
.fm.mb0.m entryconfigure 4 -state disabled

#- Set query visibility for results to 'hide'
set vsqlQvisibility hide

wm deiconify .

if { $vsqlMon } {
  if { [catch { send Vsqlmon Respond }] !=0 } {
    catch { puts stderr "Can't communicate with Conference Server." }
    set vsqlMon 0
  }
}
#<<>>  END OF OSQL
