# ----------------------------------------------------------------------
#  EntryBox class
# ----------------------------------------------------------------------
itcl_class EntryBox {

  inherit Widget

#---- Constructor ------------------------------------------------------

  constructor { winTitle entryTitle config } {

    if { [crange $this 0 0] != "." } {
      error "Improperly formed window name '$this'."
    } else {
      set winName $this
    }

    set class [$this info class]
    ::rename $this $this-tmp-
    ::toplevel $winName -class $class
    ::rename $this $this-win-
    ::rename $this-tmp- $this

    global ${this}_done
    set ${this}_done 0

    set children "title entry"

    wm title $winName "$winTitle"
    wm minsize $winName 100 50
    wm withdraw $winName
    
    frame $winName.fe1 -relief {raised} -bd {1}
    label $winName.fe1.lab -text "$entryTitle" -anchor {e}
    entry $winName.fe1.string -width "$width" -relief {sunken} -bg {green}
    bind $winName.fe1.string <Return> "$winName.fe2.ok invoke"
    bind $winName.fe1.string <Control-u> "$winName.fe1.string delete 0 end"
    pack $winName.fe1.lab -side left -anchor w -padx 10 -pady 10
    pack $winName.fe1.string -side left -anchor w -padx 10 -pady 10 \
      -fill x -expand 1

    frame $winName.fe2 -relief {sunken} -bd {1}
    button $winName.fe2.ok -text { Ok } \
      -command "
        $this ok
      "
    button $winName.fe2.cancel -text { Cancel } \
      -command "
        $this cancel
      "
    pack $winName.fe2.ok -side left -padx 30 -pady 10
    pack $winName.fe2.cancel -side right -padx 30 -pady 10
  
    pack $winName.fe1 -side top -fill both -expand 1
    pack $winName.fe2 -side top -fill x
    $winName.fe1.string insert 0 "$default"
    $winName.fe1.string icursor 0

  }

#---- Destructor -------------------------------------------------------

  #inherited from Widget

#---- Methods ----------------------------------------------------------

  method display { } {
    wm geometry $winName +[expr [winfo rootx .]+20]+[expr [winfo rooty .]+20]
    wm deiconify $winName
    tkwait visibility $winName
    tk_entrySeeCaret $winName.fe1.string
    focus $winName.fe1.string
    if { $grab } { grab set $winName }
  }

  method setentry { value } {
    $winName.fe1.string delete 0 end
    $winName.fe1.string insert 0 "$value"
  }

  method getentry { } {
    return [$winName.fe1.string get]
  }

  method getreturn { } {
    return $rtrn
  }

  method getstatus { } {
    return $stat
  }

  method ok { } {
    global ${this}_done
    set stat 1
    set rtrn [$this getentry]
    set ${this}_done 1
  }

  method cancel { } {
    global ${this}_done
    set stat 0
    set rtrn ""
    set ${this}_done 1
  }

#---- Public variables -------------------------------------------------

  public default {}

  public width 20

  #  grab
  #  indicates whether window is grabbed or not when created
  #  form is 0 or 'false' for no grab and 1 or 'true' for grab
  public grab {0} {
    set tmp [tORf $grab]
    if { "$tmp" == "error" } {
      error "grab must be 'true', 1, 'false', or 0"
    } else {
      set grab $tmp
    }
  }

#---- Protected variables -------------------------------------------------

  protected done {0}

  protected stat {}

  protected rtrn {}
  
}


