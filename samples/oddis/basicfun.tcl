####################################
# Procedure: OD_ChangeFontsize     #
####################################


proc OD_ChangeFontsize {} {
global ODv_font

set ow_list {}
set winlist [winfo children .]

foreach elem $winlist { 
  if [string match .ow_* $elem] {
     lappend ow_list $elem
  }
}

foreach elem $ow_list {
  $elem.fr_list.lb_list configure -font $ODv_font
  $elem.fr_list.lb_head configure -font $ODv_font
}

update idletask
}


#####################################
# Procedure: OD_ClearAll            #
#####################################


proc OD_ClearAll {} {
OD_ClearResult
OD_ClearMain
}


#####################################
# Procedure: OD_ClearMain           #
#####################################


proc OD_ClearMain {} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename

set ODv_cmdIdx $ODv_cmdLast
set ODv_filename ""

.tl_main.fr_statement.tx_statement delete 0.0 end
OD_Msg ""
focus .tl_main.fr_statement.tx_statement
}


#####################################
# Procedure: OD_ClearResult         #
#####################################


proc OD_ClearResult {} {
.tl_result.fr_result.lb_result delete 0 end
OD_Msg ""
focus .tl_main.fr_statement.tx_statement
}


###################################
# Procedure: OD_Display           #
###################################


proc OD_Display {} {

global ODv_select
global ODv_next
global ODv_others
global ODv_colour_select
global ODv_colour_next
global ODv_colour_others
global ODv_mono_select
global ODv_mono_next
global ODv_mono_others
global ODv_display

if {$ODv_display == "colour"} {
  set ODv_select $ODv_colour_select
  set ODv_next   $ODv_colour_next
  set ODv_others $ODv_colour_others
} else {
  set ODv_select $ODv_mono_select
  set ODv_next   $ODv_mono_next
  set ODv_others $ODv_mono_others
}
}


###################################
# Procedure: OD_GenWin            #
###################################


proc OD_GenWin { wname wtitle whead whmin wvmin wgeom oralist brow {btext ""} {bcommand ""} {buser ""} {bobj ""}} {
global ODv_font

#remove old window if exist
catch {destroy $wname}
 
set Okcmd  [string length [info commands $bcommand]]
set Okuser [string length $buser]
set Okobj  [string length $bobj]

toplevel $wname
wm title    $wname $wtitle
wm sizefrom $wname user
wm minsize  $wname $whmin $wvmin
wm geometry $wname $wgeom


frame $wname.fr_list
frame $wname.fr_cmd -relief raised -borderwidth 2

scrollbar $wname.fr_list.sb_vlist  -command "$wname.fr_list.lb_list yview" -orient vertical -relief raised
scrollbar $wname.fr_list.sb_hlist  -command "OD_HScrollCmd $wname" -orient horizontal -relief raised
listbox   $wname.fr_list.lb_head   -xscroll "$wname.fr_list.sb_hlist set" -font $ODv_font -width 1 -height 1
listbox   $wname.fr_list.lb_list   -yscroll "$wname.fr_list.sb_vlist set" -xscroll "$wname.fr_list.sb_hlist set" -relief raised -font $ODv_font

foreach elem $oralist {
    $wname.fr_list.lb_list insert end $elem
}

$wname.fr_list.lb_head insert end $whead


if $Okcmd {
  bind $wname.fr_list.lb_list <Double-1> "$wname.fr_cmd.bn_ok invoke"
  if $Okobj {
      button $wname.fr_cmd.bn_ok  -text $btext  -borderwidth 2  -relief raised -command "catch \{$bcommand $buser $bobj \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "
  } elseif $Okuser {
      button $wname.fr_cmd.bn_ok  -text $btext  -borderwidth 2  -relief raised  -command "catch \{$bcommand $buser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "
  } else {
      button $wname.fr_cmd.bn_ok  -text $btext  -borderwidth 2  -relief raised  -command "catch \{$bcommand \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "
  }
}



if {$brow} {
  button $wname.fr_cmd.bn_row -text "View Row" -borderwidth 2 -relief raised -command "catch \{OD_GenWinRow \[list $whead\] \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"
} 
button $wname.fr_cmd.bn_cancel -text "Dismiss" -command "destroy $wname" -borderwidth 2 -relief raised


pack $wname.fr_list -side top -fill both -expand 1
pack $wname.fr_cmd  -side bottom -fill x
pack $wname.fr_list.sb_vlist -side left -fill both
pack $wname.fr_list.sb_hlist -side bottom -fill x
pack $wname.fr_list.lb_head -side top -fill x  -expand 0
pack $wname.fr_list.lb_list -side right -fill both -expand 1 


if $Okcmd {
  pack $wname.fr_cmd.bn_ok -side left -fill x -expand 1
}
if {$brow} {
  pack $wname.fr_cmd.bn_row -side left -fill x -expand 1
} 

pack $wname.fr_cmd.bn_cancel -side left -fill x -expand 1


}


##################################
# Procedure: OD_GenWinRow        #
##################################


proc OD_GenWinRow { title args} {
set ctitle  [llength $title]
set xheight [expr $ctitle * 22 + 20]
set liinfo  [string trim $args \{\}]

catch {destroy .tl_onerow}
toplevel .tl_onerow

wm title     .tl_onerow "ODDIS-One Row View"
wm sizefrom  .tl_onerow user


set nr 0
set xr [expr $ctitle+1]

while {$ctitle > $nr} {
   frame .tl_onerow.f$nr
   label .tl_onerow.f${nr}.l$nr -width 25 -text [lindex $title $nr] -anchor w  -relief sunken
   set xr [expr $xr + $nr] 
   label .tl_onerow.f${nr}.l$xr -width 40 -text [lindex $liinfo $nr] -anchor w -relief sunken
   incr nr
}


set nr 0
set xr [expr $ctitle + 1]

while {$ctitle > $nr} {
   pack .tl_onerow.f$nr -fill x  
   pack .tl_onerow.f${nr}.l$nr -side left  
   set xr [expr $xr + $nr]
   pack .tl_onerow.f${nr}.l$xr -side left 
   incr nr
}

button .tl_onerow.b -text Dismiss -command {destroy .tl_onerow}
pack   .tl_onerow.b -side bottom -fill x
}


###################################
# Procedure: OD_HScrollCmd        #
###################################


proc OD_HScrollCmd { wname args} {
if {[lindex $args 0] == "moveto"} {
$wname.fr_list.lb_head xview moveto [lindex $args 1] 
$wname.fr_list.lb_list xview moveto [lindex $args 1]
} else {
$wname.fr_list.lb_head xview scroll [lindex $args 1] units
$wname.fr_list.lb_list xview scroll [lindex $args 1] units }
}


####################################
# Procedure: OD_Help_InfoBox       #
####################################

# B/S, Regine Kasten
# Creates an infobox for the selected object.
proc OD_Help_InfoBox {title winfo {wname .tl_infobox} {wminx 200} {wminy 100}} {

#remove old window if exist
catch {destroy $wname}

toplevel    $wname
wm title    $wname "ODDIS-Help for $title"
wm minsize  $wname $wminx $wminy
wm maxsize  $wname 900 700
wm sizefrom $wname user
wm geometry $wname 400x300

frame $wname.fr_info
frame $wname.fr_cmd  -relief raised -borderwidth 2

scrollbar $wname.fr_info.sb_info -orient vertical -command "$wname.fr_info.tx_info yview"
text   $wname.fr_info.tx_info  -relief raised  -width 80 -height 1 -wrap word  -yscrollcommand "$wname.fr_info.sb_info set"
button $wname.fr_cmd.bn_ok     -text "Dismiss"  -command "destroy $wname"  -borderwidth 2  -relief raised

pack $wname.fr_info -side top -fill both -expand 1
pack $wname.fr_cmd  -side bottom -fill x

pack $wname.fr_cmd.bn_ok    -side bottom -fill x
pack $wname.fr_info.sb_info -side left  -fill y
pack $wname.fr_info.tx_info -side right -fill both -expand 1 


$wname.fr_info.tx_info insert end $winfo
$wname.fr_info.tx_info config -state disabled
tkwait window $wname
}


####################################
# Procedure: OD_Help_InfoBox_Title #
####################################

# Creates title for infobox.

proc OD_Help_InfoBox_Title {oldtag wtag} {

concat [string range $oldtag 3 end]-[string range $wtag 3 end]

}


#######################################################################
# Help_Graph-Procedures                                               #
#######################################################################


##########################################
# Procedure: OD_Help_Graph_NewObject     #
##########################################

# Creates new object in canvas-graph, appends object to list (all_objects).
# Calls OD_Help_Graph_Bindings. 

proc OD_Help_Graph_NewObject {wtext wtag xpos ypos} {

global all_objects
global dependent_objects
global dependent_arrows
global ODv_xheight
global ODv_yheight
global ODv_xwidth
global ODv_ywidth

set graph [string range $wtag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]

set dependent_objects($wtag) ""
set dependent_arrows($wtag) ""

lappend all_objects($graph) $wtag

set x [expr ($xpos + $ODv_xheight) * $ODv_xwidth]
set y [expr ($ypos + $ODv_yheight) * $ODv_ywidth]
$win create text ${x}c ${y}c -text $wtext -tags $wtag -anchor nw

OD_Help_Graph_Bindings $wtag
}


#########################################
# Procedure: OD_Help_Graph_NewArrow     #
#########################################

# Creates a dependency between first and second object either in one or both directions.
# Shows no, one or two arrows for both directions with some vertices dependent on number of args.
# No : no args
# One : Second argument of args is 0
# In both directions : else

proc OD_Help_Graph_NewArrow {wtag1 wtag2 args} {

global dependent_objects
global dependent_arrows
global all_arrows
global ODv_xheight
global ODv_yheight
global ODv_xwidth
global ODv_ywidth

set number [llength $args]
set num [expr $number / 4]
set graph [string range $wtag1 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]

lappend dependent_objects($wtag1) $wtag2

if {$number != 0} {
  set arrow1tag [concat [string range $wtag1 3 end][string range $wtag2 3 end]]
  set arrow2tag [concat [string range $wtag2 3 end][string range $wtag1 3 end]]
  set list1 ""
  set list2 ""
  for {set i 0} {$i < $num} {incr i} {
    set x1 [expr ([lindex $args [expr 0 + (4 * $i)]] + $ODv_xheight) * $ODv_xwidth]
    set xx1 [expr $x1 + ([lindex $args [expr 1 + (4 * $i)]] * $ODv_xwidth)]
    set y1 [expr ([lindex $args [expr 2 + (4 * $i)]] + $ODv_yheight) * $ODv_ywidth]
    set yy1 [expr $y1 + ([lindex $args [expr 3 + (4 * $i)]] * $ODv_ywidth)]
    set list1 [linsert $list1 end "${x1}c"]
    set list1 [linsert $list1 end "${y1}c"]
    set list2 [linsert $list2 0 "${yy1}c"]
    set list2 [linsert $list2 0 "${xx1}c"]
  }
  lappend dependent_arrows($wtag1) $arrow1tag
  lappend all_arrows($graph) $arrow1tag
  eval "$win create line $list1 -arrow last -tags $arrow1tag"
  if {[lindex $args 1] != 0} {
    lappend dependent_objects($wtag2) $wtag1
    lappend dependent_arrows($wtag2) $arrow2tag
    lappend all_arrows($graph) $arrow2tag
    eval "$win create line $list2 -arrow last -tags $arrow2tag"
  }
}
}


##########################################
# Procedure: OD_Help_Graph_Menu_HeadLine #
##########################################

# Creates lower Menu-Head-Text in Canvas

proc OD_Help_Graph_Menu_Headline {wtext wtag xpos ypos} {

global ODv_xmheight
global ODv_ymheight
global ODv_xwidth
global ODv_ywidth

set graph [string range $wtag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]

set x [expr ($xpos + $ODv_xmheight) * $ODv_xwidth]
set y [expr ($ypos + $ODv_ymheight) * $ODv_ywidth]
$win create text ${x}c ${y}c -text $wtext -tags $wtag -anchor nw
}


##########################################
# Procedure: OD_Help_Graph_Menu_NewEntry #
##########################################

# Creates lower Menu-Text in Canvas, appends object to lists (all_objects,dependent_objects).
# Calls OD_Help_Graph_Menu_Bindings

proc OD_Help_Graph_Menu_NewEntry {wtext sourcetag wtag xpos ypos} {

global all_objects
global dependent_objects
global ODv_Help_Menus_Font
global ODv_xmheight
global ODv_ymheight
global ODv_xwidth
global ODv_ywidth

set graph [string range $sourcetag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]

lappend all_objects($graph) $wtag
lappend dependent_objects($sourcetag) $wtag

set x [expr ($xpos + $ODv_xmheight) * $ODv_xwidth]
set y [expr ($ypos + $ODv_ymheight) * $ODv_ywidth]
$win create text ${x}c ${y}c -text $wtext -tags $wtag -anchor nw -font $ODv_Help_Menus_Font

OD_Help_Graph_Menu_Bindings $sourcetag $wtag
}


###########################################
# Procedure: OD_Help_Graph_Bindings       #
###########################################

# Sets bindings for each item(tag) to Mouse-Button-1 and Mouse-Button-3.
# This proc. is needed for initializing bindings inside the canvas.

proc OD_Help_Graph_Bindings {wtag} {

set graph [string range $wtag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]
set proced [concat OD_Help${graph}_Graph_Bindings3_Details]

catch {$win bind $wtag <Button-1> "OD_Help_Graph_Modify $wtag"}
catch {$win bind $wtag <Button-3> "$proced {} $wtag"}
}



##############################################
# Procedure: OD_Help_Graph_Menu_Bindings     #
##############################################

# Sets binding for each menu-item(tag) to Mouse-Button-3.

proc OD_Help_Graph_Menu_Bindings {sourcetag wtag} {

set graph [string range $sourcetag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]
set proced [concat OD_Help${graph}_Graph_Bindings3_Details]

catch {$win bind $wtag <Button-3> "$proced $sourcetag $wtag"} 
}


###########################################
# Procedure: OD_Help_Graph_OtherLists     #
###########################################

# Creates for each item(tag) the other_objects- and other_arrows-lists. 
# These lists contain the independentent tags from the selected tag.

proc OD_Help_Graph_OtherLists {graph} {

global dependent_objects
global dependent_arrows
global all_objects
global all_arrows
global other_objects
global other_arrows

foreach elem $all_objects($graph) {
  if {[string range $elem 0 2] == $graph} {
    foreach elem1 $all_objects($graph) {if {[lsearch $dependent_objects($elem) $elem1] == -1} {
      lappend other_objects($elem) $elem1}}
    foreach elem2 $all_arrows($graph) {if {[lsearch $dependent_arrows($elem) $elem2] == -1} {
      lappend other_arrows($elem) $elem2}}
  }
}
} 


#######################################
# Procedure: OD_Help_Graph_Modify     #
#######################################

# Invokes the canvas to modify its appearence.
# $wtag is the invoking tag of the canvas widget.
# Both items and arrows are modified.
# This procedure must be used to invoke modifiing the canvas from main procedures,too.

proc OD_Help_Graph_Modify {wtag} {

global dependent_objects
global dependent_arrows
global other_objects
global other_arrows
global ODv_select
global ODv_next
global ODv_others

set graph [string range $wtag 0 2]
set win [concat .tl_help${graph}.fr_help.cv_help]
set proced [concat OD_Help${graph}_Graph_Modify_Details]

foreach elem $dependent_objects($wtag) {
  $win itemconfigure $elem -fill $ODv_next}
foreach elem $dependent_arrows($wtag) {
  $win itemconfigure $elem -fill $ODv_next}
foreach elem $other_objects($wtag) {
  $win itemconfigure $elem -fill $ODv_others}
foreach elem $other_arrows($wtag) {
  $win itemconfigure $elem -fill $ODv_others}
$win itemconfigure $wtag -fill $ODv_select

$proced $wtag
}


###########################################
# Procedure: OD_Help_Graph_MainText       #
###########################################

# Insert main-text into graphic.

proc OD_Help_Graph_MainText {graph wtext} {

global ODv_select
global ODv_next
global ODv_others
global ODv_display

if {$ODv_display == "colour"} {
  set text \
"ORACLE DATA DICTIONARY - INTERNAL QUERIES FOR RELATIONS bt.
                          $wtext.
Selected object : $ODv_select. Next Menu-Options : $ODv_next. Others : $ODv_others.
Information about request (only for existing relations) : Click with RIGHT
mouse button on selected item.
Change selected object : Click with LEFT mouse button on new item."
} else {
  set text \
"ORACLE DATA DICTIONARY - INTERNAL QUERIES FOR RELATIONS bt.
                          $wtext.

Information about request (only for existing relations) : Click with RIGHT
mouse button on selected item.
Change selected object : Click with LEFT mouse button on new item."
}

set win [concat .tl_help${graph}.fr_help.cv_help]
$win create text 0.2c 0.5c -text $text -anchor nw
}


#####################################
# Procedure: OD_InsSQL              #
#####################################


proc OD_InsSQL {} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_cmdRing

set actualsql [.tl_main.fr_statement.tx_statement get 1.0 end]

if {[string length [string trim $actualsql]] == 0} {
   return
}

set ODv_cmdRing($ODv_cmdLast) $actualsql
set ODv_cmdIdx $ODv_cmdLast

incr ODv_cmdLast
if {$ODv_cmdLast > 9} {
   set ODv_cmdLast 0
}
}


####################################
# Procedure: OD_Msg                #
####################################


proc OD_Msg { msg} {
.tl_info.fr_msg.mg_msg configure -text $msg
update idletask
}


####################################
# Procedure: OD_MsgBox             #
####################################


proc OD_MsgBox { wtitle wgeom wlinelength winfo} {
#remove old window if exist
catch {destroy .tl_msgbox}

toplevel .tl_msgbox
wm title    .tl_msgbox $wtitle
wm sizefrom .tl_msgbox user
wm geometry .tl_msgbox $wgeom

frame .tl_msgbox.fr_msg
frame .tl_msgbox.fr_cmd -relief raised -borderwidth 2

message .tl_msgbox.fr_msg.mg_msg  -relief raised  -text $winfo  -width $wlinelength 
button .tl_msgbox.fr_cmd.bn_ok  -text "Dismiss"  -command "destroy .tl_msgbox"  -borderwidth 2  -relief raised

pack .tl_msgbox.fr_msg -side top -fill both -expand 1
pack .tl_msgbox.fr_cmd  -side bottom -fill x

pack .tl_msgbox.fr_msg.mg_msg -side right -fill both -expand 1 
pack .tl_msgbox.fr_cmd.bn_ok      -side left -fill x -expand 1

tkwait window .tl_msgbox
}


###################################
# Procedure: OD_PrevSQL           #
###################################


proc OD_PrevSQL { dir} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_cmdRing

set i 0
set result_lines ""

while {$i < 10 && [string length $result_lines] == 0} {
   incr ODv_cmdIdx $dir
   if {$ODv_cmdIdx < 0} {
      set ODv_cmdIdx 9
   }
   if {$ODv_cmdIdx > 9} {
      set ODv_cmdIdx 0
   }
   set result_lines $ODv_cmdRing($ODv_cmdIdx)
   incr i
}

if {[string length $result_lines] > 0} {
   .tl_main.fr_statement.tx_statement delete 1.0 end
   .tl_main.fr_statement.tx_statement insert 1.0 "$result_lines"
}
}


###############################
# Optimize-Explain-Tree       #
###############################

##########################
# Procedure OD_Tree_Item #
##########################

# Regine Kasten
# shows selected item with other color
proc OD_Tree_Item { wname wtag} {

global tree_objects
global ODv_select
global ODv_next

set win [concat $wname.fr_tree.cv_tree]

foreach elem $tree_objects {
  if {[string compare $elem $wtag] != 0} {
     $win itemconfigure $elem -fill $ODv_next
  }
} 

 $win itemconfigure $wtag -fill $ODv_select

}



############################
# Procedure OD_Tree_Object #
############################

# Regine Kasten
# shows Information for Object
proc OD_Tree_Object { parentwname wname wtag} {


global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainList
global ODv_windows
global ODv_wincount


OD_Tree_Item $wname $wtag

set pos             [lsearch $ODv_ExplainListWins   $parentwname]
set ODv_ExplainList [lindex  $ODv_ExplainListLists  $pos]

set id   [string trim $wtag o]
set args [lindex $ODv_ExplainList $id]
  
OD_ShowExplainObject $parentwname $args

}


############################
# Procedure OD_Tree_ObjDet #
############################

# Regine Kasten
# shows Information for Object Extents and Devices
proc OD_Tree_ObjDet { parentwname wname wtag} {


global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainList
global ODv_windows
global ODv_wincount


OD_Tree_Item $wname $wtag

set pos             [lsearch $ODv_ExplainListWins   $parentwname]
set ODv_ExplainList [lindex  $ODv_ExplainListLists  $pos]

set id   [string trim $wtag o]

set args [lindex $ODv_ExplainList $id]
 
OD_ShowExplainObjDet $parentwname $args

}


##########################
# OD_Tree_Tree         #
##########################

# Regine Kasten
# Shows child tree under the selected node
proc OD_Tree_Tree { parentwname wname wtag} {


global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainListIds
global ODv_ExplainList
global ODv_ExplainIds


OD_Tree_Item $wname $wtag

set pos             [lsearch $ODv_ExplainListWins  $parentwname]
set ODv_ExplainList [lindex  $ODv_ExplainListLists $pos]
set ODv_ExplainIds  [lindex  $ODv_ExplainListIds   $pos]

 # get Object and Position in ExplainList
set id      [string trim $wtag o]
set pid     $id
set firstid $id
set i       $firstid
 # search Positions of child Tree in lists of ids and parent_ids
set lipos ""
while {$pid >= $id} {
  lappend lipos $i
  set lastid $i
  incr i 1
  set idpid [lindex $ODv_ExplainIds $i]
  set pid   [lindex $idpid 1]
}

 # set Child-Tree-List
set explainlist [lrange $ODv_ExplainList $firstid $lastid]
set explainids  [lrange $ODv_ExplainIds  $firstid $lastid]

OD_ShowExplainTree $parentwname $explainlist $explainids

}



################################
# Procedure: OD_Tree_Bindings  #
################################

# Regine Kasten
# Sets bindings for each item(tag) to Mouse-Button-1 and Mouse-Button-3.
# This proc. is needed for initializing bindings inside the canvas.
proc OD_Tree_Bindings { parentwname wname wtag} {

set win [concat $wname.fr_tree.cv_tree]

catch {$win bind $wtag <Button-1> "OD_Tree_Object $parentwname $wname $wtag"}
catch {$win bind $wtag <Button-2> "OD_Tree_ObjDet $parentwname $wname $wtag"}
catch {$win bind $wtag <Button-3> "OD_Tree_Tree   $parentwname $wname $wtag"}

}



#################################
# Procedure: OD_Tree_NewObject  #
#################################

# Regine Kasten
# Creates new object in canvas-tree, appends object to list (tree_objects).
# Calls OD_Tree__Bindings. 
proc OD_Tree_NewObject { parentwname wname obj wtag coord explainlist} {

global tree_objects

set win [concat $wname.fr_tree.cv_tree]

lappend tree_objects $wtag

 # set text-object-coords
set txtcoord  [lindex $coord 0]
set x         [lindex $txtcoord 0]
set y         [expr [lindex $txtcoord 1] + 0.5]
 # set item-object-coords
set itemcoord [lindex $coord 1]
set xl        [lindex $itemcoord 0]
set yl        [lindex $itemcoord 1]
set xr        [lindex $itemcoord 2]
set yr        [lindex $itemcoord 3]


# create object
set txtobj0 [concat [lindex $obj 0]]
set txtobj1 [concat [lindex $obj 1]]
set txtobj2 [concat [lindex $obj 2]]
set txtobj3 [concat [lindex $obj 3]]
# set operation
set txtobj $txtobj0
if { [string compare $txtobj0 AGGREGATE] == 0} {
  set txtobj "AGG"
} elseif { [string compare $txtobj0 AND] == 0} {
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 CONNECT] == 0} {
   set txtobj "CON"
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 CONCATENATION] == 0} {
   set txtobj "CAT"
} elseif { [string compare $txtobj0 COUNTING] == 0} {
   set txtobj "CNT"
} elseif { [string compare $txtobj0 FILTER] == 0} {
   set txtobj "FILT"
} elseif { [string compare $txtobj0 FIRST] == 0} {
   set txtobj "FIRST"
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 FIXED_TABLE] == 0} {
   set txtobj "FIXED_TAB" 
   set txtobj2 $txtobj1
   set txtobj1 0
} elseif { [string compare $txtobj0 FOR] == 0} {
   set txtobj "UPD"
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 INDEX] == 0} {
   set txtobj "IDX"
} elseif { [string compare $txtobj0 INTERSECTION] == 0} {
   set txtobj "INTER"
} elseif { [string compare $txtobj0 MERGE] == 0} {
   set txtobj "MJ"
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 MINUS] == 0} {
   set txtobj "-"
} elseif { [string compare $txtobj0 NESTED] == 0} {
   set txtobj "NL"
   set txtobj1 $txtobj2
   set txtobj2 $txtobj3
} elseif { [string compare $txtobj0 PROJECTION] == 0} {
   set txtobj "PROJ"
} elseif { [string compare $txtobj0 REMOTE] == 0} {
   set txtobj "REM"
} elseif { [string compare $txtobj0 SEQUENCE] == 0} {
   set txtobj "SEQ"
} elseif { [string compare $txtobj0 TABLE_ACCESS] == 0} {
   set txtobj "TAB"
} elseif { [string compare $txtobj0 UNION-ALL] == 0} {
   set txtobj "+"
} elseif { [string compare $txtobj0 VIEW] == 0} {
   set txtobj2 $txtobj1
   set txtobj1 0
}


# set option
if {[ctype -failindex var digit $txtobj1] == 0} {
lappend txtobj $txtobj1 }

set lhl [split "FIXED_TABLE INDEX REMOTE TABLE_ACCESS VIEW"]
if { [lsearch $lhl $txtobj0] != -1} {
    # draw item as object
    $win create text ${x}c ${y}c -text $txtobj -tags $wtag 
    if {[ctype -failindex var digit $txtobj2] == 0} {
        # set length of tablename = 15
       set txtobj2 [csubstr [concat $txtobj2] 0 15] 
       set y [expr $y + 0.5]
       $win create text ${x}c ${y}c -text $txtobj2 -tags $wtag 
    }
    $win create rectangle ${xl}c ${yl}c ${xr}c ${yr}c
} else { 
    # draw item as operation   
    set y [expr $y + 0.25]
    $win create text ${x}c ${y}c -text $txtobj -tags $wtag 
    $win create oval ${xl}c ${yl}c ${xr}c ${yr}c 
}

OD_Tree_Bindings $parentwname $wname $wtag

}



################################
# Procedure: OD_DrawExplainTree
################################

# Regine Kasten
# Creates the canvas widget for the ExplainTreeStructure and draw it.
proc OD_DrawExplainTree {  wname parentwname explainlist explainids explainpids CntIds Coord TreeSpace} {

global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainListTypes
global ODv_LeaveHeight


set lipos          [lsearch $ODv_ExplainListWins  $parentwname]
set allexplainlist [lindex $ODv_ExplainListLists $lipos]
set explaintype    [lindex  $ODv_ExplainListTypes $lipos]


OD_Msg "Still drawing the tree" 

# sets the frame for the canvas
set TreeWidth  [lindex $TreeSpace 0]
set TreeHeight [lindex $TreeSpace 1]
if {$TreeWidth  < 13} {set TreeWidth 13}
if {$TreeHeight < 7} {set TreeHeight 7}


#window
catch    "destroy $wname"
toplevel $wname -relief {raised}

# window configuration
wm title    $wname "Explain-Tree from Explain-Plan with $explaintype"
wm minsize  $wname 450  150
wm maxsize  $wname 2000 1000
wm sizefrom $wname program
wm geometry $wname 500x500


### frame for menu
frame $wname.fr_menu -borderwidth {2}  -relief {raised}
button $wname.fr_menu.bn_tree   -command "catch \{OD_ExplainFullTree $parentwname\}" -relief {flat} -text {Full}
menubutton $wname.fr_menu.filemenu  -menu "$wname.fr_menu.filemenu.m" -text {File-Menu} -underline {0}  
menu $wname.fr_menu.filemenu.m                          
  $wname.fr_menu.filemenu.m add command -command "catch \{OD_SaveExplainTree $wname $TreeWidth $TreeHeight\}"  -label {Save as...} -underline {0}
  $wname.fr_menu.filemenu.m add command -command "catch \{OD_PrintExplainTree $wname $TreeWidth $TreeHeight \}"  -label {Print} -underline {0}
button $wname.fr_menu.bn_help   -command {OD_Help_InfoBox "ODDIS-Explaintree-Help" $ODv_explainplaninfo .tl_explainhlp 900 200} -relief {flat} -text {Help}

pack append $wname.fr_menu  $wname.fr_menu.bn_tree {left frame center} $wname.fr_menu.bn_help {right frame center}  $wname.fr_menu.filemenu {right frame center} 

### frame for graphic
frame $wname.fr_tree 
scrollbar $wname.fr_tree.sb_vtree -command "$wname.fr_tree.cv_tree yview" -orient {vertical}   -relief {raised}
scrollbar $wname.fr_tree.sb_htree -command "$wname.fr_tree.cv_tree xview" -orient {horizontal} -relief {raised} 
canvas    $wname.fr_tree.cv_tree  -width {5c} -height {5c} -scrollregion "0c 0c ${TreeWidth}c ${TreeHeight}c" -relief "raised"  -xscrollcommand "$wname.fr_tree.sb_htree set"  -yscrollcommand "$wname.fr_tree.sb_vtree set" 

pack   $wname.fr_tree          -side top    -fill both -expand 1
pack   $wname.fr_tree.sb_vtree -side left   -fill y
pack   $wname.fr_tree.sb_htree -side bottom -fill x
pack   $wname.fr_tree.cv_tree  -side top    -fill both -expand 1

### frame for buttons
frame  $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_cancel -text {Dismiss} -command "destroy $wname" 

pack append $wname.fr_cmd  $wname.fr_cmd.bn_cancel {left frame center expand fill}


### pack window 
pack append $wname  $wname.fr_menu {top frame center fillx}  $wname.fr_tree {top frame center expand fill}  $wname.fr_cmd {top frame center fillx} 


### draw Tree

# write Informationtext
 $wname.fr_tree.cv_tree create text 1c 1c   -text {STRUCTURE FOR EXPLAIN-PLAN-QUERY} -anchor sw
 $wname.fr_tree.cv_tree create text 1c 1.5c -text {Selected Object: white.      Others: black} -anchor sw
 $wname.fr_tree.cv_tree create text 1c 2c   -text {Information about Object:                       Click with LEFT mouse button} -anchor sw
 $wname.fr_tree.cv_tree create text 1c 2.5c -text {Information about Object-Statistics:  Click with MIDDLE mouse button} -anchor sw
 $wname.fr_tree.cv_tree create text 1c 3c   -text {Information about Sub-Tree:                 Click with RIGHT mouse button} -anchor sw

# write Information about Statement
 set statement     [lindex $allexplainlist 0]
 set statetext     [lindex $statement 0]
 append statetext  "   " 
 append statetext  [lindex $statement 1]
 set text "Explain-Plan-Query was a   $statetext"
 set costs         [lindex $statement 4]
 if {[clength $costs] != 0 } {	
    append text "   with Costs : $costs"
 }	
 $wname.fr_tree.cv_tree create text 1c 4c  -text $text -anchor sw

OD_Msg "Still drawing the tree .." 

# Initialize Lists.

set tree_objects ""


# Insert the objects

for {set i 0} {$i <= $CntIds} {incr i 1} {
  set id  [lindex $explainids $i]
  set obj [lindex $explainlist $i]
  set coi [lindex $Coord $i]
  OD_Tree_NewObject $parentwname $wname $obj o$id $coi $explainlist 
}

OD_Msg "Still drawing the tree ..." 

# Insert the Lines

for {set i 1} {$i <= $CntIds} {incr i 1} {
   # line from
  set id       [lindex $explainids $i]
  set idcoord  [lindex $Coord $i]
  set idpoint  [lindex $idcoord 0]
  set idsx     [lindex $idpoint 0]
  set idsy     [lindex $idpoint 1]
   # line to
  set pid      [lindex $explainpids $i]
  set pidlipos [lsearch $explainids $pid]
  set pidcoord [lindex $Coord $pidlipos]
  set pidpoint [lindex $pidcoord 0]
  set pidx     [lindex $pidpoint 0]
  set pidy     [lindex $pidpoint 1]
  set pidy     [expr $pidy + $ODv_LeaveHeight] 
   # draw line
  set line$i [$wname.fr_tree.cv_tree create line ${idsx}c ${idsy}c ${pidx}c ${pidy}c]
}


OD_Msg "Explain-Tree finished, getting results"

}


################################
# Procedure OD_ShowExplainTree
################################

# Regine Kasten
# calculates the coordinates for the explaintree 
proc OD_ShowExplainTree { parentwname explainlist explainids} {

global ODv_user
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_LeaveWidth
global ODv_LeaveXSpace
global ODv_LeaveHeight
global ODv_LeaveYSpace
global ODv_TextSpace


set infotxt "Still trying to get Coordinates for the tree"
set info    $infotxt

OD_Msg "$info"

###### set all used variables

### count all elements of the plan 
set CntIds [expr [llength $explainids] - 1]

### set Ids und PIds Lists
set liids  ""
set lipids ""
for {set i 0} {$i <= $CntIds} {incr i 1} {
  set elem       [concat [lindex $explainids $i]]
  lappend liids  [lindex $elem 0]
  lappend lipids [lindex $elem 1]
}



###### make all calculations to get coordinates for a graphic 

### count and remember children
 # set elems visited
set lipidscp [lreplace $lipids 0 0 -1]
 # get children of elem
set CntChild ""
set Children ""
for {set i 0} {$i <= $CntIds} {incr i 1} {
  set childposhl ""
  set childpos   ""
  set id         [lindex  $liids $i]
  set childposhl [lsearch $lipidscp $id]
   # if child found
  while {$childposhl != -1} {
     lappend childpos [lindex   $liids    $childposhl]
     set lipidscp     [lreplace $lipidscp $childposhl $childposhl -1]
     set childposhl   [lsearch  $lipidscp $id]
  }
  ### count children
  lappend CntChild [llength $childpos]
  lappend Children [lsort -real $childpos]
} 


append info " ."
OD_Msg "$info"

### get list with ordered x-position in the tree in postorder
 # set root
set Xpos [lindex $liids 0]
 # set children on left side from elem
for {set i 1} {$i <= $CntIds} {incr i 1} {
  set id       [lindex  $liids  $i]
  set pid      [lindex  $lipids $i]
  set pidsxpos [lsearch $Xpos   $pid]
  set Xpos     [linsert $Xpos   $pidsxpos $id]
}


### get needed width of the tree
set CntLeaves [llength [lmatch $CntChild 0]]
set CntXSpace [expr $CntLeaves + 1]


### set space beetween LeavePoints
set CoordSpace [expr $ODv_LeaveWidth + $ODv_LeaveXSpace] 

append info " ."
OD_Msg "$info"


### get x-Coordinates of Leaves 
 # initialyze list
set XCoord ""
for {set i 0} {$i <= $CntIds} {incr i 1} {
  lappend XCoord 0 
}
 # set initial Element
set id     [lindex $Xpos 0]
set Coord  [expr 0.5 * $CoordSpace]
set posact [lsearch $liids $id]
set XCoord [lreplace $XCoord $posact $posact $Coord]
set lastid $id
set Width  $CoordSpace
 # calculate the Coordinates for each id 
for {set i 1} {$i <= $CntIds} {incr i 1} {
    set actid  [lindex $Xpos $i]
    set posact [lsearch $liids $actid]
    if {$actid > $lastid} { # id's with same pid
	set poslast  [lsearch $liids  $lastid]
	set actpid   [lindex  $lipids $posact]
        set lastpid  [lindex  $lipids $poslast]
	if {$actpid != $lastpid} {
	   set ActCoord [expr $Coord + (0.2 * $ODv_LeaveXSpace)]
	} else {
	   set ActCoord $Coord
	}
	set newcoord [expr $Width + $ActCoord]
	set Width    [expr $Width + (2 * $ActCoord)]
    } else { # go to pid
	set actchildren [lindex  $Children $posact]
	set actcnt      [expr    [lindex $CntChild $posact] - 1]
	set leftchild   [lindex  $actchildren 0]
	set rightchild  [lindex  $actchildren $actcnt]
	set posleft     [lsearch $liids $leftchild]
	set posright    [lsearch $liids $rightchild]
	set leftcoord   [lindex  $XCoord $posleft]
	set rightcoord  [lindex  $XCoord $posright]
	set newcoord    [expr 0.5 * ($leftcoord + $rightcoord)]
    }
    set XCoord [lreplace $XCoord $posact $posact $newcoord]
    set lastid $actid
    append info " ."
    OD_Msg "$info"
}


### set width of tree
set TreeWidth [expr [lindex $XCoord $CntIds] + $Coord]

append info " ."
OD_Msg "$info"
set info $infotxt

###  Space between Y-Coordinates
set SpaceAbs [expr $ODv_LeaveYSpace + $ODv_LeaveHeight]
 

### get ordered y-position in tree and the Coordinates
 # initialyze Ypos
set YPos 1
for {set i 1} {$i <= $CntIds} {incr i 1} {
  lappend YPos 0
} 
set actcoord [expr $SpaceAbs + $ODv_TextSpace]
set YCoord [lreplace $YPos 0 0 $actcoord]
 # 1 + height of parent, yheight * YSpace 
for {set i 1} {$i <= $CntIds} {incr i 1} {
  set pid         [lindex  $lipids   $i]
  set pidlipos    [lsearch $liids    $pid]
  set actcntchild [lindex  $CntChild $pid]
  if {$actcntchild > 2} {
     set yp [expr [lindex $YPos $pidlipos] + 1.5]
  } else {
     set yp [expr [lindex $YPos $pidlipos] + 1]
  }
  set YPos     [lreplace $YPos $i $i $yp]
  set actcoord [expr ($yp * $SpaceAbs) + $ODv_TextSpace]
  set YCoord   [lreplace $YCoord $i $i $actcoord]
  append info " ."
  OD_Msg "$info"
}


### get needed height of the tree
set hl         [lsort -real $YPos]
set TreeHeight [expr ([lindex $hl $CntIds] + 1) * $SpaceAbs]

append info " ."
OD_Msg "$info"
set info $infotxt

###  list the leavepoint- and outlinerectangle-coordinates
###  leavepoint means the middle of the nodeupperside
set Coord ""
for {set i 0} {$i <= $CntIds} {incr i 1} {
   # get leavepoint
  set xm [lindex  $XCoord $i]
  set ym [lindex  $YCoord $i]
   # get outlinepoints
  set xl [expr $xm - ($ODv_LeaveWidth * 0.5)]
  set yl $ym
  set xr [expr $xm + ($ODv_LeaveWidth * 0.5)]
  set yr [expr $ym + $ODv_LeaveHeight]
   # set leavepoint
  set xy $xm
  lappend xy $ym
   # set outlinepoints for a rectangle
  set rect $xl
  lappend rect $yl $xr $yr  
  set newCoord ""
  lappend newCoord $xy $rect
  lappend Coord $newCoord
  append info " ."
  OD_Msg "$info"
}

# make a spaceframe
set TreeWidth  [expr 1.5 * $TreeWidth]
set TreeHeight [expr 1.5 * $TreeHeight]
set TreeSpace  "$TreeWidth $TreeHeight"


if {$ODv_windows == "one"} {
  OD_DrawExplainTree .tl_drawtree $parentwname $explainlist $liids $lipids $CntIds $Coord $TreeSpace 
} elseif {$ODv_windows == "many"} {
  OD_DrawExplainTree .tl_drawdrawtree $parentwname $explainlist $liids $lipids $CntIds $Coord $TreeSpace
} else {
  incr ODv_wincount
  OD_DrawExplainTree .$ODv_wincount $parentwname $explainlist $liids $lipids $CntIds $Coord $TreeSpace
}


}
