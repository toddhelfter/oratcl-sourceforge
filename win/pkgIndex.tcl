package ifneeded Oratcl 3.0.2 "
	global tcl_platform
	if {[string equal $tcl_platform(platform) unix]} {
		load [file join $dir .. oratcl302.dll]
	} else {
		load [file join $dir .. .. bin oratcl302.dll]
	}
        source [file join $dir oraclob.tcl]
"
