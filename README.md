# Oratcl

Oratcl is a [Tcl](https://www.tcl-lang.org/) extension that provides access to an Oracle
Database server via the Oracle Call Interface (OCI). It adds Tcl commands to log in to an
Oracle server, send SQL or PL/SQL, read results back as Tcl lists, manage transactions, and
work with LOBs — without requiring any Oracle-side PL/SQL wrappers for the common cases.

Oratcl predates Perl's DBI and was inspired by similar tools written for Perl (`sybperl`,
`oraperl`), though it was written from scratch rather than ported from either. It was also
influenced by Tom Poindexter's earlier `Sybtcl`.

> **Status:** version 5.0, ported to Tcl 9 and verified against Oracle 23c, with the
> Oracle 23c/Tcl 9 compatibility and security hardening work tracked in [TODO.md](TODO.md).

## Features

- Multiple simultaneous connections to the same or different Oracle servers
- Send SQL or anonymous PL/SQL blocks to the server
- Row caching for efficient fetches; results returned as Tcl lists
- Cursor variables returned from PL/SQL (Oracle 7.2+)
- User-defined NULL value substitution
- Stored procedure calls with return value access
- Column name/length/datatype introspection (`oradesc`)
- Oracle message/error code feedback
- LOB (CLOB/BLOB) read/write, including a native OCI-based implementation (`oralob2`,
  added in 5.0) alongside the original PL/SQL-wrapper-based implementation (`oralob`)
- Commit / rollback / autocommit control
- TAF (Transparent Application Failover) callback support
- Asynchronous (non-blocking) execution mode

## Quick start

```tcl
package require Oratcl
package require -exact Oratcl 5.0

set lda [oralogon scott/tiger@mydb]
set stm [oraopen $lda]
oraparse $stm "select ename, sal from emp where deptno = :dept"
orabind $stm dept 10
oraexec $stm
while {[orafetch $stm row] == 0} {
    puts $row
}
oraclose $stm
oralogoff $lda
```

### Command reference (core)

| Command | Purpose |
|---|---|
| `oralogon` | Connect to an Oracle server |
| `oralogoff` | Disconnect |
| `oraopen` / `oraclose` | Open/close a statement handle |
| `oraparse` | Parse SQL or PL/SQL on a statement handle |
| `orabind` | Bind a value to a placeholder |
| `oraexec` | Execute a parsed statement |
| `orafetch` | Fetch the next row |
| `orasql` | Parse + bind + execute + fetch in one call |
| `orabindexec` | Bind and execute array DML |
| `oraplexec` | Execute PL/SQL and fetch output binds |
| `oracols` | Describe result-set columns |
| `oradesc` | Describe a table's columns |
| `oracommit` / `oraroll` / `oraautocom` | Transaction control |
| `orabreak` | Cancel a long-running operation |
| `oraconfig` | Get/set per-handle configuration |
| `orainfo` | Logon/statement handle introspection |
| `oramsg` | Last Oracle error message/code |
| `::oratcl::longread` / `::oratcl::longwrite` | Read/write `LONG` columns |

The full command reference (syntax, arguments, return values) is in
[doc/oratcl.html](doc/oratcl.html) (also available as an nroff man page at
[doc/oratcl.n](doc/oratcl.n)). See [doc/FAQ.html](doc/FAQ.html) for platform build notes,
SQL*NET/`tnsnames.ora` configuration, and date-format troubleshooting.

## Building

```sh
./configure --prefix=/same/prefix/as/tcl --exec-prefix=/same/exec-prefix/as/tcl
make
make install
```

Oratcl is built against a working Tcl installation (uses `tclConfig.sh`) and an Oracle
client/SDK (OCI headers and libraries, e.g. Oracle Instant Client). See [INSTALL](INSTALL)
for the full set of `configure` options and platform-specific notes.

## Project history

Oratcl's history goes back to 1999, first hosted on SourceForge under CVS as part of the
Scriptics/Ajuba Tcl tooling, later converted to SourceForge SVN, and now migrated to Git.
The full commit-by-commit history (1999–2017, versions 1.0 through 4.6) along with every
historical release branch and tag is preserved at
[toddhelfter/oratcl-sourceforge](https://github.com/toddhelfter/oratcl-sourceforge). The
5.0 development line (Tcl 9 port, Oracle 23c compatibility, security fixes) is grafted
directly onto that real history on the `oratcl-5-0-branch`.

See [ChangeLog](ChangeLog) and [ChangeLog.2003](ChangeLog.2003) for the detailed history of
changes, and [TODO.md](TODO.md) for current and planned work.

## Bug reports / contributing

Please open an issue or pull request on GitHub. When reporting a problem, please include:

- Oratcl version
- Tcl/Tk version
- Oracle server and OCI client library version
- Operating system
- `configure` switches used (see `config.status`)
- Compiler used
- A minimal SQL/Oratcl reproduction, and relevant table/view/procedure definitions

## License

Oratcl is Copyright (c) 2000-2017 Todd M. Helfter and is released under a permissive
BSD-style license — see [LICENSE](LICENSE) for the full text.
