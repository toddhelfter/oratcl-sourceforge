#########################################################################
# Internal AllObjects-Queries                                           #
#########################################################################


################################################
# Following two main procedures of this module #
################################################



proc OD_ShowAll {headline formats query oldtag newtag message args} {

global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

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

set ODv_alloldtag $oldtag
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


proc OD_GenWinAll {headline formats query oldtag newtag message viewrow_button one_window_name args} {

global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

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

set ODv_alloldtag $oldtag
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
# AllObjects-Queries      #
###########################


###############################
# AllObjects-Tables           #
###############################


# Procedure: OD_ShowAllTables
proc OD_ShowAllTables {} {

global ODv_hlAllTables
global ODv_fAllTables

set query "select object_id, created, status, object_name, owner from all_objects where object_type = 'TABLE' order by owner, object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allObjects" "allTables" "Accessible Tables"
}


# Procedure: OD_ShowAllTableColumns
proc OD_ShowAllTableColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab  [lindex $args 3]

set query "select column_name, table_name, owner, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from all_tab_columns  where table_name = '$tab' and owner = '$use' order by column_id"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allTables" "allColumns" "Columns for Table $tab of User $use"
}


# Procedure: OD_ShowAllTableIndexes
proc OD_ShowAllTableIndexes { args} {

global ODv_hlAllIndexes
global ODv_fAllIndexes

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select index_name, owner, table_owner, table_name, table_type, uniqueness, tablespace_name, ini_trans, max_trans,  initial_extent, next_extent,  min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys,  avg_leaf_blocks_per_key, avg_data_blocks_per_key,  clustering_factor, status  from all_indexes  where owner = '$use' and table_name = '$tab'  order by index_name, table_owner, tablespace_name"

OD_ShowAll $ODv_hlAllIndexes $ODv_fAllIndexes $query "allTables" "allIndexes" "Indexes for Table $tab of User $use"
}


# Procedure: OD_ShowAllTableDepViews
proc OD_ShowAllTableDepViews { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.all_dependencies d, sys.all_objects o  where d.referenced_owner = '$use' and d.referenced_name = '$tab'  and d.referenced_type = 'TABLE' and d.owner = o.owner and d.name = o.object_name and o.object_type = 'VIEW' order by o.owner, o.object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allTables" "allViews" "Dependent Views for Table $tab of User $use"
}


# Procedure: OD_ShowAllTableTablespace
proc OD_ShowAllTableTablespace { args } {

global ODv_hlAllTablespaces
global ODv_fAllTablespaces

set args [string trim $args \{\}]
set tab [lindex $args 3]
set use [lindex $args 4]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from user_tablespaces s, all_tables t where t.owner = '$use' and t.table_name = '$tab' and t.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowAll $ODv_hlAllTablespaces $ODv_fAllTablespaces $query "allTables" "allTablespaces" "Tablespace for Table $tab of User $use"
}


# Procedure: OD_ShowAllTableSynonyms
proc OD_ShowAllTableSynonyms { args} {

global ODv_hlAllSynonyms
global ODv_fAllSynonyms

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select synonym_name, owner, table_owner, table_name, db_link  from all_synonyms  where table_owner = '$use' and table_name = '$tab'  order by synonym_name, owner"

OD_ShowAll $ODv_hlAllSynonyms $ODv_fAllSynonyms $query "allTables" "allSynonyms" "Synonyms for Table $tab of User $use"
}


# Procedure: OD_ShowAllTableConstraints
proc OD_ShowAllTableConstraints { args} {

global ODv_hlAllConstraints
global ODv_fAllConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use  [lindex $args 4] 

set query "select constraint_name, table_name, owner,constraint_type, r_owner, r_constraint_name, search_condition from all_constraints  where owner = '$use' and table_name = '$tab'  order by constraint_name, r_owner, r_constraint_name"

OD_ShowAll $ODv_hlAllConstraints $ODv_fAllConstraints $query "allTables" "allConstraints" "Constraints on Table $tab of User $use"
}


# Procedure: OD_ShowAllTableTriggers
proc OD_ShowAllTableTriggers { args} {

global ODv_hlAllTriggers
global ODv_fAllTriggers

set args [string trim $args \{\}]
set use  [lindex $args 4]
set tab [lindex $args 3]

set query "select distinct trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from all_triggers where table_owner = '$use' and table_name = '$tab' order by trigger_name, table_owner, table_name"

OD_ShowAll $ODv_hlAllTriggers $ODv_fAllTriggers $query "allTables" "allTriggers" "Triggers on Table $tab of User $use"
}


# Procedure: OD_ShowAllTableGrantsto
proc OD_ShowAllTableGrantsto { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_tab_privs_recd where owner = '$use' and table_name = '$tab'  order by grantee,grantor "

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allTables" "allGrants" "Grants to User/Public on Table $tab of User $use" ".ow_allTablesGrantsto" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllTableGrantsby
proc OD_ShowAllTableGrantsby { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_tab_privs_made  where owner = '$use' and table_name = '$tab'  order by grantee,grantor "

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allTables" "allGrants" "Grants by User on Table $tab of User $use" ".ow_allTablesGrantsby" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllTableDetails
proc OD_ShowAllTableDetails { args} {

global ODv_hlAllTableDetails
global ODv_fAllTableDetails

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select tablespace_name, pct_free, pct_used, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, backed_up, num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len,cluster_name from all_tables where owner = '$use' and table_name = '$tab' order by tablespace_name"

OD_GenWinAll $ODv_hlAllTableDetails $ODv_fAllTableDetails $query "allTables" "allTables" "Details of Table $tab of User $use" 1 ".ow_allTablesDetails"
#Last parameters: viewrow_button and window_name 
}


# Procedure: OD_ShowAllTableComments
proc OD_ShowAllTableComments { args} {

global ODv_hlAllComments
global ODv_fAllComments

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select comments from all_tab_comments where owner = '$use' and table_name = '$tab' and table_type = 'TABLE' "

OD_GenWinAll $ODv_hlAllComments $ODv_fAllComments $query "allTables" "allTables" "Comments for Table $tab of User $use" 0 ".ow_allComments" ".ow_allTableComments"
#Last parameters: viewrow_button,one_window_name and many_windows_name 
}


###############################
# AllObjects-Columns          #
###############################


# Procedure: OD_ShowAllColumns
proc OD_ShowAllColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set query "select column_name, table_name, owner, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from all_tab_columns  order by owner, table_name, column_name"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allObjects" "allColumns" "Accessible Columns"
}


# Procedure: OD_ShowAllColumnTables
proc OD_ShowAllColumnTables { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set column [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from all_tab_columns c, all_objects o where c.owner = '$use' and c.table_name = '$tab' and c.column_name = '$column' and o.object_name = '$tab' and o.owner = '$use' and o.object_type = 'TABLE' order by c.table_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allColumns" "allTables" "Table for Column $column of User $use"
}


# Procedure: OD_ShowAllColumnIndexes
proc OD_ShowAllColumnIndexes { args} {

global ODv_hlAllIndexes
global ODv_fAllIndexes

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select i.index_name, i.owner, i.table_owner, i.table_name, i.table_type, i.uniqueness, i.tablespace_name, i.ini_trans, i.max_trans, i.initial_extent, i.next_extent, i.min_extents, i.max_extents, i.pct_increase, i.pct_free, i.blevel, i.leaf_blocks, i.distinct_keys, i.avg_leaf_blocks_per_key, i.avg_data_blocks_per_key, i.clustering_factor, i.status  from all_indexes i, all_ind_columns c where i.owner = '$use' and c.index_owner = '$use' and i.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$column' and i.index_name = c.index_name order by i.index_name, i.table_owner, i.tablespace_name"

OD_ShowAll $ODv_hlAllIndexes $ODv_fAllIndexes $query "allColumns" "allIndexes" "Indexes for Table $tab and Column $column of User $use"
}


# Procedure: OD_ShowAllColumnViews
proc OD_ShowAllColumnViews { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set column [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from all_objects o, all_tab_columns c  where c.owner = '$use' and c.table_name = '$tab' and c.column_name = '$column' and o.object_name = '$tab' and o.owner = '$use' and o.object_type = 'VIEW' order by o.object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allColumns" "allViews" "View for Column $column of User $use"
}


# Procedure: OD_ShowAllColumnConstraints
proc OD_ShowAllColumnConstraints { args} {

global ODv_hlAllConstraints
global ODv_fAllConstraints

set args [string trim $args \{\}]
set tab  [lindex $args 1]
set col  [lindex $args 0] 
set use  [lindex $args 2] 

set query "select t.constraint_name, t.table_name, t.owner, t.constraint_type, t.r_owner, t.r_constraint_name, t.search_condition from all_constraints t, all_cons_columns c where t.table_name = '$tab' and c.table_name = '$tab' and c.column_name = '$col'  order by t.constraint_name, t.r_owner, t.r_constraint_name"

OD_ShowAll $ODv_hlAllConstraints $ODv_fAllConstraints $query "allColumns" "allConstraints" "Constraints on Column $col, Table $tab of User $use"
}


# Procedure: OD_ShowAllColumnTriggers
proc OD_ShowAllColumnTriggers { args} {

global ODv_hlAllTriggers
global ODv_fAllTriggers

set args [string trim $args \{\}]
set use  [lindex $args 2]
set tab  [lindex $args 1]
set column [lindex $args 0]

set query "select distinct t.trigger_name, t.owner, t.table_owner, t.table_name, t.trigger_type, t.triggering_event, t.status, t.referencing_names from all_triggers t, all_trigger_cols c where t.table_owner = '$use' and c.table_owner = '$use' and t.table_name = '$tab' and c.table_name = '$tab' and t.trigger_name = c.trigger_name and t.owner = c.trigger_owner and c.column_name = '$column' order by t.trigger_name, t.table_owner, t.table_name"

OD_ShowAll $ODv_hlAllTriggers $ODv_fAllTriggers $query "allColumns" "allTriggers" "Triggers on Column $column, Table $tab of User $use"
}


# Procedure: OD_ShowAllColumnGrantsto
proc OD_ShowAllColumnGrantsto { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_col_privs_recd  where owner = '$use' and table_name = '$tab' and column_name = '$column' order by grantee"

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allColumns" "allGrants" "Grants to User/Public on Column $column" ".ow_allColumnsGrantsto" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllColumnGrantsby
proc OD_ShowAllColumnGrantsby { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set column  [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_col_privs_made  where owner = '$use' and table_name = '$tab' and column_name = '$column' order by grantee"

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allColumns" "allGrants" "Grants by User on Column $column" ".ow_allColumnsGrantsby" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllColumnComments
proc OD_ShowAllColumnComments { args} {

global ODv_hlAllComments
global ODv_fAllComments

set args [string trim $args \{\}]
set column [lindex $args 0]
set tab  [lindex $args 1]
set use [lindex $args 2]

set query "select comments from all_col_comments where column_name = '$column' and owner = '$use' and table_name = '$tab' "

OD_GenWinAll $ODv_hlAllComments $ODv_fAllComments $query "allColumns" "allColumns" "Comments for Column $column of User $use" 0 ".ow_allComments" ".ow_allColumnsComments"
}


###############################
# AllObjects-Indexes          #
###############################


# Procedure: OD_ShowAllIndexes
proc OD_ShowAllIndexes {} {

global ODv_hlAllIndexes
global ODv_fAllIndexes

set query "select i.index_name, i.owner, i.table_owner, i.table_name, i.table_type, i.uniqueness, i.tablespace_name, i.ini_trans, i.max_trans, i.initial_extent, i.next_extent, i.min_extents, i.max_extents, i.pct_increase, i.pct_free, i.blevel, i.leaf_blocks, i.distinct_keys, i.avg_leaf_blocks_per_key, i.avg_data_blocks_per_key, i.clustering_factor, i.status  from all_indexes i order by i.owner, i.index_name, i.table_owner, i.tablespace_name"

OD_ShowAll $ODv_hlAllIndexes $ODv_fAllIndexes $query "allObjects" "allIndexes" "Accessible Indexes" 
}


# Procedure: OD_ShowAllIndexTable
proc OD_ShowAllIndexTable { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set index [lindex $args 0]
set use [lindex $args 2]
set tab [lindex $args 3]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from all_indexes i, all_objects o where i.owner = '$use' and i.index_name = '$index' and o.owner = i.table_owner and i.table_name = o.object_name and o.object_type = 'TABLE' order by o.object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allIndexes" "allTables" "Tables for Index $index of User $use"
}


# Procedure: OD_ShowAllIndexColumns
proc OD_ShowAllIndexColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set use  [lindex $args 1]
set index  [lindex $args 0]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length,  t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from all_tab_columns t, all_ind_columns i  where i.index_name = '$index' and i.index_owner = '$use' and t.table_name = i.table_name and t.owner = i.table_owner and t.column_name = i.column_name order by t.owner, t.table_name, t.column_name"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allIndexes" "allColumns" "Columns for Index $index of User $use"
}


# Procedure: OD_ShowAllIndexTablespace
proc OD_ShowAllIndexTablespace { args } {

global ODv_hlAllTablespaces
global ODv_fAllTablespaces

set args [string trim $args \{\}]
set index [lindex $args 0]
set use [lindex $args 1]

set query "select s.tablespace_name, s.initial_extent, s.next_extent,  s.min_extents, s.max_extents, s.pct_increase, s.status  from user_tablespaces s, all_indexes i where i.owner = '$use' and i.index_name = '$index' and i.tablespace_name = s.tablespace_name  order by s.tablespace_name"

OD_ShowAll $ODv_hlAllTablespaces $ODv_fAllTablespaces $query "allIndexes" "allTablespaces" "Tablespace for Index $index of User $use"
}


###############################
# AllObjects-Views            #
###############################


# Procedure: OD_ShowAllViews
proc OD_ShowAllViews {} {

global ODv_hlAllViews
global ODv_fAllViews

set query "select object_id, created, status, object_name, owner from sys.all_objects where object_type = 'VIEW' order by owner, object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allObjects" "allViews" "Accessible Views"
}


# Procedure: OD_ShowAllViewBaseTables
proc OD_ShowAllViewBaseTables { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from all_dependencies d, all_objects o where d.owner = '$use' and d.name = '$viw' and d.referenced_type = 'TABLE' and d.referenced_owner = o.owner and d.referenced_name = o.object_name and o.object_type = 'TABLE' order by o.object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allViews" "allTables" "Base-Tables for View $viw of User $use"
}


# Procedure: OD_ShowAllViewColumns
proc OD_ShowAllViewColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set use  [lindex $args 4]
set viw  [lindex $args 3]

set query "select column_name, table_name, owner, data_type, data_length,  data_precision, data_scale, nullable, column_id, default_length, data_default, num_distinct, low_value, high_value from all_tab_columns  where table_name = '$viw' and owner = '$use' order by column_id"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allViews" "allColumns" "Columns for View $viw of User $use"
}


# Procedure: OD_ShowAllViewBaseViews
proc OD_ShowAllViewBaseViews { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.all_dependencies d, sys.all_objects o where d.owner = '$use' and d.name = '$viw' and d.referenced_type = 'VIEW' and o.owner = d.referenced_owner and o.object_name = d.referenced_name and o.object_type = 'VIEW' order by o.owner, o.object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allViews" "allViews" "Base-Views for View $viw of User $use" ".ow_allViewsBaseViews" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllViewDepViews
proc OD_ShowAllViewDepViews { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from sys.all_dependencies d, sys.all_objects o where d.referenced_owner = '$use' and d.referenced_name = '$viw' and d.referenced_type = 'VIEW' and o.owner = d.owner and o.object_name = d.name and o.object_type = 'VIEW' order by o.owner, o.object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allViews" "allViews" "Dependent-Views for View $viw of User $use" ".ow_allViewsDependentViews" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllViewBaseObjects
proc OD_ShowAllViewBaseObjects { args} {

global ODv_hlAllViewBaseObjects
global ODv_fAllViewBaseObjects

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select referenced_owner, referenced_name, referenced_type from all_dependencies where owner = '$use' and name = '$viw' order by referenced_name"

OD_GenWinAll $ODv_hlAllViewBaseObjects $ODv_fAllViewBaseObjects $query "allViews" "allViews" "Base Objects for View $viw of User $use" 1 ".ow_allViewsBaseObjects"
#Last parameters: viewrow_button and many_windows_name 
}


# Procedure: OD_ShowAllViewSynonyms
proc OD_ShowAllViewSynonyms { args} {

global ODv_hlAllSynonyms
global ODv_fAllSynonyms

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select synonym_name, owner, table_owner, table_name, db_link  from all_synonyms  where table_owner = '$use' and table_name = '$tab'  order by synonym_name, owner"

OD_ShowAll $ODv_hlAllSynonyms $ODv_fAllSynonyms $query "allViews" "allSynonyms" "Synonyms for View $tab of User $use"
}


# Procedure: OD_ShowAllViewGrantsto
proc OD_ShowAllViewGrantsto { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_tab_privs_recd where owner = '$use' and table_name = '$tab'  order by grantee,grantor "

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allViews" "allGrants" "Grants to User/Public on View $tab of User $use" ".ow_allViewsGrantsto" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllViewGrantsby
proc OD_ShowAllViewGrantsby { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set args [string trim $args \{\}]
set tab  [lindex $args 3]
set use [lindex $args 4]

set query "select grantee, owner, table_name, grantor, privilege, grantable  from all_tab_privs_made  where owner = '$use' and table_name = '$tab'  order by grantee,grantor "

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allViews" "allGrants" "Grants by User on View $tab of User $use" ".ow_allViewsGrantsby" 
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllViewText
proc OD_ShowAllViewText { args} {

global ODv_hlAllViewText
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag
global ODv_fAllViewText

set args [string trim $args \{\}]
set use  [lindex $args 4]
set viw [lindex $args 3]

set li [split $ODv_hlAllViewText /]
set title [format "$ODv_fAllViewText" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select text from all_views  where view_name = '$viw' and owner = '$use'"

orafetch $ODv_oracursor {
   set row @1
   set l [split $row \n]
   foreach r $l {
       lappend li $r
   }
}

OD_Msg "SQL finished, results returned"

set ODv_usroldtag "allViews"
catch {OD_Help_Graph_Modify "allViews"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_allviewtext "Text for View $viw of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_allviewtext "Text for View $viw of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Text for View $viw of User $use" $title 400 300 400x300 $li 0
}
}

# Procedure: OD_ShowAllViewComments
proc OD_ShowAllViewComments { args} {

global ODv_hlAllComments
global ODv_fAllComments

set args [string trim $args \{\}]
set viw  [lindex $args 3]
set use [lindex $args 4]

set query "select comments from all_tab_comments where owner = '$use' and table_name = '$viw' and table_type = 'VIEW' "

OD_GenWinAll $ODv_hlAllComments $ODv_fAllComments $query "allViews" "allViews" "Comments for View $viw of User $use" 0 ".ow_allComments" ".ow_allViewsComments"
#Last parameters: viewrow_button,one_window_name and many_windows_name 
}


##############################
# AllObjects - Tablespaces   #
##############################


# Procedure: OD_ShowAllTablespaces
proc OD_ShowAllTablespaces {} {

global ODv_hlAllTablespaces
global ODv_fAllTablespaces

set query "select tablespace_name, initial_extent, next_extent,  min_extents, max_extents, pct_increase, status  from user_tablespaces order by tablespace_name"

OD_ShowAll $ODv_hlAllTablespaces $ODv_fAllTablespaces $query "allObjects" "allTablespaces" "Accessible Tablespaces"
}


# Procedure: OD_ShowAllTablespaceTables
proc OD_ShowAllTablespaceTables { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set tablespacename [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from all_objects o, all_tables t where o.object_type = 'TABLE' and t.tablespace_name = '$tablespacename' and o.object_name = t.table_name order by o.object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allTablespaces" "allTables" "Tables for Tablespace $tablespacename"
}


# Procedure: OD_ShowAllTablespaceIndexes
proc OD_ShowAllTablespaceIndexes { args} {

global ODv_hlAllIndexes
global ODv_fAllIndexes

set args [string trim $args \{\}]
set tablespace  [lindex $args 0]

set query "select index_name, owner, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from all_indexes  where tablespace_name = '$tablespace'  order by index_name, table_owner, table_name"

OD_ShowAll $ODv_hlAllIndexes $ODv_fAllIndexes $query "allTablespaces" "allIndexes" "Indexes for Tablespace $tablespace"
}


############################
# AllObjects-Sequences     #
############################


# Procedure: OD_ShowAllSequences
proc OD_ShowAllSequences { args} {

global ODv_hlAllSequences
global ODv_fAllSequences

set query "select sequence_name, sequence_owner, min_value, max_value, increment_by,  cycle_flag, order_flag, cache_size, last_number  from all_sequences order by sequence_owner, sequence_name"

OD_GenWinAll $ODv_hlAllSequences $ODv_fAllSequences $query "allObjects" "allObjects" "Accessible Sequences" 1 ".ow_allSequences" 

#Last parameters: viewrow_button and many_windows_name 
}


############################
# AllObjects-DB-Links      #
############################


# Procedure: OD_ShowAllDBLinks
proc OD_ShowAllDBLinks { args} {

global ODv_hlAllDBLinks
global ODv_fAllDBLinks

set query "select owner, username, created, db_link, host  from all_db_links order by owner, username, host"

OD_GenWinAll $ODv_hlAllDBLinks $ODv_fAllDBLinks $query "allObjects" "allObjects" "Accessible DB-Links" 1 ".ow_allDBLinks"
#Last parameters: viewrow_button and many_windows_name 
}


###############################
# AllObjects - Synonyms       #
###############################


# Procedure: OD_ShowAllSynonyms
proc OD_ShowAllSynonyms { args} {

global ODv_hlAllSynonyms
global ODv_fAllSynonyms

set query "select synonym_name, owner, table_owner, table_name,  db_link  from all_synonyms order by owner, synonym_name, table_owner, table_name"

OD_ShowAll $ODv_hlAllSynonyms $ODv_fAllSynonyms $query "allObjects" "allSynonyms" "Accessible Synonyms"
}


# Procedure: OD_ShowAllSynonymTables
proc OD_ShowAllSynonymTables { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 3]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from all_objects o where o.object_type = 'TABLE' and o.owner = '$use' and o.object_name = '$tab' order by o.object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allSynonyms" "allTables" "Table for Synonym $synonym of User $use"
}


# Procedure: OD_ShowAllSynonymViews
proc OD_ShowAllSynonymViews { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set synonym [lindex $args 0]
set tab [lindex $args 3]
set use [lindex $args 2]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner  from all_objects o where o.object_type = 'VIEW' and o.owner = '$use' and o.object_name = '$tab' order by o.object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allSynonyms" "allViews" "View for Synonym $synonym of User $use"
}


# Procedure: OD_ShowAllSynonymDBLinks
proc OD_ShowAllSynonymDBLinks { args} {

global ODv_hlAllDBLinks
global ODv_fAllDBLinks

set args [string trim $args \{\}]
set use [lindex $args 1]
set link [lindex $args 4]
set synonym [lindex $args 0]

set query "select owner, username, created, db_link, host  from all_db_links where owner = '$use'  and db_link = '$link' order by owner, username, host"

OD_GenWinAll $ODv_hlAllDBLinks $ODv_fAllDBLinks $query "allSynonyms" "allSynonyms" "DB-Link for Synonym $synonym of User $use" 1 ".ow_allSynomnymsDBLinks"
#Last parameters: viewrow_button and many_windows_name 
}


#################################
# AllObjects-Constraints        #
#################################

# Procedure: OD_ShowAllConstraints
proc OD_ShowAllConstraints { args} {

global ODv_hlAllConstraints
global ODv_fAllConstraints 

set query "select constraint_name, table_name, owner,constraint_type, r_owner, r_constraint_name, search_condition from all_constraints order by constraint_name, r_owner, r_constraint_name"

OD_ShowAll $ODv_hlAllConstraints $ODv_fAllConstraints $query "allObjects" "allConstraints" "Accessible Constraints"
}


# Procedure: OD_ShowAllConstraintTable
proc OD_ShowAllConstraintTable { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set use  [lindex $args 2]
set tab [lindex $args 1]
set con [lindex $args 0]

set query "select object_id, created, status, object_name, owner  from all_objects  where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allConstraints" "allTables" "Tables for Constraint $con of User $use"
}


# Procedure: OD_ShowAllConstraintColumns
proc OD_ShowAllConstraintColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set con  [lindex $args 0]
set tab [lindex $args 1]
set use [lindex $args 2]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from all_tab_columns t, all_cons_columns c  where c.constraint_name = '$con' and t.owner = '$use' and c.owner = '$use' and c.table_name = t.table_name and t.column_name = c.column_name order by t.column_name"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allConstraints" "allColumns" "Columns for Constraint $con, table $tab of User $use"
}


##################################
# AllObjects-Triggers/Procedures #
##################################


# Procedure: OD_ShowAllTriggers
proc OD_ShowAllTriggers {} {

global ODv_hlAllTriggers
global ODv_fAllTriggers

set query "select distinct trigger_name, owner, table_owner, table_name, trigger_type, triggering_event, status, referencing_names from all_triggers order by trigger_name, table_name"

OD_ShowAll $ODv_hlAllTriggers $ODv_fAllTriggers $query "allObjects" "allTriggers" "Accessible Triggers"
}


# Procedure: OD_ShowAllTriggerTable
proc OD_ShowAllTriggerTable { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set tab [lindex $args 3]
set use [lindex $args 2]
set trigger [lindex $args 0]

set query "select o.object_id, o.created, o.status, o.object_name, o.owner from all_triggers t, all_objects o  where t.table_owner = '$use' and t.table_name = '$tab' and t.trigger_name = '$trigger' and o.object_name = '$tab' and o.owner = '$use' and o.object_type = 'TABLE' order by o.object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allTriggers" "allTables" "Tables for Trigger $trigger of User $use"
}


# Procedure: OD_ShowAllTriggerColumns
proc OD_ShowAllTriggerColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set own [lindex $args 1]
set use  [lindex $args 2]
set tab [lindex $args 3] 
set trigger [lindex $args 0]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from all_tab_columns t, all_trigger_cols c where t.owner = '$use'  and t.table_name = '$tab' and c.trigger_name = '$trigger' and c.table_owner = '$use' and c.table_name = '$tab' and c.trigger_owner = '$own' and c.column_name = t.column_name order by t.column_name"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allTriggers" "allColumns" "Columns for Trigger $trigger of User $own"
}


# Procedure: OD_ShowAllTriggerDesc
proc OD_ShowAllTriggerDesc { args} {

global ODv_hlAllTrigDesc
global ODv_fAllTrigDesc
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlAllTrigDesc /]
set title [format "$ODv_fAllTrigDesc" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select description from all_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "allTriggers"
catch {OD_Help_Graph_Modify "allTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_alltrigdesc "Description for Trigger of User $use" $title 400 300 400x300 $li 0 
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_alltrigdesc "Description for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Description for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowAllTriggerWhen
proc OD_ShowAllTriggerWhen { args} {

global ODv_hlAllTrigWhen
global ODv_fAllTrigWhen
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlAllTrigWhen /]
set title [format "$ODv_fAllTrigWhen" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select when_clause from all_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "allTriggers"
catch {OD_Help_Graph_Modify "allTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_alltrigwhen "When-clause for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_alltrigwhen "When-clause for Trigger $trig  of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "When-clause for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowAllTriggerBody
proc OD_ShowAllTriggerBody { args} {

global ODv_hlAllTrigBody
global ODv_fAllTrigBody
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

set args [string trim $args \{\}]
set trig [lindex $args 0]
set use  [lindex $args 1]
set own  [lindex $args 2]
set tab  [lindex $args 3]

set li [split $ODv_hlAllTrigBody /]
set title [format "$ODv_fAllTrigBody" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select trigger_body from all_triggers where owner = '$use' and trigger_name = '$trig' and table_name = '$tab' and table_owner = '$own'"

orafetch $ODv_oracursor {
   set row @1
   set l [split $row \n]
   foreach r $l {
       lappend li $r
   }
}

OD_Msg "SQL finished, resuls returned"

set ODv_usroldtag "allTriggers"
catch {OD_Help_Graph_Modify "allTriggers"}

if {$ODv_windows == "one"} {
OD_GenWin .ow_alltrigbody "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
OD_GenWin .ow_alltrigbody "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
OD_GenWin .$ODv_wincount "Body for Trigger $trig of User $use" $title 400 300 400x300 $li 0
}
}


# Procedure: OD_ShowAllProcedures
proc OD_ShowAllProcedures {} {

global ODv_hlAllProcedures
global ODv_fAllProcedures
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

set li [split $ODv_hlAllProcedures /]
set title [format "$ODv_fAllProcedures" [lindex $li 0] [lindex $li 1] [lindex $li 2]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select distinct owner, name, type from all_source  order by owner, name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllProcedures" @1 @2 @3]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No accessible Procedures,Functions or Packages available"
    return
}

set ODv_usroldtag "allObjects"
catch {OD_Help_Graph_Modify "allObjects"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_allprocedures "All accessible Procedures, Functions and Packages" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_allprocedures "All accessible Procedures, Functions and Packages" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "All accessible Procedures, Functions and Packages" $title 400 300 400x300 $li 1  "Source Text" OD_ShowAllProcSource
}
}


# Procedure: OD_ShowAllProcSource
proc OD_ShowAllProcSource { args} {

global ODv_hlAllProcSource
global ODv_fAllProcSource
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag

set args [string trim $args \{\}]
set use  [lindex $args 0]
set proc [lindex $args 1]
set type [lindex $args 2]

set li [split $ODv_hlAllProcSource /]
set title [format "$ODv_fAllProcSource" [lindex $li 0]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select text from all_source  where owner = '$use' and name = '$proc' order by line"

set row [orafetch $ODv_oracursor]
while {$oramsg(rc) == 0} {
   lappend li [lindex $row 0]
   set row [orafetch $ODv_oracursor]
}

orafetch $ODv_oracursor {lappend li @1}
OD_Msg "SQL finished, results returned"

set ODv_usroldtag "allObjects"
catch {OD_Help_Graph_Modify "allObjects"}

if {$ODv_windows == "one"} {
  OD_GenWin .ow_allprocsource "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
} elseif {$ODv_windows == "many"} {
  OD_GenWin .ow_allprocsource "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
} else {incr ODv_wincount
  OD_GenWin .$ODv_wincount "Source Text for $type $proc of User $use" $title 400 300 400x300 $li 0
}
}


###############################
# AllObjects-Grants           #
###############################


# Procedure: OD_ShowAllGrantstoUser
proc OD_ShowAllGrantstoUser { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set query "select grantee, owner, table_name, grantor, privilege,  grantable from all_tab_privs_recd  order by owner, table_name, grantee"

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allObjects" "allGrants" "Grants to User/Public" ".ow_allGrantsto"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllGrantsbyUser
proc OD_ShowAllGrantsbyUser { args} {

global ODv_hlAllGrants
global ODv_fAllGrants

set query "select grantee, owner, table_name, grantor, privilege,  grantable from all_tab_privs_made order by owner, table_name, grantee"

OD_ShowAll $ODv_hlAllGrants $ODv_fAllGrants $query "allObjects" "allGrants" "Grants by User" ".ow_allGrantsby"
#Last parameter: many_windows_name
}


# Procedure: OD_ShowAllGrantsTable
proc OD_ShowAllGrantsTable { args} {

global ODv_hlAllTables
global ODv_fAllTables

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set tab [lindex $args 2]

set query "select object_id, created, status, object_name, owner from all_objects where object_type = 'TABLE' and owner = '$use' and object_name = '$tab' order by object_name"

OD_ShowAll $ODv_hlAllTables $ODv_fAllTables $query "allGrants" "allTables" "Table for User $use, Grantee $grantee, Grantor $grantor"
}


# Procedure: OD_ShowAllGrantsColumns
proc OD_ShowAllGrantsColumns { args} {

global ODv_hlAllColumns
global ODv_fAllColumns

set args [string trim $args \{\}]
set use  [lindex $args 1]
set tab [lindex $args 2] 
set grantee [lindex $args 0]
set grantor [lindex $args 3]

set query "select t.column_name, t.table_name, t.owner, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, t.column_id, t.default_length, t.data_default, t.num_distinct, t.low_value, t.high_value from all_tab_columns t, all_col_privs g  where t.table_name = '$tab' and t.owner = '$use' and g.table_name = '$tab' and g.grantee = '$grantee' and g.grantor = '$grantor' and t.column_name = g.column_name order by t.column_name"

OD_ShowAll $ODv_hlAllColumns $ODv_fAllColumns $query "allGrants" "allColumns" "Columns for User $use, Grantee $grantee and Grantor $grantor"
}


# Procedure: OD_ShowAllGrantsView
proc OD_ShowAllGrantsView { args} {

global ODv_hlAllViews
global ODv_fAllViews

set args [string trim $args \{\}]
set grantee [lindex $args 0]
set grantor [lindex $args 3]
set use [lindex $args 1]
set tab [lindex $args 2]

set query "select object_id, created, status, object_name, owner from all_objects where object_type = 'VIEW' and owner = '$use' and object_name = '$tab' order by owner, object_name"

OD_ShowAll $ODv_hlAllViews $ODv_fAllViews $query "allGrants" "allViews" "View for User $use, Grantee $grantee, Grantor $grantor"
}






