# defs.tcl --
#
# This file contains definitions needed by the Oratcl test files
# The connection data needed to connect to your specific database 
# should be entered in this file. 
#
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: defs.tcl,v 1.1 1999-10-12 02:00:31 mtariq Exp $


if {[lsearch [namespace children] ::tcltest] == -1} {
	package require tcltest
	namespace import ::tcltest::*
	}

#Oracle environment variables

set ::env(NLS_LANG) American_America.UTF8
set ::env(ORA_NLS33) /tools/1.3/solaris-sparc/oracle/nls

#Oracle user, password, and connection string information
set oracleuser scott
set oraclepw tiger
set connstring or8i
package require Oratcl

