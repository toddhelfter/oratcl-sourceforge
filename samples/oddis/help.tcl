
###########################################################################
# HelpAboutOddis-Procedures                                               #
###########################################################################


####################################
# Procedure: OD_HelpAboutODDIS     #
####################################


proc OD_HelpAboutODDIS {} {
catch {destroy .tl_helpabout}
toplevel .tl_helpabout

global ODv_user
global ODv_server

set sysuser [id user]
set dbuser $ODv_user
set dbact  $ODv_server

global ODv_helptext
global ODv_selectfont
global ODv_ArHelpText

wm title    .tl_helpabout "About ODDIS ..."
wm minsize  .tl_helpabout 440 200
wm maxsize  .tl_helpabout 440 900
wm sizefrom .tl_helpabout user
wm geometry .tl_helpabout 440x300

frame .tl_helpabout.fr_help 
scrollbar .tl_helpabout.fr_help.sb_help -orient vertical -command ".tl_helpabout.fr_help.cv_help yview" 
canvas .tl_helpabout.fr_help.cv_help -width 20c -height 10c -scrollregion {0c 0c 20c 30c} -yscrollcommand ".tl_helpabout.fr_help.sb_help set"     
button .tl_helpabout.fr_help.bn_ok -text Dismiss -command {destroy .tl_helpabout}
pack   .tl_helpabout.fr_help.bn_ok -side bottom -fill x
pack   .tl_helpabout.fr_help -side top -fill both -expand 1
pack   .tl_helpabout.fr_help.sb_help -side left -fill y
pack   .tl_helpabout.fr_help.cv_help -side top -fill both -expand 1


set line "ODDIS - Version v2.1"
.tl_helpabout.fr_help.cv_help create text 2.8c 0.2c -text $line -anchor nw -font -*-courier-*-r-*-*-20-*-*-*-*-*-*-*
set line "(Oracle Data Dictionary Information System)"
.tl_helpabout.fr_help.cv_help create text 2.4c 1.0c -text $line -anchor nw
set line "Author: Regine Kasten"
.tl_helpabout.fr_help.cv_help create text 1.0c 2.0c -text $line -anchor nw -font -*-courier-*-r-*-*-14-*-*-*-*-*-*-*
set line "Authors of Version v2.0: Michael Bethke and Axel Schlueter"
.tl_helpabout.fr_help.cv_help create text 1.0c 3.0c -text $line -anchor nw 
set line "Author of Version v1.0: Rainer Gruetzner"
.tl_helpabout.fr_help.cv_help create text 1.0c 3.8c -text $line -anchor nw
set line "University of Hanover"
.tl_helpabout.fr_help.cv_help create text 1.0c 5.2c -text $line -anchor nw
set line "Institute for Informatics"
.tl_helpabout.fr_help.cv_help create text 1.0c 5.9c -text $line -anchor nw 
set line "Database and Information Systems Group"
 .tl_helpabout.fr_help.cv_help create text 1.0c 6.6c -text $line -anchor nw
set line "contact oddis@informatik.uni-hannover.de"
.tl_helpabout.fr_help.cv_help create text 1.0c 8.0c -text $line -anchor nw

.tl_helpabout.fr_help.cv_help create line  0.2c 8.5c 14.2c 8.5c -width 3.0

set line "You are logged in to system as $sysuser"
.tl_helpabout.fr_help.cv_help create text 0.2c 8.7c -text $line -anchor nw
set line "You are connected to database $dbact"
.tl_helpabout.fr_help.cv_help create text 0.2c 9.4c -text $line -anchor nw
set line "You are logged in to database as $dbuser"
.tl_helpabout.fr_help.cv_help create text 0.2c 10.1c -text $line -anchor nw

.tl_helpabout.fr_help.cv_help create line  0.2c 10.8c 14.2c 10.8c -width 3.0

.tl_helpabout.fr_help.cv_help create text  0.2c  12.0c -text $ODv_helptext  -anchor nw

.tl_helpabout.fr_help.cv_help create text  0.5c 22.4c -text "Menu File" -font $ODv_selectfont -anchor nw  -tags tagfile
.tl_helpabout.fr_help.cv_help create text  0.5c 23.0c -text "Menu Option" -font $ODv_selectfont -anchor nw  -tags tagoption
.tl_helpabout.fr_help.cv_help create text  0.5c 23.6c -text "Menu SQL-Options" -font $ODv_selectfont -anchor nw  -tags tagsqloptions
.tl_helpabout.fr_help.cv_help create text  0.5c 24.2c -text "Menu User-Objects" -font $ODv_selectfont -anchor nw -tags taguserobjects
.tl_helpabout.fr_help.cv_help create text  0.5c 24.8c -text "Menu All-Objects" -font $ODv_selectfont -anchor nw  -tags tagallobjects
.tl_helpabout.fr_help.cv_help create text  0.5c 25.4c -text "Menu System" -font $ODv_selectfont -anchor nw  -tags tagsystem
.tl_helpabout.fr_help.cv_help create text  0.5c 26.0c -text "Menu Optimize" -font $ODv_selectfont -anchor nw  -tags tagexplain
.tl_helpabout.fr_help.cv_help create text  0.5c 26.6c -text "Button Execute" -font $ODv_selectfont -anchor nw  -tags tagexecute
.tl_helpabout.fr_help.cv_help create text  0.5c 27.2c -text "Menu Help" -font $ODv_selectfont -anchor nw  -tags taghelp

catch {.tl_helpabout.fr_help.cv_help bind tagfile <Button-1> "OD_Help_InfoBox \"Menu File\" \"$ODv_ArHelpText(tagfile)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagoption <Button-1> "OD_Help_InfoBox \"Menu Option\" \"$ODv_ArHelpText(tagoption)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagsqloptions <Button-1> "OD_Help_InfoBox \"Menu SQL-Options\" \"$ODv_ArHelpText(tagsqloptions)\""}
catch {.tl_helpabout.fr_help.cv_help bind taguserobjects <Button-1> "OD_Help_InfoBox \"Menu User-Objects\" \"$ODv_ArHelpText(taguserobjects)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagallobjects <Button-1> "OD_Help_InfoBox \"Menu All-Objects\" \"$ODv_ArHelpText(tagallobjects)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagsystem <Button-1> "OD_Help_InfoBox \"Menu System\" \"$ODv_ArHelpText(tagsystem)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagexplain <Button-1> "OD_Help_InfoBox \"Menu Optimize\" \"$ODv_ArHelpText(tagoptimize)\""}
catch {.tl_helpabout.fr_help.cv_help bind tagexecute <Button-1> "OD_Help_InfoBox \"Button Execute\" \"$ODv_ArHelpText(tagexecute)\""}
catch {.tl_helpabout.fr_help.cv_help bind taghelp <Button-1> "OD_Help_InfoBox \"Menu Help\" \"$ODv_ArHelpText(taghelp)\""}
}



###########################################################
# Help-User-Objects-Procedures                            #
###########################################################


#################################################
# Procedure: OD_Helpusr_Graph_Bindings3_Details #
#################################################

# Sets binding for Mouse-Button-3 for Graph-Objects (OD_Help_InfoBox).

proc OD_Helpusr_Graph_Bindings3_Details {sourcetag wtag} {

global ODv_usroldtag
global ODv_usroldtaghelp
global ODv_ArHelp

if {$sourcetag == ""} {
  if {$ODv_usroldtag == $wtag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $ODv_usroldtaghelp $wtag] "$ODv_ArHelp($ODv_usroldtaghelp,$wtag)"}
  }
} else {
  if {$ODv_usroldtag == $sourcetag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $sourcetag $wtag] "$ODv_ArHelp($sourcetag,$wtag)"}
  }
}
}


##############################################
# Procedure: OD_Helpusr_Graph_Modify_Details #
##############################################

# Remembers new selected item.

proc OD_Helpusr_Graph_Modify_Details {wtag} {

global ODv_usroldtag
global ODv_usroldtaghelp

if {$ODv_usroldtag != $wtag} {set ODv_usroldtaghelp $ODv_usroldtag}
set ODv_usroldtag $wtag
}


############################################
# Procedure: OD_HelpUserObjects            #
############################################

# Main-HelpUser-Procedure
# Creates the canvas widget for the User-Helpstructure.

proc OD_HelpUserObjects {} {

catch {destroy .tl_helpusr}
toplevel .tl_helpusr

wm title    .tl_helpusr "ODDIS - Help  User-Objects-Structure"
wm minsize  .tl_helpusr 500 560
wm maxsize  .tl_helpusr 500 800
wm sizefrom .tl_helpusr user
wm geometry .tl_helpusr 500x800

frame .tl_helpusr.fr_help 
scrollbar .tl_helpusr.fr_help.sb_vhelp -command ".tl_helpusr.fr_help.cv_help yview" -orient {vertical} -relief {raised}
canvas .tl_helpusr.fr_help.cv_help -width 20c -height 5c -scrollregion {0c 0c 20c 25c} -yscrollcommand ".tl_helpusr.fr_help.sb_vhelp set"  
button .tl_helpusr.fr_help.bn_ok -text Dismiss -command {destroy .tl_helpusr}

pack   .tl_helpusr.fr_help.bn_ok -side bottom -fill x
pack   .tl_helpusr.fr_help -side top -fill both -expand 1
pack   .tl_helpusr.fr_help.sb_vhelp -side left -fill y
pack   .tl_helpusr.fr_help.cv_help -side top -fill both -expand 1


# Initialize Lists.

set all_objects() ""
set all_arrows() ""
set dependent_objects() ""
set dependent_arrows() ""
set other_objects() ""
set other_arrows() ""


# Insert main-text.

OD_Help_Graph_MainText usr {ALL USER-OBJECTS} 


# Insert the items.

OD_Help_Graph_NewObject USER         usrUser           6    1
OD_Help_Graph_NewObject TABLESPACES  usrTablespaces    1    2.5
OD_Help_Graph_NewObject ROLES        usrRoles          11   2.5
OD_Help_Graph_NewObject EXTENTS      usrExtents        2.5  4
OD_Help_Graph_NewObject INDEXES      usrIndexes        8    4
OD_Help_Graph_NewObject CLUSTERS     usrClusters       1    6
OD_Help_Graph_NewObject GRANTS       usrGrants         10   6
OD_Help_Graph_NewObject TABLES       usrTables         4    7.5
OD_Help_Graph_NewObject VIEWS        usrViews          7.6  7.5
OD_Help_Graph_NewObject SYNONYMS     usrSynonyms       1.8  9
OD_Help_Graph_NewObject CONSTRAINTS  usrConstraints    10   9.2
OD_Help_Graph_NewObject CLUSTER_COLS usrClusterColumns 1    10.5
OD_Help_Graph_NewObject COLUMNS      usrColumns        8    10.5
OD_Help_Graph_NewObject TRIGGERS     usrTriggers       5    12


# Insert the Arrows (Dependencies).

# Arrow-Differences 
global ODv_d
global ODv_a
set d $ODv_d
set a $ODv_a

OD_Help_Graph_NewArrow usrUser           usrRoles 
OD_Help_Graph_NewArrow usrUser           usrClusters
OD_Help_Graph_NewArrow usrUser           usrColumns
OD_Help_Graph_NewArrow usrUser           usrTables
OD_Help_Graph_NewArrow usrUser           usrViews
OD_Help_Graph_NewArrow usrUser           usrIndexes
OD_Help_Graph_NewArrow usrUser           usrTriggers
OD_Help_Graph_NewArrow usrUser           usrGrants
OD_Help_Graph_NewArrow usrUser           usrTablespaces
OD_Help_Graph_NewArrow usrUser           usrSynonyms
OD_Help_Graph_NewArrow usrUser           usrExtents
OD_Help_Graph_NewArrow usrUser           usrConstraints
OD_Help_Graph_NewArrow usrTablespaces    usrClusters        \
   1.2  $d  3.4 -$a  1.2  $d  5.9 -$a
OD_Help_Graph_NewArrow usrTablespaces    usrExtents         \
   1.8  $d  3.4 -$a  1.8  $d  4.2 -$d  2.4 -$a  4.2 -$d
OD_Help_Graph_NewArrow usrTablespaces    usrTables          \
   4.3 -$a  2.9 -$d  4.9  $d  2.9 -$d  4.9  $d  7.4 -$a
OD_Help_Graph_NewArrow usrTablespaces    usrIndexes         \
   2.7  $d  3.4 -$a  2.7  $d  3.5 -$d  8.5  $d  3.5 -$d  8.5  $d  3.9 -$a
OD_Help_Graph_NewArrow usrClusters       usrTables          \
   2.7  $d  6.9 -$a  2.7  $d  7.5 -$d  3.9 -$a  7.5 -$d
OD_Help_Graph_NewArrow usrClusters       usrSynonyms        \
   2.3  $d  6.9 -$a  2.3  $d  8.9 -$a
OD_Help_Graph_NewArrow usrClusters       usrClusterColumns  \
   1.2  $d  6.9 -$a  1.2  $d 10.4 -$a
OD_Help_Graph_NewArrow usrClusters       usrExtents         \
   2.8 -$d  5.5  $a  2.8 -$d  4.5  $a 
OD_Help_Graph_NewArrow usrClusterColumns usrTables          \
   4.2  0  10.5  0   4.7  0  10.5  0   4.7  0   8.0  0
OD_Help_Graph_NewArrow usrClusterColumns usrColumns         \
   4.6 -$a 10.9 -$d  7.9 -$a 10.9 -$d
OD_Help_Graph_NewArrow usrTables         usrRoles           \
   5.5 -$d  7.0  $a  5.5 -$d  5.4 -$d 11.5 -$d  5.4 -$d 11.5 -$d  3.0  $a
OD_Help_Graph_NewArrow usrTables         usrColumns         \
   5.2  $d  8.4 -$a  5.2  $d  9.8 -$d  8.2  $d  9.8 -$d  8.2  $d 10.4 -$a
OD_Help_Graph_NewArrow usrTables         usrViews           \
   6.0 -$a  7.8 -$d  7.5 -$a  7.8 -$d
OD_Help_Graph_NewArrow usrTables         usrIndexes         \
   4.6 -$d  7.0  $a  4.6 -$d  5.0 -$d  8.5 -$d  5.0 -$d  8.5 -$d  4.5  $a
OD_Help_Graph_NewArrow usrTables         usrExtents         \
   4.2 -$d  7.0  $a  4.2 -$d  4.5  $a
OD_Help_Graph_NewArrow usrTables         usrSynonyms        \
   3.5  $a  7.7  $d  2.7  $d  7.7  $d  2.7  $d  8.9 -$a
OD_Help_Graph_NewArrow usrTables         usrTriggers        \
   4.9  $d  8.4 -$a  4.9  $d 11.9 -$a
OD_Help_Graph_NewArrow usrTables         usrGrants          \
   5.2 -$d  7.0  $a  5.2 -$d  6.4 -$d  9.9 -$a  6.4 -$d
OD_Help_Graph_NewArrow usrTables         usrConstraints     \
   5.5  $d  8.4 -$a  5.5  $d  8.5 -$d 10.5  $d  8.5 -$d 10.5  $d  9.1 -$a    
OD_Help_Graph_NewArrow usrViews          usrColumns         \
   8.6  $d  8.4 -$a  8.6  $d 10.4 -$a
OD_Help_Graph_NewArrow usrViews          usrSynonyms        \
   7.8  $d  8.4 -$a  7.8  $d  9.3  $d  4.2  $a  9.3  $d
OD_Help_Graph_NewArrow usrViews          usrGrants          \
   8.3 -$d  7.0  $a  8.3 -$d  6.1 -$d  9.9 -$a  6.1 -$d
OD_Help_Graph_NewArrow usrIndexes        usrColumns         \
   9.0  $d  4.9 -$a  9.0  $d 10.4 -$a   
OD_Help_Graph_NewArrow usrIndexes        usrExtents         \
   7.5  $a  4.3  $d  4.4  $a  4.3  $d
OD_Help_Graph_NewArrow usrTriggers       usrColumns         \
   7.7 -$a 12.2 -$d  9.0 -$d 12.2 -$d  9.0 -$d 11.0  $a
OD_Help_Graph_NewArrow usrColumns        usrGrants          \
   9.4 -$d 10.0  $a  9.4 -$d  7.5 -$d 10.2 -$d  7.5 -$d 10.2 -$d  6.6  $a
OD_Help_Graph_NewArrow usrColumns        usrConstraints        \
  10.5 -$a 10.7 -$d 11.5 -$d 10.7 -$d 11.5 -$d  9.7  $a    


# Insert Additional Menu-Options.

OD_Help_Graph_Menu_Headline "Additional Menu-Options :" usr 0.1 0

OD_Help_Graph_Menu_Headline "USER" usrUser 0.1 0.5
OD_Help_Graph_Menu_NewEntry "Sequences"          usrUser        uusSequences        0.1  1
OD_Help_Graph_Menu_NewEntry "DB-Links"           usrUser        uusDblinks          0.1  1.35
OD_Help_Graph_Menu_NewEntry "Procedures"         usrUser        uusProcedures       0.1  1.7
OD_Help_Graph_Menu_NewEntry "Procedure-Text"     usrUser        uusProcSource       0.1  2.05
OD_Help_Graph_Menu_NewEntry "Privileges"         usrUser        uusPrivileges       0.1  2.4
OD_Help_Graph_Menu_NewEntry "Devices"            usrUser        uusDevices          0.1  2.75

OD_Help_Graph_Menu_Headline "VIEWS" usrViews 0.1 3.5
OD_Help_Graph_Menu_NewEntry "Base-Views"         usrViews       uviBaseviews        0.1  4     
OD_Help_Graph_Menu_NewEntry "Dependent-Views"    usrViews       uviDependentviews   0.1  4.35
OD_Help_Graph_Menu_NewEntry "Base-Objects"       usrViews       uviBaseobjects      0.1  4.7
OD_Help_Graph_Menu_NewEntry "Text"               usrViews       uviText             0.1  5.05
OD_Help_Graph_Menu_NewEntry "Comments"           usrViews       uviComments         0.1  5.4

OD_Help_Graph_Menu_Headline "TABLESPACES" usrTablespaces 5 0.5
OD_Help_Graph_Menu_NewEntry "User-Quota"         usrTablespaces utsUserquota        5    1
OD_Help_Graph_Menu_NewEntry "Segments"           usrTablespaces utsSegments         5    1.35

OD_Help_Graph_Menu_Headline "TABLES" usrTables 5 2.3
OD_Help_Graph_Menu_NewEntry "Details"            usrTables      utaDetails          5    2.8
OD_Help_Graph_Menu_NewEntry "Comments"           usrTables      utaComments         5    3.15

OD_Help_Graph_Menu_Headline "TRIGGERS" usrTriggers 5 4
OD_Help_Graph_Menu_NewEntry "Description"        usrTriggers    utrDescription      5    4.5
OD_Help_Graph_Menu_NewEntry "When"               usrTriggers    utrWhen             5    4.85
OD_Help_Graph_Menu_NewEntry "Body"               usrTriggers    utrBody             5    5.2

OD_Help_Graph_Menu_Headline "ROLES" usrRoles 10 0.5
OD_Help_Graph_Menu_NewEntry "Privileges"         usrRoles       uroPrivileges       10   1

OD_Help_Graph_Menu_Headline "CLUSTERS" usrClusters 10 2
OD_Help_Graph_Menu_NewEntry "Details"            usrClusters    uclDetails          10   2.5

OD_Help_Graph_Menu_Headline "SYNONYMS" usrSynonyms 10 3.5
OD_Help_Graph_Menu_NewEntry "DB-Links"           usrSynonyms    usyDblinks          10   4

OD_Help_Graph_Menu_Headline "COLUMNS" usrColumns 10 5
OD_Help_Graph_Menu_NewEntry "Comments"           usrColumns     ucoComments         10   5.5


# Create other_objects- and other_arrows-lists for each item(tag).

OD_Help_Graph_OtherLists usr


# Initialize User-item.

OD_Help_Graph_Modify "usrUser"
} 


#######################################################################
# Help-All-Objects-Procedures                                         #
#######################################################################


#################################################
# Procedure: OD_Helpall_Graph_Bindings3_Details #
#################################################

# Sets binding for Mouse-Button-3 for Graph-Objects (OD_Help_InfoBox).

proc OD_Helpall_Graph_Bindings3_Details {sourcetag wtag} {

global ODv_alloldtag
global ODv_alloldtaghelp
global ODv_ArHelp

if {$sourcetag == ""} {
  if {$ODv_alloldtag == $wtag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $ODv_alloldtaghelp $wtag] "$ODv_ArHelp($ODv_alloldtaghelp,$wtag)"}
  }
} else {
  if {$ODv_alloldtag == $sourcetag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $sourcetag $wtag] "$ODv_ArHelp($sourcetag,$wtag)"}
  }
}
}


##############################################
# Procedure: OD_Helpall_Graph_Modify_Details #
##############################################

# Remembers new selected item.

proc OD_Helpall_Graph_Modify_Details {wtag} {

global ODv_alloldtag
global ODv_alloldtaghelp

if {$ODv_alloldtag != $wtag} {set ODv_alloldtaghelp $ODv_alloldtag}
set ODv_alloldtag $wtag
}


##################################
# Procedure: OD_HelpAllObjects   #
##################################


proc OD_HelpAllObjects {} {

catch {destroy .tl_helpall}
toplevel .tl_helpall

wm title    .tl_helpall "ODDIS - Help  All-Objects-Structure"
wm minsize  .tl_helpall 500 560
wm maxsize  .tl_helpall 500 740
wm sizefrom .tl_helpall user
wm geometry .tl_helpall 500x740

frame .tl_helpall.fr_help 
scrollbar .tl_helpall.fr_help.sb_vhelp -command ".tl_helpall.fr_help.cv_help yview" -orient {vertical} -relief {raised} 

canvas .tl_helpall.fr_help.cv_help -width 20c -height 5c -scrollregion {0c 0c 20c 22c} -yscrollcommand ".tl_helpall.fr_help.sb_vhelp set"   
button .tl_helpall.fr_help.bn_ok -text Dismiss -command {destroy .tl_helpall}

pack   .tl_helpall.fr_help.bn_ok -side bottom -fill x
pack   .tl_helpall.fr_help -side top -fill both -expand 1
pack   .tl_helpall.fr_help.sb_vhelp -side left -fill y
pack   .tl_helpall.fr_help.cv_help -side top -fill both -expand 1


# Initialize Lists.

set all_objects() ""
set all_arrows() ""
set dependent_objects() ""
set dependent_arrows() ""
set other_objects() ""
set other_arrows() ""


# Insert main-text.

OD_Help_Graph_MainText all {ALL ACCESSIBLE OBJECTS}


# Insert the items.

OD_Help_Graph_NewObject ALL-OBJECTS  allObjects        4    1
OD_Help_Graph_NewObject TABLESPACES  allTablespaces    1    2.5
OD_Help_Graph_NewObject INDEXES      allIndexes        8    4
OD_Help_Graph_NewObject GRANTS       allGrants         10   6
OD_Help_Graph_NewObject TABLES       allTables         4    7.5
OD_Help_Graph_NewObject VIEWS        allViews          7.6  7.5
OD_Help_Graph_NewObject SYNONYMS     allSynonyms       1.8  9
OD_Help_Graph_NewObject CONSTRAINTS  allConstraints    10   9.2
OD_Help_Graph_NewObject COLUMNS      allColumns        8    10.5
OD_Help_Graph_NewObject TRIGGERS     allTriggers       5    12


# Insert the Arrows (Dependencies).

# Arrow-Differences 
global ODv_d
global ODv_a
set d $ODv_d
set a $ODv_a

OD_Help_Graph_NewArrow allObjects        allColumns
OD_Help_Graph_NewArrow allObjects        allTables
OD_Help_Graph_NewArrow allObjects        allViews
OD_Help_Graph_NewArrow allObjects        allIndexes
OD_Help_Graph_NewArrow allObjects        allTriggers
OD_Help_Graph_NewArrow allObjects        allGrants
OD_Help_Graph_NewArrow allObjects        allSynonyms
OD_Help_Graph_NewArrow allObjects        allTablespaces
OD_Help_Graph_NewArrow allTablespaces    allTables          \
   4.3 -$a  2.9 -$d  4.9  $d  2.9 -$d  4.9  $d  7.4 -$a
OD_Help_Graph_NewArrow allTablespaces    allIndexes         \
   2.7  $d  3.4 -$a  2.7  $d  3.5 -$d  8.5  $d  3.5 -$d  8.5  $d  3.9 -$a
OD_Help_Graph_NewArrow allTables         allColumns         \
   5.2  $d  8.4 -$a  5.2  $d  9.8 -$d  8.2  $d  9.8 -$d  8.2  $d 10.4 -$a
OD_Help_Graph_NewArrow allTables         allViews           \
   6.0 -$a  7.8 -$d  7.5 -$a  7.8 -$d
OD_Help_Graph_NewArrow allTables         allIndexes         \
   4.6 -$d  7.0  $a  4.6 -$d  5.0 -$d  8.5 -$d  5.0 -$d  8.5 -$d  4.5  $a
OD_Help_Graph_NewArrow allTables         allSynonyms        \
   3.5  $a  7.7  $d  2.7  $d  7.7  $d  2.7  $d  8.9 -$a
OD_Help_Graph_NewArrow allTables         allTriggers        \
   4.9  $d  8.4 -$a  4.9  $d 11.9 -$a
OD_Help_Graph_NewArrow allTables         allGrants          \
   5.2 -$d  7.0  $a  5.2 -$d  6.4 -$d  9.9 -$a  6.4 -$d
OD_Help_Graph_NewArrow allTables         allConstraints     \
   5.5  $d  8.4 -$a  5.5  $d  8.5 -$d 10.5  $d  8.5 -$d 10.5  $d  9.1 -$a    
OD_Help_Graph_NewArrow allViews          allColumns         \
   8.6  $d  8.4 -$a  8.6  $d 10.4 -$a
OD_Help_Graph_NewArrow allViews          allSynonyms        \
   7.8  $d  8.4 -$a  7.8  $d  9.3  $d  4.2  $a  9.3  $d
OD_Help_Graph_NewArrow allViews          allGrants          \
   8.3 -$d  7.0  $a  8.3 -$d  6.1 -$d  9.9 -$a  6.1 -$d
OD_Help_Graph_NewArrow allIndexes        allColumns         \
   9.0  $d  4.9 -$a  9.0  $d 10.4 -$a   
OD_Help_Graph_NewArrow allTriggers       allColumns         \
   7.7 -$a 12.2 -$d  9.0 -$d 12.2 -$d  9.0 -$d 11.0  $a
OD_Help_Graph_NewArrow allColumns        allGrants          \
   9.4 -$d 10.0  $a  9.4 -$d  7.5 -$d 10.2 -$d  7.5 -$d 10.2 -$d  6.6  $a
OD_Help_Graph_NewArrow allColumns        allConstraints        \
  10.5 -$a 10.7 -$d 11.5 -$d 10.7 -$d 11.5 -$d  9.7  $a    


# Insert Additional Menu-Options.

OD_Help_Graph_Menu_Headline "Additional Menu-Options :" "all" 0.1 0

OD_Help_Graph_Menu_Headline "ALL-OBJECTS" allObjects 0.1 0.5
OD_Help_Graph_Menu_NewEntry "Sequences"          allObjects     aobSequences        0.1  1
OD_Help_Graph_Menu_NewEntry "DB-Links"           allObjects     aobDblinks          0.1  1.35
OD_Help_Graph_Menu_NewEntry "Procedures"         allObjects     aobProcedures       0.1  1.7
OD_Help_Graph_Menu_NewEntry "Procedure-Text"     allObjects     aobProcSource       0.1  2.05

OD_Help_Graph_Menu_Headline "COLUMNS" allColumns 0.1 3
OD_Help_Graph_Menu_NewEntry "Comments"           allColumns     acoComments         0.1  3.5

OD_Help_Graph_Menu_Headline "TABLES" allTables 5 0.5
OD_Help_Graph_Menu_NewEntry "Details"            allTables      ataDetails          5    1
OD_Help_Graph_Menu_NewEntry "Comments"           allTables      ataComments         5    1.35

OD_Help_Graph_Menu_Headline "TRIGGERS" allTriggers 5 2.5
OD_Help_Graph_Menu_NewEntry "Description"        allTriggers    atrDescription      5    3
OD_Help_Graph_Menu_NewEntry "When"               allTriggers    atrWhen             5    3.35
OD_Help_Graph_Menu_NewEntry "Body"               allTriggers    atrBody             5    3.7

OD_Help_Graph_Menu_Headline "VIEWS" allViews 10 0.5
OD_Help_Graph_Menu_NewEntry "Base-Views"         allViews       aviBaseviews        10   1     
OD_Help_Graph_Menu_NewEntry "Dependent-Views"    allViews       aviDependentviews   10   1.35
OD_Help_Graph_Menu_NewEntry "Base-Objects"       allViews       aviBaseobjects      10   1.7
OD_Help_Graph_Menu_NewEntry "Text"               allViews       aviText             10   2.05
OD_Help_Graph_Menu_NewEntry "Comments"           allViews       aviComments         10   2.4


# Create other_objects- and other_arrows-lists for each item(tag).

OD_Help_Graph_OtherLists all


# Initialize All-Objects-item.

OD_Help_Graph_Modify "allObjects"
} 


#######################################################################
# Help-System-Procedures                                              #
#######################################################################


#################################################
# Procedure: OD_Helpsys_Graph_Bindings3_Details #
#################################################

# Sets binding for Mouse-Button-3 for Graph-Objects (OD_Help_InfoBox).

proc OD_Helpsys_Graph_Bindings3_Details {sourcetag wtag} {

global ODv_sysoldtag
global ODv_sysoldtaghelp
global ODv_ArHelp

if {$sourcetag == ""} {
  if {$ODv_sysoldtag == $wtag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $ODv_sysoldtaghelp $wtag] "$ODv_ArHelp($ODv_sysoldtaghelp,$wtag)"}
  }
} else {
  if {$ODv_sysoldtag == $sourcetag} {
    catch {OD_Help_InfoBox [OD_Help_InfoBox_Title $sourcetag $wtag] "$ODv_ArHelp($sourcetag,$wtag)"}
  }
}
}


##############################################
# Procedure: OD_Helpsys_Graph_Modify_Details #
##############################################

# Remembers new selected item.

proc OD_Helpsys_Graph_Modify_Details {wtag} {

global ODv_sysoldtag
global ODv_sysoldtaghelp

if {$ODv_sysoldtag != $wtag} {set ODv_sysoldtaghelp $ODv_sysoldtag}
set ODv_sysoldtag $wtag
}


############################################
# Procedure: OD_HelpSystem                 #
############################################

# Main-HelpSystem-Procedure
# Creates the canvas widget for the System-Helpstructure.

proc OD_HelpSystem {} {

catch {destroy .tl_helpsys}
toplevel .tl_helpsys

wm title    .tl_helpsys "ODDIS - Help  System-Structure"
wm minsize  .tl_helpsys 500 560
wm maxsize  .tl_helpsys 500 820
wm sizefrom .tl_helpsys user
wm geometry .tl_helpsys 500x820

frame .tl_helpsys.fr_help 
scrollbar .tl_helpsys.fr_help.sb_vhelp -command ".tl_helpsys.fr_help.cv_help yview" -orient {vertical} -relief {raised}

canvas .tl_helpsys.fr_help.cv_help -width 20c -height 5c -scrollregion {0c 0c 20c 25c} -yscrollcommand ".tl_helpsys.fr_help.sb_vhelp set" 
  
button .tl_helpsys.fr_help.bn_ok -text Dismiss -command {destroy .tl_helpsys}

pack   .tl_helpsys.fr_help.bn_ok -side bottom -fill x
pack   .tl_helpsys.fr_help -side top -fill both -expand 1
pack   .tl_helpsys.fr_help.sb_vhelp -side left -fill y

pack   .tl_helpsys.fr_help.cv_help -side top -fill both -expand 1


# Initialize Lists.

set all_objects() ""
set all_arrows() ""
set dependent_objects() ""
set dependent_arrows() ""
set other_objects() ""
set other_arrows() ""


# Insert main-text.

OD_Help_Graph_MainText sys {DATABASE OBJECTS for DB-ADMINS}


# Insert the items.

OD_Help_Graph_NewObject SYSTEM       sysSystem         4    1
OD_Help_Graph_NewObject TABLESPACES  sysTablespaces    1    2.5
OD_Help_Graph_NewObject USER         sysUser           6    2.5
OD_Help_Graph_NewObject ROLES        sysRoles          11   2.5
OD_Help_Graph_NewObject EXTENTS      sysExtents        2.5  4
OD_Help_Graph_NewObject INDEXES      sysIndexes        8    4
OD_Help_Graph_NewObject CLUSTERS     sysClusters       1    6
OD_Help_Graph_NewObject GRANTS       sysGrants         10   6
OD_Help_Graph_NewObject TABLES       sysTables         4    7.5
OD_Help_Graph_NewObject VIEWS        sysViews          7.6  7.5
OD_Help_Graph_NewObject SYNONYMS     sysSynonyms       1.8  9
OD_Help_Graph_NewObject CONSTRAINTS  sysConstraints    10   9.2
OD_Help_Graph_NewObject CLUSTER_COLS sysClusterColumns 1    10.5
OD_Help_Graph_NewObject COLUMNS      sysColumns        8    10.5
OD_Help_Graph_NewObject TRIGGERS     sysTriggers       5    12


# Insert the Arrows (Dependencies).

# Arrow-Differences 
global ODv_d
global ODv_a
set d $ODv_d
set a $ODv_a

OD_Help_Graph_NewArrow sysSystem         sysTablespaces     \
   4.5  0   1.5  0   4.5  0   1.9  0   2.5  0   1.9  0   2.5  0  2.4  0
OD_Help_Graph_NewArrow sysSystem         sysUser            \
   5.0  0   1.5  0   5.0  0   1.9  0   6.5  0   1.9  0   6.5  0  2.4  0
OD_Help_Graph_NewArrow sysSystem         sysRoles           \
   6.0  0   1.2  0  11.5  0   1.2  0  11.5  0   2.4  0
OD_Help_Graph_NewArrow sysTablespaces    sysClusters        \
   1.2  $d  3.4 -$a  1.2  $d  5.9 -$a
OD_Help_Graph_NewArrow sysTablespaces    sysExtents         \
   1.8  $d  3.4 -$a  1.8  $d  4.2 -$d  2.4 -$a  4.2 -$d
OD_Help_Graph_NewArrow sysTablespaces    sysUser            \
   4.3 -$a  2.6 -$d  5.9 -$a  2.6 -$d
OD_Help_Graph_NewArrow sysTablespaces    sysTables          \
   4.3 -$a  2.9 -$d  4.9  $d  2.9 -$d  4.9  $d  7.4 -$a
OD_Help_Graph_NewArrow sysTablespaces    sysIndexes         \
   2.7  $d  3.4 -$a  2.7  $d  3.5 -$d  8.5  $d  3.5 -$d  8.5  $d  3.9 -$a
OD_Help_Graph_NewArrow sysUser           sysTables          \
   6.0  $d  3.4 -$a  6.0  $d  7.5  $d  5.6  $a  7.5  $d
OD_Help_Graph_NewArrow sysUser           sysColumns         \
   6.8  $d  3.4 -$a  6.8  $d 10.5 -$d  7.9 -$a 10.5 -$d   
OD_Help_Graph_NewArrow sysUser           sysIndexes         \
   7.6 -$a  2.9 -$d  9.0  $d  2.9 -$d  9.0  $d  3.9 -$a
OD_Help_Graph_NewArrow sysUser           sysViews           \
   7.0  $d  3.4 -$a  7.0  $d  7.5 -$d  7.5 -$a  7.5 -$d
OD_Help_Graph_NewArrow sysUser           sysClusters        \
   5.8  $d  3.4 -$a  5.8  $d  6.0  $d  3.2  $a  6.0  $d
OD_Help_Graph_NewArrow sysUser           sysExtents         \
   5.5  $a  2.8  $d  5.4  $d  2.8  $d  5.4  $d  4.0  $d  4.4  $a  4.0  $d
OD_Help_Graph_NewArrow sysUser           sysSynonyms        \
   6.2  $d  3.4 -$a  6.2  $d  9.0  $d  4.2  $a  9.0  $d  
OD_Help_Graph_NewArrow sysUser           sysTriggers        \
   6.6  $d  3.4 -$a  6.6  $d 11.9 -$a
OD_Help_Graph_NewArrow sysUser           sysRoles           \
   7.6 -$a  2.5 -$d 10.9 -$a  2.5 -$d
OD_Help_Graph_NewArrow sysUser           sysGrants          \
   7.6 -$a  2.7 -$d 10.2  $d  2.7 -$d 10.2  $d  5.9 -$a
OD_Help_Graph_NewArrow sysUser           sysConstraints     \
   7.2  0   3.1  0  10.5  0   3.1  0  10.5  0   4.0  0  12.2  0   4.0  0  12.2  0   9.1  0 
OD_Help_Graph_NewArrow sysClusters       sysTables          \
   2.7  $d  6.9 -$a  2.7  $d  7.5 -$d  3.9 -$a  7.5 -$d
OD_Help_Graph_NewArrow sysClusters       sysSynonyms        \
   2.3  $d  6.9 -$a  2.3  $d  8.9 -$a
OD_Help_Graph_NewArrow sysClusters       sysClusterColumns  \
   1.2  $d  6.9 -$a  1.2  $d 10.4 -$a
OD_Help_Graph_NewArrow sysClusters       sysExtents         \
   2.8 -$d  5.5  $a  2.8 -$d  4.5  $a 
OD_Help_Graph_NewArrow sysClusterColumns sysTables          \
   4.2  0  10.5  0   4.7  0  10.5  0   4.7  0   8.0  0
OD_Help_Graph_NewArrow sysClusterColumns sysColumns         \
   4.6 -$a 10.9 -$d  7.9 -$a 10.9 -$d
OD_Help_Graph_NewArrow sysClusterColumns sysUser            \
   4.2  0  10.65 0   6.45 0  10.65 0   6.45 0   3.0  0
OD_Help_Graph_NewArrow sysTables         sysRoles           \
   5.5 -$d  7.0  $a  5.5 -$d  5.4 -$d 11.5 -$d  5.4 -$d 11.5 -$d  3.0  $a
OD_Help_Graph_NewArrow sysTables         sysColumns         \
   5.2  $d  8.4 -$a  5.2  $d  9.8 -$d  8.2  $d  9.8 -$d  8.2  $d 10.4 -$a
OD_Help_Graph_NewArrow sysTables         sysViews           \
   6.0 -$a  7.8 -$d  7.5 -$a  7.8 -$d
OD_Help_Graph_NewArrow sysTables         sysIndexes         \
   4.6 -$d  7.0  $a  4.6 -$d  5.0 -$d  8.5 -$d  5.0 -$d  8.5 -$d  4.5  $a
OD_Help_Graph_NewArrow sysTables         sysExtents         \
   4.2 -$d  7.0  $a  4.2 -$d  4.5  $a
OD_Help_Graph_NewArrow sysTables         sysSynonyms        \
   3.5  $a  7.7  $d  2.7  $d  7.7  $d  2.7  $d  8.9 -$a
OD_Help_Graph_NewArrow sysTables         sysTriggers        \
   4.9  $d  8.4 -$a  4.9  $d 11.9 -$a
OD_Help_Graph_NewArrow sysTables         sysGrants          \
   5.2 -$d  7.0  $a  5.2 -$d  6.4 -$d  9.9 -$a  6.4 -$d
OD_Help_Graph_NewArrow sysTables         sysConstraints     \
   5.5  $d  8.4 -$a  5.5  $d  8.5 -$d 10.5  $d  8.5 -$d 10.5  $d  9.1 -$a  
OD_Help_Graph_NewArrow sysViews          sysColumns         \
   8.6  $d  8.4 -$a  8.6  $d 10.4 -$a
OD_Help_Graph_NewArrow sysViews          sysSynonyms        \
   7.8  $d  8.4 -$a  7.8  $d  9.3  $d  4.2  $a  9.3  $d
OD_Help_Graph_NewArrow sysViews          sysGrants          \
   8.3 -$d  7.0  $a  8.3 -$d  6.1 -$d  9.9 -$a  6.1 -$d
OD_Help_Graph_NewArrow sysIndexes        sysColumns         \
   9.0  $d  4.9 -$a  9.0  $d 10.4 -$a   
OD_Help_Graph_NewArrow sysIndexes        sysExtents         \
   7.5  $a  4.3  $d  4.4  $a  4.3  $d
OD_Help_Graph_NewArrow sysTriggers       sysColumns         \
   7.7 -$a 12.2 -$d  9.0 -$d 12.2 -$d  9.0 -$d 11.0  $a
OD_Help_Graph_NewArrow sysColumns        sysGrants          \
   9.4 -$d 10.0  $a  9.4 -$d  7.5 -$d 10.2 -$d  7.5 -$d 10.2 -$d  6.6  $a
OD_Help_Graph_NewArrow sysColumns        sysConstraints        \
  10.5 -$a 10.7 -$d 11.5 -$d 10.7 -$d 11.5 -$d  9.7  $a    


# Insert Additional Menu-Options.

OD_Help_Graph_Menu_Headline "Additional Menu-Options :" "sys" 0.1 0

OD_Help_Graph_Menu_Headline "SYSTEM" sysSystem 0.1 0.5
OD_Help_Graph_Menu_NewEntry "Rollback Segs"      sysSystem      sssRollbacksegs     0.1  1
OD_Help_Graph_Menu_NewEntry "Free Space"         sysSystem      sssFreespace        0.1  1.35
OD_Help_Graph_Menu_NewEntry "Free Space Details" sysSystem      sssFreespacedetails 0.1  1.7
OD_Help_Graph_Menu_NewEntry "Data Files"         sysSystem      sssDatafiles        0.1  2.05
OD_Help_Graph_Menu_NewEntry "Devices"            sysSystem      sssDevices          0.1  2.40

OD_Help_Graph_Menu_Headline "VIEWS" sysViews 0.1 3.2
OD_Help_Graph_Menu_NewEntry "Base-Views"         sysViews       sviBaseviews        0.1  3.7     
OD_Help_Graph_Menu_NewEntry "Dependent-Views"    sysViews       sviDependentviews   0.1  4.05
OD_Help_Graph_Menu_NewEntry "Base-Objects"       sysViews       sviBaseobjects      0.1  4.4
OD_Help_Graph_Menu_NewEntry "Text"               sysViews       sviText             0.1  4.75
OD_Help_Graph_Menu_NewEntry "Comments"           sysViews       sviComments         0.1  5.05

OD_Help_Graph_Menu_Headline "SYNONYMS" sysSynonyms 0.1 6
OD_Help_Graph_Menu_NewEntry "DB-Links"           sysSynonyms    ssyDblinks          0.1  6.5

OD_Help_Graph_Menu_Headline "TABLESPACES" sysTablespaces 5 0.5
OD_Help_Graph_Menu_NewEntry "Files"              sysTablespaces stsFiles            5    1
OD_Help_Graph_Menu_NewEntry "User-Quotas"        sysTablespaces stsUserquotas       5    1.35
OD_Help_Graph_Menu_NewEntry "Segments"           sysTablespaces stsSegments         5    1.7

OD_Help_Graph_Menu_Headline "TABLES" sysTables 5 2.5
OD_Help_Graph_Menu_NewEntry "Details"            sysTables      staDetails          5    3
OD_Help_Graph_Menu_NewEntry "Comments"           sysTables      staComments         5    3.35

OD_Help_Graph_Menu_Headline "TRIGGERS" sysTriggers 5 4.1
OD_Help_Graph_Menu_NewEntry "Description"        sysTriggers    strDescription      5    4.6
OD_Help_Graph_Menu_NewEntry "When"               sysTriggers    strWhen             5    4.95
OD_Help_Graph_Menu_NewEntry "Body"               sysTriggers    strBody             5    5.3

OD_Help_Graph_Menu_Headline "COLUMNS" sysColumns 5 6
OD_Help_Graph_Menu_NewEntry "Comments"           sysColumns     scoComments         5    6.5

OD_Help_Graph_Menu_Headline "USER" sysUser 10 0.5
OD_Help_Graph_Menu_NewEntry "Def.Tablespace"     sysUser        susDefTablespace    10   1
OD_Help_Graph_Menu_NewEntry "Temp.Tablespace"    sysUser        susTempTablespace   10   1.35
OD_Help_Graph_Menu_NewEntry "Sequences"          sysUser        susSequences        10   1.7
OD_Help_Graph_Menu_NewEntry "DB-Links"           sysUser        susDblinks          10   2.05
OD_Help_Graph_Menu_NewEntry "Procedures"         sysUser        susProcedures       10   2.4
OD_Help_Graph_Menu_NewEntry "Procedure-Text"     sysUser        susProcSource       10   2.75
OD_Help_Graph_Menu_NewEntry "Privileges"         sysUser        susPrivileges       10   3.1

OD_Help_Graph_Menu_Headline "ROLES" sysRoles 10 4
OD_Help_Graph_Menu_NewEntry "Granted Roles"      sysRoles       sroGrantedRoles     10   4.5
OD_Help_Graph_Menu_NewEntry "Granted to Roles"   sysRoles       sroGrantedtoRoles   10   4.85
OD_Help_Graph_Menu_NewEntry "Privileges"         sysRoles       sroPrivileges       10   5.2

OD_Help_Graph_Menu_Headline "CLUSTERS" sysClusters 10 6
OD_Help_Graph_Menu_NewEntry "Details"            sysClusters    sclDetails          10   6.5


# Create other_objects- and other_arrows-lists for each item(tag).

OD_Help_Graph_OtherLists sys


# Initialize System-item.

OD_Help_Graph_Modify "sysSystem"
} 


########################################################################
# Internal Oracle-Help-Queries                                         #
########################################################################


# Procedure: OD_ShowHelpOraInfo

proc OD_ShowHelpOraInfo { args} {

global ODv_hlHelpOraInfo
global ODv_oracursor
global oramsg

#set args [string trim $args \{\}]
set top   [string trimright [string trim [lindex $args 0] \{\}]]

set li     [split $ODv_hlHelpOraInfo /]
set title  [format "%-80.80s" [lindex $li 0]]

set li ""

OD_Msg "Searching for data..."
orasql $ODv_oracursor "select info from system.help where topic = '$top' order by seq"
orafetch $ODv_oracursor {lappend li [format "%-80.80s" @1]}
set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

OD_GenWin .ow_helporainfo "Help-Info for Topic '$top'" $title 400 300 700x400 $li 0

}


# Procedure: OD_ShowHelpOraTopics  

proc OD_ShowHelpOraTopics {} {

global ODv_hlHelpOraTopics
global ODv_oracursor
global oramsg

set li [split $ODv_hlHelpOraTopics /]
set title  [format "%-50.50s" [lindex $li 0]]

set li ""

OD_Msg "Searching for data..."
orasql $ODv_oracursor {select distinct topic from system.help order by topic}
orafetch $ODv_oracursor {lappend li [format "%-50.50s" @1]}
set cnt $oramsg(rows)
OD_Msg "SQL finished, $cnt rows returned"

if  {[llength $li] == 0} {
    OD_Msg "No Oracle Help Topics available"
    return
}

OD_GenWin .ow_helporatopics "Help Topics" $title 400 300 400x300 $li 0  Info OD_ShowHelpOraInfo

}


