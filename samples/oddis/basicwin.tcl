#################################################################
# Show window - procedures                                      #
#################################################################



################################
# Show window : Messages       #
################################


proc ShowWindow.tl_info { args} {


catch "destroy .tl_info"

toplevel .tl_info   -relief {raised}

# Window manager configurations
wm positionfrom .tl_info program
wm sizefrom .tl_info program
wm geometry .tl_info 671x30
wm minsize .tl_info 175 30
wm title .tl_info {ODDIS - Messages}


frame .tl_info.fr_msg  -borderwidth {2}  -relief {raised}
message .tl_info.fr_msg.mg_msg  -aspect {2000}  -padx {5}  -pady {2}  -text {}

pack append .tl_info.fr_msg  .tl_info.fr_msg.mg_msg {left frame center fill}

pack append .tl_info  .tl_info.fr_msg {top frame center expand fill}

}


#################################
# Show window : Results         #
#################################


proc ShowWindow.tl_result { args} {


catch "destroy .tl_result"

toplevel .tl_result   -relief {raised}

# Window manager configurations
wm positionfrom .tl_result program
wm sizefrom .tl_result program
wm geometry .tl_result 472x150
wm minsize .tl_result 310 150
wm title .tl_result {ODDIS - Results}

frame .tl_result.fr_menu  -borderwidth {2}  -relief {raised}
menubutton .tl_result.fr_menu.option  -menu {.tl_result.fr_menu.option.m}  -text {Options} -underline {0} 
menu .tl_result.fr_menu.option.m
  .tl_result.fr_menu.option.m add radiobutton  -command {set ODv_appendclear 0
}  -label {Append Result} -underline {0}  -value {0}  -variable {ODv_appendclear}
  .tl_result.fr_menu.option.m add radiobutton  -command {set ODv_appendclear 1
}  -label {Clear Result} -underline {0}  -value {1}  -variable {ODv_appendclear}
  .tl_result.fr_menu.option.m add cascade  -label {Fontsize}  -underline {0} -menu {.tl_result.fr_menu.option.m.fs} 
menu .tl_result.fr_menu.option.m.m
menu .tl_result.fr_menu.option.m.fs
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-8-*-*-*-*-*-*-*
}  -label {  8}  -value { 8}  -variable {ODv_resultfontsize}
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-10-*-*-*-*-*-*-*
}  -label {10}  -value {10}  -variable {ODv_resultfontsize}
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-12-*-*-*-*-*-*-*
}  -label {12}  -value {12}  -variable {ODv_resultfontsize}
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-14-*-*-*-*-*-*-*
}  -label {14}  -value {14}  -variable {ODv_resultfontsize}
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-17-*-*-*-*-*-*-*
}  -label {17}  -value {17}  -variable {ODv_resultfontsize}
  .tl_result.fr_menu.option.m.fs add radiobutton  -command {.tl_result.fr_result.lb_result configure  -font -*-courier-*-r-*-*-20-*-*-*-*-*-*-*}  -label {20}  -value {20}  -variable {ODv_resultfontsize}

pack append .tl_result.fr_menu  .tl_result.fr_menu.option {left frame center}

frame .tl_result.fr_result  -borderwidth {2}  -relief {raised}
scrollbar .tl_result.fr_result.sb_vresult  -command {.tl_result.fr_result.lb_result yview}  -relief {raised}
scrollbar .tl_result.fr_result.sb_hresult  -command {.tl_result.fr_result.lb_result xview}  -orient {horizontal}  -relief {raised}
listbox .tl_result.fr_result.lb_result  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {10} -height {2}  -relief {raised}  -xscrollcommand {.tl_result.fr_result.sb_hresult set}  -yscrollcommand {.tl_result.fr_result.sb_vresult set}

pack append .tl_result.fr_result  .tl_result.fr_result.sb_vresult {left frame center filly}  .tl_result.fr_result.sb_hresult {bottom frame center fillx}  .tl_result.fr_result.lb_result {right frame center expand fill}

frame .tl_result.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_result.fr_cmd.bn_clear  -command {OD_ClearResult}  -text {Clear}
button .tl_result.fr_cmd.bn_saveas  -command {OD_FileBox .saveresults * "" OD_SaveResult}  -text {Save as...}
button .tl_result.fr_cmd.bn_print  -command {OD_PrintResult}  -text {Print}

pack append .tl_result.fr_cmd  .tl_result.fr_cmd.bn_clear {left frame center expand fillx}  .tl_result.fr_cmd.bn_saveas {left frame center expand fillx}  .tl_result.fr_cmd.bn_print {left frame center expand fillx}

pack append .tl_result  .tl_result.fr_menu {top frame center fillx}  .tl_result.fr_result {top frame center expand fill}  .tl_result.fr_cmd {top frame center fillx}

tk_menuBar .tl_result.fr_menu .tl_result.fr_menu.option
  
}


#################################
# Show window : Main-Window     #
#################################


proc ShowWindow.tl_main { args} {

catch "destroy .tl_main"

toplevel .tl_main   -relief {raised}

# Window manager configurations
wm positionfrom .tl_main program
wm sizefrom .tl_main program
wm geometry .tl_main 620x209
wm minsize .tl_main 350 200
wm maxsize .tl_main 620 700
wm title .tl_main {ODDIS - Main-Window}

frame .tl_main.fr_menu  -borderwidth {2}  -relief {raised}


menubutton .tl_main.fr_menu.file  -menu {.tl_main.fr_menu.file.m}  -text {File} 

menu .tl_main.fr_menu.file.m
  .tl_main.fr_menu.file.m add command  -command {OD_ClearAll}  -label {New} -underline {0}  
  .tl_main.fr_menu.file.m add command  -command {OD_FileBox .open * "" OD_FileOpen}  -label {Open...} -underline {0}  
  .tl_main.fr_menu.file.m add command  -command {OD_FileSave}  -label {Save} -underline {0}  
  .tl_main.fr_menu.file.m add command  -command {OD_FileBox .saveas * "" OD_FileSaveAs}  -label {Save as...} -underline {5}  
  .tl_main.fr_menu.file.m add separator
  .tl_main.fr_menu.file.m add command  -command {OD_ExitODDIS}  -label {Quit} -underline {0}  


menubutton .tl_main.fr_menu.op  -menu {.tl_main.fr_menu.op.m}  -text {Options}   

menu .tl_main.fr_menu.op.m
  .tl_main.fr_menu.op.m add cascade  -label {AutoCommit} -underline {0}  -menu {.tl_main.fr_menu.op.m.ac}  -state {active}  
  .tl_main.fr_menu.op.m add cascade  -label {Fontsize} -underline {0}  -menu {.tl_main.fr_menu.op.m.fs}  
  .tl_main.fr_menu.op.m add cascade  -label {Windows} -underline {0}  -menu {.tl_main.fr_menu.op.m.wd}  
  .tl_main.fr_menu.op.m add cascade  -label {Display} -underline {0}  -menu {.tl_main.fr_menu.op.m.dis}  

menu .tl_main.fr_menu.op.m.ac
  .tl_main.fr_menu.op.m.ac add radiobutton  -command {oraautocom $ODv_orahandle on; OD_Msg "AutoCommit on"}  -label {On}  -value {on}  -variable {ODv_autocommit}
  .tl_main.fr_menu.op.m.ac add radiobutton  -command {oraautocom $ODv_orahandle off; OD_Msg "AutoCommit off"}  -label {Off}  -value {off}  -variable {ODv_autocommit}

menu .tl_main.fr_menu.op.m.wd
  .tl_main.fr_menu.op.m.wd add radiobutton  -command {set ODv_windows one} -label {One Window per Object} -value {one}  -variable  {ODv_windows}
  .tl_main.fr_menu.op.m.wd add radiobutton  -command {set ODv_windows many} -label {One Window per Relation} -value {many}  -variable  {ODv_windows}
  .tl_main.fr_menu.op.m.wd add radiobutton  -command {set ODv_windows much} -label {One Window per Query} -value {much}  -variable  {ODv_windows}

menu .tl_main.fr_menu.op.m.dis
  .tl_main.fr_menu.op.m.dis add radiobutton  -command {OD_Display} -label {Colour/Grey} -value {colour}  -variable  {ODv_display}
  .tl_main.fr_menu.op.m.dis add radiobutton  -command {OD_Display} -label {Monochrome} -value {mono}  -variable {ODv_display}

OD_Display

menu .tl_main.fr_menu.op.m.fs
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-8-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {8}  -value {8}  -variable {ODv_fontsize}
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-10-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {10}  -value {10}  -variable {ODv_fontsize}
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-12-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {12}  -value {12}  -variable {ODv_fontsize}
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-14-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {14}  -value {14}  -variable {ODv_fontsize}
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-17-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {17}  -value {17}  -variable {ODv_fontsize}
  .tl_main.fr_menu.op.m.fs add radiobutton  -command {set ODv_font -*-courier-*-r-*-*-20-*-*-*-*-*-*-*; OD_ChangeFontsize}  -label {20}  -value {20}  -variable {ODv_fontsize}


menubutton .tl_main.fr_menu.option  -menu {.tl_main.fr_menu.option.m}  -text {SQL-Options} 

menu .tl_main.fr_menu.option.m
  .tl_main.fr_menu.option.m add command  -command {oracommit $ODv_orahandle; OD_Msg "Committed"}  -label {Commit now} -underline {0}  
  .tl_main.fr_menu.option.m add command  -command {oraroll $ODv_orahandle; OD_Msg "Rolled back"}  -label {Rollback now} -underline {4}  
  .tl_main.fr_menu.option.m add separator
  .tl_main.fr_menu.option.m add command  -command {OD_LongFile Write}  -label {Write Long Col...} -underline {0}  
  .tl_main.fr_menu.option.m add command  -command {OD_LongFile Read}   -label {Read Long Col...} -underline {0}  
  .tl_main.fr_menu.option.m add separator
  .tl_main.fr_menu.option.m add command  -command {OD_PLExec}          -label {Procedure Exec...} -underline {0}  


menubutton .tl_main.fr_menu.usr  -menu {.tl_main.fr_menu.usr.m}  -text {User-Objects}   

menu .tl_main.fr_menu.usr.m
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserTables}  -label {Tables} -underline {0}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserColumns}  -label {Columns} -underline {0} 
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserIndexes}  -label {Indexes} -underline {0}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserViews}  -label {Views} -underline {0}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserClusters}  -label {Clusters} -underline {1}  
  .tl_main.fr_menu.usr.m add separator
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserTablespaces}  -label {Tablespaces} -underline {2}
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserExtents}  -label {Extents} -underline {0}
  .tl_main.fr_menu.usr.m add separator
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserSequences}  -label {Sequences} -underline {0}
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserDBLinks}  -label {DB-Links} -underline {0}
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserSynonyms}  -label {Synonyms} -underline {1}
  .tl_main.fr_menu.usr.m add separator
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserConstraints}  -label {Constraints} -underline {2}
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserTriggers}  -label {Triggers} -underline {3}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserProcedures}  -label {Procedures} -underline {2}
  .tl_main.fr_menu.usr.m add separator
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserRoles}  -label {Roles} -underline {0}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserPrivileges}  -label {Privileges} -underline {0}
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserGrantstoUser}  -label {GrantstoUser} -underline {0}  
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowUserGrantsbyUser}  -label {GrantsbyUser} -underline {3}  
 .tl_main.fr_menu.usr.m add separator
  .tl_main.fr_menu.usr.m add command  -command {OD_ShowWindow.ow_usrfindobject .ow_usrfindobject "Find User-Object"}  -label {Find...} -underline {0}  

 
menubutton .tl_main.fr_menu.all  -menu {.tl_main.fr_menu.all.m}  -text {All-Objects}   

menu .tl_main.fr_menu.all.m
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllTables}  -label {Tables} -underline {0}  
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllColumns}  -label {Columns} -underline {0} 
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllIndexes}  -label {Indexes} -underline {0}  
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllViews}  -label {Views} -underline {0}  
  .tl_main.fr_menu.all.m add separator
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllTablespaces}  -label {Tablespaces} -underline {2}
  .tl_main.fr_menu.all.m add separator
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllSequences}  -label {Sequences} -underline {0}
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllDBLinks}  -label {DB-Links} -underline {0}
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllSynonyms}  -label {Synonyms} -underline {1}
  .tl_main.fr_menu.all.m add separator
.tl_main.fr_menu.all.m add command  -command {OD_ShowAllConstraints}  -label {Constraints} -underline {2}
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllTriggers}  -label {Triggers} -underline {3}  
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllProcedures}  -label {Procedures} -underline {2}  
  .tl_main.fr_menu.all.m add separator
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllGrantstoUser}  -label {GrantstoPublic/User} -underline {0}  
  .tl_main.fr_menu.all.m add command  -command {OD_ShowAllGrantsbyUser}  -label {GrantsbyUser} -underline {3}  
 .tl_main.fr_menu.all.m add separator
  .tl_main.fr_menu.all.m add command  -command {OD_ShowWindow.ow_allfindobject .ow_allfindobject "Find accessible Object"}  -label {Find...} -underline {0}  


menubutton .tl_main.fr_menu.system  -menu {.tl_main.fr_menu.system.m}  -text {System}  

menu .tl_main.fr_menu.system.m
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysUserList}  -label {User List} -underline {0}  
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysTablespaces}  -label {Tablespaces} -underline {2}  
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysRoles}  -label {Roles} -underline {1}  
  .tl_main.fr_menu.system.m add separator
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysRollbackSegs}  -label {Rollback Segs}  -underline {0}  
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysFreeSpaceSum}  -label {Free Space}     -underline {0}  
  .tl_main.fr_menu.system.m add command  -command {OD_TryShowSysDataFiles}     -label {Data Files}     -underline {0}  
  .tl_main.fr_menu.system.m add cascade  -label   {Devices} -underline {1} -menu {.tl_main.fr_menu.system.m.dev}
  .tl_main.fr_menu.system.m add separator
 .tl_main.fr_menu.system.m add command  -command {OD_ShowWind.ow_sysfindobject .ow_sysfindobject "Find Object" }  -label {Find...}     -underline {1}  
 
# Regine Kasten
menu .tl_main.fr_menu.system.m.dev
  .tl_main.fr_menu.system.m.dev add command  -command {OD_TryShowSysDevicesAll}     -label {All}       -underline {1}
  .tl_main.fr_menu.system.m.dev add command  -command {OD_TryShowSysDevicesOra}  -label {Oracle}    -underline {1}
  .tl_main.fr_menu.system.m.dev add separator
  .tl_main.fr_menu.system.m.dev add command  -command {OD_TryShowSysDevTables}   -label {DevTables} -underline {1}

# Regine Kasten
menubutton .tl_main.fr_menu.optimize  -menu {.tl_main.fr_menu.optimize.m}  -text {Optimize}  

menu .tl_main.fr_menu.optimize.m
  .tl_main.fr_menu.optimize.m add cascade -label {Analyze} -underline {0} -menu {.tl_main.fr_menu.optimize.m.an}  
  .tl_main.fr_menu.optimize.m add separator
  .tl_main.fr_menu.optimize.m add cascade -label {Explain} -underline {0} -menu {.tl_main.fr_menu.optimize.m.ex}
  
menu .tl_main.fr_menu.optimize.m.an
 .tl_main.fr_menu.optimize.m.an add command -command {OD_ShowAnalyzeTables}  -label {Tables}  -underline {0}
 .tl_main.fr_menu.optimize.m.an add command -command {OD_ShowAnalyzeIndexes} -label {Indexes} -underline {0}
 .tl_main.fr_menu.optimize.m.an add separator
 .tl_main.fr_menu.optimize.m.an add command -command {OD_ShowAnalyzeCluster} -label {Cluster} -underline {0}
  
menu .tl_main.fr_menu.optimize.m.ex
 .tl_main.fr_menu.optimize.m.ex add command -command {OD_ShowExplainPlan Choose}     -label {Choose}     -underline {0}
 .tl_main.fr_menu.optimize.m.ex add separator
 .tl_main.fr_menu.optimize.m.ex add command -command {OD_ShowExplainPlan All_Rows}   -label {All Rows}   -underline {0}
 .tl_main.fr_menu.optimize.m.ex add command -command {OD_ShowExplainPlan First_Rows} -label {First Rows} -underline {0}
 .tl_main.fr_menu.optimize.m.ex add command -command {OD_ShowExplainPlan Rule}       -label {Rule}       -underline {0}


button .tl_main.fr_menu.execute -command {eval $ODv_cmdExec} -relief {flat} -text {Execute}

menubutton .tl_main.fr_menu.help  -menu {.tl_main.fr_menu.help.m}  -text {Help} 

menu .tl_main.fr_menu.help.m
  .tl_main.fr_menu.help.m add command  -command {OD_ShowHelpOraTopics}  -label {Oracle} -underline {0}  
  .tl_main.fr_menu.help.m add command  -command {OD_HelpUserObjects} -label {User-Objects Structure} -underline {0} 
  .tl_main.fr_menu.help.m add command  -command {OD_HelpAllObjects}  -label {All-Objects Structure} -underline {0}  
  .tl_main.fr_menu.help.m add command  -command {OD_HelpSystem}  -label {System-Structure} -underline {0}  
  .tl_main.fr_menu.help.m add command  -command {OD_HelpAboutODDIS}  -label {About ODDIS ...} -underline {7}  


pack append .tl_main.fr_menu  .tl_main.fr_menu.file {left frame center}  .tl_main.fr_menu.op {left frame center}  .tl_main.fr_menu.option {left frame center}  .tl_main.fr_menu.usr {left frame center} .tl_main.fr_menu.all {left frame center}  .tl_main.fr_menu.system {left frame center} .tl_main.fr_menu.optimize {left frame center}  .tl_main.fr_menu.execute {left frame center}  .tl_main.fr_menu.help {right frame center}


frame .tl_main.fr_statement  -borderwidth {2}  -relief {raised}
scrollbar .tl_main.fr_statement.sb_statement  -command {.tl_main.fr_statement.tx_statement yview}  -relief {raised}
label .tl_main.fr_statement.lb_statement  -relief {ridge}  -text {SQL-Statement}
text .tl_main.fr_statement.tx_statement  -height {200}  -relief {raised}  -width {96}  -wrap {word}  -yscrollcommand {.tl_main.fr_statement.sb_statement set}
  # bindings
  bind .tl_main.fr_statement.tx_statement <Control-Key-Down> {OD_PrevSQL 1}
  bind .tl_main.fr_statement.tx_statement <Control-Key-Return> {.tl_main.fr_menu.execute invoke}
  bind .tl_main.fr_statement.tx_statement <Control-Key-Up> {OD_PrevSQL -1}
  bind .tl_main.fr_statement.tx_statement <Shift-Key-Down> {OD_PrevSQL 1}
  bind .tl_main.fr_statement.tx_statement <Shift-Key-Return> {.tl_main.fr_menu.execute invoke}
  bind .tl_main.fr_statement.tx_statement <Shift-Key-Up> {OD_PrevSQL -1}
 
pack append .tl_main.fr_statement  .tl_main.fr_statement.lb_statement {top frame center fillx}  .tl_main.fr_statement.sb_statement {left frame center filly}  .tl_main.fr_statement.tx_statement {top frame center fillx}

pack append .tl_main  .tl_main.fr_menu {top frame center fillx}  .tl_main.fr_statement {top frame center expand fill}


tk_menuBar .tl_main.fr_menu .tl_main.fr_menu.file .tl_main.fr_menu.option .tl_main.fr_menu.usr .tl_main.fr_menu.all .tl_main.fr_menu.system .tl_main.fr_menu.optimize .tl_main.fr_menu.help .tl_main.fr_menu.op


.tl_main.fr_statement.tx_statement insert end {}
}


##################################################
# Following two main procedures creating windows #
##################################################


#Procedure: CreateWindow
proc CreateWindow {wname title args} {

catch "destroy $wname"

toplevel $wname   -relief {raised}

if {[llength $args] == 0} {
  set geom 450x350
  set min1 400
  set min2 300
} else {
  set geom [lindex $args 0]
  set min1 [lindex $args 1]
  set min2 [lindex $args 2]
}

# Window manager configurations
wm positionfrom $wname program
wm sizefrom     $wname program
wm geometry     $wname $geom
wm minsize      $wname $min1 $min2
wm title        $wname $title 
}


#Procedure: FillWindow
proc FillWindow {wname li headline} {

global ODv_font

frame $wname.fr_list  -borderwidth {2}  -relief {raised}
scrollbar $wname.fr_list.sb_vlist  -command "$wname.fr_list.lb_list yview"  -relief {raised}
scrollbar $wname.fr_list.sb_hlist  -command "OD_HScrollCmd $wname"  -orient {horizontal}  -relief {raised}
listbox $wname.fr_list.lb_head  -exportselection {0}  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {1} -height {1}  -relief {ridge}  -xscrollcommand "$wname.fr_list.sb_hlist set"
listbox $wname.fr_list.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {10} -height {10}  -relief {raised}  -xscrollcommand "$wname.fr_list.sb_hlist set"  -yscrollcommand "$wname.fr_list.sb_vlist set"
pack append $wname.fr_list  $wname.fr_list.sb_vlist {left frame center filly}  $wname.fr_list.sb_hlist {bottom frame center fillx}  $wname.fr_list.lb_head {top frame center fillx}  $wname.fr_list.lb_list {top frame center expand fill}

frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_row -text "View Row" -borderwidth 2 -relief raised -command "catch \{OD_GenWinRow \[list $headline\] \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"
button $wname.fr_cmd.bn_cancel -text "Dismiss" -command "destroy $wname" -borderwidth 2 -relief raised
pack $wname.fr_cmd.bn_row -side left -fill x -expand 1
pack $wname.fr_cmd.bn_cancel -side left -fill x -expand 1

pack append $wname  $wname.fr_menu {top frame center fillx}  $wname.fr_list {top frame center expand fill}  $wname.fr_cmd {bottom frame center fillx}

$wname.fr_list.lb_head configure -font $ODv_font
$wname.fr_list.lb_list configure -font $ODv_font
$wname.fr_list.lb_head delete 0 end
$wname.fr_list.lb_list delete 0 end

$wname.fr_list.lb_head insert end $headline
foreach elem $li {
  $wname.fr_list.lb_list insert end $elem
  }
}


##################################
# User - Windows                 #
##################################


###################################
# Show window : User-Tables       #
###################################


proc ShowWindow.ow_usrTables { wname li headline title } {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablemenu  -menu "$wname.fr_menu.tablemenu.m" -text {Table-Menu} -underline {0}  
menu $wname.fr_menu.tablemenu.m
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {10}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableTablespace \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableExtents \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableSynonyms  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \} "  -label {Synonyms} -underline {0}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableConstraints \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Constraints} -underline {7}
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Triggers} -underline {3} 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableRoles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Roles} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableGrants  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grants} -underline {0}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableDetails \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Details} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {1}  
pack append $wname.fr_menu  $wname.fr_menu.tablemenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablemenu
}


##################################
# Show window : User-Columns     #
##################################


proc ShowWindow.ow_usrColumns { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.columnmenu  -menu "$wname.fr_menu.columnmenu.m" -text {Column-Menu} -underline {0}  
menu $wname.fr_menu.columnmenu.m
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnClusterColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster-Column} -underline {1}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnConstraints  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Constraints} -underline {7}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Triggers} -underline {3}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnGrants  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grants} -underline {0}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnComments  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.columnmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.columnmenu
}


##################################
# Show window : User-Indexes     #
##################################


proc ShowWindow.ow_usrIndexes { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.indexmenu  -menu "$wname.fr_menu.indexmenu.m" -text {Index-Menu} -underline {0}  
menu $wname.fr_menu.indexmenu.m
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexExtents  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.indexmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.indexmenu
  }


################################
# Show window : User-Views     #
################################


proc ShowWindow.ow_usrViews { wname li headline title} { 


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.viewmenu  -menu "$wname.fr_menu.viewmenu.m" -text {View-Menu} -underline {0}  
menu $wname.fr_menu.viewmenu.m
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewBaseTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Tables} -underline {5}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewBaseViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Views} -underline {0}   
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {0}
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewBaseObjects \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Objects} -underline {5}
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewSynonyms \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewGrants \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Grants} -underline {0} 
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewText \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Text} -underline {2}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowUserViewComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {2}  
pack append $wname.fr_menu  $wname.fr_menu.viewmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.viewmenu
}



######################################
# Show window : User-Clusters        #
######################################

proc ShowWindow.ow_usrClusters { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustermenu  -menu "$wname.fr_menu.clustermenu.m" -text {Cluster-Menu} -underline {0}  
menu $wname.fr_menu.clustermenu.m
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterClusterColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster-Columns} -underline {8}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterExtents  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterSynonyms  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterDetails  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Details} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.clustermenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.clustermenu
}


###########################################
# Show window : User-ClusterColumn        #
###########################################

proc ShowWindow.ow_usrClusterColumns { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustercolumnmenu  -menu "$wname.fr_menu.clustercolumnmenu.m" -text {ClusterColumn-Menu} -underline {0}  
menu $wname.fr_menu.clustercolumnmenu.m
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowUserClusterColumnRefTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Referenced Table} -underline {11}  
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowUserClusterColumnRefColumn \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Referenced Column} -underline {11}
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowUserClusterColumnClusters  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
pack append $wname.fr_menu  $wname.fr_menu.clustercolumnmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.clustercolumnmenu
}


#####################################
# Show window : User-Tablespaces    #
#####################################


proc ShowWindow.ow_usrTablespaces { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablespacemenu  -menu "$wname.fr_menu.tablespacemenu.m" -text {Tablespace-Menu} -underline {2}  
menu $wname.fr_menu.tablespacemenu.m
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Clusters} -underline {1}  
  $wname.fr_menu.tablespacemenu.m add separator
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceExtents \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceUserQuota \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {User-Quota} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowUserTablespaceSegments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Segments} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.tablespacemenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablespacemenu
}


#####################################
# Show window : User-Extents        #
#####################################


proc ShowWindow.ow_usrExtents { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.extentmenu  -menu "$wname.fr_menu.extentmenu.m" -text {Extent-Menu} -underline {0}  
menu $wname.fr_menu.extentmenu.m
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowUserExtentTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
   $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowUserExtentIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Index} -underline {0}  
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowUserExtentClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.extentmenu.m add separator
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowUserExtentTablespace \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
pack append $wname.fr_menu  $wname.fr_menu.extentmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.extentmenu
}


#####################################
# Show window : User-Synomyms       #
#####################################


proc ShowWindow.ow_usrSynonyms { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.synonymmenu  -menu "$wname.fr_menu.synonymmenu.m" -text {Synonym-Menu} -underline {1}  
menu $wname.fr_menu.synonymmenu.m
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowUserSynonymTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Table} -underline {0}
   $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowUserSynonymViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowUserSynonymClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.synonymmenu.m add separator
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowUserSynonymDBLinks \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {DB-Link} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.synonymmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.synonymmenu
}


#####################################
# Show window : User-Constraints    #
#####################################


proc ShowWindow.ow_usrConstraints { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.constraintmenu  -menu "$wname.fr_menu.constraintmenu.m" -text {Constraint-Menu} -underline {7}  
menu $wname.fr_menu.constraintmenu.m
  $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowUserConstraintTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
   $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowUserConstraintColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.constraintmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.constraintmenu
}


######################################
# Show window : User-Triggers        #
######################################


proc ShowWindow.ow_usrTriggers { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.triggermenu -menu "$wname.fr_menu.triggermenu.m" -text {Trigger-Menu} -underline {3} 
menu $wname.fr_menu.triggermenu.m
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowUserTriggerTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Table} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowUserTriggerColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Columns} -underline {0}  
  $wname.fr_menu.triggermenu.m add separator
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowUserTriggerDesc \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Description} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowUserTriggerWhen \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {When} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowUserTriggerBody \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Body} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.triggermenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.triggermenu
}


#####################################
# Show window : User-Roles          #
#####################################


proc ShowWindow.ow_usrRoles { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.rolemenu  -menu "$wname.fr_menu.rolemenu.m" -text {Role-Menu} -underline {0}  
menu $wname.fr_menu.rolemenu.m
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowUserRoleTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.rolemenu.m add separator
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowUserRolePrivileges \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Privileges} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.rolemenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.rolemenu
}


###################################
# Show window : User-Grants       #
###################################


proc ShowWindow.ow_usrGrants { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.grantsmenu  -menu "$wname.fr_menu.grantsmenu.m" -text {Grants-Menu} -underline {0}  
menu $wname.fr_menu.grantsmenu.m
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowUserGrantsTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowUserGrantsColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowUserGrantsView  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.grantsmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.grantsmenu
}



#################################
# All-Objects - Windows         #
#################################


#####################################
# Show window : All-Tables          #
#####################################


proc ShowWindow.ow_allTables { wname li headline title } {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablemenu  -menu "$wname.fr_menu.tablemenu.m" -text {Table-Menu} -underline {0}  
menu $wname.fr_menu.tablemenu.m
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {10}
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableTablespace \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableSynonyms  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms} -underline {1}
  $wname.fr_menu.tablemenu.m add separator  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableConstraints \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Constraints} -underline {7}
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Triggers} -underline {3} 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableGrantsto  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Grantsto} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableGrantsby  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grantsby} -underline {3}
  $wname.fr_menu.tablemenu.m add separator 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableDetails \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Details} -underline {0} 
 $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAllTableComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {1} 
pack append $wname.fr_menu  $wname.fr_menu.tablemenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablemenu
}


#################################
# Show window : All-Columns     #
#################################


proc ShowWindow.ow_allColumns { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.columnmenu  -menu "$wname.fr_menu.columnmenu.m" -text {Column-Menu} -underline {0}  
menu $wname.fr_menu.columnmenu.m
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes}  -underline {0} 
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnConstraints  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Constraints} -underline {7}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Triggers} -underline {3}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnGrantsto  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grantsto} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnGrantsby  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grantsby}  -underline {3} 
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowAllColumnComments  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments}  -underline {0} 
pack append $wname.fr_menu  $wname.fr_menu.columnmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.columnmenu
}


#################################
# Show window : All-Indexes     #
#################################


proc ShowWindow.ow_allIndexes { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.indexmenu  -menu "$wname.fr_menu.indexmenu.m" -text {Index-Menu} -underline {0}  
menu $wname.fr_menu.indexmenu.m
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowAllIndexTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowAllIndexColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowAllIndexTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
pack append $wname.fr_menu  $wname.fr_menu.indexmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.indexmenu
}


###################################
# Show window : All-Views         #
###################################


proc ShowWindow.ow_allViews { wname li headline title} { 

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.viewmenu  -menu "$wname.fr_menu.viewmenu.m" -text {View-Menu} -underline {0}  
menu $wname.fr_menu.viewmenu.m
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewBaseTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Tables} -underline {5}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Columns} -underline {0}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewBaseViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Base Views} -underline {0}   
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {0}
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewBaseObjects \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Objects} -underline {5}
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewSynonyms \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewGrantsto \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Grantsto} -underline {0} 
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewGrantsby \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Grantsby} -underline {3}  
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewText \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Text} -underline {0}       
 $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowAllViewComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {1}  
pack append $wname.fr_menu  $wname.fr_menu.viewmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.viewmenu
}

#####################################
# Show window : All-Tablespaces     #
#####################################


proc ShowWindow.ow_allTablespaces { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablespacemenu  -menu "$wname.fr_menu.tablespacemenu.m" -text {Tablespace-Menu} -underline {2}  
menu $wname.fr_menu.tablespacemenu.m
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowAllTablespaceTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowAllTablespaceIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}   
pack append $wname.fr_menu  $wname.fr_menu.tablespacemenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablespacemenu
}


#####################################
# Show window : All objects-Synomyms#
#####################################


proc ShowWindow.ow_allSynonyms { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.synonymmenu  -menu "$wname.fr_menu.synonymmenu.m" -text {Synonym-Menu} -underline {1}  
menu $wname.fr_menu.synonymmenu.m
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowAllSynonymTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
   $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowAllSynonymViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.synonymmenu.m add separator
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowAllSynonymDBLinks \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {DB-Link} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.synonymmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.synonymmenu
}


#######################################
# Show window : All-Constraints       #
#######################################


proc ShowWindow.ow_allConstraints { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.constraintmenu  -menu "$wname.fr_menu.constraintmenu.m" -text {Constraint-Menu} -underline {7}  
menu $wname.fr_menu.constraintmenu.m
  $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowAllConstraintTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
   $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowAllConstraintColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.constraintmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.constraintmenu
}


######################################
# Show window : All-Triggers         #
######################################


proc ShowWindow.ow_allTriggers { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.triggermenu -menu "$wname.fr_menu.triggermenu.m" -text {Trigger-Menu} -underline {3} 
menu $wname.fr_menu.triggermenu.m
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowAllTriggerTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Table} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowAllTriggerColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Columns} -underline {0}  
  $wname.fr_menu.triggermenu.m add separator
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowAllTriggerDesc \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Description} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowAllTriggerWhen \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {When} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowAllTriggerBody \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Body} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.triggermenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.triggermenu
}


################################
# Show window : All-Grants     #
################################


proc ShowWindow.ow_allGrants { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.grantsmenu  -menu "$wname.fr_menu.grantsmenu.m" -text {Grants-Menu}  -underline {0} 
menu $wname.fr_menu.grantsmenu.m
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowAllGrantsTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowAllGrantsColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowAllGrantsView  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.grantsmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.grantsmenu
}



##################################
# System - Windows               #
##################################


##################################
# Show window : System-Userlist  #
##################################


proc ShowWindow.ow_sysUser { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.usermenu  -menu "$wname.fr_menu.usermenu.m"  -text {User-Menu} -underline {0}  
menu $wname.fr_menu.usermenu.m
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Tables} -underline {0} 
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "   -label {Indexes} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Views} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Clusters} -underline {1}  
  $wname.fr_menu.usermenu.m add separator
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserTablespaces \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Tablespaces} -underline {2}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserDefTablespaces \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Def. Tablespace} -underline {2}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserTempTablespaces \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Temp. Tablespace} -underline {2}  
 $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserExtents \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Extents} -underline {0}  
  $wname.fr_menu.usermenu.m add separator
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserSequences \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Sequences} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserDBLinks \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {DB-Links} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserSynonyms \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Synonyms} -underline {1}
  $wname.fr_menu.usermenu.m add separator
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserConstraints \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Constraints} -underline {2}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Triggers} -underline {3}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserProcedures \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Procedures} -underline {2}  
  $wname.fr_menu.usermenu.m add separator
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserRoles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Roles} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserPrivileges \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Privileges} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserGrantstoUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Grants to User} -underline {0}  
  $wname.fr_menu.usermenu.m add command  -command "catch \{OD_ShowSysUserGrantsbyUser \[$wname.fr_list.lb_list get  \[$wname.fr_list.lb_list curselection \]\]\} "  -label {Grants by User} -underline {3}  
pack append $wname.fr_menu  $wname.fr_menu.usermenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.usermenu
}


#####################################
# Show window : System-User-Tables  #
#####################################


proc ShowWindow.ow_sysTables { wname li headline title } {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablemenu  -menu "$wname.fr_menu.tablemenu.m"  -text {Table-Menu} -underline {0}  
menu $wname.fr_menu.tablemenu.m
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {10}
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableExtents  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableSynonyms  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableConstraints \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Constraints} -underline {7}
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Triggers} -underline {3} 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableRoles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Roles} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableGrants  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \} "  -label {Grants} -underline {0}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableDetails \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Details} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {1}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowSysTableUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {Tableowner} -underline {6} 
pack append $wname.fr_menu  $wname.fr_menu.tablemenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablemenu
}


#####################################
# Show window : System-User-Columns #
#####################################

    
proc ShowWindow.ow_sysColumns { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.columnmenu  -menu "$wname.fr_menu.columnmenu.m" -text {Column-Menu} -underline {0}  
menu $wname.fr_menu.columnmenu.m
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnClusterColumns  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster-Column} -underline {8}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnConstraints  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Constraints} -underline {7}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Triggers} -underline {3}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnGrants  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grants} -underline {0}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnComments  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments} -underline {1}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowSysColumnUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columnowner} -underline {7}  
pack append $wname.fr_menu  $wname.fr_menu.columnmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.columnmenu
}


######################################
# Show window : System-User-Indexes  #
######################################


proc ShowWindow.ow_sysIndexes { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.indexmenu  -menu "$wname.fr_menu.indexmenu.m" -text {Index-Menu} -underline {0}  
menu $wname.fr_menu.indexmenu.m
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexExtents  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}  
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexowner} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowSysIndexTableowner  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tableowner} -underline {7}  
pack append $wname.fr_menu  $wname.fr_menu.indexmenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.indexmenu
}


#####################################
# Show window : System-User-Views   #
#####################################


proc ShowWindow.ow_sysViews { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.viewmenu  -menu "$wname.fr_menu.viewmenu.m"  -text {View-Menu} -underline {0}  
menu $wname.fr_menu.viewmenu.m
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewBaseTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Tables} -underline {5}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \} "  -label {Columns} -underline {0}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewBaseViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Views} -underline {0}  
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewDepViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Dependent Views} -underline {0}
   $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewBaseObjects \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Base Objects} -underline {5}
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewSynonyms \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewGrants \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grants} -underline {0}  
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewText \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Text}  -underline {2} 
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewComments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Comments}  -underline {1} 
  $wname.fr_menu.viewmenu.m add separator
  $wname.fr_menu.viewmenu.m add command  -command "catch \{OD_ShowSysViewUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Viewowner} -underline {5}  
pack append $wname.fr_menu  $wname.fr_menu.viewmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.viewmenu
}


######################################
# Show window : System-User-Clusters #
######################################

proc ShowWindow.ow_sysClusters { wname li headline title} {

 
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustermenu  -menu "$wname.fr_menu.clustermenu.m" -text {Cluster-Menu} -underline {1}  
menu $wname.fr_menu.clustermenu.m
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterClusterColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster-Columns} -underline {8}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterTablespace  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterExtents  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterSynonyms  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Synonyms}  -underline {1} 
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterDetails  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Details} -underline {0}
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowSysClusterUser  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Clusterowner} -underline {8}  
pack append $wname.fr_menu  $wname.fr_menu.clustermenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.clustermenu
}


###########################################
# Show window : System-User-ClusterColumn #
###########################################

proc ShowWindow.ow_sysClusterColumns { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustercolumnmenu  -menu "$wname.fr_menu.clustercolumnmenu.m" -text {ClusterColumn-Menu} -underline {0}  
menu $wname.fr_menu.clustercolumnmenu.m
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowSysClusterColumnRefTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Referenced Table} -underline {11}  
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowSysClusterColumnRefColumn \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Referenced Column} -underline {11}  
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowSysClusterColumnClusters  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.clustercolumnmenu.m add separator
  $wname.fr_menu.clustercolumnmenu.m add command  -command "catch \{OD_ShowSysClusterColumnUser  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Clusterowner} -underline {8}  
pack append $wname.fr_menu  $wname.fr_menu.clustercolumnmenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.clustercolumnmenu
}


#####################################
# Show window : System-Constraints  #
#####################################


proc ShowWindow.ow_sysConstraints { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.constraintmenu  -menu "$wname.fr_menu.constraintmenu.m" -text {Constraint-Menu} -underline {7}  
menu $wname.fr_menu.constraintmenu.m
  $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowSysConstraintTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
  $wname.fr_menu.constraintmenu.m add command  -command "catch \{OD_ShowSysConstraintColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.constraintmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.constraintmenu
}

######################################
# Show window : System-User-Triggers #
######################################


proc ShowWindow.ow_sysTriggers { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.triggermenu -menu "$wname.fr_menu.triggermenu.m" -text {Trigger-Menu} -underline {3} 
menu $wname.fr_menu.triggermenu.m
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerTable \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Table} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Columns} -underline {0}  
  $wname.fr_menu.triggermenu.m add separator
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerDesc \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Description} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerWhen \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {When} -underline {0}  
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerBody \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Body} -underline {0}  
  $wname.fr_menu.triggermenu.m add separator
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerTableowner \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Tableowner} -underline {6} 
  $wname.fr_menu.triggermenu.m add command  -command  "catch \{OD_ShowSysTriggerUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \} "  -label {Triggerowner} -underline {3}
pack append $wname.fr_menu  $wname.fr_menu.triggermenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.triggermenu
}


######################################
# Show window : System-User-Grants   #
######################################


proc ShowWindow.ow_sysGrants { wname li headline title} {

  
CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.grantsmenu  -menu "$wname.fr_menu.grantsmenu.m" -text {Grants-Menu} -underline {0}  
menu $wname.fr_menu.grantsmenu.m
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsTable  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsView  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.grantsmenu.m add separator
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsOwner  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Owner} -underline {1}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsGrantor  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grantor} -underline {0}  
  $wname.fr_menu.grantsmenu.m add command  -command "catch \{OD_ShowSysGrantsGrantee  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grantee} -underline {3}  
pack append $wname.fr_menu  $wname.fr_menu.grantsmenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.grantsmenu
}


#####################################
# Show window : System-Tablespaces  #
#####################################


proc ShowWindow.ow_sysTablespaces { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablespacemenu  -menu "$wname.fr_menu.tablespacemenu.m" -text {Tablespace-Menu} -underline {2}  
menu $wname.fr_menu.tablespacemenu.m
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}
   $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Clusters} -underline {1}  
  $wname.fr_menu.tablespacemenu.m add separator
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceExtents \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Extents} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceFiles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Files} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceUserQuotas \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {User-Quotas} -underline {5}  
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceSegments \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Segments} -underline {0}  
  $wname.fr_menu.tablespacemenu.m add separator
  $wname.fr_menu.tablespacemenu.m add command  -command "OD_ShowSysTablespaceUsers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] "  -label {Users} -underline {0}
  $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceDefUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Default User} -underline {0} 
 $wname.fr_menu.tablespacemenu.m add command  -command "catch \{OD_ShowSysTablespaceTempUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Temporary User} -underline {2}  
pack append $wname.fr_menu  $wname.fr_menu.tablespacemenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablespacemenu
}


#####################################
# Show window : System-Extents      #
#####################################


proc ShowWindow.ow_sysExtents { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.extentmenu  -menu "$wname.fr_menu.extentmenu.m" -text {Extent-Menu} -underline {0}  
menu $wname.fr_menu.extentmenu.m
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowSysExtentTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}
   $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowSysExtentIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Index} -underline {0}  
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowSysExtentClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.extentmenu.m add separator
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowSysExtentTablespace \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.extentmenu.m add separator
  $wname.fr_menu.extentmenu.m add command  -command "catch \{OD_ShowSysExtentUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\}"  -label {Owner} -underline {1}  
pack append $wname.fr_menu  $wname.fr_menu.extentmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.extentmenu
}


#####################################
# Show window : System-Synomyms     #
#####################################


proc ShowWindow.ow_sysSynonyms { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.synonymmenu  -menu "$wname.fr_menu.synonymmenu.m" -text {Synonym-Menu} -underline {1}  
menu $wname.fr_menu.synonymmenu.m
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Table} -underline {0}
   $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymClusters \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.synonymmenu.m add separator
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymDBLinks \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {DB-Link} -underline {0}  
  $wname.fr_menu.synonymmenu.m add separator
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymUser \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \} "  -label {Synonymowner} -underline {9}  
  $wname.fr_menu.synonymmenu.m add command  -command "catch \{OD_ShowSysSynonymObjectOwner \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Objectowner}
pack append $wname.fr_menu  $wname.fr_menu.synonymmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.synonymmenu
}


#####################################
# Show window : System-Roles        #
#####################################


proc ShowWindow.ow_sysRoles { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.rolemenu  -menu "$wname.fr_menu.rolemenu.m" -text {Role-Menu} -underline {0}  
menu $wname.fr_menu.rolemenu.m
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowSysRoleUsers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Users} -underline {0}  
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowSysRoleTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowSysRoleGrantedRoles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Granted Roles} -underline {0}  
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowSysRoleGrantedtoRoles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Granted to Roles}  -underline {3} 
  $wname.fr_menu.rolemenu.m add separator
  $wname.fr_menu.rolemenu.m add command  -command "catch \{OD_ShowSysRolePrivileges \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Privileges} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.rolemenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.rolemenu
}



#####################################
# Show windows : Devices            #
#####################################

#####################################
# Show window : System-All-Devices  #
#####################################

# Regine Kasten
# Procedure : ShowWindow.ow_sysdevicesall
# shows all mounted devices from unix-system
proc ShowWindow.ow_sysdevicesall { wname li headline title} {


global ODv_font

CreateWindow $wname $title 450x400 400 300

frame $wname.fr_list  -borderwidth {2}  -relief {raised}
scrollbar $wname.fr_list.sb_vlist  -command "$wname.fr_list.lb_list yview"  -relief {raised}
scrollbar $wname.fr_list.sb_hlist  -command "OD_HScrollCmd $wname"  -orient {horizontal}  -relief {raised}
listbox   $wname.fr_list.lb_head  -exportselection {0}  -width {1} -height {1}  -relief {ridge}  -xscrollcommand "$wname.fr_list.sb_hlist set"
listbox   $wname.fr_list.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {10} -height {2}  -relief {raised}  -xscrollcommand "$wname.fr_list.sb_hlist set"  -yscrollcommand "$wname.fr_list.sb_vlist set"

pack append $wname.fr_list  $wname.fr_list.sb_vlist {left frame center filly}  $wname.fr_list.sb_hlist {bottom frame center fillx}  $wname.fr_list.lb_head {top frame center fillx}  $wname.fr_list.lb_list {top frame center expand fill}

frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_row -text "View Row" -borderwidth 2 -relief raised -command "catch \{OD_GenWinRow \[list $headline\] \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"
button $wname.fr_cmd.bn_cancel -text "Dismiss" -command "destroy $wname" -borderwidth 2 -relief raised

pack $wname.fr_cmd.bn_row -side left -fill x -expand 1

pack $wname.fr_cmd.bn_cancel -side left -fill x -expand 1

pack append $wname  $wname.fr_list {top frame center expand fill}  $wname.fr_cmd {top frame center fillx}


$wname.fr_list.lb_head configure -font $ODv_font
$wname.fr_list.lb_list configure -font $ODv_font
$wname.fr_list.lb_head delete 0 end
$wname.fr_list.lb_list delete 0 end

$wname.fr_list.lb_head insert end $headline
foreach elem $li {
   $wname.fr_list.lb_list insert end $elem
}
}


##############################################
# Show window : System-Oracle-Device         #
##############################################

# Regine Kasten
# Procedure:  ShowWindow.ow_sysdevicesora
# shows only all mounted oracle-devices
proc ShowWindow.ow_sysdevicesora { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.devmenu  -menu "$wname.fr_menu.devmenu.m" -text {Device-Menu} -underline {0}  
menu $wname.fr_menu.devmenu.m
$wname.fr_menu.devmenu.m add command  -command "catch \{OD_ShowSysDevDataFiles \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Datafiles} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.devmenu {left frame center fillx}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.devmenu
}



##############################################
# Show windows : System-Device-Tables        #
##############################################

##############################################
# Show window : System-Create-Device-Tables #
##############################################

# Regine Kasten
# Procedure: ShowWindow.tl_sysdevtabcre
# Shows a dialog box for creating the device-tables 
proc ShowWindow.tl_sysdevtabcre {} {


destroy .tl_sysdevicetables

catch "destroy .tl_sysdevtabcre"

toplevel .tl_sysdevtabcre   -relief {raised}

# Window manager configurations
wm positionfrom .tl_sysdevtabcre program
wm sizefrom     .tl_sysdevtabcre program
wm maxsize      .tl_sysdevtabcre 1000 65
wm minsize      .tl_sysdevtabcre 300 65
wm title        .tl_sysdevtabcre {Creates Device-Tables}

frame .tl_sysdevtabcre.fr_inp  -borderwidth {2}
label .tl_sysdevtabcre.fr_inp.lb_inp  -text "Do you really want to drop an than create new  DEVICE-TABLES ???"

pack append .tl_sysdevtabcre.fr_inp  .tl_sysdevtabcre.fr_inp.lb_inp {left frame e}  

frame .tl_sysdevtabcre.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_sysdevtabcre.fr_cmd.bn_ok  -command {OD_DoSysDevTabCre}  -text {OK}
button .tl_sysdevtabcre.fr_cmd.bn_cancel  -command {destroy .tl_sysdevtabcre}  -text {Cancel}
button .tl_sysdevtabcre.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Device-Tables-Create Help" 600x500 590 $ODv_sysdevicecreinfo}  -text {Help}

pack append .tl_sysdevtabcre.fr_cmd  .tl_sysdevtabcre.fr_cmd.bn_ok {left frame center expand fillx}  .tl_sysdevtabcre.fr_cmd.bn_help {left frame center expand fillx}  .tl_sysdevtabcre.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_sysdevtabcre  .tl_sysdevtabcre.fr_inp {top frame center fillx}  .tl_sysdevtabcre.fr_cmd {top frame center fillx} 
}


##############################################
# Show window : System-Grant-Device-Tables   #
##############################################

# Regine Kasten
# Procedure: ShowWindow.tl_sysdevtabgra
# Shows a dialog box for granting on the device-tables
proc ShowWindow.tl_sysdevtabgra { } {


destroy .tl_sysdevicetables

catch "destroy .tl_sysdevtabgra"

toplevel .tl_sysdevtabgra   -relief {raised}

# Window manager configurations
wm positionfrom .tl_sysdevtabgra program
wm sizefrom     .tl_sysdevtabgra program
wm maxsize      .tl_sysdevtabgra 1000 100
wm minsize      .tl_sysdevtabgra 300 100
wm title        .tl_sysdevtabgra {Grants for Device-Tables}

frame .tl_sysdevtabgra.fr_message  -borderwidth {2}
message .tl_sysdevtabgra.fr_message.mg_text -aspect {1000}  -padx {5}  -pady {2}  -text {}
pack append .tl_sysdevtabgra.fr_message .tl_sysdevtabgra.fr_message.mg_text  {top frame center fillx}

frame .tl_sysdevtabgra.fr_inp  -borderwidth {2}
label .tl_sysdevtabgra.fr_inp.lb_inp  -text {grant to: }
entry .tl_sysdevtabgra.fr_inp.en_inp  -relief {sunken}
  # bindings
  bind .tl_sysdevtabgra.fr_inp.en_inp <Key-Return> {.tl_sysdevtabgra.fr_cmd.bn_ok invoke}

.tl_sysdevtabgra.fr_inp.en_inp insert 0 "DBA"

pack append .tl_sysdevtabgra.fr_inp  .tl_sysdevtabgra.fr_inp.lb_inp {left frame e}  .tl_sysdevtabgra.fr_inp.en_inp {right frame center expand fillx}

frame .tl_sysdevtabgra.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_sysdevtabgra.fr_cmd.bn_ok  -command {OD_DoSysDevTabGra}  -text {OK}
button .tl_sysdevtabgra.fr_cmd.bn_cancel  -command {destroy .tl_sysdevtabgra}  -text {Cancel}
button .tl_sysdevtabgra.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Device-Tables-Grants-Help" 350x150 310 $ODv_sysdevicegrainfo}  -text {Help}
pack append .tl_sysdevtabgra.fr_cmd  .tl_sysdevtabgra.fr_cmd.bn_ok {left frame center expand fillx}  .tl_sysdevtabgra.fr_cmd.bn_help {left frame center expand fillx}  .tl_sysdevtabgra.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_sysdevtabgra .tl_sysdevtabgra.fr_message {top frame center fillx} .tl_sysdevtabgra.fr_inp {top frame center fillx}   .tl_sysdevtabgra.fr_cmd {top frame center fillx} 

.tl_sysdevtabgra.fr_inp.en_inp insert end {}
}


##############################################
# Show window : System-Delete-Device-Tables #
##############################################

# Regine Kasten
# Procedure: ShowWindow.tl_sysdevtabdel
# Shows a dialog box for deleting from the device-tables
proc ShowWindow.tl_sysdevtabdel {} {


destroy .tl_sysdevicetables

catch "destroy .tl_sysdevtabdel"

toplevel .tl_sysdevtabdel   -relief {raised}

# Window manager configurations
wm positionfrom .tl_sysdevtabdel program
wm sizefrom     .tl_sysdevtabdel program
wm maxsize      .tl_sysdevtabdel 1000 65
wm minsize      .tl_sysdevtabdel 300 65
wm title        .tl_sysdevtabdel {Deletes Device-Tables}

frame .tl_sysdevtabdel.fr_inp  -borderwidth {2}
label .tl_sysdevtabdel.fr_inp.lb_inp  -text "Do you really want to delete the DEVICE-TABLES ???"

pack append .tl_sysdevtabdel.fr_inp  .tl_sysdevtabdel.fr_inp.lb_inp {left frame e}  

frame .tl_sysdevtabdel.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_sysdevtabdel.fr_cmd.bn_ok  -command {OD_DoSysDevTabDel}  -text {OK}
button .tl_sysdevtabdel.fr_cmd.bn_cancel  -command {destroy .tl_sysdevtabdel}  -text {Cancel}
button .tl_sysdevtabdel.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Device-Tables-Delete Help" 350x200 340 $ODv_sysdevicedelinfo}  -text {Help}

pack append .tl_sysdevtabdel.fr_cmd  .tl_sysdevtabdel.fr_cmd.bn_ok {left frame center expand fillx}  .tl_sysdevtabdel.fr_cmd.bn_help {left frame center expand fillx}  .tl_sysdevtabdel.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_sysdevtabdel  .tl_sysdevtabdel.fr_inp {top frame center fillx}  .tl_sysdevtabdel.fr_cmd {top frame center fillx} 
}


##############################################
# Show window : System-Insert-Device-Tables #
##############################################

# Regine Kasten
# Procedure: ShowWindow.tl_sysdevtabins
# Shows a dialog box for inserting into the device-tables
proc ShowWindow.tl_sysdevtabins {} {


destroy .tl_sysdevicetables

catch "destroy .tl_sysdevtabins"

toplevel .tl_sysdevtabins   -relief {raised}

# Window manager configurations
wm positionfrom .tl_sysdevtabins program
wm sizefrom     .tl_sysdevtabins program
wm maxsize      .tl_sysdevtabins 1000 65
wm minsize      .tl_sysdevtabins 300 65
wm title        .tl_sysdevtabins {Insert into Device-Tables}

frame .tl_sysdevtabins.fr_inp  -borderwidth {2}
label .tl_sysdevtabins.fr_inp.lb_inp  -text "Do you really want to insert into the DEVICE-TABLES ???"

pack append .tl_sysdevtabins.fr_inp  .tl_sysdevtabins.fr_inp.lb_inp {left frame e}  

frame .tl_sysdevtabins.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_sysdevtabins.fr_cmd.bn_ok  -command {OD_DoSysDevTabIns}  -text {OK}
button .tl_sysdevtabins.fr_cmd.bn_cancel  -command {destroy .tl_sysdevtabins}  -text {Cancel}
button .tl_sysdevtabins.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Device-Tables-Insert Help" 350x200 340 $ODv_sysdeviceinsinfo}  -text {Help}

pack append .tl_sysdevtabins.fr_cmd  .tl_sysdevtabins.fr_cmd.bn_ok {left frame center expand fillx}  .tl_sysdevtabins.fr_cmd.bn_help {left frame center expand fillx}  .tl_sysdevtabins.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_sysdevtabins  .tl_sysdevtabins.fr_inp {top frame center fillx}  .tl_sysdevtabins.fr_cmd {top frame center fillx} 
}



##############################################
# Show window : System-Device-Tables         #
##############################################

# Regine Kasten
# Procedure:  ShowWindow.tl_sysdevicetables
# shows a dialog box to give Information about Device-Tables 
proc ShowWindow.tl_sysdevicetables { } {


catch "destroy .tl_sysdevicetables"

toplevel .tl_sysdevicetables   -relief {raised}

# Window manager configurations
wm positionfrom .tl_sysdevicetables program
wm sizefrom     .tl_sysdevicetables program
wm maxsize      .tl_sysdevicetables 1000 150
wm minsize      .tl_sysdevicetables 300 65
wm title        .tl_sysdevicetables {Device-Tables}

frame .tl_sysdevicetables.fr_inp  -borderwidth {2}
label .tl_sysdevicetables.fr_inp.lb_inp1  -text "You can create the Device-Tables and give grants on them."
label .tl_sysdevicetables.fr_inp.lb_inp2  -text "You can delete the values of the Device-Tables and insert new values."

pack append .tl_sysdevicetables.fr_inp  .tl_sysdevicetables.fr_inp.lb_inp1 {top frame w}  .tl_sysdevicetables.fr_inp.lb_inp2 {top frame w}

frame .tl_sysdevicetables.fr_cmd1  -borderwidth {2}  -relief {raised}
button .tl_sysdevicetables.fr_cmd1.bn_cre  -command {ShowWindow.tl_sysdevtabcre}  -text {Create...}
button .tl_sysdevicetables.fr_cmd1.bn_gra  -command {ShowWindow.tl_sysdevtabgra}  -text {Grant...}
button .tl_sysdevicetables.fr_cmd1.bn_del  -command {ShowWindow.tl_sysdevtabdel}  -text {Delete...}
button .tl_sysdevicetables.fr_cmd1.bn_ins  -command {ShowWindow.tl_sysdevtabins}  -text {Insert...}

pack append .tl_sysdevicetables.fr_cmd1 .tl_sysdevicetables.fr_cmd1.bn_cre {left frame center expand fillx} .tl_sysdevicetables.fr_cmd1.bn_gra {left frame center expand fillx} .tl_sysdevicetables.fr_cmd1.bn_del {left frame center expand fillx} .tl_sysdevicetables.fr_cmd1.bn_ins {left frame center expand fillx}

frame .tl_sysdevicetables.fr_cmd2  -borderwidth {2}  -relief {raised}
button .tl_sysdevicetables.fr_cmd2.bn_cancel  -command {destroy .tl_sysdevicetables}  -text {Cancel}
button .tl_sysdevicetables.fr_cmd2.bn_help  -command {OD_MsgBox "ODDIS-Device-Tables Help" 390x230 380 $ODv_sysdevtablesinfo}  -text {Help}

pack append .tl_sysdevicetables.fr_cmd2 .tl_sysdevicetables.fr_cmd2.bn_help {left frame center expand fillx}  .tl_sysdevicetables.fr_cmd2.bn_cancel {left frame center expand fillx}

pack append .tl_sysdevicetables  .tl_sysdevicetables.fr_inp {top frame center fillx}  .tl_sysdevicetables.fr_cmd1 {top frame center fillx} .tl_sysdevicetables.fr_cmd2 {top frame center fillx} 
}



##########################################
# Optimize Windows	    		 #
##########################################

#####################################
# Show windows : Analyze	    #
#####################################

#####################################
# Show window : Analyze-Tables	    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzetables
# Shows user tables for analyzing
proc ShowWindow.ow_analyzetables { wname li headline title} {

CreateWindow $wname $title

set ODv_AnalyzeType {current}

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablemenu  -menu "$wname.fr_menu.tablemenu.m" -text {Analyze-Table-Menu} -underline {0}  
menu $wname.fr_menu.tablemenu.m
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowAnalyzedTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Show Statistics} -underline {0}
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_AnalyzeTablesCom   \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {compute...} -underline {0}  
   $wname.fr_menu.tablemenu.m add command -command "catch \{OD_AnalyzeTablesEst   \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {estimate...} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_AnalyzeTablesDel   \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {delete...} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.tablemenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablemenu
}


#####################################
# Show window : Analyzed-Tables	    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzedtablestab
# Shows statistics of tables for the selected table   
proc ShowWindow.ow_analyzedtablestab { wname li headline title} {


CreateWindow $wname $title 610x200 500 200

set t [lindex [split $title] 4]
set t [list $t]
set a [list {0} {1} {2} $t]

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.tablemenu  -menu "$wname.fr_menu.tablemenu.m" -text {Table-Menu} -underline {0}  
menu $wname.fr_menu.tablemenu.m
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableColumns  $a\} "  -label {Columns} -underline {0} 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableIndexes  $a\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableDepViews $a\} "  -label {Dependent Views} -underline {10}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableClusters $a\} "  -label {Cluster} -underline {1}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableTablespace $a\} " -label {Tablespace} -underline {2}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableExtents  $a\} "   -label {Extents} -underline {0}
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableSynonyms $a\} "   -label {Synonyms} -underline {0}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableConstraints $a\} " -label {Constraints} -underline {7}
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableTriggers $a\} "    -label {Triggers} -underline {3} 
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableRoles $a\} "       -label {Roles} -underline {0}  
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableGrants  $a\} "     -label {Grants} -underline {0}  
  $wname.fr_menu.tablemenu.m add separator
  $wname.fr_menu.tablemenu.m add command  -command "catch \{OD_ShowUserTableDetails $a\} "     -label {Details} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.tablemenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.tablemenu
}


#####################################
# Show window : Analyzed-Columns    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzedtablescol
# Shows statistics of columns for the selected table   
proc ShowWindow.ow_analyzedtablescol {wname li headline title} {


CreateWindow $wname $title 550x350 100 100

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.columnmenu  -menu "$wname.fr_menu.columnmenu.m" -text {Column-Menu} -underline {0}  
menu $wname.fr_menu.columnmenu.m
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnTables \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Table} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnIndexes  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Indexes} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnViews \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {View} -underline {0}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnClusterColumns \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Cluster-Column} -underline {1}  
  $wname.fr_menu.columnmenu.m add separator
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnConstraints  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\] \}"  -label {Constraints} -underline {7}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnTriggers \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Triggers} -underline {3}  
  $wname.fr_menu.columnmenu.m add command  -command "catch \{OD_ShowUserColumnGrants  \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Grants} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.columnmenu {left frame center}

FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.columnmenu
}


########################################
# Show window : Analyze-Tables-Compute #
########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzetabcom
# Shows a dialog box for analyze tables with compute
proc ShowWindow.tl_analyzetabcom { args} {


catch "destroy .tl_analyzetabcom"

toplevel .tl_analyzetabcom   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzetabcom program
wm sizefrom     .tl_analyzetabcom program
wm maxsize      .tl_analyzetabcom 1000 60
wm minsize      .tl_analyzetabcom 300 60
wm title        .tl_analyzetabcom {Analyze-Tables with Compute}

set args [string trim $args \{\}]
set tab  [lindex $args 3]

frame .tl_analyzetabcom.fr_inp  -borderwidth {2}
label .tl_analyzetabcom.fr_inp.lb_inp  -text "Do you really want to overwrite the statistics for table $tab ?"

pack append .tl_analyzetabcom.fr_inp  .tl_analyzetabcom.fr_inp.lb_inp {left frame e}  

frame .tl_analyzetabcom.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzetabcom.fr_cmd.bn_ok  -command {OD_DoAnalyzeTablesCom $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzetabcom.fr_cmd.bn_cancel  -command {destroy .tl_analyzetabcom}  -text {Cancel}
button .tl_analyzetabcom.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Compute Help" 350x210 340 $ODv_analyzecominfo}  -text {Help}

pack append .tl_analyzetabcom.fr_cmd  .tl_analyzetabcom.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzetabcom.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzetabcom.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzetabcom  .tl_analyzetabcom.fr_inp {top frame center fillx}  .tl_analyzetabcom.fr_cmd {top frame center fillx} 

.tl_analyzetabcom
}


#########################################
# Show window : Analyze-Tables-Estimate #
#########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzetabest
# Shows a dialog box for analyze tables with estimate
proc ShowWindow.tl_analyzetabest { args} {

catch "destroy .tl_analyzetabest"

toplevel .tl_analyzetabest   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzetabest program
wm sizefrom     .tl_analyzetabest program
wm maxsize      .tl_analyzetabest 1000 120
wm minsize      .tl_analyzetabest 300 120
wm title        .tl_analyzetabest {Analyze-Tables with Estimate}

set ODv_AnalyzeArgs [string trim $args \{\}]

frame .tl_analyzetabest.fr_message  -borderwidth {2}
message .tl_analyzetabest.fr_message.mg_text -aspect {1000}  -padx {5}  -pady {2}  -text {}
pack append .tl_analyzetabest.fr_message .tl_analyzetabest.fr_message.mg_text  {top frame center fillx}

frame .tl_analyzetabest.fr_inp  -borderwidth {2}
label .tl_analyzetabest.fr_inp.lb_inp  -text {sample:}
entry .tl_analyzetabest.fr_inp.en_inp  -relief {sunken}
  # bindings
  bind .tl_analyzetabest.fr_inp.en_inp <Key-Return> {.tl_analyzetabest.fr_cmd.bn_ok invoke}
pack append .tl_analyzetabest.fr_inp  .tl_analyzetabest.fr_inp.lb_inp {left frame e}  .tl_analyzetabest.fr_inp.en_inp {right frame center expand fillx}

frame .tl_analyzetabest.fr_ch  -borderwidth {2}  -relief {raised}
radiobutton .tl_analyzetabest.fr_ch.rb_rows -text {rows} -value {rows} -variable {ODv_analyzeest}
radiobutton .tl_analyzetabest.fr_ch.rb_percent -text {percent} -value {percent} -variable {ODv_analyzeest}
pack append .tl_analyzetabest.fr_ch  .tl_analyzetabest.fr_ch.rb_percent {left frame center expand fillx} .tl_analyzetabest.fr_ch.rb_rows {left frame center expand fillx}

frame .tl_analyzetabest.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzetabest.fr_cmd.bn_ok  -command {OD_DoAnalyzeTablesEst $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzetabest.fr_cmd.bn_cancel  -command {destroy .tl_analyzetabest}  -text {Cancel}
button .tl_analyzetabest.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Estimate-Help" 450x290 410 $ODv_analyzeestinfo}  -text {Help}
pack append .tl_analyzetabest.fr_cmd  .tl_analyzetabest.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzetabest.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzetabest.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzetabest  .tl_analyzetabest.fr_message {top frame center fillx} .tl_analyzetabest.fr_inp {top frame center fillx}  .tl_analyzetabest.fr_ch {top frame center fillx} .tl_analyzetabest.fr_cmd {top frame center fillx} 

.tl_analyzetabest.fr_inp.en_inp insert end {}
}


#######################################
# Show window : Analyze-Tables-Delete #
#######################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzetabdel
# Shows a dialog box for analyze tables with delete
proc ShowWindow.tl_analyzetabdel { args} {

catch "destroy .tl_analyzetabdel"

toplevel .tl_analyzetabdel   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzetabdel program
wm sizefrom     .tl_analyzetabdel program
wm maxsize      .tl_analyzetabdel 1000 60
wm minsize      .tl_analyzetabdel 300 60
wm title        .tl_analyzetabdel {Analyze-Tables with Delete}

set args [string trim $args \{\}]
set tab  [lindex $args 3]

frame .tl_analyzetabdel.fr_inp  -borderwidth {2}
label .tl_analyzetabdel.fr_inp.lb_inp  -text "Do you really want to delete the statistics for table $tab ?"

pack append .tl_analyzetabdel.fr_inp  .tl_analyzetabdel.fr_inp.lb_inp {left frame e}  

frame .tl_analyzetabdel.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzetabdel.fr_cmd.bn_ok  -command {OD_DoAnalyzeTablesDel $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzetabdel.fr_cmd.bn_cancel  -command {destroy .tl_analyzetabdel}  -text {Cancel}
button .tl_analyzetabdel.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Delete Help" 350x200 340 $ODv_analyzedelinfo}  -text {Help}

pack append .tl_analyzetabdel.fr_cmd  .tl_analyzetabdel.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzetabdel.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzetabdel.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzetabdel  .tl_analyzetabdel.fr_inp {top frame center fillx}  .tl_analyzetabdel.fr_cmd {top frame center fillx} 

.tl_analyzetabdel
}



#####################################
# Show window : Analyze-Indexes    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzeindexes
# Shows user indexes for analyzing
proc ShowWindow.ow_analyzeindexes { wname li headline title} {


CreateWindow $wname $title

set ODv_AnalyzeType {current}

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.indexmenu  -menu "$wname.fr_menu.indexmenu.m" -text {Analyze-Index-Menu} -underline {0}  
menu $wname.fr_menu.indexmenu.m
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowAnalyzedIndexes \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Show Statistics} -underline {0}
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_AnalyzeIndexesCom \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {compute...} -underline {0}  
   $wname.fr_menu.indexmenu.m add command  -command  "catch \{OD_AnalyzeIndexesEst \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {estimate...} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command  "catch \{OD_AnalyzeIndexesDel \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {delete...} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.indexmenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu 
}


#####################################
# Show window : Analyzed-Indexes    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzedindexes
# Shows statistics of indexes for the selected index
proc ShowWindow.ow_analyzedindexes { wname li headline title} {


CreateWindow $wname $title 870x200 400 200

set i [lindex [split $title] 4]
set i [list $i]
set a [list $i]

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.indexmenu  -menu "$wname.fr_menu.indexmenu.m" -text {Index-Menu} -underline {0}  
menu $wname.fr_menu.indexmenu.m
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexTable       $a\} "  -label {Table} -underline {0}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexColumns     $a\} "  -label {Columns} -underline {0}  
  $wname.fr_menu.indexmenu.m add separator
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexTablespace  $a\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.indexmenu.m add command  -command "catch \{OD_ShowUserIndexExtents     $a\} "  -label {Extents} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.indexmenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.indexmenu
}


#########################################
# Show window : Analyze-Indexes-Compute #
#########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzeidxcom
# Shows dialog box for analyze indexes with compute
proc ShowWindow.tl_analyzeidxcom { args} {

catch "destroy .tl_analyzeidxcom"

toplevel .tl_analyzeidxcom   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzeidxcom program
wm sizefrom     .tl_analyzeidxcom program
wm maxsize      .tl_analyzeidxcom 1000 60
wm minsize      .tl_analyzeidxcom 300 60
wm title        .tl_analyzeidxcom {Analyze-Indexes with Compute}

set args [string trim $args \{\}]
set ind  [lindex $args 0]

frame .tl_analyzeidxcom.fr_inp  -borderwidth {2}
label .tl_analyzeidxcom.fr_inp.lb_inp  -text "Do you really want to overwrite the statistics for index $ind ?"

pack append .tl_analyzeidxcom.fr_inp  .tl_analyzeidxcom.fr_inp.lb_inp {left frame e}  

frame .tl_analyzeidxcom.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzeidxcom.fr_cmd.bn_ok  -command {OD_DoAnalyzeIndexesCom $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzeidxcom.fr_cmd.bn_cancel  -command {destroy .tl_analyzeidxcom}  -text {Cancel}
button .tl_analyzeidxcom.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Compute Help" 350x210 340 $ODv_analyzecominfo}  -text {Help}

pack append .tl_analyzeidxcom.fr_cmd  .tl_analyzeidxcom.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzeidxcom.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzeidxcom.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzeidxcom  .tl_analyzeidxcom.fr_inp {top frame center fillx}  .tl_analyzeidxcom.fr_cmd {top frame center fillx} 

.tl_analyzeidxcom
}


###########################################
# Show windows : Analyze-Indexes-Estimate #
###########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzeidxest
# Shows dialog box for analyze indexes with estimate
proc ShowWindow.tl_analyzeidxest { args} {

catch "destroy .tl_analyzeidxest"

toplevel .tl_analyzeidxest   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzeidxest program
wm sizefrom     .tl_analyzeidxest program
wm maxsize      .tl_analyzeidxest 1000 120
wm minsize      .tl_analyzeidxest 300 120
wm title        .tl_analyzeidxest {Analyze-Indexes with Estimate}

set ODv_AnalyzeArgs [string trim $args \{\}]

frame .tl_analyzeidxest.fr_message  -borderwidth {2}
message .tl_analyzeidxest.fr_message.mg_text -aspect {1000}  -padx {5}  -pady {2}  -text {}
pack append .tl_analyzeidxest.fr_message .tl_analyzeidxest.fr_message.mg_text  {top frame center fillx}

frame .tl_analyzeidxest.fr_inp  -borderwidth {2}
label .tl_analyzeidxest.fr_inp.lb_inp  -text {sample:}
entry .tl_analyzeidxest.fr_inp.en_inp  -relief {sunken}
  # bindings
  bind .tl_analyzeidxest.fr_inp.en_inp <Key-Return> {.tl_analyzeidxest.fr_cmd.bn_ok invoke}
pack append .tl_analyzeidxest.fr_inp  .tl_analyzeidxest.fr_inp.lb_inp {left frame e}  .tl_analyzeidxest.fr_inp.en_inp {right frame center expand fillx}

frame .tl_analyzeidxest.fr_ch  -borderwidth {2}  -relief {raised}
radiobutton .tl_analyzeidxest.fr_ch.rb_rows -text {rows} -value {rows} -variable {ODv_analyzeest}
radiobutton .tl_analyzeidxest.fr_ch.rb_percent -text {percent} -value {percent} -variable {ODv_analyzeest}
pack append .tl_analyzeidxest.fr_ch  .tl_analyzeidxest.fr_ch.rb_percent {left frame center expand fillx} .tl_analyzeidxest.fr_ch.rb_rows {left frame center expand fillx}

frame .tl_analyzeidxest.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzeidxest.fr_cmd.bn_ok  -command {OD_DoAnalyzeIndexesEst $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzeidxest.fr_cmd.bn_cancel  -command {destroy .tl_analyzeidxest}  -text {Cancel}
button .tl_analyzeidxest.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Estimate-Help" 450x290 410 $ODv_analyzeestinfo}  -text {Help}
pack append .tl_analyzeidxest.fr_cmd  .tl_analyzeidxest.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzeidxest.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzeidxest.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzeidxest  .tl_analyzeidxest.fr_message {top frame center fillx} .tl_analyzeidxest.fr_inp {top frame center fillx}  .tl_analyzeidxest.fr_ch {top frame center fillx} .tl_analyzeidxest.fr_cmd {top frame center fillx} 

.tl_analyzeidxest.fr_inp.en_inp insert end {}
}


#########################################
# Show windows : Analyze-Indexes-Delete #
#########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzeidxdel
# Shows dialog box for analyze indexes with delete
proc ShowWindow.tl_analyzeidxdel { args} {

catch "destroy .tl_analyzeidxdel"

toplevel .tl_analyzeidxdel   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzeidxdel program
wm sizefrom     .tl_analyzeidxdel program
wm maxsize      .tl_analyzeidxdel 1000 60
wm minsize      .tl_analyzeidxdel 300 60
wm title        .tl_analyzeidxdel {Analyze-Indexes with Delete}

set args [string trim $args \{\}]
set ind  [lindex $args 0]

frame .tl_analyzeidxdel.fr_inp  -borderwidth {2}
label .tl_analyzeidxdel.fr_inp.lb_inp  -text "Do you really want to delete the statistics for index $ind ?"

pack append .tl_analyzeidxdel.fr_inp  .tl_analyzeidxdel.fr_inp.lb_inp {left frame e}  

frame .tl_analyzeidxdel.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzeidxdel.fr_cmd.bn_ok  -command {OD_DoAnalyzeIndexesDel $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzeidxdel.fr_cmd.bn_cancel  -command {destroy .tl_analyzeidxdel}  -text {Cancel}
button .tl_analyzeidxdel.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Delete Help" 350x200 340 $ODv_analyzedelinfo}  -text {Help}

pack append .tl_analyzeidxdel.fr_cmd  .tl_analyzeidxdel.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzeidxdel.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzeidxdel.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzeidxdel  .tl_analyzeidxdel.fr_inp {top frame center fillx}  .tl_analyzeidxdel.fr_cmd {top frame center fillx} 

.tl_analyzeidxdel
}


#####################################
# Show window : Analyze-Clusters    #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzecluster
# Shows user cluster for analyzing
proc ShowWindow.ow_analyzecluster { wname li headline title} {


CreateWindow $wname $title

set ODv_AnalyzeType {current}

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustermenu  -menu "$wname.fr_menu.clustermenu.m" -text {Analyze-Cluster-Menu} -underline {0}  
menu $wname.fr_menu.clustermenu.m
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowAnalyzedCluster \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {Show Statistics} -underline {0}
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_AnalyzeClustersCom \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} "  -label {compute...} -underline {0}  
   $wname.fr_menu.clustermenu.m add command  -command  "catch \{OD_AnalyzeClustersEst \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {estimate...} -underline {0}  
  $wname.fr_menu.clustermenu.m add command  -command  "catch \{OD_AnalyzeClustersDel \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection\]\]\} " -label {delete...} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.clustermenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu 
}


#####################################
# Show window : Analyzed-Clusters   #
#####################################

# Regine Kasten
# Procedure: ShowWindow.ow_analyzedcluster
# Shows statistics of cluster for the selected cluster
proc ShowWindow.ow_analyzedcluster { wname li headline title} {


CreateWindow $wname $title 450x200 400 200

set c [lindex [split $title] 4]
set c [list $c]
set a [list {0} {1} {2} $c]

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.clustermenu  -menu "$wname.fr_menu.clustermenu.m" -text {Cluster-Menu} -underline {0}  
menu $wname.fr_menu.clustermenu.m
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterTable          $a\} "  -label {Tables} -underline {0}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterClusterColumns $a\} "  -label {Cluster-Columns} -underline {8}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterTablespace     $a\} "  -label {Tablespace} -underline {2}  
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterExtents        $a\} "  -label {Extents} -underline {0}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterSynonyms       $a\} "  -label {Synonyms} -underline {1}  
  $wname.fr_menu.clustermenu.m add separator
  $wname.fr_menu.clustermenu.m add command  -command "catch \{OD_ShowUserClusterDetails        $a\} "  -label {Details} -underline {0}  
pack append $wname.fr_menu  $wname.fr_menu.clustermenu {left frame center}
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu $wname.fr_menu.clustermenu
}


##########################################
# Show windows : Analyze-Cluster-Compute #
##########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzeclucom
# Shows dialog box for analyze cluster with compute
proc ShowWindow.tl_analyzeclucom { args} {

catch "destroy .tl_analyzeclucom"

toplevel .tl_analyzeclucom   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzeclucom program
wm sizefrom     .tl_analyzeclucom program
wm maxsize      .tl_analyzeclucom 1000 60
wm minsize      .tl_analyzeclucom 300 60
wm title        .tl_analyzeclucom {Analyze-Cluster with Compute}

set args [string trim $args \{\}]
set clu  [lindex $args 3]

frame .tl_analyzeclucom.fr_inp  -borderwidth {2}
label .tl_analyzeclucom.fr_inp.lb_inp  -text "Do you really want to overwrite the statistics for index $clu ?"

pack append .tl_analyzeclucom.fr_inp  .tl_analyzeclucom.fr_inp.lb_inp {left frame e}  

frame .tl_analyzeclucom.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzeclucom.fr_cmd.bn_ok  -command {OD_DoAnalyzeClustersCom $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzeclucom.fr_cmd.bn_cancel  -command {destroy .tl_analyzeclucom}  -text {Cancel}
button .tl_analyzeclucom.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Compute Help" 350x210 340 $ODv_analyzecominfo}  -text {Help}

pack append .tl_analyzeclucom.fr_cmd  .tl_analyzeclucom.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzeclucom.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzeclucom.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzeclucom  .tl_analyzeclucom.fr_inp {top frame center fillx}  .tl_analyzeclucom.fr_cmd {top frame center fillx} 

.tl_analyzeclucom
}


##########################################
# Show window : Analyze-Cluster-Estimate #
##########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzecluest
# Shows dialog box for analyze cluster with estimate
proc ShowWindow.tl_analyzecluest { args} {

catch "destroy .tl_analyzecluest"

toplevel .tl_analyzecluest   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzecluest program
wm sizefrom     .tl_analyzecluest program
wm maxsize      .tl_analyzecluest 1000 120
wm minsize      .tl_analyzecluest 300 120
wm title        .tl_analyzecluest {Analyze-Clusters with Estimate}

set ODv_AnalyzeArgs [string trim $args \{\}]

frame .tl_analyzecluest.fr_message  -borderwidth {2}
message .tl_analyzecluest.fr_message.mg_text -aspect {1000}  -padx {5}  -pady {2}  -text {}
pack append .tl_analyzecluest.fr_message .tl_analyzecluest.fr_message.mg_text  {top frame center fillx}

frame .tl_analyzecluest.fr_inp  -borderwidth {2}
label .tl_analyzecluest.fr_inp.lb_inp  -text {sample:}
entry .tl_analyzecluest.fr_inp.en_inp  -relief {sunken}
  # bindings
  bind .tl_analyzecluest.fr_inp.en_inp <Key-Return> {.tl_analyzecluest.fr_cmd.bn_ok invoke}
pack append .tl_analyzecluest.fr_inp  .tl_analyzecluest.fr_inp.lb_inp {left frame e}  .tl_analyzecluest.fr_inp.en_inp {right frame center expand fillx}

frame .tl_analyzecluest.fr_ch  -borderwidth {2}  -relief {raised}
radiobutton .tl_analyzecluest.fr_ch.rb_rows -text {rows} -value {rows} -variable {ODv_analyzeest}
radiobutton .tl_analyzecluest.fr_ch.rb_percent -text {percent} -value {percent} -variable {ODv_analyzeest}
pack append .tl_analyzecluest.fr_ch  .tl_analyzecluest.fr_ch.rb_percent {left frame center expand fillx} .tl_analyzecluest.fr_ch.rb_rows {left frame center expand fillx}

frame .tl_analyzecluest.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzecluest.fr_cmd.bn_ok  -command {OD_DoAnalyzeClustersEst $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzecluest.fr_cmd.bn_cancel  -command {destroy .tl_analyzecluest}  -text {Cancel}
button .tl_analyzecluest.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Estimate-Help" 450x290 410 $ODv_analyzeestinfo}  -text {Help}
pack append .tl_analyzecluest.fr_cmd  .tl_analyzecluest.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzecluest.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzecluest.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzecluest  .tl_analyzecluest.fr_message {top frame center fillx} .tl_analyzecluest.fr_inp {top frame center fillx}  .tl_analyzecluest.fr_ch {top frame center fillx} .tl_analyzecluest.fr_cmd {top frame center fillx} 

.tl_analyzecluest.fr_inp.en_inp insert end {}
}


########################################
# Show window : Analyze-Cluster-Delete #
########################################

# Regine Kasten
# Procedure: ShowWindow.tl_analyzecludel
# Shows dialog box for analyze cluster with delete
proc ShowWindow.tl_analyzecludel { args} {

catch "destroy .tl_analyzecludel"

toplevel .tl_analyzecludel   -relief {raised}

# Window manager configurations
wm positionfrom .tl_analyzecludel program
wm sizefrom     .tl_analyzecludel program
wm maxsize      .tl_analyzecludel 1000 60
wm minsize      .tl_analyzecludel 300 60
wm title        .tl_analyzecludel {Analyze-Clusters with Delete}

set args [string trim $args \{\}]
set clu  [lindex $args 3]

frame .tl_analyzecludel.fr_inp  -borderwidth {2}
label .tl_analyzecludel.fr_inp.lb_inp  -text "Do you really want to delete the statistics for index $clu ?"

pack append .tl_analyzecludel.fr_inp  .tl_analyzecludel.fr_inp.lb_inp {left frame e}  

frame .tl_analyzecludel.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_analyzecludel.fr_cmd.bn_ok  -command {OD_DoAnalyzeClustersDel $ODv_AnalyzeArgs}  -text {OK}
button .tl_analyzecludel.fr_cmd.bn_cancel  -command {destroy .tl_analyzecludel}  -text {Cancel}
button .tl_analyzecludel.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-Analyze-Delete Help" 350x200 340 $ODv_analyzedelinfo}  -text {Help}

pack append .tl_analyzecludel.fr_cmd  .tl_analyzecludel.fr_cmd.bn_ok {left frame center expand fillx}  .tl_analyzecludel.fr_cmd.bn_help {left frame center expand fillx}  .tl_analyzecludel.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_analyzecludel  .tl_analyzecludel.fr_inp {top frame center fillx}  .tl_analyzecludel.fr_cmd {top frame center fillx} 

.tl_analyzecludel
}




#####################################
# Show windows : Explain            #
#####################################


##############################
# Show window : Explain-Plan #
##############################

# Regine Kasten
# Procedure: ShowWindow.ow_explainplan
# Shows the execution plan for the statement in the main window
proc ShowWindow.ow_explainplan { wname li headline title} {


CreateWindow $wname $title

frame $wname.fr_menu  -borderwidth {2}  -relief {raised}
menubutton $wname.fr_menu.objmenu -menu "$wname.fr_menu.objmenu.m" -text {Object-Menu} -underline {0}
menu $wname.fr_menu.objmenu.m
  $wname.fr_menu.objmenu.m add command -command "catch \{OD_ShowExplainObject $wname \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}"  -label {Object} -underline {0}
  $wname.fr_menu.objmenu.m add command -command "catch \{OD_ShowExplainObjDet $wname \[$wname.fr_list.lb_list get \[$wname.fr_list.lb_list curselection \]\] \}" -label {Object-Details}
button $wname.fr_menu.bn_tree   -command "catch \{OD_ExplainFullTree $wname\}" -relief {flat} -text {Show Tree}
menubutton $wname.fr_menu.filemenu  -menu "$wname.fr_menu.filemenu.m" -text {File-Menu} -underline {0}  
menu $wname.fr_menu.filemenu.m
  $wname.fr_menu.filemenu.m add command -command {OD_FileBox .saveexplain * "" OD_SaveExplain}  -label {Save as...} -underline {0}
  $wname.fr_menu.filemenu.m add command -command {OD_PrintExplain}  -label {Print} -underline {0}
button $wname.fr_menu.bn_help   -command {OD_Help_InfoBox "ODDIS-ExplainPlan-Help" $ODv_explainplaninfo .tl_explainhlp 900 200} -relief {flat} -text {Help}
pack append $wname.fr_menu  $wname.fr_menu.objmenu {left frame center} $wname.fr_menu.bn_tree {left frame center} $wname.fr_menu.bn_help {right frame center} $wname.fr_menu.filemenu {right frame center} 
  
FillWindow $wname $li $headline
tk_menuBar $wname.fr_menu 
}



##############################################
# Procedure: ShowWindow.tl_ExplainObjDetails #
##############################################

# Regine Kasten
# Procedure: ShowWindow.tl_ExplainObjDetails
# Shows a window with Details for an Explained-Object
# with information about the object, extents and statistics
proc ShowWindow.tl_ExplainObjDetails {wname titlelist elementslist wtitle extnum} { 

catch "destroy $wname"

toplevel $wname   -relief {raised}

# Window manager configurations
wm positionfrom $wname program
wm sizefrom     $wname user
wm title        $wname $wtitle 

# set three lists for object, extents and statistics
set objtitle [lindex $titlelist 0]
set exttitle [lindex $titlelist 1]
set statitle [lindex $titlelist 2]
set objelems [lindex $elementslist 0]
set extelems [lindex $elementslist 1]
set staelems [lindex $elementslist 2]

 # frame-height
set lenobj  [expr 1 + [llength $objelems]]
set lenext  [expr 1 + [llength $exttitle]]
set lenlist [llength $extelems]
set lensta  [expr 1 + [llength $staelems]]

if {$lenext <= 3 } {set extnum 0}


### object

frame $wname.fr_obj -relief {raised}

### object  title

frame $wname.fr_objt -borderwidth {2}  -relief {raised}
listbox $wname.fr_objt.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {16} -height {1}  -relief {ridge}  
listbox $wname.fr_objt.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {16} -height $lenobj  -relief {ridge} 

pack append $wname.fr_objt  $wname.fr_objt.lb_head {top frame center fillx}  $wname.fr_objt.lb_list {top frame center expand fill}

$wname.fr_objt.lb_head delete 0 end
$wname.fr_objt.lb_list delete 0 end

$wname.fr_objt.lb_head insert end "EXPLAIN-OBJECT"
foreach elem $objtitle {
  $wname.fr_objt.lb_list insert end $elem
  }

### object elements

frame $wname.fr_obje  -borderwidth {2}  -relief {raised}
listbox $wname.fr_obje.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height {1}  -relief {ridge}  
listbox $wname.fr_obje.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height $lenobj  -relief {raised} 

pack append $wname.fr_obje  $wname.fr_obje.lb_head {top frame center fillx}  $wname.fr_obje.lb_list {top frame center expand fill}

$wname.fr_obje.lb_head delete 0 end
$wname.fr_obje.lb_list delete 0 end

$wname.fr_obje.lb_head insert end ""
foreach elem $objelems {
  $wname.fr_obje.lb_list insert end $elem
  }

pack append $wname.fr_obj  $wname.fr_objt {left frame center fillx}  $wname.fr_obje {left frame center expand fill}


### extents

frame $wname.fr_ext -relief {raised}

### extents title

frame $wname.fr_extt  -borderwidth {2}  -relief {raised}
listbox $wname.fr_extt.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*} -width {16} -height {1}  -relief {ridge}  
listbox $wname.fr_extt.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*} -width {16} -height $lenext  -relief {ridge} 

pack append $wname.fr_extt  $wname.fr_extt.lb_head {top frame center fillx}  $wname.fr_extt.lb_list {top frame center expand fill}

$wname.fr_extt.lb_head delete 0 end
$wname.fr_extt.lb_list delete 0 end

$wname.fr_extt.lb_head insert end "EXTENTS"
foreach elem $exttitle {
  $wname.fr_extt.lb_list insert end $elem
  }

### extents elements

frame $wname.fr_list  -borderwidth {2}  -relief {raised}
scrollbar $wname.fr_list.sb_hlist  -command "OD_HScrollCmd $wname"  -orient {horizontal}  -relief {raised}
listbox $wname.fr_list.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height {1}  -relief {ridge}  -xscrollcommand "$wname.fr_list.sb_hlist set"
listbox $wname.fr_list.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height $lenlist  -relief {raised}  -xscrollcommand "$wname.fr_list.sb_hlist set"

pack append $wname.fr_list    $wname.fr_list.sb_hlist {bottom frame center fillx}  $wname.fr_list.lb_head {top frame center fillx}  $wname.fr_list.lb_list {top frame center expand fill}

$wname.fr_list.lb_list configure -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}
$wname.fr_list.lb_list configure -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}
$wname.fr_list.lb_head delete 0 end
$wname.fr_list.lb_list delete 0 end

$wname.fr_list.lb_head insert end "Number of Extents $extnum"
foreach elem $extelems {
  $wname.fr_list.lb_list insert end $elem
  }


pack append $wname.fr_ext $wname.fr_extt {left frame center fill}  $wname.fr_list {left frame center expand fill}



### statistics

frame $wname.fr_sta -relief {raised}

### statistics  title

frame $wname.fr_stat -borderwidth {2}  -relief {raised}
listbox $wname.fr_stat.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {16} -height {1}  -relief {ridge}  
listbox $wname.fr_stat.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {16} -height $lensta  -relief {ridge} 

pack append $wname.fr_stat  $wname.fr_stat.lb_head {top frame center fillx}  $wname.fr_stat.lb_list {top frame center expand fill}

$wname.fr_stat.lb_head delete 0 end
$wname.fr_stat.lb_list delete 0 end

$wname.fr_stat.lb_head insert end "STATISTICS"
foreach elem $statitle {
  $wname.fr_stat.lb_list insert end $elem
  }

### statistics elements

frame $wname.fr_stae  -borderwidth {2}  -relief {raised}
listbox $wname.fr_stae.lb_head  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height {1}  -relief {ridge}  
listbox $wname.fr_stae.lb_list  -font {-*-courier-*-r-*-*-14-*-*-*-*-*-*-*}  -width {30} -height $lensta  -relief {raised} 

pack append $wname.fr_stae  $wname.fr_stae.lb_head {top frame center fillx}  $wname.fr_stae.lb_list {top frame center expand fill}


$wname.fr_stae.lb_head delete 0 end
$wname.fr_stae.lb_list delete 0 end

$wname.fr_stae.lb_head insert end ""
foreach elem $staelems {
  $wname.fr_stae.lb_list insert end $elem
  }


pack append $wname.fr_sta $wname.fr_stat {left frame center fillx}  $wname.fr_stae {left frame center expand fill}



### cancel button

frame $wname.fr_cmd  -borderwidth {2}  -relief {raised}
button $wname.fr_cmd.bn_cancel -text "Dismiss" -command "destroy $wname" -borderwidth 2 -relief raised

pack $wname.fr_cmd.bn_cancel  -fill both -expand 1


### pack window

pack append $wname $wname.fr_obj  {top frame center fillx} $wname.fr_ext {top frame center fillx} $wname.fr_sta {top frame center fillx} 
pack $wname.fr_cmd -pady 0 -expand 1 -fill both  
}


