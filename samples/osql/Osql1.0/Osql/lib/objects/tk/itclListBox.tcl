# ----------------------------------------------------------------------
#  PURPOSE:  listbox with scrollbars via [incr Tcl].
#
#   AUTHOR:  Dan R. Schenck (713) 954-6053
#            Texaco, Inc.  -  Email schendr@texaco.com
#
# ----------------------------------------------------------------------
#            Copyright (c) 1993  Texaco, Inc., All rights reserved.
# ======================================================================

# ----------------------------------------------------------------------
#  ListBoxWithScroll class
# ----------------------------------------------------------------------
itcl_class ListBoxWithScroll {

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
      label $winName.title -text "$title" -anchor {e}
    }

    set permission {1}
    
    if { $scrollx } { addScrollx }

    if { $scrolly } { addScrolly }
  
    listbox $winName.list \
      -cursor $cursor \
      -width $width \
      -height $height \
      -relief {sunken} \
      -selectmode $selectmode \
      -exportselection {true}
    lappend children "list"

    packWidget
    
    set winExists {1}
    set permission {0}
  }

#---- Destructor -------------------------------------------------------

  #inherited from Widget
  
#---- Methods ----------------------------------------------------------

  method append { items } {
    foreach i $items {
      $winName.list insert end "$i"
    }
  }

  method bind { object key binding } {
    if { "$object" == "all" } {
      foreach c children {
       eval "::bind $winName.$c $key \{ [::bind [winfo class $winName.$c] $key] $binding \}"
      }
    } elseif { [lsearch $children $object] != -1 } {
      eval "::bind $winName.$object $key \{ [::bind [winfo class $winName.$object] $key] $binding \}"
    } else {
      error "Invalid widget object for this method - $object"
    }
  }

  method clear { } {
    catch {$winName.list delete 0 end}
    return {}
  }

  method edititem { index newVal } {
    $winName.list delete $index
    $winName.list insert $index "$newVal"
  }
  
  method getcontents { } {
    set contents {}
    loop i 0 [$winName.list size] {
      lappend contents [$winName.list get $i]
    }
    return $contents
  }

  method getitem { index } {
    set item {}
    catch { set item [$winName.list get $index] }
    return "$item"
  }

  method getcursel { } {
    return [$winName.list curselection]
  }

  method getsel { } {
    set item {}
    foreach s [$winName.list curselection] {
      lappend item [$winName.list get $s]
    }
    return "$item"
  }

  method fill { items } {
    $this clear
    $this append "$items"
  }

  method finditem { letter } {
    if { $rowPointer >= [expr [$this size]+1] } {
      set $rowPointer 0
      set lastLetters ""
    }
    ::append lastLetters "$letter"
    loop i $rowPointer [expr [$this size]+1] {
      if { [cequal [csubstr [$this getitem $i] 0 $letterPointer] $lastLetters] } {
        if { $rowPointer < $i } {
          if { ![cequal [set lItem [$winName.list curselection]] ""] } {
            $winName.list selection clear $lItem
          }
          $winName.list selection set $i
          $winName.list activate $i
          $winName.list yview $i
          set rowPointer $i
        }
        incr letterPointer
        break
      }
    }
  }

  method resetfind { } {
    set letterPointer 1
    set rowPointer 0
    set lastLetters {}
  }
  
  method objconfigure { object args } {
    if { "$object" == "all" } {
      foreach c $children {
        catch { eval [concat $winName.$c configure $args] }
      }
    } elseif { [lsearch $children $object] != -1 } {
      eval [concat $winName.$object configure $args]
    } else {
      error "Invalid widget object for this method - $object"
    }
  }

  method scrollxset { a1 a2 } {
    if { $scrollx } {
      $winName.scrollx set $a1 $a2
    }
  }

  method scrollxget { } {
    if { $scrollx } {
      return [$winName.scrollx get]
    }
  }

  method scrollyset { a1 a2 a3 a4 } {
    if { $scrolly } {
      $winName.scrolly set $a1 $a2 $a3 $a4
    }
  }

  method scrollyget { } {
    if { $scrolly } {
      return [$winName.scrolly get]
    }
  }

  method setfont { object font } {
    case $object in {
      {title list} {
        $winName.$object config -font "$font"
      }
      all {
        if { [lsearch $children title] != "" } {
          $winName.title config -font "$font"
        }
        $winName.list config -font "$font"
      }
      default {
        error "Invalid widget object for this method - $object"
      }
    }
  }

  method size { } { return [$winName.list size] }

  method xview { args } {
    eval $winName.list xview $args
  }

  method setcurselection { index } {
    $this resetfind
    if { ![cequal [set lItem [$winName.list curselection]] ""] } {
      $winName.list selection clear $lItem
    }
    $winName.list selection set $index
    $winName.list yview $index
  }

  method addScrollx { } {
    if { !$permission } { return }
    if { [lsearch [winfo children $winName] $winName.scrollx] != -1 } {
      destroy $winName.scrollx
    }
    scrollbar $winName.scrollx \
      -command "$winName.list xview" \
      -relief {sunken} \
      -width {12} \
      -orient {horizontal}
    lappend children scrollx
    set scrollxExists {1}
  }
  
  method addScrolly { } {
    if { !$permission } { return }
    if { [lsearch [winfo children $winName] $winName.scrolly] != -1 } {
      destroy $winName.scrolly
    }
    scrollbar $winName.scrolly \
      -command "$this resetfind; $winName.list yview" \
      -relief {sunken} \
      -width {12} \
      -orient {vertical}
    lappend children scrolly
    set scrollyExists {1}
  }

  method packWidget { } {
    if { !$permission } { return }
    if { [lsearch $children "title"] != -1 } {
      pack $winName.title \
        -side top \
        -anchor w
    }
    if { $scrolly } {
      $winName.list configure -yscrollcommand "$winName.scrolly set"
      pack $winName.scrolly \
        -side right \
        -fill y
    }
    pack $winName.list \
      -side top \
      -expand 1 \
      -fill both
    if { $scrollx } {
      $winName.list configure -xscrollcommand "$winName.scrollx set"
      pack $winName.scrollx \
        -side bottom \
        -fill x
    }
  }

  method unpackWidget { } {
    if { !$permission } { return }
    if { [lsearch [winfo children $winName] $winName.scrollx] != -1 } {
      pack forget $winName.scrollx
    }
    if { [lsearch [winfo children $winName] $winName.scrolly] != -1 } {
      pack forget $winName.scrolly
    }
    if { [lsearch [winfo children $winName] $winName.title] != -1 } {
      pack forget $winName.title
    }
    pack forget $winName.list
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
    set permission {1}
    if { $scrollxExists && !$scrollx } {
      unpackWidget
      removeChild scrollx
      set scrollxExists {0}
      packWidget
    } elseif { !$scrollxExists && $winExists && $scrollx } {
      unpackWidget
      addScrollx
      packWidget
    }
    set permission {0}
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
    set permission {1}
    if { $scrollyExists && !$scrolly } {
      unpackWidget
      removeChild scrolly
      set scrollyExists {0}
      packWidget
    } elseif { !$scrollyExists && $winExists && $scrolly } {
      unpackWidget
      addScrolly
      packWidget
    }
    set permission {0}
  }

  #  title
  #  title of listbox
  public title {} {
    if {$winExists} {
      $winName.title config -text "$title"
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

  #  scrollxExists
  #  indicates whether scrollx exists or not
  protected scrollxExists {0}
  
  #  scrollyExists
  #  indicates whether scrolly exists or not
  protected scrollyExists {0}

  #  lastLetters
  #  last group of letters searched for
  protected lastLetters {}

  #  letterPointer
  #  number of letters to search from beginning of listbox item
  protected letterPointer {1}

  #  rowPointer
  #  points to the last row found
  protected rowPointer {0}
  
}