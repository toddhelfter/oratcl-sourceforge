# simple installer for Sybtcl/Oratcl
# Copyright 1997 Tom Poindexter

# read in the makefile, to figure out which package and version

frame .f
pack .f -side top
text .f.t
pack .f.t -side top -fill both -expand 1

proc puts {text} {.f.t insert end "$text\n"; .f.t see end; update idletasks}

puts ""
update idletasks

set fn  [info script]
set spl [file split $fn]
set pll [llength $spl]
set npll [incr pll -2]

set path [lindex  $spl 0]
foreach elem [lrange $spl 1 $npll] {
	set path [file join $path $elem]
}

set make [file join $path makefile.vc]

if {[catch {set fd [open $make]}]} {
  puts "can't find 'makefile.vc'"
  update idletasks
  after 3000
  exit
}

set mf [read $fd]
close $fd

set project ""
set version ""
set dllvers ""

set ws "\[ \t]?"
set al "\[A-Za-z_]*"
set vn "\[0-9]*\\.\[0-9]*"
set dl "\[0-9]*"

# parse project name, version, and dll version

if {! [regexp "${ws}PROJECT${ws}=${ws}(${al})"          $mf match project] } {
  puts "can't find package name"
  update idletasks
  after 3000
  exit
}
if {! [regexp -nocase "${ws}${project}_VERSION${ws}=${ws}(${vn})" $mf \
							  match version] } {
  puts "can't find package version"
  update idletasks
  after 3000
  exit
}
if {! [regexp "${ws}DLL_VERSION${ws}=${ws}(${dl})"      $mf match dllvers] } {
  puts "can't find package dll version"
  update idletasks
  after 3000
  exit
}

# set directory for pkgIndex.tcl, set required dll, and install dll name

set proj_dir ${project}${dllvers}
set proj_dll ${project}${dllvers}.dll
set inst_dll ${project}${dllvers}.dll

#puts "proj_dir = $proj_dir"
#puts "proj_dll = $proj_dll"
#puts "inst_dll = $inst_dll"


# set package name

set package "[string toupper [string range $project 0 0]][string tolower [string range $project 1 end]]"

# see if project dll file exists

if {! [file isfile $proj_dll] } {
  puts "can't find $proj_dll"
  puts "there doesn't seem to be a dll for $project version $version"
  update idletasks
  after 3000
  exit
}

# get tcl lib location, location based on nameofexecutable

set tcllib [file join [file dirname [file dirname [info nameofexecutable]]] lib]

# see if auto_path is flakey (some 7.6 installations)
set ok 1
foreach dir $auto_path {
  if {! [file isdirectory $dir]} {
    set ok 0
    break
  }
}

if {$ok} {
  # ok to install in private project directory
  set proj_dir [file join $tcllib $proj_dir]
} else {
  # auto_path is flakey, just install in tcl_library
  set proj_dir [info library]
}

# tell user what we are about to to

puts ""
puts "installing $package"
puts ""
puts "steps to be performed:"
puts ""
puts "  copy  $proj_dll [file join $tcllib oratcl302 $inst_dll]"
if {! [file isdirectory [file join $proj_dir]] } {
  puts "  mkdir [file join $proj_dir]"
}
puts "  copy  pkgIndex.tcl [file join $tcllib oratcl30 pkgIndex.tcl]"

set ans Y
puts ""
puts "installing now"
puts ""

# install if answer was yes,y

switch -glob -- $ans {
  y* -
  Y* {
    if {! [file isdirectory $proj_dir] } {
      puts "mkdir file join $proj_dir"
      if {[catch {file mkdir $proj_dir}]} {
	puts "oops, can't mkdir $proj_dir"
  update idletasks
  after 3000
	exit
      }
    }
	set path_dll [file join $tcllib $proj_dir $inst_dll] 
	puts "copy  $proj_dll $path_dll"
	if {[catch {file copy -force $proj_dll $path_dll}]} {
		puts "oops, can't copy  $proj_dll $path_dll"
		exit
	}

	set path_pkg [file join $tcllib $proj_dir pkgIndex.tcl] 
	puts "copy  pkgIndex.tcl $path_pkg"
	if {[catch {file copy -force pkgIndex.tcl $path_pkg}]} {
		puts "oops, can't copy  pkgIndex.tcl $path_pkg"
		exit
	}

    puts ""
    puts "installation complete"
  }
  default {puts "no action taken, exiting $package install"}
}

  update idletasks
  after 30000
#exit
