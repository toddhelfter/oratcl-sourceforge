####################################
# Procedure: OD_CheckFile          #
####################################


proc OD_CheckFile { win execproc} {
catch {OD_SelInsert $win [lindex [selection get] 0]}

set f [lindex [$win.fr_file.en_file get] 0]
if [file isdirectory $f] {
  cd $f
  set f [pwd]
  OD_FillLst $win [$win.fr_filter.en_filter get] $f
} else {
  $execproc $win $f
}
}


#####################################
# Procedure: OD_FileBox             #
#####################################


proc OD_FileBox { win filt startdir execproc} {

set win_title $win
regsub -all {_} $win_title " " win_title
set win [translit A-Z a-z $win]

catch {destroy $win}
toplevel $win
wm title $win [string range $win_title 1 end]
wm sizefrom $win program
wm geometry $win 270x300

if {[string length $startdir] == 0} {
   set startdir [pwd]
}


frame $win.fr_list -borderwidth {2} -relief {raised}
scrollbar $win.fr_list.sb_vlist -command "$win.fr_list.lb_list yview"
scrollbar $win.fr_list.sb_hlist -orient {horizontal}  -command "$win.fr_list.lb_list xview"
listbox $win.fr_list.lb_list -width {10} -height {2} -relief {raised} -xscroll "$win.fr_list.sb_hlist set" -yscroll "$win.fr_list.sb_vlist set"

frame $win.fr_filter  -borderwidth {2} -relief {raised}
label $win.fr_filter.lb_filter  -text {Filter:} -width {10}
entry $win.fr_filter.en_filter  -relief {sunken}  -width {25}

frame $win.fr_file  -borderwidth {2} -relief {raised}
label $win.fr_file.lb_file  -text {Selection:} -width {10}
entry $win.fr_file.en_file  -relief {sunken}   -width {25}

frame  $win.fr_cmd  -borderwidth {2} -relief {raised}
button $win.fr_cmd.bn_ok      -text {Ok}      -command "OD_CheckFile $win $execproc"
button $win.fr_cmd.bn_filter  -text {Filter}  -command "OD_FillLst $win \[$win.fr_filter.en_filter get\] \[pwd\]"
button $win.fr_cmd.bn_cancel  -text {Cancel}  -command "destroy $win"

pack $win.fr_list -side top -fill both -expand 1
pack $win.fr_filter -fill x
pack $win.fr_file -fill x
pack $win.fr_cmd -fill x

pack $win.fr_list.sb_vlist -side left -fill y
pack $win.fr_list.sb_hlist -side bottom -fill x
pack $win.fr_list.lb_list  -side top -fill both -expand 1

pack $win.fr_filter.lb_filter -side left
pack $win.fr_filter.en_filter -side top

pack $win.fr_file.lb_file -side left
pack $win.fr_file.en_file -side top

pack $win.fr_cmd.bn_ok -side left -fill x -expand 1
pack $win.fr_cmd.bn_filter -side left -fill x -expand 1
pack $win.fr_cmd.bn_cancel -side left -fill x -expand 1

$win.fr_filter.en_filter insert 0 $filt

#bind $win.fr_filter.en_filter <KeyPress-Return> "$win.fr_cmd.bn_filter invoke"
#bind $win.fr_file.en_file     <KeyPress-Return> "$win.fr_cmd.bn_ok     invoke"
bind $win.fr_list.lb_list <ButtonRelease-1> "OD_SelInsert $win \[%W get \[%W nearest %y \] \]"
#bind $win.fr_list.lb_list <Button1-Motion> ""
#bind $win.fr_list.lb_list <Shift-Button1-Motion> ""

#bind $win <1> "$win.fr_cmd.bn_ok config -relief sunken"
#bind $win <ButtonRelease-1> "$win.fr_cmd.bn_ok invoke; $win.fr_cmd.bn_ok deactivate"
bind $win <Return> "$win.fr_cmd.bn_ok invoke"
#bind $win.fr_cmd <Enter> "$win.fr_cmd.bn_ok activate"
#bind $win.fr_cmd <Leave> "$win.fr_cmd.bn_ok deactivate"

OD_FillLst $win $filt $startdir
selection own $win
focus $win.fr_file.en_file
}


######################################
# Procedure: OD_FileOpen             #
######################################


proc OD_FileOpen { win filename} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename
set ODv_cmdIdx $ODv_cmdLast

if [file isfile $filename] {
   OD_ClearResult
   OD_ClearMain
   set ODv_filename [file tail $filename]
   OD_Msg "SQL (${ODv_filename})"
   set result_lines [exec cat -s $filename]
   .tl_main.fr_statement.tx_statement insert 1.0 "$result_lines"
   OD_Msg "$filename loaded"
   destroy $win
} else {
   OD_Msg "$filename not found"
}
focus .tl_main.fr_statement.tx_statement
}


#####################################
# Procedure: OD_FileSave            #
#####################################


proc OD_FileSave {} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename
set ODv_cmdIdx $ODv_cmdLast

if {[string length $ODv_filename] == 0} {
  OD_FileBox .Save * "" OD_FileSaveAs
} else {
  set f [open $ODv_filename w]
  puts $f [.tl_main.fr_statement.tx_statement get 1.0 end]
  close $f
  OD_Msg "saved to $ODv_filename"
}
}


#####################################
# Procedure: OD_FileSaveAs          #
#####################################


proc OD_FileSaveAs { win filename} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename
set ODv_cmdIdx $ODv_cmdLast

set openrc [catch {set f [open $filename w]}]

if $openrc==1 {
   OD_Msg "Error: $filename could not be opened, not saved"
   return
}

set ODv_filename $filename
OD_Msg "SQL (${ODv_filename})"
puts $f [.tl_main.fr_statement.tx_statement get 1.0 end]
close $f
OD_Msg "SQL saved to $ODv_filename"

destroy $win
}


####################################
# Procedure: OD_FillLst            #
####################################


proc OD_FillLst { win filt dir} {
$win.fr_list.lb_list delete 0 end
cd $dir
set dir [pwd]
if {[string length $filt] == 0} {
  set filt *
}
set all_list [lsort [glob -nocomplain $dir/$filt]]
set dlist "$dir/../"
set flist ""

foreach f $all_list {
   if [file isfile $f] {
      lappend flist $f
   }
   if [file isdirectory $f] {
      lappend dlist ${f}/
   }
}

foreach d $dlist {
  $win.fr_list.lb_list insert end $d
}

foreach f $flist {
  $win.fr_list.lb_list insert end $f
}

$win.fr_list.lb_list yview 0

set idx [expr [string length [file dirname [file dirname $dir]]]+1]

$win.fr_list.lb_list xview $idx
}

###################################
# Procedure: OD_PrintResult       #
###################################

# B/S, Regine Kasten
proc OD_PrintResult {} {

global ODv_printPSPath

if [.tl_result.fr_result.lb_result size]==0 {
  OD_Msg "No output to print"
  return
}

for {set i 0} {$i < [.tl_result.fr_result.lb_result size]} {incr i} {
   append out_lines "[.tl_result.fr_result.lb_result get $i]\n"
}

OD_Msg [exec $ODv_printPSPath << $out_lines]
}


###################################
# Procedure: OD_SaveResult        #
###################################


proc OD_SaveResult { win filename} {
global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename
set ODv_cmdIdx $ODv_cmdLast

set openrc [catch {set f [open $filename w]}]

if $openrc==1 {
   OD_Msg "Error: $filename could not be opened, not saved"
   return
}


if [.tl_result.fr_result.lb_result size]==0 {
  OD_Msg "No output to save"
  close $f
  return
}


for {set i 0} {$i < [.tl_result.fr_result.lb_result size]} {incr i} {
   puts $f [.tl_result.fr_result.lb_result get $i]
}
close $f
OD_Msg "Results saved to $ODv_filename"
destroy $win
}


###################################
# Procedure: OD_SelInsert         #
###################################


proc OD_SelInsert { win pathname} {
$win.fr_file.en_file delete 0 end
$win.fr_file.en_file insert 0 $pathname
set idx [expr [string length [file dirname [file dirname $pathname]]]+1]
$win.fr_file.en_file xview $idx
$win.fr_file.en_file select from 0
}

########################################
# Procedures: Explain                  #
########################################

###################################
# Procedure: OD_PrintExplain      #
###################################

# Regine Kasten
# Procedure: OD_PrintExplain
# Print the result in the explainplan window on a laserwriter
proc OD_PrintExplain {} {

global ODv_printPSPath

if [.ow_explainplan.fr_list.lb_list size]==0 {
  OD_Msg "No output to print"
  return
}

for {set i 0} {$i < [.ow_explainplan.fr_list.lb_head size]} {incr i} {
   append out_lines "[.ow_explainplan.fr_list.lb_head get $i]\n"
}

for {set i 0} {$i < [.ow_explainplan.fr_list.lb_list size]} {incr i} {
   append out_lines "[.ow_explainplan.fr_list.lb_list get $i]\n"
}

OD_Msg [exec $ODv_printPSPath << $out_lines]
}


###################################
# Procedure: OD_SaveExplain       #
###################################

# Regine Kasten
# Procedure: OD_SaveExplain
# save the result in the explainplan window with filename
proc OD_SaveExplain { win filename} {

global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename

set ODv_cmdIdx $ODv_cmdLast

set openrc [catch {set f [open $filename w]}]

if $openrc==1 {
   OD_Msg "Error: $filename could not be opened, not saved"
   return
}


if [.ow_explainplan.fr_list.lb_list size]==0 {
  OD_Msg "No output to save"
  close $f
  return
}

for {set i 0} {$i < [.ow_explainplan.fr_list.lb_list size]} {incr i} {
   puts $f [.ow_explainplan.fr_list.lb_list get $i]
}

close $f
OD_Msg "Explain-Results saved to $ODv_filename"
destroy $win

}


###################################
# Procedure: OD_PrintExplainTree  #
###################################

# Regine Kasten
# Procedure: OD_PrintExplainTree
# print the result in the explaintree window on a laserwriter
# !!! only the frame which you can see
proc OD_PrintExplainTree { wname width height} {

global ODv_printTreePath

OD_Msg [exec $ODv_printTreePath << [$wname.fr_tree.cv_tree postscript -height ${height}c -width ${width}c]]

}



###########################
# Procedures: OD_SaveTree #
###########################

# Regine Kasten
# save the result in the explaintree window 
# as a postscriptfile in filename
# !!! only the frame which you can see
proc OD_SaveTree { win filename} {

global ODv_cmdIdx
global ODv_cmdLast
global ODv_filename
global ODv_TreeHeight
global ODv_TreeWidth

set ODv_cmdIdx $ODv_cmdLast

set openrc [catch {set f [open $filename w]}]

if $openrc==1 {
   OD_Msg "Error: $filename could not be opened, not saved"
   return
}

set l [clength $win]
set l [expr $l - 4]
set wname [csubstr $win 0 $l]

$wname.fr_tree.cv_tree postscript -height ${ODv_TreeHeight}c -width ${ODv_TreeWidth}c -file $filename

close $f
OD_Msg "Explain-Results saved to $ODv_filename"
destroy $win

}


###################################
# Procedures: OD_SaveExplainTree  #
###################################

# Regine Kasten
# select the result canvas and shows a filebox-window
# !!! only the frame which you can see
proc OD_SaveExplainTree { wname width height} {

global ODv_TreeHeight
global ODv_TreeWidth

set ODv_TreeHeight $height
set ODv_TreeWidth  $width

set savewin ${wname}save

OD_FileBox $savewin * "" OD_SaveTree

}
