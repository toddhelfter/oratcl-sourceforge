package ifneeded Oratcl 3.0.2 "
	global tcl_platform
	if {[string equal $tcl_platform(platform) unix]} {
		load [file join $dir .. liboratcl3.0.2.so]
	} else {
		load [file join $dir .. .. bin liboratcl3.0.2.so]
	}
        source [file join $dir oralob.tcl]
"
