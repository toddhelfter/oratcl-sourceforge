package ifneeded Oratcl 3.1 "
	global tcl_platform
	if {[string equal $tcl_platform(platform) unix]} {
		load [file join $dir .. liboratcl3.1.so]
	} else {
		load [file join $dir .. .. bin liboratcl3.1.so]
	}
        source [file join $dir oralob.tcl]
"
