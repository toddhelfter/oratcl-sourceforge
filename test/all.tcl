# all.tcl --
#
# This file is sourced by the 'make test' target to execute the
# Oratcl test suite
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.
#
# RCS: @(#) $Id: all.tcl,v 1.18 2002-09-17 20:42:05 tmh Exp $

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
		oraparse.test \
		orabind.test \
		oraexec.test \
		orafetch.test \
		oracols.test \
		oradesc.test \
		oracommit.test \
		oralob.test \
		oralong.test \
		safe.test \
		orasql.test \
		orabindexec.test \
		oraplexec.test \
		i18n.test \
		codes.test \
		async.test \
		usertype.test \
	]

foreach test $testlist {
	lappend tests [file join [file dirname [info script]] $test]
}

set testtimes {}
foreach test $tests {
	puts stdout \n$test
	flush stdout
	set t0 [clock clicks -milliseconds]
	if {[catch {source $test} msg]} {
		puts $msg
	}
	set tD [clock clicks -milliseconds]
	set times "$test :: [expr {$tD - $t0}] ms"
	puts stdout $times
	lappend testtimes $times
}     

source [file join [file dirname [info script]] cleanup.tcl]

puts stderr "\ntest timings\n"
foreach times $testtimes {
	puts stdout $times
}
