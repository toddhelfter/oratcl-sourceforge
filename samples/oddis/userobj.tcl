############################################################################
# Internal User-Queries                                                    #
############################################################################


################################################
# Following two main procedures of this module #
################################################


proc OD_ShowUser {headline formats query oldtag newtag message args} {

global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set li [split $headline /]
set nr_of_columns [llength $li]
set string ""
for {set i 0} {$i < $nr_of_columns} {incr i} {
    set index [lindex $li $i]		
    set string [concat $string $index]
    }
set title [eval format \"$formats\" $string]
 
set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor $query

set string "lappend li \[format \"$formats\""
for {set i 1} {$i <= $nr_of_columns} {incr i} {
    set string [concat $string @$i]
    }
set string [concat $string\]] 

orafetch $ODv_oracursor $string 

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    set no_message [concat No $message available]
    OD_Msg $no_message
    return
}

set ODv_usroldtag $oldtag
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


proc OD_GenWinUser {headline formats query oldtag newtag message viewrow_button one_window_name args} {

global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set li [split $headline /]
set nr_of_columns [llength $li]
set string ""
for {set i 0} {$i < $nr_of_columns} {incr i} {
    set index [lindex $li $i]		
    set string [concat $string $index]
    }
set title [eval format \"$formats\" $string]
 
set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor $query

set string "lappend li \[format \"$formats\""
for {set i 1} {$i <= $nr_of_columns} {incr i} {
    set string [concat $string @$i]
    }
set string [concat $string\]] 

orafetch $ODv_oracursor $string 

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    set no_message [concat No $message available]
    OD_Msg $no_message
    return
}

set ODv_usroldtag $oldtag
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
# User-Objects-Queries    #
###########################


#############################
# User-Tables               #
#############################

# Procedure: OD_ShowUserTables
proc OD_ShowUserTables {} {

global ODv_hlUsrTables
global ODv_fUsrTables

set query "select object_id, created, status, object_name from user_objects where object_type = 'TABLE' order by object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrUser" "usrTables" "User-Tables"
}


# Procedure: OD_ShowUserTableColumns
proc OD_ShowUserTableColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select column_name, table_name, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from user_tab_columns  where table_name = '$tab'  order by column_name" 

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrTables" "usrColumns" "User-Columns of Table $tab"
}


# Procedure: OD_ShowUserTableIndexes
proc OD_ShowUserTableIndexes { args} {

global ODv_hlUsrIndexes
global ODv_fUsrIndexes

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes  where table_name = '$tab'  order by index_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrIndexes $ODv_fUsrIndexes $query "usrTables" "usrIndexes" "User-Indexes on Table $tab"
}


# Procedure: OD_ShowUserTableDepViews
proc OD_ShowUserTableDepViews { args} {

global ODv_hlUsrViews
global ODv_fUsrViews
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_dependencies d, user_objects o  where d.referenced_owner = '$ODv_user' and d.referenced_name = '$tab'  and d.referenced_type = 'TABLE' and d.name = o.object_name and o.object_type = 'VIEW'  order by o.object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrTables" "usrViews" "Dependent User-Views on Table $tab"
}


# Procedure: OD_ShowUserTableClusters
proc OD_ShowUserTableClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o, user_tables t where o.object_type = 'CLUSTER' and t.table_name = '$tab' and t.cluster_name = o.object_name order by o.object_id"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrTables" "usrClusters" "User-Cluster for Table $tab"
}


# Procedure: OD_ShowUserTableTablespace
proc OD_ShowUserTableTablespace { args } {

global ODv_hlUsrTablespaces
global ODv_fUsrTablespaces

set args [string trim $args \{\}]
set tab [lindex $args 3]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from user_tablespaces s, user_tables t where t.table_name = '$tab' and t.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowUser $ODv_hlUsrTablespaces $ODv_fUsrTablespaces $query "usrTables" "usrTablespaces" "Tablespace for Table $tab"
}


# Procedure: OD_ShowUserTableExtents
proc OD_ShowUserTableExtents { args } {

global ODv_hlUsrExtents
global ODv_fUsrExtents

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select extent_id, segment_name, segment_type, tablespace_name, bytes, blocks from user_extents where segment_name = '$tab' order by segment_name, extent_id"

OD_ShowUser $ODv_hlUsrExtents $ODv_fUsrExtents $query "usrTables" "usrExtents" "User-Extents for Table $tab"
}


# Procedure: OD_ShowUserTableSynonyms
proc OD_ShowUserTableSynonyms { args} {

global ODv_hlUsrSynonyms
global ODv_fUsrSynonyms
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select synonym_name, table_owner, table_name, db_link  from user_synonyms  where table_owner = '$ODv_user' and table_name = '$tab'  order by synonym_name"

OD_ShowUser $ODv_hlUsrSynonyms $ODv_fUsrSynonyms $query "usrTables" "usrSynonyms" "User-Synonyms for Table $tab"}


# Procedure: OD_ShowUserTableConstraints
proc OD_ShowUserTableConstraints { args} {

global ODv_hlUsrConstraints
global ODv_fUsrConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select constraint_name, table_name, owner, constraint_type, r_owner, r_constraint_name, search_condition from user_constraints  where table_name = '$tab'  order by constraint_name, r_owner, r_constraint_name"

OD_ShowUser $ODv_hlUsrConstraints $ODv_fUsrConstraints $query "usrTables" "usrConstraints" "Constraints on Table $tab"
}


# Procedure: OD_ShowUserTableTriggers
proc OD_ShowUserTableTriggers { args} {

global ODv_hlUsrTriggers
global ODv_fUsrTriggers

set args [string trim $args \{\}]
set tab [lindex $args 3]

set query "select distinct trigger_name, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from user_triggers where table_name = '$tab' order by trigger_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrTriggers $ODv_fUsrTriggers $query "usrTables" "usrTriggers" "User-Triggers on Table $tab"
}


# Procedure: OD_ShowUserTableRoles
proc OD_ShowUserTableRoles {args} {

global ODv_hlUsrTableRoles
global ODv_fUsrTableRoles
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3] 

set query "select role, owner, table_name, privilege, grantable from sys.role_tab_privs where owner = '$ODv_user' and table_name = '$tab' order by role, privilege"

OD_ShowUser $ODv_hlUsrTableRoles $ODv_fUsrTableRoles $query "usrTables" "usrRoles" "Roles with Privileges on Table $tab"
}


# Procedure: OD_ShowUserTableGrants
proc OD_ShowUserTableGrants { args} {

global ODv_hlUsrGrants
global ODv_fUsrGrants
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from user_tab_privs  where owner = '$ODv_user' and table_name = '$tab'  order by grantor,grantee"

OD_ShowUser $ODv_hlUsrGrants $ODv_fUsrGrants $query  "usrTables" "usrGrants" "Grants on Table $tab"
}


# Procedure: OD_ShowUserTableDetails
proc OD_ShowUserTableDetails { args} {

global ODv_hlUsrTableDetails
global ODv_fUsrTableDetails

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select tablespace_name, pct_free, pct_used, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, backed_up, num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len,cluster_name from user_tables where table_name = '$tab' order by tablespace_name"

OD_GenWinUser $ODv_hlUsrTableDetails $ODv_fUsrTableDetails $query "usrTables" "usrTables" "Details of Table $tab" 1 ".ow_usrTablesDetails"
#Last parameters: viewrow_button and many_windows_name 
}


# Procedure: OD_ShowUserTableComments
proc OD_ShowUserTableComments { args} {

global ODv_hlUsrComments
global ODv_fUsrComments

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select comments from user_tab_comments where table_name = '$tab' and table_type = 'TABLE' "

OD_GenWinUser $ODv_hlUsrComments $ODv_fUsrComments $query "usrTables" "usrTables" "User-Comments for Table $tab" 0 ".ow_usrComments" ".ow_usrTablesComments"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


###########################
# User-Columns            #
###########################


# Procedure: OD_ShowUserColumns
proc OD_ShowUserColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set query "select column_name, table_name, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from user_tab_columns  order by table_name, column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrUser" "usrColumns" "User-Columns"
}


# Procedure: OD_ShowUserColumnTables
proc OD_ShowUserColumnTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set column [lindex $args 0]
set tab [lindex $args 1]

set query "select o.object_id, o.created, o.status, o.object_name from user_tab_columns c, user_objects o   where c.table_name = '$tab' and c.column_name = '$column' and o.object_name = '$tab' and o.object_type = 'TABLE' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrColumns" "usrTables" "User-Table of Column $column"
} 


# Procedure: OD_ShowUserColumnIndexes
proc OD_ShowUserColumnIndexes { args} {

global ODv_hlUsrIndexes
global ODv_fUsrIndexes

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab [lindex $args 1]

set query "select t.index_name, t.table_owner, t.table_name, t.table_type, t.uniqueness, t.tablespace_name, t.ini_trans,  t.max_trans, t.initial_extent, t.next_extent, t.min_extents, t.max_extents, t.pct_increase, t.pct_free, t.blevel, t.leaf_blocks,  t.distinct_keys, t.avg_leaf_blocks_per_key, t.avg_data_blocks_per_key, t.clustering_factor, t.status from user_indexes t, user_ind_columns c  where t.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$column' and t.index_name = c.index_name  order by t.index_name, t.table_owner, t.table_name"

OD_ShowUser $ODv_hlUsrIndexes $ODv_fUsrIndexes $query "usrColumns" "usrIndexes" "Indexes on Table $tab and Column $column"
}


# Procedure: OD_ShowUserColumnViews
proc OD_ShowUserColumnViews { args} {

global ODv_hlUsrViews
global ODv_fUsrViews

set args [string trim $args \{\}]
set column [lindex $args 0]
set tab [lindex $args 1] 

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o, user_tab_columns c  where o.object_name = '$tab' and o.object_type = 'VIEW' and  c.table_name = '$tab' and c.column_name = '$column' order by o.object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrColumns" "usrViews" "User-View of Column $column"
}


# Procedure: OD_ShowUserColumnClusterColumns
proc OD_ShowUserColumnClusterColumns { args} {

global ODv_hlUsrClusterColumns
global ODv_fUsrClusterColumns

set args  [string trim $args \{\}]
set col [lindex $args 0]
set tab [lindex $args 1]

set query "select cluster_name, clu_column_name, table_name, tab_column_name  from user_clu_columns  where tab_column_name = '$col' and table_name = '$tab' order by cluster_name, clu_column_name"

OD_ShowUser $ODv_hlUsrClusterColumns $ODv_fUsrClusterColumns $query "usrColumns" "usrClusterColumns" "Cluster-Column for Table $tab and Column $col" 
}


# Procedure: OD_ShowUserColumnConstraints
proc OD_ShowUserColumnConstraints { args} {

global ODv_hlUsrConstraints
global ODv_fUsrConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 1]
set col  [lindex $args 0] 

set query "select t.constraint_name, t.table_name, t.owner, t.constraint_type, t.r_owner, t.r_constraint_name, t.search_condition from user_constraints t, user_cons_columns c where t.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$col'  order by t.constraint_name, t.r_owner, t.r_constraint_name"

OD_ShowUser $ODv_hlUsrConstraints $ODv_fUsrConstraints $query "usrColumns" "usrConstraints" "Constraints on Column $col and  Table $tab"
}


# Procedure: OD_ShowUserColumnTriggers
proc OD_ShowUserColumnTriggers { args} {

global ODv_hlUsrTriggers
global ODv_fUsrTriggers

set args [string trim $args \{\}]
set tab  [lindex $args 1]
set column [lindex $args 0]

set query "select distinct t.trigger_name, t.table_owner, t.table_name, t.trigger_type, t.triggering_event, t.status, t.referencing_names from user_triggers t, user_trigger_cols c where t.table_owner = c.table_owner and t.table_name = '$tab' and c.table_name = '$tab' and t.trigger_name = c.trigger_name and c.column_name = '$column' order by t.trigger_name, t.table_owner, t.table_name"

OD_ShowUser $ODv_hlUsrTriggers $ODv_fUsrTriggers $query "usrColumns" "usrTriggers" "User-Triggers on Column $column"
}


# Procedure: OD_ShowUserColumnGrants
proc OD_ShowUserColumnGrants { args} {

global ODv_hlUsrGrants
global ODv_fUsrGrants
global ODv_user

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab [lindex $args 1]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from user_col_privs where owner = '$ODv_user' and grantee = '$ODv_user' and table_name = '$tab' and column_name = '$column' order by grantor"

OD_ShowUser $ODv_hlUsrGrants $ODv_fUsrGrants $query "usrColumns" "usrGrants" "Grants on Column $column"
}


# Procedure: OD_ShowUserColumnComments
proc OD_ShowUserColumnComments { args} {

global ODv_hlUsrComments
global ODv_fUsrComments

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab  [lindex $args 1]

set query "select comments from user_col_comments where table_name = '$tab' and column_name = '$column' "

OD_GenWinUser $ODv_hlUsrComments $ODv_fUsrComments $query "usrColumns" "usrColumns" "User-Comments for Column $column" 0 ".ow_usrComments" ".ow_usrColumnsComments"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


#############################
# User-Indexes              #
#############################


# Procedure: OD_ShowUserIndexes
proc OD_ShowUserIndexes {} {

global ODv_hlUsrIndexes
global ODv_fUsrIndexes

set query "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes order by index_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrIndexes $ODv_fUsrIndexes $query "usrUser" "usrIndexes" "User-Indexes"
}


# Procedure: OD_ShowUserIndexTable
proc OD_ShowUserIndexTable { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set index [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name from user_indexes i, user_objects o where i.index_name = '$index' and o.object_name = i.table_name and o.object_type = 'TABLE' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrIndexes" "usrTables" "User-Tables related to Index $index" "ShowWindow.ow_usertable" ".ow_usertable" ".ow_userindextable"

#parameters: headline formats query oldtag newtag message procedure one_window_name many_windows_name
}


# Procedure: OD_ShowUserIndexColumns
proc OD_ShowUserIndexColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set index  [lindex $args 0]

set query "select t.column_name, t.table_name, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from user_tab_columns t, user_ind_columns i where i.index_name = '$index' and t.table_name = i.table_name and t.column_name = i.column_name order by t.table_name, t.column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrIndexes" "usrColumns" "User-Columns related to Index $index"
}


# Procedure: OD_ShowUserIndexTablespace
proc OD_ShowUserIndexTablespace { args } {

global ODv_hlUsrTablespaces
global ODv_fUsrTablespaces

set args [string trim $args \{\}]
set index [lindex $args 0]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from user_tablespaces s, user_indexes i where i.index_name = '$index' and i.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowUser $ODv_hlUsrTablespaces $ODv_fUsrTablespaces $query "usrIndexes" "usrTablespaces" "Tablespace for Index $index"
}


# Procedure: OD_ShowUserIndexExtents
proc OD_ShowUserIndexExtents { args } {

global ODv_hlUsrExtents
global ODv_fUsrExtents

set args [string trim $args \{\}]
set index  [lindex $args 0]

set query "select extent_id, segment_name, segment_type, tablespace_name, bytes, blocks from user_extents where segment_name = '$index' order by segment_name, extent_id"

OD_ShowUser $ODv_hlUsrExtents $ODv_fUsrExtents $query "usrIndexes" "usrExtents" "User-Extents for Index $index"
}


#############################
# User-Views                #
#############################


# Procedure: OD_ShowUserViews
proc OD_ShowUserViews {} {

global ODv_hlUsrViews
global ODv_fUsrViews

set query "select object_id, created, status, object_name from user_objects where object_type = 'VIEW' order by object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrUser" "usrViews" "User-Views"
}



# Procedure: OD_ShowUserViewBaseTables
proc OD_ShowUserViewBaseTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables
global ODv_user

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_dependencies d, user_objects o where d.referenced_owner = '$ODv_user' and d.name = '$viw' and d.referenced_type = 'TABLE' and d.referenced_name = o.object_name and o.object_type = 'TABLE' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrViews" "usrTables" "User-Base Tables of View $viw"
}


# Procedure: OD_ShowUserViewColumns
proc OD_ShowUserViewColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select column_name, table_name, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from user_tab_columns  where table_name = '$viw'  order by column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrViews" "usrColumns" "User-Columns of View $viw"
}


# Procedure: OD_ShowUserViewBaseViews
proc OD_ShowUserViewBaseViews { args} {

global ODv_hlUsrViews
global ODv_fUsrViews
global ODv_user

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_dependencies d, user_objects o where d.name = '$viw' and d.referenced_type = 'VIEW' and d.referenced_name = o.object_name and d.referenced_owner = '$ODv_user' and o.object_type = 'VIEW' order by o.object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrViews" "usrViews" "User-Base Views of View $viw" ".ow_usrViewsBaseViews"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowUserViewDepViews
proc OD_ShowUserViewDepViews { args} {

global ODv_hlUsrViews
global ODv_fUsrViews
global ODv_user

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_dependencies d, user_objects o where d.referenced_owner = '$ODv_user' and d.referenced_name = '$viw' and d.referenced_type = 'VIEW' and o.object_name = d.name and o.object_type = 'VIEW' order by o.object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrViews" "usrViews" "User-Dependent Views of View $viw" ".ow_usrViewsDependentViews"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowUserViewBaseObjects
proc OD_ShowUserViewBaseObjects { args} {

global ODv_hlUsrViewBaseObjects
global ODv_fUsrViewBaseObjects

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select referenced_owner, referenced_name, referenced_type from user_dependencies where name = '$viw' order by referenced_name"

OD_GenWinUser $ODv_hlUsrViewBaseObjects $ODv_fUsrViewBaseObjects $query "usrViews" "usrViews" "Base Objects of View $viw" 1 ".ow_usrViewBaseObjects"
#Last parameters: viewrow_button and many_windows_name 
}



# Procedure: OD_ShowUserViewSynonyms
proc OD_ShowUserViewSynonyms { args} {

global ODv_hlUsrSynonyms
global ODv_fUsrSynonyms
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select synonym_name, table_owner, table_name, db_link  from user_synonyms  where table_owner = '$ODv_user' and table_name = '$tab'  order by synonym_name"

OD_ShowUser $ODv_hlUsrSynonyms $ODv_fUsrSynonyms $query "usrViews" "usrSynonyms" "User-Synonyms for View $tab"
}


# Procedure: OD_ShowUserViewGrants
proc OD_ShowUserViewGrants { args} {

global ODv_hlUsrGrants
global ODv_fUsrGrants
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from user_tab_privs  where owner = '$ODv_user' and table_name = '$tab'  order by grantor,grantee"

OD_ShowUser $ODv_hlUsrGrants $ODv_fUsrGrants $query "usrViews" "usrGrants" "Grants on View $tab"
}


# Procedure: OD_ShowUserViewText
proc OD_ShowUserViewText { args} {

global ODv_hlUsrViewText
global ODv_fUsrViewText

set args [string trim $args \{\}]
set viw [lindex $args 3]

set query "select text from user_views  where view_name = '$viw'"

OD_GenWinUser $ODv_hlUsrViewText $ODv_fUsrViewText $query "usrViews" "usrViews" "Text of View $viw" 0 ".ow_usrViewsText"
#Last parameters: viewrow_button and many_windows_name 
}


# Procedure: OD_ShowUserViewComments
proc OD_ShowUserViewComments { args} {

global ODv_hlUsrComments
global ODv_fUsrComments

set args [string trim $args \{\}]
set viw  [lindex $args 3]

set query "select comments from user_tab_comments where table_name = '$viw' and table_type = 'VIEW' "

OD_GenWinUser $ODv_hlUsrComments $ODv_fUsrComments $query "usrViews" "usrViews" "User-Comments for View $viw" 0 ".ow_usrComments" ".ow_usrViewsComments"

#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


#########################
# User-Clusters         #
#########################


# Procedure: OD_ShowUserClusters
proc OD_ShowUserClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set query "select object_id, created, status, object_name from user_objects where object_type = 'CLUSTER' order by object_id"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrUser" "usrClusters" "User-Clusters"
}


# Procedure: OD_ShowUserClusterTable
proc OD_ShowUserClusterTable { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set clu [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name from user_tables t, user_objects o where t.cluster_name = '$clu' and o.object_name = t.table_name and o.object_type = 'TABLE' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrClusters" "usrTables" "User-Tables for Cluster $clu"
} 


# Procedure: OD_ShowUserClusterClusterColumns
proc OD_ShowUserClusterClusterColumns { args} {

global ODv_hlUsrClusterColumns
global ODv_fUsrClusterColumns

set args  [string trim $args \{\}]
set clu [lindex $args 3]

set query "select cluster_name, clu_column_name, table_name, tab_column_name  from user_clu_columns  where cluster_name = '$clu'  order by clu_column_name, table_name, tab_column_name"

OD_ShowUser $ODv_hlUsrClusterColumns $ODv_fUsrClusterColumns $query "usrClusters" "usrClusterColumns" "User-Cluster-Columns for Cluster $clu"
} 


# Procedure: OD_ShowUserClusterTablespace
proc OD_ShowUserClusterTablespace { args } {

global ODv_hlUsrTablespaces
global ODv_fUsrTablespaces

set args [string trim $args \{\}]
set clu [lindex $args 3]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from user_tablespaces s, user_clusters c  where c.cluster_name = '$clu' and c.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowUser $ODv_hlUsrTablespaces $ODv_fUsrTablespaces $query "usrClusters" "usrTablespaces" "Tablespace for Cluster $clu"
} 


# Procedure: OD_ShowUserClusterExtents
proc OD_ShowUserClusterExtents { args } {

global ODv_hlUsrExtents
global ODv_fUsrExtents

set args [string trim $args \{\}]
set clu  [lindex $args 3]

set query "select extent_id, segment_name, segment_type, tablespace_name, bytes, blocks from user_extents where segment_name = '$clu' order by segment_name, extent_id"

OD_ShowUser $ODv_hlUsrExtents $ODv_fUsrExtents $query "usrClusters" "usrExtents" "User-Extents for Cluster $clu"
} 


# Procedure: OD_ShowUserClusterSynonyms
proc OD_ShowUserClusterSynonyms { args} {

global ODv_hlUsrSynonyms
global ODv_fUsrSynonyms
global ODv_user

set args [string trim $args \{\}]
set tab  [lindex $args 3]

set query "select synonym_name, table_owner, table_name, db_link  from user_synonyms  where table_owner = '$ODv_user' and table_name = '$tab'  order by synonym_name"

OD_ShowUser $ODv_hlUsrSynonyms $ODv_fUsrSynonyms $query "usrClusters" "usrSynonyms" "User-Synonyms for Cluster $tab"
} 


# Procedure: OD_ShowUserClusterDetails
proc OD_ShowUserClusterDetails { args} {

global ODv_hlUsrClusterDetails
global ODv_fUsrClusterDetails

set args [string trim $args \{\}]
set clu  [lindex $args 3]

set query "select cluster_name, tablespace_name,  pct_free, pct_used, key_size, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents,  pct_increase, avg_blocks_per_key, cluster_type,  function, hashkeys  from user_clusters  where cluster_name = '$clu'  order by tablespace_name"

OD_GenWinUser $ODv_hlUsrClusterDetails $ODv_fUsrClusterDetails $query "usrClusters" "usrClusters" "Cluster-Details of Cluster $clu" 1 ".ow_usrClustersDetails"

#Last parameters: viewrow_button and many_windows_name 
}


##############################
# User-ClusterColumns        #
##############################


# Procedure: OD_ShowUserClusterColumnRefTables
proc OD_ShowUserClusterColumnRefTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set tab [lindex $args 2]
set clu [lindex $args 0]

set query "select object_id, created, status, object_name from user_objects where object_name = '$tab' and object_type = 'TABLE'"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrClustersColumns" "usrTables" "User-Tables for Cluster $clu"
} 


# Procedure: OD_ShowUserClusterColumnRefColumns
proc OD_ShowUserClusterColumnRefColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set clu [lindex $args 0]
set clucol [lindex $args 1]
set tab [lindex $args 2]
set col [lindex $args 3]

set query "select column_name, table_name, data_type, data_length, data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from user_tab_columns  where table_name = '$tab' and column_name = '$col' order by column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrClustersColumns" "usrColumns" "Column for Cluster $clu and Cluster-Column $clucol"
} 


# Procedure: OD_ShowUserClusterColumnClusters
proc OD_ShowUserClusterColumnClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set args [string trim $args \{\}]
set clu  [lindex $args 0]

set query "select object_id, created, status, object_name from user_objects where object_type = 'CLUSTER' and object_name = '$clu' order by object_id"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrClustersColumns" "usrClusters" "Cluster $clu"
} 


##############################
# User - Tablespaces         #
##############################


# Procedure: OD_ShowUserTablespaces
proc OD_ShowUserTablespaces {} {

global ODv_hlUsrTablespaces
global ODv_fUsrTablespaces

set query "select distinct t.tablespace_name, t.initial_extent, t.next_extent, t.min_extents, t.max_extents, t.pct_increase, t.status  from user_tablespaces t, user_extents e where t.tablespace_name = e.tablespace_name order by tablespace_name"

OD_ShowUser $ODv_hlUsrTablespaces $ODv_fUsrTablespaces $query "usrUser" "usrTablespaces" "Tablespaces with Extents of User"
} 


# Procedure: OD_ShowUserTablespaceTables
proc OD_ShowUserTablespaceTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set tablespacename [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o, user_tables t where o.object_type = 'TABLE' and t.tablespace_name = '$tablespacename' and o.object_name = t.table_name order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrTablespaces" "usrTables" "User-Tables for Tablespace $tablespacename"
}


# Procedure: OD_ShowUserTablespaceIndexes
proc OD_ShowUserTablespaceIndexes { args} {

global ODv_hlUsrIndexes
global ODv_fUsrIndexes

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes  where tablespace_name = '$tablespace'  order by index_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrIndexes $ODv_fUsrIndexes $query "usrTablespaces" "usrIndexes" "User-Indexes for Tablespace $tablespace"
}


# Procedure: OD_ShowUserTablespaceClusters
proc OD_ShowUserTablespaceClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o, user_clusters c where o.object_type = 'CLUSTER' and o.object_name = c.cluster_name and c.tablespace_name = '$tablespace' order by object_id"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrTablespaces" "usrClusters" "User-Clusters for Tablespace $tablespace"
}


# Procedure: OD_ShowUserTablespaceExtents
proc OD_ShowUserTablespaceExtents { args } {

global ODv_hlUsrExtents
global ODv_fUsrExtents

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select extent_id, segment_name, segment_type, tablespace_name, bytes, blocks from user_extents where tablespace_name = '$tablespace' order by segment_name, extent_id"

OD_ShowUser $ODv_hlUsrExtents $ODv_fUsrExtents $query "usrTablespaces" "usrExtents" "User-Extents for Tablespace $tablespace"
}


# Procedure: OD_ShowUserTablespaceUserQuota
proc OD_ShowUserTablespaceUserQuota { args} {

global ODv_hlUsrTablespaceUserQuota
global ODv_fUsrTablespaceUserQuota

set args [string trim $args \{\}]
set tablespace  [lindex $args 0] 

set query "select bytes, max_bytes, blocks, max_blocks from user_ts_quotas where tablespace_name = '$tablespace'"

OD_GenWinUser $ODv_hlUsrTablespaceUserQuota $ODv_fUsrTablespaceUserQuota $query "usrTablespaces" "usrTablespaces" "User-Quota for Tablespace $tablespace" 1 ".ow_usrTablespaceQuotas"
#Last parameters: viewrow_button and many_windows_name 
}


# Procedure: OD_ShowUserTablespaceSegments
proc OD_ShowUserTablespaceSegments { args} {

global ODv_hlUsrTablespaceSegments
global ODv_fUsrTablespaceSegments

set args [string trim $args \{\}]
set tablespace  [lindex $args 0] 

set query "select segment_name, segment_type, bytes, blocks, extents, initial_extent, next_extent, min_extents, max_extents, pct_increase, freelists, freelist_groups from user_segments where tablespace_name = '$tablespace' order by segment_name, segment_type"

OD_GenWinUser $ODv_hlUsrTablespaceSegments $ODv_fUsrTablespaceSegments $query "usrTablespaces" "usrTablespaces" "User-Segments for Tablespace $tablespace" 1 ".ow_usrTablespaceSegments"
#Last parameters: viewrow_button and many_windows_name 
}


#################################
# User - Extents                #
#################################


# Procedure: OD_ShowUserExtents
proc OD_ShowUserExtents { args } {

global ODv_hlUsrExtents
global ODv_fUsrExtents

set query "select extent_id, segment_name, segment_type, tablespace_name, bytes, blocks from user_extents order by segment_name, extent_id"

OD_ShowUser $ODv_hlUsrExtents $ODv_fUsrExtents $query "usrUser" "usrExtents" "User-Extents"
}


# Procedure: OD_ShowUserExtentTables
proc OD_ShowUserExtentTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set tab  [lindex $args 1]
set ext  [lindex $args 0]

set query "select object_id, created, status, object_name from user_objects  where object_type = 'TABLE' and object_name = '$tab' order by object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrExtents" "usrTables" "User-Table for Segment $tab and Extent $ext"
}


# Procedure: OD_ShowUserExtentIndexes
proc OD_ShowUserExtentIndexes { args} {

global ODv_hlUsrIndexes
global ODv_fUsrIndexes

set args [string trim $args \{\}]
set index  [lindex $args 1]
set ext  [lindex $args 0]

set query "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes  where index_name = '$index' order by index_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrIndexes $ODv_fUsrIndexes $query "usrExtents" "usrIndexes" "User-Index for Segment $index and Extent $ext"
}


# Procedure: OD_ShowUserExtentClusters
proc OD_ShowUserExtentClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set args [string trim $args \{\}]
set clu  [lindex $args 1]
set ext  [lindex $args 0]

set query "select object_id, created, status, object_name from user_objects  where object_type = 'CLUSTER' and object_name = '$clu' order by object_name"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrExtents" "usrClusters" "User-Cluster for Segment $clu and Extent $ext"
}


# Procedure: OD_ShowUserExtentTablespace
proc OD_ShowUserExtentTablespace { args } {

global ODv_hlUsrTablespaces
global ODv_fUsrTablespaces

set args [string trim $args \{\}]
set tablespace [lindex $args 3]
set extent [lindex $args 0]
set segment [lindex $args 1]

set query "select tablespace_name, initial_extent, next_extent, min_extents, max_extents, pct_increase, status  from user_tablespaces where tablespace_name = '$tablespace'  order by tablespace_name"

OD_ShowUser $ODv_hlUsrTablespaces $ODv_fUsrTablespaces $query "usrExtents" "usrTablespaces" "Tablespace for Segment $segment and Extent $extent"
} 


#############################
# User-Sequences            #
#############################


# Procedure: OD_ShowUserSequences
proc OD_ShowUserSequences { args} {

global ODv_hlUsrSequences
global ODv_fUsrSequences

set args [string trim $args \{\}]
set use [lindex $args 0]

set query "select sequence_name, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from user_sequences order by sequence_name"

OD_GenWinUser $ODv_hlUsrSequences $ODv_fUsrSequences $query "usrUser" "usrUser" "User-Sequences" 1 ".ow_usrSequences" 
#Last arameters: viewrow_button and many_windows_name 
}


############################
# User-DB-Links            #
############################


# Procedure: OD_ShowUserDBLinks
proc OD_ShowUserDBLinks { args} {

global ODv_hlUsrDBLinks
global ODv_fUsrDBLinks

set query "select username, created, db_link, host  from user_db_links order by username, host"

OD_GenWinUser $ODv_hlUsrDBLinks $ODv_fUsrDBLinks $query "usrUser" "usrUser" "User-DB-Links" 1 ".ow_usrDBLinks" 
#Last arameters: viewrow_button and many_windows_name 
}


###############################
# User - Synonyms             #
###############################


# Procedure: OD_ShowUserSynonyms
proc OD_ShowUserSynonyms { args} {

global ODv_hlUsrSynonyms
global ODv_fUsrSynonyms

set query "select synonym_name, table_owner, table_name,  db_link  from user_synonyms  order by synonym_name, table_owner, table_name"

OD_ShowUser $ODv_hlUsrSynonyms $ODv_fUsrSynonyms $query "usrUser" "usrSynonyms" "User-Synonyms"
}


# Procedure: OD_ShowUserSynonymTables
proc OD_ShowUserSynonymTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o where o.object_type = 'TABLE' and o.object_name = '$tab' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrSynonyms" "usrTables" "User-Table for Synonym $synonym"
}


# Procedure: OD_ShowUserSynonymViews
proc OD_ShowUserSynonymViews { args} {

global ODv_hlUsrViews
global ODv_fUsrViews

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o where o.object_type = 'VIEW' and o.object_name = '$tab' order by o.object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrSynonyms" "usrViews" "User-View for Synonym $synonym"
}


# Procedure: OD_ShowUserSynonymClusters
proc OD_ShowUserSynonymClusters { args} {

global ODv_hlUsrClusters
global ODv_fUsrClusters

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name from user_objects o where o.object_type = 'CLUSTER' and o.object_name = '$tab' order by o.object_name"

OD_ShowUser $ODv_hlUsrClusters $ODv_fUsrClusters $query "usrSynonyms" "usrClusters" "User-Cluster for Synonym $synonym"
}


# Procedure: OD_ShowUserSynonymDBLinks
proc OD_ShowUserSynonymDBLinks { args} {

global ODv_hlUsrDBLinks
global ODv_fUsrDBLinks

set args [string trim $args \{\}]
set link [lindex $args 3]
set synonym [lindex $args 0]

set query "select username, created, db_link, host  from user_db_links where db_link = '$link' order by username, host"

OD_GenWinUser $ODv_hlUsrDBLinks $ODv_fUsrDBLinks $query "usrSynonyms" "usrSynonyms" "User-DB-Link for Synonym $synonym" 1 ".ow_usrSynonymsDBLinks"
#Last arameters: viewrow_button and many_windows_name 
}


#################################
# User-Constraints              #
#################################

# Procedure: OD_ShowUserConstraints
proc OD_ShowUserConstraints { args} {

global ODv_hlUsrConstraints
global ODv_fUsrConstraints


set query "select constraint_name, table_name, owner, constraint_type, r_owner, r_constraint_name, search_condition from user_constraints order by constraint_name, r_owner, r_constraint_name"

OD_ShowUser $ODv_hlUsrConstraints $ODv_fUsrConstraints $query "usrUser" "usrConstraints" "User-Constraints"
}


# Procedure: OD_ShowUserConstraintTable
proc OD_ShowUserConstraintTable { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set tab [lindex $args 1]
set con [lindex $args 0]

set query "select object_id, created, status, object_name  from user_objects  where object_type = 'TABLE' and object_name = '$tab' order by object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrConstraints" "usrTables" "User-Table for Constraint $con"
}


# Procedure: OD_ShowUserConstraintColumns
proc OD_ShowUserConstraintColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set con  [lindex $args 0]
set tab [lindex $args 1]

set query "select t.column_name, t.table_name, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from user_tab_columns t, user_cons_columns c  where c.constraint_name = '$con' and c.table_name = t.table_name and t.column_name = c.column_name order by t.column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrConstraints" "usrColumns" "User-Columns for Table $tab and Constraint $con"
} 


#################################
# User-Triggers/Procedures      #
#################################


# Procedure: OD_ShowUserTriggers
proc OD_ShowUserTriggers {} {

global ODv_hlUsrTriggers
global ODv_fUsrTriggers

set query "select distinct trigger_name, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from user_triggers order by trigger_name, table_name"

OD_ShowUser $ODv_hlUsrTriggers $ODv_fUsrTriggers $query "usrUser" "usrTriggers" "User-Triggers"
} 


# Procedure: OD_ShowUserTriggerTable
proc OD_ShowUserTriggerTable { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set tab [lindex $args 2]
set trigger [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name from user_triggers t, user_objects o where t.table_name = '$tab' and t.trigger_name = '$trigger' and o.object_name = '$tab' and o.object_type = 'TABLE' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrTriggers" "usrTables" "User-Tables related to Trigger $trigger"
}


# Procedure: OD_ShowUserTriggerColumns
proc OD_ShowUserTriggerColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set tab [lindex $args 2] 
set trigger [lindex $args 0]

set query "select t.column_name, t.table_name, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from user_tab_columns t, user_trigger_cols c where t.table_name = '$tab' and c.trigger_name = '$trigger' and c.table_name = '$tab' and  t.column_name = c.column_name order by t.column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrTriggers" "usrColumns" "User-Columns related to Trigger $trigger"
} 


# Procedure: OD_ShowUserTriggerDesc
proc OD_ShowUserTriggerDesc { args} {

global ODv_hlUsrTrigDesc
global ODv_fUsrTrigDesc
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set own  [lindex $args 1]
set tab  [lindex $args 2]

set li [split $ODv_hlUsrTrigDesc /]
set title [format "$ODv_fUsrTrigDesc" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select description from user_triggers where trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "usrTriggers"
catch {OD_Help_Graph_Modify "usrTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_usertrigdesc "Description for Trigger $trig" $title 400 300 400x300 $li 0 
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_usertrigdesc "Description for Trigger $trig" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Description for Trigger $trig" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowUserTriggerWhen
proc OD_ShowUserTriggerWhen { args} {

global ODv_hlUsrTrigWhen
global ODv_fUsrTrigWhen
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set own  [lindex $args 1]
set tab  [lindex $args 2]

set li [split $ODv_hlUsrTrigWhen /]
set title [format "$ODv_fUsrTrigWhen" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select when_clause from user_triggers where trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "usrTriggers"
catch {OD_Help_Graph_Modify "usrTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_usertrigwhen "Trigger When-clause for Trigger $trig" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_usertrigwhen "Trigger When-clause for Trigger $trig" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Trigger When-clause for Trigger $trig" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowUserTriggerBody
proc OD_ShowUserTriggerBody { args} {

global ODv_hlUsrTrigBody
global ODv_fUsrTrigBody
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set own  [lindex $args 1]
set tab  [lindex $args 2]

set li [split $ODv_hlUsrTrigBody /]
set title [format "$ODv_fUsrTrigBody" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select trigger_body from user_triggers where trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

orafetch $ODv_oracursor {
   set row @1
   set l [split $row \n]
   foreach r $l {
       lappend li $r
   }
}

OD_Msg "SQL finished, resuls returned"

set ODv_usroldtag "usrTriggers"
catch {OD_Help_Graph_Modify "usrTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_usertrigbody "Body for Trigger $trig" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_usertrigbody "Body for Trigger $trig" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Body for Trigger $trig" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowUserProcedures
proc OD_ShowUserProcedures {} {

global ODv_hlUsrProcedures
global ODv_fUsrProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set li [split $ODv_hlUsrProcedures /]
set title [format "$ODv_fUsrProcedures" [lindex $li 0] [lindex $li 1]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct name, type from user_source  order by name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrProcedures" @1 @2]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No User-Procedures, Functions or Packages available"
    return
}

set ODv_usroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrUser"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_userprocedures "User-Procedures, Functions and Packages" $title 400 300 400x300 $li 1 "Source Text" OD_ShowUserProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_userprocedures "User-Procedures, Functions and Packages" $title 400 300 400x300 $li 1 "Source Text" OD_ShowUserProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "User-Procedures, Functions and Packages" $title 400 300 400x300 $li 1 "Source Text" OD_ShowUserProcSource
}
}


# Procedure: OD_ShowUserProcSource
proc OD_ShowUserProcSource { args} {

global ODv_hlUsrProcSource
global ODv_fUsrProcSource
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag

set args [string trim $args \{\}]
set proc [lindex $args 0]
set type [lindex $args 1]

set li [split $ODv_hlUsrProcSource /]
set title [format "$ODv_fUsrProcSource" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select text from user_source  where name = '$proc' order by line"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrUser"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_userprocsource "Source Text of $type $proc" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_userprocsource "Source Text of $type $proc" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Source Text of $type $proc" $title 400 300 400x300 $li 0
}
}


##############################
# User - Roles/Privileges    #
##############################


# Procedure: OD_ShowUserRoles
proc OD_ShowUserRoles {} {

global ODv_hlUsrRoles
global ODv_fUsrRoles
global ODv_user

set query "select role from session_roles order by role"

OD_ShowUser $ODv_hlUsrRoles $ODv_fUsrRoles $query "usrUser" "usrRoles" "Available Roles to User $ODv_user"
} 


# Procedure: OD_ShowUserRoleTables
proc OD_ShowUserRoleTables { args} {

global ODv_hlUsrTables
global ODv_fUsrTables
global ODv_user

set args [string trim $args \{\}]
set role  [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name from sys.user_objects o, sys.role_tab_privs r  where o.object_type = 'TABLE' and r.role = '$role' and o.object_name = r.table_name and r.owner = '$ODv_user' order by o.object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrRoles" "usrTables" "User-Tables with Privileges granted to Role $role"
}


# Procedure: OD_ShowUserRolePrivileges
proc OD_ShowUserRolePrivileges { args} {

global ODv_hlUsrRolePrivileges
global ODv_fUsrRolePrivileges

set args [string trim $args \{\}]
set rol  [lindex $args 0]

set query "select privilege, admin_option  from role_sys_privs where role = '$rol' order by privilege"

OD_GenWinUser $ODv_hlUsrRolePrivileges $ODv_fUsrRolePrivileges $query "usrRoles" "usrRoles" "Privileges for Role $rol" 1 "ow_usrPrivileges" ".ow_usrRolePrivileges"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


# Procedure: OD_ShowUserPrivileges
proc OD_ShowUserPrivileges {} {

global ODv_hlUsrPrivileges
global ODv_fUsrPrivileges
global ODv_user

set query "select privilege from session_privs order by privilege"

OD_GenWinUser $ODv_hlUsrPrivileges $ODv_fUsrPrivileges $query "usrUser" "usrUser" "Privileges to User $ODv_user" 0 ".ow_usrPrivileges" ".ow_usrUserPrivileges"
#Last parameters: viewrow_button, one_window_name and many_windows_name 
}


##############################
# User-Grants                #
##############################


# Procedure: OD_ShowUserGrantstoUser
proc OD_ShowUserGrantstoUser { args} {

global ODv_hlUsrGrants
global ODv_fUsrGrants
global ODv_user

set query "select grantee, owner, table_name, grantor, privilege,  grantable from user_tab_privs where grantee = '$ODv_user'  order by owner, table_name, grantee"

OD_ShowUser $ODv_hlUsrGrants $ODv_fUsrGrants $query "usrUser" "usrGrants" "Grants to User" ".ow_usrGrantsto"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowUserGrantsbyUser
proc OD_ShowUserGrantsbyUser { args} {

global ODv_hlUsrGrants
global ODv_fUsrGrants
global ODv_user

set query "select grantee, owner, table_name, grantor, privilege,  grantable from user_tab_privs where grantor = '$ODv_user' order by owner, table_name, grantee"

OD_ShowUser $ODv_hlUsrGrants $ODv_fUsrGrants $query "usrUser" "usrGrants" "Grants by User" ".ow_usrGrantsby"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowUserGrantsTable
proc OD_ShowUserGrantsTable { args} {

global ODv_hlUsrTables
global ODv_fUsrTables

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set tab [lindex $args 2]

set query "select object_id, created, status, object_name from user_objects where object_type = 'TABLE'  and object_name = '$tab' order by object_name"

OD_ShowUser $ODv_hlUsrTables $ODv_fUsrTables $query "usrGrants" "usrTables" "User-Table for Grantee $grantee and Grantor $grantor"
}


# Procedure: OD_ShowUserGrantsColumns
proc OD_ShowUserGrantsColumns { args} {

global ODv_hlUsrColumns
global ODv_fUsrColumns

set args [string trim $args \{\}]
set use  [lindex $args 1]
set tab [lindex $args 2] 
set grantee [lindex $args 0]
set grantor [lindex $args 3]

set query "select t.column_name, t.table_name, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from user_tab_columns t, user_col_privs g  where t.table_name = '$tab' and g.owner = '$use' and g.table_name = '$tab' and g.grantee = '$grantee' and g.grantor = '$grantor' and t.column_name = g.column_name order by t.column_name"

OD_ShowUser $ODv_hlUsrColumns $ODv_fUsrColumns $query "usrGrants" "usrColumns" "User-Columns for Grantee $grantee and Grantor $grantor"
} 


# Procedure: OD_ShowUserGrantsView
proc OD_ShowUserGrantsView { args} {

global ODv_hlUsrViews
global ODv_fUsrViews

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set tab [lindex $args 2]

set query "select object_id, created, status, object_name from user_objects where object_type = 'VIEW'  and object_name = '$tab' order by object_name"

OD_ShowUser $ODv_hlUsrViews $ODv_fUsrViews $query "usrGrants" "usrViews" "User-Views for Grantee $grantee and Grantor $grantor"
}
