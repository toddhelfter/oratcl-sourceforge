# Oratcl TODO

## Story 1: Rewrite oralob using OCI C API

Replace the current PL/SQL-based oralob implementation with direct OCI C calls.

The current approach wraps `DBMS_LOB` PL/SQL procedures via `oraplexec`, which introduces:
- VARCHAR2 size limits on blob piece sizes (32767 max, 16383 after hex encoding)
- Implicit type conversion issues with newer Oracle versions (e.g., ORA-01460 on Oracle 23c)
- Hex encoding overhead for blob write/writeappend (`binary scan $str H* str` + `HEXTORAW`)
- Extra round-trips through the PL/SQL engine

A native C implementation using OCI LOB functions (`OCILobRead2`, `OCILobWrite2`, `OCILobTrim2`, etc.) would eliminate these issues and provide direct binary data handling without conversion.

## Story 2: Fix arraydml with Oracle 23c

arraydml-1.1 and arraydml-1.5 fail with `ORA-24338: statement handle not executed` when fetching after array DML insert. Oracle 23c may have changed how statement handles behave after array DML operations — the handle may need to be re-prepared or a separate cursor used for the SELECT.

## Story 3: Fix unicode test failures with Tcl 9 + Oracle 23c

unicode tests 1.1-1.4 fail — string comparison shows data doesn't round-trip correctly. Likely related to Tcl 9 internal encoding changes (always UTF-8) and/or Oracle 23c NLS behavior. Needs investigation into how bind variables handle multi-byte characters.
