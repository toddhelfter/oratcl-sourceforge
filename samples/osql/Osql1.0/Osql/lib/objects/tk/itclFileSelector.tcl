# ----------------------------------------------------------------------
#  PURPOSE:  file selector via [incr Tcl].
#
#   AUTHOR:  Dan R. Schenck (713) 954-6053
#            Texaco, Inc.  -  Email schendr@texaco.com
#
# ----------------------------------------------------------------------
#            Copyright (c) 1993  Texaco, Inc., All rights reserved.
# ======================================================================

# ----------------------------------------------------------------------
# NOTES:
#   This [incr tcl] object requires the Widget and ListBoxWithScroll
#   widgets.
#
#   Also, the busy procedure found in ~schendr/tcl/library/busy.tcl
#   is required to be sourced by the instantiating program.
#
#   To use the file selector widget, create it, then request the object
#   to display itself (see example below).
#
#   After the user selects a file, the file selector widget is unmapped.
#   To destroy the widget, use the delete method (i.e. .fsWin delete).
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# EXAMPLE:
#   proc selectFile { w } {
#     if { [itcl_info objects $w] != "$w" } {
#       FileSelector $w -title "OSQL File Selector"
#     }
#     return [$w display]
#   }
#   puts stdout "Selected file = '[selectFile .fsWin1]'"
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
#  FileSelector class
# ----------------------------------------------------------------------
itcl_class FileSelector {

  inherit Widget

#---- Constructor ------------------------------------------------------

  constructor { config } {

    global env FSEL$this

    if { [crange $this 0 0] != "." } {
      error "Improperly formed window name '$this'."
    } else {
      set winName $this
    }

    set class [$this info class]
    ::rename $this $this-tmp-
    ::toplevel $this -class $class
    ::rename $this $this-win-
    ::rename $this-tmp- $this
    ::wm withdraw $this
  
    if { "$title" != "" } {
      wm title $winName "$title"
    }
    wm minsize $winName 100 50
    wm geometry $winName $geometry
    #-- Treat window close as a cancel
    wm protocol $winName WM_DELETE_WINDOW "
      $winName.f3.cancel invoke
    "

    frame $winName.f0 -bd 2 -relief {sunken}
    frame $winName.f1 -bd 2
    frame $winName.f1a -bd 2 
    frame $winName.f2 -bd 2 -relief {sunken}
    frame $winName.f3 -bd 2 -relief {raised}
  
    #--------------------------------------------------------------------------#
    #  Output file name widget
    label $winName.f2.lab1 -text "Selected File" \
      -anchor {e} 
    entry $winName.f2.outfile
    bind $winName.f2.outfile <Return> " $winName.f3.ok invoke "
    $winName.f2.outfile configure \
      -relief sunken -bd 3 \
      -width {35}
    pack $winName.f2.lab1 \
      -side left -padx 10 -pady 10
    pack $winName.f2.outfile \
      -side left -padx 10 -pady 10 -fill x -expand 1
  
    #--------------------------------------------------------------------------#
    #  Filter text widget
    label $winName.f0.lab1 -text "Filter" \
      -anchor {e}
    entry $winName.f0.filter
    bind $winName.f0.filter <Return> "
      $this getNewDir \[$winName.f0.filter get]
    "
    $winName.f0.filter configure \
      -relief sunken -bd 3 \
      -width {42}
    pack $winName.f0.lab1 \
      -side left -padx 10 -pady 10
    pack $winName.f0.filter \
      -side left -padx 10 -pady 10 -fill x -expand 1
        
    #---------------------------------------------------------------------------
    #  Show Dot Files Check Box
  
    checkbutton $winName.f1.dotFiles -variable FSEL${this}(showDotFiles) \
      -text { Show Dot Files? } \
      -relief flat \
      -command " $this displayFiles "
    set FSEL${this}(showDotFiles) 0
    label $winName.f1.host \
      -text "User: $env(USER)  Host: [lindex [split [exec hostname] .] 0]"
    pack $winName.f1.dotFiles -side left -padx 20
    pack $winName.f1.host -side right -padx 20
  
    #--------------------------------------------------------------------------#
    #  Directory list
  
    ListBoxWithScroll $winName.f1a.dl \
      -width 15 \
      -height $filesDisplayed \
      -scrollx true \
      -scrolly true \
      -title "Directories:"
    $winName.f1a.dl bind list <Button-1> "
      $winName.f1a.dl resetfind
    "
    $winName.f1a.dl bind list <Any-Key> " $this doFindDL %K "

    $winName.f1a.dl bind list <Double-Button-1> "
      $this getNewDir
    "
    pack $winName.f1a.dl -side left -fill both -expand 1
  
    #--------------------------------------------------------------------------#
    #  File list
  
    ListBoxWithScroll $winName.f1a.fl \
      -width 15 \
      -height $filesDisplayed \
      -scrollx true \
      -scrolly true \
      -title "Files:"
    $winName.f1a.fl bind list <Button-1> "
      $winName.f1a.fl resetfind
    "
    $winName.f1a.fl bind list <Any-Key> " $this doFindFL %K "

    $winName.f1a.fl bind list <Double-Button-1> "
      $this handleFile
    "
  
    pack $winName.f1a.fl -side left -fill both -expand 1
  
    button $winName.f3.ok -text {  Ok  } -cursor {hand2} \
      -command " $this rtrnFile \[$winName.f2.outfile get]"
    button $winName.f3.cancel -text {  Cancel  } -cursor {hand2} \
      -command " $this rtrnFile \"\" "
    pack $winName.f3.ok -side left -padx 40 -pady 10
    pack $winName.f3.cancel -side right -padx 40 -pady 10
    
    pack $winName.f0 -side top -fill x -padx 10 -pady 10 -expand 1
    pack $winName.f1 -side top -fill both -padx 10 -expand 1
    pack $winName.f1a -side top -fill both -padx 10 -pady 10 -expand 1
    pack $winName.f2 -side top -fill x -padx 10 -pady 10 -expand 1
    pack $winName.f3 -side top -fill x

    set winExists 1
}

#---- Destructor -------------------------------------------------------

  destructor {
    global FSEL$this
    unset FSEL$this
  }
#---- Methods ----------------------------------------------------------

  method rtrnFile { f } {
    if { !$permission } { return }
    global FSEL$this
    set FSEL${this}(file) $f
  }

  method display { } {
    set permission 1
    global FSEL$this
    $winName.f0.filter delete 0 end
    $winName.f0.filter insert 0 [$this getPwd]/$filter
    $this getNewDir
    wm deiconify $winName
    grab $winName
    tkwait variable FSEL${this}(file)
    grab release $winName
    wm withdraw $winName
    set permission 0
    update
    return [set FSEL${this}(file)]
  }

  method doFindDL { k } {
    if { !$permission } { return }
    if { [clength $k] == 1 } {
      $winName.f1a.dl finditem $k
    } else {
        switch -exact $k {
      
        Delete
          -
          
        BackSpace
          { $winName.f1a.dl setcurselection 0 }

        Up
          { if { [set cs [$winName.f1a.dl getcursel]] > 0 } {
              $winName.f1a.dl setcurselection [expr $cs-1]
            }
          }

        Down
          { if { [set cs [$winName.f1a.dl getcursel]] < [$winName.f1a.dl size]
            && $cs >= 0 } {
              $winName.f1a.dl setcurselection [expr $cs+1]
            }
          }

        Right
          { $this setFocus $winName.f1a.fl }

        Return
          { $this getNewDir }

        minus
          { $winName.f1a.dl finditem - }

        period
          { $winName.f1a.dl finditem . }

        underscore
          { $winName.f1a.dl finditem _ }

        default
          {}
      }
    }
  
  }
  
  method doFindFL { k } {
    if { !$permission } { return }
    if { [clength $k] == 1 } {
      $winName.f1a.fl finditem $k
    } else {
      switch -exact $k {
      
        Delete
          -
          
        BackSpace
          { $winName.f1a.fl setcurselection 0 }

        Up
          { if { [set cs [$winName.f1a.fl getcursel]] > 0 } {
              $winName.f1a.fl setcurselection [expr $cs-1]
            }
          }

        Down
          { if { [set cs [$winName.f1a.fl getcursel]] < [$winName.f1a.fl size]
            && $cs >= 0 } {
              $winName.f1a.fl setcurselection [expr $cs+1]
            }
          }

        Left
          { $this setFocus $winName.f1a.dl }

        Return
          { $this handleFile }

        minus
          { $winName.f1a.fl finditem - }

        period
          { $winName.f1a.fl finditem . }

        underscore
          { $winName.f1a.fl finditem _ }

        default
          {}
      }
    }
  }
  
  method getPwd { } {
    if { !$permission } { return }
    if { [lindex [set p [split [pwd] /]] 1] == "tmp_mnt" } {
      lvarpop p 1
    }
    return [join $p /]
  }
  
  
  method displayFiles { } {

    global FSEL$this
    if { !$permission } { return }
    ::busy {
    if { [set FSEL${this}(showDotFiles)] } {
      set dirs ""
      set files [glob -nocomplain * .*]
    } else {
      set dirs ". .."
      set files [glob -nocomplain *]
    }
    set cnt 0
    foreach f $files {
      if { [file isdirectory "$f"] } {
        lappend dirs [lvarpop files $cnt]
        incr cnt -1
      }
      incr cnt
    }
    set cnt 0
    if { ![cequal $filter *] } {
      foreach f $files {
        if { ![string match $filter $f] } {
          lvarpop files $cnt
          incr cnt -1
        }
        incr cnt
      }
    }
  
    $winName.f1a.dl clear
    $winName.f1a.fl clear
    set numDirs [llength $dirs]
    set numFiles [llength $files]
    foreach d [lsort $dirs] {
      $winName.f1a.dl append \{$d\}
    }
    foreach f [lsort $files] {
      $winName.f1a.fl append \{$f\}
    }
    $winName.f1a.dl config -title "Directories:  $numDirs"
    $winName.f1a.fl config -title "Files:  $numFiles"
    }
    $this setFocus $winName.f1a.dl
    update
  }
  
  method handleFile { } {
    if { !$permission } { return }
    $winName.f2.outfile delete 0 end
    $winName.f2.outfile insert 0 \
      "[$this getPwd]/[$winName.f1a.fl getsel]"
    focus $winName.f2.outfile
  }
  
  
  method getNewDir { {newdir ""} } {
    if { !$permission } { return }
    if { $newdir == "" } {
      set newdir [$winName.f1a.dl getsel]
      if { [cequal $newdir ""] } { set newdir [pwd] }
    } elseif { $newdir != ".." && $newdir != "." } {
      set tmp1 [file dirname $newdir]
      set tmp2 [file tail $newdir]
      if { [string first {*} $tmp2] != -1 ||
           [string first {[} $tmp2] != -1 ||
          ![file isdirectory $tmp2] } {
        set filter $tmp2
        set newdir $tmp1
      } else {
        set filter {*}
      }
      if { ![file isdirectory $newdir] } { return }
    }
    catch { cd $newdir }
    $this displayFiles
    $winName.f0.filter delete 0 end
    $winName.f0.filter insert 0 [$this getPwd]/$filter
  }
  
  
  method setFocus { w } {
    if { !$permission } { return }
    $w setcurselection 0
    focus $w.list
  }

#---- Public variables -------------------------------------------------

  #  filter
  #  The file filter
  public filter {*}

  #  title
  #  The window title
  public title {File Selector} {
    if { $winExists } {
      wm title $winName "$title"
    }
  }

  #  geometry
  #  The location of the window
  public geometry "+[expr [winfo rootx .]+40]+[expr [winfo rooty .]+40]"

  #  filesDisplayed
  #  number of files to be displayed in listboxes
  public filesDisplayed {5} {
    if { $winExists } {
      $winName.f1a.dl config -width 15 -height $filesDisplayed
      $winName.f1a.fl config -width 15 -height $filesDisplayed
    }
  }
#---- Protected variables ----------------------------------------------

}
