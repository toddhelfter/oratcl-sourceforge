##################################################
# Find System-Objects                            #
##################################################

proc OD_ShowWind.ow_sysfindobject { wname title args} {

catch "destroy $wname"
toplevel $wname   -relief {raised}

# Window manager configuration
global ODv_font
wm positionfrom $wname program
wm sizefrom $wname program
wm title $wname $title 



message $wname.mg  -aspect {1000}  -padx {5}  -pady {2}  -relief {ridge}  -text {Find Object, please enter SQL-search-string}
frame $wname.fr_owner  -borderwidth {2}
entry $wname.fr_owner.en_owner  -relief {sunken}
  # bindings
  bind $wname.fr_owner.en_owner <Key-Return> "focus $wname.fr_name.en_name"
label $wname.fr_owner.lb_owner  -text {Owner        }

pack append $wname.fr_owner  $wname.fr_owner.en_owner {right frame e padx 20 pady 20 expand}  $wname.fr_owner.lb_owner {left frame center}

frame $wname.fr_name  -borderwidth {2}
entry $wname.fr_name.en_name  -relief {sunken} 
  # bindings
  bind $wname.fr_name.en_name <Key-Return> "$wname.fr_cmd.bn_find invoke"
label $wname.fr_name.lb_name  -text {Name        }

pack append $wname.fr_name  $wname.fr_name.en_name {right frame e padx 20 pady 20 expand}  $wname.fr_name.lb_name {left frame center}

frame $wname.fr_typelist  -borderwidth {2}
entry $wname.fr_typelist.en_typelist  -relief {sunken}
  # bindings
  bind $wname.fr_typelist.en_typelist <Key-Return> "$wname.fr_cmd.bn_find invoke"
menubutton $wname.fr_typelist.mb_typelist  -menu "$wname.fr_typelist.mb_typelist.m"  -relief {raised}  -text {Typelist}  
menu $wname.fr_typelist.mb_typelist.m

pack append $wname.fr_typelist  $wname.fr_typelist.en_typelist {right frame e padx 20 pady 20 expand}  $wname.fr_typelist.mb_typelist {left frame center}

message $wname.mg_error  -aspect {1500}  -padx {5}  -pady {2}  -text {}
frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_find  -command "OD_TrySysFind \[$wname.fr_owner.en_owner get\] \[$wname.fr_name.en_name get\] \[$wname.fr_typelist.en_typelist get\] "  -text {Find}
button $wname.fr_cmd.bn_dismiss  -command "destroy $wname"  -text {Dismiss}

pack append $wname.fr_cmd  $wname.fr_cmd.bn_find {left frame center expand fillx}  $wname.fr_cmd.bn_dismiss {left frame center expand fillx}

pack append $wname  $wname.mg {top frame center pady 5 fillx} $wname.fr_owner {top frame center padx 80 pady 10} $wname.fr_name {top frame center} $wname.fr_typelist {top frame center pady 15} $wname.mg_error {top frame center fillx} $wname.fr_cmd {top frame center fillx}

tk_menuBar $wname.fr_typelist $wname.fr_typelist.mb_typelist
$wname.fr_typelist.mb_typelist.m add command -label {Table} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TABLE}"
$wname.fr_typelist.mb_typelist.m add command -label {Index} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {INDEX}"
$wname.fr_typelist.mb_typelist.m add command -label {View} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {VIEW}"
$wname.fr_typelist.mb_typelist.m add command -label {Cluster} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {CLUSTER}"
$wname.fr_typelist.mb_typelist.m add command -label {Sequence} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SEQUENCE}"
$wname.fr_typelist.mb_typelist.m add command -label {DB_Link} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {DATABASE LINK}"
$wname.fr_typelist.mb_typelist.m add command -label {Synonym} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SYNONYM}"
$wname.fr_typelist.mb_typelist.m add command -label {Trigger} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TRIGGER}"
$wname.fr_typelist.mb_typelist.m add command -label {Procedure} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PROCEDURE}"
$wname.fr_typelist.mb_typelist.m add command -label {Package} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PACKAGE}"


$wname.fr_owner.en_owner insert end {}
$wname.fr_name.en_name insert end {} 
$wname.fr_typelist.en_typelist insert end {}

}

proc OD_TrySysFind {owner name type} {
set error [catch {OD_SysFind $owner $name $type}]
if {$error == 1} {OD_Msg "Permission denied"}
}

#Procedure OD_SysFind
proc OD_SysFind {owner name type} {
global ODv_oracursor
global oramsg
global ODv_hlSysObjects
global ODv_wincount
global ODv_windows
global ODv_fSysObjects

set li [split $ODv_hlSysObjects /]
set title [format "$ODv_fSysObjects" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

if {$owner == ""} {set owner "%"}
if {$name == ""} {set name "%"}
if {$type == ""} {
    set query "select owner, object_name, object_type from sys.dba_objects where owner like upper('$owner') and object_name like upper('$name') order by owner, object_name"
  } else {
    set query "select owner, object_name, object_type from sys.dba_objects where owner like upper('$owner') and object_name like upper('$name') and object_type like upper('$type') order by owner, object_name"
  }

set li ""
OD_Msg "Searching for data..."
orasql $ODv_oracursor $query

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysObjects" @1 @2 @3]}



if {[llength $li] == 0} {
   OD_Msg "No match"
   return
}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if {$ODv_windows == "one"} {
  OD_GenWin .ow_sysobject "Matching Ojects" $title 440 310 440x310 $li 1 "Details" OD_ShowSysObjectDetails
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_sysobject "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowSysObjectDetails
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowSysObjectDetails
}

}


proc OD_ShowSysObjectDetails { args} {
global ODv_hlSysTables
global ODv_hlSysIndexes
global ODv_hlSysViews
global ODv_hlSysClusters
global ODv_hlSysSequences
global ODv_hlSysDBLinks
global ODv_hlSysSynonyms
global ODv_hlSysTriggers
global ODv_hlSysProcedures
global ODv_fSysTables
global ODv_fSysIndexes
global ODv_fSysViews
global ODv_fSysClusters
global ODv_fSysSequences
global ODv_fSysDBLinks
global ODv_fSysSynonyms
global ODv_fSysTriggers
global ODv_fSysProcedures

set oldargs $args
set args [string trim $args \{\}]
set owner [lindex $args 0]
set name [lindex $args 1]
set type [lindex $args 2]

if {$type == "TABLE"} { 
      set headline $ODv_hlSysTables
      set form $ODv_fSysTables
      set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'TABLE' and owner = '$owner' and object_name = '$name'"
      set newtag "sysTables"
      set message "Table $name of User $owner"
    } elseif {$type == "INDEX"} {
      set headline $ODv_hlSysIndexes
      set form $ODv_fSysIndexes
      set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from sys.dba_indexes  where owner = '$owner' and index_name = '$name'"
      set newtag "sysIndexes"
      set message "Index $name of User $owner"
    } elseif {$type == "VIEW"} { 
      set headline $ODv_hlSysViews
      set form $ODv_fSysViews
      set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'VIEW' and owner = '$owner' and object_name = '$name'" 
      set newtag "sysViews"
      set message "View $name of User $owner"
    } elseif {$type == "CLUSTER"} { 
      set headline $ODv_hlSysClusters
      set form $ODv_fSysClusters
      set query "select object_id, created, status, object_name, owner from sys.dba_objects where object_type = 'CLUSTER' and owner = '$owner' and object_name ='$name'"
      set newtag "sysClusters"
      set message "Cluster $name of User $owner"
    } elseif {$type == "SEQUENCE"} { 
      set headline $ODv_hlSysSequences
      set form $ODv_fSysSequences
      set query "select sequence_name, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from sys.dba_sequences where sequence_owner = '$owner' and sequence_name = '$name'"
      set newtag "sysFind"
      set message "Sequence $name of User $owner"
    } elseif {$type == "DATABASE"} { 
      set headline $ODv_hlSysDBLinks
      set form $ODv_fSysDBLinks
      set query "select username, created, db_link, host  from sys.dba_db_links where owner = '$owner'  and db_link = '$name' order by username, host"
      set newtag "sysFind"
      set message "DBLink $name of User $owner"
    } elseif {$type == "SYNONYM"} {
      set headline $ODv_hlSysSynonyms
      set form $ODv_fSysSynonyms
      set query "select synonym_name, owner, table_owner, table_name,  db_link  from sys.dba_synonyms  where owner = '$owner' and synonym_name = '$name'"
      set newtag "sysSynonyms"
      set message "Synonym $name of User $owner"
    } elseif {$type == "TRIGGER"} { 
      set headline $ODv_hlSysTriggers
      set form $ODv_fSysTriggers
      set query "select trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from sys.dba_triggers where owner = '$owner' and trigger_name = '$name'"
      set newtag "sysTriggers"
      set message "Trigger $name of User $owner"
    }

set oldtag "sysFind"

if {$type == "SEQUENCE"} {
    OD_GenWinSys $headline $form $query $oldtag $newtag $message 1 ".ow_sysFindSequences" } elseif {$type == "DATABASE"} {
    OD_GenWinSys $headline $form $query $oldtag $newtag $message 1 ".ow_sysFindDBLinks"} elseif {($type == "PROCEDURE") || ($type == "PACKAGE")} {OD_ShowSysFindProcedures $oldargs} elseif {$type != ""} {
OD_ShowSys $headline $form $query $oldtag $newtag $message 
		  }
}


# Procedure: OD_ShowSysFindProcedures
proc OD_ShowSysFindProcedures { args} {

global ODv_hlSysProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag
global ODv_fSysProcedures

set args [string trim $args \{\}]
set use  [lindex $args 0]
set name [lindex $args 1]
set li [split $ODv_hlSysProcedures /]
set title  [format "$ODv_fSysProcedures" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct owner, name, type from sys.dba_source where owner = '$use' and name = '$name'  order by owner, name, type"

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysProcedures" @1 @2 @3]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Procedure, Function or Package $name of User $use available"
   return
}

set ODv_sysoldtag "sysFind"
catch {OD_Help_Graph_Modify "sysFind"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_sysfindprocedures "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_sysfindprocedures "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
}
}


##########################################################
# Find All-Objects                                       #
##########################################################

#Procedure to show window .ow_allfindobject
proc OD_ShowWindow.ow_allfindobject { wname title args} {

catch "destroy $wname"
toplevel $wname   -relief {raised}

# Window manager configuration
global ODv_font
wm positionfrom $wname program
wm sizefrom $wname program
wm title $wname $title 



message $wname.mg  -aspect {1000}  -padx {5}  -pady {2}  -relief {ridge}  -text {Find Object, please enter SQL-search-string}
frame $wname.fr_owner  -borderwidth {2}
entry $wname.fr_owner.en_owner  -relief {sunken}
  # bindings
  bind $wname.fr_owner.en_owner <Key-Return> "focus $wname.fr_name.en_name"
label $wname.fr_owner.lb_owner  -text {Owner        }

pack append $wname.fr_owner  $wname.fr_owner.en_owner {right frame e padx 20 pady 20 expand}  $wname.fr_owner.lb_owner {left frame center}

frame $wname.fr_name  -borderwidth {2}
entry $wname.fr_name.en_name  -relief {sunken} 
  # bindings
  bind $wname.fr_name.en_name <Key-Return> "$wname.fr_cmd.bn_find invoke"
label $wname.fr_name.lb_name  -text {Name        }

pack append $wname.fr_name  $wname.fr_name.en_name {right frame e padx 20 pady 20 expand}  $wname.fr_name.lb_name {left frame center}

frame $wname.fr_typelist  -borderwidth {2}
entry $wname.fr_typelist.en_typelist  -relief {sunken}
  # bindings
  bind $wname.fr_typelist.en_typelist <Key-Return> "$wname.fr_cmd.bn_find invoke"
menubutton $wname.fr_typelist.mb_typelist  -menu "$wname.fr_typelist.mb_typelist.m"  -relief {raised}  -text {Typelist}  
menu $wname.fr_typelist.mb_typelist.m

pack append $wname.fr_typelist  $wname.fr_typelist.en_typelist {right frame e padx 20 pady 20 expand}  $wname.fr_typelist.mb_typelist {left frame center}

message $wname.mg_error  -aspect {1500}  -padx {5}  -pady {2}  -text {}
frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_find  -command "OD_AllFind \[$wname.fr_owner.en_owner get\] \[$wname.fr_name.en_name get\] \[$wname.fr_typelist.en_typelist get\] "  -text {Find}
button $wname.fr_cmd.bn_dismiss  -command "destroy $wname"  -text {Dismiss}

pack append $wname.fr_cmd  $wname.fr_cmd.bn_find {left frame center expand fillx}  $wname.fr_cmd.bn_dismiss {left frame center expand fillx}

pack append $wname  $wname.mg {top frame center pady 5 fillx} $wname.fr_owner {top frame center padx 80 pady 10} $wname.fr_name {top frame center} $wname.fr_typelist {top frame center pady 15} $wname.mg_error {top frame center fillx} $wname.fr_cmd {top frame center fillx}

tk_menuBar $wname.fr_typelist $wname.fr_typelist.mb_typelist
$wname.fr_typelist.mb_typelist.m add command -label {Table} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TABLE}"
$wname.fr_typelist.mb_typelist.m add command -label {Index} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {INDEX}"
$wname.fr_typelist.mb_typelist.m add command -label {View} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {VIEW}"
$wname.fr_typelist.mb_typelist.m add command -label {Sequence} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SEQUENCE}"
$wname.fr_typelist.mb_typelist.m add command -label {DB_Link} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {DATABASE LINK}"
$wname.fr_typelist.mb_typelist.m add command -label {Synonym} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SYNONYM}"
$wname.fr_typelist.mb_typelist.m add command -label {Trigger} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TRIGGER}"
$wname.fr_typelist.mb_typelist.m add command -label {Procedure} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PROCEDURE}"
$wname.fr_typelist.mb_typelist.m add command -label {Package} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PACKAGE}"


$wname.fr_owner.en_owner insert end {}
$wname.fr_name.en_name insert end {} 
$wname.fr_typelist.en_typelist insert end {}

}


#Procedure OD_AllFind
proc OD_AllFind {owner name type} {
global ODv_oracursor
global oramsg
global ODv_hlAllObjects
global ODv_wincount
global ODv_windows
global ODv_fAllObjects

set li [split $ODv_hlAllObjects /]
set title [format "$ODv_fAllObjects" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

if {$owner == ""} {set owner "%"}
if {$name == ""} {set name "%"}
if {$type == ""} {
    set query "select owner, object_name, object_type from all_objects where owner like upper('$owner') and object_name like upper('$name') order by owner, object_name"
  } else {
    set query "select owner, object_name, object_type from all_objects where owner like upper('$owner') and object_name like upper('$name') and object_type like upper('$type') order by owner, object_name"
  }

set li ""
OD_Msg "Searching for data..."
orasql $ODv_oracursor $query

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllObjects" @1 @2 @3]}



if {[llength $li] == 0} {
   OD_Msg "No match"
   return
}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if {$ODv_windows == "one"} {
  OD_GenWin .ow_allobject "Matching Ojects" $title 440 310 440x310 $li 1 "Details" OD_ShowAllObjectDetails
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_allobject "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowAllObjectDetails
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowAllObjectDetails
}

}


proc OD_ShowAllObjectDetails { args} {
global ODv_hlAllTables
global ODv_hlAllIndexes
global ODv_hlAllViews
global ODv_hlAllSequences
global ODv_hlAllDBLinks
global ODv_hlAllSynonyms
global ODv_hlAllTriggers
global ODv_hlAllProcedures
global ODv_fAllTables
global ODv_fAllIndexes
global ODv_fAllViews
global ODv_fAllSequences
global ODv_fAllDBLinks
global ODv_fAllSynonyms
global ODv_fAllTriggers
global ODv_fAllProcedures

set oldargs $args
set args [string trim $args \{\}]
set owner [lindex $args 0]
set name [lindex $args 1]
set type [lindex $args 2]

if {$type == "TABLE"} { 
      set headline $ODv_hlAllTables
      set form $ODv_fAllTables
      set query "select object_id, created, status, object_name, owner  from all_objects  where object_type = 'TABLE' and owner = '$owner' and object_name = '$name'"
      set newtag "allTables"
      set message "Table $name of User $owner"
    } elseif {$type == "INDEX"} {
      set headline $ODv_hlAllIndexes
      set form $ODv_fAllIndexes
      set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from all_indexes  where owner = '$owner' and index_name = '$name'"
      set newtag "allIndexes"
      set message "Index $name of User $owner"
    } elseif {$type == "VIEW"} { 
      set headline $ODv_hlAllViews
      set form $ODv_fAllViews
      set query "select object_id, created, status, object_name, owner  from all_objects  where object_type = 'VIEW' and owner = '$owner' and object_name = '$name'" 
      set newtag "allViews"
      set message "View $name of User $owner"
    } elseif {$type == "SEQUENCE"} { 
      set headline $ODv_hlAllSequences
      set form $ODv_fAllSequences
      set query "select sequence_name, sequence_owner, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from all_sequences where sequence_owner = '$owner' and sequence_name = '$name'"
      set newtag "allFind"
      set message "Sequence $name of User $owner"
    } elseif {$type == "DATABASE"} { 
      set headline $ODv_hlAllDBLinks
      set form $ODv_fAllDBLinks
      set query "select username, created, db_link, host  from all_db_links where owner = '$owner'  and db_link = '$name' order by username, host"
      set newtag "allFind"
      set message "DBLink $name of User $owner"
    } elseif {$type == "SYNONYM"} {
      set headline $ODv_hlAllSynonyms
      set form $ODv_fAllSynonyms
      set query "select synonym_name, owner, table_owner, table_name,  db_link  from all_synonyms  where owner = '$owner' and synonym_name = '$name'"
      set newtag "allSynonyms"
      set message "Synonym $name of User $owner"
    } elseif {$type == "TRIGGER"} { 
      set headline $ODv_hlAllTriggers
      set form $ODv_fAllTriggers
      set query "select trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from all_triggers where owner = '$owner' and trigger_name = '$name'"
      set newtag "allTriggers"
      set message "Trigger $name of User $owner"
    }

set oldtag "allFind"

if {$type == "SEQUENCE"} {
    OD_GenWinAll $headline $form $query $oldtag $newtag $message 1 ".ow_allFindSequences" } elseif {$type == "DATABASE"} {
    OD_GenWinAll $headline $form $query $oldtag $newtag $message 1 ".ow_allFindDBLinks"} elseif {($type == "PROCEDURE") || ($type == "PACKAGE")} {OD_ShowAllFindProcedures $oldargs} elseif {$type != ""} {
OD_ShowAll $headline $form $query $oldtag $newtag $message 
		  }
}


# Procedure: OD_ShowAllFindProcedures
proc OD_ShowAllFindProcedures { args} {

global ODv_hlAllProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag
global ODv_fAllProcedures

set args [string trim $args \{\}]
set use  [lindex $args 0]
set name [lindex $args 1]
set li [split $ODv_hlAllProcedures /]
set title  [format "$ODv_fAllProcedures" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct owner, name, type from all_source where owner = '$use' and name = '$name'  order by owner, name, type"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllProcedures" @1 @2 @3]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Procedure, Function or Package $name of User $use available"
   return
}

set ODv_alloldtag "allFind"
catch {OD_Help_Graph_Modify "allFind"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_allfindprocedures "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_allfindprocedures "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Procedure, Function or Package $name of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
}
}

##########################################################
# Find User-Objects                                      #
##########################################################

#Procedure to show window .ow_usrfindobject
proc OD_ShowWindow.ow_usrfindobject { wname title args} {

catch "destroy $wname"
toplevel $wname   -relief {raised}

# Window manager configuration
global ODv_font
wm positionfrom $wname program
wm sizefrom $wname program
wm title $wname $title 



message $wname.mg  -aspect {1000}  -padx {5}  -pady {2}  -relief {ridge}  -text {Find Object, please enter SQL-search-string}

frame $wname.fr_name  -borderwidth {2}
entry $wname.fr_name.en_name  -relief {sunken} 
  # bindings
  bind $wname.fr_name.en_name <Key-Return> "$wname.fr_cmd.bn_find invoke"
label $wname.fr_name.lb_name  -text {Name        }

pack append $wname.fr_name  $wname.fr_name.en_name {right frame e padx 20 pady 20 expand}  $wname.fr_name.lb_name {left frame center}

frame $wname.fr_typelist  -borderwidth {2}
entry $wname.fr_typelist.en_typelist  -relief {sunken}
  # bindings
  bind $wname.fr_typelist.en_typelist <Key-Return> "$wname.fr_cmd.bn_find invoke"
menubutton $wname.fr_typelist.mb_typelist  -menu "$wname.fr_typelist.mb_typelist.m"  -relief {raised}  -text {Typelist}  
menu $wname.fr_typelist.mb_typelist.m

pack append $wname.fr_typelist  $wname.fr_typelist.en_typelist {right frame e padx 20 pady 20 expand}  $wname.fr_typelist.mb_typelist {left frame center}

message $wname.mg_error  -aspect {1500}  -padx {5}  -pady {2}  -text {}
frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_find  -command "OD_UserFind  \[$wname.fr_name.en_name get\] \[$wname.fr_typelist.en_typelist get\] "  -text {Find}
button $wname.fr_cmd.bn_dismiss  -command "destroy $wname"  -text {Dismiss}

pack append $wname.fr_cmd  $wname.fr_cmd.bn_find {left frame center expand fillx}  $wname.fr_cmd.bn_dismiss {left frame center expand fillx}

pack append $wname  $wname.mg {top frame center pady 5 fillx} $wname.fr_name {top frame center} $wname.fr_typelist {top frame center pady 15} $wname.mg_error {top frame center fillx} $wname.fr_cmd {top frame center fillx}

tk_menuBar $wname.fr_typelist $wname.fr_typelist.mb_typelist
$wname.fr_typelist.mb_typelist.m add command -label {Table} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TABLE}"
$wname.fr_typelist.mb_typelist.m add command -label {Index} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {INDEX}"
$wname.fr_typelist.mb_typelist.m add command -label {View} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {VIEW}"
$wname.fr_typelist.mb_typelist.m add command -label {Cluster} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {CLUSTER}"
$wname.fr_typelist.mb_typelist.m add command -label {Sequence} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SEQUENCE}"
$wname.fr_typelist.mb_typelist.m add command -label {DB_Link} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {DATABASE LINK}"
$wname.fr_typelist.mb_typelist.m add command -label {Synonym} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {SYNONYM}"
$wname.fr_typelist.mb_typelist.m add command -label {Trigger} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {TRIGGER}"
$wname.fr_typelist.mb_typelist.m add command -label {Procedure} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PROCEDURE}"
$wname.fr_typelist.mb_typelist.m add command -label {Package} -command "$wname.fr_typelist.en_typelist delete 0 end; $wname.fr_typelist.en_typelist insert 0 {PACKAGE}"


$wname.fr_name.en_name insert end {} 
$wname.fr_typelist.en_typelist insert end {}

}


#Procedure OD_UserFind
proc OD_UserFind {name type} {
global ODv_oracursor
global oramsg
global ODv_hlUsrObjects
global ODv_wincount
global ODv_windows
global ODv_fUsrObjects

set li [split $ODv_hlUsrObjects /]
set title [format "$ODv_fUsrObjects" [lindex $li 0] [lindex $li 1]]

if {$name == ""} {set name "%"}
if {$type == ""} {
    set query "select object_name, object_type from user_objects where object_name like upper('$name') order by object_name"
  } else {
    set query "select object_name, object_type from user_objects where object_name like upper('$name') and object_type like upper('$type') order by object_name"
  }

set li ""
OD_Msg "Searching for data..."
orasql $ODv_oracursor $query

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrObjects" @1 @2]}



if {[llength $li] == 0} {
   OD_Msg "No match"
   return
}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if {$ODv_windows == "one"} {
  OD_GenWin .ow_usrobject "Matching Ojects" $title 440 310 440x310 $li 1 "Details" OD_ShowUserObjectDetails
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_usrobject "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowUserObjectDetails
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Matching Objects" $title 440 310 440x310 $li 1 "Details" OD_ShowUserObjectDetails
}

}


proc OD_ShowUserObjectDetails { args} {
global ODv_hlUsrTables
global ODv_hlUsrIndexes
global ODv_hlUsrViews
global ODv_hlUsrClusters
global ODv_hlUsrSequences
global ODv_hlUsrDBLinks
global ODv_hlUsrSynonyms
global ODv_hlUsrTriggers
global ODv_hlUsrProcedures
global ODv_fUsrTables
global ODv_fUsrIndexes
global ODv_fUsrViews
global ODv_fUsrClusters
global ODv_fUsrSequences
global ODv_fUsrDBLinks
global ODv_fUsrSynonyms
global ODv_fUsrTriggers
global ODv_fUsrProcedures

set oldargs $args
set args [string trim $args \{\}]
set name [lindex $args 0]
set type [lindex $args 1]

if {$type == "TABLE"} { 
      set headline $ODv_hlUsrTables
      set form $ODv_fUsrTables
      set query "select object_id, created, status, object_name  from user_objects  where object_type = 'TABLE' and object_name = '$name'"
      set newtag "usrTables"
      set message "User-Table $name"
    } elseif {$type == "INDEX"} {
      set headline $ODv_hlUsrIndexes
      set form $ODv_fUsrIndexes
      set query "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes  where index_name = '$name'"
      set newtag "usrIndexes"
      set message "User-Index $name"
    } elseif {$type == "VIEW"} { 
      set headline $ODv_hlUsrViews
      set form $ODv_fUsrViews
      set query "select object_id, created, status, object_name from user_objects  where object_type = 'VIEW' and object_name = '$name'" 
      set newtag "usrViews"
      set message "User-View $name"
    } elseif {$type == "CLUSTER"} { 
      set headline $ODv_hlUsrClusters
      set form $ODv_fUsrClusters
      set query "select object_id, created, status, object_name, owner from user_objects where object_type = 'CLUSTER' and object_name ='$name'"
      set newtag "sysClusters"
      set message "User-Cluster $name"
    } elseif {$type == "SEQUENCE"} { 
      set headline $ODv_hlUsrSequences
      set form $ODv_fUsrSequences
      set query "select sequence_name, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from user_sequences where sequence_name = '$name'"
      set newtag "usrFind"
      set message "User-Sequence $name"
    } elseif {$type == "DATABASE"} { 
      set headline $ODv_hlUsrDBLinks
      set form $ODv_fUsrDBLinks
      set query "select username, created, db_link, host  from user_db_links where db_link = '$name' order by username, host"
      set newtag "usrFind"
      set message "User-DBLink $name"
    } elseif {$type == "SYNONYM"} {
      set headline $ODv_hlUsrSynonyms
      set form $ODv_fUsrSynonyms
      set query "select synonym_name, table_owner, table_name,  db_link  from user_synonyms  where synonym_name = '$name'"
      set newtag "usrSynonyms"
      set message "User-Synonym $name"
    } elseif {$type == "TRIGGER"} { 
      set headline $ODv_hlUsrTriggers
      set form $ODv_fUsrTriggers
      set query "select trigger_name, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from user_triggers where trigger_name = '$name'"
      set newtag "usrTriggers"
      set message "User-Trigger $name"
    }

set oldtag "usrFind"

if {$type == "SEQUENCE"} {
    OD_GenWinUser $headline $form $query $oldtag $newtag $message 1 ".ow_usrFindSequences" } elseif {$type == "DATABASE"} {
    OD_GenWinUser $headline $form $query $oldtag $newtag $message 1 ".ow_usrFindDBLinks"} elseif {($type == "PROCEDURE") || ($type == "PACKAGE")} {OD_ShowUserFindProcedures $oldargs} elseif {$type != ""} {
OD_ShowUser $headline $form $query $oldtag $newtag $message 
		  }
}


# Procedure: OD_ShowUserFindProcedures
proc OD_ShowUserFindProcedures { args} {

global ODv_hlUsrProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fUsrProcedures

set args [string trim $args \{\}]
set name [lindex $args 0]
set li [split $ODv_hlUsrProcedures /]
set title  [format "$ODv_fUsrProcedures" [lindex $li 0] [lindex $li 1]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct name, type from user_source where name= '$name'  order by name, type"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrProcedures" @1 @2]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No User-Procedure, Function or Package $name available"
   return
}

set ODv_usroldtag "usrFind"
catch {OD_Help_Graph_Modify "usrFind"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_usrfindprocedures "User-Procedure, Function or Package" $title 400 300 400x300 $li 1  "Source Text" OD_ShowUserProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_usrfindprocedures "User-Procedure, Function or Package $name" $title 400 300 400x300 $li 1  "Source Text" OD_ShowUserProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "User-Procedure, Function or Package $name" $title 400 300 400x300 $li 1  "Source Text" OD_ShowUserProcSource
}
}


