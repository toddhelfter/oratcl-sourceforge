proc seeEntryText { w width } {

  if { [expr $width+4] < [$w index end] } {
    $w icursor [expr [$w index end]-$width]
  } else {
    $w icursor 0
  }
}


proc getEntryData { var } {
  global $var
  if { [set thisEntry [.getData.fe1.string get]] != "" } {
      set $var $thisEntry
      return 1
  }
  return 0
}


proc getEntryPopup { x y winTitle entryTitle defString rtrn { entryWidth 20 } } {

  global $rtrn weAreDone
  set w .getData
  if { [winfo exists $w] } {
    tkwait window $w
  }
  set weAreDone {}
  toplevel $w
  wm geometry $w +$x+$y
  wm title $w "$winTitle"
  wm minsize $w 100 50
  wm withdraw $w

  frame $w.fe1 -relief {raised} -bd {1}
  label $w.fe1.lab -text "$entryTitle" -anchor {e}
  entry $w.fe1.string -width "$entryWidth" -relief {sunken} -bg {green}
  bind $w.fe1.string <Return> " $w.fe2.ok invoke "
  pack append $w.fe1 $w.fe1.lab { left frame w padx 10 pady 10 } \
  		    $w.fe1.string { left frame w padx 10 pady 10 }

  frame $w.fe2 -relief {sunken} -bd {1}
  button $w.fe2.ok -text { Ok } \
    -command "
      global weAreDone
      set weAreDone \[getEntryData $rtrn]
    "
  button $w.fe2.cancel -text { Cancel } \
    -command {
      global weAreDone
      set weAreDone 0
    }
  pack append $w.fe2 $w.fe2.ok { left padx 30 pady 10 frame center } \
		    $w.fe2.cancel { right padx 30 pady 10 frame center }

  pack append $w $w.fe1 { top frame center } \
		 $w.fe2 { top frame center fillx }

  $w.fe1.string insert 0 "$defString"
  wm deiconify $w
  tkwait visibility $w
  grab set $w
  seeEntryText $w.fe1.string $entryWidth
  focus $w.fe1.string
  tkwait variable weAreDone
  after 5 " grab release $w; destroy .getData "
  return $weAreDone
}
