# all.tcl --
#
# This file is sourced by the 'make test' target to execute the
# Oratcl test suite
#
#
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: all.tcl,v 1.1 1999-10-12 01:59:42 mtariq Exp $


source [file  join [pwd] [file dirname [info script]] defs.tcl]

if {[catch {set t [oralogon $oracleuser/$oraclepw@$connstring]} msg]} {
	puts "Connection to Oracle database can not be established"
} elseif {[regexp ^(oratcl)+.* $t]} {
   oralogoff $t
   set tests [glob -nocomplain ../test/*.test]
   foreach i $tests {
      puts stdout $i
      flush stdout
       if {[catch {source $i} msg]} {
        puts $msg
       }
   }     
}

