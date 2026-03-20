# Oratcl TODO

**Current test status**: 185 passed, 4 failed (unicode 1.1–1.4), 4 skipped (NLS mismatch)

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

## Story 3: Fix unicode mode for Tcl 9 (`Tcl_UniChar` size change)

### Problem

All unicode tests (1.1–1.4) fail. Debug output shows data does not round-trip:
- test 1.3 src = `c727ebe9e9...` (1000 bytes, "Ç'ëéé" x 200)
- test 1.3 res = `c7` (1 byte)

### Root Cause

Tcl 9 changed `Tcl_UniChar` from **2 bytes** (UCS-2) to **4 bytes** (UTF-32). The Oratcl C code uses `OCI_UCS2ID` (charset 1000 = UCS-2, 2-byte encoding) but interfaces with Tcl via `Tcl_GetUnicodeFromObj()` and `Tcl_NewUnicodeObj()`, which now produce/consume 4-byte characters.

**On bind** (`orabind.c`): `Tcl_GetUnicodeFromObj` returns an array of 4-byte `Tcl_UniChar`. The code copies these raw bytes and tells Oracle the charset is UCS-2 (2-byte). Oracle misinterprets the data.

**On fetch** (`oratcl.c`): Oracle returns UCS-2 (2-byte) data. `Tcl_NewUnicodeObj` interprets each 4-byte chunk as one character, reading 2 bytes of real data + 2 null bytes per character. The null bytes cause early string termination (explaining the single `c7` byte result).

### Affected Code

- `generic/orabind.c`: `Tcl_GetUnicodeFromObj`, `memcpy` with `sizeof(utext)`, `OCI_BindByName` with `OCI_UCS2ID`
- `generic/oratcl.c`: `Tcl_NewUnicodeObj`, `OCI_DefineByPos` with `OCI_UCS2ID`, fetch value pointer arithmetic using `sizeof(utext)`
- `generic/oratclTypes.h`: `typedef unsigned short utext` (2 bytes) vs Tcl 9 `Tcl_UniChar` (4 bytes)

### Possible Fix Approaches

1. **Add UCS-2 ↔ UTF-32 conversion layer**: Keep OCI in UCS-2 mode. On bind, convert 4-byte `Tcl_UniChar` array → 2-byte UCS-2 array before sending to OCI. On fetch, convert 2-byte UCS-2 array from OCI → 4-byte `Tcl_UniChar` array before calling `Tcl_NewUnicodeObj`. Handles surrogate pairs if needed.

2. **Switch to UTF-8 mode**: When `unicode` is set, instead of UCS-2, use `AL32UTF8` charset with OCI and standard `Tcl_GetStringFromObj`/`Tcl_NewStringObj` (Tcl 9 strings are always UTF-8 internally). This is the simplest approach but changes the wire encoding.

3. **Conditional compilation**: Use `#if TCL_UTF_MAX > 3` (or check `sizeof(Tcl_UniChar)`) to select the right code path for Tcl 8 vs Tcl 9.
