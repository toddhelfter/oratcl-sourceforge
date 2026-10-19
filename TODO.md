# Oratcl TODO

**Current test status**: 189 passed, 0 failed, 4 skipped (NLS mismatch) (prior environment); **169 passed, 0 failed, 0 skipped** against a live Oracle 23c (XEPDB1) database on Ubuntu/WSL2 with Tcl 9.1.0 — see Story 7

## Story 7: Build release packages for multiple platforms

SourceForge downloads need updating: a fresh source `tar.gz` plus new prebuilt binaries for Windows and possibly macOS, matching the current 5.0 source. Historically these were cross-compiled; we don't currently have direct access to all target platforms, so this is broadly scoped pending investigation of what's actually feasible here.

**Current state (as of this writing):** SourceForge's "latest version" default download is still `oratcl45.tar.gz` (293.0 kB, from the 4.5 line) — no 4.6 *source* `tar.gz` was ever published as the default download, even though 4.6 existed on trunk. However, a 4.6 **Windows x64 binary** *was* published and still exists: [`Oratcl46-MSWin32-x64.zip`](https://sourceforge.net/projects/oratcl/files/oratcl/4.6/Oratcl46-MSWin32-x64.zip/download) (95,478 bytes, confirmed live) — so Windows builds for 4.6 did happen, just not a corresponding source release or 32-bit/macOS build. **Resolved**: this was not a mislabeling — contemporaneous email correspondence (October 2017, "Oratcl Windows Build") confirms Todd Helfter and Steve Shaw collaborated on exactly this: Shaw shared his own working Visual C build setup, and Todd confirmed a genuine working "Tcl 8.6.7/Tk 8.6.7 and Oratcl (head) 4.6 build on 64bit windows" — that's the direct origin of this x64 zip. (SourceForge note: the "Default Download" per-file checkbox under each file's settings controls which file is served from the `/files/latest/download` link; uncheck it on the old file / check it on the new one when a replacement is ready.)

- [x] Produce an updated source release tarball (`oratcl-5.0.tar.gz` or similar) from the final `main`/5.0 tree via `make dist` or equivalent — **done**: fixed the `make dist` rule (was missing `LICENSE`/`COPYRIGHT`/`INSTALL`), verified the resulting `oratcl-5.0.tar.gz` extracts and builds cleanly from scratch
- [x] Investigate Windows cross-compilation options from macOS/Linux (e.g. mingw-w64 toolchain) against an Oracle Instant Client SDK for Windows, matching how prior Windows binaries were built — **confirmed working, no Oracle SDK needed, no MSVC needed**:
  - Chosen over native MSVC since Shaw's own 2017 build setup is confirmed out of date (per Steve Shaw) and MSVC itself isn't readily available; `tclconfig/tcl.m4` already has first-class mingw-w64 cross-compile support built in (auto-detects `x86_64-w64-mingw32-gcc`/`ld`/`ar`/`ranlib`/`windres`), so this reuses the exact same `configure.in`/`Makefile.in` already proven on macOS — no separate `win/makefile.vc`/MSVC system needed
  - Confirmed `TEA_ADD_LIBS([])` is empty and Oratcl only ever loads Oracle's library dynamically at runtime (`LoadLibrary`/`GetProcAddress` on Windows, `dlopen`/`dlsym` elsewhere) — so cross-compiling needs **no real Oracle software at all**, not even for headers (verified: a build against a totally empty placeholder `sdk/include/` directory succeeds)
  - Verified end-to-end (standing in for WSL Ubuntu, using the identical `mingw-w64` GCC toolchain `apt install mingw-w64` would provide): cross-built Tcl 9.0.4 itself from source for Windows (`cd win && ./configure --host=x86_64-w64-mingw32 --enable-64bit && make && make install`), then cross-configured and built Oratcl (`./configure --host=x86_64-w64-mingw32 --with-tcl=<tcl-win-install>/lib --with-oracle-directory=<any dir with an empty sdk/include>`), producing a genuine `tcl9Oratcl50.dll` — confirmed via `objdump`: valid PE32+ x86-64 format, `Oratcl_Init` properly exported (matching Tcl's package-load convention), and its only imports are standard Windows CRT/system DLLs
  - Along the way, found and fixed **two real, previously-undiscovered bugs** in the `__WIN32__` code path, which has apparently never been compiled since the Tcl 9 port (no CI, no `win/` directory exists at all): a missing `int` return type on the `EXTERN Oratcl_Init` declaration (implicit-int is a hard error under modern C), and a local variable literally named `bool` in `oraautocom.c` colliding with the real `bool` keyword/macro now that Tcl 9's headers pull in `<stdbool.h>`
  - **Not yet runtime-tested on an actual Windows machine** — the DLL is structurally verified (format, exports, imports) but needs a real Windows + Tcl 9 + `tclsh` to confirm it actually loads and runs correctly
  - Exact recipe for WSL Ubuntu: `sudo apt install mingw-w64 build-essential`, then cross-build Tcl 9 from source (`win/configure --host=x86_64-w64-mingw32 --enable-64bit`), then `./configure --host=x86_64-w64-mingw32 --with-tcl=<path> --with-oracle-directory=<any placeholder dir with an empty sdk/include>` for Oratcl itself
- [x] Investigate macOS binary builds (native, since we're on macOS) against Oracle Instant Client for macOS (arm64/x86_64), and whether a universal binary is feasible/desired — **confirmed feasible, proof-of-concept built successfully**:
  - `./configure --with-tcl=<tclConfig.sh dir> --with-oracle-directory=<instant client dir>` followed by `make` produces a working `libtcl9Oratcl5.0.dylib` (Mach-O arm64) against Tcl 9.0.2 and Oracle Instant Client 23.3
  - Verified it loads cleanly under `tclsh9.0` (`package require Oratcl`) and registers all expected commands, including the new `oralob2`
  - Set `env(ORACLE_LIBRARY)` to the full path of `libclntsh.dylib` directly when using an Instant Client layout (no `lib/` subdirectory) — the default `$ORACLE_HOME/lib/libclntsh.dylib` lookup only matches a traditional full Oracle Client install layout
  - Along the way, found and fixed a real build-system bug: `oralob2.c` (added in 5.0) was never registered in `configure.in`'s `TEA_ADD_SOURCES`, so every build was silently failing at link time (`undefined symbol _Oratcl_Lob2`) until now
  - Live-DB functional/integration testing intentionally skipped for now — no test database currently available
  - Universal (arm64+x86_64) binary and Intel Mac builds not yet attempted
- [x] Native Linux build and full live-database test run — **done, 100% pass rate, confirms the whole Tcl 9 + Oracle 23c compatibility story end-to-end**: Todd built and ran Oratcl 5.0 on Ubuntu/WSL2 (Tcl 9.1.0, Oracle Instant Client 23.26) against a real, live Oracle 23c XE database (`XEPDB1`), producing `libtcl9Oratcl5.0.so` and running the full `make test` suite — **169 passed, 0 failed, 0 skipped**, including `unicode.test` (5/5, validating Story 3's Tcl 9 UTF-8 resolution) and `arraydml.test` (5/5, validating the Oracle 23c array-DML cursor fix). This is the first real-database verification of the entire 5.0 line, and also retroactively validates the Windows cross-compile approach (same `configure.in`/`Makefile.in`, same zero-Oracle-at-build-time design) since the only difference on Windows is the cross-compiler target.
- [x] Determine which Oracle client/SDK versions to target per platform — **decided**: Oracle 23c client is the standard going forward (matches the Oracle 23c compatibility work already done in 5.0)
- [x] Decide packaging/distribution format per platform — **decided**: both `tar.gz` and `.zip`, matching the already-built artifacts (`oratcl-5.0.tar.gz` for source, `.zip` for platform binaries — `.zip` in particular because Windows doesn't typically have `tar` available). **New consideration**: the 4.5 line was also distributed as RPMs ([`Oratcl-4.5-1.i386.rpm`](https://sourceforge.net/projects/oratcl/files/oratcl/4.5/Oratcl-4.5-1.i386.rpm/download), [`Oratcl-4.5-1.x86_64.rpm`](https://sourceforge.net/projects/oratcl/files/oratcl/4.5/Oratcl-4.5-1.x86_64.rpm/download), 2009) alongside `oratcl45_win.zip`/`oratcl45.tar.gz` — decide whether to resume RPM packaging for 5.0 (would need `rpmbuild` or `fpm`, neither currently installed/attempted)
- [x] Once 5.0 packages are ready, update SourceForge's "Default Download" flag to point at the new tarball/binaries instead of `oratcl45.tar.gz` — **done**, confirmed by Todd
- [x] Wire up the resulting artifacts to the GitHub Releases (feeding Story 4's GitHub→SourceForge sync) once built — **done and verified end-to-end**: [Oratcl 5.0](https://github.com/toddhelfter/oratcl-sourceforge/releases/tag/oratcl-5.0) published with `oratcl-5.0.tar.gz`, `Oratcl50-Darwin-arm64.zip`, and `Oratcl50-Windows-x64.zip` attached; the webhook fired and delivered successfully, confirmed live on SourceForge's Files page under `oratcl-5-0` (the `.` in the GitHub tag `oratcl-5.0` gets normalized to `-` in the SourceForge folder name) — the full GitHub→SourceForge release pipeline (Story 4) works

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

- [x] Compare `HammerDBLtd/Oratcl`'s Tcl 9 port approach against ours — notably commit
  `e4ec059` "Fix segfault in oraparse on Linux if utf8 not used in config", which
  redefines `ub4` as `Tcl_Size` in `oratypes.h`; check whether we're exposed to the same
  bug and whether our `5a30fb7` (`Tcl_Size` type mismatch fix) already covers it
  differently — **done, do not adopt `e4ec059`**:
  - Both projects hit the exact same bug: `generic/oraparse.c`'s `stln` variable, passed
    to `Tcl_GetStringFromObj()`, needs to be `Tcl_Size` under Tcl 9.
  - Ours (`5a30fb7`) retypes just that one local variable at its declaration site —
    surgical, leaves Oracle's real `ub4` OCI type (`unsigned int`, 4 bytes) untouched
    everywhere else.
  - Theirs (`e4ec059`) globally `#define ub4 Tcl_Size` in `oratypes.h`. This incidentally
    "fixes" `stln` too (it's declared `ub4`), but also silently changes `ub4`'s type
    across dozens of real OCI function-pointer parameters (`OCIHANDLEFREE`,
    `OCIINITIALIZE`, `OCITERMINATE`, etc. in `oratclTypes.h`). Oracle's actual
    `libclntsh` library is compiled independently with a true 4-byte `unsigned int ub4`
    baked into its ABI — on 64-bit Linux under Tcl 9, `Tcl_Size` is an 8-byte
    `ptrdiff_t`, so this risks passing wrong-sized arguments to real OCI calls across
    the whole codebase, not just the one case it was meant to fix.
  - Root cause trace: their earlier `4a19fc0` (Oct 2024) cast pointers to
    `(Tcl_Size *)` without resizing the underlying storage (`ub4 *alenp`, `ub4 stln`) —
    itself a latent buffer-overflow; `e4ec059` (Feb 2025) papered over the resulting
    segfault 4+ months later with the blanket macro redefinition instead of fixing the
    specific declarations.
- [x] Review their other Tcl 9 commits (`7fc9de3` Windows build, `4a19fc0` compiler
  warnings, `73f2726` initial Tcl 9 update) for anything worth adopting — **done**:
  - `73f2726` and `4a19fc0` mostly duplicate ground we've already covered (`CONST84`→
    `const`, `Tcl_Obj *CONST`→`*const`, per-variable `Tcl_Size` retyping) — nothing new
    to adopt.
  - `7fc9de3` updates `win/makefile.vc` for Tcl 9 (`tclstub86.lib` → `tclstub.lib`,
    since Tcl 9's stub lib dropped the Tcl-version suffix) — **this exposed a real
    gap**: `oratcl-sourceforge` has no `win/` directory at all, on `main` or on
    `oratcl-4-6-branch`. We currently have zero Windows build support; see Story 7
    (multi-platform release packages) for the follow-up.
- [x] Track down where/how the historical Intel-sponsored thread-safety work (bounty via
  Steve Shaw) actually landed — **done, and corrected**: Oratcl's thread-safety shipped
  in version 4.0 (December 2001), funded by Dionisios Pothos and Grid Intelligent
  Systems Ltd, UK (directly sourced in `CHANGELOG.md`) — Shaw and HammerOra (HammerDB's
  original name) were already using Oratcl at the time and needed that thread safety to
  drive TPC-C/TPC-H benchmark workloads with threaded Tcl, so he was a direct
  beneficiary/motivated user, not the funder of its creation. The "Intel bounty" framing
  in `ADOPTERS.md` was unsubstantiated (no corroborating source found) and has been
  corrected: Intel's real connection was conducting chipset performance testing using
  HammerDB, again depending on — not sponsoring — Oratcl's already-existing thread
  safety.
  - Note: Tcl threading support (`--enable-threads`) is a compile-time option, not a
    given — any thread-safety work needs to account for Oratcl being built against both
    threaded and non-threaded Tcl, and the corresponding OCI environment initialization
    mode (`OCI_THREADED` vs. not) needs to match how Tcl itself was built
- [ ] Consider reaching out to Steve Shaw directly, given the shared lineage and
  HammerDB's real-world dependency on Oratcl, to coordinate/share fixes going forward —
  Todd and Shaw have a long history of exactly this kind of direct collaboration (2006
  threading debugging, 2017 Windows build work, both per contemporaneous email
  correspondence — see `ADOPTERS.md`), so this has real precedent. Worth specifically
  asking whether Shaw still has his working Visual C build setup for Oratcl on Windows
  (see Story 7) and whether the `OCIStmtExecute` Windows threading issue they diagnosed
  in 2017 (an Oracle client bug, not Oratcl's) is relevant to the current 5.0 line.

## Story 13: Decide the fate of legacy Unix platform support (HP-UX, Solaris/SPARC, AIX)

While investigating dead code from the old Windows/MSVC build era (see Story 7), found
that `generic/oratcl.c` still has a dedicated `#if defined(__hpux)` dynamic-loading
branch (`shl_load`/`shl_unload`, HP-UX's pre-`dlopen` API) alongside the standard
`dlopen`/`dlsym` path used everywhere else. No equivalent dedicated code path exists for
AIX or Solaris/SPARC specifically — those use the standard `dlopen` branch — but all
three are platforms the project historically supported and that Todd no longer has
access to test or verify:

- HP-UX: no build attempted since before 2005
- Solaris/SPARC: no access to hardware anymore
- AIX: no build attempted in 20+ years

- [ ] Decide whether to keep the HP-UX `shl_load` branch as-is (low cost to leave,
  untested but also unlikely to be exercised by anyone), or remove it and let HP-UX fall
  back to the standard `dlopen` path (uncertain whether modern HP-UX even still needs
  `shl_load`, or has long since supported plain `dlopen` too — would need someone with
  actual HP-UX access to confirm either way)
- [ ] Decide whether Solaris/SPARC and AIX remain officially "supported" platforms for
  5.0 given no ability to test them, and if so, how to message that (e.g. "best effort,
  untested" in README/Users Guide) vs. formally dropping them
- [ ] If any of these are dropped, update the Users Guide's Solaris chapter accordingly
  (currently untouched, written for Solaris 8/9/10 circa mid-2000s)

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
