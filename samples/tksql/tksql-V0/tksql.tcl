#!/usr/contrib/bin/X11/tkora 
#
####################################################################
#    ORA.tcl  : Browser base ORACLE
####################################################################
#  From : Regis d'Aubarede , at Paris under raining in August !...
#
#  UNDER CONSTRUCT !
#  Commit/Rollback : not implemented 
#  Update          : bugged
#  Select(s)       : Ok    
#
#  The authors hereby grant permission to use, copy, modify, distribute,
#  and license this software and its documentation for any purpose, provided
#  that existing copyright notices are retained in all copies and that this
#  notice is included verbatim in any distributions. No written agreement,
#  license, or royalty fee is required for any of the authorized uses.
#  Modifications to this software may NOT be copyrighted by their authors
#  and need not follow the licensing terms described here, provided that
#  the new terms are clearly indicated on the first page of each file where
#  they apply.
#  
#  IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#  FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#  ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY 
#  DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#  
#  THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#  IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#  NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#  MODIFICATIONS.
#  

package require Oratcl

set tk_strictMotif 1

proc echo { args }  { puts $args }
proc tr { args }  { puts "TR>$args" ; flush stdout ; return [uplevel 1 $args]  }

proc exec_sqlplus {base pass serv } {
  global g_oralog g_ora env oramsg

  if { $serv != "" } then {
    set env(ORACLE_SID) $serv
    set serv "@$serv"
  }
  echo oralogon $base/${pass}$serv
  if {[catch {set g_oralog [oralogon $base/${pass}$serv]} err] } then {
    tk_dialog .err "Echec Login Oracle" "logon $base/*****$serv\n\n$err \n$oramsg(errortxt) " warning 0 Exit
    exit
  } 
  
  set g_ora    [oraopen $g_oralog]
  if {[file exist ~/.init_tksql_$base]} then {
    charge_descripteur ~/.init_tksql_$base
  } else {
    tk_dialog .err "Associations" "file $env($HOME)/.init_tksql_$base don't existe, you have no association" warning 0 Ok
  }
}

############### WSQL : envoi ordre ##############
proc wsql { arg } {
  global g_ora oramsg
  .text insert end $arg\n
  .text yview end
  if {[catch {orasql $g_ora  $arg} err] } then {
    tk_dialog .err "Erreur SQL" "$arg \n $err \n $oramsg(errortxt)" warning 0 Ok
  }
    
}


########################################################################
#     Utilitaire extraction table
########################################################################
proc exec_req { SQL table callb_fetch callb_fin } {
 global g_ora oramsg nb_execora nb_line

 incr nb_execora
 if {$nb_execora > 1} then {set nb_execora 0 ; error " -------RECURSIF SUR SQL-----" ; return }

 if {$table == "nill" } then {regexp {from[ \t]+([A-Za-z_0-9]+)} $SQL x table}
 wsql $SQL
 set nb_line 0
 set cursor [orafetch $g_ora]
 while {$oramsg(rc)==0} {
    incr nb_line
    if {[eval $callb_fetch $table \"$cursor\"] == 0 } then {break}
    set cursor [orafetch $g_ora]
 } 
 uplevel #0 "$callb_fin"
 incr nb_execora -1
}



proc fetch_entete { table cb } {
 global rsql lch_table nb_champs
 upvar #0 dscr_table  dscr_$table

 waitsql "*-------*" "fetch2 $table $cb"

 set i 0
 foreach item $rsql {
   lappend lch_table($table)  $item
   set dscr_table($i) $item
   incr i
 } 
 set nb_champs($table) $i
}

proc fetch2 { table cb } {  waitsql "" "fetch_ligne $table $cb" }

proc fetch_ligne { table cb_fetch} {
 global nb_ligne g_callb_fin_select rsql
 upvar #0 ligne_table  ligne_$table

 #echo "LIGNE = $rsql len=[string length $rsql]"
 
 if {[string length $rsql] < 2} then {
   waitsql - "" 
   uplevel #0 $g_callb_fin_select
   return
 }

 set i 0
 set line ""
 foreach val $rsql {  
  lappend ligne $val 
  incr i
 }
 incr nb_ligne($table) 
 waitsql "" "fetch_ligne $table $cb_fetch" 

 if {$i > 0 } then {eval $cb_fetch $table \"$ligne\"}
}


########################################################################
#     Applicatif
########################################################################
proc deb_connection { } {
  appli 
}

proc appli { } {
 global no_table nb_dico

 incr nb_dico
 set title .dico$nb_dico
 catch {destroy $title}

 toplevel $title
 wm title $title "Dictionnaire de la base"
 frame $title.top
   button $title.top.ex -text "   Sortie   " -command "destroy $title"  -bg gold 
   button $title.top.rb -text "   Rollback   " -command "destroy $title"  -bg orange
   button $title.top.co  -text "  Commit   " -command "destroy $title"  -bg green
   pack  $title.top.ex  $title.top.rb  $title.top.co -side left -anchor w
 frame $title.base
 frame $title.cmd -relief sunken -bd 2
 frame $title.bot
 frame $title.text
   text      $title.text.t -font 6x13 -width 120 -height 10 -wrap none \
      -yscroll  "$title.text.y set" \
      -xscroll  "$title.text.x set" 
   button  $title.text.b -text raz -command "$title.text.t delete 0.0 end" -font 6x13 -padx 0 -pady 0
   scrollbar $title.text.y -command "$title.text.t yview"
   scrollbar $title.text.x -orient hori -command "$title.text.t xview" 
   grid $title.text.t -row 0 -column 0 -sticky nsew
   grid $title.text.y -row 0 -column 1 -sticky ns
   grid $title.text.x -row 1 -column 0 -sticky ew
   grid $title.text.b -row 1 -column 1
 frame $title.lien
 

 grid $title.top  -row 0 -column 0 -columnspan 2 -sticky w
 grid $title.base -row 1 -column 0 -rowspan 3 -sticky n
 grid $title.cmd  -row 1 -column 1 -sticky wn
 grid $title.text -row 2 -column 1 -sticky wn
 grid $title.bot  -row 0 -column 0 -columnspan 2
 grid $title.lien -row 3 -column 1

 set no_table 0
 dico_init $title
 return $title
}
proc dico_init { title } {
 global ex_file g_title fin g_base

 listbox $title.base.f1 -relief raised -borderwidth 2 -yscrollcommand "$title.base.scroll set" \
   -height 30
 pack $title.base.f1 -side left -expand 1 -fill y
 scrollbar $title.base.scroll -command "$title.base.f1 yview"
 pack $title.base.scroll -side right -fill y -expand 1

 #bind $title.base.f1 <ButtonRelease-1>  "source /home/praxitel/debug/simu/tksql.tcl ; select_table $title \[selection get\] nil"
 bind $title.base.f1 <ButtonRelease-1>  "select_table $title \[selection get\] nil"

  set g_title $title
  set ex_file 0
  if {[file exists ~/.inisql_$g_base]} then {
   set ex_file 1
   source ~/.inisql_$g_base
  } else {
   global fin
   set fin 0

   set fin 0
   exec_req  "select * from user_objects where OBJECT_TYPE='TABLE'" nil \
      dico_init_fetch_user_objects {set fin 1}
   tkwait variable fin
  }
}

proc dico_init_fetch_user_objects {table lchamps } {
  global ligne_user_objects no_table ex_file g_title g_base
  
  if { $ex_file==0} then {
    exec /bin/echo "dico_init_fetch_user_objects $table \"$lchamps\"" >> ~/.inisql_$g_base
  }

  set table [lindex $lchamps 0]
  if  {[lindex $lchamps 2]== "TABLE" } then {
   $g_title.base.f1 insert end $table 
  }
  return 1
}



################ SELECT_TABLE : Creation vue d'une table #######################
proc select_table {title table requette} {
 global no_line champs lchamps total_len g_table

 set table [lower $table]
 set g_table($table) $title
 catch {destroy $title.cmd.top }
 catch {destroy $title.cmd.fr }
 foreach w [winfo children $title.lien] {destroy $w}
 frame $title.cmd.top -relief sunken -bd 4
 frame $title.cmd.fr
 pack $title.cmd.top $title.cmd.fr -fill x -expand true -side top
 frame $title.cmd.fr.left
 frame $title.cmd.fr.right
 pack $title.cmd.fr.left $title.cmd.fr.right -side left -expand true -fill both -padx 5


 set i 0
 foreach b "{dep1 << first} {dep2 < pred}  {dep3 > next} {dep4 >> last}" {
  scan $b {%s %s %s}   b txt cde
  button $title.cmd.top.$b -text $txt -command "navig $cde $title $table"
  grid $title.cmd.top.$b -column $i -row 0 -sticky ew
  incr i
 }
 label $title.cmd.top.lab -text "   $table     " -relief groove -bd 3            
 grid $title.cmd.top.lab -column 6 -row 0  -sticky w

 
 button $title.cmd.top.sel  -text Select -command "sel_select $title $table nil" -bg blue  
 grid $title.cmd.top.sel -column 7 -row 0 -sticky ew
 button $title.cmd.top.upd  -text Update -command "sel_update $title $table" -bg green3
 grid $title.cmd.top.upd -column 8 -row 0 -sticky ew
 button $title.cmd.top.del  -text Delete -command "sel_delete $title $table" -bg orange
 grid $title.cmd.top.del -column 9 -row 0 -sticky ew
 button $title.cmd.top.ins  -text Insert -command "sel_insert $title $table" -bg gray60
 grid $title.cmd.top.ins -column 10 -row 0 -sticky ew
 checkbutton  $title.cmd.top.abo -text "Abort select" -variable g_abort
 grid $title.cmd.top.abo -column 11 -row 0 -sticky ew   

 set no_line 0
 global g_bute_repet
 set g_bute_repet 4000
 
 foreach x [array name champs] {
  if {[string match $title.* $x]} then {unset champs($x) }
 }
 set lchamps($table) ""
 set total_len($table) 0

 exec_req \
   "select column_name,data_type,data_length,data_precision,default_length \
      from user_tab_columns where table_name = '[string toupper $table]'"  \
    $table               \
    "fetch_struc $title" \
    "$title.text.t configure -width 150"
 crea_touches $title $table $requette
}

proc crea_touches {title table requette} {
  global champs
  
  crea_touches_lien $title lien $table
  echo crea_touches $title $table $requette
  if { $requette != "nil" } then {
   if {[regexp {(ORDER[  \t]*BY)} [string toupper $requette]] == 0 } then {
     lappend $requette " ORDER BY [lindex $champs($table.0) 0]"
   } 
   sel_select $title $table  "select * from $table $requette" 
  }
}

proc fetch_struc {title table lch } {
  global no_line champs select update value lchamps total_len clevaleur


  crea_descr_table $table $lch
  set name [lindex $champs($table.$no_line) 0]
  set type [lindex $champs($table.$no_line) 1]
  set len  [lindex $champs($table.$no_line) 2]

  set no_line1 [expr $no_line%20]
  set col      [expr 10*($no_line/20)]
  
  button $title.cmd.fr.left.lab$no_line -text [string toupper [lindex $champs($table.$no_line) 0]] -relief ridge -bd 2 -command \
    "mess $title \"Champs $name , type  $type , value \$value($table.$no_line)\" "
  grid $title.cmd.fr.left.lab$no_line -column [expr $col+2] -row $no_line1 -sticky e

  if {$len > 20} then {set len 20} ;
  entry       $title.cmd.fr.left.en$no_line -textvariable value($table.$no_line) -width $len -relief sunken -bd 2
  checkbutton $title.cmd.fr.left.select1$no_line -variable select($table.$no_line) -text "=" -onvalue "="
  checkbutton $title.cmd.fr.left.select2$no_line -variable select($table.$no_line) -text ">" -onvalue ">"
  checkbutton $title.cmd.fr.left.select3$no_line -variable select($table.$no_line) -text "<" -onvalue "<"
  checkbutton $title.cmd.fr.left.update$no_line -variable update($table.$no_line) -bg green3
  grid $title.cmd.fr.left.select1$no_line -column [expr $col+3] -row $no_line1 -sticky e
  grid $title.cmd.fr.left.select2$no_line -column [expr $col+4] -row $no_line1 -sticky e
  grid $title.cmd.fr.left.select3$no_line -column [expr $col+5] -row $no_line1 -sticky e
  grid $title.cmd.fr.left.en$no_line      -column [expr $col+6] -row $no_line1 -sticky e
  grid $title.cmd.fr.left.update$no_line  -column [expr $col+7] -row $no_line1 -sticky e
  incr no_line 
  return 1
}

###########################################################################
#   UTILITAIRS POUR REPONSES A ACTIONS SUR MASQUES
###########################################################################
proc valeur { no } {
 global champs value

 set type [lindex $champs($no) 1]
 if {([string match  *char* [string tolower $type]] || $type=="DATE")} then {
   set xvalue  "'$value($no)'"
 } else {
   set xvalue $value($no)
 }
 return $xvalue
}

proc make_where_clause {title table } {
  global lchamps champs select update value

  set a ""
  set str ""
  foreach no $lchamps($table) {
    if {$select($no) != 0} then {
      set str "$str $a [lindex $champs($no) 0] $select($no) [valeur $no]"
      set a   "and"
    }
  }
  if {$a == "and" } then { return "where $str" }
  return ""
}

proc make_entete { title table} {
 global lchamps champs separa entete listlen

 set sep ""
 set sep1 ""  
 set entete " "
 set separa "-"
 set delta 0
 foreach no  $lchamps($table) {
    set len  [lindex $champs($no) 2]
    set name [lindex $champs($no) 0]
    set lname [string length $name]
    incr len  2
    if { $lname > $len } then {
      set len $lname
    }
    set entete "${entete}$sep[format %${len}s $name]"
    set separa "${separa}$sep1[string range ------------------------------------------------------------------------ 1 $len ]"
    incr len -2
    set listlen($no) $len
    set sep "|"
    set sep1 "+"
 }
 set entete "$entete|"
 set separa "$separa|"
}

proc update_liste_select {title table line } {
 global value no_line champs separa entete  g_abort listlen

 set no 0
 set mess ""
 set sep ""
 foreach val $line {
   if {$no_line < 1 } then {
     set value($table.$no) $val 
   }
   set mess "$mess $sep [format %$listlen($table.$no)s $val]"
   incr no
   set sep "|"
 }
 if {$no_line == 0} then {
  $title.text.t insert end $entete\n
  $title.text.t insert end $separa\n
 }
 if { $no_line >= 0} then {
   mess $title $mess
   $title.text.t yview end
 }
 incr no_line
 return [expr ($g_abort==1)]
}

proc fin_aff_select { title } {
 global separa entete no_line nb_line

 if {$no_line > 20 } then {
   $title.text.t insert end $separa\n 
   $title.text.t insert end $entete\n 
   $title.text.t insert end $separa\n 
 }
 if { $nb_line > 7 } then {
   $title.text.t insert end "Nombre d'occurences : $nb_line\n"
 }
 $title.text.t yview end
}

proc mess {title text} {
 $title.text.t insert end $text\n
 $title.text.t yview end
 update
}

proc execute { requete } {
 global q

 set q $requete
 set rep [tk_dialog .sql "Valider la modification" "$q                                  " warning  0 NOk Ok]
 if { $rep == 1 } then {
  wsql $q
 }
}


proc update_navig { title table line} {
 global no_line
 set no_line -1
 update_liste_select $title $table $line
 return 0
}



############ CREA_DESCR_TABLE : memo structure d'une table ############
#
# Une structure de table est decrite par des tableaux indexe sur :
# <non_fenetre>.<no_champ> :
#
#    champs(cle) "libelle type longueur"
#    select(cle) 1/0                      : indique si champs a selection si select
#    update(cle) "                        :  "       "    "        "      "  update
#    value(cle)  valeur               : valeur du champs dans l'occurence courante
#    clevaleur(<table>.<nom_champs>) <title>.<no_champ>: donne la cle par rappor a un nom de champs
#

proc crea_descr_table {table lch } {
  global no_line champs select update value lchamps total_len clevaleur

  set lch [lower $lch]
  set table [lower $table]
  set name [lindex $lch 0]
  set type [lindex $lch 1] 
  set len  [lindex $lch 2] 
  set prec [lindex $lch 3] 
  set dlen [lindex $lch 4] 
  if {[string match *CHAR* $type]} then {set type ${type}($len) ;  } 
  if {"NUMBER" == $type}           then {set type ${type}($prec); set len $prec}
  if {"DATE" == $type}             then {set len 20}

  if {[info exists total_len($table)] == 0 } then {set total_len($table) 0}
  if {[info exists lchamps($table)] == 0 } then {set lchamps($table) ""}

  incr total_len($table) [expr $len+3] ; if {($total_len($table) > 170)} then { set  total_len($table) 170 }

  set     champs($table.$no_line) "$name $type ${len}"
  set     select($table.$no_line) 0
  set     update($table.$no_line) 0
  set     value($table.$no_line) ""
  set     clevaleur($table.[lower $name]) $table.$no_line
  lappend lchamps($table) $table.$no_line
}


##########################################################################
######                    Action sur masque                    ###########
##########################################################################

############ NAVIGATION << < > >> #################
proc navig  {type title table} {
 global champs value 

 set clef [lindex $champs($table.0) 0]
 switch $type {
   first {set where "order by $clef"}
   last  {set where "order by $clef desc"}
   next  {set where "where $clef > [valeur $table.0] order by $clef" }
   pred  {set where "where $clef < [valeur $table.0] order by $clef desc" }
 }
 exec_req "select * from $table $where" $table "update_navig $title" "nop"
}

proc nop { } { ; }

proc sel_select {title table q} {
 global no_line separa entete g_abort champs

 if { $q == "nil" } then {
  set q "select * from $table [make_where_clause $title $table] order by [lindex $champs($table.0) 0]"  
 }
 set no_line 0
 mess $title "--------------------------------------------------------------------"
 mess $title "*      $q "
 mess $title "--------------------------------------------------------------------"
 make_entete $title $table
 set g_abort 1
 exec_req $q $table "update_liste_select  $title" "fin_aff_select $title"
 
}

proc sel_insert {title  table } {
 global champs value
 
 set sep " "
 set str ""
 foreach no [array names champs] { if {[string match $title* $no]} then {
   set str "$str $sep $value($no)"
   set sep ","
 }}
 set q "insert into $table values ( $str ) "
 execute $q
}

proc sel_update {title table } {
 global champs update value

 set sep " "
 set str ""
 foreach no [array names champs] {if {[string match $title.* $no]} then {
  if { $update($no) == 1 } then {
    set name [lindex $champs($no) 0]
    set str "$str $sep $name=[valeur $no]"
    set sep ","
  }
 }}
 set q "update $table set $str [make_where_clause $title $table] "
 execute $q
}

proc sel_delete {title table } {

 set q "delete  $table [make_where_clause $title $table] ;"
 execute $q
}

########################################################################
######### GESTION DES CONTRAINTES                             ##########
########################################################################
proc lower { p } {return [string tolower $p]}

############## Utilitaire pour languqge de description #########

proc fils { p r d req} {
  global blien g_lsite g_llien
  set p [lower $p]
  set d [lower $d]
  set req [lower $req]
  lappend blien [list $p $r $d $req ]
}


############# CHARGE_DESCRIPTEUR : Chargement des descripteurs de liens sur la base ###
proc charge_descripteur { file } {
 global g_lien_pere blien g_lsite g_llien g_lpere

 #----------- Raz du context ------------

 set   blien ""
 catch {unset g_lien_pere}
 catch {unset g_lsite}
 catch {unset g_llien}
 catch {unset g_lpere}

 #------------- Chargement ----------------

 source $file
 
 #------------ Creation base de donnee ----------

 foreach lien $blien {
   set pere [lindex $lien 0]
   set asso [lindex $lien 1]
   set fils [lindex $lien 2]
   set req  [lindex $lien 3]
   lappend g_lien_pere($pere) [list $asso $fils $req]
   lappend g_lsite($pere) $fils 
   lappend    g_llien($pere.$fils) \"$asso\"
   lappend    g_lpere($fils) $pere
 } 
}

########## CREA_TOUCHES_LIEN : creation des boutons associés a une table ########
proc crea_touches_lien { title place table } {
 global g_lien_pere
 
 set table [string  tolower $table]
 if {[info exist g_lien_pere($table)] == 0 } then { return }
 
 set i 2
 set fr $title.$place
 foreach lien $g_lien_pere($table) {
   button $fr.bb$i  -text [lindex $lien 0] -command [list acces_lien $table [lindex $lien 1] [lindex $lien 2]]  
   grid $fr.bb$i -column [expr $i%5] -row [expr $i/5]
   incr i
 }

 #------------ touches acces graphique ------------

 button $fr.bb0 -text "Schema des entite"     -command "schema_entite    $table" -bg gold
 button $fr.bb1 -text "Schema des occurences" -command "schema_occurence $table" -bg blue3 -fg gold
 grid $fr.bb0 -column 0 -row 0 -sticky ew
 grid $fr.bb1 -column 1 -row 0 -sticky ew
}



proc complete_liaison {table  requette} {
  global  champs clevaleur value
  while {[regexp  {:([A-Za-z0-9_]+)} $requette x cle]} {
     if { [info exists clevaleur($table.[string tolower $cle]) ]==0 } then {
       tk_dialog .errreq "Erreur lien" "Le champs $table.$cle est inconnu (erreur description liens)" warning 0 Ok
       return
     }
     set no $clevaleur($table.[string tolower $cle])
     if { $value($no) == "" } then {
       tk_dialog .errreq "Erreur lien" "Le champs $table.$cle n'est pas saisie" warning 0 Ok
       return
     }
     regsub {:([A-Za-z0-9_]+)} $requette $value($no) requette
  }
  return $requette
}

proc complete_liaison_short {table  requette} {
  global  champs clevaleur value g_line g_dscr
  while {[regexp  {:([A-Za-z0-9_]+)} $requette x cle]} {
     set v  [lsearch $g_dscr($table) $cle]
     if { $v==-1 } then {
       tk_dialog .errreq "Erreur lien" "Le champs $table.$cle est inconnu (erreur description liens)" warning 0 Ok
       return
     }
     set v [lindex $g_line($table) $v]
     regsub {:([A-Za-z0-9_]+)} $requette $v requette
  }
  return $requette
}

################## ACCES_LIEN : creation d'une vue d'une table fille ######
proc acces_lien {pere table requette} {
  global lchamps champs clevaleur value

  #------------ Construction de la requette -------------
  # remplacement des :xxx par la valeure de pere.xxx  

  set requette [complete_liaison $pere $requette]

  echo $requette

  #-------- Creation fenetre fille ----------------------

  set title [ appli ]
  select_table $title $table "where $requette" 
}




#########################################################################################
#                 GESTION DES GRAPHES
#########################################################################################

##################### Graphe par entite #########################################

proc schema_entite    { table } {
  global cv g_sitye g_lien g_lsite g_llien g_depl
  crea_canvas 400 400 "Entite a partir de $table"

  crea_graphe_entite 5 $table 
  set g_depl 3000
  ord_syno 4
  after 100 cmd_ord_syno ord_syno 1
}

proc cmd_ord_syno { args } {
 global g_depl
 
 eval $args
 if { $g_depl > 1000} then {after 10  cmd_ord_syno $args}
}

##################### GRAPHE PAR OCCURENCE #########################################

proc schema_occurence { table } { 
  global cv champs value

  crea_canvas 400 450 "Occurences lie a $table.[lindex $champs($table.0) 0] = $value($table.0)"
  set cv .cv.fr.cv
  wm geometry .cv +5+5  
  crea_arbre_occur0  $table
}


proc crea_arbre_occur0 { table } {
  global y_cur value g_ora champs g_line g_dscr cv

  set y_cur 10
  orasql  $g_ora  "select * from $table where [lindex $champs($table.0) 0]=[valeur $table.0]"
  set g_line($table) [orafetch $g_ora]
  set g_dscr($table)  [lower [oracols $g_ora]]
  crea_arbre_occur 0 $table $value($table.0) 10 10

  set height [expr [lindex [$cv bbox all] 3]+5]
  $cv configure -scrollregion "0 0 400 $height"  
}

proc crea_arbre_occur { level table item xp yp} {
 global g_oralog g_lsite g_lien_pere g_dscr g_line y_cur

 dess_occur $level $table / $item black $xp $yp xf yf
 if {$level > 5} then {return}
 incr level
 set level1 [expr $level+1]
 if {[info exist g_lsite($table)]} then {
  set link [oraopen $g_oralog]
  set nb_line0 0
  foreach ass $g_lien_pere($table) {
    set nb_line 0
    set asso [lindex $ass 0]
    set dst [lindex $ass 1]
    set req [lindex $ass 2]
    orasql  $link  "select * from $dst where [complete_liaison_short $table $req]"
    oracols $link
    set g_dscr($dst) [lower [oracols $link]]
    oracancel $link
    orasql  $link  "select * from $dst where [complete_liaison_short $table $req] order by [lindex $g_dscr($dst) 0]"
    orafetch $link {
      if {( $nb_line == 0 )} then {
        dess_occur $level $table "" ${asso} blue3 $xf $yf xxf yyf
      }
      set g_line($dst) @0
      crea_arbre_occur $level1 $dst [lindex $g_line($dst) 0] $xxf $yyf
      incr nb_line
      if {$nb_line > 20} then {
        dess_occur $level1 .... / .... gold $xxf $yyf x y 
        break
      }
    }
    incr y_cur 4
  }
  oraclose $link
 }
}

proc dess_occur { level table sep item fg xp yp xxf yyf} {
  global cv y_cur
  upvar  $xxf XF
  upvar  $yyf YF

  set table1 $table
  if { $sep == "" } then {set table1 ""}
  incr y_cur 16
  set YF $y_cur 
  set XF [expr ($level+2)*12]
  set gitem [$cv create text $XF $YF -text ${table1}${sep}$item -anchor w -fill $fg]
  $cv create line $xp $yp $xp $YF $XF $YF
  incr XF 6
  incr YF 6

  $cv bind $gitem <1> [list aff_occur $table $item]
}

proc aff_occur { table cle} {
  global value select g_lien_pere
  if {[llength $cle] > 1 } then {
    foreach asso $g_lien_pere($table) {if {[lindex $asso 0] == $cle} then {
      acces_lien $table [lindex $asso 1] [lindex $asso 2]
    }}
  } else {  
    set title [ appli ]
    select_table $title $table nil
    set value($table.0) $cle
    set select($table.0) =
    sel_select $title $table nil
  }
}

###################### GRAPH ENTITE : CREATION SITE / LIEN ##########################

proc crea_graphe_entite { level table } {
 global g_lsite g_llien g_site g_lien g_lpere

 if { $level == 0 } then {return}
 incr level -1
 
 if {[info exist g_site($table)] == 0 } then {
   dess_entite $table
 }
 if {[info exist g_lsite($table)]} then {foreach dst $g_lsite($table) {
   crea_graphe_entite $level $dst
   if {$level} then {dess_lien_entite $table $dst}
 }}
 if {[info exist g_lpere($table)]} then {
   foreach dst $g_lpere($table) {
     crea_graphe_entite $level $dst
   }
 }
}

proc dess_entite { table } {
  crea_site $table
}


proc dess_lien_entite { src dst } {
 global g_nblist g_llien
 
 set txt ""
 foreach asso $g_llien($src.$dst) {
   set txt "$txt\n$asso"
 }
 set g_nblist($src,$dst) ""
 crea_lien $src $dst $src,$dst $src,$dst
}

########### Selection sur entite #########
proc pannel_site { table } {
 global g_table
 echo pannel_site $table
 set e 0
 if {[info exists g_table($table)]} then {if {[winfo exists $g_table($table)]} then {
   set e 1
   set title $g_table($table)
   wm withdraw $title
   wm deiconify $title
   return
 }}

 if { $e == 0 } then {
   set title [appli]
  select_table $title $table nil 
 }
}

################################### SYNOPTIQUE ##########################################
set g_nb_site 0
catch {destroy .cv}
set auto 1



proc crea_canvas { w h titre } {
 global cv g_site g_lien

 catch {unset g_site}
 catch {unset g_lien}
 if {[winfo exist .cv]} then {
   .cv.fr.cv delete all
   return
 }
 
 toplevel .cv
 wm title .cv "$titre"
 frame .cv.fr -relief ridge -bd 3  
 pack .cv.fr -expand 1 -fill both -side top 
 if { $h <= 410 } then {
   canvas .cv.fr.cv -width $w -height $h
   pack .cv.fr.cv
 } else {
  canvas .cv.fr.cv    -scrollregion "0 0 $w [expr $h*4]" -width $w -height  $h -yscrollcommand ".cv.fr.sy set"
  scrollbar .cv.fr.sy -command ".cv.fr.cv yview"
  pack .cv.fr.sy -side right -fill y -expand true
  pack .cv.fr.cv -side left -fill both -expand true
 }

 frame .cv.bot -relief sunken -bd 2
 button .cv.bot.b1 -text Sortie -command {set g_depl 0 ; after 1000 destroy .cv} -bg gold3
 button .cv.bot.b2 -text Start  -command {set g_depl 10000 ;after 500 cmd_ord_syno ord_syno 1 } -bg gold1
 button .cv.bot.b3 -text Stop   -command {set g_depl 0 } -bg gold2
 pack .cv.bot -expand 1 -fill x -side top 
 pack .cv.bot.b3  .cv.bot.b2 .cv.bot.b1 -side left -expand true
 set cv .cv.fr.cv

 bind .cv.fr.cv  <3> { set x %x ; set y %y
   if {[info exists g_select_site]} then {
      scan [.cv.fr.cv coord zz_$g_select_site]  "%%f %%f" x0 y0
      .cv.fr.cv move y_$g_select_site [expr $x-$x0] [expr $y-$y0]
      set g_site($g_select_site) "$x $y" 
   }
 }
 

}



set g_depl 10
proc ord_syno { rep } {
 global g_site g_lien g_llien auto g_depl g_opt g_dscr g_host

 if  {$auto==0} then {return}
 if  {$g_depl <= 100 } then {set g_opt "" ; return}
 
 set lsite [array names g_site]
 set moy 10000
 set g_depl1 0
 if {$g_depl > 20000 } { incr rep 7}
 # catch 
 set lateral 0
 for {set i 0} {($i<$rep)&&($g_depl > 100)} {incr i} {    
  set nb_depl 1
  foreach ori $lsite {
   set dx 0
   set dy 0   
   set lex 0 
   set ley 0 
   set lrx 0
   set lry 0
   set nblien 2
   scan $g_site($ori) "%f %f" x0 y0
   foreach dst $lsite {
    if {($ori != $dst)} then {
     scan $g_site($dst) "%f %f" x1 y1 
     set dist [expr round(($x0-$x1)*($x0-$x1)+($y0-$y1)*($y0-$y1))]
     incr dist
     #echo Distance $ori/$dst :: $dist / $moy
     set lie [expr \
      ([info exist g_llien($ori,$dst)]||[info exist g_llien($dst,$ori)])]

     if       {$dist < 700} then { 
       set dx   [expr $dx+((($dist+1023)%3)-1)*100] 
       set dy   [expr $dy+10] 
     }
     if { $lie } then {
       incr nblien
       depl     [expr -$dist/100]  dx dy lex ley $x0 $y0 $x1 $y1
     }
     if {($dist < $moy)&&($dist >= 100)}      then { 
       depl     [expr ($moy-$dist)/6] dx dy lrx lry $x0 $y0 $x1 $y1
     }
   }}
   set dexy [expr ($lex*$lex+$ley*$ley)/($nblien*$nblien)]
   set drxy [expr ($lrx*$lrx+$lry*$lry)/($nblien*$nblien)]
   set g_dscr($ori) \
       [format "%12s %7f.3/%7f.3 idx2=%7.1f idr2=%7.1f Depl=%8.2f" $ori $dx $dy $dexy $drxy $g_depl] 
   if {$dx != 0 || $dy != 0} then {
      set dx [expr round($dx)]
      set dy [expr round($dy)]
      .cv.fr.cv move y_$ori $dx $dy
      set site_modif($ori) 1
      set g_site($ori) [.cv.fr.cv coord zz_$ori]
      incr g_depl1 [expr ($dx*$dx)+($dy*$dy)]
   }
   if {( $lateral==  0)&&($g_depl < 1500)} then {
     if {($dexy > 12000)&&($drxy > 12000)&&(($dx*$dx+$dy*$dy) < 10)} then {
      echo Lateral ------ $ori $g_host($ori)  $dexy $drxy $dx/$dy $g_depl
      set dx [expr round(0-$ley/6)]     
      set dy [expr round($lex/6)]     
      .cv.fr.cv move y_$ori $dx $dy
      set site_modif($ori) 1
      set g_site($ori) [.cv.fr.cv coord zz_$ori]
      incr g_depl1 [expr ($dx*$dx)+($dy*$dy)]
      set lateral 1
   }}
   #mupdate 1
  }
  set g_depl [expr (($g_depl1/$nb_depl)+10*$g_depl)/11]
  #echo Depl==$g_depl
 }
 
 #-------------- Redessinde tous les liens ---------------

 set lis ""
 foreach nol [array names g_lien] {lappend lis $g_lien($nol) ; }
 set g_nolien 0
 foreach sd $lis { incr g_nolien ; eval crea_lien $sd $g_nolien}
 .cv.fr.cv lower lien

 #----------- Recadrage dessin dans la fenetre -----------
 
 scan [.cv.fr.cv bbox all] "%f %f %f %f" x0 y0 x1 y1
 set gx  [expr ($x0+$x1)/2]
 set gy  [expr ($y0+$y1)/2]
 set xx0 [expr (400)/2]
 set yy0 [expr (400)/2]

 .cv.fr.cv move all [expr $xx0-$gx] [expr $yy0-$gy]
 scan [.cv.fr.cv bbox all] "%f %f %f %f" x0 y0 x1 y1
 .cv.fr.cv scale all $xx0 $yy0 [expr (400-30)/($x1-$x0)] [expr (400-30)/($y1-$y0)]

 #---- Ajustement des rectangle autour des nom des sites ---
 
 foreach s $lsite { eval .cv.fr.cv coord z_$s [.cv.fr.cv bbox zz_$s] }

 if { $g_depl >= 100 } then {
  #set g_opt "ajustement automatique en cours"
 } else {
  #set g_opt ""
 }
 mupdate 0

}

proc depl { v dx dy lx ly x0 y0 x1 y1} {
 upvar $dx DX
 upvar $dy DY
 upvar $lx LX
 upvar $ly LY
 if {$DY > 30 } then {set DY $DY-30}
 if {$DY < -30} then {set DY $DY+30}
 
 set delx [expr ($v*($x0-$x1))/10000]
 set dely [expr ($v*($y0-$y1))/10000]
 set DX [expr $DX+$delx]
 set DY [expr $DY+$dely]

 set LX  [expr $LX+$delx*100]
 set LY  [expr $LY+$dely*100]
}
########## CREA_SITE : dessin d'un site (reconstriuit le syno) ########
proc crea_site { site } {
 global g_site g_nb_site g_lien g_nolien g_host g_broad auto
 
  if {( [info exist g_site($site)] == 1 )} then {return}
  set cv .cv.fr.cv
  incr g_nb_site  
  set g_site($site) 1

  #-------- Efface le synoptique --------  

  if {$auto==0} then { $cv delete all}

  #------------ Cherche nom du noeud -------
  
   
  if {([info exist g_host($site)] )} then {
    set host [lindex $g_host($site) 1]
  } else {
    set host $site
    set g_host($site) $site
  }
  
  #--------- Dessin des site en rond ------------

  set rayon 250
  set xc    325
  set yc    350
  set l     34
  set h     8

  set pas [expr 1.0*(3.14*2)/($g_nb_site)]
  set angle 0
  foreach s [lsort [array names g_site]] {

   #----------------- Comptage nb de lien sur le site -----
   set nb 0
   foreach nol [array names g_lien] {
     if {([lsearch $g_lien($nol) $s] != -1)} then {incr nb}
   }
   set rayon1 [expr (2*$rayon)/(($nb/4)+2)]
   if {($s == $site)||($auto==0)} then {
     #------------ Calcule position sur un cercle -----------
   
     set sin [expr 0.001*$angle]
     set cos $sin
     set x0 [expr round($xc+$rayon1*$cos)]
     set y0 [expr round($yc+1.2*$rayon1*$sin)]

     #---------------- Recherche du nom du host en claire (tkdump.lis)--
   
     set host $g_host($s)
     #set host $s
   
     #-------------------- Dessin text/Cadre ------------------
   
     set itemt [$cv create text $x0 $y0 -text $host \
                    -tags "site txt  l_$s y_$s zz_$s"]
     set bbox [$cv bbox $itemt]
     set itemr [eval $cv create rectangle  $bbox \
                      -width 0 -outline black -fill gold \
                      -tags \"site rect l_$s y_$s z_$s \" ]
     set g_site($s) "$x0 $y0"
     $cv bind y_$s <1> "pannel_site $s"
     $cv bind y_$s <3> "set g_select_site $s"
   }

   set angle [expr $angle+$pas]
  }

  $cv lower rect
  
  #------------- Dessin des liens connus ----------------
  
  set lis ""
  foreach nol [array names g_lien] {lappend lis $g_lien($nol) ; }
  set g_nolien 0
  foreach sd $lis { incr g_nolien ; eval crea_lien $sd $g_nolien}
  .cv.fr.cv lower lien

  mupdate 1
  global g_depl 
  incr g_depl 300
}

 
########### CREA_LIEN : dessin lien entre deux site ##############
proc crea_lien { src dst noliste g_nolien} {
  global g_site g_lien g_llien g_nblist

  set g_llien($src,$dst) 1
  .cv.fr.cv delete x_$noliste
  set g_lien($g_nolien) "$src $dst $noliste"

  scan [.cv.fr.cv coord zz_$src]  "%f %f" x0 y0 
  scan [.cv.fr.cv coord zz_$dst]  "%f %f" x1 y1 
  set item [.cv.fr.cv create line $x0 $y0 $x1 $y1 -arrow last -arrowshape "14 20 6"\
      -fill black -width 1 \
      -tags "lien l_$src l_$dst x_$noliste" ]
  .cv.fr.cv  bind $item <1> \
    "active_list .a$noliste ;.cv.fr.cv itemconfig x_$noliste -fill red"
  .cv.fr.cv create text [expr round((2*$x1+$x0)/3)] [expr round((2*$y1+$y0)/3)] \
      -text $g_nblist($src,$dst) -tags "lien l_$src l_$dst x_$noliste  t_$src,$dst" 
}

set nb_repet 0
proc mupdate { c } {
 global nb_repet
 incr nb_repet
 if {($nb_repet % 10)|| $c } then {
   update
 }
}

######################## PANNEL-LOGON ##############
proc pannel_logon { } {
  global g_base g_passwd g_serveur g_editor

  set g_base    praxitel
  set g_passwd  praxibdd
  set g_serveur ""
  set g_editor  tkedit

  set title .log
  catch "destroy $title"
  toplevel  $title
  wm title  $title "TkSql : Login Oracle"
  frame $title.top -relief sunken -bd 2
  frame $title.bot
  pack  $title.top $title.bot -expand true -fill x -side top

  button $title.bot.s -text Ok -command "destroy $title"
  pack $title.bot.s -expand true

  set title $title.top 
  label $title.n1 -text "Base name"
  label $title.p1 -text "Password"
  label $title.s1 -text "Serveur" 
  label $title.s3 -text "(alias OR <oracle name serveur> OR T:<hostname><oracle name server>)" 
  label $title.e1 -text "X editor" -pady 20

  entry $title.n2 -textvariable g_base -width 10
  entry $title.p2 -textvariable g_passwd -width 10 -bg gray60 -fg gray65
  entry $title.s2 -textvariable g_serveur -width 40
  entry $title.e2 -textvariable g_editor -width 10 

  grid $title.n1 -row 1 -column 1 -sticky w
  grid $title.p1 -row 2 -column 1 -sticky w
  grid $title.s1 -row 3 -column 1 -sticky w
  grid $title.s3 -row 4 -column 1 -columnspan 2
  grid $title.e1 -row 5 -column 1 -sticky sw

  grid $title.n2 -row 1 -column 2 -sticky w
  grid $title.p2 -row 2 -column 2 -sticky w
  grid $title.s2 -row 3 -column 2 -sticky w
  grid $title.e2 -row 5 -column 2 -sticky sw

  tkwait window .log
  
}
#########################################################################################
#                                   MAIN
#########################################################################################




if {[info exists g_wait]==0} then {
set nb_execora 0
set nb_dico 1
set gi 0
set g_wait "-"
set g_callb_wait ""
set nb_repet 0
set g_bute_repet 0

entry .q -width 80 -textvariable q
button .s  -text Exit -command "exit 0" -bg gold
#button .s1 -text Dico -command "source /home/praxitel/debug/simu/tksql.tcl ; appli" -bg gold
button .s1 -text Dico -command "appli" -bg gold
button .s2 -text "Edition Association"  -command {
   catch {exec $g_editor [glob ~/.init_tksql_$g_base]} 
   charge_descripteur  ~/.init_tksql_$g_base 
   appli
  } -bg gold

bind .q <Return> "wsql \$q"

text .text -font  lucidasans-10 -width 20 -height 10 -wrap none
pack .q -side top -expand 1 -fill x
pack  .s   -side bottom -expand 1 -fill x
pack  .s1  -side bottom -expand 1 -fill x
pack  .s2  -side bottom -expand 1 -fill x
pack .text -side top -expand 1 -fill both
update


pannel_logon
exec_sqlplus  $g_base $g_passwd $g_serveur

appli
}










