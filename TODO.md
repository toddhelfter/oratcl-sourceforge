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

## Story 5: GitHub-compatible documentation

Most of the project's documentation predates Markdown/GitHub (`doc/oratcl.html`, `doc/oratcl.man`, `doc/oratcl.txt`, plain-text `README`/`INSTALL`/`CHANGES`/`ChangeLog`, `COPYRIGHT`/`license.terms`), so `oratcl-sourceforge`'s GitHub "About" panel currently shows no description, no recognized README/License, no topics, 0 stars/watchers.

- [ ] Write a proper `README.md` (GitHub-flavored Markdown) synthesized from the existing `doc/oratcl.html`, `oratcl.man`, `oratcl.txt`, `README`, and `INSTALL`, across `oratcl-sourceforge` and its branches
- [ ] Add a GitHub-recognized `LICENSE` file derived from `COPYRIGHT`/`license.terms` so the License badge resolves
- [ ] Set the repo description and topics (e.g. `tcl`, `oracle`, `oci`, `database`) on GitHub
- [ ] Mine the historical branches/tags (scriptics-sc-* through oratcl-4-6, plus oratcl-source's 5.0 work) for anything worth preserving in the new docs (feature history, platform notes, API changes)
- [ ] Decide whether this applies only to `oratcl-sourceforge` or also `oratcl-source`, depending on which repo remains canonical

## Story 6: Backport 5.0 security fixes (memory guards, buffer overruns) to 4.6

During 5.0 development, security-related issues — memory guards and buffer over-runs — were analyzed and fixed. Several of these aren't tied to the Tcl 9 port and are candidates to backport onto `oratcl-4-6-branch` (last real SVN release line). Identified by reviewing the actual diffs (not just commit titles) of all 25 commits between `a2281e4` and `91e9d74`, including a dedicated second pass for buffer-safety swaps (`sprintf`→`snprintf`, `strcpy`→`strncpy`, bounds/guard checks):

- [ ] `42b4053` — fix script injection and stack buffer overflow in the TAF failover callback (replace `sprintf`+`Tcl_Eval` with `Tcl_EvalObjv`)
- [ ] `afa57a3` — add an upper bound (`MAX_FETCH_ROWS`) on `fetchrows` to prevent integer overflow in `ckalloc` size calculations
- [ ] `5389c9b` — memory guard: scrub password (`memset` before `ckfree`) before freeing the connect string, so credentials don't linger in freed heap memory
- [ ] `c45cfba` — fix a truncated `OCI_AttrGet` call in `oraexec.c` (missing `OCI_ATTR_SQLFNCODE`/`errhp` args) — cherry-pick only this bug fix, not the same commit's unrelated `CONST84`→`const` Tcl 9 cleanup

Two full diff passes (keyword + buffer-safety pattern scan) across all 25 commits found no additional distinct memory-guard/overrun fixes beyond these four. Re-check against your own notes/memory of the 5.0 work in case something was missed, and add any other specific commits you have in mind.

## Story 7: Build release packages for multiple platforms

SourceForge downloads need updating: a fresh source `tar.gz` plus new prebuilt binaries for Windows and possibly macOS, matching the current 5.0 source. Historically these were cross-compiled; we don't currently have direct access to all target platforms, so this is broadly scoped pending investigation of what's actually feasible here.

**Current state (as of this writing):** SourceForge's "latest version" default download is still `oratcl45.tar.gz` (293.0 kB, from the 4.5 line) — no `oratcl46.tar.gz` was ever published, even though 4.6 existed on trunk. (SourceForge note: the "Default Download" per-file checkbox under each file's settings controls which file is served from the `/files/latest/download` link; uncheck it on the old file / check it on the new one when a replacement is ready.)

- [ ] Produce an updated source release tarball (`oratcl-5.0.tar.gz` or similar) from the final `main`/5.0 tree via `make dist` or equivalent
- [ ] Investigate Windows cross-compilation options from macOS/Linux (e.g. mingw-w64 toolchain) against an Oracle Instant Client SDK for Windows, matching how prior Windows binaries were built
- [ ] Investigate macOS binary builds (native, since we're on macOS) against Oracle Instant Client for macOS (arm64/x86_64), and whether a universal binary is feasible/desired
- [ ] Determine which Oracle client/SDK versions to target per platform (note Oracle 23c compatibility work already done in 5.0)
- [ ] Decide packaging/distribution format per platform (zip vs tar.gz, directory layout) consistent with prior SourceForge releases
- [ ] Once 5.0 packages are ready, update SourceForge's "Default Download" flag to point at the new tarball/binaries instead of `oratcl45.tar.gz`
- [ ] Wire up the resulting artifacts to the GitHub Releases (feeding Story 4's GitHub→SourceForge sync) once built
