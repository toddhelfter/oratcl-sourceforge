proc icon { name } {
  set icon_path {/home/schendr/tcl/library}
  foreach ipath $icon_path {
     if { [file readable "$ipath/$name"] } {
       return "@$ipath/$name"
     } else { return "" }
  }
}


# ----------------------------------------------------------------------
#  PURPOSE:  Root widget class all others inherit from
#
#   AUTHOR:  Dan R. Schenck (713) 954-6053
#            Texaco, Inc.  -  Email schendr@texaco.com
#
# ----------------------------------------------------------------------
#            Copyright (c) 1993  Texaco, Inc., All rights reserved.
# ======================================================================

# ----------------------------------------------------------------------
#  Widget class
# ----------------------------------------------------------------------
itcl_class Widget {

#---- Constructor ------------------------------------------------------

  constructor { config } {
  }

#---- Destructor -------------------------------------------------------

  destructor {
    ::rename $winName-win- {}
    catch {::destroy $winName}
  }

#---- Methods ----------------------------------------------------------

  method children { } {
    return $children
  }

  method config {config} { }

  method isshowing { } {
    return [winfo ismapped $winName]
  }

  method removeChild { child } {
    if { !$permission } { return }
    if { [set index [lsearch $children $child]] != -1 } {
      lvarpop children $index
    }
  }

  method windowname { } {
    return $winName
  }

  method withdraw { } {
    wm withdraw $winName
  }

  proc tORf { val } {
    if { "$val" == "true" | "$val" == "1" } { return 1 }
    if { "$val" == "false" | "$val" == "0" } { return 0 }
    return "error"
  }

#---- Protected variables ----------------------------------------------

  #  children
  #  the types of children the window contains, not the literal children
  #  names used by tk
  protected children {}

  #  permission
  #  toggles permission to execute certain methods
  protected permission {0}

  #  winExists
  #  1 = window has been created; 0 = window has not been created
  protected winExists {0}

  #  winName
  #  the message window name
  protected winName {}

}
