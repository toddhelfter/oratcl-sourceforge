#!/export/home/libes/bin/tclsh

# This is a CGI script that gets the date from Oracle using Oratcl.
# I wish we had a public account on our Oracle server so that I could
# allow anyone to run this, but alas we don't.  So you'll have to trust
# me that it does something. - Don

package require cgi
package require Oratcl

cgi_eval {
    source example.tcl

    cgi_title "Oracle Example"
    cgi_input

    cgi_body {
        set env(ORACLE_SID) fork
        set env(ORACLE_HOME) /u01/oracle/product/7322

        set logon [oralogon [import user]  [import password]]
        set cursor oraopen $logon

        orasql $cursor "select TO_CHAR(SysDate,'Dy Mon DD HH24:MI:SS YYYY') from dual"
        cgi_p "Oracle's date is [orafetch $cursor]"

        oraclose $cursor
        oralogoff $logon
    }
}

