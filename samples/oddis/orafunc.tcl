
#####################################
# Show window : Longfile            #
#####################################

proc ShowWindow.tl_longfile { args} {


catch "destroy .tl_longfile"

toplevel .tl_longfile 

# Window manager configurations
wm positionfrom .tl_longfile program
wm sizefrom .tl_longfile program
wm title .tl_longfile {ODDIS - longfile}


frame .tl_longfile.fr_tab  -borderwidth {2}
label .tl_longfile.fr_tab.lb_tab  -text {Table:}  -width {8}
entry .tl_longfile.fr_tab.en_tab  -relief {sunken}  -width {30}
  # bindings
  bind .tl_longfile.fr_tab.en_tab <Key-Return> {focus .tl_longfile.fr_col.en_col}
  bind .tl_longfile.fr_tab.en_tab <Key-Tab> {focus .tl_longfile.fr_col.en_col}

pack append .tl_longfile.fr_tab  .tl_longfile.fr_tab.lb_tab {left frame e}  .tl_longfile.fr_tab.en_tab {left frame center expand fillx}

frame .tl_longfile.fr_col  -borderwidth {2}
label .tl_longfile.fr_col.lb_col  -text {Column:}  -width {8}
entry .tl_longfile.fr_col.en_col  -relief {sunken}  -width {30}
  # bindings
  bind .tl_longfile.fr_col.en_col <Key-Return> {focus .tl_longfile.fr_row.en_row}
  bind .tl_longfile.fr_col.en_col <Key-Tab> {focus .tl_longfile.fr_row.en_row}

pack append .tl_longfile.fr_col  .tl_longfile.fr_col.lb_col {left frame e}  .tl_longfile.fr_col.en_col {left frame center expand fillx}

frame .tl_longfile.fr_row  -borderwidth {2}
label .tl_longfile.fr_row.lb_row  -text {Row ID:}  -width {8}
entry .tl_longfile.fr_row.en_row  -relief {sunken}  -width {30}
  # bindings
  bind .tl_longfile.fr_row.en_row <Key-Return> {focus .tl_longfile.fr_file.en_file}
  bind .tl_longfile.fr_row.en_row <Key-Tab> {focus .tl_longfile.fr_file.en_file}

pack append .tl_longfile.fr_row  .tl_longfile.fr_row.lb_row {left frame e}  .tl_longfile.fr_row.en_row {left frame center expand fillx}

frame .tl_longfile.fr_file  -borderwidth {2}
label .tl_longfile.fr_file.lb_file  -text {File:}  -width {8}
entry .tl_longfile.fr_file.en_file  -relief {sunken}  -textvariable {ODv_longfilename}  -width {30}
  # bindings
  bind .tl_longfile.fr_file.en_file <Key-Return> {focus .tl_longfile.fr_tab.en_tab}
  bind .tl_longfile.fr_file.en_file <Key-Tab> {focus .tl_longfile.fr_tab.en_tab}

pack append .tl_longfile.fr_file  .tl_longfile.fr_file.lb_file {left frame e}  .tl_longfile.fr_file.en_file {left frame center expand fillx}

frame .tl_longfile.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_longfile.fr_cmd.bn_ok  -text {Execute}
button .tl_longfile.fr_cmd.bn_cancel  -command {destroy .tl_longfile}  -state {active}  -text {Cancel}
button .tl_longfile.fr_cmd.bn_pickfile  -command {OD_FileBox .pickfile * "" OD_PickFileName}  -text {Pick File}

pack append .tl_longfile.fr_cmd  .tl_longfile.fr_cmd.bn_pickfile {left frame center expand fillx}  .tl_longfile.fr_cmd.bn_ok {left frame center expand fillx}  .tl_longfile.fr_cmd.bn_cancel {left frame center expand fillx}

frame .tl_longfile.fr_message  -borderwidth {2}  -relief {raised}
message .tl_longfile.fr_message.mg_text  -aspect {1000}  -padx {5}  -pady {2}  -text {}

pack append .tl_longfile.fr_message  .tl_longfile.fr_message.mg_text {top frame center}

pack append .tl_longfile  .tl_longfile.fr_message {top frame center fillx}  .tl_longfile.fr_tab {top frame center pady 8 fillx}  .tl_longfile.fr_col {top frame center pady 8 fillx}  .tl_longfile.fr_row {top frame center pady 8 fillx}  .tl_longfile.fr_file {top frame center pady 8 fillx}  .tl_longfile.fr_cmd {top frame center fillx}

.tl_longfile.fr_tab.en_tab insert end {}
.tl_longfile.fr_col.en_col insert end {}
.tl_longfile.fr_row.en_row insert end {}

}


#####################################
# Show window  : Plexec             #
#####################################


proc ShowWindow.tl_plexec { args} {


catch "destroy .tl_plexec"

toplevel .tl_plexec   -relief {raised}

# Window manager configurations
wm positionfrom .tl_plexec program
wm sizefrom .tl_plexec program
wm maxsize .tl_plexec 1000 65
wm minsize .tl_plexec 300 65
wm title .tl_plexec {ODDIS - PL/SQL Execute}


frame .tl_plexec.fr_inp  -borderwidth {2}
label .tl_plexec.fr_inp.lb_inp  -text {Bind Variables:}
entry .tl_plexec.fr_inp.en_inp  -relief {sunken}
  # bindings
  bind .tl_plexec.fr_inp.en_inp <Key-Return> {.tl_plexec.fr_cmd.bn_ok invoke}

pack append .tl_plexec.fr_inp  .tl_plexec.fr_inp.lb_inp {left frame e}  .tl_plexec.fr_inp.en_inp {right frame center expand fillx}

frame .tl_plexec.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_plexec.fr_cmd.bn_ok  -command {OD_DoPL}  -text {Bind&Execute}
button .tl_plexec.fr_cmd.bn_cancel  -command {destroy .tl_plexec}  -text {Cancel}
button .tl_plexec.fr_cmd.bn_help  -command {OD_MsgBox "ODDIS-PL/Exec Help" 480x290 450 $ODv_plexecinfo}  -text {Help}

pack append .tl_plexec.fr_cmd  .tl_plexec.fr_cmd.bn_ok {left frame center expand fillx}  .tl_plexec.fr_cmd.bn_help {left frame center expand fillx}  .tl_plexec.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_plexec  .tl_plexec.fr_inp {top frame center fillx}  .tl_plexec.fr_cmd {top frame center fillx}

.tl_plexec.fr_inp.en_inp insert end {}

}


############################################
# Procedures: System  	                   #
############################################


#################################
# Procedure: DoSysDevAll        #
#################################

# Regine Kasten
# Procedure:  OD_DoSysDevAll
# searches for all devices with the unix-command df
proc OD_DoSysDevAll {} {

global ODv_dfPath
global ODv_SysDevAll


### read devices from unix-system

# execute df-command
set ok [catch {exec $ODv_dfPath -ak} dflist]
set dflist [split $dflist \n]

# make one-line Elements, if one line is splitted into two in the df-result
set devlist ""
foreach elem $dflist {
   if {[ctype digit [lindex $elem 0]] == 1 } {
      set l     [expr [llength $devlist] - 1]
      set last  [lindex $devlist $l]
      set lidir [lreplace $devlist $l $l [concat $last $elem]]
   } else {
      lappend devlist $elem
   }
}

# order permission denied lines set device_id
set llist [llength $devlist]
set lidevices ""
for {set i 1} {$i < $llist} {incr i} {
   set elem [lindex $devlist $i]
   set old0 [lindex $elem 0]
    # if permission denied
   if {[string compare $old0 df:] == 0} {
      set old1 [lindex $elem 1]
       # if cannot stavf
      if {[string compare $old1 cannot] == 0} {
	 set old3 [lindex $elem 3]
	 set elem {Denied $old3}
      }
      set new0 "Denied"
      set new1 0
      set new2 0
      set new3 0
      set new4 0
      set new5 [string trimright [lindex $elem 1] :]
      set new  [concat $new0 $new1 $new2 $new3 $new4 $new5]
      lappend lidevices [concat $i $new]
   } else {
      set new4 [string trimright [lindex $elem 4] %]
      set elem [lreplace $elem 4 4 $new4]
      lappend lidevices [concat $i $elem]
   }
}

set ODv_SysDevAll $lidevices

}


#################################
# Procedure: DoSysDevTabCre #
#################################

# Regine Kasten
# Procedure: OD_DoSysDevTabCre
# create the device-tables
proc OD_DoSysDevTabCre { } {

global ODv_oracursor
global oramsg

destroy .tl_sysdevtabcre


### exists device-tables ???

set li ""
OD_Msg "Searching for datafiles..."

orasql $ODv_oracursor "select table_name from user_tables where table_name = 'DEVICE$' or table_name = 'DEVICE_DFILE$'"

orafetch $ODv_oracursor {lappend li @1}

# if exists than drop tables
if  {[llength $li] != 0} { 
	OD_Msg "Droping Device-tables..."
	set error [catch {orasql $ODv_oracursor "drop table device_dfile$"}]
	if $error==1 {
		OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
		return
	}
	set error [catch {orasql $ODv_oracursor "drop table device$"}]
	if $error==1 {
		OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
		return
	}
}


### create new device-tables

OD_Msg "Creating Device-Tables..."

set error [catch {orasql $ODv_oracursor "create table device$ (device_id number(3) not null constraint oradev_pk primary key, fs_system varchar2(150) not null, blocks number(10) not null, used number(10) not null, free number(10) not null, percent number(3) not null, mount varchar2(150) not null)"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

set error [catch {orasql $ODv_oracursor "create table device_dfile$ (device_id number(3) not null constraint fk_devid references device$(device_id), tablespace_name varchar2(30) not null , file_id number(2) not null constraint devdat_pk primary key, file_name varchar2(257) not null)"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

OD_Msg "Creating Device-Tables finished"

}


#################################
# Procedure: DoSysDevTabGra     #
#################################

# Regine Kasten
# Procedure: OD_DoSysDevTabGra
# Issue the grant to command for the device tables 
proc OD_DoSysDevTabGra {} {

global ODv_oracursor
global oramsg

### exists device-tables ???

set li ""
OD_Msg "Searching for datafiles..."

orasql $ODv_oracursor "select table_name from user_tables where table_name = 'DEVICE$' or table_name = 'DEVICE_DFILE$'"

orafetch $ODv_oracursor {lappend li @1}

if  {[llength $li] == 0} {
    OD_Msg "Device-Tables not exists !!!"
    return
}


### set grantto

set grantto [string trim [.tl_sysdevtabgra.fr_inp.en_inp get]]
set grantto [string toupper $grantto]
 # if nothing is written
if {[string length $grantto] == 0} {
    .tl_sysdevtabgra.fr_message.mg_text configure -text "Grant must be specified !!!"
    return
  # exists grantee ????
} elseif {[string compare $grantto "PUBLIC"] != 0} {
    set error [catch {orasql $ODv_oracursor "select role from sys.dba_roles where role = '$grantto'"}]
    if {$error == 1} {
       	set error [catch {orasql $ODv_oracursor "select username from sys.dba_users where username = '$grantto'"}]
       	if {$error == 1} {
	   .tl_sysdevtabgra.fr_message.mg_text configure -text "Grant only to role or user !!!"
           return
       	}
    }
}

destroy .tl_sysdevtabgra

OD_Msg "Granting..."

set error [catch {orasql $ODv_oracursor "grant select on device$ to $grantto"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

set error [catch {orasql $ODv_oracursor "grant select on device_dfile$ to $grantto"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

OD_Msg "Grant select on device tables to $grantto finished"

}


#################################
# Procedure: DoSysDevTabDel     #
#################################

# Regine Kasten
# Procedure: OD_DoSysDevTabDel
# issue the delete from command to the device-tables
proc OD_DoSysDevTabDel { } {

global ODv_oracursor
global oramsg

destroy .tl_sysdevtabdel

### exists device-tables ???

set li ""
OD_Msg "Searching for datafiles..."

orasql $ODv_oracursor "select table_name from user_tables where table_name = 'DEVICE$' or table_name = 'DEVICE_DFILE$'"

orafetch $ODv_oracursor {lappend li @1}

if  {[llength $li] == 0} {
    OD_Msg "Device-Tables not exists !!!"
    return
}


### delete

OD_Msg "Deleting Device-Tables..."

set error [catch {orasql $ODv_oracursor "delete from device_dfile$"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

set error [catch {orasql $ODv_oracursor "delete from device$"}]

if $error==1 {
	OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
	return
}

OD_Msg "Deleting Device-Tables finished"

}


#################################
# Procedure: DoSysDevTabIns #
#################################

# Regine Kasten
# Procedure: OD_DoSysDevTabIns
# automatically insert into the device-tables
proc OD_DoSysDevTabIns { } {

global ODv_oracursor
global oramsg
global ODv_dfPath

destroy .tl_sysdevtabins

### exists device-tables ???

set li ""
OD_Msg "Searching for datafiles..."

orasql $ODv_oracursor "select table_name from user_tables where table_name = 'DEVICE$' or table_name = 'DEVICE_DFILE$'"

orafetch $ODv_oracursor {lappend li @1}

if  {[llength $li] == 0} {
    OD_Msg "Device-Tables not exists !!!"
    return
}


### search for datafiles

set lidatafiles ""

OD_Msg "Searching for datafiles..."

orasql $ODv_oracursor "select tablespace_name, file_id, file_name  from sys.dba_data_files  order by file_id"

orafetch $ODv_oracursor {lappend lidatafiles [list @1 @2 @3 ]}

if  {[llength $lidatafiles] == 0} {
    OD_Msg "No Data-Files available"
    return
}

set ODv_sysoldtag "sysSystem"
catch {OD_Help_Graph_Modify "sysSystem"}

 # set lists with all tablespace_names
set lendatafiles [llength $lidatafiles]
set lifilename   ""
foreach elem $lidatafiles {
	lappend lifilename [lindex $elem 2]
} 


### Searching for devices with df-command

OD_Msg "Searching for Devices..."

 # list of values for device$
set limount  ""
 # found devices
set founddev ""
 # list of values for device_dfile$
set lidata   ""
 # count datafiles
set i        1
 # count denied devices
set j        1
for {set k 0} {$k < $lendatafiles } {incr k} {
  set actfilename [lindex $lifilename $k]
  # search for devices for actfilename
  set ok     [catch  {exec $ODv_dfPath -ak $actfilename} dflist]     
  set dflist [split  $dflist \n]
  if {[llength $dflist] > 1} {
    set dfelem [lindex $dflist 0]
    # nothing found
    if {[lsearch $dfelem "No"] == -1} {	
	set dfelem [lindex $dflist 1]
	# name of actfound device
	set actdev [lindex $dfelem 0]
	# nothing found too
	if {[lsearch $dfelem "No"] == -1} {	
		# permission denied line
		if {[string compare $actdev df:] == 0} {
			set old1 [lindex $dfelem 1]
			# if cannot stavf
			if {[string compare $old1 cannot] == 0} {
				set old3 [lindex $dfelem 3]
				set dfelem {Denied $old3}
			}
			set actdev "Denied$j"
			set new1 0
			set new2 0
			set new3 0
			set new4 0
			set new5   [string trimright [lindex $dfelem 1] :]
			set dfelem [concat $actdev $new1 $new2 $new3 $new4 $new5]
			incr j
		} else { # "normal" result 
			set new4   [string trimright [lindex $dfelem 4] %]
			set dfelem [lreplace $dfelem 4 4 $new4]
		}
		set actdatafile [lindex $lidatafiles $k]
		# search device-id
		set pos [lsearch $founddev $actdev]
		if {$pos == -1} { # found new device
			# set act oracle device
			set dfelem [concat $i $dfelem] 
			lappend limount  $dfelem
			lappend founddev $actdev
			# set act device-datafile information
			set dataelem [concat $i $actdatafile]
			incr i
		} else { # found old device
			set pos      [expr $pos + 1]
			set dataelem [concat $pos $actdatafile]
		}
		lappend lidata $dataelem
	}
    }
  }
}


if  {[llength $limount] == 0} {
    OD_Msg "No mounted Oracle-Files found"
    return
}


### Inserting into the Device-Tables

OD_Msg "Inserting into Device-Tables..."

foreach elem $limount {
	set device_id [lindex $elem 0]
	set fs_system [lindex $elem 1]
	set blocks    [lindex $elem 2]
	set used      [lindex $elem 3]
	set free      [lindex $elem 4]
	set percent   [lindex $elem 5]
	set mount     [lindex $elem 6]
	set error [catch {orasql $ODv_oracursor "insert into device$ values($device_id, '$fs_system', $blocks, $used, $free, $percent, '$mount')"}]
	if $error==1 {
		OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
		return
	}
}

OD_Msg "Inserting into Device$  finished"

foreach elem $lidata {
	set device_id       [lindex $elem 0]
	set tablespace_name [lindex $elem 1]
	set file_id         [lindex $elem 2]
	set file_name       [lindex $elem 3]
	set error [catch {orasql $ODv_oracursor "insert into device_dfile$ values($device_id, '$tablespace_name', $file_id, '$file_name')"}]
	if $error==1 {
		OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
		return
	}
}

OD_Msg "Inserting into Device_DFile$ finished"


OD_Msg "Inserting into Device-Tables finished"

}


############################################
# Procedures: Optimizing	           #
############################################

#####################################
# Procedure: OD_DoAnalyzeTablesCom  #
#####################################

# Regine Kasten
# Procedure:  OD_DoAnalyzeTablesCom 
# Issue the analyze command for tables with compute  
proc OD_DoAnalyzeTablesCom { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeType {compute}

destroy .tl_analyzetabcom

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze table $tab compute statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Tables-Compute for table $tab finished"


OD_ShowAnalyzedTables $args

}


#####################################
# Procedure: OD_DoAnalyzeTablesEst  #
#####################################

# Regine Kasten
# Procedure: OD_DoAnalyzeTablesEst
# Issue the analyze command for tables with estimate
proc OD_DoAnalyzeTablesEst { args} {

global ODv_analyzeest
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_oracursor
global oramsg

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeType {estimate}

set sample [string trim [.tl_analyzetabest.fr_inp.en_inp get]]
if {[string length $sample] == 0} {
    .tl_analyzetabest.fr_message.mg_text configure -text "Sample must be specified!"
    return
} elseif {[ctype -failindex var digit $sample] == 0} {
  .tl_analyzetabest.fr_message.mg_text configure -text "Sample must be a number!"
  return
} elseif {[string compare $ODv_analyzeest "percent"] == 0} {
  if {[expr $sample < 100] == 0} {
     .tl_analyzetabest.fr_message.mg_text configure -text "Sample must be  < 100!"
     return
  }
}

destroy .tl_analyzetabest

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze table $tab estimate  statistics sample $sample $ODv_analyzeest"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Tables-Estimate for table $tab finished"

OD_ShowAnalyzedTables $ODv_AnalyzeArgs

}


#################################
# Procedure: DoAnalyzeTablesDel #
#################################

# Regine Kasten
# Procedure: OD_DoAnalyzeTablesDel
# Issue the analyze command fot tables with delete
proc OD_DoAnalyzeTablesDel { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeType {delete}

destroy .tl_analyzetabdel

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze table $tab delete statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Tables-Delete for table $tab finished"

OD_ShowAnalyzedTables $args

}


######################################
# Procedures: OD_DoAnalyzeIndexesCom #
######################################

# Regine Kasten
# Procedure:  OD_DoAnalyzeIndexesCom 
# Issue the analyze command for indexes with compute
proc OD_DoAnalyzeIndexesCom { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeType {compute}

destroy .tl_analyzeidxcom

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze index $ind compute statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Indexes-Compute for index $ind finished"

OD_ShowAnalyzedIndexes $args

}


#################################
# Procdure: DoAnalyzeIndexesEst #
#################################

# Regine Kasten
# Procedure: OD_DoAnalyzeIndexesEst
# Issue the analyze command for indexes with estimate
proc OD_DoAnalyzeIndexesEst { args} {

global ODv_analyzeest
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_oracursor
global oramsg

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeType {estimate}

set sample [string trim [.tl_analyzeidxest.fr_inp.en_inp get]]
if {[string length $sample] == 0} {
    .tl_analyzeidxest.fr_message.mg_text configure -text "Sample must be specified!"
    return
}  elseif {[ctype -failindex var digit $sample] == 0} {
  .tl_analyzeidxest.fr_message.mg_text configure -text "Sample must be a number!"
  return
} elseif {[string compare $ODv_analyzeest "percent"] == 0} {
  if {[expr $sample < 100] == 0} {
     .tl_analyzeidxest.fr_message.mg_text configure -text "Sample must be  < 100!"
     return
  }
}
 

destroy .tl_analyzeidxest

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze index $ind estimate statistics sample $sample $ODv_analyzeest"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Indexes-Estimate for index $ind finished"

OD_ShowAnalyzedIndexes $ODv_AnalyzeArgs

}


##################################
# Procedure: DoAnalyzeIndexesDel #
##################################

# Regine Kasten
# Procedure: OD_DoAnalyzeIndexesDel
# Issue the analyze command for indexes with delete
proc OD_DoAnalyzeIndexesDel { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeType {delete}

destroy .tl_analyzeidxdel

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze index $ind delete statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Indexes-Delete for index $ind finished"

OD_ShowAnalyzedIndexes $args

}


######################################
# Procedure: OD_DoAnalyzeClustersCom #
######################################

# Regine Kasten
# Procedure:  OD_DoAnalyzeClustersCom 
# Issue the analyze command for cluster with compute 
proc OD_DoAnalyzeClustersCom { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set clu             [lindex $args 3]
set ODv_AnalyzeType {compute}

destroy .tl_analyzeclucom

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze cluster $clu compute statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Clusters-Compute for Cluster $clu finished"


OD_ShowAnalyzedCluster $args

}


######################################
# Procedure: OD_DoAnalyzeClustersEst #
######################################

# Regine Kasten
# Procedure: OD_DoAnalyzeClustersEst
# Issue the analyze command for cluster with estimate
proc OD_DoAnalyzeClustersEst { args} {

global ODv_analyzeest
global ODv_AnalyzeType
global ODv_AnalyzeArgs
global ODv_oracursor
global oramsg

set args            [string trim $args \{\}]
set clu             [lindex $args 3]
set ODv_AnalyzeType {estimate}

set sample [string trim [.tl_analyzecluest.fr_inp.en_inp get]]
if {[string length $sample] == 0} {
    .tl_analyzecluest.fr_message.mg_text configure -text "Sample must be specified!"
    return
}  elseif {[ctype -failindex var digit $sample] == 0} {
  .tl_analyzecluest.fr_message.mg_text configure -text "Sample must be a number!"
  return
} elseif {[string compare $ODv_analyzeest "percent"] == 0} {
  if {[expr $sample < 100] == 0} {
     .tl_analyzecluest.fr_message.mg_text configure -text "Sample must be  < 100!"
     return
  }
}

destroy .tl_analyzecluest

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze cluster $clu estimate statistics sample $sample $ODv_analyzeest"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Clusters-Estimate for Cluster $clu finished"

OD_ShowAnalyzedCluster $ODv_AnalyzeArgs

}


######################################
# Procedure: OD_DoAnalyzeClustersDel #
######################################

# Regine Kasten
# Procedure: OD_DoAnalyzeClustersDel
# Issue the analyze command for cluster with delete
proc OD_DoAnalyzeClustersDel { args} {

global ODv_oracursor
global oramsg
global ODv_AnalyzeType

set args            [string trim $args \{\}]
set clu             [lindex $args 3]
set ODv_AnalyzeType {delete}

destroy .tl_analyzecludel

OD_Msg "Analyzing..."

set error [catch {orasql $ODv_oracursor "analyze cluster $clu delete statistics"}]

if $error==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt) $error"
   return
}

OD_Msg "Analyze-Clusters-Delete for Cluster $clu finished"

OD_ShowAnalyzedCluster $args

}



####################################
# Procedure: OD_DoLong             #
####################################


proc OD_DoLong { io} {
global ODv_oracursor

set tab [string trim [.tl_longfile.fr_tab.en_tab get]]
if {[string length $tab] == 0} {
    .tl_longfile.fr_message.mg_text configure -text "Table must be specified!"
    return
}

set col [string trim [.tl_longfile.fr_col.en_col get]]
if {[string length $col] == 0} {
    .tl_longfile.fr_message.mg_text configure -text "Column must be specified!"
    return
}
set row [string trim [.tl_longfile.fr_row.en_row get]]
if {[string length $row] == 0} {
    .tl_longfile.fr_message.mg_text configure -text "Row-ID must be specified!"
    return
}
set fil [string trim [.tl_longfile.fr_file.en_file get]]
if {[string length $tab] == 0} {
    .tl_longfile.fr_message.mg_text configure -text "Filename must be specified!"
    return
}

if {[string compare $io Read] == 0} {
   set extra "into file $fil from $tab.$col"
   set dbret [catch {orareadlong $ODv_oracursor $row $tab $col $fil} result]
} else {
   set extra "into $tab.$col from file $fil"
   if [file isfile $fil] {
      set dbret [catch {orawritelong $ODv_oracursor $row $tab $col $fil} result]
   } else {
      .tl_longfile.fr_message.mg_text configure -text "Error: $fil file not found"
      return
   }
}

if {$dbret==1} {
   .tl_longfile.fr_message.mg_text configure -text "Error: $result\n\n(bad Table, Column or Row-ID ?)\n\n"
} else {
   .tl_longfile.fr_message.mg_text configure -text "$result bytes transferred\n$extra\n\n"
}
}


#####################################
# Procedure: OD_DoPL                #
#####################################


proc OD_DoPL {} {
global ODv_oracursor
global oramsg

set d [replicate "----------------" 16]
set row ""
set sql_str [.tl_main.fr_statement.tx_statement get 1.0 end]
set sql_filt ""

OD_ClearResult

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
  OD_Msg "No SQL to execute"
  return
}

OD_InsSQL

set bind_vars [.tl_plexec.fr_inp.en_inp get]

OD_Msg "Running PL/SQL"
set dbret [catch {set row [eval oraplexec $ODv_oracursor \"$sql_filt\" $bind_vars]}]

set rc $oramsg(rc)

OD_CheckMessage

set col_names [oracols $ODv_oracursor]
set c_lengs ""
set r_lengs ""

foreach c $col_names {
   lappend c_lengs [string length $c]
}
foreach c $row {
   lappend r_lengs [string length $c]
}

set fmt ""

for {set i 0} {$i < [llength $c_lengs]} {incr i} {
   set len [max [lindex $c_lengs $i] [lindex $r_lengs $i]]
   append fmt "%-${len}.${len}s"
}

.tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $col_names]
set dash $col_names
for {set i 0} {$i < [llength $dash]} {incr i} {
   set dash [lreplace $dash $i $i $d]
}

.tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $dash]
.tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $row]

OD_Msg "PL/SQL Execute done, return code = $rc"
}


###################################
# Procedure: OD_DoSQL             #
###################################


proc OD_DoSQL {} {
global ODv_oracursor
global oramsg
global contFlag
global stopFlag
global ODv_appendclear
global ODv_cmdRing

set contFlag 1
set stopFlag 1
global ODv_cmdExec
set ODv_cmdExec "set contFlag 0; set stopFlag 0"
.tl_main.fr_menu.execute configure -text "Cancel" -state active
update

set NO_MORE_ROWS 1403

set d [replicate "----------------" 16]

set txtindx ""
set txtcols ""
set txtdata ""
set txtlens ""
set row ""
set cnt 0
set sql_str [.tl_main.fr_statement.tx_statement get 1.0 end]
set sql_filt ""
set rpc_rows 0

if $ODv_appendclear OD_ClearResult

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
  OD_Msg "No SQL to execute"
  set ODv_cmdExec OD_DoSQL
  .tl_main.fr_menu.execute configure -text "Execute" -state normal
  return
}

OD_InsSQL
OD_Msg "Running SQL"
set dbret [catch {orasql $ODv_oracursor $sql_filt}]

if $dbret==1 {
   OD_Msg "Error: $oramsg(rc) : $oramsg(errortxt)"
   set ODv_cmdExec OD_DoSQL
   .tl_main.fr_menu.execute configure -text "Execute" -state active
   return
} else {
   set rpc_rows $oramsg(rows)
   OD_Msg "SQL finished, getting results"
   OD_CheckMessage
}

set fmt ""
if {$oramsg(rc) != $NO_MORE_ROWS} {
  set row [orafetch $ODv_oracursor]
  OD_CheckMessage
}
set lastnext $oramsg(rc)
if {[string length $row] == 0} {
  set contFlag  0
}

while {$oramsg(rc) == 0 && $contFlag} {
   set rpc_rows $oramsg(rows)
   if {[string length $fmt] == 0} {
      set col_names [oracols $ODv_oracursor]
      OD_CheckMessage
      set i [lsearch $oramsg(coltypes) long]
      while {$i >= 0} {
	 lappend txtindx $i
	 lappend txtcols  [lvarpop col_names $i]
	 lappend txtllens [lvarpop oramsg(collengths) $i]
	 lvarpop oramsg(coltypes) $i
	 set i [lsearch $oramsg(coltypes) long]
      }
      set fmt [OD_FormatCols $col_names $oramsg(coltypes) $oramsg(collengths)]
      .tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $col_names]
      set dash $col_names
      for {set i 0} {$i < [llength $dash]} {incr i} {
	  set dash [lreplace $dash $i $i $d]
      }
      .tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $dash]
   }

   if {[string length $row] == 0} {
      set fmt ""
   } else {
      set txtdata ""
      foreach i $txtindx {
	 lappend txtdata [lvarpop row $i]
      } 
      .tl_result.fr_result.lb_result insert end [eval format \"$fmt\" $row]
      incr cnt
      if {[llength $txtindx] > 0} {
	 set i 0
	 foreach t $txtcols {
	   .tl_result.fr_result.lb_result insert end "" [lindex $txtcols $i]
	   .tl_result.fr_result.lb_result insert end [string range $d 0 30]
	   eval .tl_result.fr_result.lb_result insert end [split [lindex $txtdata $i] \n]
	   .tl_result.fr_result.lb_result insert end ""
	 }
      }
    }

    if {$cnt % 20 == 0} {
      OD_Msg "$cnt rows so far...."
      update
    }

    set row [orafetch $ODv_oracursor]
    OD_CheckMessage
}

if $stopFlag {
  OD_Msg "SQL finished, $cnt rows returned, $rpc_rows rows affected"
} else {
  OD_Msg "SQL interrupted, $cnt rows returned"
}

set  ODv_cmdExec OD_DoSQL
.tl_main.fr_menu.execute configure -text "Execute" -state normal
}





####################################
# Procedure: OD_FormatCols         #
####################################


proc OD_FormatCols { names types lengths} {
set fmt ""

while {! [lempty $names]} {
   set t [lvarpop types]
   set l [lvarpop lengths]
   set n [lvarpop names] 

   case $t {
     {number}   {set len 18; set just ""}
     {rowid}    {set len 19; set just ""}
     {*date}    {set len 26; set just -}
     {*char*}   {set len $l; set just -}
     {default}  {set len 32; set just -}
   }

   set len [max $len [string length $n]]
   append fmt "%${just}${len}.${len}s "
}
return $fmt
}



#####################################
# Procedure: OD_LongFile            #
#####################################


proc OD_LongFile { io} {
global ODv_longfilename

set ODv_longfilename ""

if {[string compare $io Write]==0} {
  set mtext "Write a Long Column from a file"
} else {
  set mtext "Read a Long Column from a file"
}

ShowWindow.tl_longfile
.tl_longfile.fr_message.mg_text configure -text $mtext
.tl_longfile.fr_cmd.bn_ok  configure -command "OD_DoLong $io"
update idletask

focus .tl_longfile.fr_tab.en_tab
}



###################################
# Procedure: OD_PLExec            #
###################################


proc OD_PLExec {} {
ShowWindow.tl_plexec
focus .tl_plexec.fr_inp.en_inp
}


###################################
# Procedure: OD_PickFileName      #
###################################


proc OD_PickFileName { win fn} {
global ODv_longfilename

set ODv_longfilename $fn
destroy $win
}




########################################
# Procedures: Analyze                  #
########################################

###################################
# Procedure: OD_AnalyzeTablesCom  #
###################################

# Regine Kasten
# Procedure: OD_AnalyzeTablesCom
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeTablesCom { args} {

global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzetabcom $args
}

###################################
# Procedure: OD_AnalyzeTablesEst  #
###################################

# Regine Kasten
# Procedure: OD_AnalyzeTablesEst
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeTablesEst { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzetabest $ODv_AnalyzeArgs
focus .tl_analyzetabest.fr_inp.en_inp
}

###################################
# Procedure: OD_AnalyzeTablesDel  #
###################################

# Regine Kasten
# Procedure: OD_AnalyzeTablesDel
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeTablesDel { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set tab             [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzetabdel $args
}


####################################
# Procedure: OD_AnalyzeIndexesCom  #
####################################

# Regine Kasten
# Procedure: OD_AnalyzeIndexesCom
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeIndexesCom { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzeidxcom $args
}

###################################
# Procedure: OD_AnalyzeIndexesEst #
###################################

# Regine Kasten
# Procedure: OD_AnalyzeIndexesEst
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeIndexesEst { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzeidxest $ODv_AnalyzeArgs
focus .tl_analyzeidxest.fr_inp.en_inp
}


###################################
# Procedure: OD_AnalyzeIndexesDel #
###################################

# Regine Kasten
# procedure: OD_AnalyzeIndexesDel
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeIndexesDel { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set ind             [lindex $args 0]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzeidxdel $args
}


###################################
# Procedure: OD_AnalyzeClustersCom#
###################################

# Regine Kasten
# Procedure: OD_AnalyzeClustersCom
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeClustersCom { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set clu             [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzeclucom $args
}

###################################
# Procedure: OD_AnalyzeClustersEst#
###################################

# Regine Kasten
# Procedure: OD_AnalyzeClustersEst
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeClustersEst { args} {
global ODv_AnalyzeArgs

set args            [string trim $args \{\}]
set clu             [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzecluest $ODv_AnalyzeArgs
focus .tl_analyzecluest.fr_inp.en_inp
}

###################################
# Procedure: OD_AnalyzeClustersDel#
###################################

# Regine Kasten
# Procedure: OD_AnalyzeClustersDel
# sets variable ODv_AnalyzeArgs 
proc OD_AnalyzeClustersDel { args} {
global ODv_AnalyzeArgs

set args [string trim $args \{\}]
set clu  [lindex $args 3]
set ODv_AnalyzeArgs $args

ShowWindow.tl_analyzecludel $args
}

