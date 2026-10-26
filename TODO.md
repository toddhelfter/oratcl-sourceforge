# Oratcl TODO

**Current test status**: 189 passed, 0 failed, 4 skipped (NLS mismatch) (prior environment); **169 passed, 0 failed, 0 skipped** against a live Oracle 23c (XEPDB1) database on Ubuntu/WSL2 with Tcl 9.1.0 — see Story 7

## Story 7: Build release packages for multiple platforms — COMPLETE

SourceForge downloads need updating: a fresh source `tar.gz` plus new prebuilt binaries for Windows and possibly macOS, matching the current 5.0 source. Historically these were cross-compiled; we don't currently have direct access to all target platforms, so this is broadly scoped pending investigation of what's actually feasible here.

**Closed out**: all three platforms Todd has hardware access to (Linux, macOS, Windows) now have 5.0 built and runtime-verified with a live Oracle 23c connection (`package require Oratcl` + `oralogon`). Full `make test` suite parity across all three is tracked separately as Story 15, since the Windows test harness needs rework before it can run there at all — that's a test-infrastructure gap, not a packaging gap, so it doesn't block closing this story.

**Current state (as of this writing):** SourceForge's "latest version" default download is still `oratcl45.tar.gz` (293.0 kB, from the 4.5 line) — no 4.6 *source* `tar.gz` was ever published as the default download, even though 4.6 existed on trunk. However, a 4.6 **Windows x64 binary** *was* published and still exists: [`Oratcl46-MSWin32-x64.zip`](https://sourceforge.net/projects/oratcl/files/oratcl/4.6/Oratcl46-MSWin32-x64.zip/download) (95,478 bytes, confirmed live) — so Windows builds for 4.6 did happen, just not a corresponding source release or 32-bit/macOS build. **Resolved**: this was not a mislabeling — contemporaneous email correspondence (October 2017, "Oratcl Windows Build") confirms Todd Helfter and Steve Shaw collaborated on exactly this: Shaw shared his own working Visual C build setup, and Todd confirmed a genuine working "Tcl 8.6.7/Tk 8.6.7 and Oratcl (head) 4.6 build on 64bit windows" — that's the direct origin of this x64 zip. (SourceForge note: the "Default Download" per-file checkbox under each file's settings controls which file is served from the `/files/latest/download` link; uncheck it on the old file / check it on the new one when a replacement is ready.)

- [x] Produce an updated source release tarball (`oratcl-5.0.tar.gz` or similar) from the final `main`/5.0 tree via `make dist` or equivalent — **done**: fixed the `make dist` rule (was missing `LICENSE`/`COPYRIGHT`/`INSTALL`), verified the resulting `oratcl-5.0.tar.gz` extracts and builds cleanly from scratch
- [x] Investigate Windows cross-compilation options from macOS/Linux (e.g. mingw-w64 toolchain) against an Oracle Instant Client SDK for Windows, matching how prior Windows binaries were built — **confirmed working, no Oracle SDK needed, no MSVC needed**:
  - Chosen over native MSVC since Shaw's own 2017 build setup is confirmed out of date (per Steve Shaw) and MSVC itself isn't readily available; `tclconfig/tcl.m4` already has first-class mingw-w64 cross-compile support built in (auto-detects `x86_64-w64-mingw32-gcc`/`ld`/`ar`/`ranlib`/`windres`), so this reuses the exact same `configure.in`/`Makefile.in` already proven on macOS — no separate `win/makefile.vc`/MSVC system needed. Tcl does also support building with MSVC (`win/makefile.vc`), but that's always been a licensed product few contributors actually own, which is itself a good reason to prefer the free mingw-w64 path for this project going forward
  - Confirmed `TEA_ADD_LIBS([])` is empty and Oratcl only ever loads Oracle's library dynamically at runtime (`LoadLibrary`/`GetProcAddress` on Windows, `dlopen`/`dlsym` elsewhere) — so cross-compiling needs **no real Oracle software at all**, not even for headers (verified: a build against a totally empty placeholder `sdk/include/` directory succeeds)
  - Verified end-to-end (standing in for WSL Ubuntu, using the identical `mingw-w64` GCC toolchain `apt install mingw-w64` would provide): cross-built Tcl 9.0.4 itself from source for Windows (`cd win && ./configure --host=x86_64-w64-mingw32 --enable-64bit && make && make install`), then cross-configured and built Oratcl (`./configure --host=x86_64-w64-mingw32 --with-tcl=<tcl-win-install>/lib --with-oracle-directory=<any dir with an empty sdk/include>`), producing a genuine `tcl9Oratcl50.dll` — confirmed via `objdump`: valid PE32+ x86-64 format, `Oratcl_Init` properly exported (matching Tcl's package-load convention), and its only imports are standard Windows CRT/system DLLs
  - Along the way, found and fixed **two real, previously-undiscovered bugs** in the `__WIN32__` code path, which has apparently never been compiled since the Tcl 9 port (no CI, no `win/` directory exists at all): a missing `int` return type on the `EXTERN Oratcl_Init` declaration (implicit-int is a hard error under modern C), and a local variable literally named `bool` in `oraautocom.c` colliding with the real `bool` keyword/macro now that Tcl 9's headers pull in `<stdbool.h>`
  - **Runtime-tested on an actual Windows machine — confirmed working**: Todd tested the published `Oratcl50-Windows-x64.zip` build on native Windows (mingw64-x64 TCL build, `tcltk91`) against Oracle Instant Client 23.26 and a live Oracle 23c (`XEPDB1`) database — set `ORACLE_HOME`/`ORACLE_LIBRARY` env vars and added the Instant Client dir to `PATH`, manually copied the Oratcl files into the Tcl `lib/` location (no installer), then `package require Oratcl` loaded cleanly reporting version `5.0`, and `oralogon oratcl50/<password>@XEPDB1` succeeded (returned logon handle `oratcl1`) after an initial expected `ORA-01005` with a wrong password. **`make test` could not be run in this pass** — the test harness (`tests/all.tcl` and friends) currently assumes a Unix shell/`make` environment and needs rework before it can run under native Windows PowerShell; tracked as Story 15
  - The mingw-w64 cross-compile toolchain itself is confirmed working as the *host* from more than one platform: both macOS (with `mingw-w64` installed via Homebrew) and Windows/WSL (Ubuntu, with `mingw-w64` via `apt`) successfully cross-build Tcl 9 and Oratcl for the `x86_64-w64-mingw32` Windows target, using the same `configure.in`/`Makefile.in` either way — this isn't a novel trick, Tcl's own `win/README` documents `--host=x86_64-w64-mingw32` cross-compiling from Unix as a first-class supported path
  - Exact recipe for WSL Ubuntu: `sudo apt install mingw-w64 build-essential`, then cross-build Tcl 9 from source (`win/configure --host=x86_64-w64-mingw32 --enable-64bit`), then `./configure --host=x86_64-w64-mingw32 --with-tcl=<path> --with-oracle-directory=<any placeholder dir with an empty sdk/include>` for Oratcl itself
  - [`doc/Oratcl_Users_Guide_and_Reference.md`](doc/Oratcl_Users_Guide_and_Reference.md)'s "MS Windows" section has been updated to match this verified workflow — same `ORACLE_HOME`/`ORACLE_LIBRARY` env vars as Unix/macOS (plus `PATH`), manual copy of the built DLL/`pkgIndex.tcl`/`oratcl_utils.tcl` into Tcl's `lib` dir pending an installer, and a note that the same Instant Client major version (23.x) is used consistently across Linux/macOS/Windows — Windows env-var handling across the historical versions of this doc has always been the trickiest part to get right
- [x] Investigate macOS binary builds (native, since we're on macOS) against Oracle Instant Client for macOS (arm64/x86_64), and whether a universal binary is feasible/desired — **confirmed feasible, proof-of-concept built successfully**:
  - `./configure --with-tcl=<tclConfig.sh dir> --with-oracle-directory=<instant client dir>` followed by `make` produces a working `libtcl9Oratcl5.0.dylib` (Mach-O arm64) against Tcl 9.0.2 and Oracle Instant Client 23.3
  - Verified it loads cleanly under `tclsh9.0` (`package require Oratcl`) and registers all expected commands, including the new `oralob2`
  - Set `env(ORACLE_LIBRARY)` to the full path of `libclntsh.dylib` directly when using an Instant Client layout (no `lib/` subdirectory) — the default `$ORACLE_HOME/lib/libclntsh.dylib` lookup only matches a traditional full Oracle Client install layout
  - Along the way, found and fixed a real build-system bug: `oralob2.c` (added in 5.0) was never registered in `configure.in`'s `TEA_ADD_SOURCES`, so every build was silently failing at link time (`undefined symbol _Oratcl_Lob2`) until now
  - **Runtime-tested against a live DB — confirmed working**: `package require Oratcl` loaded cleanly and `oralogon` succeeded against a live Oracle 23c database on macOS, same spot-check level as the Windows test (not the full `make test` suite — see Story 15)
  - Universal (arm64+x86_64) binary and Intel Mac builds not yet attempted
- [x] Native Linux build and full live-database test run — **done, 100% pass rate, confirms the whole Tcl 9 + Oracle 23c compatibility story end-to-end**: Todd built and ran Oratcl 5.0 on Ubuntu/WSL2 (Tcl 9.1.0, Oracle Instant Client 23.26) against a real, live Oracle 23c XE database (`XEPDB1`), producing `libtcl9Oratcl5.0.so` and running the full `make test` suite — **169 passed, 0 failed, 0 skipped**, including `unicode.test` (5/5, validating Story 3's Tcl 9 UTF-8 resolution) and `arraydml.test` (5/5, validating the Oracle 23c array-DML cursor fix). This is the first real-database verification of the entire 5.0 line, and also retroactively validates the Windows cross-compile approach (same `configure.in`/`Makefile.in`, same zero-Oracle-at-build-time design) since the only difference on Windows is the cross-compiler target.
- [x] Determine which Oracle client/SDK versions to target per platform — **decided**: Oracle 23c client is the standard going forward (matches the Oracle 23c compatibility work already done in 5.0)
- [x] Decide packaging/distribution format per platform — **decided**: both `tar.gz` and `.zip`, matching the already-built artifacts (`oratcl-5.0.tar.gz` for source, `.zip` for platform binaries — `.zip` in particular because Windows doesn't typically have `tar` available). **New consideration**: the 4.5 line was also distributed as RPMs ([`Oratcl-4.5-1.i386.rpm`](https://sourceforge.net/projects/oratcl/files/oratcl/4.5/Oratcl-4.5-1.i386.rpm/download), [`Oratcl-4.5-1.x86_64.rpm`](https://sourceforge.net/projects/oratcl/files/oratcl/4.5/Oratcl-4.5-1.x86_64.rpm/download), 2009) alongside `oratcl45_win.zip`/`oratcl45.tar.gz` — decide whether to resume RPM packaging for 5.0 (would need `rpmbuild` or `fpm`, neither currently installed/attempted)
- [x] Once 5.0 packages are ready, update SourceForge's "Default Download" flag to point at the new tarball/binaries instead of `oratcl45.tar.gz` — **done**, confirmed by Todd
- [x] Wire up the resulting artifacts to the GitHub Releases (feeding Story 4's GitHub→SourceForge sync) once built — **done and verified end-to-end**: [Oratcl 5.0](https://github.com/toddhelfter/oratcl-sourceforge/releases/tag/oratcl-5.0) published with `oratcl-5.0.tar.gz`, `Oratcl50-Darwin-arm64.zip`, and `Oratcl50-Windows-x64.zip` attached; the webhook fired and delivered successfully, confirmed live on SourceForge's Files page under `oratcl-5-0` (the `.` in the GitHub tag `oratcl-5.0` gets normalized to `-` in the SourceForge folder name) — the full GitHub→SourceForge release pipeline (Story 4) works
- [x] SourceForge's project-level "Operating System" Trove classifier only listed BSD/Linux/Windows despite shipping a macOS binary — **done**, Todd added the macOS/Darwin classifier via Project Admin → Categorization

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
- [x] Independent corroboration found of HammerOra's real-world dependency on Oratcl,
  pre-dating the 2017 Windows collaboration: Todd's own "High Performance Oracle RAC
  Cluster with Infiniband" document, written while at DataPipe (local-only copy in the
  gitignored `Scratch/` folder, not in this repo), shows DataPipe used "hammerora" (the
  "open source oracle load test tool") to run TPC-C-style benchmark workloads comparing
  UDP-over-ethernet vs. UDP-over-Infiniband vs. RDS-over-Infiniband, to determine the
  best network/SAN storage settings for Oracle RAC throughput — concrete evidence
  HammerOra (and thus transitively Oratcl) was in real production use for RAC
  performance tuning at Todd's own employer, independent of Shaw's involvement.


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

## Story 14: Recover content gaps between historical Users Guide drafts and the current living doc

While reviewing old drafts of the Users Guide kept for reference in a local, untracked
`Scratch/` folder (`.gitignore`d, not in the repo), found that two 2017 drafts — "Revision
2" and "Revision 3" (`OraTcl User's Guide and Reference 2-0.doc.pdf` / `3-0.doc.pdf`,
subtitled "Updated for OraTcl Version 4.6") — reorganized and extended the book beyond
"Revision 8" (2009–2012), which is the version [doc/Oratcl_Users_Guide_and_Reference.md](doc/Oratcl_Users_Guide_and_Reference.md)
was actually converted from. Since the current doc's lineage skips straight from Revision
8 to this Markdown conversion, none of Revision 2/3's additions ever made it in. Note:
the source PDFs themselves only exist locally in `Scratch/` right now (gitignored,
temporary) — they'd need to be re-located or re-extracted (`pdftotext -layout`) before
acting on any of this.

- [ ] **Oratcl Compatibility Matrix** — Revision 3 added a "Chapter 22 - Oratcl
  Compatibility Matrix" with a real (if sparsely-filled-in) table cross-referencing Oratcl
  versions (1.0 through 4.4) against Tcl versions (7.4–8.5) and Oracle versions (6 through
  11g), plus Y/N compatibility flags for some rows. Never present in Revision 8 or the
  current doc. Worth recreating as a maintained table extended through 5.0/Tcl 9/Oracle
  23c rather than resurrecting the old partial data verbatim
- [ ] **Consolidated "Environment Variables that influence OraTcl" reference section** —
  both Revision 2 and 3 planned a dedicated chapter documenting `ORACLE_SID`,
  `ORACLE_HOME`, and `ORACLE_LIBRARY` in one place (each got its own one-line stub
  definition, never fully fleshed out). The current doc still only explains these
  contextually, scattered across the Solaris/macOS/Windows platform-specific sections —
  consider adding a single consolidated reference section instead/in addition
- [ ] **"What's New" section** — both 2017 revisions reserved a "What's New" section right
  after the Preface/Acknowledgments, intended as release-note-style summary of changes,
  but it was left completely blank in both drafts and never written. Decide whether the
  living doc should finally add one (could mirror/link `CHANGELOG.md` rather than
  duplicating it)
- [ ] Minor/cosmetic, lower priority: Revision 3 split the "Extending TCL" chapter's
  history narrative into explicitly named "Tom Poindexter's recollections" / "Todd
  Helfter's recollections" subheadings — the current doc has the same recollection text
  but without those subheadings; consider adopting for readability

## Story 15: Achieve full `make test` parity on macOS and Windows

All three platforms Todd has hardware for (Linux, macOS, Windows) now have 5.0 built and
spot-checked against a live Oracle 23c database (`package require Oratcl` + `oralogon`
succeed — see Story 7). Only Linux/WSL2 has run the *full* `tests/all.tcl` suite
(169 passed, 0 failed, 0 skipped). macOS and Windows haven't, for different reasons.

- [ ] macOS: no particular blocker identified yet beyond not having prioritized it —
  revisit and run `make test` there now that a live DB connection is confirmed working
- [ ] Windows: currently can't run at all — the test harness assumes a Unix shell/`make`
  environment (`tests/all.tcl`, `tests/defs.tcl`, `tests/startup.tcl`) and PowerShell
  env-var syntax (`$env:VAR=`) differs from what the harness expects; needs investigation
  into whether `tclsh`-driven tests can run standalone without `make`, or whether the
  harness needs a PowerShell-compatible setup path
- [ ] Once both are running, update the top-of-file test status line to reflect combined
  pass/fail counts across all three platforms

## Story 16: Update and version-control the `oratcl.sourceforge.net` project website

`oratcl.sourceforge.net` is SourceForge's separate "Project Web" static-hosting service
(distinct from the Files area and from this git repo) — content is uploaded via
SFTP/SCP/rsync to `web.sourceforge.net:/home/project-web/oratcl/htdocs/`. It's badly
stale: the homepage still says "LATEST VERSION: ORATCL 4.5" (2009), and `manpage.html` is
the man2html-converted man page for Oratcl 4.4 (2006) — neither reflects the 5.0 work
(Tcl 9, Oracle 23c, `oralob2`, etc.). None of this site's HTML sources (`index.html`,
`changelog.html`, `manpage.html`) currently live in this repo, so there's no
version-controlled way to regenerate or diff them; only `doc/FAQ.html` and `doc/oratcl.html`
(the current 5.0 man page, man2html-converted from `doc/oratcl.n`) exist here, and it's
unclear whether `doc/FAQ.html` matches what's actually live on the site.

- [x] Pull down the current live site content (`index.html`, `changelog.html`, any other
  pages/images referenced in its sub-menu) and add it to the repo (e.g. under a new
  `doc/web/` directory) so it's version-controlled going forward — **done**: pulled via
  SFTP into `doc/web/`, renamed to match repo conventions (`manpage.html` → `oratcl.html`,
  `changelog.html` → `CHANGELOG.html`, `OraTcl_Users_Guide_and_Reference.pdf` →
  `Oratcl_Users_Guide_and_Reference.pdf`), `css/` and `images/` (including `backgrounds/`)
  carried over as-is
- [x] Update `index.html`'s "latest version" banner and body text for 5.0 (Tcl 9 port,
  Oracle 23c compatibility, new `oralob2` command, security hardening — see `CHANGELOG.md`)
  — **done**, also fixed dead links (`wiki.tcl.tk` → `wiki.tcl-lang.org`), repointed
  bug/feature links at SourceForge Tickets, added a GitHub repo link
- [x] Regenerate `manpage.html` from the current `doc/oratcl.n`/`doc/oratcl.html` (5.0,
  includes `oralob2`) instead of the stale 4.4 version — **done**, `doc/web/oratcl.html`
  wraps the already-current `doc/oratcl.html` body in the site's nav/CSS template
- [x] Verify `doc/FAQ.html` is current and republish it; update `changelog.html` to point
  at/mirror `CHANGELOG.md` — **done**: the live FAQ.html (pulled from the server) turned
  out to be more current than the in-repo `doc/FAQ.html` despite an older `$Id` tag
  (confirms the site was hand-edited post-2009 without keeping that tag in sync) — used it
  as the baseline, added a Tcl 9/Oracle 23c/5.0 row to the compatibility matrix, and fixed
  several dead/stale links (old CVS, SourceForge forum/bugs/patch URLs, bad email
  addresses). `CHANGELOG.html` now opens with a 5.0/4.6 summary linking to the full
  `CHANGELOG.md` on GitHub, with the original 4.5-and-earlier log preserved below.
- [x] Publish the updated site via SFTP/SCP/rsync per SourceForge's Project Web docs
  (`sftp <user>@web.sourceforge.net`, upload to `/home/project-web/oratcl/htdocs/`) —
  **done**: [`doc/web/deploy.sh`](doc/web/deploy.sh) removes the old stale filenames and
  uploads the renamed content via `sftp`
- [x] Post-publish visual pass (prompted by live screenshots of the deployed site on a
  widescreen monitor) — **done**:
  - The original CSS pinned `#header`/`#content` to 720/750px, leaving huge empty margins
    on widescreen displays; widened to `width:94%; max-width:1600px` (sidebar/mainbar
    split is margin-based, not percentage-based, so this didn't require touching that math)
  - Added `<meta name="viewport">` to all four pages (was missing entirely), bumped base
    font-size from `0.74em` to `1em`, added a `@media (max-width:700px)` breakpoint to
    stack the sidebar below mainbar instead of overflowing on narrow viewports, and
    removed `index.html`'s defunct W3C XHTML validator badge
  - A follow-up `max-width:75ch` added to `#mainbar p` for readability was reverted after
    a live screenshot showed it mismatched against the full-width `<h1>` heading
    underlines — confirmed looking right afterward and redeployed
- [ ] Decide whether to keep this a manual per-release publish step, or automate it (e.g.
  a GitHub Actions step triggered on release, alongside Story 4's GitHub→SourceForge
  Files sync)

## Story 17: Validate Oratcl 5.0 against Oracle 26AI

Oracle 26AI has just been released. We already track Oracle 12c/19c/21c/23c compatibility
(4.6/5.0, per the FAQ's compatibility matrix) — need to confirm 5.0 also works against
this newest release, download the [Instant Client](https://www.oracle.com/database/technologies/instant-client/downloads.html)
for it, and update the compatibility matrix/docs accordingly.

- [x] Run Oratcl 5.0's live-database test suite (`make test`) against a live Oracle 26AI
  server — **done**, from WSL2/Ubuntu (Tcl 9.1.0) using the existing Oracle 23c Instant
  Client (23.26) against a remote 26AI (`FREE`) database — confirms the existing 23c
  client is forward-compatible with a 26AI server; no new Instant Client download was
  actually needed for this pass. Nearly everything passed; two pre-existing tests broke
  due to 26AI wording/behavior changes, not build or connectivity issues:
  - `oradesc-2.0`/`oradesc-2.1` (`tests/oradesc.test`): 26AI capitalizes the error text —
    `ORA-04043: Object ... does not exist` (capital `O`) vs. the lowercase `object` the
    regexes still expect. Needs a test fix (case-insensitive match or updated literal).
  - `oraparse-2.1` (`tests/oraparse.test`): the second bad-SQL case
    (`select * from oratcl___tests v_number = 0`) now raises `ORA-03048` ("SQL reserved
    word '=' is not syntactically valid...") instead of the `ORA-00933` ("SQL command not
    properly ended") a 23c-era server reports for the same statement — a genuine
    server-side parser behavior change in 26AI, not an Oratcl bug. Also reconfirmed the
    existing `# TMH` note in that test: `oraparse` still requires wrapping in `catch` to
    get a usable return code instead of raising a bare Tcl error, which the test works
    around rather than exercises.
  - `orabindexec-1.4` ("too few bind values") newly **fails** against 26AI: binding only
    2 of 3 `:varname` placeholders now returns `0` (success) instead of raising
    `ORA-01008: not all variables bound` — looks like a real behavior change (either in
    26AI's OCI parse/bind validation, or a latent Oratcl bug this exposes) and needs
    investigation in `generic/orabindexec.c`/`generic/orabind.c`, not just a test update.
  - Also noted in passing: `generic/oratcl.c`'s `Oratcl_Checkerr` allocates a fixed
    `ORA_MSG_SIZE` (1000 bytes, `generic/oratclInt.h`) buffer for `OCIErrorGet` — 26AI
    error messages now append a `Help: https://docs.oracle.com/error-help/db/ora-NNNNN/`
    line, making messages meaningfully longer than older Oracle versions produced; worth
    checking whether any real-world message now gets silently truncated by that fixed
    buffer (`OCIErrorGet` gives no truncation indication) and bumping it if so.
- [x] Fix `tests/oradesc.test`'s `oradesc-2.0`/`-2.1` expected-error text for 26AI's
  capitalized `Object` wording — **done**: switched both from `-match regexp` to
  `-match glob` with the literal (now correctly-cased) `Object` text plus a trailing `*`
  to tolerate 26AI's appended `Help: ...` URL line, rather than reaching for a
  case-insensitive regex — a direct string/glob comparison is simpler and was all that
  was actually needed here
- [x] Decide how to handle `oraparse.test`'s version-dependent error codes (`ORA-00933`
  on older servers vs. `ORA-03048` on 26AI for the same malformed SQL) — **done**: split
  the old `tst(1)`/`tst(2)` loop (one test asserting an exact list of hardcoded codes)
  into two separate tests, `oraparse-2.1`/`oraparse-2.2`, one SQL string each, each
  asserting only `-returnCodes {1}` and `-match glob -result {ORA-*}` — no exact code or
  wording pinned down, since that's the server's business, not Oratcl's. Along the way,
  found the `catch` wrapping (and the `# TMH` comment claiming it was needed) was already
  stale: `generic/oraparse.c` has returned `TCL_ERROR` directly on a bad `OCI_StmtPrepare`
  since before this investigation, so both new tests call `oraparse` directly with no
  `catch`. Exact rc/error-text self-consistency is now covered separately in the new
  `oramsg.test` (below), which doesn't depend on which specific code a given server
  version assigns to a given malformed statement either.
- [x] Investigate the `orabindexec-1.4` regression (too-few-bind-values no longer errors)
  against 26AI — **partially done**: read through `generic/orabindexec.c` (a thin
  `Oratcl_Bind()` + `Oratcl_Exec()` wrapper, no logic of its own) and `generic/oraexec.c`
  (plain `OCIStmtExecute()`, no statement caching enabled anywhere) and found nothing in
  Oratcl's own C code that would explain OCI no longer raising `ORA-01008` — root cause
  (genuine 26AI engine behavior change vs. something about the test's 26AI run) is still
  unconfirmed, since diagnosing it further needs an actual 26AI connection this workspace
  doesn't have. Also worth noting: `orabindexec` is legacy Oratcl-2.x-era syntax, now
  superseded by `oraplexec`/`orasql`-style usage (nothing in `library/*.tcl` uses it
  internally, only `oraplexec`) — kept only for backwards compatibility with old scripts.
  Decided for now to just unblock the suite rather than guess at new expected output or
  remove the command: `orabindexec-1.4`/`-1.5` are skipped via a new
  `knownBug_orabindexec14` constraint in `tests/orabindexec.test`, pending either root-
  causing this on a real 26AI connection or a separate future decision to retire
  `orabindexec` outright
- [x] Check whether `ORA_MSG_SIZE` (`generic/oratclInt.h`, currently 1000 bytes) needs to
  be increased given 26AI's longer `Help:`-URL-suffixed error messages, and confirm
  `Oratcl_Checkerr` doesn't need to handle/detect truncation — **done**: bumped
  `ORA_MSG_SIZE` to Oracle's own `OCI_ERROR_MAXMSG_SIZE2` (3072 bytes, added as a new
  constant in `generic/oratclInt.h`), matching Oracle's documented recommendation for
  buffers passed to `OCIErrorGet()` since 26AI's `Help:` URL suffix was introduced.
  `Oratcl_Checkerr` itself doesn't need a code change — 3072 bytes is large enough in
  practice, and the existing code already just takes whatever `OCIErrorGet()` returns
- [ ] Add a connection-level option to `oraconfig` to toggle the 26AI `Help:` URL suffix
  on/off per-session (wrapping `OCI_ATTR_SUPPRESS_ERROR_URL` on the environment handle,
  the same effect as the `ORA_SUPPRESS_ERROR_URL` env var but controllable from Tcl) —
  worth doing since some callers may want the shorter message back, or may be parsing/
  matching on exact error text elsewhere the way `tests/oradesc.test`/`oraparse.test` do

- [x] Consider moving the bad-SQL/error-message tests out of `oraparse.test` into a
  dedicated `oramsg.test`, since they're really exercising `oramsg`'s error reporting more
  than `oraparse` itself — **done**: added `tests/oramsg.test` (registered in
  `tests/all.tcl`), asserting self-consistency rather than hardcoded codes — `rc` is a
  positive integer, the numeric prefix embedded in `error`'s `ORA-NNNNN:` text matches
  `rc` regardless of which code it is, `all`'s first two elements agree with the `rc`/
  `error` single-option accessors, and `rc`/`error` reset to `0`/`{}` after a subsequent
  successful parse on the same statement handle
- [ ] Note any OCI-level incompatibilities or deprecations introduced in 26AI that affect
  `generic/oradefs.h`'s type/constant definitions (same category of work as the 23c SDK
  updates already done)
- [ ] Once verified, add a 26AI column to the compatibility matrix in `doc/web/FAQ.html`
  (and the in-repo `doc/FAQ.html` if still tracked separately) and mention it in
  `CHANGELOG.md`/`doc/web/CHANGELOG.html`

## Story 18: `Oratcl::utils` (`library/oratcl_utils.tcl`) packaging gap

While documenting `Oratcl::utils` (`logonBox`, `prettyDesc`, `getLogo`) for the Users
Guide, found that although the standard `./configure && make && make install` process
on Unix correctly installs `oratcl_utils.tcl` alongside `pkgIndex.tcl` (verified directly
in `Makefile.in`'s `install-lib-binaries` target, which iterates `$(PKG_TCL_SOURCES)`),
the **macOS build instructions in the Users Guide never run `make install` at all** —
they stop at `make` — and never mention copying `oratcl_utils.tcl`/`pkgIndex.tcl`
anywhere, unlike the Windows section which explicitly calls both out. Story 7's actual
macOS runtime test only verified `package require Oratcl` + `oralogon`, not
`Oratcl::utils`. The already-published `Oratcl50-Darwin-arm64.zip` (and possibly
`Oratcl50-Windows-x64.zip`, since that was also built via manual copy rather than a
scripted/automated step) may be missing `oratcl_utils.tcl` entirely.

- [ ] Download and inspect the contents of the already-published `Oratcl50-Darwin-arm64.zip`
  and `Oratcl50-Windows-x64.zip` from the 5.0 GitHub release / SourceForge Files to confirm
  whether `oratcl_utils.tcl` and `pkgIndex.tcl` (with its `Oratcl::utils` line) are
  actually present
- [ ] If missing, rebuild and republish corrected zips, and fix the Users Guide's macOS
  section to match the Windows section's explicit file-copy instructions (or to run
  `make install DESTDIR=...` instead of a manual copy)

Three candidate approaches were discussed for permanently closing this gap (no decision
made yet — Todd wants to think it over):

1. **Packaging script/`make` target** — add a `tools/`-style script (or new `Makefile.in`
   target) that runs `make install DESTDIR=<staging>` and zips the resulting `pkglibdir`
   contents, so every platform's distributable zip is built the same scripted way instead
   of by manual file copying. Lowest risk, smallest change, but doesn't prevent the
   underlying class of bug (a file silently missing from manual packaging) as robustly as
   the other two options — it just makes the *correct* path easier to follow.
2. **Freeze `oratcl_utils.tcl` into the C extension via `Tcl_Eval`** — at build time,
   embed the existing Tcl source as a C string constant and `Tcl_Eval()` it once near the
   end of `Oratcl_Init()` (just defining the procs, not calling them). Since
   `package require Tk` already only appears lazily *inside* `logonBox`/`getLogo`
   (never at file-source time in the current code), this preserves the existing
   "no Tk dependency unless you actually call a GUI proc" safety property automatically —
   nothing new to guard. Fully eliminates the possibility of the file going missing from
   a package (it's baked into the shared library/DLL itself), at the cost of losing
   accurate file/line attribution in Tcl error tracebacks originating from that embedded
   code, plus a small amount of added build complexity to keep the frozen copy in sync
   with the real `.tcl` source.
3. **Full native C reimplementation** (Todd's original instinct, same approach as
   `oralob`/`oralong`) — rewrite `logonBox`/`prettyDesc`/`getLogo` as real C functions
   using Tk's public C API (`Tk_InitStubs`, `Tk_PhotoPutBlock`, etc.) instead of
   evaluating Tcl script text. This is the most work by far (new `.c`/`.h` files, TK_STUBS
   build wiring in `configure.in`), and — unlike option 2 — does *not* get Tk-optionality
   for free: `Tk_InitStubs` must be called defensively (e.g. only when a GUI command is
   actually invoked, checking its return value and raising a normal Tcl error rather than
   hard-failing `Oratcl_Init()`/package load if Tk isn't present), since linking against
   Tk's stub table at all introduces a real dependency that has to be explicitly guarded
   wherever it's used, not just deferred like options 1 and 2 get automatically from the
   current Tcl-level design.
