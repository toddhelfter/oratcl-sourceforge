# ----------------------------------------------------------------------
#  PURPOSE:  listbox with scrollbars and scrolling header via [incr Tcl].
#
#   AUTHOR:  Dan R. Schenck (713) 954-6053
#            Texaco, Inc.  -  Email schendr@texaco.com
#
# ----------------------------------------------------------------------
#            Copyright (c) 1993  Texaco, Inc., All rights reserved.
# ======================================================================

# ----------------------------------------------------------------------
#  ListBoxWithHeader class
# ----------------------------------------------------------------------
itcl_class ListBoxWithHeader {

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
    ::frame $this -class $class -bd $bd
    ::rename $this $this-win-
    ::rename $this-tmp- $this

    if { "$title" != "" } {
      lappend children title
    }
  
    ListBoxWithScroll $winName.header \
      -title "$title" \
      -width $width \
      -height 1 \
      -bd $bd

    ListBoxWithScroll $winName.list \
      -width $width \
      -height $height \
      -scrollx $scrollx \
      -scrolly $scrolly \
      -cursor $cursor \
      -selectmode $selectmode \
      -bd $bd

    set permission {1}

    packWidget

    set winExists {1}
    set permission {0}

  }

#---- Destructor -------------------------------------------------------

  destructor {
    $winName.header delete
    $winName.list delete
    ::rename $winName-win- {}
    ::destroy $winName
  }

#---- Methods ----------------------------------------------------------

  method append { contents } {
    $winName.list append "$contents"
  }

  method clear { } {
    $winName.list clear
  }

  method clearall { } {
    $this clear
    $this clearheader
  }

  method clearheader { } {
    $winName.header clear
  }

  method fill { contents } {
    $winName.list fill "$contents"
  }

  method fillheader { contents } {
    $winName.header fill "$contents"
  }

  method getcontents { } {
    return [$winName.list getcontents]
  }

  method packWidget { } {
    if { !$permission } { return }
    pack $winName.header \
      -side top \
      -fill x
    pack $winName.list \
      -side top \
      -expand 1 \
      -fill both

    if { $scrollx } {
      $winName.list config -scrollx $scrollx
      $winName.list objconfigure scrollx -command "$winName xview"
      $winName.list objconfigure list -xscrollcommand "$winName xscroll"
      $winName.header objconfigure list \
        -xscrollcommand "$winName.list scrollxset"
    }
  }

  method setfont { obj font } {
    $winName.list setfont $obj $font
    $winName.header setfont $obj $font
  }

  method xview { args } {
    eval $winName.header.list xview $args
    eval $winName.list.list xview $args
  }

  method xscroll { a1 a2 } {
    $winName.list scrollxset $a1 $a2
  }

#---- Public variables -------------------------------------------------

  #  bd
  #  widget border width
  public bd {0} {
    if { $winExists } {
      $winName config -bd $bd
    }
  }

  #  width
  #  width of listbox
  public width {35}
  
  #  height
  #  height of listbox
  public height {10}
  

  #  scrollx
  #  'true' or 1 if x scrollbar to be turned on
  #  'false' or 0 if x scrollbar not to be turned on
  public scrollx {0} {
    set tmp [tORf $scrollx]
    if { "$tmp" == "error" } {
      error "scrollx must be 'true', 1, 'false', or 0"
    } else {
      set scrollx $tmp
    }
    if { $winExists && $scrollx } {
      $winName.list config -scrollx $scrollx
      $winName.list objconfigure scrollx -command "$winName xview"
      $winName.list objconfigure list -xscrollcommand "$winName xscroll"
      $winName.header objconfigure list \
        -xscrollcommand "$winName.list scrollxset"
    }
  }

  #  scrolly
  #  'true' or 1 if y scrollbar to be turned on
  #  'false' or 0 if y scrollbar not to be turned on
  public scrolly {0} {
    set tmp [tORf $scrolly]
    if { "$tmp" == "error" } {
      error "scrolly must be 'true', 1, 'false', or 0"
    } else {
      set scrolly $tmp
    }
    if { $winExists } {
      $winName.list config -scrolly $scrolly
    }
  }

  #  title
  #  title of listbox
  public title {} {
    if {$winExists} {
      $winName.header.title config -text "$title"
    }
  }

  #  cursor
  #  cursor in listbox
  public cursor {} {
    if {$winExists} {
      $winName.list config -cursor "$cursor"
    }
  }


  #  selectmode
  #  selection mode - single, browse, multiple or extended
  public selectmode {} {
    if {$winExists} {
      $winName.list config -selectmode "$selectmode"
    }
  }

#---- Protected variables ----------------------------------------------

  #  permission
  #  toggles permission to use certain methods
  protected permission {0}

}