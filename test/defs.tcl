# defs.tcl --
#
# This file contains definitions needed by the Oratcl test files
# The connection data needed to connect to your specific database 
# should be entered in this file. 
#
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: defs.tcl,v 1.2 1999-11-06 03:25:54 mtariq Exp $


if {[lsearch [namespace children] ::tcltest] == -1} {
	package require tcltest
	namespace import ::tcltest::*
	}

#Oracle environment variables

set ::env(NLS_LANG) American_America.UTF8
set ::env(ORACLE_HOME) /tools/1.3/solaris-sparc/oracle

#Oracle user, password, and connection string information
set oracleuser scott
set oraclepw tiger
set connstring or8i
package require Oratcl

