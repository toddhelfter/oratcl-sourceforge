# all.tcl --
#
# This file is sourced by the 'make test' target to execute the
# Oratcl test suite
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.
#
# RCS: @(#) $Id: all.tcl,v 1.5 2000-09-27 20:39:37 tmh Exp $

if {$tcl_platform(os) == "Win32s"} {
    set files [glob ../test/*.tes]
} else {
    set files [glob ../test/*.test]
}

global ora_lda

source [file join [file dirname [info script]] defs.tcl]
source [file join [file dirname [info script]] startup.tcl]

set testlist [list \
		oralogin.test \
		oraopen.test \
		orasql.test \
		oracols.test \
		orabindexec.test \
		oraplexec.test \
		orasafe.test \
		oracommit.test \
		oralob.test \
		i18n.test]

foreach test $testlist {
	lappend tests [file join [file dirname [info script]] $test]
}

foreach test $tests {
	puts stdout $test
	flush stdout
	if {[catch {source $test} msg]} {
		puts $msg
	}
}     

source [file join [file dirname [info script]] cleanup.tcl]
