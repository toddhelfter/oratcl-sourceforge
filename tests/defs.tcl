# defs.tcl --
#
#
# Copyright (c) 2017 by Todd M. Helfter
# All rights reserved.
# 
# RCS: @(#) $Id: defs.tcl,v 1.8 2017/09/29 02:06:03 tmh Exp $


if {[lsearch [namespace children] ::tcltest] == -1} {
	package require tcltest
	namespace import ::tcltest::*
	}

package require -exact Oratcl 5.0

# ensure NLS_LANG is set for proper UTF-8 handling
if {![info exists env(NLS_LANG)] || $env(NLS_LANG) eq ""} {
    set env(NLS_LANG) AMERICAN_AMERICA.AL32UTF8
}

# check for ORACLE env var
if {![info exists env(ORACLE_HOME)]} {
    puts "ORACLE_HOME environment variable not defined"
    puts "please enter the full pathname of your Oracle installation"
    gets stdin env(ORACLE_HOME)
}
puts "\n\tUsing tclsh binary :: [info nameofexecutable]"
puts "\n\tUsing oracle home :: $env(ORACLE_HOME)"

# get oracle credentials from env vars or interactive prompts
# env vars: ORA_TEST_USER, ORA_TEST_PW, ORA_TEST_SERVER
puts {}

if {[info exists env(ORA_TEST_USER)]} {
    set ora_userid $env(ORA_TEST_USER)
} else {
    puts "Enter your oracle id: "
    puts -nonewline ">"
    flush stdout
    gets stdin ora_userid
}

if {[info exists env(ORA_TEST_PW)]} {
    set ora_pw $env(ORA_TEST_PW)
} else {
    puts "Enter your oracle password: "
    puts -nonewline ">"
    flush stdout
    gets stdin ora_pw
}

if {[info exists env(ORA_TEST_SERVER)]} {
    set ora_server $env(ORA_TEST_SERVER)
} else {
    puts "For remote connection enter your oracle connect string: "
    puts -nonewline ">"
    flush stdout
    gets stdin ora_server
}

if {[string length $ora_server]} {
        set ora_constr $ora_userid/$ora_pw@$ora_server
        puts "\n\ttesting using a remote connection.\n"
	flush stdout
} else {
        set ora_constr $ora_userid/$ora_pw
        puts "\n\ttesting using a local connection.\n"
	flush stdout
}
