package ifneeded Oratcl 3.1 "
	global tcl_platform
	if {[string equal $tcl_platform(platform) unix]} {
		load [file join $dir .. oratcl31.dll]
	} else {
		load [file join $dir .. .. bin oratcl31.dll]
	}
        source [file join $dir oralob.tcl]
"
