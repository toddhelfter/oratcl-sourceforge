# Oratcl TODO

**Current test status**: 189 passed, 0 failed, 4 skipped (NLS mismatch)

## Story 1: Rewrite oralob using OCI C API

Replace the current PL/SQL-based oralob implementation with direct OCI C calls.

The current approach wraps `DBMS_LOB` PL/SQL procedures via `oraplexec`, which introduces:
- VARCHAR2 size limits on blob piece sizes (32767 max, 16383 after hex encoding)
- Implicit type conversion issues with newer Oracle versions (e.g., ORA-01460 on Oracle 23c)
- Hex encoding overhead for blob write/writeappend (`binary scan $str H* str` + `HEXTORAW`)
- Extra round-trips through the PL/SQL engine

A native C implementation using OCI LOB functions (`OCILobRead2`, `OCILobWrite2`, `OCILobTrim2`, etc.) would eliminate these issues and provide direct binary data handling without conversion.

## Story 2: Fix arraydml with Oracle 23c

**FIXED** — arraydml-1.1 and arraydml-1.5 failed with `ORA-24338: statement handle not executed` when reparsing a SELECT on the same statement handle after array DML insert. Oracle 23c no longer allows this. Fixed by using a separate statement handle for the SELECT query (matching the pattern already used in arraydml-1.4).

## Story 3: Deprecate `oraconfig unicode` for Tcl 9

**RESOLVED** — The `oraconfig $stm unicode true` option used UCS-2 encoding via `Tcl_GetUnicodeFromObj`/`Tcl_NewUnicodeObj`, which is broken in Tcl 9 (changed `Tcl_UniChar` from 2 bytes to 4 bytes).

**Resolution**: With Tcl 9 + `NLS_LANG=AL32UTF8`, unicode "just works" through the default UTF-8 code path:
- Tcl 9 strings are always UTF-8 internally
- `NLS_LANG=AL32UTF8` tells OCI the client encoding is UTF-8
- `Tcl_GetStringFromObj` / `Tcl_NewStringObj` handle UTF-8 transparently
- No `oraconfig unicode true` needed

The `unicode` config option now prints a deprecation warning if set to true. Tests updated to use the default path.

## Story 4: GitHub ↔ SourceForge release integration

Wire up SourceForge's GitHub release integration so new GitHub releases are automatically mirrored to SourceForge downloads.

- [ ] Pick the target GitHub repo for the sync (`oratcl-sourceforge` vs `oratcl-source`)
- [ ] Automatic import: enter the GitHub username/repo at https://sourceforge.net/p/oratcl/admin/ext/import/github-downloads/
- [ ] Add a SourceForge download button into GitHub release notes (checkbox in the same SourceForge integration page)
- [ ] Manual webhook (if automatic setup needs it / as a fallback), on the target GitHub repo under Settings -> Webhooks:
  - Payload URL: `https://sourceforge.net/p/oratcl/files/github_webhook`
  - Content type: `application/x-www-form-urlencoded`
  - Secret: `6178f31bd3fd27aac850a08f4e5e8b8ed3dd964d`
  - Events: only `Release`
- [ ] Verify: refresh the SourceForge admin page for "Integration configured", and confirm the GitHub webhook's `ping` event delivered successfully
