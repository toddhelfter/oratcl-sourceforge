
NOTE - I received this email about using Oratcl 2.5 with Oracle 8.  I haven't
incorporated any of the mods into the configure/make files yet.


-----------------------------------------------------------------------------
hi tom,

tba (twenty beers after) i found one way to compile a static version of oratcl.
i know the way making demoapplications and then notice about the lib's,
but this time .... uaaaahg!

when you found a better way, please tell me.

whats about new OCI? 
i think we should use it?
nice way's for reading writing blobs and so on ...
if you decide adapting oratcl, please tell me.
i'am trying the same.

so here is a solution i've found (perhaps stupid):
1. configure --without-tk --disabled-shared (not so time consuming)
2. substitute the following variables (by):
# Oracle 8.0 enhancement
#

# with the following include nautab.o there is a duplicate  symbol
#ORA_SYS_LIBS  = -lclntsh ${ORA}/nautab.o ${ORA}/naeet.o ${ORA}/naect.o 
{ORA}/naedhs.o

# without is ok
ORA_SYS_LIBS  = -lclntsh ${ORA}/naeet.o ${ORA}/naect.o ${ORA}/naedhs.o

OTHER_ORA_LIBS = -lc -laio -lm  -lthread

OCIIGNORE =

OCILIB        =  \
${ORA}/libclient.a\
${ORA}/libcommon.a\
${ORA}/libgeneric.a\
${ORA}/libmm.a\
${ORA}/libnetv2.a\
${ORA}/libnetwork.a\
${ORA}/libncr.a\
${ORA}/libnttcp.a\
${ORA}/libepc.a\
${ORA}/libcore4.a\
${ORA}/libnlsrtl3.a\
${ORA}/__fstd.o

3. you need the ${ORA} in your LD_LIBRARY_PATH (and at minimum ucblib)

4. this works on solaris 2.5.1 with Oracle 8.0.3.2 with or without OPS



