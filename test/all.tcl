# all.tcl --
#
# This file is sourced by the 'make test' target to execute the
# Oratcl test suite
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.
#
# RCS: @(#) $Id: all.tcl,v 1.9 2001-08-25 22:00:49 tmh Exp $

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
		orainfo.test \
		orasql.test \
		oracols.test \
		oradesc.test \
		orabindexec.test \
		oraplexec.test \
		oracommit.test \
		oralob.test \
		oralong.test \
		orasafe.test \
		i18n.test \
	]

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
