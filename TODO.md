# Oratcl TODO

**Current test status**: 189 passed, 0 failed, 4 skipped (NLS mismatch)

## Story 4: GitHub ↔ SourceForge release integration

Wire up SourceForge's GitHub release integration so new GitHub releases are automatically mirrored to SourceForge downloads.

- [x] Pick the target GitHub repo for the sync — **`oratcl-sourceforge` is canonical** going forward
- [ ] Automatic import: enter the GitHub username/repo at https://sourceforge.net/p/oratcl/admin/ext/import/github-downloads/
- [ ] Add a SourceForge download button into GitHub release notes (checkbox in the same SourceForge integration page)
- [ ] Manual webhook (if automatic setup needs it / as a fallback), on the target GitHub repo under Settings -> Webhooks:
  - Payload URL: `https://sourceforge.net/p/oratcl/files/github_webhook`
  - Content type: `application/x-www-form-urlencoded`
  - Secret: `REDACTED-ROTATE-THIS-SECRET`
  - Events: only `Release`
- [ ] Verify: refresh the SourceForge admin page for "Integration configured", and confirm the GitHub webhook's `ping` event delivered successfully

## Story 7: Build release packages for multiple platforms

SourceForge downloads need updating: a fresh source `tar.gz` plus new prebuilt binaries for Windows and possibly macOS, matching the current 5.0 source. Historically these were cross-compiled; we don't currently have direct access to all target platforms, so this is broadly scoped pending investigation of what's actually feasible here.

**Current state (as of this writing):** SourceForge's "latest version" default download is still `oratcl45.tar.gz` (293.0 kB, from the 4.5 line) — no 4.6 *source* `tar.gz` was ever published as the default download, even though 4.6 existed on trunk. However, a 4.6 **Windows x64 binary** *was* published and still exists: [`Oratcl46-MSWin32-x64.zip`](https://sourceforge.net/projects/oratcl/files/oratcl/4.6/Oratcl46-MSWin32-x64.zip/download) (95,478 bytes, confirmed live) — so Windows builds for 4.6 did happen, just not a corresponding source release or 32-bit/macOS build (per Todd's own recollection: "I did manage to create a 4.6 win32 download, but never a 64b one" — though the filename itself says x64; this may be a historical mislabeling worth double-checking against the archive's actual binary). (SourceForge note: the "Default Download" per-file checkbox under each file's settings controls which file is served from the `/files/latest/download` link; uncheck it on the old file / check it on the new one when a replacement is ready.)

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

## Story 9: Reconcile fixes with the HammerDBLtd/Oratcl (HammerDB) fork

HammerDB (now at [TPC-Council/HammerDB](https://github.com/TPC-Council/HammerDB)) still
uses Oratcl for Oracle connectivity, via a dedicated, actively-maintained fork now under
HammerDB's own GitHub organization: [HammerDBLtd/Oratcl](https://github.com/HammerDBLtd/Oratcl)
(originally created by Steve Shaw as `sm-shaw/Oratcl` from an independent SVN export in
2022, then transferred to the `HammerDBLtd` org — `sm-shaw/Oratcl` now 301-redirects
there; last pushed 2025-02-24). That fork has done its own separate Tcl 9 modernization
work in parallel with ours, so there's likely useful fixes to pull in both directions.

- [ ] Compare `HammerDBLtd/Oratcl`'s Tcl 9 port approach against ours — notably commit
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
