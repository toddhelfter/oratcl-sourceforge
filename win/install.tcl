# simple installer for Sybtcl/Oratcl
# Copyright 1997 Tom Poindexter

# read in the makefile, to figure out which package and version


if {[catch {set fd [open makefile.vc]}]} {
  puts "can't find 'makefile.vc'"
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
  exit
}
if {! [regexp -nocase "${ws}${project}_VERSION${ws}=${ws}(${vn})" $mf \
							  match version] } {
  puts "can't find package version"
  exit
}
if {! [regexp "${ws}DLL_VERSION${ws}=${ws}(${dl})"      $mf match dllvers] } {
  puts "can't find package dll version"
  exit
}


# figure out tcl version, and strip out dots

set tclver [info tclversion]
regsub -all {\.} $tclver "" tclver

if {"$tclver" > "80"} {
  set tclver 80
}

# set directory for pkgIndex.tcl, set required dll, and install dll name

set proj_dir ${project}${dllvers}
set proj_dll ${project}${dllvers}${tclver}.dll
set inst_dll ${project}${dllvers}.dll

# set package name

set package "[string toupper [string range $project 0 0]][string tolower [string range $project 1 end]]"

# see if project dll file exists

if {! [file isfile $proj_dll] } {
  puts "can't find $proj_dll"
  puts "there doesn't seem to be a dll for $project version $version"
  puts "for Tcl version [info tclversion]"
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

# create package ifneeded script, location based on nameofexecutable

set pkg "\n\npackage ifneeded $package $version \"load \[list \[file join \[file dirname \[file dirname \[info nameofexecutable]]] lib $inst_dll]]\""

# tell user what we are about to to

puts ""
puts "installing $package"
puts ""
puts "steps to be performed:"
puts ""
puts "  copy  $proj_dll [file join $tcllib $inst_dll]"
if {! [file isdirectory [file join $proj_dir]] } {
  puts "  mkdir [file join $proj_dir]"
}
puts "  create or add to [file join $proj_dir pkgIndex.tcl] as:"
puts "  $pkg"
puts ""
puts -nonewline "continue (yes/no) ? "
flush stdout
gets stdin ans

# install if answer was yes,y

switch -glob -- $ans {
  y* -
  Y* {
    puts "copy  $proj_dll [file join $tcllib $inst_dll]"
    if {[catch {file copy -force $proj_dll [file join $tcllib $inst_dll]}]} {
      puts "oops, can't copy  $proj_dll [file join $tcllib $inst_dll]"
      exit
    }
    if {! [file isdirectory $proj_dir] } {
      puts "mkdir file join $proj_dir"
      if {[catch {file mkdir $proj_dir}]} {
	puts "oops, can't mkdir $proj_dir"
	exit
      }
    }
    if {[file isfile [file join $proj_dir pkgIndex.tcl]]} {
      puts "appending to  [file join $proj_dir pkgIndex.tcl]"
    } else {
      puts "creating [file join $proj_dir pkgIndex.tcl]"
    }
    if {[catch {set fd [open [file join $proj_dir pkgIndex.tcl] a]}]} {
      puts "oops, can't create or append [file join $proj_dir pkgIndex.tcl]"
      exit
    }
    puts $fd $pkg
    close $fd
    puts ""
    puts "installation complete"
  }
  default {puts "no action taken, exiting $package install"}
}

exit
