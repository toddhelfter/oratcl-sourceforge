# Known uses of Oratcl

A non-exhaustive list of notable projects and products built on Oratcl.

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

Know of another project using Oratcl? Open a pull request adding it here.
