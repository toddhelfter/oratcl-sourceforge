###############################################################################
#
# Oratcl-2.5
# Makefile for oratcl-capi
#
# Tom Poindexter 

SHELL = /bin/sh

###############################################################################
#
# set the following defines as needed: 


#------------------------------------------------------------------------------
# define where Oracle OCI libraries are located

#ORACLE_HOME =  /define/this/if/ORACLE_HOME/is/not/in/your/environment

# use the oracle shared lib, for machines that don't have this, you will
# need to use the OCI= line from the Oratcl Makefile.  alternatively, you
# can make the Oracle 'cdemo1 program' in $ORACLE_HOME/rdbms/demo/oracle.mk 
# to get a list of required libraries

#OCILIB = $(ORACLE_HOME)/lib/liboracle.so
#OCILIB = $(ORACLE_HOME)/lib/liboracle.sl
OCILIB = $(ORACLE_HOME)/lib/libclntsh.so

#------------------------------------------------------------------------------
# compiler to use

CC = cc -g 
# CC = cc -g

CCOPTS = -I. -DVERSION7 -DNONBLOCK_CURSOR

#
# end of defines
#
###############################################################################


all:	testcapi


#------------------------------------------------------------------------------
# how to build objects for oratcl-capi

oratcl.o:	../oratcl.c tcl.h
	$(CC) -c $(CCOPTS) ../oratcl.c

oratcl-capi.o:	oratcl-capi.c oratcl-capi.h tcl.h
	$(CC) -c $(CCOPTS) oratcl-capi.c

test.o:		test.c oratcl-capi.h 
	$(CC) -c $(CCOPTS) test.c

testcapi:	test.o oratcl-capi.o oratcl.o
	$(CC) -o testcapi test.o oratcl-capi.o oratcl.o $(OCILIB) 


clean:	
	/bin/rm -f oratcl.o oratcl-capi.o test.o testcapi


###############################################################################
# end of Makefile
###############################################################################

