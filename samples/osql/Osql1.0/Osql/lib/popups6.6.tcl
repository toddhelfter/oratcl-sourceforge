proc warn { msg } {
  set w [genName .warn]
  toplevel $w
  frame $w.m
  pack append $w $w.m {top expand fill}

  label $w.m.l -text "Warning: $msg"
  button $w.m.b -command "destroy $w" -text "OK"

  pack append $w.m $w.m.l top $w.m.b top
}

proc timedMsg { msg { timeout 30000 } args } {
  set winx [expr [winfo rootx .]+20]
  set winy [expr [winfo rooty .]+20]
  set fnt {NULL}
  set wingrab {false}
  set buttonInd {true}
  if { [llength $args] > 0 } {
    if { [expr [llength $args]%2] > 0 } {
      puts stderr "timedMsg- Incorrect number of arguments."
      return
    }
    while { [llength $args] > 0 } {
      set a [lvarpop args 0]
      case $a in {
	-x { set winx [lvarpop args 0] }
	-y { set winy [lvarpop args 0] }
	-font { set fnt [lvarpop args 0] }
	-grab { set wingrab [lvarpop args 0] }
	-okbutton { set buttonInd [lvarpop args 0] }
	default {
	  puts stderr "timedMsg- Unknown parameter $a"
	  return
	}
      }
    }
  }
  set w [genName .infoMessage]
  toplevel $w
  wm geometry $w +$winx+$winy
  wm title $w "Message"
  wm withdraw $w

  frame $w.m

  set tmp [split $msg \n]
  set i 0
  foreach line $tmp {
    set i [max $i [clength $line]]
  }

  message $w.m.l -text "$msg" \
    -width [expr $i*9] \
    -relief {raised} \
    -justify {center}
  if { $fnt != {NULL} } { $w.m.l configure -font $fnt }
  if { $buttonInd == {true} } { button $w.m.b -command "destroy $w" -text "OK" }

  pack append $w.m $w.m.l top
  if { $buttonInd == {true} } { pack append $w.m $w.m.b { top pady 5 } }
  pack append $w $w.m {top expand fill}
  if { $timeout != "INFINITE" } { after $timeout "removeTimedMsg $w" }

  wm deiconify $w
  tkwait visibility $w
  if { $wingrab == {true} } { grab set $w }
  return $w

}

proc removeTimedMsg { win } {

  if { [lsearch [winfo children .] $win] > -1 } { destroy $win }

}

proc genName {{var var}} {
  global nameCount
  if [info exists nameCount($var)] {
    incr nameCount($var)
  } else {
    set nameCount($var) 0
  }
  return "$var$nameCount($var)"
}

proc frameMultChoice {frame msg choices default} {
  frame $frame
  subMultChoice $frame $msg $choices $default
}

proc multChoice {title msg choices default} {
  set w [genName .mult]
  toplevel $w
  wm title $w $title
  wm geometry $w +[expr [winfo rootx .]+20]+[expr [winfo rooty .]+20]
  subMultChoice $w $msg $choices $default
}

proc subMultChoice {w msg choices default} {
  set var [genName]
  frame $w.m -relief raised -border 1
  frame $w.b -relief raised -border 1
  set style {top fill expand}
  if {$msg != ""} {
    pack append $w $w.m $style
  }
  pack append $w $w.b $style
  label $w.m.l -text $msg
  pack append $w.m $w.m.l top
  foreach i $choices {
    set text [lindex $i 0]
    set command [lindex $i 1]
    set style1 {left expand padx 40 pady 20}
    if {$text == $default} {
      set style2 {expand padx 5 pady 5}
      set button default
    } {
      set style2 {expand}
      set button [genName button]
    }
    frame $w.b.$button -relief sunken -border 1
    pack append $w.b $w.b.$button $style1
    button $w.b.$button.b -text $text -command "destroy $w; $command"
    pack append $w.b.$button $w.b.$button.b $style2
    bind $w.b.$button <Enter> "$w.b.$button.b config -state active; update"
    bind $w.b.$button <Leave> "$w.b.$button.b config -state disabled; update"
    bind $w.b.$button <Return> "$w.b.$button.b invoke"
    bind $w.b.$button.b <Return> "$w.b.$button.b invoke"
  }
  bind $w.m <Enter>	"$w.b.default.b config -state active; update"
  bind $w.m.l <Enter>	"$w.b.default.b config -state active; update"
  bind $w.b <Enter>	"$w.b.default.b config -state active; update"
  bind $w.m <Leave>	"$w.b.default.b config -state disabled; update"
  bind $w.m.l <Leave>	"$w.b.default.b config -state disabled; update"
  bind $w.b <Leave>	"$w.b.default.b config -state disabled; update"
  bind $w.m <Return>	"$w.b.default.b invoke"
  bind $w.m.l <Return>	"$w.b.default.b invoke"
  bind $w.b <Return>	"$w.b.default.b invoke"
  eval [list proc $w.invoke_default {} [list $w.b.default.b invoke]]
  update idletasks
  grab set $w
  tkwait window $w
}

proc yesNo { title msg yesAction noAction default} {
  multChoice $title $msg [list "Yes [list $yesAction]" "No [list $noAction]"] $default
}

proc quit { prog { quitProc "destroy ." } } {
  #multChoice "Quit" "Are you sure you want to quit $prog?" {{Yes "destroy ."} {No ""}} No
  yesNo "Quit" "Are you sure you want to quit $prog?" "$quitProc" "noop" No
}

proc noop {} {
}  

proc toggle {var} {
  global $var
  if [info exists $var] {
    if [set $var] {
      set $var 0
    } else {
      set $var 1
    }
  } else {
    set $var 1
  }
}
