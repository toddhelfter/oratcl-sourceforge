
#############################
# Show window : Startup     #
#############################


proc ShowWindow.tl_startup { args} {


catch "destroy .tl_startup"

toplevel .tl_startup   -relief {raised}

# Window manager configurations
wm positionfrom .tl_startup program
wm sizefrom .tl_startup program
wm title .tl_startup {ODDIS - Startup}
wm withdraw .

message .tl_startup.mg_startup  -aspect {1000}  -padx {5}  -pady {2}  -relief {ridge}  -text {ODDIS - Oracle Connection Dialog}
frame .tl_startup.fr_user  -borderwidth {2}
entry .tl_startup.fr_user.en_user  -relief {sunken}
  # bindings
  bind .tl_startup.fr_user.en_user <Key-Return> {focus .tl_startup.fr_pw.en_pw}
label .tl_startup.fr_user.lb_user  -text { User          }

pack append .tl_startup.fr_user  .tl_startup.fr_user.en_user {right frame e padx 20 pady 20 expand}  .tl_startup.fr_user.lb_user {left frame center}

frame .tl_startup.fr_pw  -borderwidth {2}
entry .tl_startup.fr_pw.en_pw -show { }  -relief {sunken} 
  # bindings
  bind .tl_startup.fr_pw.en_pw <Key-Return> {.tl_startup.fr_cmd.bn_connect invoke}
label .tl_startup.fr_pw.lb_pw  -text {Password    }

pack append .tl_startup.fr_pw  .tl_startup.fr_pw.en_pw {right frame e padx 20 pady 20 expand}  .tl_startup.fr_pw.lb_pw {left frame center}

frame .tl_startup.fr_sl  -borderwidth {2}
entry .tl_startup.fr_sl.en_sl  -relief {sunken}
  # bindings
  bind .tl_startup.fr_sl.en_sl <Key-Return> {.tl_startup.fr_cmd.bn_connect invoke}
menubutton .tl_startup.fr_sl.mb_sl  -menu {.tl_startup.fr_sl.mb_sl.m}  -relief {raised}  -text {Server-List}  
menu .tl_startup.fr_sl.mb_sl.m

pack append .tl_startup.fr_sl  .tl_startup.fr_sl.en_sl {right frame e padx 20 pady 20 expand}  .tl_startup.fr_sl.mb_sl {left frame center}

message .tl_startup.mg_error  -aspect {1500}  -padx {5}  -pady {2}  -text {}
frame .tl_startup.fr_cmd  -borderwidth {2}  -relief {raised}
button .tl_startup.fr_cmd.bn_connect  -command {OD_TryConnect [.tl_startup.fr_user.en_user get] [.tl_startup.fr_pw.en_pw get] [.tl_startup.fr_sl.en_sl get] }  -text {Try Connect}
button .tl_startup.fr_cmd.bn_cancel  -command {destroy .}  -text {Cancel}

pack append .tl_startup.fr_cmd  .tl_startup.fr_cmd.bn_connect {left frame center expand fillx}  .tl_startup.fr_cmd.bn_cancel {left frame center expand fillx}

pack append .tl_startup  .tl_startup.mg_startup {top frame center pady 5 fillx}  .tl_startup.fr_user {top frame center padx 80 pady 10}  .tl_startup.fr_pw {top frame center}  .tl_startup.fr_sl {top frame center pady 15}  .tl_startup.mg_error {top frame center fillx}  .tl_startup.fr_cmd {top frame center fillx}

tk_menuBar .tl_startup.fr_sl .tl_startup.fr_sl.mb_sl

.tl_startup.fr_user.en_user insert end {}
.tl_startup.fr_pw.en_pw insert end {} 
.tl_startup.fr_sl.en_sl insert end {}

}



####################################
# Procedure: OD_CheckMessage       #
####################################


proc OD_CheckMessage {} {
global oramsg

if {[string length $oramsg(errortxt)] > 0} {
   set msgs [split $oramsg(errortxt) \n]
   set msgn [split $oramsg(rc) |n]
   set i 0
   foreach f $msgs {
      set msgno ""
      catch {set msgno [lindex $msgn $i]}
      .tl_result.fr_result.lb_result insert end "$msgno: $f"
      incr i
  }
}
}


#####################################
# Procedure: OD_ExitODDIS           #
#####################################


proc OD_ExitODDIS {} {
global ODv_orahandle

oralogoff $ODv_orahandle
destroy .
exit
}


#####################################################
# Start procedures                                  #
#####################################################


# Procedure: OD_StartUp
proc OD_StartUp {} {
global env
global ODv_user
global ODv_cmdRing
global matchInfo

set ODv_user [id user]

for {set i 0} {$i < 10} {incr i} {
  set ODv_cmdRing($i) ""
}

set ora_home [lsearch [array names env] ORACLE_HOME]

if {$ora_home == -1} {
  set ora_home ""
  catch {set ora_home [exec ypcat passwd | egrep ^oracle: ]}
  if {[string length $ora_home] > 0} {
    set ora_home [lindex [split $ora_home :] 5]
  } else {
    set ora_home [exec egrep ^oracle: < /etc/passwd]
    if {[string length $ora_home] > 0} {
      set ora_home [lindex [split $ora_home :] 5]
    } else {
      set ora_home ""
    }
  }
  set $env(ORACLE_HOME) $ora_home
} else {
  set ora_home $env(ORACLE_HOME)
}

set serverlist ""

set intfile /etc/oratab
if [file isfile $intfile] {
  set fd [open $intfile]
  set sc [scancontext create]
  scanmatch -nocase $sc {^[a-z]}  {lappend serverlist [lindex [split $matchInfo(line) :] 0]}
  scanfile $sc $fd
  close $fd
}

set intfile /etc/sqlnet
if [file isfile $intfile] {
  set fd [open $intfile]
  set sc [scancontext create]
  scanmatch -nocase $sc {^[a-z]}  {lappend serverlist "@[lindex $matchInfo(line) 0]"}
  scanfile $sc $fd
  close $fd
}

set intfile $env(HOME)/.sqlnet
if [file isfile $intfile] {
  set fd [open $intfile]
  set sc [scancontext create]
  scanmatch -nocase $sc {^[a-z]}  {lappend serverlist "@[lindex $matchInfo(line) 0]"}
  scanfile $sc $fd
  close $fd 
}

if {[llength $serverlist] == 0} {
   lappend serverlist "(localdb)"
   lappend serverlist "(@remote_alias)"
   lappend serverlist "(@T:host:remoteedb)"
}

ShowWindow.tl_startup
foreach s $serverlist {
   .tl_startup.fr_sl.mb_sl.m add command -label $s -command ".tl_startup.fr_sl.en_sl delete 0 end; .tl_startup.fr_sl.en_sl insert 0 $s"
}

.tl_startup.fr_user.en_user delete 0 end
.tl_startup.fr_user.en_user insert 0 $ODv_user

.tl_startup.fr_sl.en_sl delete 0 end

if { [lsearch [array names env] ORACLE_SID] >= 0} {
   .tl_startup.fr_sl.en_sl insert 0 $env(ORACLE_SID)
} else {
  .tl_startup.fr_sl.en_sl insert 0 [lindex $serverlist 0]
}

focus .tl_startup.fr_pw.en_pw
}


# Procedure: OD_TryConnect
proc OD_TryConnect { use pw ser} {
global env
global oramsg
global ODv_orahandle
global ODv_oracursor
global ODv_server
global ODv_user
global errortxt

if {[string first @ $ser] == 0} {
  set ODv_server $ser
} else {
  set ODv_server $ser
  set env(ORACLE_SID) $ser
  set ser "" 
}

set ODv_user [string toupper $use]

set retcode [catch {set ODv_orahandle [oralogon ${use}/${pw}${ser}]}]

if {$retcode == 0} {
   set ODv_oracursor [oraopen $ODv_orahandle]
   .tl_startup.fr_pw.en_pw delete 0 end 
   destroy .tl_startup
   ShowWindow.tl_main
   ShowWindow.tl_info 
   ShowWindow.tl_result
   OD_Msg "Connected to database"
   focus .tl_main.fr_statement.tx_statement
} else {
   .tl_startup.mg_error configure -text $oramsg(errortxt)
   focus .tl_startup.fr_pw.en_pw
}
}

