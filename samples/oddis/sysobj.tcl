#########################################################################
# Internal System-Queries                                               #
#########################################################################


################################################
# Following two main procedures of this module #
################################################


proc OD_ShowSys {headline formats query oldtag newtag message args} {

global ODv_oracursor 
global oramsg 
global ODv_windows 
global ODv_wincount 
global ODv_sysoldtag

set li [split $headline /]
set nr_of_columns [llength $li]
set string ""
for {set i 0} {$i < $nr_of_columns} {incr i} {
    set index [lindex $li $i]		
    set string [concat $string $index]
    }
set title [eval format \"$formats\" $string]
set li ""
set string "lappend li \[format \"$formats\""
for {set i 1} {$i <= $nr_of_columns} {incr i} {
    set string [concat $string @$i]
    }
set string [concat $string\]] 

OD_Msg "Searching for data..."
orasql $ODv_oracursor $query
orafetch $ODv_oracursor $string 
set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    set no_message [concat No $message available]
    OD_Msg $no_message
    return
}

set ODv_sysoldtag $oldtag
catch {OD_Help_Graph_Modify $newtag}

set procedure [concat ShowWindow.ow_$newtag]
if {$ODv_windows == "one"} {
  set one_window_name [concat .ow_$newtag]
  $procedure $one_window_name $li $title $message
} elseif {$ODv_windows == "many"} {
if {[llength $args] == 0} {
  set many_windows_name [concat .ow_$oldtag$newtag]
  } else {
  set many_windows_name [lindex $args 0]
  }
  $procedure $many_windows_name $li $title $message
} else {incr ODv_wincount
  $procedure .$ODv_wincount $li $title $message
}
}


proc OD_GenWinSys {headline formats query oldtag newtag message  viewrow_button one_window_name args} {

global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set li [split $headline /]
set nr_of_columns [llength $li]
set string ""
for {set i 0} {$i < $nr_of_columns} {incr i} {
    set index [lindex $li $i]		
    set string [concat $string $index]
    }
set title [eval format \"$formats\" $string]
set li ""
set string "lappend li \[format \"$formats\""
for {set i 1} {$i <= $nr_of_columns} {incr i} {
    set string [concat $string @$i]
    }
set string [concat $string\]] 

OD_Msg "Searching for data..."
orasql $ODv_oracursor $query
orafetch $ODv_oracursor $string 
set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    set no_message [concat No $message available]
    OD_Msg $no_message
    return
}

set ODv_sysoldtag $oldtag
catch {OD_Help_Graph_Modify $newtag}

if {$ODv_windows == "one"} {
  OD_GenWin $one_window_name $message $title 440 310 440x310 $li $viewrow_button
} elseif {$ODv_windows == "many"} {
if {[llength $args] == 0} {
      set many_windows_name [concat .ow_$one_window_name]
    } else {
      set many_windows_name [lindex $args 0]
    }
  OD_GenWin $many_windows_name $message $title 440 310 440x310 $li $viewrow_button
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount $message $title 440 310 440x310 $li $viewrow_button
}
}


###########################
# System-Queries          #
###########################


##############################
# System - User              #
##############################


proc OD_TryShowSysUserList {} {
  set error [catch {OD_ShowSysUserList}]
  if {$error == 1} {OD_Msg "Permission denied"}
}

proc OD_TryShowSysTablespaces {} {
  set error [catch {OD_ShowSysTablespaces}]
  if {$error == 1} {OD_Msg "Permission denied"}
}

proc OD_TryShowSysRoles {} {
  set error [catch {OD_ShowSysRoles}]
  if {$error == 1} {OD_Msg "Permission denied"}
}

proc OD_TryShowSysRollbackSegs {} {
  set error [catch {OD_ShowSysRollbackSegs}]
  if {$error == 1} {OD_Msg "Permission denied"}
}

proc OD_TryShowSysFreeSpaceSum {} {
  set error [catch {OD_ShowSysFreeSpaceSum}]
  if {$error == 1} {OD_Msg "Da Sie sich zum wiederholten Male fuer Dinge interessiert haben, die Sie nichts angehen, sehen wir uns leider gezwungen, Ihnen den Account zu entziehen. "
                    wm iconify .tl_main
                    wm iconify .tl_result
  }
}

proc OD_TryShowSysDataFiles {} {
  set error [catch {OD_ShowSysDataFiles}]
  if {$error == 1} {OD_Msg "Permission denied"}
}


# Regine Kasten
proc OD_TryShowSysDevicesAll {} {
  set error [catch {OD_ShowSysDevicesAll}]
  if {$error == 1} {OD_Msg "Permission denied"}
}


# Regine Kasten
proc OD_TryShowSysDevicesOra {} {
  set error [catch {OD_ShowSysDevicesOra}]
  if {$error == 1} {OD_Msg "Permission denied"}
}


# Regine Kasten
proc OD_TryShowSysDevTables {} {

global ODv_user

   if {[string compare $ODv_user SYS] == 0} {
	ShowWindow.tl_sysdevicetables 
   } else {
	OD_Msg "Permission denied"
   }
}


#######################
# System-UserList     #
#######################


# Procedure: OD_ShowSysUserList
proc OD_ShowSysUserList {} {

global ODv_hlSysUser
global ODv_fSysUser

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysSystem" "sysUser" "User-List"
}


#########################
# System-User-Tables    #
#########################


# Procedure: OD_ShowSysUserTables
proc OD_ShowSysUserTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'TABLE' and owner = '$use'  order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysUser" "sysTables" "Tables of User $use" 
}


# Procedure: OD_ShowSysTableColumns
proc OD_ShowSysTableColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab [lindex $args 3]

set query "select column_name, table_name, owner, data_type, data_length, data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from sys.dba_tab_columns  where owner = '$use'  and table_name = '$tab' order by column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysTables" "sysColumns" "Columns for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableIndexes
proc OD_ShowSysTableIndexes { args} {

global ODv_hlSysIndexes
global ODv_fSysIndexes

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select index_name, owner, table_owner, table_name, table_type, uniqueness, tablespace_name, ini_trans, max_trans,  initial_extent, next_extent,  min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys,  avg_leaf_blocks_per_key, avg_data_blocks_per_key,  clustering_factor, status  from sys.dba_indexes  where owner = '$use' and table_name = '$tab'  order by index_name, table_owner, tablespace_name"

OD_ShowSys $ODv_hlSysIndexes $ODv_fSysIndexes $query "sysTables" "sysIndexes" "Indexes for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableDepViews
proc OD_ShowSysTableDepViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.dba_dependencies d, sys.dba_objects o  where d.referenced_owner = '$use' and d.referenced_name = '$tab'  and d.referenced_type = 'TABLE' and o.object_name = d.name and d.owner = o.owner and o.object_type = 'VIEW'  order by o.owner, o.object_id"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysTables" "sysViews" "Dependent Views for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableClusters
proc OD_ShowSysTableClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name ,o.owner from sys.dba_objects o, sys.dba_tables t where o.object_type = 'CLUSTER' and t.owner = '$use' and t.table_name = '$tab' and t.cluster_name = o.object_name order by o.object_id"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysTables" "sysClusters" "Cluster for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableTablespace
proc OD_ShowSysTableTablespace { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set tab [lindex $args 3]
set use [lindex $args 4]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from sys.dba_tablespaces s, sys.dba_tables t where t.owner = '$use' and t.table_name = '$tab' and t.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysTables" "sysTablespaces" "Tablespace for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableExtents
proc OD_ShowSysTableExtents { args } {

global ODv_hlSysExtents
global ODv_fSysExtents

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use  [lindex $args 4]

set query "select extent_id, segment_name, owner, segment_type, tablespace_name, file_id, block_id, bytes, blocks from sys.dba_extents where owner = '$use' and segment_name = '$tab' order by segment_name, extent_id"

OD_ShowSys $ODv_hlSysExtents $ODv_fSysExtents $query "sysTables" "sysExtents" "Extents for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableSynonyms
proc OD_ShowSysTableSynonyms { args} {

global ODv_hlSysSynonyms
global ODv_fSysSynonyms

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select synonym_name, owner, table_owner, table_name, db_link  from sys.dba_synonyms  where table_owner = '$use' and table_name = '$tab'  order by synonym_name, owner"

OD_ShowSys $ODv_hlSysSynonyms $ODv_fSysSynonyms $query "sysTables" "sysSynonyms" "Synonyms for Table $tab of User $use"
}


# Procedure: OD_ShowSysTableConstraints
proc OD_ShowSysTableConstraints { args} {

global ODv_hlSysConstraints
global ODv_fSysConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use  [lindex $args 4] 

set query "select constraint_name, table_name, owner, constraint_type, r_owner, r_constraint_name, search_condition  from sys.dba_constraints  where owner = '$use' and table_name = '$tab'  order by constraint_name, r_owner, r_constraint_name"

OD_ShowSys $ODv_hlSysConstraints $ODv_fSysConstraints $query "sysTables" "sysConstraints" "Constraints on Table $tab of User $use"
}


# Procedure: OD_ShowSysTableTriggers
proc OD_ShowSysTableTriggers { args} {

global ODv_hlSysTriggers
global ODv_fSysTriggers

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab [lindex $args 3]

set query "select distinct trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from sys.dba_triggers where table_owner = '$use' and table_name = '$tab' order by trigger_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysTriggers $ODv_fSysTriggers $query "sysTables" "sysTriggers" "Triggers on Table $tab of User $use"
}


# Procedure: OD_ShowSysTableRoles
proc OD_ShowSysTableRoles {args} {

global ODv_hlSysTableRoles
global ODv_fSysTableRoles

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use  [lindex $args 4] 

set query "select role, owner, table_name, privilege, grantable from sys.role_tab_privs where owner = '$use' and table_name = '$tab' order by role, privilege"

OD_ShowSys $ODv_hlSysTableRoles $ODv_fSysTableRoles $query "sysTables" "sysRoles" "Roles with Privileges on Table $tab of User $use"
}


# Procedure: OD_ShowSysTableGrants
proc OD_ShowSysTableGrants { args} {

global ODv_hlSysGrants
global ODv_fSysGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from sys.dba_tab_privs  where owner = '$use' and table_name = '$tab'  order by grantor"

OD_ShowSys $ODv_hlSysGrants $ODv_fSysGrants $query "sysTables" "sysGrants" "Grants on Table $tab of User $use"
}


# Procedure: OD_ShowSysTableDetails
proc OD_ShowSysTableDetails { args} {

global ODv_hlSysTableDetails
global ODv_fSysTableDetails

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select tablespace_name, pct_free, pct_used, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, backed_up, num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len, cluster_name from sys.dba_tables where owner = '$use' and table_name = '$tab' order by tablespace_name"

OD_GenWinSys $ODv_hlSysTableDetails $ODv_fSysTableDetails $query "sysTables" "sysTables" "Details for Table $tab of User $use" 1 ".ow_sysTablesDetails"
#Last parameters: viewrow_button and window_names 
}


# Procedure: OD_ShowSysTableComments
proc OD_ShowSysTableComments { args} {

global ODv_hlSysComments
global ODv_fSysComments

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select comments from sys.dba_tab_comments where owner = '$use' and table_name = '$tab' and table_type = 'TABLE' "

OD_GenWinSys $ODv_hlSysComments $ODv_fSysComments $query "sysTables" "sysTables" "Comments for Table $tab of User $use" 0 ".ow_sysComments" ".ow_sysTablesComments"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


# Procedure: OD_ShowSysTableUser
proc OD_ShowSysTableUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 4]
set tab [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTables" "sysUser" "Tableowner of Table $tab"
}


###########################
# System-User-Columns     #
###########################


# Procedure: OD_ShowSysUserColumns
proc OD_ShowSysUserColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select column_name, table_name, owner, data_type, data_length, data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from sys.dba_tab_columns  where owner = '$use' order by table_name, column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysUser" "sysColumns" "Columns for User $use"
}


# Procedure: OD_ShowSysColumnTables
proc OD_ShowSysColumnTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set column [lindex $args 0]
set use [lindex $args 2] 
set tab [lindex $args 1]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_tab_columns c  where o.owner = '$use' and o.object_name = '$tab' and o.object_type = 'TABLE' and c.owner = '$use' and c.table_name = '$tab' and c.column_name = '$column' order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysColumns" "sysTables" "Table for Column $column of User $use"
}


# Procedure: OD_ShowSysColumnIndexes
proc OD_ShowSysColumnIndexes { args} {

global ODv_hlSysIndexes
global ODv_fSysIndexes

set args [string trim $args \{\}]
set column  [lindex $args 0]
set use [lindex $args 2]
set tab [lindex $args 1]

set query "select t.index_name, t.owner, t.table_owner, t.table_name, t.table_type, t.uniqueness, t.tablespace_name, t.ini_trans, t.max_trans, t.initial_extent, t.next_extent, t.min_extents, t.max_extents, t.pct_increase, t.pct_free, t.blevel, t.leaf_blocks, t.distinct_keys, t.avg_leaf_blocks_per_key, t.avg_data_blocks_per_key,  t.clustering_factor, t.status  from sys.dba_indexes t , sys.dba_ind_columns c  where t.owner = '$use' and c.index_owner = '$use' and t.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$column' and t.index_name = c.index_name order by t.index_name, t.table_owner, t.tablespace_name"

OD_ShowSys $ODv_hlSysIndexes $ODv_fSysIndexes $query "sysColumns" "sysIndexes" "Indexes for Table $tab and Column $column of User $use"
}


# Procedure: OD_ShowSysColumnViews
proc OD_ShowSysColumnViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set column [lindex $args 0]
set use [lindex $args 2] 
set viw [lindex $args 1]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_tab_columns c  where o.owner = '$use' and o.object_name = '$viw' and o.object_type = 'VIEW' and c.owner = '$use' and c.table_name = '$viw' and c.column_name = '$column' order by o.object_name"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysColumns" "sysViews" "Views for Column $column of User $use"
}


# Procedure: OD_ShowSysColumnClusterColumns
proc OD_ShowSysColumnClusterColumns { args} {

global ODv_hlSysClusterColumns
global ODv_fSysClusterColumns

set args  [string trim $args \{\}]
set col [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select owner, cluster_name, clu_column_name, table_name, tab_column_name  from sys.dba_clu_columns  where owner = '$use' and tab_column_name = '$col' and table_name = '$tab' order by cluster_name, clu_column_name"

OD_ShowSys $ODv_hlSysClusterColumns $ODv_fSysClusterColumns $query "sysColumns" "sysClusterColumns" "Cluster-Columns for Table $tab and Column $col"
}


# Procedure: OD_ShowSysColumnConstraints
proc OD_ShowSysColumnConstraints { args} {

global ODv_hlSysConstraints
global ODv_fSysConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 1]
set col  [lindex $args 0] 
set use  [lindex $args 2] 

set query "select t.constraint_name, t.table_name, t.owner, t.constraint_type, t.r_owner, t.r_constraint_name, t.search_condition from sys.dba_constraints t, sys.dba_cons_columns c where t.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$col'  order by t.constraint_name, t.r_owner, t.r_constraint_name"

OD_ShowSys $ODv_hlSysConstraints $ODv_fSysConstraints $query "sysColumns" "sysConstraints" "Constraints on Column $col, Table $tab of User $use"
}


# Procedure: OD_ShowSysColumnTriggers
proc OD_ShowSysColumnTriggers { args} {

global ODv_hlSysTriggers
global ODv_fSysTriggers

set args [string trim $args \{\}]
set use  [lindex $args 2]
set column [lindex $args 0]

set query "select distinct t.trigger_name, t.owner, t.table_owner, t.table_name, t.trigger_type, t.triggering_event, t.status, t.referencing_names from sys.dba_triggers t, sys.dba_trigger_cols c where t.table_owner = '$use' and c.table_owner = '$use' and t.trigger_name = c.trigger_name and t.owner = c.trigger_owner and c.column_name = '$column' order by t.trigger_name, t.table_owner, t.table_name"

OD_ShowSys $ODv_hlSysTriggers $ODv_fSysTriggers $query "sysColumns" "sysTriggers" "Triggers on Column $column of User $use"
}


# Procedure: OD_ShowSysColumnGrants
proc OD_ShowSysColumnGrants { args} {

global ODv_hlSysGrants
global ODv_fSysGrants

set args [string trim $args \{\}]
set column  [lindex $args 0]
set use [lindex $args 2]
set tab [lindex $args 1]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from sys.dba_col_privs  where owner = '$use' and table_name = '$tab' and column_name = '$column' order by grantor"

OD_ShowSys $ODv_hlSysGrants $ODv_fSysGrants $query "sysColumns" "sysGrants" "Grants for User $use on Column $column"
}


# Procedure: OD_ShowSysColumnComments
proc OD_ShowSysColumnComments { args} {

global ODv_hlSysComments
global ODv_fSysComments

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab  [lindex $args 1]
set use [lindex $args 2]

set query "select comments from sys.dba_col_comments where owner = '$use' and table_name = '$tab' and column_name = '$column' "

OD_GenWinSys $ODv_hlSysComments $ODv_fSysComments $query "sysColumns" "sysColumns" "Comments for Column $column of User $use" 0 ".ow_sysComments" ".ow_sysColumnsComments"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


# Procedure: OD_ShowSysColumnUser
proc OD_ShowSysColumnUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 2]
set col [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysColumns" "sysUser" "User for Column $col"
}


#############################
# System-User-Indexes       #
#############################


# Procedure: OD_ShowSysUserIndexes
proc OD_ShowSysUserIndexes { args} {

global ODv_hlSysIndexes
global ODv_fSysIndexes

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from sys.dba_indexes  where owner = '$use'  order by index_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysIndexes $ODv_fSysIndexes $query "sysUser" "sysIndexes" "Indexes for User $use"
}


# Procedure: OD_ShowSysIndexTable
proc OD_ShowSysIndexTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set index [lindex $args 0]
set use [lindex $args 1]
set tab [lindex $args 3]
set own [lindex $args 2]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects where object_type = 'TABLE' and owner = '$own' and object_name = '$tab' order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysIndexes" "sysTables" "Tables for Index $index of User $use"
}


# Procedure: OD_ShowSysIndexColumns
proc OD_ShowSysIndexColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 1]
set tab [lindex $args 3] 
set index [lindex $args 0]
set own [lindex $args 2]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from sys.dba_tab_columns t, sys.dba_ind_columns c  where t.owner = '$own'  and c.index_name = '$index' and c.index_owner = '$use' and c.table_name = '$tab' and c.table_owner = '$own' and t.table_name = '$tab' and c.column_name = t.column_name order by column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysIndexes" "sysColumns" "Columns for Index $index of User $use"
}


# Procedure: OD_ShowSysIndexTablespace
proc OD_ShowSysIndexTablespace { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set index [lindex $args 0]
set use [lindex $args 1]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from sys.dba_tablespaces s, sys.dba_indexes i where i.owner = '$use' and i.index_name = '$index' and i.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysIndexes" "sysTablespaces" "Tablespace for Index $index of User $use"
}


# Procedure: OD_ShowSysIndexExtents
proc OD_ShowSysIndexExtents { args } {

global ODv_hlSysExtents
global ODv_fSysExtents

set args [string trim $args \{\}]
set index  [lindex $args 0]
set use  [lindex $args 1]

set query "select extent_id, segment_name, owner, segment_type, tablespace_name, file_id, block_id, bytes, blocks from sys.dba_extents where owner = '$use' and segment_name = '$index' order by segment_name, extent_id"

OD_ShowSys $ODv_hlSysExtents $ODv_fSysExtents $query "sysIndexes" "sysExtents" "Extents for Index $index of User $use"
}


# Procedure: OD_ShowSysIndexUser
proc OD_ShowSysIndexUser { args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set index [lindex $args 0]
set use  [lindex $args 1]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysIndexes" "sysUser" "Indexowner for Index $index" ".ow_sysIndexesUser" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysIndexTableowner
proc OD_ShowSysIndexTableowner { args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set index [lindex $args 0]
set use  [lindex $args 2]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query  "sysIndexes" "sysUser" "Tableowner for Index $index" ".ow_sysIndexesOwner" 
#Last parameter: many_windows_name
}



###########################
# System-User-Views       #
###########################

# Procedure: OD_ShowSysUserViews
proc OD_ShowSysUserViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'VIEW' and owner = '$use'  order by object_name"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysUser" "sysViews" "Views for User $use"
}


# Procedure: OD_ShowSysViewBaseTables
proc OD_ShowSysViewBaseTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_dependencies d where o.owner = d.referenced_owner and o.object_name = d.referenced_name and d.referenced_type = 'TABLE' and d.owner = '$use' and d.name = '$viw'  order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysViews" "sysTables" "Base Tables for View $viw of User $use"
}


# Procedure: OD_ShowSysViewColumns
proc OD_ShowSysViewColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab [lindex $args 3]

set query "select column_name, table_name, owner, data_type, data_length, data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from sys.dba_tab_columns  where owner = '$use'  and table_name = '$tab' order by column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysViews" "sysColumns" "Columns for View $tab of User $use"
}


# Procedure: OD_ShowSysViewBaseViews
proc OD_ShowSysViewBaseViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_dependencies d where o.owner = d.referenced_owner and o.object_name = d.referenced_name and d.referenced_type = 'VIEW' and d.owner = '$use' and d.name = '$viw'  order by o.object_name"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysViews" "sysViews" "Base-Views for View $viw of User $use" ".ow_sysViewsBaseViews" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysViewDepViews
proc OD_ShowSysViewDepViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.dba_dependencies d, sys.dba_objects o  where d.referenced_owner = '$use' and d.referenced_name = '$viw'  and d.referenced_type = 'VIEW' and o.object_name = d.name and d.owner = o.owner and o.object_type = 'VIEW'  order by o.owner, o.object_id"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysViews" "sysViews" "Dependent-Views for View $viw of User $use" ".ow_sysViewsDependentViews" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysViewBaseObjects
proc OD_ShowSysViewBaseObjects { args} {

global ODv_hlSysViewBaseObjects
global ODv_fSysViewBaseObjects

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select referenced_owner, referenced_name, referenced_type from sys.dba_dependencies where owner = '$use' and name = '$viw' order by referenced_name"

OD_GenWinSys $ODv_hlSysViewBaseObjects $ODv_fSysViewBaseObjects $query "sysViews" "sysViews" "Base Objects for View $viw of User $use" 1 ".ow_sysViewsBaseObjects"
#Last parameters: viewrow_button and window_names 
}


# Procedure: OD_ShowSysViewSynonyms
proc OD_ShowSysViewSynonyms { args} {

global ODv_hlSysSynonyms
global ODv_fSysSynonyms

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select synonym_name, owner, table_owner, table_name, db_link  from sys.dba_synonyms  where table_owner = '$use' and table_name = '$viw'  order by synonym_name, owner"

OD_ShowSys $ODv_hlSysSynonyms $ODv_fSysSynonyms $query "sysViews" "sysSynonyms" "Synonyms for View $viw of User $use"
}


# Procedure: OD_ShowSysViewGrants
proc OD_ShowSysViewGrants { args} {

global ODv_hlSysGrants
global ODv_fSysGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from sys.dba_tab_privs  where owner = '$use' and table_name = '$tab'  order by grantor"

OD_ShowSys $ODv_hlSysGrants $ODv_fSysGrants $query "sysViews" "sysGrants" "Grants on View $tab of User $use"
}


# Procedure: OD_ShowSysViewText
proc OD_ShowSysViewText { args} {

global ODv_hlSysViewText
global ODv_fSysViewText

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select text from sys.dba_views where view_name = '$viw' and owner = '$use'"

OD_GenWinSys $ODv_hlSysViewText $ODv_fSysViewText $query "sysViews" "sysViews" "Text for View $viw of User $use" 0 ".ow_sysViewsText" 
#Last parameters: viewrow_button and window_names 
}


# Procedure: OD_ShowSysViewComments
proc OD_ShowSysViewComments { args} {

global ODv_hlSysComments
global ODv_fSysComments

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select comments from sys.dba_tab_comments where owner = '$use' and table_name = '$viw' and table_type = 'VIEW'"

OD_GenWinSys $ODv_hlSysComments $ODv_fSysComments $query "sysViews" "sysViews" "Comments for View $viw of User $use" 0 ".ow_sysComments" ".ow_sysViewsComments"
#Last parameters: viewrow_button and one_window_name and many_windows_name 
}


# Procedure: OD_ShowSysViewUser
proc OD_ShowSysViewUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 4]
set viw [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysViews" "sysUser" "Viewowner of View $viw"
}


#########################
# System-User-Clusters  #
#########################


# Procedure: OD_ShowSysUserClusters
proc OD_ShowSysUserClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select object_id, created, status, object_name, owner from sys.dba_objects where object_type = 'CLUSTER' and owner = '$use' order by object_id"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysUser" "sysClusters" "Clusters of User $use"
}


# Procedure: OD_ShowSysClusterTable
proc OD_ShowSysClusterTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set use  [lindex $args 4]
set clu [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_tables t  where o.object_type = 'TABLE' and t.cluster_name = '$clu' and t.table_name = o.object_name and o.owner = t.owner  order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysClusters" "sysTables" "Tables for Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterClusterColumns
proc OD_ShowSysClusterClusterColumns { args} {

global ODv_hlSysClusterColumns
global ODv_fSysClusterColumns

set args  [string trim $args \{\}]
set clu [lindex $args 3]
set use [lindex $args 4]

set query "select owner, cluster_name, clu_column_name, table_name, tab_column_name  from sys.dba_clu_columns  where owner = '$use' and cluster_name = '$clu'  order by clu_column_name, table_name, tab_column_name"

OD_ShowSys $ODv_hlSysClusterColumns $ODv_fSysClusterColumns $query "sysClusters" "sysClusterColumns" "Cluster-Columns for Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterTablespace
proc OD_ShowSysClusterTablespace { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set clu [lindex $args 3]
set use [lindex $args 4]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from sys.dba_tablespaces s, sys.dba_clusters c  where c.owner = '$use' and c.cluster_name = '$clu' and c.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysClusters" "sysTablespaces" "Tablespace for Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterExtents
proc OD_ShowSysClusterExtents { args } {

global ODv_hlSysExtents
global ODv_fSysExtents

set args [string trim $args \{\}]
set clu  [lindex $args 3]
set use  [lindex $args 4]

set query "select extent_id, segment_name, owner, segment_type, tablespace_name, file_id, block_id, bytes, blocks from sys.dba_extents where owner = '$use' and segment_name = '$clu' order by segment_name, extent_id"

OD_ShowSys $ODv_hlSysExtents $ODv_fSysExtents $query "sysClusters" "sysExtents" "Extents for Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterSynonyms
proc OD_ShowSysClusterSynonyms { args} {

global ODv_hlSysSynonyms
global ODv_fSysSynonyms

set args [string trim $args \{\}]
set clu  [lindex $args 3]
set use [lindex $args 4]

set query "select synonym_name, owner, table_owner, table_name, db_link  from sys.dba_synonyms  where table_owner = '$use' and table_name = '$clu'  order by synonym_name, owner"

OD_ShowSys $ODv_hlSysSynonyms $ODv_fSysSynonyms $query "sysClusters" "sysSynonyms" "Synonyms for Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterDetails
proc OD_ShowSysClusterDetails { args} {

global ODv_hlSysClusterDetails
global ODv_fSysClusterDetails

set args [string trim $args \{\}]
set clu  [lindex $args 3]
set use  [lindex $args 4]

set query "select cluster_name, owner, tablespace_name,  pct_free, pct_used, key_size, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents,  pct_increase, avg_blocks_per_key, cluster_type,  function, hashkeys  from sys.dba_clusters  where owner = '$use' and cluster_name = '$clu'  order by tablespace_name"

OD_GenWinSys $ODv_hlSysClusterDetails $ODv_fSysClusterDetails $query "sysClusters" "sysClusters" "Details for Cluster $clu of User $use" 1 ".ow_sysClustersDetails"
#Last parameters: viewrow_button and window_names 
}


# Procedure: OD_ShowSysClusterUser
proc OD_ShowSysClusterUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 4]
set clu [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysClusters" "sysUser" "Clusterowner for Cluster $clu"
}


##############################
# System-User-ClusterColumns #
##############################


# Procedure: OD_ShowSysClusterColumnRefTable
proc OD_ShowSysClusterColumnRefTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set use  [lindex $args 0]
set tab [lindex $args 3]
set clucol [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o  where o.object_type = 'TABLE' and o.object_name = '$tab' and o.owner = '$use'  order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysClusterColumns" "sysTables" "Tables for ClusterColumn $clucol of User $use"
}


# Procedure: OD_ShowSysClusterColumnRefColumn
proc OD_ShowSysClusterColumnRefColumn { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 0]
set clu [lindex $args 1]
set clucol [lindex $args 2]
set tab [lindex $args 3]
set col [lindex $args 4]

set query "select column_name, table_name, owner, data_type, data_length, data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from sys.dba_tab_columns  where owner = '$use'  and table_name = '$tab' and column_name = '$col' order by column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysClusterColumns" "sysColumns" "Columns for Cluster $clu and Cluster-Column $clucol"
}


# Procedure: OD_ShowSysClusterColumnClusters
proc OD_ShowSysClusterColumnClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set use  [lindex $args 0]
set clu  [lindex $args 1]

set query "select object_id, created, status, object_name, owner from sys.dba_objects where object_type = 'CLUSTER' and owner = '$use' and object_name = '$clu' order by object_id"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysClusterColumns" "sysClusters" "Cluster $clu of User $use"
}


# Procedure: OD_ShowSysClusterColumnUser
proc OD_ShowSysClusterColumnUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 0]
set clu [lindex $args 1]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysClusterColumns" "sysUser" "Clusterowner of Cluster $clu"
}


#################################
# System-User-Tablespaces       #
#################################


# Procedure: OD_ShowSysUserTablespaces
proc OD_ShowSysUserTablespaces { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select distinct t.tablespace_name, t.initial_extent, t.next_extent,  t.min_extents, t.max_extents, t.pct_increase, t.status  from sys.dba_tablespaces t, sys.dba_extents e where e.owner = '$use' and e.tablespace_name = t.tablespace_name order by t.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysUser" "sysTablespaces" "Tablespaces containing Extents of User $use" ".ow_sysUserTablespaces" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysUserDefTablespaces
proc OD_ShowSysUserDefTablespaces { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select t.tablespace_name, t.initial_extent, t.next_extent,  t.min_extents, t.max_extents, t.pct_increase, t.status  from sys.dba_tablespaces t, sys.dba_users u where u.username = '$use' and u.default_tablespace = t.tablespace_name order by t.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysUser" "sysTablespaces" "Default Tablespace for User $use" ".ow_sysUserDefTablespaces" 
#Last parametes: many_windows_name
}


# Procedure: OD_ShowSysUserTempTablespaces
proc OD_ShowSysUserTempTablespaces { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select t.tablespace_name, t.initial_extent, t.next_extent,  t.min_extents, t.max_extents, t.pct_increase, t.status  from sys.dba_tablespaces t, sys.dba_users u where u.username = '$use' and u.temporary_tablespace = t.tablespace_name order by t.tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysUser" "sysTablespaces" "Default Temporary Tablespace for User $use" ".ow_sysUserTempTablespaces" 
#Last parameter: many_windows_name
}


# Look at System-Tablespaces


#################################
# System-User-Extents           #
#################################


# Procedure: OD_ShowSysUserExtents
proc OD_ShowSysUserExtents { args } {

global ODv_hlSysExtents
global ODv_fSysExtents

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select extent_id, segment_name, owner, segment_type, tablespace_name, file_id, block_id, bytes, blocks from sys.dba_extents where owner = '$use' order by segment_name, extent_id"

OD_ShowSys $ODv_hlSysExtents $ODv_fSysExtents $query "sysUser" "sysExtents" "Extents for User $use"
}


# Procedure: OD_ShowSysExtentTables
proc OD_ShowSysExtentTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set use  [lindex $args 2]
set tab  [lindex $args 1]
set ext  [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysExtents" "sysTables" "Table for Extent $ext and Segment $tab of User $use"
}


# Procedure: OD_ShowSysExtentIndexes
proc OD_ShowSysExtentIndexes { args} {

global ODv_hlSysIndexes
global ODv_fSysIndexes

set args [string trim $args \{\}]
set use  [lindex $args 2]
set index  [lindex $args 1]
set ext  [lindex $args 0]

set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from sys.dba_indexes  where owner = '$use' and index_name = '$index' order by index_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysIndexes $ODv_fSysIndexes $query "sysExtents" "sysIndexes" "Indexes for Extent $ext and Segment $index of User $use"
}


# Procedure: OD_ShowSysExtentClusters
proc OD_ShowSysExtentClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set use  [lindex $args 2]
set clu  [lindex $args 1]
set ext  [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'CLUSTER' and owner = '$use' and object_name = '$clu' order by object_name"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysExtents" "sysClusters" "Cluster for Extent $ext and Segment $clu of User $use"
}


# Procedure: OD_ShowSysExtentTablespace
proc OD_ShowSysExtentTablespace { args } {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set args [string trim $args \{\}]
set tablespace [lindex $args 4]
set extent [lindex $args 0]
set segment [lindex $args 3]
set use [lindex $args 2]

set query "select tablespace_name, initial_extent, next_extent, min_extents, max_extents, pct_increase, status  from sys.dba_tablespaces where tablespace_name = '$tablespace'  order by tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysExtents" "sysTablespaces" "Tablespace for Segment $segment and Extent $extent of User $use"
}


# Procedure: OD_ShowSysExtentUser
proc OD_ShowSysExtentUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 2]
set segment [lindex $args 1]
set extent [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysExtents" "sysUser" "Owner of Segment $segment and Extent $extent"
}


#################################
# System-User-Sequences         #
#################################


# Procedure: OD_ShowSysUserSequences
proc OD_ShowSysUserSequences { args} {

global ODv_hlSysSequences
global ODv_fSysSequences

set args [string trim $args \{\}]
set use [lindex $args 0]

set query "select sequence_name, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from sys.dba_sequences where sequence_owner = '$use'  order by sequence_name"

OD_GenWinSys $ODv_hlSysSequences $ODv_fSysSequences $query "sysUser" "sysUser" "Sequences of User $use" 1 ".ow_sysUserSequences" 
#Last parameters: viewrow_button and window_names
}


###############################
# System-User-DB-Links        #
###############################


# Procedure: OD_ShowSysUserDBLinks
proc OD_ShowSysUserDBLinks { args} {

global ODv_hlSysDBLinks
global ODv_fSysDBLinks

set args [string trim $args \{\}]
set use [lindex $args 0]

set query "select username, created, db_link, host  from sys.dba_db_links where owner = '$use'  order by username, host"

OD_GenWinSys $ODv_hlSysDBLinks $ODv_fSysDBLinks $query "sysUser" "sysUser" "DB-Links of User $use" 1 ".ow_sysUserDBLinks" 
#Last parameters: viewrow_button and window_names
}


###############################
# System - User - Synonyms    #
###############################


# Procedure: OD_ShowSysUserSynonyms
proc OD_ShowSysUserSynonyms { args} {

global ODv_hlSysSynonyms
global ODv_fSysSynonyms

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select synonym_name, owner, table_owner, table_name,  db_link  from sys.dba_synonyms  where owner = '$use'  order by synonym_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysSynonyms $ODv_fSysSynonyms $query "sysUser" "sysSynonyms" "Synonyms of User $use"
}


# Procedure: OD_ShowSysSynonymTables
proc OD_ShowSysSynonymTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 3]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o where o.object_type = 'TABLE' and o.owner = '$use' and o.object_name = '$tab' order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysSynonyms" "sysTables" "Table for Synonym $synonym of User $use"
}


# Procedure: OD_ShowSysSynonymViews
proc OD_ShowSysSynonymViews { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 3]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o where o.object_type = 'VIEW' and o.owner = '$use' and o.object_name = '$tab' order by o.object_name"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysSynonyms" "sysViews" "View for Synonym $synonym of User $use"
}


# Procedure: OD_ShowSysSynonymClusters
proc OD_ShowSysSynonymClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 3]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o where o.object_type = 'CLUSTER' and o.owner = '$use' and o.object_name = '$tab' order by o.object_name"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysSynonyms" "sysClusters" "Cluster for Synonym $synonym of User $use"
}


# Procedure: OD_ShowSysSynonymDBLinks
proc OD_ShowSysSynonymDBLinks { args} {

global ODv_hlSysDBLinks
global ODv_fSysDBLinks

set args [string trim $args \{\}]
set use [lindex $args 1]
set link [lindex $args 4]
set synonym [lindex $args 0]

set query "select username, created, db_link, host  from sys.dba_db_links where owner = '$use'  and db_link = '$link' order by username, host"

OD_GenWinSys $ODv_hlSysDBLinks $ODv_fSysDBLinks $query "sysSynonyms" "sysSynonyms" "DB-Link for Synonym $synonym of User $use" 1 ".ow_sysSynonymsDBLinks" 
#Last parameters: viewrow_button and window_names
}


# Procedure: OD_ShowSysSynonymUser
proc OD_ShowSysSynonymUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 1]
set synonym [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysSynonyms" "sysUser" "Synonymowner of Synonym $synonym" ".ow_sysSynonymsOwner"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysSynonymObjectOwner
proc OD_ShowSysSynonymObjectOwner {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set use [lindex $args 2]
set synonym [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysSynonyms" "sysUser" "Objectowner of Synonym $synonym" ".ow_sysSynonymsObjectowner"
#Last parameter: many_windows_name
}


###################################
# System-User-Constraints         #
###################################

# Procedure: OD_ShowSysUserConstraints
proc OD_ShowSysUserConstraints { args} {

global ODv_hlSysConstraints
global ODv_fSysConstraints

set args [string trim $args \{\}]
set use  [lindex $args 0] 

set query "select constraint_name, table_name, owner, constraint_type, r_owner, r_constraint_name, search_condition  from sys.dba_constraints  where owner = '$use'  order by constraint_name, r_owner, r_constraint_name"

OD_ShowSys $ODv_hlSysConstraints $ODv_fSysConstraints $query "sysUser" "sysConstraints" "Constraints of User $use"
}


# Procedure: OD_ShowSysConstraintTable
proc OD_ShowSysConstraintTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set use  [lindex $args 2]
set tab [lindex $args 1]
set con [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysConstraints" "sysTables" "Tables for Constraint $con of User $use"
}


# Procedure: OD_ShowSysConstraintColumns
proc OD_ShowSysConstraintColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set con  [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from sys.dba_tab_columns t, sys.dba_cons_columns c  where c.constraint_name = '$con' and t.owner = '$use' and c.owner = '$use' and c.table_name = t.table_name and t.column_name = c.column_name order by t.column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysConstraints" "sysColumns" "Columns for Table $tab and Constraint $con of User $use"
}


###################################
# System-User-Triggers/Procedures #
###################################


# Procedure: OD_ShowSysUserTriggers
proc OD_ShowSysUserTriggers { args} {

global ODv_hlSysTriggers
global ODv_fSysTriggers

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select distinct trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from sys.dba_triggers where owner = '$use' order by trigger_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysTriggers $ODv_fSysTriggers $query "sysUser" "sysTriggers" "Triggers of User $use"
}


# Procedure: OD_ShowSysTriggerTable
proc OD_ShowSysTriggerTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set tab [lindex $args 3]
set use [lindex $args 2]
set trigger [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from sys.dba_objects  where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysTriggers" "sysTables" "Tables for Trigger $trigger of User $use"
}


# Procedure: OD_ShowSysTriggerColumns
proc OD_ShowSysTriggerColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 2]
set tab [lindex $args 3] 
set own [lindex $args 1]
set trigger [lindex $args 0]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from sys.dba_tab_columns t, sys.dba_trigger_cols c  where t.owner = '$use'  and t.table_name = '$tab' and c.trigger_owner = '$own' and c.trigger_name = '$trigger' and c.table_owner = '$use' and c.table_name = '$tab' and  t.column_name = c.column_name order by t.column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysTriggers" "sysColumns" "Columns for Trigger $trigger of User $use"
}


# Procedure: OD_ShowSysTriggerDesc
proc OD_ShowSysTriggerDesc { args} {

global ODv_hlSysTrigDesc
global ODv_fSysTrigDesc
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlSysTrigDesc /]
set title [format "$ODv_fSysTrigDesc" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select description from sys.dba_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_sysoldtag "sysTriggers"
catch {OD_Help_Graph_Modify "sysTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_systrigdesc "Description for Trigger $trig of User $use" $title 400 300 400x300 $li 0 
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_systrigdesc "Description for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Description for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowSysTriggerWhen
proc OD_ShowSysTriggerWhen { args} {

global ODv_hlSysTrigWhen
global ODv_fSysTrigWhen
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlSysTrigWhen /]
set title [format "$ODv_fSysTrigWhen" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select when_clause from sys.dba_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_sysoldtag "sysTriggers"
catch {OD_Help_Graph_Modify "sysTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_systrigwhen "Trigger When-clause for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_systrigwhen "Trigger When-clause for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Trigger When-clause for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowSysTriggerBody
proc OD_ShowSysTriggerBody { args} {

global ODv_hlSysTrigBody
global ODv_fSysTrigBody
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlSysTrigBody /]
set title [format "$ODv_fSysTrigBody" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select trigger_body from sys.dba_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

orafetch $ODv_oracursor {
   set row @1
   set l [split $row \n]
   foreach r $l {
       lappend li $r
   }
}

OD_Msg "SQL finished, resuls returned"

set ODv_sysoldtag "sysTriggers"
catch {OD_Help_Graph_Modify "sysTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_systrigbody "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_systrigbody "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowSysTriggerUser
proc OD_ShowSysTriggerUser { args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set trigger [lindex $args 0]
set use  [lindex $args 1]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTriggers" "sysUser" "Owner for Trigger $trigger" ".ow_sysTriggersOwner"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysTriggerTableowner
proc OD_ShowSysTriggerTableowner { args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set trigger [lindex $args 0]
set use  [lindex $args 2]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$use' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTriggers" "sysUser" "Tableowner for Trigger $trigger" ".ow_sysTriggersTableowner"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysUserProcedures
proc OD_ShowSysUserProcedures { args} {

global ODv_hlSysProcedures
global ODv_fSysProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set args [string trim $args \{\}]
set use  [lindex $args 0]

set li [split $ODv_hlSysProcedures /]
set title  [format "$ODv_fSysProcedures" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct owner, name, type from sys.dba_source where owner = '$use'  order by owner, name, type"

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysProcedures" @1 @2 @3]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Procedures, Functions or Packages of User $use available"
   return
}

set ODv_sysoldtag "sysUser"
catch {OD_Help_Graph_Modify "sysUser"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_sysuserprocedures "Procedures, Functions and Packages of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_sysuserprocedures "Procedures, Functions and Packages of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Procedures, Functions and Packages of User $use" $title 400 300 400x300 $li 1  "Source Text" OD_ShowSysProcSource
}
}


# Procedure: OD_ShowSysProcSource
proc OD_ShowSysProcSource { args} {

global ODv_hlSysProcSource
global ODv_fSysProcSource
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set args [string trim $args \{\}]
set proc [lindex $args 1]
set use  [lindex $args 0]
set type [lindex $args 2]

set li [split $ODv_hlSysProcSource /]
set title [format "$ODv_fSysProcSource" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select text from sys.dba_source  where owner = '$use' and name = '$proc' order by line"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_sysoldtag "sysUser"
catch {OD_Help_Graph_Modify "sysUser"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_sysuserprocsource "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_sysuserprocsource "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
}
}


#############################
# System-User-Roles         #
#############################


# Procedure: OD_ShowSysUserRoles
proc OD_ShowSysUserRoles { args} {

global ODv_hlSysUserRoles
global ODv_fSysUserRoles

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select granted_role, admin_option, default_role, password_required from sys.dba_role_privs, sys.dba_roles where grantee = '$use' and role = granted_role order by granted_role"

OD_ShowSys $ODv_hlSysUserRoles $ODv_fSysUserRoles $query "sysUser" "sysRoles" "Roles for User $use"
}


# Look at System-Roles


################################
# System-User-Privileges       #
################################


# Procedure: OD_ShowSysUserPrivileges
proc OD_ShowSysUserPrivileges {args} {

global ODv_hlSysPrivileges
global ODv_fSysPrivileges

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select privilege, admin_option from sys.dba_sys_privs where grantee = '$use' order by privilege"

OD_GenWinSys $ODv_hlSysPrivileges $ODv_fSysPrivileges $query "sysUser" "sysUser" "Privileges to User $use" 1 ".ow_sysPrivileges" ".ow_sysUserPrivileges" 
#Last parameters: viewrow_button, one_window_name and many_windows_name
}


#############################
# System-User-Grants        #
#############################


# Procedure: OD_ShowSysUserGrantstoUser
proc OD_ShowSysUserGrantstoUser { args} {

global ODv_hlSysGrants
global ODv_fSysGrants

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select grantee, owner, table_name, grantor, privilege,  grantable from sys.dba_tab_privs  where grantee = '$use'  order by owner, table_name, grantee"

OD_ShowSys $ODv_hlSysGrants $ODv_fSysGrants $query "sysUser" "sysGrants" "Grants to User $use" ".ow_sysUserGrantsto"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysUserGrantsbyUser
proc OD_ShowSysUserGrantsbyUser { args} {

global ODv_hlSysGrants
global ODv_fSysGrants

set args [string trim $args \{\}]
set use  [lindex $args 0]

set query "select grantee, owner, table_name, grantor, privilege,  grantable from sys.dba_tab_privs  where grantor = '$use'  order by owner, table_name, grantee"

OD_ShowSys $ODv_hlSysGrants $ODv_fSysGrants $query "sysUser" "sysGrants" "Grants by User $use" ".ow_sysUserGrantsby"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysGrantsTable
proc OD_ShowSysGrantsTable { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set tab [lindex $args 2]

set query "select object_id, created, status, object_name, owner from sys.dba_objects where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysGrants" "sysTables" "Table for User $use, Grantee   $grantee, Grantor $grantor"
}


# Procedure: OD_ShowSysGrantsColumns
proc OD_ShowSysGrantsColumns { args} {

global ODv_hlSysColumns
global ODv_fSysColumns

set args [string trim $args \{\}]
set use  [lindex $args 1]
set tab [lindex $args 2] 
set grantee [lindex $args 0]
set grantor [lindex $args 3]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from sys.dba_tab_columns t, sys.dba_col_privs g  where t.owner = '$use'  and t.table_name = '$tab' and g.owner = '$use' and g.table_name = '$tab' and g.grantee = '$grantee' and g.grantor = '$grantor' and t.column_name = g.column_name order by t.column_name"

OD_ShowSys $ODv_hlSysColumns $ODv_fSysColumns $query "sysGrants" "sysColumns" "Columns for User $use, Grantee   $grantee, Grantor $grantor"
}

  
# Procedure: OD_ShowSysGrantsView
proc OD_ShowSysGrantsView { args} {

global ODv_hlSysViews
global ODv_fSysViews

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set viw [lindex $args 2]

set query "select object_id, created, status, object_name, owner from sys.dba_objects where object_type = 'VIEW' and owner = '$use' and object_name = '$viw' order by object_name"

OD_ShowSys $ODv_hlSysViews $ODv_fSysViews $query "sysGrants" "sysViews" "View for User $use, Grantee   $grantee, Grantor $grantor"
}


# Procedure: OD_ShowSysGrantsOwner
proc OD_ShowSysGrantsOwner {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set own [lindex $args 1]
set tab [lindex $args 2]
set grantor [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$own' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysGrants" "sysUser" "Owner for Grantee $grantee, Grantor $grantor and Table $tab" ".ow_sysGrantsOwner"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysGrantsGrantor
proc OD_ShowSysGrantsGrantor {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set own [lindex $args 1]
set tab [lindex $args 2]
set grantor [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$grantor' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysGrants" "sysUser" "Grantor for Owner $own, Grantee $grantee and Table $tab" ".ow_sysGrantsGrantor"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysGrantsGrantee
proc OD_ShowSysGrantsGrantee {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set own [lindex $args 1]
set tab [lindex $args 2]
set grantor [lindex $args 3]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where username = '$grantee' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysGrants" "sysUser" "Grantee for Owner $own, Grantor $grantor and Table $tab" ".ow_sysGrantsGrantee"
#Last parameter: many_windows_name
}


##############################
# System - Tablespaces       #
##############################


# Procedure: OD_ShowSysTablespaces
proc OD_ShowSysTablespaces {} {

global ODv_hlSysTablespaces
global ODv_fSysTablespaces

set li [split $ODv_hlSysTablespaces /]
set title [format "$ODv_fSysTablespaces" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6]]

set query "select tablespace_name, initial_extent, next_extent,  min_extents, max_extents, pct_increase, status  from sys.dba_tablespaces order by tablespace_name"

OD_ShowSys $ODv_hlSysTablespaces $ODv_fSysTablespaces $query "sysSystem" "sysTablespaces" "Tablespaces" ".ow_sysSystemTablespaces"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysTablespaceTables
proc OD_ShowSysTablespaceTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set tablespace [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from sys.dba_objects o, sys.dba_tables t where o.object_type = 'TABLE' and t.tablespace_name = '$tablespace' and o.object_name = t.table_name order by o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysTablespaces" "sysTables" "Tables for Tablespace $tablespace"
}


# Procedure: OD_ShowSysTablespaceIndexes
proc OD_ShowSysTablespaceIndexes { args} {

global ODv_hlSysIndexes
global ODv_fSysIndexes

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from sys.dba_indexes  where tablespace_name = '$tablespace'  order by index_name, table_owner, table_name"

OD_ShowSys $ODv_hlSysIndexes $ODv_fSysIndexes $query "sysTablespaces" "sysIndexes" "Indexes for Tablespace $tablespace"
}


# Procedure: OD_ShowSysTablespaceClusters
proc OD_ShowSysTablespaceClusters { args} {

global ODv_hlSysClusters
global ODv_fSysClusters

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.dba_objects o, sys.dba_clusters c where o.object_type = 'CLUSTER' and o.owner = c.owner and o.object_name = c.cluster_name and c.tablespace_name = '$tablespace' order by object_id"

OD_ShowSys $ODv_hlSysClusters $ODv_fSysClusters $query "sysTablespaces" "sysClusters" "Clusters for Tablespace $tablespace"
}


# Procedure: OD_ShowSysTablespaceExtents
proc OD_ShowSysTablespaceExtents { args } {

global ODv_hlSysExtents
global ODv_fSysExtents

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]
set use  [lindex $args 4]

set query "select extent_id, segment_name, owner, segment_type, tablespace_name, file_id, block_id, bytes, blocks from sys.dba_extents where tablespace_name = '$tablespace' order by segment_name, extent_id"

OD_ShowSys $ODv_hlSysExtents $ODv_fSysExtents $query "sysTablespaces" "sysExtents" "Extents for Tablespace $tablespace"
}


# Procedure: OD_ShowSysTablespaceFiles
proc OD_ShowSysTablespaceFiles { args} {

global ODv_hlSysTablespaceFiles
global ODv_fSysTablespaceFiles

set args [string trim $args \{\}]
set tablespace  [lindex $args 0] 

set query "select file_id, bytes, blocks, status, file_name from sys.dba_data_files where tablespace_name = '$tablespace' order by file_name"

OD_GenWinSys $ODv_hlSysTablespaceFiles $ODv_fSysTablespaceFiles $query "sysTablespaces" "sysTablespaces" "Files for Tablespace $tablespace" 1 ".ow_sysTablespacesFiles" 
#Last parameters: viewrow_button and window_names
}


# Procedure: OD_ShowSysTablespaceUserQuotas
proc OD_ShowSysTablespaceUserQuotas { args} {

global ODv_hlSysTablespaceUserQuotas
global ODv_fSysTablespaceUserQuotas

set args [string trim $args \{\}]
set tablespace  [lindex $args 0] 

set query "select username, bytes, max_bytes, blocks, max_blocks from sys.dba_ts_quotas where tablespace_name = '$tablespace' order by username"

OD_GenWinSys $ODv_hlSysTablespaceUserQuotas $ODv_fSysTablespaceUserQuotas $query "sysTablespaces" "sysTablespaces" "Quotas for Tablespace $tablespace" 1 ".ow_sysTablespacesQuotas" 
#Last parameters: viewrow_button and window_names
}


# Procedure: OD_ShowSysTablespaceSegments
proc OD_ShowSysTablespaceSegments { args} {

global ODv_hlSysTablespaceSegments
global ODv_fSysTablespaceSegments

set args [string trim $args \{\}]
set tablespace  [lindex $args 0] 

set query "select owner, segment_name, segment_type, header_file, header_block, bytes, blocks, extents, initial_extent, next_extent, min_extents, max_extents, pct_increase, freelists, freelist_groups from sys.dba_segments where tablespace_name = '$tablespace' order by owner, segment_name, segment_type"

OD_GenWinSys $ODv_hlSysTablespaceSegments $ODv_fSysTablespaceSegments $query "sysTablespaces" "sysTablespaces" "Segments for Tablespace $tablespace" 1 ".ow_sysTablespacesSegments" 
#Last parameters: viewrow_button and window_names
}


# Procedure: OD_ShowSysTablespaceUsers
proc OD_ShowSysTablespaceUsers {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set tablespace [lindex $args 0]

set query "select distinct u.username, u.user_id, u.default_tablespace, u.temporary_tablespace, u.created, u.profile  from sys.dba_users u, sys.dba_extents e where e.tablespace_name = '$tablespace' and e.owner = u.username order by u.username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTablespaces" "sysUser" "Users with Extents in Tablespace $tablespace" ".ow_sysTablespacesUser"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysTablespaceDefUser
proc OD_ShowSysTablespaceDefUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set tablespace [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where default_tablespace = '$tablespace' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTablespaces" "sysUser" "Users with Default Tablespace $tablespace" ".ow_sysTablespacesDefUser"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysTablespaceTempUser
proc OD_ShowSysTablespaceTempUser {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set tablespace [lindex $args 0]

set query "select username, user_id, default_tablespace, temporary_tablespace, created, profile  from sys.dba_users where temporary_tablespace = '$tablespace' order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysTablespaces" "sysUser" "Users with Temporary Tablespace $tablespace" ".ow_sysTablespacesTempUser"
#Last parameter: many_windows_name
}


##############################
# System - Roles             #
##############################


# Procedure: OD_ShowSysRoles
proc OD_ShowSysRoles {} {

global ODv_hlSysRoles
global ODv_fSysRoles

set query "select role, password_required from sys.dba_roles order by role"

OD_ShowSys $ODv_hlSysRoles $ODv_fSysRoles $query "sysSystem" "sysRoles" "Roles"
}


# Procedure: OD_ShowSysRoleUsers
proc OD_ShowSysRoleUsers {args} {

global ODv_hlSysUser
global ODv_fSysUser

set args [string trim $args \{\}]
set role [lindex $args 0]

set query "select u.username, u.user_id, u.default_tablespace, u.temporary_tablespace, u.created, u.profile  from sys.dba_users u, sys.dba_role_privs r where r.granted_role = '$role' and r.grantee = u.username order by username"

OD_ShowSys $ODv_hlSysUser $ODv_fSysUser $query "sysRoles" "sysUser" "Users with Role $role"
}


# Procedure: OD_ShowSysRoleTables
proc OD_ShowSysRoleTables { args} {

global ODv_hlSysTables
global ODv_fSysTables

set args [string trim $args \{\}]
set role  [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.dba_objects o, sys.role_tab_privs r  where o.object_type = 'TABLE' and r.role = '$role' and o.object_name = r.table_name and o.owner = r.owner order by o.owner, o.object_name"

OD_ShowSys $ODv_hlSysTables $ODv_fSysTables $query "sysRoles" "sysTables" "Tables with Privileges granted to  Role $role"
}


# Procedure: OD_ShowSysRoleGrantedRoles
proc OD_ShowSysRoleGrantedRoles { args} {

global ODv_hlSysUserRoles
global ODv_fSysUserRoles

set args [string trim $args \{\}]
set role  [lindex $args 0]

set query "select granted_role, admin_option, default_role, password_required from sys.dba_role_privs, sys.dba_roles where grantee = '$role' and role = granted_role order by granted_role"

OD_ShowSys $ODv_hlSysUserRoles $ODv_fSysUserRoles $query "sysRoles" "sysRoles" "Granted Roles for Role $role" ".ow_sysRolesGrantedRoles"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysRoleGrantedtoRoles
proc OD_ShowSysRoleGrantedtoRoles { args} {

global ODv_hlSysUserRoles
global ODv_fSysUserRoles

set args [string trim $args \{\}]
set role  [lindex $args 0]

set query "select role, admin_option, default_role, password_required from sys.dba_role_privs, sys.dba_roles where granted_role = '$role' and role = grantee order by role"

OD_ShowSys $ODv_hlSysUserRoles $ODv_fSysUserRoles $query "sysRoles" "sysRoles" "Roles to which Role $role is granted" ".ow_sysRolesGrantedtoRoles"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowSysRolePrivileges
proc OD_ShowSysRolePrivileges { args} {

global ODv_hlSysPrivileges
global ODv_fSysPrivileges

set args [string trim $args \{\}]
set rol  [lindex $args 0]

set query "select privilege, admin_option  from role_sys_privs where role = '$rol' order by privilege"

OD_GenWinSys $ODv_hlSysPrivileges $ODv_fSysPrivileges $query "sysRoles" "sysRoles" "Privileges for Role $rol" 1 ".ow_sysPrivileges" ".ow_sysRolesPrivileges" 
#Last parameters: viewrow_button, one_window_name and many_windows_name
}


###############################
# System-RollbackSegments     #
###############################


# Procedure: OD_ShowSysRollbackSegs
proc OD_ShowSysRollbackSegs {} {

global ODv_hlSysRollbackSegs
global ODv_fSysRollbackSegs

set query "select segment_name, owner, tablespace_name,  segment_id, file_id, block_id, initial_extent,  next_extent, min_extents, max_extents, pct_increase,  status, instance_num  from sys.dba_rollback_segs  order by segment_name, owner, tablespace_name"

OD_GenWinSys $ODv_hlSysRollbackSegs $ODv_fSysRollbackSegs $query "sysSystem" "sysSystem" "Rollback Segments" 1 ".ow_sysRollbackSegs"
#Last parameters: viewrow_button and window_names
}


############################
# System-Freespace         #
############################

# Procedure: OD_ShowSysFreeSpaceSum
proc OD_ShowSysFreeSpaceSum {} {

global ODv_hlSysFreeSpaceSum
global ODv_fSysFreeSpaceSum
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_sysoldtag

set li [split $ODv_hlSysFreeSpaceSum /]
set title [format "$ODv_fSysFreeSpaceSum" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select tablespace_name, sum(bytes), sum(blocks), count(*), max(bytes) from sys.dba_free_space group by tablespace_name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysFreeSpaceSum" @1 @2 @3 @4 @5]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Free Space Summary available"
    return
}

set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_sysfreespacesum "Free Space Summary" $title 400 300 400x300 $li 1  Details OD_ShowSysFreeSpaceDetail
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_sysfreespacesum "Free Space Summary" $title 400 300 400x300 $li 1  Details OD_ShowSysFreeSpaceDetail
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Free Space Summary" $title 400 300 400x300 $li 1  Details OD_ShowSysFreeSpaceDetail
}
}


# Procedure: OD_ShowSysFreeSpaceDetail
proc OD_ShowSysFreeSpaceDetail { args} {

global ODv_hlSysFreeSpaceDetail
global ODv_fSysFreeSpaceDetails

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select tablespace_name, file_id, block_id, bytes, blocks from sys.dba_free_space where tablespace_name = '$tablespace'  order by file_id"

OD_GenWinSys $ODv_hlSysFreeSpaceDetail $ODv_fSysFreeSpaceDetails $query "sysSystem" "sysSystem" "Free Space Details for Tablespace $tablespace" 1 ".ow_sysFreeSpaceDetails"
#Last parameters: viewrow_button and window_names
}


##########################
# System-DataFiles       #
##########################


# Procedure: OD_ShowSysDataFiles
proc OD_ShowSysDataFiles {} {

global ODv_hlSysDataFiles
global ODv_fSysDataFiles

set query "select tablespace_name, file_id, bytes, blocks, status,  file_name  from sys.dba_data_files  order by file_id"

OD_GenWinSys $ODv_hlSysDataFiles $ODv_fSysDataFiles $query "sysSystem" "sysSystem" "Data-Files" 1 ".ow_sysDataFiles"
#Last parameters: viewrow_button and window_names
}


###############################
# System-Devices              #
###############################

##########################
# System-Devices-All     #
##########################

# Regine Kasten
# gives information about all mounted Devices 
# Procedure: OD_ShowSysDevicesAll
proc OD_ShowSysDevicesAll {} {

global ODv_sysoldtag
global ODv_windows
global ODv_wincount
global ODv_SysDevAll
global ODv_hlSysDevices
global ODv_fSysDevices


OD_Msg "Searching for data..."

OD_DoSysDevAll

### show results

set li    [split $ODv_hlSysDevices /]
set title [format "$ODv_fSysDevices"  [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6]]

set li ""
foreach elem $ODv_SysDevAll {
 lappend li [format "$ODv_fSysDevices" [lindex $elem 0] [lindex $elem 1] [lindex $elem 2] [lindex $elem 3] [lindex $elem 4] [lindex $elem 5] [lindex $elem 6]]
}

OD_Msg "Read Devices finished"

if  {[llength $li] == 0} {
    OD_Msg "No Devices available" 
    return
}

set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_sysdevicesall .ow_sysdevicesall $li $title "All-Devices"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_sysdevicesall .ow_sysdevicesalldev $li $title "All-Devices"
} else {incr ODv_wincount
  ShowWindow.ow_sysdevicesall .$ODv_wincount $li $title "AllDevices"
}
}


##########################
# System-Devices-Oracle  #
##########################

# Regine Kasten
# gives information about mounted oracle-devices
# Procedure: OD_ShowSysDevicesOra
proc OD_ShowSysDevicesOra {} {

global ODv_oracursor
global oramsg
global ODv_sysoldtag
global ODv_windows
global ODv_wincount
global ODv_hlSysDevices
global ODv_fSysDevices


# show results

set li    [split $ODv_hlSysDevices /]
set title [format "$ODv_fSysDevices"  [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select device_id, fs_system, blocks, used, free, percent, mount from sys.device$ order by device_id"

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysDevices" @1 @2 @3 @4 @5 @6 @7]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Devices available" 
    return
}


set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}


if {$ODv_windows == "one"} {
  ShowWindow.ow_sysdevicesora .ow_sysdevicesora $li $title "Oracle-Devices"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_sysdevicesora .ow_sysdevicesoradev $li $title "Oracle-Devices"
} else {incr ODv_wincount
  ShowWindow.ow_sysdevicesora .$ODv_wincount $li $title "Oracle-Devices"
}


}


##########################
# System-DevicesData     #
##########################

# Regine Kasten
# gives information about oracle-devices and datafiles
# Procedure: OD_ShowSysDevDataFiles
proc OD_ShowSysDevDataFiles { args} {

global ODv_oracursor
global oramsg
global ODv_sysoldtag
global ODv_windows
global ODv_wincount
global ODv_hlSysDevDataFiles
global ODv_fSysDevDataFiles

set args [string trim $args \{\}]
set dev  [lindex $args 0]


# show results

set li    [split $ODv_hlSysDevDataFiles /]
set title [format "$ODv_fSysDevDataFiles"  [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select device_id, tablespace_name, file_id, file_name from sys.device_dfile$ where device_id = $dev order by file_id"

orafetch $ODv_oracursor {lappend li [format "$ODv_fSysDevDataFiles" @1 @2 @3 @4]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Tablespaces of Device available" 
    return
}


set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}


if {$ODv_windows == "one"} {
 OD_GenWin .ow_sysdevdatafiles "Data-Files on Device $dev" $title 400 310 400x310 $li 1
} elseif {$ODv_windows == "many"} {
 OD_GenWin .ow_sysdevdevdatafiles "Data-Files on Device $dev" $title 400 310 400x310 $li 1
} else {incr ODv_wincount
 OD_GenWin .$ODv_wincount "Data-Files on Device $dev" $title 400 310 400x310 $li 1 
}


}






















































































