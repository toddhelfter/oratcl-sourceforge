# defs.tcl --
#
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.
# 
# RCS: @(#) $Id: defs.tcl,v 1.5 2006-07-07 17:04:54 tmh Exp $


if {[lsearch [namespace children] ::tcltest] == -1} {
	package require tcltest
	namespace import ::tcltest::*
	}

package require -exact Oratcl 4.5

# check for ORACLE env var
if {![info exists env(ORACLE_HOME)]} {
    puts "ORACLE_HOME environment variable not defined"
    puts "please enter the full pathname of your Oracle installation"
    gets stdin env(ORACLE_HOME)
}
puts "\n\tUsing oracle home :: $env(ORACLE_HOME)"

# prompt for oracle user id, password, server, and dbname
puts {}

puts "Enter your oracle id: "
puts -nonewline ">"
flush stdout
gets stdin ora_userid

puts "Enter your oracle password: "
puts -nonewline ">"
flush stdout
gets stdin ora_pw

puts "For remote connection enter your oracle connect string: "
puts -nonewline ">"
flush stdout
gets stdin ora_server

if {[string length $ora_server]} {
        set ora_constr $ora_userid/$ora_pw@$ora_server
        puts "\n\ttesting using a remote connection.\n"
	flush stdout
} else {
        set ora_constr $ora_userid/$ora_pw
        puts "\n\ttesting using a local connection.\n"
	flush stdout
}
