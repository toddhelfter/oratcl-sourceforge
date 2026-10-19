# Known uses of Oratcl

A non-exhaustive list of notable projects and products built on Oratcl.

- **Oracle Enterprise Manager (OEM)** itself, versions 8i/9i era — Oracle's own official
  product documentation states that OraTcl was the scripting language for OEM job and
  event scripts: *"The Tcl Language with OraTcl extensions is used to write the job and
  events scripts"* — see
  [the Oracle8 OEM 1.3.5 manual, mirrored at UMBC](https://portal.cs.umbc.edu/help/oracle8.bak/oem135/A53701_01/scripts.htm#54069).
  See [WIKI.md](WIKI.md) for additional book citations documenting this usage.
- **HP 3PAR System Reporter** — uses Oratcl for Oracle database access. Confirmed: page 3
  of the [System Reporter 2.8 User's Guide](https://www.manualsdir.com/manuals/398299/hp-3par-system-reporter-software.html)
  (Nov 2010) reproduces the Oratcl copyright/license notice verbatim.
- **[HammerDB](https://github.com/TPC-Council/HammerDB)** (formerly HammerOra), by Steve
  Shaw — has used Oratcl for Oracle load-testing/benchmarking workloads for many years.
  HammerDB maintains its own actively-updated fork,
  [HammerDBLtd/Oratcl](https://github.com/HammerDBLtd/Oratcl), with independent Tcl 9
  modernization work. Real-world usage documented in
  [a walkthrough of running TPC-C against Oracle with HammerDB in Docker](https://rammpeter.blogspot.com/2025/11/oracle-db-run-tpc-benchmark-with.html),
  which shows HammerDB's `Oratcl_Init()` loading the Oracle Instant Client directly. In
  Todd Helfter's own "Oratcl User's Guide and Reference" (see
  [doc/Oratcl_Users_Guide_and_Reference.md](doc/Oratcl_Users_Guide_and_Reference.md)), Steve Shaw is quoted directly: *"when I
  looked for the best language to write a load test tool the main requirements were a
  scripted Oracle interface (thread safe) with a multi-threaded capability and only TCL
  and Oratcl met this requirement and as far as I know still do."* HammerOra was already
  an established tool well before GitHub existed: it has its own dedicated chapter
  ("Benchmarking Tools: Hammerora and Swingbench") in *[Pro Oracle Database 10g RAC on
  Linux: Installation, Administration, and Performance](https://www.oreilly.com/library/view/pro-ora-cle/9781590595244/)*
  (Julian Dyke and Steve Shaw, Apress, March 2007).
- Oratcl's initial thread-safety shipped earlier, in version 4.0 (December 2001), funded
  by Dionisios Pothos and Grid Intelligent Systems Ltd, UK (see `CHANGELOG.md`) — Shaw
  and HammerOra (HammerDB's original name) were already using Oratcl at the time and
  needed that thread safety to drive TPC-C and TPC-H benchmark workloads with threaded
  Tcl, simulating many concurrent database clients. Contemporaneous email correspondence
  documents two later, separate episodes of direct collaboration between Shaw and Todd
  Helfter:
  - **March-April 2006** ("Oratcl 4.4 and Threading"): with Intel (Shaw's employer at the
    time, Technical Solutions EMEA) providing remote access to a development/test system,
    and Jeff Hobbs (ActiveState) copied on the exchange, the two tracked down a genuine
    bug surfaced under concurrent multi-threaded use — an uninitialized struct member in
    `oratcl.c` that occasionally matched the LOB type code, causing attempts to free LOB
    locators that didn't exist. Shaw validated the fix directly against Oratcl 4.4 using
    HammerOra's GUI, running thousands of transactions across 10 concurrent users with no
    errors. This lines up with `CHANGELOG.md`'s 2006-03-16 entries fixing a related race
    condition exposed by Tcl 8.5's new per-test threading model in the test suite
    (`tests/oralong.test`). This was Intel providing in-kind technical/infrastructure
    support for debugging a specific bug, not a cash bounty, and is separate from the
    original 4.0 thread-safety work.
  - **October 2017** ("Oratcl Windows Build"): Shaw shared his own working Visual C build
    setup for compiling Oratcl 4.6 on 64-bit Windows — the direct origin of the
    historical `Oratcl46-MSWin32-x64.zip` SourceForge download (see Story 7 in
    `TODO.md`). The two also diagnosed a Windows-only crash in `OCIStmtExecute` under
    multi-threaded use, reproduced directly via HammerDB, and root-caused it to a known
    Oracle client bug (not an Oratcl bug), worked around via a `sqlnet.ora` setting. Shaw
    noted he'd done similar from-scratch Windows builds, never released, for the other
    database Tcl extensions HammerDB grew to support.
- **ActiveState**, via **ActiveTcl** — bundled/distributed Oratcl through its "teapot" Tcl
  package repository (confirmed by Jeff Hobbs in the September 2017 email thread above),
  making it readily installable alongside the rest of ActiveTcl's package set rather than
  requiring a separate build. ActiveTcl also bundled Tcl's **Thread** extension (the
  package that actually creates OS-level Tcl threads/interpreters — without it, Tcl is
  single-threaded per interpreter), which is what Oratcl's thread-safety feature
  (shipped in 4.0, December 2001) exists to be used *with*. A contemporaneous October 2006
  email (Zoran Vasiljevic to Jeff Hobbs on the `activetcl-dev` mailing list, re: building
  Thread 2.6.4 for the ActiveTcl 8.4.14/8.5 beta release) documents this Thread-extension
  maintenance as an active, ongoing part of ActiveTcl's release process at the time —
  the same release vehicle that carried Oratcl. Together, ActiveTcl was effectively the
  standard distribution channel that made "thread-safe Oratcl" (as used by HammerOra/
  HammerDB, see above) practically usable without a from-source build.
- **[tdbc_oratcl](https://fossil.sowaswie.de/tdbc_oratcl/home)**, by Joerg Mehring
  (Copyright 2018 SESAM GmbH / 2023 MehrDV) — a BSD-3-licensed TDBC driver (Tcl's standard
  `tdbc` database API, the Tcl analog of ODBC/JDBC/DBI) built on top of classic Oratcl
  4.5/4.6, letting Oracle be accessed through the uniform TDBC interface. Versions 0.1
  through 0.8, actively developed on a self-hosted Fossil instance. Three TclOO classes
  (`connection`/`statement`/`resultset`) delegate to `oralogon`/`oraopen`/`oraparse`/
  `orabind`/`oraexec`/`orafetch`/`oracols`/`oramsg`/`oracommit`/`oraroll`/`oraclose`/
  `oralogoff`/`oraconfig`. A possible bug was spotted while reviewing it: in `columns`,
  `nullable` is derived from `DATA_SCALE` rather than the actual `NULLABLE` column.
- **[Neatware MyrmecoX Studio](http://www.neatware.com/studio/language/tcl/tcl_oratcl.html)**
  — a commercial Tcl IDE that bundles Oratcl as its built-in "Oracle database connector",
  alongside SQLite and ODBC connectors, per
  [Neatware's own product documentation](http://www.neatware.com/studio/language/tcl/).

Know of another project using Oratcl? Open a pull request adding it here.
