# ----------------------------------------------------------------------
#  PURPOSE:  Popup dialog box via [incr Tcl].
#
#   AUTHOR:  Dan R. Schenck (713) 954-6053
#            Texaco, Inc.  -  Email schendr@texaco.com
#
# ----------------------------------------------------------------------
#            Copyright (c) 1993  Texaco, Inc., All rights reserved.
# ======================================================================

# ----------------------------------------------------------------------
#  Dialogbox class
# ----------------------------------------------------------------------
itcl_class DialogBox {

  inherit Widget

#---- Constructor ------------------------------------------------------

  constructor { config } {

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
  
    set children "message"

    set configLater [list DialogBox::message]

    foreach attr $config {
      if { [lsearch $configLater $attr] == -1 } {
        config -$attr [set $attr]
      } else {
        lappend laterConfig $attr
      }
    }

    if { $x == 0 } {
      set x [expr ([winfo screenwidth .]/2)-($width/2)]
    }
    if { $y == 0 } {
      set y [expr ([winfo screenheight .]/2)-($height/2)]
    }

    if { $width == 0 | $height == 0 } {
      wm geometry $winName +$x+$y
    } else {
      wm geometry $winName =${width}x${height}+$x+$y
    }
    wm title $winName "$title"
    wm protocol $winName WM_DELETE_WINDOW { }
    wm withdraw $winName
  
    frame $winName.f1
    frame $winName.f2
    frame $winName.sep -bd 1 -relief sunken
  
    if { $bitmap != "" } {
      lappend children "symbol"
      label $winName.f1.symbol \
        -bitmap "$bitmap" \
        -relief {raised} \
        -width 30
      pack $winName.f1.symbol \
        -side left \
        -fill both \
        -expand 0
    }
    message $winName.f1.message \
      -relief raised \
      -justify $justify
  
    pack $winName.f1.message \
      -side left \
      -fill both \
      -expand 1

    if { "${button-1}" != "" } {
      lappend children "button-1"
      button $winName.f2.button-1 -text "${button-1}"
      pack $winName.f2.button-1 \
        -side left \
        -padx 20 \
        -pady 5
    }
    if { "${button-2}" != "" } {
      lappend children "button-2"
      button $winName.f2.button-2 -text "${button-2}"
      pack $winName.f2.button-2 \
        -side right \
        -padx 20 \
        -pady 5
    }
    if { "${button-3}" != "" } {
      lappend children "button-3"
      button $winName.f2.button-3 -text "${button-3}"
      pack $winName.f2.button-3 \
        -side top \
        -padx 20 \
        -pady 5
    }
    pack $winName.f1 \
      -side top \
      -fill both \
      -expand 1
    pack $winName.sep $winName.f2 \
      -side top \
      -fill x

    set winExists {1}

    if { [info exists laterConfig] } {
      foreach attr $laterConfig {
        $this config -$attr [set $attr]
      }
    }

  }

#---- Destructor -------------------------------------------------------

  #inherited from Widget

#---- Methods ----------------------------------------------------------

  method bind { object key binding } {
    switch -regexp $object {
      message {
        eval "::bind $winName.f1.message $key \{ $binding \}"
      }
      button-[123] {
        if { [set $object] != "" } {
          eval "::bind $winName.f2.$object $key \{ [::bind Button $key] $binding \}"
        } else {
          error "Invalid widget object - $object"
        }
      }
      default {
        error "Invalid widget object - $object"
      }
    }
  }

  method command { object cmd } {
    switch -regexp $object {
      button-[123] {
        if { [set $object] != "" } {
          eval "$winName.f2.$object configure -command \{ $cmd \}"
        } else {
          error "Invalid widget object for this method - $object"
        }
      }
      default {
        error "Invalid widget object for this method - $object"
      }
    }
  }

  method display { } {
    wm deiconify $winName
    tkwait visibility $winName
    if { $grab } { grab set $winName }
    return $winName
  }

  method getmessage { } {
    return [lindex [$winName.f1.message configure -text] 4]
  }

  method objconfigure { object args } {
    switch -regexp $object {
      button-[123] {
        eval "$winName.f2.$object configure $args"
      }
      message {
        eval "$winName.f1.message configure $args"
      }
      default {
        error "Invalid widget object for this method - $object"
      }
    }
  }

  method invoke { object } {
    switch -regexp $object {
      button-[123] {
        if { [set $object] != "" } {
          $winName.f2.$object invoke
        } else {
          error "Invalid widget object for this method - $object"
        }
      }
      default {
        error "Invalid widget object for this method - $object"
      }
    }
  }

  method setfont { object font } {
    switch -regexp $object {
      All {
        $winName.f1.message configure -font $font
        $winName.f2.button-1 configure -font $font
        $winName.f2.button-2 configure -font $font
        $winName.f2.button-3 configure -font $font
      }
      message {
        $winName.f1.message configure -font $font
      }
      button-[123] {
        $winName.f2.$object configure -font $font
      }
      button-all {
        $winName.f2.button-1 configure -font $font
        $winName.f2.button-2 configure -font $font
        $winName.f2.button-3 configure -font $font
      }
      default {
        error "Invalid widget object for this method - $object"
      }
    }
  }

#---- Public variables -------------------------------------------------

  #  button-1
  #  If non-null, creates left button with button-1 value as title
  public button-1 {}
  
  #  button-2
  #  If non-null, creates right button with button-1 value as title
  public button-2 {}
  
  #  button-3
  #  If non-null, creates center button with button-1 value as title
  public button-3 {}

  #  geometry
  #  width and height of window in pixels; form - wxh
  public geometry {0x0} {
    set width [lindex [split $geometry x] 0]
    set height [lindex [split $geometry x] 1]
  }

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

  #  justify
  #  indicates justify mode for message text
  public justify {center}

  #  message
  #  sets the message text for the widget
  public message {} {
    if { $winExists } {
      set i 0
      foreach line [split $message \n] {
        set i [max $i [clength $line]]
      }

      set wide [expr ($i*9)+18]
      $winName.f1.message configure \
        -width $wide \
        -text "$message"
      raise $winName
      update
    }
  }

  #  bitmap
  #  name of bitmap to be shown
  public bitmap {}
  
  #  title
  #  the message window title
  public title {}

  #  x
  #  the x location in pixels for the upper left corner of the window
  public x {0}

  #  y
  #  the x location in pixels for the upper left corner of the window
  public y {0}
  
#---- Protected variables ----------------------------------------------

  #  width
  #  the width of the message window
  protected width {0}

  #  height
  #  the height of the message window
  protected height {0}

}