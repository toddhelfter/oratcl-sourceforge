# common definitions for all examples

# cgi_debug -on

set NIST_HOST   http://www.nist.gov
set MSID_HOST   http://www.nist.gov
set EXPECT_HOST http://expect.nist.gov
set MSID_STAFF  $MSID_HOST/msidstaff
set CGITCL      $EXPECT_HOST/cgi.tcl

# prevent everyone in the world from sending specious mail to me!!
# The NIST web server (pitch) isn't reporting it's domain name, sigh.
if {([exec domainname] == "cme.nist.gov") || ([exec hostname] == "pitch")} {
    cgi_admin_mail_addr libes@nist.gov
}

set TOP target=_top
cgi_link NIST     "NIST"                        $NIST_HOST $TOP
cgi_link Don      "Don Libes"                   $MSID_STAFF/libes.don.html $TOP
cgi_link admin    "your system administrator"   mailto:[cgi_admin_mail_addr]
cgi_link CGITCL   "cgi.tcl homepage"            $CGITCL $TOP
cgi_link examples "list of examples"            [cgi_cgi examples]
cgi_link Expect   "Expect"                      $EXPECT_HOST $TOP
cgi_link Oratcl   "Oratcl"                      http://www.nyx.net/~tpoindex/tcl.html#Oratcl $TOP

# Allow for both my development and production environment.  And people
# who copy this to their own server and fail to change cgi_root will get
# my production environment!
if {[exec /bin/domainname] == "cme.nist.gov"} {
    cgi_root "http://www-i.cme.nist.gov/cgi-bin/cgi-tcl-examples"
} else {
    cgi_root "http://pitch.nist.gov/cgi-bin/cgi.tcl"
}

proc scriptlink {} {
    if {0==[catch {cgi_import framed}]} {
        set target "target=script"
    } else {
        set target ""
    }

    cgi_url "the Tcl script" [cgi_cgi display scriptname=[info script]] $target
}

proc app_body_start {} {
    h2 [cgi_title]
    puts "See [scriptlink] that created this page."
    hr
}

proc app_body_end {} {
    hr; puts "Report problems with this script to [link admin]."
    br; puts "CGI script author: [link Don], [link NIST]"
    br; puts "Go back to [link CGITCL] or [link examples]."
}

cgi_body_args bgcolor=#00b0b0 text=#ffffff

