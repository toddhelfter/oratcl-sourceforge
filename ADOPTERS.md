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
  which shows HammerDB's `Oratcl_Init()` loading the Oracle Instant Client directly.
- Steve Shaw, together with Intel, sponsored a bounty to make Oratcl thread-safe.
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
