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
  - Secret: `REDACTED-ROTATE-THIS-SECRET`
  - Events: only `Release`
- [ ] Verify: refresh the SourceForge admin page for "Integration configured", and confirm the GitHub webhook's `ping` event delivered successfully

## Story 5: GitHub-compatible documentation

Most of the project's documentation predates Markdown/GitHub (`doc/oratcl.html`, `doc/oratcl.man`, `doc/oratcl.txt`, plain-text `README`/`INSTALL`/`CHANGES`/`ChangeLog`, `COPYRIGHT`/`license.terms`), so `oratcl-sourceforge`'s GitHub "About" panel currently shows no description, no recognized README/License, no topics, 0 stars/watchers.

- [x] Write a proper `README.md` (GitHub-flavored Markdown) synthesized from the existing `doc/oratcl.html`, `oratcl.man`, `oratcl.txt`, `README`, and `INSTALL`, across `oratcl-sourceforge` and its branches — see [oratcl-sourceforge#1](https://github.com/toddhelfter/oratcl-sourceforge/pull/1) (pending merge to `main`)
- [x] Add a GitHub-recognized `LICENSE` file derived from `COPYRIGHT`/`license.terms` so the License badge resolves — same PR; note GitHub's detector matches it as "Other" (not an exact SPDX template), since the original historical license text was preserved as-is
- [x] Set the repo description and topics (e.g. `tcl`, `oracle`, `oci`, `database`) on GitHub — done: "Tcl extension providing access to Oracle Database via OCI (Oracle Call Interface)", topics: tcl, oracle, oci, database, oracle-database, tcl-extension
- [x] Add `ADOPTERS.md` (linked from `README.md`, not inlined there) listing notable projects/products built on Oratcl — see [oratcl-sourceforge#1](https://github.com/toddhelfter/oratcl-sourceforge/pull/1) (pending merge to `main`):
  - HP 3PAR System Reporter ([user's guide reference](https://www.manualsdir.com/manuals/398299/hp-3par-system-reporter-software.html), System Reporter 2.8, Nov 2010) — **confirmed**: page 3 of that manual reproduces the Oratcl copyright/license notice verbatim ("Copyright (c) 2000-2005 Todd M. Helfter... Permission to use, copy, modify, distribute, and sell this software..."), i.e. the exact `license.terms` text, though dated 2000-2005 vs. our `license.terms`'s 2000-2017 — worth noting as a data point on the license's copyright year history
  - HammerOra / HammerDB (Steve Shaw) — used Oratcl for many years; see Story 9 for the HammerDB fork
  - Steve Shaw and Intel sponsored a bounty to make Oratcl thread-safe
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

## Story 8: Seamless/inline LOB handling (replace the PL/SQL-wrapper mindset)

`oralob` (original) wraps `DBMS_LOB` PL/SQL procedures via `oraplexec`, and `oralob2`
(added in 5.0) reads LOBs directly via `OCILobRead2` — but both are still separate,
explicit commands the caller must invoke *in addition to* the normal fetch path. Other
OCI-based language bindings have figured out how to make LOB columns "just work" inline
as part of a normal query result, the same as any `VARCHAR2`/`NUMBER` column, with no
special-case API. This has always felt like a weak point in Oratcl's design (simple to
build at the time, but not the right model) and is worth properly solving rather than
continuing to add parallel LOB commands.

- [ ] Research how other OCI consumers handle LOB columns inline during normal fetch (e.g.
  `cx_Oracle`/`python-oracledb`, Perl `DBD::Oracle`, PHP `oci8`, Oracle's own OCCI/Pro*C
  patterns) — likely centered on `OCIDefineByPos` with `SQLT_CLOB`/`SQLT_BLOB` and a LOB
  locator descriptor (`OCI_DTYPE_LOB`), read via `OCILobRead2` at/after fetch time
- [ ] Design how a LOB locator would flow through Oratcl's existing column/row pipeline
  (`Oratcl_ColAlloc`/`Oratcl_ColAppend`/`orafetch`) so LOB values appear directly in the
  fetched row like any other column
- [ ] Decide the read strategy for large LOBs within a row-oriented fetch loop (full read
  vs. size-capped vs. streaming/piecewise), and how that interacts with `oraconfig`
  options (e.g. existing `lobpsize`)
- [ ] Decide what happens to `oralob`/`oralob2` once inline fetching exists — likely kept
  for explicit/manual control, with inline fetching as the new default/opt-in behavior
- [ ] This is a research/design story before implementation — scope out a concrete plan
  once the above is understood

## Story 9: Reconcile fixes with the sm-shaw/Oratcl (HammerDB) fork

HammerDB (now at [TPC-Council/HammerDB](https://github.com/TPC-Council/HammerDB)) still
uses Oratcl for Oracle connectivity, via a dedicated, actively-maintained fork by Steve
Shaw: [sm-shaw/Oratcl](https://github.com/sm-shaw/Oratcl) (forked independently from an
SVN export in 2022, last pushed 2025-02-24). That fork has done its own separate Tcl 9
modernization work in parallel with ours, so there's likely useful fixes to pull in both
directions.

- [ ] Compare `sm-shaw/Oratcl`'s Tcl 9 port approach against ours — notably commit
  `e4ec059` "Fix segfault in oraparse on Linux if utf8 not used in config", which
  redefines `ub4` as `Tcl_Size` in `oratypes.h`; check whether we're exposed to the same
  bug and whether our `e487666` (`Tcl_Size` type mismatch fix) already covers it
  differently
- [ ] Review their other Tcl 9 commits (`7fc9de3` Windows build, `4a19fc0` compiler
  warnings, `73f2726` initial Tcl 9 update) for anything worth adopting
- [ ] Track down where/how the historical Intel-sponsored thread-safety work (bounty via
  Steve Shaw) actually landed — confirm whether it's already reflected in the mainline
  4.x branches we imported from SourceForge, or only exists in Shaw's fork history
  - Note: Tcl threading support (`--enable-threads`) is a compile-time option, not a
    given — any thread-safety work needs to account for Oratcl being built against both
    threaded and non-threaded Tcl, and the corresponding OCI environment initialization
    mode (`OCI_THREADED` vs. not) needs to match how Tcl itself was built
- [ ] Consider reaching out to Steve Shaw directly, given the shared lineage and
  HammerDB's real-world dependency on Oratcl, to coordinate/share fixes going forward

## Story 10: Copyright year was bumped per-release — update it for 5.0

The copyright end-year in `license.terms`/`COPYRIGHT` was updated at each release over
the project's history, not left static:

| Branch | Copyright notice |
|---|---|
| `scriptics-sc-1-0-branch` / `oratcl-3-0-branch` | `Copyright 1993 Tom Poindexter and U S WEST Advanced Technologies, Inc.` (no Helfter year range yet) |
| `oratcl-4-3-branch` | `Copyright (c) 2000-2004 Todd M. Helfter` |
| `oratcl-4-5-branch` | `Copyright (c) 2000-2005 Todd M. Helfter` |
| `oratcl-4-6-branch` | `Copyright (c) 2000-2017 Todd M. Helfter` |

The HP 3PAR System Reporter manual (Story 5) reproduces the `2000-2005` notice, matching
whatever Oratcl version it was bundled with at the time — confirming the pattern that the
copyright year tracked the release it shipped with, not a single fixed range.

Our current 5.0 line (`license.terms`, `COPYRIGHT`, and the new root `LICENSE` copy)
inherited `2000-2017` unchanged from 4.6 — it was never bumped for 5.0.

- [x] Update `license.terms`, `COPYRIGHT`, and `LICENSE` (root, on `oratcl-5-0-branch`) to
  `Copyright (c) 2000-2026 Todd M. Helfter` for the 5.0 release — done in both
  `oratcl-source` (`main`) and `oratcl-sourceforge` (`oratcl-5-0-branch`); `COPYRIGHT`
  itself doesn't carry a year, so only `license.terms`/`LICENSE` needed the bump
- [x] Apply this on both `oratcl-source` and `oratcl-sourceforge`'s `oratcl-5-0-branch`
  (same files need updating in both places until/unless one repo is retired)
- [ ] Going forward, bump the end-year again at each future release, matching the
  historical pattern

## Story 11: Learn from bagnongithub/oratcl (ODPI-C reimplementation)

Discovered [bagnongithub/oratcl](https://github.com/bagnongithub/oratcl) (doc site:
https://bagnongithub.github.io/oratcl/), by Miguel Bañón — a full, independent, MIT-licensed
reimplementation of the classic Oratcl API as "Oratcl 9.1", built on **ODPI-C 5.6.4**
instead of raw OCI, targeting Tcl 9. Actively maintained (commits through Aug 2026). This
isn't the HammerDB fork (Story 9) — a separate, unrelated derivative work — but it directly
and substantially overlaps with two of our open stories:

- **Solves Story 8 (inline LOB handling)** via an `inlineLobs` connection config option:
  when enabled, `orafetch` returns raw LOB data instead of LOB handles, transparently.
  Worth studying this design (and its `oralob size|read|write|trim|close` fallback API for
  when `inlineLobs` is off) as a reference before designing our own approach.
- **Solves a mature form of Story 9's thread-safety goal**: one global ODPI context per
  process, per-interpreter isolated handle registries, cross-interpreter connection
  "adoption" (sharing a physical `dpiConn*` via refcounted shared records + a per-connection
  operation gate that serializes all access), a persistent async worker thread pool with
  orphan-safe teardown, and behavioral-policy sync (autocommit, fetch sizes, failover
  policy) across adopters.

- [ ] Review the full `doc/oratcl.html`/`oratcl.n` reference and source at
  `bagnongithub/oratcl` in depth, particularly the per-connection "gate" and connection
  adoption mechanism, as prior art for Story 9
- [ ] Review the `inlineLobs` implementation as prior art for Story 8
- [ ] Note the architectural difference: this reimplementation drops raw OCI entirely in
  favor of ODPI-C (Oracle's own open-source driver layer, also used under the hood by
  `python-oracledb`/`node-oracledb`) — consider whether our codebase should ever consider
  the same move, as a separate/future decision from the LOB and threading work specifically
- [ ] Consider reaching out to Miguel Bañón, given the direct overlap in goals
- [ ] Decide whether/how to reference this project in `ADOPTERS.md` or a "Related
  projects" note in `README.md` (it's a derivative/alternative implementation, not a
  known *user* of our codebase, so it may deserve its own section rather than living in
  ADOPTERS.md)
