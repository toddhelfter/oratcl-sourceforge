#
# cleanup.tcl
#
# Finalize the tests.
#
# Copyright (c) 2000 by Todd M. Helfter
# All rights reserved.

if {[catch {set ora_lda [oralogon $ora_constr]}] != 0} {
    puts "can't logon to oracle server"
    exit
} else {
    if {[catch {set ora_cur [oraopen $ora_lda]}] != 0} {
        oralogoff $ora_lda
        puts "can't open cursor for handle  $ora_lda"
        exit
    }
    if {[catch {set ora_cur2 [oraopen $ora_lda]}] != 0} {
        oralogoff $ora_lda
        puts "can't open cursor for handle  $ora_lda"
        exit
    }
    if {[catch {set ora_cur3 [oraopen $ora_lda]}] != 0} {
        oralogoff $ora_lda
        puts "can't open cursor for handle  $ora_lda"
        exit
    }
}

puts "\tUsing login handle   :: $ora_lda"
puts "\tUsing cursor handle  :: $ora_cur"
puts "\tUsing cursor handle  :: $ora_cur2"
puts "\tUsing cursor handle  :: $ora_cur3"
puts {}
flush stdout

proc truncate_table {} {
    global ora_lda ora_cur
    orasql $ora_lda {truncate table oratcl___tests}
}

proc drop_table {} {
    global ora_lda ora_cur

    catch {orasql $ora_cur "drop procedure oratcl___test1"}
    catch {orasql $ora_cur "drop procedure oratcl___test2"}
    orasql $ora_cur "drop table oratcl___tests"
}

set sql {select table_name from user_tables where table_name = 'ORATCL___TESTS'}
orasql $ora_cur $sql
set table_exists 0
set column [orafetch $ora_cur]
orafetch $ora_cur {} {} column 1
puts $column

if {[string compare $column ORATCL___TESTS] == 0} {
        set table_exists 1
}

if {$table_exists} {
    puts {oratcl___tests exists,}
    puts -nonewline {  do you want to drop and re-create it (yes/no, default=no)
: }
    flush stdout
    gets stdin res
    if {[string match $res yes]} {
        drop_table
    } else {
        exit
    }
}

puts "creating test table oratcl___tests & procedure oratcl___test1"
flush stdout

proc create_table {} {
    global ora_lda ora_cur oramsg

    set sql {create table oratcl___tests (
                v_number       number(2),
                v_date         date,
                v_char         char(2),
                v_varchar2     varchar2(36))
    }

    set res [catch {orasql $ora_cur $sql} reason]

    if {$res != 0} {
        oraclose $ora_cur
        oralogoff $ora_lda
        puts "can't create table oratcl___tests"
        puts "$reason:\n$oramsg(errortxt)"
        exit
    }
if 0 {
   orasql $ora_cur {
       create or replace function oratcl___test1 (
         arg_x number, arg_y char) return date as

        nres number(10);
        dres date;


        cursor cur_tests(arg_x number, arg_y char)
                is select v_number, v_date from oratcl___tests
                        where v_number = arg_x
                        and v_char = arg_y;
       begin

           open cur_tests(arg_x, arg_y);
           fetch cur_tests into nres, dres;
           close cur_tests;
           return dres;
       end;
     }
}
}

create_table

proc insert_data {} {
        global ora_cur ora_lda

        set sql {alter session set nls_date_format = 'DD-MON-YYYY'}
        orasql $ora_cur $sql

        puts -nonewline "inserting 30 rows in oratcl___tests"; flush stdout
        for {set cnt 0} {$cnt < 30} {incr cnt} {
                set ins_sql "insert into oratcl___tests (v_number, \
                        v_date, v_char, v_varchar2) values ( $cnt, \
                        [clock format [clock seconds] -format {'%d-%b-%Y'}], \
                        '$cnt', '$cnt 1234567890')"

                orasql $ora_cur $ins_sql
                puts -nonewline "." ; flush stdout
        }
        puts "\ndone.\n" ; flush stdout
}

insert_data
