# Oratcl Wiki / History

## Origins (early 1990s–1999): Tom Poindexter

Oratcl predates Perl's DBI and was inspired by similar tools written for Perl (`sybperl`,
`oraperl`), though it was written from scratch rather than ported from either.

Oratcl was originally written by [Tom Poindexter](https://www.nyx.net/~tpoindex/tcl.html),
who also wrote the Sybase-focused `Sybtcl` and adapted that earlier work into Oratcl for
Oracle. Poindexter authored Oratcl versions 1.0 through 2.6. Scriptics Corp (John
Ousterhout's company, maintainer of Tcl itself) helped produce Oratcl 2.6, adding build
support for Oracle 8.0/8.1 and I18N support for Tcl 8.2, and hosted the code on its NetCVS
site — this matches this project's imported `scriptics-sc-1-0-branch`,
`scriptics-sc-1-1-branch`, `scriptics-sc-2-6-branch`, and `scriptics-sc-2-7-branch` branches,
and the `ajuba-ajuba2-*` tags (Ajuba Solutions was Scriptics' later corporate name).

## Ownership transfer (1999): Todd Helfter

Todd Helfter contributed most of the patches for Oratcl 2.7. Poindexter transferred
ownership and maintenance of the project to Helfter in 1999. Helfter has authored every
release from 3.0.1 onward — 3.1, 3.2, 3.3, 4.0, 4.1, 4.3, 4.4, 4.5, 4.6 (the last SVN trunk
state, 2017), and the current 5.0.

## Publications

Oratcl is covered in **"Tcl/Tk Tools"**, edited by Mark Harrison, published by O'Reilly and
Associates (1st Edition, September 1997, ISBN 1-56592-218-2), as the chapter "Oratcl: An
Oracle Interface for Tcl" by Tom Poindexter, starting page 453 — see
[the Google Books entry](https://books.google.com/books?id=SaxQAAAAMAAJ&q=Oratcl&dq=Oratcl)
or [his page](https://www.nyx.net/~tpoindex/tcl.html) for more on his own writing and software.

Oratcl is also covered in **"Oracle & Open Source"** by Andy Duncan and Sean Hull,
published by O'Reilly (2001, ISBN 0596000189), chapter 4, including page 86's
walkthrough of downloading and installing Oratcl on Unix from
`http://download.sourceforge.net/oratcl/` (e.g. `oratcl31.tar.gz`) — see the
[publisher's chapter page](https://www.oreilly.com/library/view/oracle-and-open/0596000189/ch04.html)
or [borrow it on the Internet Archive](https://archive.org/details/oracleopensource0000dunc).

Oratcl's full command set is also documented in **"Tcl/Tk in a Nutshell: A Desktop Quick
Reference"** by Paul Raines and Jeff Tranter (O'Reilly, 1999) — see
[the reference entries starting page 388](https://books.google.com/books?id=0PkWJs1UvJ8C&pg=PA435&dq=Oratcl)
on Google Books.

Oratcl installation/usage is also covered in **"Tcl/Tk: A Developer's Guide"** by Clif Flynt
(2003) — see [page 704 on Google Books](https://books.google.com/books?id=LS0z-FeoEDUC&pg=PA704&dq=Oratcl),
which walks through installing the 2.5 Oratcl extension on UNIX.

Oratcl is also referenced in **"High-Performance Oracle: Proven Methods for Achieving
Optimum Performance and Availability"** by Geoff Ingram (2002), page 590, in the context of
Oracle Intelligent Agent (OIA) scripting with the "OraTcl Scripting Language" — see
[page 590 on Google Books](https://books.google.com/books?id=mK6fRiVrZpoC&q=Oratcl&dq=Oratcl).

Oratcl is also described in **"Implementing and Managing Oracle Databases"** by Steve
Lemme and John R. Colby (2000), page 79, in the context of Oracle Enterprise Manager
integration — see
[page 79 on Google Books](https://books.google.com/books?id=wWZGAAAAYAAJ&q=Oratcl&dq=Oratcl).

Oratcl is used in a CGI example in **"Web Tcl Complete"** by Steven/Steve Ball (1999), page
86, showing a `tclsh` CGI script using `package require Oratcl` to query Oracle from a web
page — see [page 86 on Google Books](https://books.google.com/books?id=2YNQAAAAMAAJ&q=Oratcl&dq=Oratcl).

Oratcl is indexed in **"Oracle9i for Windows Handbook"** by Anand Adkoli and Rama Velpuri
(2002) — the index (page 522) points to "OraTcl" on page 319 and "OraTcl language" on page
322 — see [the index entry on Google Books](https://books.google.com/books?id=L8K5BAt7kzcC&q=Oratcl&dq=Oratcl).

Oratcl is discussed in **"The Fifth Annual Tcl/Tk Workshop '97 Proceedings"** (edited by
Joseph A. Konstan and Brent Welch, 1997), page 165, which describes OraTcl as "a well known
Tcl extension from T. Poindexter that provides access to a Oracle Database server" — see
[page 165 on Google Books](https://books.google.com/books?id=8wYJAQAAMAAJ&q=Oratcl&dq=Oratcl).

Oratcl is mentioned in a book by **Richard Petersen** (2001), page 232, noting that
"Oratcl implement[s] database interfaces to the Sybase and Oracle databases" — see
[page 232 on Google Books](https://books.google.com/books?id=3LNQAAAAMAAJ&q=Oratcl&dq=Oratcl).

Oratcl (as "OraTCL") is described in a book by **Carol McCullough-Dieter, Jatinder Prem,
and Ramesh Chandak** (1998), page 57, in the context of Oracle Enterprise Manager batch
jobs generating Tcl scripts — see
[page 57 on Google Books](https://books.google.com/books?id=mc9QAAAAMAAJ&q=Oratcl&dq=Oratcl).

Oratcl is indexed in **"Effective Tcl/Tk Programming"** by Mark Harrison and Michael
McLennan (1998) — the index (page 401) points to "Oratcl" on page 315 — see
[the index entry on Google Books](https://books.google.com/books?id=tI4t3lWeQmkC&q=Oratcl&dq=Oratcl).
(Harrison also edited "Tcl/Tk Tools", cited above.)

A CERN publication (Issue 7, 1999), page 99, mentions "oratcl scripts" alongside what
appears to be OCR-garbled content about Oracle Forms and hardware/power-supply
descriptions — see [page 99 on Google Books](https://books.google.com/books?id=tPsWAQAAMAAJ&q=Oratcl&dq=Oratcl).
Low-confidence citation (snippet is largely OCR noise), but notable as a potential sign of
Oratcl use at CERN.

Oratcl is described in **"Astronomical Data Analysis Software and Systems VI"** (edited by
Gareth Hunt and Harry Edward Payne, 1997), page 64: "OraTcl... is used to create the
windows-based user interface" for an astronomical data system — see
[page 64 on Google Books](https://books.google.com/books?id=xvsaAQAAIAAJ&q=Oratcl&dq=Oratcl).

Oratcl is indexed in **"Practical Programming in Tcl & Tk"** by Brent B. Welch (2000) — a
core, widely-used Tcl reference by one of the Tcl/Tk community's foremost authors — see
[the index entry on Google Books](https://books.google.com/books?id=JkNGAQAAIAAJ&q=Oratcl&dq=Oratcl).

A 2003 book (title unclear from the Google Books snippet, possibly on system
administration) lists `oratcl.sourceforge.net` in its bibliography — see
[page 13 on Google Books](https://books.google.com/books?id=aU5VAAAAMAAJ&q=Oratcl&dq=Oratcl).
This is a bibliography/URL mention rather than substantive coverage, unlike the citations
above.

## Pre-1999 history isn't in the commit history

The CVS/SVN-derived Git history begins at version 2.5 (1999-07-27, "initial check-in of
Oratcl 2.5" — the earliest revision after `cvs2svn`'s standard project initialization).
Versions 1.0 through roughly 2.4 (authored solely by Poindexter) predate what was captured
into the CVS repository that was later converted to SVN, and aren't present in the commit
history — only referenced via retained copyright notices still present in early branch
files (e.g. "Copyright 1993 Tom Poindexter and U S WEST Advanced Technologies, Inc.").

## CVS → SVN → Git migration (2026)

The project's canonical history began as CVS, hosted on SourceForge (confirmed by revision
1 of the SVN repository: "Standard project directories initialized by cvs2svn"). It was
later converted to SVN, still on SourceForge
(`svn+ssh://tmh@svn.code.sf.net/p/oratcl/svncode`), where it remained through version 4.6
(2017) — still read-only accessible today at
https://svn.code.sf.net/p/oratcl/svncode/.

In 2026, the full revision history (800 SVN revisions, itself encompassing the earlier CVS
history back to 1999-07-26) was imported into Git via `git svn`, preserving every branch
(`scriptics-sc-1-0` through `oratcl-4-6`) and tag, with real authorship and dates, at
[toddhelfter/oratcl-sourceforge](https://github.com/toddhelfter/oratcl-sourceforge).

The independently-developed Oratcl 5.0 work (Tcl 9 port, Oracle 23c compatibility, security
hardening) — originally built from a disconnected manual snapshot of the 4.6 state — was
grafted onto this real history via `git replace --graft` + `git filter-repo`, producing a
single unbroken 669-commit history from 1999 through 5.0, with content verified
byte-identical at the graft seam (matching tree hashes) and no unrelated branch/tag history
disturbed.

## Related/derivative projects

- [HammerDBLtd/Oratcl](https://github.com/HammerDBLtd/Oratcl) — HammerDB's own
  actively-maintained fork (originally `sm-shaw/Oratcl` by Steve Shaw, later transferred to
  the HammerDB GitHub organization), with its own independent Tcl 9 modernization work. See
  [TODO.md](TODO.md) Story 9.
- [bagnongithub/oratcl](https://github.com/bagnongithub/oratcl) — an independent,
  MIT-licensed reimplementation of the classic Oratcl API on top of ODPI-C 5.6.4, by Miguel
  Bañón, targeting Tcl 9 with built-in cross-interpreter thread safety and inline LOB
  fetching. See [TODO.md](TODO.md) Story 11.

## See also

- [ADOPTERS.md](ADOPTERS.md) for known production users of Oratcl.
- [TODO.md](TODO.md) for current and planned work.
- [ChangeLog](ChangeLog) and [ChangeLog.2003](ChangeLog.2003) for detailed version-by-version
  changes.
