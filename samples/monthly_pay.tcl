#!/usr/local/bin/tcl
#
# monthly_pay.tcl 
#
# usage: monthly_pay.tcl [connect_string]
#  or    tcl -f monthly_pay.tcl [connect_string]
#
# sample program for Oratcl
# Tom Poindexter
#
# example of sql, pl/sql, multiple cursors
# uses Oracle demo table SCOTT.EMP
# uses id/pass from command line, or "scott/tiger" if not specified
#
# this example does not illustrate efficient sql!
# a simple report is produced of the monthly payroll for each jobclass
#

global oramsg

set find_jobs_sql { select distinct job from SCOTT.EMP }

set monthly_pay_pl {
	begin 
	  select sum(sal) into :monthly 
		 from SCOTT.EMP
		 where job like :jobclass;
	end;
}

set idpass $argv
if {[string length $idpass] == 0} {
  set idpass "scott/tiger"
}

set lda [oralogon $idpass]
set cur1 [oraopen $lda]
set cur2 [oraopen $lda]


orasql $cur1 $find_jobs_sql

set job [orafetch $cur1]

while {$oramsg(rc) == 0} {

  oraplexec $cur2 $monthly_pay_pl :monthly "" :jobclass "$job"

  set total_for_job [lindex [orafetch $cur2] 0]

  puts stdout "Total monthly salary for job class $job = \$ $total_for_job"

  set job [orafetch $cur1]

}


oraclose $cur1
oraclose $cur2

oralogoff $lda

exit

