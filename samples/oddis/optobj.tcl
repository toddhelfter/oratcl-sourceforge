
#########################################################################
# Internal Optimize-Queries                                             #
#########################################################################

##########################
# Optimize-Analyze       #
##########################

##########################
# Analyze Tables         #
##########################

# Regine Kasten
# search for all user tables to select a table for analyzing
# Procedure: OD_ShowAnalyzeTables
proc OD_ShowAnalyzeTables {} {

global ODv_hlUsrTables
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fUsrTables
global ODv_AnalyzeType

set ODv_AnalyzeType {current}

set li    [split $ODv_hlUsrTables /]
set title [format "$ODv_fUsrTables" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select object_id, created, status, object_name from user_objects where object_type = 'TABLE' order by object_name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrTables" @1 @2 @3 @4]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"


if  {[llength $li] == 0} {
    OD_Msg "No User-Tables available"
    return
}

set ODv_usroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrTables"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzetables .ow_analyzetables $li $title "Analyze-Tables"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzetables .ow_analyzealltables $li $title "Analyze-Tables"
} else {incr ODv_wincount
  ShowWindow.ow_analyzetables .$ODv_wincount $li $title "Analyze-Tables"
}
}



##########################
# Analyzed Tables        #
##########################

# Regine Kasten
# Search for statistics of tables and columns for a selected table 
# Procedure OD_ShowAnalyzedTables 
proc OD_ShowAnalyzedTables { args} {

global ODv_hlAnalyzedTablesTab
global ODv_hlAnalyzedTablesCol
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fAnalyzedTablesTab
global ODv_fAnalyzedTablesCol
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_analyzeest


set args [string trim $args \{\}]
set tab  [lindex $args 3]


### Statistics for tables

set li    [split $ODv_hlAnalyzedTablesTab /]
set title [format "$ODv_fAnalyzedTablesTab" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len from user_tables  where table_name = '$tab'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAnalyzedTablesTab" @1 @2 @3 @4 @5 @6]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows for table returned"


if  {[llength $li] == 0} {
    OD_Msg "No Statistics of Table $tab for tables available"
    return
}


set ODv_usroldtag "usrTables"
catch {OD_Help_Graph_Modify "usrTables"}


if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzedtablestab .ow_analyzedtablestab $li $title  "$ODv_AnalyzeType Statistics of Table $tab for Tables"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzedtablestab .ow_analyzedtabtablestab $li $title "$ODv_AnalyzeType Statistics of Table $tab for Tables"
} else {incr ODv_wincount
  ShowWindow.ow_analyzedtablestab .$ODv_wincount $li  $title "$ODv_AnalyzeType Statistics of Table $tab for Tables"
}


### Statistics for columns

set li    [split $ODv_hlAnalyzedTablesCol /]
set title [format "$ODv_fAnalyzedTablesCol" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select column_name, table_name, low_value, high_value, num_distinct from user_tab_columns  where table_name = '$tab'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAnalyzedTablesCol" @1 @2 @3 @4 @5]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows for table returned"

if  {[llength $li] == 0} {
    OD_Msg "No Statistics of Table $tab for columns available"
    return
}


set ODv_usroldtag "usrTables"
catch {OD_Help_Graph_Modify "usrColumns"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzedtablescol .ow_analyzedtablescol    $li $title  "$ODv_AnalyzeType Statistics of Table $tab for Columns"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzedtablescol .ow_analyzedtabtablescol $li $title "$ODv_AnalyzeType Statistics of Table $tab for Columns"
} else {incr ODv_wincount
  ShowWindow.ow_analyzedtablescol .$ODv_wincount           $li  $title "$ODv_AnalyzeType Statistics of Table $tab for Columns"
}


set ODv_AnalyzeType {current}

}


##########################
# Analyze Indexes        #
##########################

# Regine Kasten
# search for user indexes to select an index for analyzing
# Procedure: OD_ShowAnalyzeIndexes
proc OD_ShowAnalyzeIndexes {} {

global ODv_hlUsrIndexes  
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fUsrIndexes
global ODv_AnalyzeType

set ODv_AnalyzeType {current}

set li     [split $ODv_hlUsrIndexes /]
set title  [format "$ODv_fUsrIndexes" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6] [lindex $li 7] [lindex $li 8] [lindex $li 9] [lindex $li 10] [lindex $li 11] [lindex $li 12] [lindex $li 13] [lindex $li 14] [lindex $li 15] [lindex $li 16] [lindex $li 17] [lindex $li 18] [lindex $li 19] [lindex $li 20]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select index_name, table_owner, table_name,  table_type, uniqueness, tablespace_name, ini_trans,  max_trans, initial_extent, next_extent, min_extents, max_extents, pct_increase, pct_free, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor, status from user_indexes order by index_name, table_owner, table_name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrIndexes" @1 @2 @3 @4 @5 @6 @7 @8 @9 @10 @11 @12 @13 @14 @15 @16 @17 @18 @19 @20 @21]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No User-Indexes available"
    return
}

set ODv_usroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrIndexes"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzeindexes .ow_analyzeindexes $li $title "Analyze-Indexes"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzeindexes .ow_analyzeallindexes $li $title "Analyze-Indexes"
} else {incr ODv_wincount
  ShowWindow.ow_analyzeindexes .$ODv_wincount $li $title "Analyze-Indexes"
}
}


##########################
# Analyzed Indexes       #
##########################

# Regine Kasten
# search for statistics of indexes for a selected index
# Procedure OD_ShowAnalyzedIndexes 
proc OD_ShowAnalyzedIndexes { args} {

global ODv_hlAnalyzedIndexes
global ODv_fAnalyzedIndexes
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_analyzeest


set args [string trim $args \{\}]
set index [lindex $args 0]

## statistics for Index

set li [split $ODv_hlAnalyzedIndexes /]
set title  [format "$ODv_fAnalyzedIndexes" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select table_name, blevel, leaf_blocks,  distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor from user_indexes where index_name = '$index'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAnalyzedIndexes" @1 @2 @3 @4 @5 @6 @7]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Statistics for User-Indexes of Index $index available"
    return
}

set ODv_usroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrIndexes"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzedindexes .ow_analyzedindexes $li $title  "$ODv_AnalyzeType Statistics of Index $index for Indexes"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzedindexes .ow_analyzedindindexes $li $title "$ODv_AnalyzeType Statistics of Index $index for Indexes"
} else {incr ODv_wincount
  ShowWindow.ow_analyzedindexes .$ODv_wincount $li  $title "$ODv_AnalyzeType Statistics of Index $index for Indexes"
}

set ODv_AnalyzeType {current}

}


##########################
# Analyze Cluster        #
##########################

# Regine Kasten
# search for user cluster to select a cluster for analyzing
# Procedure: OD_ShowAnalyzeCluster
proc OD_ShowAnalyzeCluster {} {

global ODv_hlUsrClusters
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fUsrClusters
global ODv_AnalyzeType

set ODv_AnalyzeType {current}

set li    [split $ODv_hlUsrClusters /]
set title [format "$ODv_fUsrClusters" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select object_id, created, status, object_name from user_objects where object_type = 'CLUSTER' order by object_id"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrClusters" @1 @2 @3 @4]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No User-Clusters available"
    return
}

set ODv_useroldtag "usrUser"
catch {OD_Help_Graph_Modify "usrClusters"}

if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzecluster .ow_analyzecluster $li $title "Analyze-Clusters"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzecluster .ow_analyzeanacluster $li $title "Analyze-Clusters"
} else {
  incr ODv_wincount
  ShowWindow.ow_analyzecluster .$ODv_wincount $li $title "Analyze-Clusters"
}
}


##########################
# Analyzed Cluster       #
##########################

# Regine Kasten
# Search for statistics of cluster for a selected cluster
# Procedure OD_ShowAnalyzedCluster
proc OD_ShowAnalyzedCluster { args} {

global ODv_hlUsrClusterDetails
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_fUsrClusterDetails
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_analyzeest

set args [string trim $args \{\}]
set clu  [lindex $args 3]

## statistics for Cluster

set li [split $ODv_hlUsrClusterDetails /]
set title [format "$ODv_fUsrClusterDetails"  [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6] [lindex $li 7]  [lindex $li 8] [lindex $li 9] [lindex $li 10] [ lindex $li 11] [lindex $li 12] [lindex $li 13] [lindex $li 14] [lindex $li 15]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select cluster_name, tablespace_name,  pct_free, pct_used, key_size, ini_trans, max_trans, initial_extent, next_extent, min_extents, max_extents,  pct_increase, avg_blocks_per_key, cluster_type,  function, hashkeys  from user_clusters  where cluster_name = '$clu'  order by tablespace_name"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrClusterDetails" @1 @2 @3 @4 @5 @6 @7 @8 @9 @10 @11 @12 @13 @14 @15 @16]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Statistics of Cluster $clu available"
    return
}

set ODv_usroldtag "usrClusters"
catch {OD_Help_Graph_Modify "usrClusters"}


if {$ODv_windows == "one"} {
  ShowWindow.ow_analyzedcluster .ow_analyzedcluster $li $title "$ODv_AnalyzeType Statistics of Cluster $clu for Clusters"
} elseif {$ODv_windows == "many"} {
  ShowWindow.ow_analyzedcluster .ow_analyzedanacluster $li $title "$ODv_AnalyzeType Statistics of Cluster $clu for Clusters"
} else {
  incr ODv_wincount
  ShowWindow.ow_analyzedcluster .$ODv_wincount $li $title "$ODv_AnalyzeType Statistics of Cluster $clu for Clusters"
}

set ODv_AnalyzeType {current}

}



###############################
# Optimize-Explain            #
###############################


##########################
# Optimize-Explain-Plan  #
##########################

# B/S, Regine Kasten
# Create plan table. Get the execution plan for a statement 
# Procedure: OD_ShowExplainPlan
proc OD_ShowExplainPlan { explaintype} {

global ODv_fExplainplan
global ODv_hlExplainplan
global oraexplaincursor
global ODv_oracursor
global oramsg
global contFlag
global stopFlag
global ODv_cmdRing
global ODv_user
global ODv_orahandle
global ODv_windows
global ODv_wincount
global ODv_usroldtag
global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainListIds
global ODv_ExplainListStates
global ODv_ExplainListTypes


set contFlag 1
set stopFlag 1

set oraexplaincursor [oraopen $ODv_orahandle]
set sql_str          [.tl_main.fr_statement.tx_statement get 1.0 end]
set ExplainState     $sql_str
set sql_filt         ""

foreach f [split $sql_str \n] {
   set ex1 [regexp -nocase "^#.*$|^ *#.*$" $f]
   set ex2 [regexp -nocase "^;.*$|^ *;.*$" $f]
   if !$ex1$ex2 {
      append sql_filt "$f\n"
   } else {
      append sql_filt "\n"
   }
}

if {[string length $sql_filt] == 0} {
  OD_Msg "No SQL to explain"
  oraclose $oraexplaincursor
  return
}

OD_InsSQL

# create Plan_table
set error [catch {orasql $oraexplaincursor "create table plan_table (statement_id    varchar2(30),  timestamp       date, remarks         varchar2(80), operation       varchar2(30), options         varchar2(30), object_node     varchar2(128), object_owner    varchar2(30), object_name     varchar2(30), object_instance numeric, object_type     varchar2(30), search_columns  numeric, id              numeric, parent_id       numeric, position        numeric, other           long)"}]
if $error==0 {
   OD_MsgBox "ODDIS-Info" 200x50 200 "PLAN_TABLE created"
} 


# change optimizer_goal
if {[string compare $explaintype Choose ] == 0} { 
   set error [catch {orasql $ODv_oracursor "alter session set optimizer_goal = CHOOSE"}]
   if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
   }
   OD_Msg "Alter-Session with $explaintype finished"
} elseif  {[string compare $explaintype All_Rows ] == 0} { 
   set error [catch {orasql $ODv_oracursor "alter session set optimizer_goal = ALL_ROWS"}]
   if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
   }
} elseif  {[string compare $explaintype First_Rows ] == 0} { 
    set error [catch {orasql $ODv_oracursor "alter session set optimizer_goal = FIRST_ROWS"}]
   if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
   }
} else { 
   set error [catch {orasql $ODv_oracursor "alter session set optimizer_goal = RULE"}]
   if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
   } 
}  


### searching for execution plan 

set process_id [pid]
set state_id OD_$process_id

OD_Msg "Running Explain"

set error [catch {orasql $oraexplaincursor "explain plan set statement_id = '$state_id'  into plan_table for $sql_filt"}]
if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt)"
   oraclose $oraexplaincursor
   return
}


set error [catch {orasql $oraexplaincursor "select lpad(' ', 2*(level-1))||decode(operation,'TABLE ACCESS','TABLE_ACCESS','FIXED TABLE', 'FIXED_TABLE', operation), decode(substr(options,1,15), 'BY ROWID','ROWID','GROUP BY','GROUP','ORDER BY','ORDER','UNIQUE SCAN','UNIQUE','RANGE SCAN','DESCEND',substr(options,1,15)), object_name, object_owner, id, parent_id, decode(id,0,''||position) from plan_table start with id = 0 and statement_id = '$state_id' connect by prior id = parent_id and statement_id = '$state_id' order by id"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   oraclose $oraexplaincursor
   return
} else {
   OD_Msg "Explain-SQL finished, getting results"
   OD_CheckMessage
}

# set result list

set li    [split $ODv_hlExplainplan /]
set title [format "$ODv_fExplainplan" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6]]

set li   ""
orafetch $oraexplaincursor {lappend li [format "$ODv_fExplainplan" @1 @2 @3 @4 @5 @6 @7]}

orasql $oraexplaincursor "select id, parent_id from plan_table start with id = 0 and statement_id = '$state_id' connect by prior id = parent_id and statement_id = '$state_id' order by id"


# set ID-List used in ShowexplainTree 

set liids ""
orafetch  $oraexplaincursor {lappend liids [format "%11s %11s" @1 @2]}

set ExplainIds  $liids
set ExplainList $li


if {$ODv_windows == "one"} {
   set wname .ow_explainplan
   ShowWindow.ow_explainplan $wname $li $title "Explain-Result with $explaintype" 
} elseif {$ODv_windows == "many"} {
   set wname .ow_explainplanexp
   ShowWindow.ow_explainplan $wname $li $title "Explain-Result with $explaintype"
} else {incr ODv_wincount
   set wname .$ODv_wincount 
   ShowWindow.ow_explainplan $wname $li $title "Explain-Result with $explaintype" 
}

### delete explain plan result from plan_table
set error [catch {orasql $oraexplaincursor "delete from plan_table where statement_id = '$state_id'"}]
if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt)"
   oraclose $oraexplaincursor
   return
}

### set default for optimizer_goal
set error [catch {orasql $ODv_oracursor "alter session set optimizer_goal = CHOOSE"}]
   if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
   } 

### remember Parameters for Explaintree

set pos [lsearch $ODv_ExplainListWins $wname]
if {$pos == -1} { 
    # all windownames from executionplans
   lappend ODv_ExplainListWins   $wname
    # all plantable values for statement
   lappend ODv_ExplainListLists  $ExplainList
    # all ids and parent_ids from plantable for statement
   lappend ODv_ExplainListIds    $ExplainIds
    # all statements
   lappend ODv_ExplainListStates $ExplainState
    # all explaintypes 
   lappend ODv_ExplainListTypes  $explaintype
} else {
   set ODv_ExplainListWins   [lreplace ODv_ExplainListWins   $pos $pos $wname]
   set ODv_ExplainListLists  [lreplace ODv_ExplainListLists  $pos $pos $ExplainList]
   set ODv_ExplainListIds    [lreplace ODv_ExplainListIds    $pos $pos $ExplainIds]
   set ODv_ExplainListStates [lreplace ODv_ExplainListStates $pos $pos $ExplainState]
   set ODv_ExplainListTypes  [lreplace ODv_ExplainListTypes  $pos $pos $explaintype]
}

}



#############################
# Optimize-Explained-Object #
#############################

# Regine Kasten
# Search for information about a selected object in the execution plan
# Procedure: OD_ShowExplainObject
proc OD_ShowExplainObject { parentwname args} {

global ODv_hlAllTables
global ODv_fAllTables
global ODv_hlAllIndexes
global ODv_fAllIndexes
global ODv_hlUsrClusters
global ODv_fUsrClusters
global ODv_hlAllViews
global ODv_fAllViews
global ODv_usroldtag
global ODv_oracursor
global oramsg
global ODv_windows
global ODv_wincount
global ODv_alloldtag
global ODv_ExplainListWins
global ODv_ExplainListStates
global ODv_ExplainOpe

set args      [string trim $args \{\}]

###  statement - id 

set op [lindex $args 1]

if { [string compare $op STATEMENT] == 0} {
   set pos             [lsearch $ODv_ExplainListWins   $parentwname]
   set ExplainState    [lindex  $ODv_ExplainListStates $pos]
      if {$ODv_windows == "one"} {
               OD_Help_InfoBox "Explain-Statement" $ExplainState .ow_explainstate
      } elseif {$ODv_windows == "many"} {
               OD_Help_InfoBox "Explain-Statement" $ExplainState .ow_explainstatestate
      } else   {incr ODv_wincount
               OD_Help_InfoBox "Explain-Statement" $ExplainState .$ODv_wincount
      }
    return
}


### no object

set operation [lindex $args 0]

if { [lsearch $ODv_ExplainOpe $operation] == -1} {
      OD_Msg "No Object accessible"
      return
}


### Object - Name, Owner

set obj_name  [lindex $args 2]
set obj_owner [lindex $args 3]


### Type = Table

set li    [split $ODv_hlAllTables /]
set title [format "$ODv_fAllTables" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4]]

set li ""
OD_Msg "Searching for data..."

orasql   $ODv_oracursor "select object_id, created, status, object_name, owner from all_objects where object_type = 'TABLE' and object_name = '$obj_name' and owner = '$obj_owner'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllTables" @1 @2 @3 @4 @5]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No accessible Table available"
} else {

  set ODv_alloldtag "allObjects"
  catch {OD_Help_Graph_Modify "allTables"}

  if {$ODv_windows == "one"} {
    ShowWindow.ow_alltable .ow_alltable $li $title "Explain-Object"
  } elseif {$ODv_windows == "many"} {
    ShowWindow.ow_alltable .ow_allexplaintable $li $title "Explain-Object"
  } else {incr ODv_wincount
    ShowWindow.ow_alltable .$ODv_wincount $li $title "Explain-Object"
  }
  return
}


### Type = Index

set li     [split $ODv_hlAllIndexes /]
set title  [format "$ODv_fAllIndexes" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4] [lindex $li 5] [lindex $li 6] [lindex $li 7] [lindex $li 8] [lindex $li 9] [lindex $li 10] [lindex $li 11] [lindex $li 12] [lindex $li 13] [lindex $li 14] [lindex $li 15] [lindex $li 16] [lindex $li 17] [lindex $li 18] [lindex $li 19] [lindex $li 20] [lindex $li 21]]

set li ""
OD_Msg "Searching for data..."

orasql   $ODv_oracursor "select i.index_name, i.owner, i.table_owner,
i.table_name, i.table_type, i.uniqueness, i.tablespace_name, i.ini_trans, i.max_trans, i.initial_extent, i.next_extent, i.min_extents, i.max_extents, i.pct_increase, i.pct_free, i.blevel, i.leaf_blocks, i.distinct_keys, i.avg_leaf_blocks_per_key, i.avg_data_blocks_per_key, i.clustering_factor, i.status  from all_indexes i where i.index_name = '$obj_name' and i.owner = '$obj_owner'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllIndexes" @1 @2 @3 @4 @5 @6 @7 @8 @9 @10 @11 @12 @13 @14 @15 @16 @17 @18 @19 @20 @21 @22]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"


if  {[llength $li] == 0} {
    OD_Msg "No accessible Index available"
} else {
  set ODv_alloldtag "allObjects"
  catch {OD_Help_Graph_Modify "allIndexes"}

  if {$ODv_windows == "one"} {
    ShowWindow.ow_allindex .ow_allindex $li $title "Explain-Object"
  } elseif {$ODv_windows == "many"} {
    ShowWindow.ow_allindex .ow_allallindex $li $title "Explain-Object"
  } else {incr ODv_wincount
    ShowWindow.ow_allindex .$ODv_wincount $li $title "Explain-Object"
  }
  return
}


### Type = Cluster

set li    [split $ODv_hlUsrClusters /]
set title [format "$ODv_fUsrClusters" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3]]

set li ""
OD_Msg "Searching for data..."

orasql   $ODv_oracursor "select object_id, created, status, object_name from user_objects where object_type = 'CLUSTER' and object_name = '$obj_name'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fUsrClusters" @1 @2 @3 @4]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No User-Clusters available"
} else {

  set ODv_useroldtag "usrUser"
  catch {OD_Help_Graph_Modify "usrClusters"}

  if {$ODv_windows == "one"} {
    ShowWindow.ow_usercluster .ow_usercluster $li $title "Explain-Object" 
  } elseif {$ODv_windows == "many"} {
    ShowWindow.ow_usercluster .ow_userusercluster $li $title "Explain-Object"
  } else {
    incr ODv_wincount
    ShowWindow.ow_usercluster .$ODv_wincount $li $title "Explain-Object"
  }
  return
}


### Type = View

set obj_name  [lindex $args 1]

set li    [split $ODv_hlAllViews /]
set title [format "$ODv_fAllViews" [lindex $li 0] [lindex $li 1] [lindex $li 2] [lindex $li 3] [lindex $li 4]]

set li ""
OD_Msg "Searching for data..."

orasql $ODv_oracursor "select object_id, created, status, object_name, owner from all_objects where object_type = 'VIEW' and object_name = '$obj_name'and owner = '$obj_owner'"

orafetch $ODv_oracursor {lappend li [format "$ODv_fAllViews" @1 @2 @3 @4 @5]}

set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No accessible Views available" 
} else {
  set ODv_alloldtag "allObjects"
  catch {OD_Help_Graph_Modify "allViews"}

  if {$ODv_windows == "one"} {
    ShowWindow.ow_allview .ow_allview $li $title "Explain-Object"
  } elseif {$ODv_windows == "many"} {
    ShowWindow.ow_allview .ow_allallview $li $title "Explain-Object"
  } else {incr ODv_wincount
    ShowWindow.ow_allview .$ODv_wincount $li $title "Explain-Object"
  }
  return
}


### Message if no Object

if {[ctype -failindex var digit $obj_name] != 0} { 
   OD_Msg "No Object available"
} else {
  OD_Msg "No accessible Object available"
}

}



############################ 
# Optimize-Explain-Obj-Det #
############################

# Regine Kasten
# Search for information about a selected object extents and devices
# Procedure: OD_ShowExplainObjDet
proc OD_ShowExplainObjDet { parentwname args} {

global ODv_oracursor
global oramsg
global ODv_sysoldtag
global ODv_windows
global ODv_wincount
global ODv_AnalyzeType
global ODv_f_nrsmall
global ODv_ExplainOpe

set args      [string trim $args \{\}]
set operation [lindex $args 0]
set option    [lindex $args 1]
set obj_name  [lindex $args 2]
set obj_owner [lindex $args 3]
set obj_type  ""



### object exists ?

if { [lsearch $ODv_ExplainOpe $operation] == -1} {
      OD_Msg "No Object accessible"
      return
}

if {[string compare $option STATEMENT] == 0} {
   OD_Msg "No Object accessible"
   return
}


### is view ?

if {[string compare $operation VIEW] == 0} {
	set obj_name  [lindex $args 1]
	set obj_owner [lindex $args 2]
}


### set lists for title and information 

set titlelist    ""
set elementslist ""
 # number of extents
set extnum       1

### Information for Object

set title    ""
set elements ""

set helpli "" 

OD_Msg "Searching for object..."

set error [catch {orasql $ODv_oracursor "select object_type from sys.dba_objects where object_name = '$obj_name' and owner = '$obj_owner'"}]

orafetch $ODv_oracursor {lappend helpli @0}

if {$error == 1} { ### no dba-grants
	set helpli ""
	orasql $ODv_oracursor "select object_type from all_objects where object_name = '$obj_name' and owner = '$obj_owner'"
	orafetch $ODv_oracursor {lappend helpli @1}
	if {[llength $helpli] == 0} { # is index ?
           set helpli ""
	   orasql $ODv_oracursor "select table_name,table_type from all_indexes where index_name = '$obj_name' and owner = '$obj_owner'"
	   orafetch $ODv_oracursor {lappend helpli @1 @2}
	   if {[llength $helpli] == 0} {# no index
	      set title [concat  $title {OBJECT OWNER}]
	      lappend elements $obj_name $obj_owner
	   } else { 
	      set title [concat  $title {OBJECT TYPE OWNER TABLE_NAME TABLE_TYPE}]
	      lappend elements $obj_name INDEX $obj_owner 
	      lappend elements [lindex $helpli 0]
	      lappend elements [lindex $helpli 1]
	      set obj_type INDEX
	   }
	} else { # is table or other
	   set title [concat $title {OBJECT TYPE OWNER}]
	   lappend elements $obj_name
	   lappend elements [lindex $helpli 0]
	   lappend elements $obj_owner
	   set obj_type [lindex $helpli 0]
	   if {[string compare $obj_type TABLE] == 0} {
		set helpli ""
		orasql $ODv_oracursor "select count(*) from all_indexes where table_name = '$obj_name' and table_owner = '$obj_owner'"
		orafetch $ODv_oracursor {lappend helpli @1}	
		lappend title    INDEXES
		lappend elements [lindex $helpli 0]
	   }
	   if  {[string compare $obj_type INDEX] == 0} {
		set helpli ""
		orasql $ODv_oracursor "select table_name,table_type from all_indexes where index_name = '$obj_name' and owner = '$obj_owner'"
		orafetch $ODv_oracursor {lappend helpli @1 @2}	
	        set title [concat  $title {TABLE_NAME TABLE_TYPE}]
		lappend elements [lindex $helpli 0]
		lappend elements [lindex $helpli 1]
	   }
	}
} else { ### with dba - grants
	if {[llength $helpli] == 0} {
	    set title [concat  $title {OBJECT  OWNER}]
	    lappend elements $obj_name $obj_owner
	} else {
	   set title [concat $title {OBJECT TYPE OWNER}]
	   lappend elements $obj_name
	   lappend elements [lindex $helpli 0]
	   lappend elements $obj_owner
	   set obj_type [lindex $helpli 0]
	   if  {[string compare $obj_type TABLE] == 0} {
		set helpli ""
		orasql $ODv_oracursor "select count(*) from sys.dba_indexes where table_name = '$obj_name' and table_owner = '$obj_owner'"
		orafetch $ODv_oracursor {lappend helpli @1}	
		lappend title    INDEXES
		lappend elements [lindex $helpli 0]
	   }
	   if  {[string compare $obj_type INDEX] == 0} {
		set helpli ""
		orasql $ODv_oracursor "select table_name,table_type from sys.dba_indexes where index_name = '$obj_name' and owner = '$obj_owner'"
		orafetch $ODv_oracursor {lappend helpli @1 @2}	
		set title [concat $title {TABLE_NAME TABLE_TYPE}]
		lappend elements [lindex $helpli 0]
		lappend elements [lindex $helpli 1]
	   }
	}
}


### Extents and Devices for Object

set helpli ""

OD_Msg "Searching for devices..."

set error 0
set error [catch {orasql $ODv_oracursor "select distinct u.tablespace_name, e.extent_id, e.blocks, u.file_id, d.device_id from sys.dba_extents e, sys.dba_free_space u, sys.device_dfile$ d where u.file_id = d.file_id and e.tablespace_name = u.tablespace_name and e.segment_name = '$obj_name' and e.owner = '$obj_owner' order by e.extent_id, u.file_id"}]

orafetch $ODv_oracursor {lappend helpli @0}

if  {$error == 1} { ### no dba-grants

    set helpli ""
    set error 0
    set error [catch {orasql $ODv_oracursor "select distinct u.tablespace_name, e.extent_id, e.blocks, u.file_id, d.device_id from user_extents e, user_free_space u, sys.device_dfile$ d where u.file_id = d.file_id and e.tablespace_name = u.tablespace_name and e.segment_name = '$obj_name' order by e.extent_id, u.file_id"}]

    orafetch $ODv_oracursor {lappend helpli @0}

    if  {$error == 1} { ### no device-grants

	set helpli ""
    	orasql $ODv_oracursor "select distinct u.tablespace_name, e.extent_id, e.blocks, u.file_id from user_extents e, user_free_space u where e.tablespace_name = u.tablespace_name and e.segment_name = '$obj_name' order by e.extent_id, u.file_id"

	    orafetch $ODv_oracursor {lappend helpli @0}

	    if {[llength $helpli] == 0} {
	       lappend titlelist    $title
	       lappend elementslist $elements
	       set title     ""
	       set elements  ""
	       lappend elements "No User-Object"
	    } else {
	       lappend title TABLESPACE_NAME
	       lappend elements [lindex [lindex $helpli 0] 0]
	       lappend titlelist    $title
	       lappend elementslist $elements
	       set title     ""
	       set elements  ""
	       set title [concat $title {ID BLOCKS FILE_ID}]
	       set liid     ""
	       set liblocks ""
	       set lifiles  ""
	       set extnum [llength $helpli]
	       foreach elem $helpli {
	            append liid     [format "$ODv_f_nrsmall" [lindex $elem 1]]
	            append liblocks [format "$ODv_f_nrsmall" [lindex $elem 2]]
	            append lifiles  [format "$ODv_f_nrsmall" [lindex $elem 3]]
	       }
	       lappend elements $liid
	       lappend elements $liblocks
	       lappend elements $lifiles
	    }
    } else { ## with devices 
       if {[llength $helpli] == 0} {
	  lappend titlelist    $title
	  lappend elementslist $elements
	  set title     ""
	  set elements  ""
	  lappend elements "No User-Object"
       } else {
          lappend title TABLESPACE_NAME
          lappend elements [lindex [lindex $helpli 0] 0]
	  lappend titlelist    $title
	  lappend elementslist $elements
	  set title     ""
	  set elements  ""
       	  set title [concat $title {ID BLOCKS FILE_ID DEVICE_ID}]
          set liid     ""
          set liblocks ""
          set lifiles  ""
          set lidev    ""
	  set extnum [llength $helpli]
          foreach elem $helpli {
            append liid     [format "$ODv_f_nrsmall" [lindex $elem 1]]
            append liblocks [format "$ODv_f_nrsmall" [lindex $elem 2]]
            append lifiles  [format "$ODv_f_nrsmall" [lindex $elem 3]]
            append lidev    [format "$ODv_f_nrsmall" [lindex $elem 4]]
         }
         lappend elements $liid
         lappend elements $liblocks
         lappend elements $lifiles
         lappend elements $lidev
       }
    }

} else { ### with dba-grants
    if {[llength $helpli] == 0} {
       lappend titlelist    $title
       lappend elementslist $elements
       set title     ""
       set elements  ""
       lappend elements "No Accessibble-Object"
    } else {
       lappend title TABLESPACE_NAME
       lappend elements [lindex [lindex $helpli 0] 0]
       lappend titlelist    $title
       lappend elementslist $elements
       set title     ""
       set elements  ""
       set title [concat $title {ID BLOCKS FILE_ID DEVICE_ID}]
       set liid     ""
       set liblocks ""
       set lifiles  ""
       set lidev    ""
       set extnum [llength $helpli]
       foreach elem $helpli {
            append liid     [format "$ODv_f_nrsmall" [lindex $elem 1]]
            append liblocks [format "$ODv_f_nrsmall" [lindex $elem 2]]
            append lifiles  [format "$ODv_f_nrsmall" [lindex $elem 3]]
            append lidev    [format "$ODv_f_nrsmall" [lindex $elem 4]]
       }
       lappend elements $liid
       lappend elements $liblocks
       lappend elements $lifiles
       lappend elements $lidev
    }
}


### show statistics for object

lappend titlelist    $title
lappend elementslist $elements
set title    ""
set elements ""

set helpli ""

if {[string compare $obj_type TABLE] == 0} { ### Statistics for tables

   OD_Msg "Searching for statistics..."

   orasql $ODv_oracursor "select num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len from all_tables  where table_name = '$obj_name' and owner = '$obj_owner'"

   orafetch $ODv_oracursor {lappend helpli @1 @2 @3 @4 @5 @6}

   if  {[llength $helpli] == 0} {
       lappend elements "No Statistics for"
       lappend elements "Table accessible"
   } else {
	if {[lindex $helpli 0] == 0} { # no statistics
           lappend elements "No current Statistics"
           lappend elements "for Table available"
	} else {
       	   set title [concat $title {NUM_ROWS BLOCKS EMPTY_BLOCKS AVG_SPACE CHAIN_CNT AVG_ROW_LEN}]
           lappend elements [lindex $helpli 0]
           lappend elements [lindex $helpli 1]
           lappend elements [lindex $helpli 2]
           lappend elements [lindex $helpli 3]
           lappend elements [lindex $helpli 4]
           lappend elements [lindex $helpli 5]
        }
   }

   set ODv_alloldtag "allTables"
   catch {OD_Help_Graph_Modify "allTables"}

} elseif {[string compare $obj_type INDEX] == 0 } {### statistics for Index

   OD_Msg "Searching for data..."

   orasql $ODv_oracursor "select blevel, leaf_blocks, distinct_keys, avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor from all_indexes where index_name = '$obj_name' and owner = '$obj_owner'"

   orafetch $ODv_oracursor {lappend helpli @1 @2 @3 @4 @5 @6}

   if  {[llength $helpli] == 0} {
       lappend elements "No Statistics for"
       lappend elements "Index accessible"
   } else {
	if {[lindex $helpli 3] == 0} { # no statistics
	        lappend elements "No current Statistics"
	        lappend elements "for Index available"	
	} else {
	       set title [concat $title { BLEVEL LEAF_BLOCKS DIST_KEYS AVG_LEAF_BLOCKS AVG_DATA_BLOCKS CLUSTER_FACTOR}]
	       lappend elements [lindex $helpli 0]
	       lappend elements [lindex $helpli 1]
	       lappend elements [lindex $helpli 2]
	       lappend elements [lindex $helpli 3]
	       lappend elements [lindex $helpli 4]
	       lappend elements [lindex $helpli 5]
	}
   }

   set ODv_usroldtag "allIndexes"
   catch {OD_Help_Graph_Modify "allIndexes"}

} elseif {[string compare $obj_type CLUSTER] == 0} {### statistics for Cluster

   OD_Msg "Searching for data..."

   set error 0
   set error [catch {orasql $ODv_oracursor "select pct_free, pct_used, key_size, next_extent, min_extents, max_extents,  pct_increase, avg_blocks_per_key, cluster_type,  function, hashkeys  from dba_clusters  where cluster_name = '$obj_name" and owner = '$obj_owner'}]

   orafetch $ODv_oracursor {lappend helpli @0}

   if  {$error == 1} { ### no dba-grants

   	orasql $ODv_oracursor "select pct_free, pct_used, key_size, next_extent, min_extents, max_extents,  pct_increase, avg_blocks_per_key, cluster_type,  function, hashkeys  from user_clusters  where cluster_name = '$obj_name'"

   	orafetch $ODv_oracursor {lappend helpli @1 @2 @3 @4 @5 @6 @7 @8 @9}

   	if  {[llength $helpli] == 0} {
	       lappend elements "No Statistics of User"
	       lappend elements "-Cluster accessible"
	   } else {
		if {[lindex $helpli 0] == 0} {
  		   lappend title    ""
	           lappend elements ""
	           lappend title    "No current Statistics of"
	           lappend elements "User-Cluster available"
		} else {
		   set title [concat $title {PCT_FREE KEY_SIZE NEXT_EXTENT MIN_EXTENTS MAX_EXTENTS PCT_INCREASE AVG_BLOCKS CLUSTER_TYPE FUNCTION HASHKEYS}]
		   lappend elements [lindex $helpli 0]
	           lappend elements [lindex $helpli 1]
	           lappend elements [lindex $helpli 2]
	           lappend elements [lindex $helpli 3]
	           lappend elements [lindex $helpli 4]
	           lappend elements [lindex $helpli 5]
	           lappend elements [lindex $helpli 6]
	           lappend elements [lindex $helpli 7]
	           lappend elements [lindex $helpli 8]
	           lappend elements [lindex $helpli 9]
		}
	   }

	   set ODv_usroldtag "usrClusters"
	   catch {OD_Help_Graph_Modify "usrClusters"}
   } else {
	if  {[llength $helpli] == 0} {
	       lappend elements "No Statistics for"
	       lappend elements "Cluster accessible"
	   } else {
		if {[lindex $helpli 0] == 0} {
	           lappend elements "No current Statistics for"
	           lappend elements "User-Cluster available"
	        } else {
		   set title [concat $title {PCT_FREE KEY_SIZE NEXT_EXTENT MIN_EXTENTS MAX_EXTENTS PCT_INCREASE AVG_BLOCKS CLUSTER_TYPE FUNCTION HASHKEYS}]
		   lappend elements [lindex $helpli 0]
		   lappend elements [lindex $helpli 1]
		   lappend elements [lindex $helpli 2]
		   lappend elements [lindex $helpli 3]
		   lappend elements [lindex $helpli 4]
		   lappend elements [lindex $helpli 5]
		   lappend elements [lindex $helpli 6]
		   lappend elements [lindex $helpli 7]
	 	   lappend elements [lindex $helpli 8]
		   lappend elements [lindex $helpli 9]
		}
	   }
	set ODv_sysoldtag "sysClusters"
	catch {OD_Help_Graph_Modify "sysClusters"}
   } 
} else {
  lappend elements "No Statistics for"
  lappend elements "Object accessible"
}


### show window

lappend titlelist    $title
lappend elementslist $elements

OD_Msg "Searching finished, getting results..."

set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}

if {$ODv_windows == "one"} {
   ShowWindow.tl_ExplainObjDetails .tl_sysdatafiles $titlelist $elementslist "Explain-Object-Details for $obj_name" $extnum
} elseif {$ODv_windows == "many"} {
   ShowWindow.tl_ExplainObjDetails .tl_sysdatafiles $titlelist $elementslist "Explain-Object-Details for $obj_name"  $extnum
} else {incr ODv_wincount
   ShowWindow.tl_ExplainObjDetails .$ODv_wincount $titlelist $elementslist "Explain-Object-Details for $obj_name"  $extnum
}

}



##########################
# OD_ExplainFullTree  #
##########################

# Regine Kasten
# select the full explainplan information 
proc OD_ExplainFullTree { parentwname} {

global ODv_ExplainListWins
global ODv_ExplainListLists
global ODv_ExplainListIds
global ODv_ExplainList
global ODv_ExplainIds

 # which window is selected
set pos             [lsearch $ODv_ExplainListWins  $parentwname]
 # which explainplan
set ODv_ExplainList [lindex  $ODv_ExplainListLists $pos]
 # which ids and parentids
set ODv_ExplainIds  [lindex  $ODv_ExplainListIds   $pos]

OD_ShowExplainTree $parentwname $ODv_ExplainList $ODv_ExplainIds

}

