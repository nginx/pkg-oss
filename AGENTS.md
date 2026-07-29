# AGENTS.md — pkg-oss

This file provides guidance for AI agents working in this repository. It covers
the project structure, build system, conventions, and step-by-step workflows for
the most common minor-change tasks.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Layout](#2-repository-layout)
3. [Branches](#3-branches)
4. [Build System — Four Makefile Layers](#4-build-system--four-makefile-layers)
5. [Platform Build Quick Reference](#5-platform-build-quick-reference)
6. [Template System — The `.in` Convention](#6-template-system--the-in-convention)
7. [Contrib Source Management](#7-contrib-source-management)
8. [Module Makefile Variable Reference](#8-module-makefile-variable-reference)
9. [Adding a New Module](#9-adding-a-new-module)
10. [Updating a Module or Dependency Version](#10-updating-a-module-or-dependency-version)
11. [Testing](#11-testing)
12. [CI Testing Architecture](#12-ci-testing-architecture)
13. [Platform Compatibility and Skip Files](#13-platform-compatibility-and-skip-files)
14. [OSS vs Plus Dual-mode](#14-oss-vs-plus-dual-mode)
15. [Changelog and Documentation](#15-changelog-and-documentation)
16. [build_module.sh — Packaging 3rd-party Modules](#16-build_modulesh--packaging-3rd-party-modules)
17. [Supply-chain and Attestation](#17-supply-chain-and-attestation)
18. [Commit and PR Conventions](#18-commit-and-pr-conventions)
19. [Key Gotchas](#19-key-gotchas)

---

## 1. Project Overview

`pkg-oss` is the official NGINX Open Source packaging repository. It is the
single source of truth for producing installable binary packages of NGINX and
its dynamic modules across all supported Linux distributions.

**What it produces:**
- `.apk` packages for Alpine Linux
- `.deb` packages for Debian and Ubuntu
- `.rpm` packages for RHEL, CentOS, Fedora, Amazon Linux, and SLES

**What it does NOT contain:** compiled application source code. The entire repo
is build infrastructure — GNU Make, POSIX shell, XML, and XSLT.

**Supported targets:**
- NGINX OSS (open source) — default
- NGINX Plus (commercial) — via `BASE_TARGET=plus`

**Currently pinned versions** (in `contrib/src/nginx/version` and
`contrib/src/njs/version`):
- NGINX `1.31.3` (mainline)
- NGINX Plus `37.0.0`
- NJS `1.0.0`

**Module categories:**

| Category | Modules |
|---|---|
| Bundled/base | `acme`, `geoip`, `image-filter`, `njs`, `otel`, `perl`, `xslt` |
| External/3rd-party | `auth-spnego`, `brotli`, `encrypted-session`, `fips-check`, `geoip2`, `headers-more`, `lua`, `ndk`, `passenger`, `rtmp`, `set-misc`, `subs-filter` |

---

## 2. Repository Layout

```
pkg-oss/
├── Makefile                   # Release management (version bumps, tagging)
├── build_module.sh            # Standalone helper to package 3rd-party modules
├── .github/
│   ├── workflows/ci.yml       # CI pipeline
│   └── test-env/              # Per-module test environment setup scripts
│       └── module-<name>.sh   # Sourced by CI before the module's test step
├── alpine/                    # Alpine Linux (.apk) packaging
│   ├── Makefile               # Platform build driver
│   ├── Makefile.module-*      # Per-module variable definitions
│   ├── alpine/                # APKBUILD templates (.in files), init scripts, nginx.conf
│   └── alpine-plus/           # NGINX Plus APKBUILD template
├── debian/                    # Debian/Ubuntu (.deb) packaging
│   ├── Makefile               # Platform build driver
│   ├── Makefile.module-*      # Per-module variable definitions
│   ├── debian/                # Debian packaging templates (.in files), service files
│   └── debian-plus/           # NGINX Plus control template
├── rpm/
│   ├── SPECS/                 # RPM (.rpm) packaging
│   │   ├── Makefile           # Platform build driver
│   │   ├── Makefile.module-*  # Per-module variable definitions
│   │   ├── nginx.spec.in      # Base NGINX spec template
│   │   ├── nginx-module.spec.in        # OSS module spec template
│   │   └── nginx-plus-module.spec.in   # Plus module spec template
│   └── SOURCES/               # Static files embedded in RPMs (nginx.conf, systemd units, etc.)
├── contrib/                   # Upstream source dependency management
│   ├── Makefile               # Download/verify/unpack orchestrator
│   ├── attestation.mak        # Supply-chain attestation helpers
│   ├── src/<dep>/             # Per-dependency: version, SHA512SUMS, Makefile
│   └── tarballs/              # Downloaded archives land here (git-ignored)
└── docs/                      # XML changelogs and XSLT transformation tooling
    ├── *.xml                  # Canonical changelog per package
    ├── *.copyright            # Copyright text embedded into packages
    ├── changes.dtd            # DTD for the XML changelog format
    ├── changes.xslt / .xsls   # XSLT stylesheet for changelog generation
    └── Makefile               # Drives xsltproc transformations
```

---

## 3. Branches

| Branch | Purpose |
|---|---|
| `master` | Current mainline packages (`FLAVOR=mainline`) |
| `stable-*` | Stable release packages (`FLAVOR=stable`) |

The root `Makefile` auto-detects the flavor from the branch name: any branch
containing the word `stable` sets `FLAVOR=stable`; everything else is `mainline`.
Do not manually override this.

---

## 4. Build System — Four Makefile Layers

### Layer 1 — Root `Makefile` (release management)

Handles version bumps, SHA512 appending, changelog injection, and Git tagging.
Agents performing minor changes (module updates, dep bumps) generally do not
need to invoke the root `Makefile` directly. The relevant targets are:

| Target | Purpose |
|---|---|
| `make release` | Bump `NGINX_VERSION`, update SHA512SUMS, inject changelog entries |
| `make release-njs` | Same workflow for the NJS module |
| `make revert / commit / tag` | Git workflow helpers |

### Layer 2 — `contrib/Makefile` (source acquisition)

Downloads, checksums, and unpacks all upstream source tarballs. Sources are
fetched from `https://packages.nginx.org/contrib` with fallback to the original
upstream URL.

| Target | Purpose |
|---|---|
| `make fetch` | Download and verify checksums for all packages |
| `make install` | Download, verify, and unpack all packages |
| `make list` | Print all known package names |
| `make clean` | Remove downloaded tarballs and unpacked trees |

Run these from the `contrib/` directory.

**Verbose output:** `tar` and `unzip` are quiet by default during unpack. Set
`V=1` to restore full output:

```sh
V=1 make install
```

### Layer 3 — Platform Makefiles (package builds)

One each in `alpine/`, `debian/`, `rpm/SPECS/`. All three follow the same
structure and expose the same targets. Run from the respective directory.

### Layer 4 — `docs/Makefile` (changelog pipeline)

Transforms `docs/*.xml` source via `xsltproc` into `.rpm-changelog` and
`.deb-changelog` files that are embedded into packages during builds.

| Target | Purpose |
|---|---|
| `make changes` | Generate all changelog files |
| `make changelogs` | Alias for `make changes` |

Run from the `docs/` directory.

---

## 5. Platform Build Quick Reference

The following targets work identically in `alpine/`, `debian/`, and
`rpm/SPECS/`:

```sh
# Build the NGINX base package
make base

# Build a specific module package
make module-<name>

# Build base + all bundled base modules
make all

# Build all modules including external
make all-modules

# Run the full test suite: core nginx-tests plus the suite of every built module
make test

# Same, against the nginx-debug binary and the debug .so files
make test-debug

# Narrow a run down to specific modules or files
make test TEST_MODULES=.                    # core suite only
make test TEST_MODULES=<name>               # a single module suite
make test TEST_MODULES=<name>/some.t        # a single test file

# Check that built .so files have no embedded RPATHs
make check-modules

# Check/generate platform compatibility skip files
make check-compat-<name>

# List all modules known to the platform Makefile
make list-all-modules
```

**NGINX Plus mode** — prefix any target with `BASE_TARGET=plus`:

```sh
BASE_TARGET=plus make module-njs
```

---

## 6. Template System — The `.in` Convention

> **Never edit generated files.** All final packaging files (APKBUILD,
> `debian/control`, `debian/rules`, `.spec`) are produced by `sed` substitution
> from `.in` templates. Edits to generated files are silently overwritten on the
> next build.

Templates use double-percent delimited tokens:

```
%%VERSION%%  %%CODENAME%%  %%MODULE_CONFIGURE_ARGS%%  %%PACKAGE_VENDOR%%
```

Template locations:

| Platform | Templates |
|---|---|
| Alpine | `alpine/alpine/APKBUILD-base.in`, `alpine/alpine/APKBUILD-module.in` |
| Debian | `debian/debian/*.control.in`, `debian/debian/*.rules.in`, `debian/debian/*.postinst.in` |
| RPM | `rpm/SPECS/nginx.spec.in`, `rpm/SPECS/nginx-module.spec.in`, `rpm/SPECS/nginx-plus-module.spec.in` |

If a packaging change is needed (e.g. adding a new `BuildRequires`, changing a
`Replaces:` tag), edit the `.in` template, not any generated file.

---

## 7. Contrib Source Management

Every upstream dependency has its own subdirectory under `contrib/src/`:

```
contrib/src/<dep>/
├── version       # Defines DEP_VERSION := x.y.z (and optionally DEP_GITHASH)
├── SHA512SUMS    # One "hash  filename" line per historical tarball (append-only)
└── Makefile      # Download and unpack rules
```

The `SHA512SUMS` file is **append-only** — keep all historical entries so that
older pkg-oss checkouts can still verify their tarballs. Never delete existing
lines.

### Adding a new dependency

1. Create `contrib/src/<dep>/` with the three files above.
2. Add a `PKGS += <dep>` line and a download target in the new `Makefile`.
3. Compute the SHA512: `sha512sum <tarball>` and add the line to `SHA512SUMS`.
4. Verify: `make fetch` from `contrib/` (downloads and checks the checksum).

### Updating a dependency version

1. Edit `contrib/src/<dep>/version` — update `DEP_VERSION`.
2. Compute the new tarball SHA512 and **append** it to `contrib/src/<dep>/SHA512SUMS`.
3. Run `make fetch` from `contrib/` to download and verify.
4. Update `MODULE_VERSION_<n>` and `MODULE_SOURCES_<n>` in all three platform
   `Makefile.module-<name>` files (see [§8](#8-module-makefile-variable-reference)).

### Git-sourced dependencies

Some deps (e.g. `ngx_brotli`, `luajit2`) are fetched from Git refs rather than
tarballs. Their `Makefile` uses the `download_git` helper, which creates a
reproducible `.tar.xz` archive and records the commit hash in a `.githash`
sidecar file. When updating these, provide the new Git ref and update `version`
with the new commit hash as `DEP_GITHASH`.

---

## 8. Module Makefile Variable Reference

Each `Makefile.module-<name>` file defines a set of namespaced Make variables.
The `<n>` suffix below stands for the module nickname (e.g. `njs`, `brotli`).

### Common variables (all three platforms)

| Variable | Required | Description |
|---|---|---|
| `MODULES += <n>` | yes | Registers the module with the platform Makefile |
| `MODULE_SUMMARY_<n>` | yes | One-line human description (used in package metadata) |
| `MODULE_VERSION_<n>` | yes | Module version string, usually `$(DEP_VERSION)` |
| `MODULE_RELEASE_<n>` | yes | Package release number; reset to `1` on each new upstream version |
| `MODULE_SOURCES_<n>` | yes | Space-separated list of source tarball filenames from `contrib/tarballs/` |
| `MODULE_CONFARGS_<n>` | yes | `--add-dynamic-module=<path>` argument(s) passed to nginx `./configure` |
| `MODULE_CONTRIB_DEPS_<n>` | if needed | Space-separated contrib dep names; their `version` files are auto-included |
| `MODULE_VERSION_PREFIX_<n>` | yes | Set to `$(MODULE_TARGET_PREFIX)` for standard version epoch |
| `MODULE_PATCHES_<n>` | if needed | Space-separated list of patch file paths to apply to sources |
| `MODULE_CC_OPT_<n>` | if needed | Extra `-I` / compiler flags for the module build |
| `MODULE_LD_OPT_<n>` | if needed | Extra `-L` / linker flags for the module build |
| `MODULE_CC_OPT_DEBUG_<n>` | if needed | Same as above but for the `nginx-debug` build |
| `MODULE_LD_OPT_DEBUG_<n>` | if needed | Same as above but for the `nginx-debug` build |
| `MODULE_PREBUILD_<n>` | if needed | `define … endef` shell block run before nginx configure (e.g. build a dependency library) |
| `MODULE_PREINSTALL_<n>` | if needed | `define … endef` shell block run before package install step (e.g. install extra binaries/docs) |
| `MODULE_POST_<n>` | yes | `define … endef` block that prints the post-install banner (`load_module` instructions) |

### Platform-specific variables

**Alpine only:**

| Variable | Description |
|---|---|
| `MODULE_BUILD_DEPENDS_<n>` | Space-separated list of Alpine `apk` packages required at build time |
| `MODULE_ADD_CONTROL_TAGS_<n>` | Extra APKBUILD tags (e.g. `replaces="nginx-mod-http-js"`) |

**Debian only:**

| Variable | Description |
|---|---|
| `MODULE_BUILD_DEPENDS_<n>` | Comma-prefixed list of Debian packages required at build time (e.g. `,libedit-dev,libxml2-dev`) |
| `MODULE_ADD_CONTROL_TAGS_<n>` | Extra `debian/control` stanza entries |

**RPM only:**

| Variable | Description |
|---|---|
| `MODULE_DEFINITIONS_<n>` | `define … endef` block for raw spec preamble content (typically `BuildRequires:` lines with conditional RPM macros) |
| `MODULE_FILES_<n>` | `define … endef` block listing additional files for the spec `%files` section (e.g. `%{_bindir}/njs`) |

### Example — minimal module Makefile

```make
MODULES+=	mymodule

MODULE_SUMMARY_mymodule=	mymodule dynamic module

MODULE_CONTRIB_DEPS_mymodule=	mymodule-src

include $(foreach dep,$(MODULE_CONTRIB_DEPS_mymodule),$(CONTRIB)/src/$(dep)/version)

MODULE_VERSION_mymodule=	$(MYMODULE_SRC_VERSION)
MODULE_RELEASE_mymodule=	1

MODULE_SOURCES_mymodule=	mymodule-src-$(MYMODULE_SRC_VERSION).tar.gz

MODULE_CONFARGS_mymodule=	--add-dynamic-module=$(MODSRC_PREFIX)mymodule-src-$(MYMODULE_SRC_VERSION)

MODULE_VERSION_PREFIX_mymodule=$(MODULE_TARGET_PREFIX)

define MODULE_POST_mymodule
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_mymodule) for $(MODULE_SUMMARY_PREFIX) has been installed.
To enable this module, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_mymodule.so;

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_mymodule
```

---

## 9. Adding a New Module

Follow these steps in order. Use an existing similar module as a reference:
simple case → `Makefile.module-brotli`; multi-source/complex → `Makefile.module-njs`.

### Step 1 — Add the upstream source to contrib (if not already present)

```
contrib/src/<dep>/version      # e.g.  MYMODULE_VERSION := 1.2.3
contrib/src/<dep>/SHA512SUMS   # sha512sum output for the tarball
contrib/src/<dep>/Makefile     # download/unpack rules
```

Run `make fetch` from `contrib/` to verify the checksum.

### Step 2 — Create `Makefile.module-<name>` in all three platform directories

The file must be created in all three locations:
- `alpine/Makefile.module-<name>`
- `debian/Makefile.module-<name>`
- `rpm/SPECS/Makefile.module-<name>`

The variable set is largely identical across platforms; see
[§8](#8-module-makefile-variable-reference) for platform differences.

### Step 3 — Add changelog and copyright stubs

Create two files in `docs/`:

**`docs/nginx-module-<name>.xml`:**
```xml
<?xml version="1.0" ?>
<!DOCTYPE change_log SYSTEM "changes.dtd" >

<change_log title="nginx_module_<name>">

<changes apply="nginx-module-<name>" ver="1.0.0" rev="1" basever="1.31.3"
         date="YYYY-MM-DD" time="HH:MM:SS +0000"
         packager="NGINX Packaging <nginx-packaging@f5.com>">

<change>
<para>
initial release of nginx-module-<name>
</para>
</change>

</changes>

</change_log>
```

**`docs/nginx-module-<name>.copyright`:**
```
Copyright and license text for nginx-module-<name>.
```

### Step 4 — Verify the build

```sh
# From the target platform directory, e.g.:
cd debian
make module-<name>
```

---

## 10. Updating a Module or Dependency Version

### Updating a contrib dependency

1. Edit `contrib/src/<dep>/version` — change `DEP_VERSION`.
2. Obtain the new tarball SHA512:
   ```sh
   sha512sum <new-tarball.tar.gz>
   ```
3. **Append** the new line to `contrib/src/<dep>/SHA512SUMS`. Do not remove
   existing lines.
4. Verify: `make fetch` from `contrib/`.

### Updating module version in all platform Makefiles

For each of `alpine/Makefile.module-<name>`, `debian/Makefile.module-<name>`,
`rpm/SPECS/Makefile.module-<name>`:

1. Update `MODULE_VERSION_<n>` (or the contrib version variable it references).
2. Update `MODULE_SOURCES_<n>` filenames to match the new version.
3. If this is a new upstream release (not just a packaging fix), reset
   `MODULE_RELEASE_<n>` back to `1`. Increment `MODULE_RELEASE_<n>` only for
   packaging-only changes that do not change the upstream version.

### Updating the changelog

Append a new `<changes>` block to `docs/nginx-module-<name>.xml`:

```xml
<changes apply="nginx-module-<name>" ver="X.Y.Z" rev="1" basever="1.31.3"
         date="YYYY-MM-DD" time="HH:MM:SS +0000"
         packager="NGINX Packaging <nginx-packaging@f5.com>">

<change>
<para>
upgraded to <name> version X.Y.Z
</para>
</change>

</changes>
```

Always append; never edit or remove existing `<changes>` blocks.

---

## 11. Testing

Tests use the official [nginx-tests](https://github.com/nginx/nginx-tests) Perl TAP
suite, run via `prove`. The test suite source is cloned via
`contrib/src/nginx-tests`.

Third-party modules whose upstream suite is written for OpenResty's
`Test::Nginx::Socket` DSL are not used directly. Instead they are converted to
the nginx-tests framework and live in a separate repository,
[pkg-oss-tests](https://github.com/nginx/pkg-oss-tests), cloned via
`contrib/src/pkg-oss-tests` with one `<module>/t/` directory per module. That
repo has its own `AGENTS.md` describing the conversion rules. Nothing from
OpenResty is required at runtime — the converted suites use nginx-tests'
own `lib/Test/Nginx.pm`.

Both checkouts are fetched and copied into the platform directory by a single
shared rule, so `nginx-tests/` and `pkg-oss-tests/` are local working copies:

```make
nginx-tests pkg-oss-tests:
	@{ \
	if [ ! -d "$(CONTRIB)/tarballs/$@" ]; then \
	    cd $(CONTRIB) && make .sum-$@ ; \
	fi ; \
	cp -rP $(CONTRIB)/tarballs/$@ $@ ; \
	}
```

### Test targets

Run from the platform directory (`alpine/`, `debian/`, or `rpm/SPECS/`):

| Target | What it runs |
|---|---|
| `make test` | Core nginx-tests suite plus the suite of every built module, against the release binary |
| `make test-debug` | Same, against `nginx-debug` and the debug `.so` files |

These two are the **only** test entry points, and behave identically on all
three platforms. There is no `test-module-<name>` target — use
`make test TEST_MODULES=<name>`.

`test` and `test-debug` share a single recipe, distinguished at runtime by
`case "$@" in *-debug)`, which sets the binary (`nginx` / `nginx-debug`) and the
`.so` suffix. For each module that has been built (`module-<n>/` exists) and has
a test suite, the recipe stages it into `nginx-tests/module-<n>/` and hands the
directory to the same `prove` invocation that runs the core suite. `prove` is
not recursive, so `.` picks up the core tests exactly once and each
`module-<n>` directory exactly once.

Staging always runs, regardless of `TEST_MODULES`. That ordering matters: a CI
job does a fresh checkout and then calls `make test TEST_MODULES=<name>` as its
only test invocation, so if staging were skipped when `TEST_MODULES` is set,
`nginx-tests/module-<name>/` would never be created and the run would silently
pass without executing anything.

### Narrowing a run — `TEST_MODULES`

`TEST_MODULES` filters what's passed to `prove` **after** staging, by bare
module name — not the `nginx-tests/`-relative directory name. It defaults to
the core suite plus every staged module. The one non-module value is `.`,
which selects the core suite; there is no other way to express "core only".

```sh
make test                                   # core suite + all built module suites
make test TEST_MODULES=.                    # core suite only
make test TEST_MODULES=set-misc             # one module suite
make test TEST_MODULES=lua/socket.t         # one test file
make test TEST_MODULES="set-misc lua"       # several modules
```

Internally each value is prefixed with `module-` before being checked against
`nginx-tests/` (`set-misc` → `module-set-misc`, `lua/socket.t` →
`module-lua/socket.t`), except `.`, which is passed through unchanged.

Values that were never staged (a module with no test suite, or one that is not
built) are dropped with a notice; if nothing remains the target exits 0. That is
what lets the CI matrix run `make test TEST_MODULES=<name>` uniformly for every
module, including the ones that ship no tests.

### Environment variables

| Variable | Purpose |
|---|---|
| `TEST_NGINX_BINARY` | Path to the nginx binary under test |
| `TEST_NGINX_GLOBALS` | Directives prepended to `nginx.conf`; the Makefile **appends** the generated `load_module` directives to whatever is already in this variable |
| `TEST_NGINX_GLOBALS_HTTP` | Directives injected into the `http {}` block |
| `TEST_NGINX_GLOBALS_STREAM` | Directives injected into the `stream {}` block |
| `TEST_NGINX_PEBBLE_BINARY` | Path to the Pebble ACME test server binary. **Optional** — the acme suite calls `has_daemon($PEBBLE)`, so it skips itself when the variable is unset and `pebble` is not in `PATH` |
| `PROVE_ARGS` | Extra arguments for `prove` (e.g. `-v`, `-j4`) |

**Skip conditions belong in the suite, not in the Makefile.** nginx-tests
already owns that vocabulary — `has_daemon`, `has`, `try_run`,
`plan(skip_all => ...)`, and guarded `eval { require ... }` — and the
pkg-oss-tests conversion rules require every suite to be self-contained in this
respect. Do not add per-module skip logic to the platform Makefiles; a suite
that needs an external daemon or CPAN module must guard itself so that a plain
`make test` degrades to a skip rather than a failure.

### Where a module's tests come from

A module's test directory is not declared per-module. It is resolved by the
platform driver, by convention, relative to the staged local copy:

```
pkg-oss-tests/<nickname>/t
```

If that directory does not exist, the module simply has no suite and is skipped
— that covers `geoip`, `image-filter`, `ndk`, `otel`, `passenger`, `perl` and
`xslt` with no exception list to maintain. Adding a suite for an existing module
therefore requires **no pkg-oss change at all**: create `<nickname>/t/` in
pkg-oss-tests and it is picked up.

Two modules maintain their suite upstream in their own source tree and are
handled by explicit `case` arms in each platform driver:

```sh
acme)	testdir=$$pwd/<SRCROOT>/nginx-acme-$(NGINX_ACME_VERSION)/t ;;
njs)	testdir=$$pwd/<SRCROOT>/njs-$(NJS_VERSION)/nginx/t ;;
*)	testdir=pkg-oss-tests/$$m/t ;;
```

They live in the driver rather than in `Makefile.module-<n>` because `<SRCROOT>`
— where a module's unpacked source lands in the build tree — is platform
knowledge, not module knowledge:

| platform | `<SRCROOT>` |
|---|---|
| alpine | `abuild-module-<n>/src` |
| debian | `debuild-module-<n>/$(SRCDIR)/debian/extra` |
| rpm | `module-<n>/..` |

This is the same category as the `perl` `objs/` path and the `lua`
`lua-resty-*` paths, which are hardcoded in the drivers for the same reason.
A third in-tree suite means adding one `case` arm to each of the three drivers.

Both `nginx-tests` and `pkg-oss-tests` are prerequisites of `test` /
`test-debug`, so the checkouts are fetched and copied in unconditionally by the
shared rule shown at the top of this section.

**Do not point a build or test at `$(CONTRIB)/tarballs/nginx-tests` or
`$(CONTRIB)/tarballs/pkg-oss-tests` directly.** Those are shared source clones.
The staging step does `rm -rf nginx-tests/module-<n>` and copies into it, so if
the local `nginx-tests/` is a symlink to the contrib clone (which is what
`cp -rP` produces when `$(CONTRIB)/tarballs/nginx-tests` is itself a symlink),
staging writes *through* it and pollutes the shared clone with stray
`module-*/` directories. If a checkout starts behaving oddly, run
`git clean -fd` inside `contrib/tarballs/nginx-tests`.

Staging copies the directory to `nginx-tests/module-<n>/`, replacing any
previous copy, and symlinks `lib -> ../lib` unless the suite ships a `lib/` of
its own (`acme` does: `Test::Nginx::ACME`, `Test::Nginx::DNS`). `prove` is
always given `-I<pwd>/nginx-tests/lib`, so `Test::Nginx` resolves either way.

**Variable naming convention:** module variable suffixes always use underscores
even when the module nickname contains dashes (e.g. `set-misc` → `set_misc`).
The recipes look these up through `$(call modname, ...)` (which calls
`tr '-' '_'`), so define them with underscores.

### NDK load order

`ndk` (`ngx_devel_kit`) is the project's only inter-module load dependency:
`encrypted-session`, `lua`, and `set-misc` compile against it and need
`ndk_http_module.so` loaded before their own `.so`. There is no per-module
declaration for this — the platform driver derives the dependent set from the
same condition that already determines the build:

```make
NDK_MODULES=	$(filter-out ndk,$(foreach m,$(MODULES),$(if $(findstring ngx_devel_kit,$(MODULE_CONFARGS_$(call modname, $(m)))),$(m))))
```

A module is in `NDK_MODULES` if and only if its `MODULE_CONFARGS_<n>` contains
`ngx_devel_kit` — the same fact that makes it delete `objs/ndk_http_module.so`
in its own `MODULE_PREINSTALL_<n>` so the two packages don't collide. This
derivation cannot drift out of sync with the build the way a hand-maintained
list could.

It drives two things in `test` / `test-debug`: when any module in
`NDK_MODULES` is built but `module-ndk/` is not, `make module-ndk` runs first;
and the `load_module` loop always emits `ndk` ahead of every other module
(`for m in ndk $(filter-out ndk,$(MODULES))`), not a plain sort — `ndk`'s
module name (`ndk_http_module`) happens to sort before the `ngx_*` dependents
today, but that's a coincidence not a guarantee, so the loop states the order
explicitly instead of relying on it.

If a future module needs a different inter-module load order, add another
derived variable in this style rather than a per-module test variable.

---

## 12. CI Testing Architecture

The CI (`github/workflows/ci.yml`) splits each platform into two jobs to avoid
rebuilding nginx once per module:

| Job | Purpose |
|---|---|
| `alpine-base` / `ubuntu-base` / `redhat-base` | Builds nginx, uploads `base/nginx` as a GitHub Actions artifact |
| `alpine` / `ubuntu` / `redhat` | Module matrix (no `base` entry); downloads artifact; builds and tests modules |

The module matrix jobs `needs:` their platform's base job, so the artifact is
guaranteed to exist before any module job starts.

### How Make accepts the downloaded binary

The artifact is downloaded into `{platform}/base/`. Make sees `base/` already
exists as a directory and considers the `base` target satisfied without
rebuilding. No Makefile changes are required.

### Per-module test environment — `.github/test-env/`

Scripts in `.github/test-env/module-<name>.sh` are executed by CI before each
module's test step (`make test TEST_MODULES=<name>`). They write to
`$GITHUB_ENV` to export
module-specific environment variables into the subsequent test step. The script
uses `$GITHUB_WORKSPACE` for path discovery — no platform-specific logic is
needed.

**To add test setup for a new module:** create
`.github/test-env/module-<name>.sh`. No CI YAML changes are required.

Example — `module-acme.sh` discovers and activates the Pebble ACME test server:

```sh
#!/bin/bash
PEBBLE=$(find "$GITHUB_WORKSPACE" -path "*/nginx-acme-*/build/get-pebble.pl" \
         -type f 2>/dev/null | head -1)
[ -n "$PEBBLE" ] && echo "TEST_NGINX_PEBBLE_BINARY=$(perl "$PEBBLE")" >> "$GITHUB_ENV"
```

---

## 13. Platform Compatibility and Skip Files

Some modules cannot be built on certain platforms or architectures (e.g. GeoIP
is not available on RHEL ≥ 8; LuaJIT does not support ppc64le/s390x; OTel
requires a newer toolchain than Ubuntu 18.04 or RHEL 7 provide).

The `check-compat-<name>` target inspects the current OS/distro version and
writes `nginx-module-<name>.skip` when a module must be skipped. The
`make module-<name>` target honours this skip file and exits cleanly.

**Do not delete `.skip` files manually.** They are regenerated by
`make check-compat-<name>` and exist for a reason. If a module is being enabled
for a new platform, the relevant compatibility check in the platform `Makefile`
must be updated instead.

---

## 14. OSS vs Plus Dual-mode

All three platform Makefiles support a `BASE_TARGET` variable:

| Value | Behaviour |
|---|---|
| `oss` (default) | Builds against NGINX Open Source; uses `alpine/alpine/`, `debian/debian/`, standard spec templates |
| `plus` | Builds against NGINX Plus; uses `alpine/alpine-plus/`, `debian/debian-plus/`, Plus spec template; adds EULA and Plus-specific configure flags |

Usage:

```sh
BASE_TARGET=plus make module-njs
BASE_TARGET=plus make base
```

The `MODULE_TARGET` variable (`oss` / `plus`) controls whether module packages
declare a dependency on `nginx` or `nginx-plus`. It defaults to the same value
as `BASE_TARGET`.

---

## 15. Changelog and Documentation

### XML changelog format

`docs/*.xml` is the canonical release history for every package. Each file
contains one or more `<changes>` blocks, newest first:

```xml
<change_log title="nginx_module_njs">

  <changes apply="nginx-module-njs" ver="1.0.0" rev="1" basever="1.31.3"
           date="2025-04-15" time="15:00:00 +0000"
           packager="NGINX Packaging <nginx-packaging@f5.com>">
    <change>
      <para>upgraded to njs-1.0.0</para>
    </change>
  </changes>

</change_log>
```

Key attributes:
- `apply` — package name (must match the filename stem)
- `ver` — upstream module version
- `rev` — package release number
- `basever` — NGINX version this was built against
- `date` / `time` — release timestamp

### Generating formatted changelogs

```sh
make -C docs changes
```

This produces `*.rpm-changelog` and `*.deb-changelog` files consumed by the
platform build targets. Run this after editing any `docs/*.xml` file to keep the
generated files current.

---

## 16. `build_module.sh` — Packaging 3rd-party Modules

`build_module.sh` is a standalone POSIX shell script for packaging arbitrary
3rd-party dynamic modules without modifying this repository. It:

1. Detects the local package manager (`yum`, `apt-get`, or `apk`)
2. Installs build prerequisites
3. Fetches the module source from a URL or local path
4. Clones this pkg-oss repository
5. Generates a `Makefile.module-<name>` scaffold
6. Calls the appropriate platform `make module-<name>`
7. Copies the finished packages to an output directory

### Usage

```sh
./build_module.sh [options] <URL | /path/to/module/source>
```

### Options

| Option | Description |
|---|---|
| `-n <nickname>` | Module nickname — lowercase alphanumeric only, used in package names |
| `-V <ver[-rel]>` | Module version string (default: `1.0-1`) |
| `-v [<oss-ver>]` | Build against this NGINX OSS version (default: current mainline) |
| `-r <plus-rel>` | Build against the OSS version corresponding to this NGINX Plus release (`NN[pN]` or `NN.N[.N]`) |
| `-o <dir>` | Output directory for finished packages (default: `./build-module-artifacts/`) |
| `-y` | Non-interactive — auto-confirm all prompts and overwrite existing files |
| `-f` | Force-convert a static module config to dynamic (experimental) |
| `-s` | Skip dependency installation |

### Source formats accepted

- **Git URL** (ending in `.git`): cloned with `git clone --recursive`
- **Zip archive URL**: downloaded and extracted
- **Tarball URL** (any other suffix): downloaded and extracted with `tar`
- **Local directory path**: copied directly

### Requirements

- The module source must contain a `config` file that includes `. auto/module`
  (dynamic module convention). Use `-f` to attempt auto-conversion if the module
  only has a static `config`.
- NGINX version must be ≥ 1.11.5 (dynamic module support).

### Example

```sh
# Build the headers-more module against the current mainline
./build_module.sh -n headersmore -y \
    https://github.com/openresty/headers-more-nginx-module/archive/v0.37.tar.gz

# Build against NGINX Plus R37
./build_module.sh -n headersmore -r 37 -y \
    https://github.com/openresty/headers-more-nginx-module/archive/v0.37.tar.gz
```

Finished packages are placed in `./build-module-artifacts/` (or the path given
with `-o`).

> **Note:** The script is intended as a demonstration tool. The packages it
> produces are not for redistribution.

---

## 17. Supply-chain and Attestation

### SHA512 verification

Every source tarball in `contrib/src/<dep>/SHA512SUMS` is verified by
`contrib/Makefile` before it is unpacked. The format is standard `sha512sum`
output:

```
<hex-digest>  <filename>
```

If a checksum is missing or incorrect, the build aborts. Always add the
checksum before pushing a dep update.

### Attestation artifacts

`contrib/attestation.mak` provides targets that generate SLSA-style provenance
sidecar files listing each dependency's name, version, commit hash, and SHA512:

```sh
make attest-base              # attestation for the NGINX base package
make attest-module-<name>     # attestation for a module
```

These are generated as part of the release process and should be regenerated
whenever dependency versions change.

---

## 18. Commit and PR Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <subject>

<body>
```

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `ci`

Common scopes: `njs`, `otel`, `brotli`, `debian`, `alpine`, `rpm`, `contrib`

Rules:
- Subject line ≤ 72 characters
- Present tense, imperative mood ("Add feature" not "Added feature")
- Reference issues and PRs in the commit body
- Squash/rebase locally before submitting a PR; keep the history clean
- Fork the repo, work on a branch, and open a PR when changes are tested

---

## 19. Key Gotchas

**Always update all three platform Makefile.module files together.**
`alpine/Makefile.module-<n>`, `debian/Makefile.module-<n>`, and
`rpm/SPECS/Makefile.module-<n>` must stay in sync. A version bump in only one
platform will cause divergent package versions across distros.

**`MODULE_BUILD_DEPENDS` syntax differs by platform.**
- Alpine: space-separated: `MODULE_BUILD_DEPENDS_njs= libedit-dev libxml2-dev`
- Debian: leading comma for each entry: `MODULE_BUILD_DEPENDS_njs= ,libedit-dev,libxml2-dev`

**Shell inside `define … endef` requires escaped special characters.**
- `$` → `$$`
- `&&` → `\&\&`
- `\` (line continuation in shell) → `\` (single backslash, but watch context)

**`contrib/tarballs/` is git-ignored and unpopulated in a fresh clone.**
Run `make fetch` or `make install` from `contrib/` before attempting a package
build from source.

**Never edit generated packaging files.**
Files like `debian/nginx-module-njs/debian/control` or
`rpm/SPECS/nginx-module-njs.spec` are generated outputs. Always edit the
corresponding `.in` template.

**SHA512SUMS is append-only.**
Remove a line from `contrib/src/<dep>/SHA512SUMS` only if the corresponding
tarball was never published (i.e. a mistake before any public release). For all
other cases, keep historical entries.

**`MODULE_RELEASE_<n>` semantics:**
- Reset to `1` when `MODULE_VERSION_<n>` changes (new upstream release).
- Increment (to `2`, `3`, …) for packaging-only fixes that do not change the
  upstream module version.

**The root `Makefile` `make release` is destructive.**
It rewrites version files and injects changelog entries across the whole
repository. Do not run it unless you are performing an intentional version bump
for a release.

**Platform skip files are authoritative.**
If `nginx-module-<name>.skip` exists in a platform build directory, the module
will not be built there. This is intentional. Fix the underlying compatibility
check in the platform `Makefile` rather than deleting the skip file.

**`check-compat-%` does not create its own target file.** *(debian and rpm only
— alpine has no compatibility-check or skip-file mechanism at all.)*
The `check-compat-%` recipe writes `.skip` files for incompatible modules but
never creates a file named `check-compat-*`. Because the target file never
exists, Make re-runs the recipe every time it appears as a prerequisite of
`module-%`. When the recipe re-runs after `module-%` was already built, Make
considers `module-%` out of date and triggers a full rebuild. This only affects
`make module-<n>` itself — `make test` has no `module-%` prerequisite, so the
old CI `touch module-${MODULE}` workaround is no longer needed and has been
removed.

**The test targets are identical on all three platforms.**
`test` and `test-debug` are the only test entry points; there is no
`test-module-%`. They share a single recipe per platform that stages and runs
every built module's suite, narrowable with `TEST_MODULES` (see §11). The three
recipes differ only in the build-tree paths (`<SRCROOT>`, perl `objs/`, lua
`lua-resty-*`), so keep them in sync when changing one.

**Staging must not be made conditional on `TEST_MODULES`.**
`TEST_MODULES` filters what is handed to `prove`; it must never gate the
staging loop. CI runs `make test TEST_MODULES=<name>` as the only test command
after a fresh checkout, so gating staging on an unset `TEST_MODULES` makes
every per-module CI job exit 0 without running a single test.

**`contrib/Makefile` tar/unzip output is quiet by default.**
Use `V=1 make install` (or `V=1 make fetch`) to restore verbose tar and unzip
output during source unpacking.
