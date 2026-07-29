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
│       └── module-<name>.sh   # Sourced by CI before make test-module-<name>
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

# Run the full test suite
make test

# Run tests against the nginx-debug binary
make test-debug

# Run tests for a specific module only
make test-module-<name>

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
| `MODULE_TESTS_<n>` | if needed | Path inside the unpacked module source tree to its nginx-tests `t/` directory (enables `make test-module-<n>`) |
| `MODULE_TESTS_DEPS_<n>` | if needed | Space-separated list of module nicknames whose `.so` files must be loaded **before** the main module's `.so` during `make test-module-<n>` (e.g. `ndk` for `set-misc`) |
| `MODULE_TESTS_CONTRIB_DEPS_<n>` | if needed | Space-separated list of contrib dep names to fetch before running tests (e.g. `openresty-test-nginx` for `set-misc`) |

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

For modules whose tests use OpenResty's declarative `Test::Nginx::Socket` format
(e.g. `set-misc`, `lua`, `headers-more`), the [openresty-test-nginx](https://github.com/openresty/test-nginx)
library is also required. It is cloned via `contrib/src/openresty-test-nginx` and its `lib/`
is automatically added to `prove`'s include path (`-I<contrib>/tarballs/openresty-test-nginx/lib`) when
`make test-module-<n>` is invoked — no extra setup is needed.

### Test targets

Run from the platform directory (`alpine/`, `debian/`, or `rpm/SPECS/`):

| Target | What it runs |
|---|---|
| `make test` | Full suite against the release binary and all built modules |
| `make test-debug` | Full suite against `nginx-debug` and debug `.so` files |
| `make test-module-<name>` | Only the tests for a specific module |

### Environment variables

| Variable | Purpose |
|---|---|
| `TEST_NGINX_BINARY` | Path to the nginx binary under test |
| `TEST_NGINX_GLOBALS` | Directives prepended to `nginx.conf`; the Makefile **appends** the generated `load_module` directives to whatever is already in this variable |
| `TEST_NGINX_GLOBALS_HTTP` | Directives injected into the `http {}` block |
| `TEST_NGINX_GLOBALS_STREAM` | Directives injected into the `stream {}` block |
| `TEST_NGINX_PEBBLE_BINARY` | Path to the Pebble ACME test server binary (required for acme module tests; tests fail if unset) |

### Module test path

`MODULE_TESTS_<n>` must point to the `t/` directory inside the unpacked module
source tree. It is supported on all three platforms:

```make
MODULE_TESTS_njs=      njs-$(NJS_VERSION)/nginx/t/
MODULE_TESTS_acme=     nginx-acme-$(NGINX_ACME_VERSION)/t/
MODULE_TESTS_set_misc= set-misc-nginx-module-$(SET_MISC_NGINX_MODULE_VERSION)/t/
```

When set, `make test-module-<n>` copies the test directory into `nginx-tests/`
and runs `prove` against it. The recipe always passes
`-I$$pwd/nginx-tests/lib` and `-I$(CONTRIB)/tarballs/openresty-test-nginx/lib` so both `Test::Nginx`
(official) and `Test::Nginx::Socket` (OpenResty) are on the include path.

**Variable naming convention:** module variable suffixes always use underscores
even when the module nickname contains dashes (e.g. `set-misc` → `set_misc`).
The `test-module-%` recipe uses `$(call modname, $*)` (which calls
`tr '-' '_'`) when looking up `MODULE_TESTS_<n>` and `MODULE_TESTS_DEPS_<n>`,
so define these variables with underscores.

### Load-order dependencies

If a module's tests require another module's `.so` to be loaded first (e.g.
`ndk_http_module.so` before `ngx_http_set_misc_module.so`), set
`MODULE_TESTS_DEPS_<n>` to the space-separated list of prerequisite module
nicknames:

```make
MODULE_TESTS_DEPS_set_misc= ndk
```

The recipe prepends those `.so` files to `TEST_NGINX_GLOBALS` before the main
module's `.so`, ensuring correct load order. The prerequisite module must
already be built (via `prerequisites-for-module-<n>`) by the time
`make test-module-<n>` runs.

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
`make test-module-<name>` invocation. They write to `$GITHUB_ENV` to export
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

**`check-compat-%` does not create its own target file.**
The `check-compat-%` recipe writes `.skip` files for incompatible modules but
never creates a file named `check-compat-*`. Because the target file never
exists, Make re-runs the recipe every time it appears as a prerequisite of
`module-%`. When the recipe re-runs after `module-%` was already built, Make
considers `module-%` out of date and triggers a full rebuild. In CI this is
worked around with `touch module-${MODULE}` immediately before invoking
`make test-module-${MODULE}`. Locally, running `make test-module-<n>` on a
fresh checkout is unaffected.

**`contrib/Makefile` tar/unzip output is quiet by default.**
Use `V=1 make install` (or `V=1 make fetch`) to restore verbose tar and unzip
output during source unpacking.
