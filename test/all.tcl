# all.tcl --
#
# This file is sourced by the 'make test' target to execute the
# Oratcl test suite
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.
#
# RCS: @(#) $Id: all.tcl,v 1.2.6.1 2000-05-25 01:25:43 tmh Exp $

if {$tcl_platform(os) == "Win32s"} {
    set files [glob test/*.tes]
} else {
    set files [glob test/*.test]
}

global ora_lda

source [file join [file dirname [info script]] defs.tcl]
source [file join [file dirname [info script]] startup.tcl]

set tests [glob -nocomplain \
	     [file join [file dirname [info script]] ora*.test]]

foreach test [lsort $tests] {
	puts stdout $test
	flush stdout
	if {[catch {source $test} msg]} {
		puts $msg
	}
}     

source [file join [file dirname [info script]] cleanup.tcl]
