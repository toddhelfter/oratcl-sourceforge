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

## Logos and merchandise

The codebase itself has carried an embedded "OraTcl POWERED" logo for years, exposed via
`::Oratcl::utils::getLogo` (`library/oratcl_utils.tcl`), stored as hex-encoded GIF data.
It's extracted here as an actual image asset:

![OraTcl POWERED logo](doc/images/oratcl-powered-logo.gif)

Separately, Tcl conferences in the 1990s had their own promotional merchandise — Poindexter's
site includes photos of a ["Sybtcl/Oratcl: Digging Data for Tcl/Tk" fanny pack](https://www.nyx.net/~tpoindex/tcl-wear/sybtcl-oratcl-pack.html)
and a matching ["Sybtcl/Oratcl: Digging Data" logo hat](https://www.nyx.net/~tpoindex/tcl-wear/sybtcl-oratcl-hat.html)
(reusing "Sammy the Steam Shovel" line art from a tee shirt and watch), both branded with
"Talus Technologies, Inc.", distinct from the logo above but a fun artifact of the same era
(see [his Tcl-Wear page](https://www.nyx.net/~tpoindex/tcl.html) generally for more Tcl
conference swag history). Poindexter sent Helfter one of these hats personally — Helfter
still has it.

## Ownership transfer (1999): Todd Helfter

Todd Helfter contributed most of the patches for Oratcl 2.7. Poindexter transferred
ownership and maintenance of the project to Helfter in 1999. Helfter has authored every
release from 3.0.1 onward — 3.1, 3.2, 3.3, 4.0, 4.1, 4.3, 4.4, 4.5, 4.6 (the last SVN trunk
state, 2017), and the current 5.0.

## Enterprise usage and minimum Tcl version (2006)

Contemporaneous email correspondence (January–February 2006) documents Steve May, a Tcl
consultant who had used Oratcl on an Oracle 8i project at **Computerized Processes
Unlimited (CPU) LLC** roughly four years earlier (and also worked with Tcl extensively at
**AspenTech**, both companies that got ActiveTcl builds directly from Jeff Hobbs),
reaching out about upgrading a client from Oracle 8i to 10i and asking the minimum Tcl
version Oratcl 4.3 required. Jeff Hobbs initially guessed "8.3, and possibly as early as
8.1," but Todd Helfter — the actual maintainer — gave the definitive answer directly:
*"Oratcl relies heavily on Tcl_Obj, I know for certain it will compile/run with Tcl 8.3.
Earlier than that, no dice."* Todd also mentioned being "available for contract
programming for special situations," documenting an informal paid-consulting dimension to
the project's maintenance model, separate from the various sponsored bug-fix/thread-safety
work documented elsewhere (see `ADOPTERS.md`).

A March 2006 email to Jeff Hobbs documents Todd hitting a genuine Tcl core limitation
while implementing direct SQL access to Oracle LOB columns for the Oratcl 4.4 candidate
("one of the most requested features of Oratcl"): `Tcl_DString`-based values beyond
roughly 1.2GB (`Tcl_ConvertCountedElement`/`tclUtil.c`) caused a segfault, traced to
signed-`int`-based size limits baked into the `Tcl_DString` API itself. Hobbs confirmed
this was an inherent API restriction, not an Oratcl bug: *"the maximum size is signed int,
based on restrictions in how the APIs were written. You may find that you can construct
something larger, but it may not be 'sized' right in all occurrences that use it."* This
is a direct historical precursor to the exact class of problem Tcl 9's `Tcl_Size` type
(signed `ptrdiff_t`, able to address far beyond 32-bit `int` limits) was designed to fix —
twenty years before Oratcl's own Tcl 9 port tackled the same category of size-type issue
throughout the codebase (see `CHANGELOG.md`'s 2026-02-17 entries).

A November 2007 email thread with Hobbs, during Todd's work adding Unicode database
support to Oratcl (matching `CHANGELOG.md`'s 2007-10-29 and 2007-11-24 entries adding the
`oraconfig unicode` flag and unicode processing to `orabind`/`orafetch` — the email is
dated the day after the latter commit), discusses detecting whether a `Tcl_Obj` genuinely
needs Unicode representation versus plain ASCII. Hobbs sketched a possible Tcl core
addition (`TclStringObjIsAscii` in `tclStringObj.c`) partly in response to this exchange,
noting "it's not in the core at this time, but it could be added... perhaps you have
better supporting cases?" — Oratcl's real-world Unicode-handling needs informing a
Tcl-core API design discussion, not just consuming an existing one.

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
Reference"** by Paul Raines and Jeff Tranter (O'Reilly Media, Inc., March 25, 1999, 456
pages) — its own publisher description lists "Oratcl, SybTcl, and Tclodbc" among the
extensions covered, alongside core Tcl/Tk, Expect, [incr Tcl]/[incr Tk], Tix, TclX, and
BLT — see [the reference entries starting page 388](https://books.google.com/books?id=0PkWJs1UvJ8C&pg=PA435&dq=Oratcl)
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

Oratcl's role in Oracle Enterprise Manager (OEM) job/event scripting is confirmed by
**official Oracle documentation itself**: the Oracle8 OEM 1.3.5 manual's "Jobs and Events
Scripts" chapter states plainly, *"The Tcl Language with OraTcl extensions is used to write
the job and events scripts"* — see
[the chapter, mirrored at UMBC](https://portal.cs.umbc.edu/help/oracle8.bak/oem135/A53701_01/scripts.htm#54069).
This is also documented across several Oracle-focused books:

- **"Oracle Enterprise Manager 101"** by Lars Bo Vanting and Dirk Schepanek (2002), page
  100 — using the `OraTcl` verb `ORAREPORTEVENT` from within a Tcl script for event
  handling — see [page 100 on Google Books](https://books.google.com/books?id=VcdTaSqbxxoC&q=Oratcl&dq=Oratcl).
- **"Everyday Oracle DBA"** by April Wells (2006), page 255 — OEM job scripts submitted
  via the "Run TCL" job task use OraTcl — see
  [page 255 on Google Books](https://books.google.com/books?id=fd5QAAAAMAAJ&q=Oratcl&dq=Oratcl).
- **"Oracle9i Web Development"** by Bradley D. Brown (2001), page 914 — OEM job/event
  scripts using OraTcl extensions for startups, shutdowns, and backups — see
  [page 914 on Google Books](https://books.google.com/books?id=2odwtDYA-TwC&q=Oratcl&dq=Oratcl).

Oratcl is mentioned alongside `sybtcl` and `odbctcl` in a (likely network/SNMP management)
book by **Dave Zeltserman and Gerard Puoplo** (1998), page 406, as a database-scripting
option in a broader network tooling context — see
[page 406 on Google Books](https://books.google.com/books?id=V4Y_AQAAIAAJ&q=Oratcl&dq=Oratcl).

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

**Origin of the idea (2017):** per contemporaneous email correspondence, Todd first raised
the question of converting Oratcl from CVS to Git nearly a decade before it actually
happened — on September 11, 2017, reaching out to former ActiveState Tcl core developers
Jeff Hobbs and Andreas Kupries (both had since moved on, Hobbs independently and Kupries to
SUSE/MicroFocus) for help, motivated in part by wanting to add connection-handling
improvements for Oracle 12c and its new container database (CDB/PDB) architecture. Kupries
identified Roy Keene as the person with the actual hands-on experience doing these kinds of
Tcl-ecosystem CVS/SVN-to-git conversions. The same email thread shows Todd separately asking
about getting Oratcl included in ActiveTcl; Hobbs confirmed Oratcl was already listed in
ActiveState's "teapot" Tcl package repository — which explains why `teapot.txt`/
`teapot.txt.in` (ActiveState teapot package metadata, `Meta as::author`, `Meta as::origin`,
etc.) are still present in the build system today, auto-generated on every build.

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

## Forks and alternative implementations

Forks of Oratcl's own codebase and independent reimplementations of its command API (as
distinct from projects that merely depend on Oratcl as a library — those are "adopters",
see [ADOPTERS.md](ADOPTERS.md)):

- [HammerDBLtd/Oratcl](https://github.com/HammerDBLtd/Oratcl) — HammerDB's own
  actively-maintained fork (originally `sm-shaw/Oratcl` by Steve Shaw, later transferred to
  the HammerDB GitHub organization), with its own independent Tcl 9 modernization work. See
  [TODO.md](TODO.md) Story 9.
- [bagnongithub/oratcl](https://github.com/bagnongithub/oratcl) — an independent,
  MIT-licensed reimplementation of the classic Oratcl API on top of ODPI-C 5.6.4, by Miguel
  Bañón, targeting Tcl 9 with built-in cross-interpreter thread safety and inline LOB
  fetching. See [TODO.md](TODO.md) Story 11. Notably, this isn't his first contribution to
  Oratcl: `CHANGELOG.md` credits a "Miguel Bagnon" with several classic Oratcl patches back
  in 2002-2003 (compiler warning fixes, improved OCI error-info checking, an `oraparse`
  async-parsing bugfix) — almost certainly the same person, decades before building his own
  independent reimplementation.
- [OCI\*ML](https://github.com/gaiustech/ociml) by Gaius Hammond — an **OCaml** (not Tcl)
  OCI binding whose own GitHub description reads "Oracle OCI binding for OCaml based on
  OraTcl", and whose README states it's "a higher level library patterned after OraTcl...
  as much as possible the commands do the same things". Command names mirror Oratcl's
  almost exactly (`oralogon`, `oralogoff`, `oraopen`, `oraclose`, `oraparse`, `orabind`,
  `oraexec`, `oracommit`, `oraroll`, `orafetch`/`orafetchall`), adapted to OCaml's type
  system — a cross-language tribute rather than a fork. Its
  [manpage](https://gaiustech.github.io/ociml/manpage.html) includes a formal
  acknowledgement: *"With thanks to the [OraTcl project](http://oratcl.sourceforge.net/)"*.
  Last active 2016.

## See also

- [ADOPTERS.md](ADOPTERS.md) for known production users of Oratcl.
- [TODO.md](TODO.md) for current and planned work.
- [CHANGELOG.md](CHANGELOG.md) for detailed version-by-version changes (converted from the
  original plain-text `ChangeLog`/`ChangeLog.2003`, now removed).
