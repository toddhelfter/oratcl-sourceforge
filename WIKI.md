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
Associates (1st Edition, September 1997, ISBN 1-56592-218-2). Tom Poindexter authored the
book's chapters on both `Sybtcl` and Oratcl — see
[his page](https://www.nyx.net/~tpoindex/tcl.html) for more on his own writing and software.

Oratcl is also covered in **"Oracle & Open Source"** by Andy Duncan, published by O'Reilly
(ISBN 0596000189), chapter 4 — see the
[publisher's chapter page](https://www.oreilly.com/library/view/oracle-and-open/0596000189/ch04.html)
or [borrow it on the Internet Archive](https://archive.org/details/oracleopensource0000dunc).

Oratcl's full command set is also documented in **"Tcl/Tk in a Nutshell: A Desktop Quick
Reference"** by Paul Raines and Jeff Tranter (O'Reilly, 1999) — see
[the reference entries starting page 388](https://books.google.com/books?id=0PkWJs1UvJ8C&pg=PA435&dq=Oratcl)
on Google Books.

Oratcl installation/usage is also covered in **"Tcl/Tk: A Developer's Guide"** by Clif Flynt
(2003) — see [page 704 on Google Books](https://books.google.com/books?id=LS0z-FeoEDUC&pg=PA704&dq=Oratcl),
which walks through installing the 2.5 Oratcl extension on UNIX.

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
