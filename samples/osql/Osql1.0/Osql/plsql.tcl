#------------------------------------------------------------------------------#
#                                                                              #
#  plsql.tcl:  subprogram for executing PL/SQL statements                      #
#                                                                              #
#------------------------------------------------------------------------------#


proc VSQL_saveText { w p f } {
  busy {
    update
    VSQL_makeFile {} {} [$w get 0.0 end] "$p/$f"
  }
  timedMsg "SQL Text Saved To File\n$p/$f" 6000
}
#<<>>


proc VSQL_loadText { w } {
  busy {
    if { [set infName [selectFile .fsWin1]] != "" && \
   	 [file exists "$infName"] } {
      VSQL_loadSQL "$infName" $w
    
      focus $w
   
      if { [cequal $w .sql.sqlText] } {
        VSQL_updateSQLsaveFile "$infName"
      } else {
        VSQL_updatePLSQLsaveFile "$infName" .[lindex [split $w .] 1]
      }
    }
  }
}
#<<>>


proc VSQL_saveTextAs { w } {
  busy {
    global ynDecision
    if { [set outfName [selectFile .fsWin1]] != "" } {
      if { [file exists "$outfName"] } {
        set ynDecision 1
        VSQL_yesNoDialog "File Already Exists" \
          "Overwrite File?\n'$outfName'" \
          "" \
          "global ynDecision; set ynDecision 0"
        if { !$ynDecision } {
          return
        }
      }
      VSQL_makeFile "" "" [$w get 0.0 end] "$outfName"
      if { [cequal $w .sql.sqlText] } {
        VSQL_updateSQLsaveFile "$outfName"
      } else {
        VSQL_updatePLSQLsaveFile "$outfName" .[lindex [split $w .] 1]
      }
    }
  }
}
#<<>>


proc VSQL_updatePLSQLsaveFile { f w } {
  global plsql
  set plsql(saveFile_$w) [file tail $f]
  set plsql(saveDir_$w) [file dirname $f]
  $w.fm.mb0.m entryconfigure 2 -state normal
}
#<<>>


proc VSQL_execPlCode { w } {
  global plsql oramsg
  set code [$w.f3.code get 0.0 end]
  set variables [$w.f1.variables get]
  set varTemp $variables
  set vnames ""
  set fmtResult ""
  while { [llength $varTemp] > 0 } {
    lappend vnames [lvarpop varTemp]
    lvarpop varTemp
  }
  set result [eval oraplexec [set plsql(cursor_$w)] \{$code\} $variables]
  foreach n $vnames {
    lappend fmtResult "$n = [lvarpop result]"
  }
  $w.f4.results fill $fmtResult
  if { [set rc $oramsg(rc)] != "" && [set msg $oramsg(errortxt)] != "" } {
    VSQL_msgList \
      [VSQL_unique plsqlerr] \
      "PL/SQL Error" \
      "ORACLE Error No. $rc" \
      [split $oramsg(errortxt) \n] \
      -bitmap error
  }
}
#<<>>


proc VSQL_plsqlFreeMem { w } {
  global plsql
  foreach n [array names plsql] {
    if { [string match *$w $n] } {
      unset plsql($n)
    }
  }
}
#<<>>


proc VSQL_plsqlClose { w } {
  global plsql
  if { [lsearch [array names plsql] cursor_$w] != -1 &&
       $plsql(cursor_$w) != "" } {
    oraclose $plsql(cursor_$w)
  }
  #-- Unset variables only after the window is gone because some are in use
  after 10 VSQL_plsqlFreeMem $w
  destroy $w
}
#<<>>


proc VSQL_execPLSQL { } {
  global dbHandle plsql
  set winBase [VSQL_unique plSQL]
  set w .${winBase}X
  set winNumber [lindex [split $winBase _] 1]
  set plsql(cursor_$w) [oraopen $dbHandle]
  set plsql(saveFile_$w) ""
  set plsql(saveDir_$w) ""
  toplevel $w
  wm withdraw $w

  #-- Build window
  wm title $w "PL/SQL Window #$winNumber"
  wm geometry $w 80x10
  wm iconname $w $w
  wm minsize $w 80 10
  wm positionfrom $w program
  wm sizefrom $w user
  wm protocol $w WM_DELETE_WINDOW "
    VSQL_plsqlClose $w
  "

  frame $w.fm -bd 2 -relief raised
  menubutton $w.fm.mb0 \
    -menu $w.fm.mb0.m \
    -text " File " \
    -underline 1

  menubutton $w.fm.mbh \
    -menu $w.fm.mbh.m \
    -text " Help " \
    -underline 1

  tk_menuBar $w.fm $w.fm.mb0 $w.fm.mbh
  menu $w.fm.mb0.m
  # Menu widget code

  $w.fm.mb0.m add command \
    -label " Load PL/SQL... " \
    -underline 1\
    -command " VSQL_loadText $w.f3.code "
  
  $w.fm.mb0.m add command \
    -label " Save " \
    -underline 1\
    -command " VSQL_saveText $w.f3.code \"\$plsql(saveDir_$w)\" \"\$plsql(saveFile_$w)\""
  
  $w.fm.mb0.m add command \
    -label " Save PL/SQL As... " \
    -underline 13 \
    -command "
      VSQL_saveTextAs $w.f3.code
    "

  $w.fm.mb0.m add separator
  
  $w.fm.mb0.m add command \
    -label " Close Window " \
    -underline 1 \
    -command "
      VSQL_plsqlClose $w
    "

  menu $w.fm.mbh.m

  $w.fm.mbh.m add command \
    -label " Osql... " \
    -underline 1 \
    -command { hyperhelp_file Osql.intro }

  $w.fm.mbh.m add command \
    -label " PL/SQL... " \
    -underline 1 \
    -command { hyperhelp_file Osql.plsql }

  pack $w.fm.mb0 -side left
  pack $w.fm.mbh -side right
  pack $w.fm -side top -fill x

  frame $w.fcmd
  button $w.fcmd.exec \
    -text " Execute PL/SQL " \
    -command "
      busy \{ VSQL_execPlCode $w \}
    "
  label $w.fcmd.labSav -text "     Current Save File:  "
  label $w.fcmd.labFile -textvariable plsql(saveFile_$w)

  pack $w.fcmd.exec -side left -padx 10 -pady 10
  pack $w.fcmd.labSav $w.fcmd.labFile -side left -pady 10
  pack $w.fcmd -side top -fill x

  #-- A separator
  frame $w.sep1 -relief {sunken} -bd {2} -width 20 -height 5

  pack $w.sep1 -fill x

  frame $w.f0
  label $w.f0.labVar -text " PL/SQL Variables "

  pack $w.f0.labVar -side left -fill x
  pack $w.f0 -side top -fill x

  frame $w.f1
  entry $w.f1.variables -bd 2 -relief sunken
  bind $w.f1.variables <Tab> " focus $w.f3.code "
  bind $w.f1.variables <Return> " focus $w.f3.code "
  bind $w.f1.variables <2> \
    " catch \{$w.f1.variables insert insert \[selection get\]\}
    "

  pack $w.f1.variables -side top -fill x
  pack $w.f1 -side top -fill x

  frame $w.f2
  label $w.f2.labCode -text " PL/SQL Code "

  pack $w.f2.labCode -side left -fill x
  pack $w.f2 -side top -fill x

  frame $w.f3 -bd 2
  text $w.f3.code \
  -setgrid 1 \
  -wrap {word} \
  -relief {sunken} \
  -bd {2} \
  -height {10} \
  -yscrollcommand " $w.f3.yscroll set "
  bind $w.f3.code <2> " VSQL_insertSelected $w.f3.code "
  bind $w.f3.code <Shift-Return> " $w.fcmd.exec invoke "
  bind $w.f3.code <Shift-Tab> " focus $w.f1.variables "
  bind $w.f3.code <Shift-Delete> " $w.f3.code delete 0.0 end "
  scrollbar $w.f3.yscroll \
    -width {12} \
    -command " $w.f3.code yview "

  pack $w.f3.yscroll -side right -fill y
  pack $w.f3.code -side top -expand 1 -fill both
  pack $w.f3 -side top -expand 1 -fill both

  frame $w.f4
  ListBoxWithScroll $w.f4.results \
    -scrollx 1 \
    -scrolly 1 \
    -title "PL/SQL Results" \
    -bd 2 \
    -width 80 -height 5

  pack $w.f4.results -side top -fill both -expand 1
  pack $w.f4 -side top -expand 1 -fill both

  $w.fm.mb0.m entryconfigure 2 -state disabled
    
  wm deiconify $w
}
#<<>>
