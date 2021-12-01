all: install

TOPSRC := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SRC := $(TOPSRC)/src
TARBALLS := $(TOPSRC)/tarballs
VPATH := $(TARBALLS)
PREFIX = $(TOPSRC)/local
PREFIX := $(abspath $(PREFIX))

PKGS_ALL := $(patsubst $(SRC)/%/Makefile,%,$(wildcard $(SRC)/*/Makefile))

# Common download locations
NGINX := https://nginx.org/download
CONTRIB_NGINX := https://packages.nginx.org/contrib
GITHUB := https://github.com

#
# Tools
#
NPROC := $(shell getconf _NPROCESSORS_ONLN)
_SMP_MFLAGS := -j$(NPROC)

ifndef GIT
ifeq ($(shell git --version >/dev/null 2>&1 || echo FAIL),)
GIT = git
endif
endif
GIT ?= $(error git not found)

ifeq ($(shell curl --version >/dev/null 2>&1 || echo FAIL),)
download = curl -f -L -- "$(1)" > "$@"
else ifeq ($(shell wget --version >/dev/null 2>&1 || echo FAIL),)
download = (rm -f $@.tmp && \
	wget --passive -c -p -O $@.tmp "$(1)" && \
	touch $@.tmp && \
	mv $@.tmp $@ )
else ifeq ($(which fetch >/dev/null 2>&1 || echo FAIL),)
download = (rm -f $@.tmp && \
	fetch -p -o $@.tmp "$(1)" && \
	touch $@.tmp && \
	mv $@.tmp $@)
else
download = $(error Neither curl nor wget found)
endif

download_pkg = $(call download,$(CONTRIB_NGINX)/$(2)/$(lastword $(subst /, ,$(@)))) || \
	( $(call download,$(1)) && echo "Please upload $(lastword $(subst /, ,$(@))) to $(CONTRIB_NGINX)" )

ifeq ($(shell which xz >/dev/null 2>&1 || echo FAIL),)
XZ = xz
else
XZ ?= $(error XZ (LZMA) compressor not found)
endif

ifeq ($(shell sha512sum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = sha512sum --check
else ifeq ($(shell shasum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = shasum -a 512 --check
else ifeq ($(shell openssl version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = openssl dgst -sha512
else
SHA512SUM = $(error SHA-512 checksumming not found)
endif

CMAKE_MIN_VERSION = 3.1
ifndef CMAKE
_CMAKE_VERSION := $(shell cmake --version 2>/dev/null | head -1 | cut -d ' ' -f 3)
_CMAKE3_VERSION := $(shell cmake3 --version 2>/dev/null | head -1 | cut -d ' ' -f 3)
ifeq ($(shell test "$(_CMAKE_VERSION)" = "`echo -e "$(_CMAKE_VERSION)\n$(CMAKE_MIN_VERSION)" | sort -V | tail -1`" || echo FAIL),)
CMAKE = cmake
else ifeq ($(shell test "$(_CMAKE3_VERSION)" = "`echo -e "$(_CMAKE3_VERSION)\n$(CMAKE_MIN_VERSION)" | sort -V | tail -1`" || echo FAIL),)
CMAKE = cmake3
endif
endif
CMAKE ?= $(error cmake >= $(CMAKE_MIN_VERSION) not found)

#
# Common helpers
#
download_git = \
	rm -Rf -- "$(@:.tar.xz=)" && \
	$(GIT) init --bare "$(@:.tar.xz=)" && \
	(cd "$(@:.tar.xz=)" && \
	$(GIT) remote add origin "$(1)" && \
	$(GIT) fetch origin "$(2)") && \
	(cd "$(@:.tar.xz=)" && \
	$(GIT) archive --prefix="$(notdir $(@:.tar.xz=))/" \
		--format=tar "$(3)") > "$(@:.xz=)" && \
	echo "$(3) $(@)" > "$(@:.tar.xz=.githash)" && \
	rm -Rf -- "$(@:.tar.xz=)" && \
	$(XZ) --stdout "$(@:.xz=)" > "$@.tmp" && \
	rm -f "$(@:.xz=)" && \
	mv -f -- "$@.tmp" "$@"
check_githash = \
	h=`sed -e "s,^\([0-9a-fA-F]\{40\}\) .*/$(notdir $<),\1,g" \
		< "$(<:.tar.xz=.githash)"` && \
	test "$$h" = "$1"

checksum = \
	$(foreach f,$(filter $(TARBALLS)/%,$^), \
		grep -- " $(f:$(TARBALLS)/%=%)$$" \
			"$(SRC)/$(patsubst $(3)%,%,$@)/$(2)SUMS" |) \
		(cd $(TARBALLS) && $(1))
CHECK_SHA512 = $(call checksum,$(SHA512SUM),SHA512,.sum-)
UNPACK = $(RM) -R $@ \
	$(foreach f,$(filter %.tar.gz %.tgz,$^), && tar xvzfo $(f)) \
	$(foreach f,$(filter %.tar.bz2,$^), && tar xvjfo $(f)) \
	$(foreach f,$(filter %.tar.xz,$^), && tar xvJfo $(f)) \
	$(foreach f,$(filter %.zip,$^), && unzip $(f))
UNPACK_DIR = $(patsubst %.tar,%,$(basename $(notdir $<)))
APPLY = (cd $(UNPACK_DIR) && patch -fp1) <
MOVE = mv $(UNPACK_DIR) $@ && touch $@

# Per-package build rules
include $(SRC)/*/Makefile

# Targets
PKGS_DEPS := $(sort $(foreach p,$(PKGS),$(DEPS_$(p))))

fetch: $(PKGS:%=.sum-%)
install: $(PKGS:%=.%)

clean:
	-$(RM) $(foreach p,$(PKGS),.$(p) .sum-$(p) .dep-$(p))
	-$(RM) -R $(foreach p,$(PKGS),$(p))
	-$(RM) -R "$(PREFIX)"
	-$(RM) $(TARBALLS)/*.*

list:
	@echo Packages:
	@echo '  $(PKGS)' | tr " " "\n" | sort | tr "\n" " " |fmt
	@echo Depended-on packages:
	@echo '  $(PKGS_DEPS)' | tr " " "\n" | sort | tr "\n" " " |fmt

.PHONY: all fetch install clean list

# Default pattern rules
.sum-%: $(SRC)/%/SHA512SUMS
	$(CHECK_SHA512)
	touch $@

.sum-%:
	$(error Download and check target not defined for $*)

# Real dependency on missing packages
$(patsubst %,.dep-%,$(PKGS)): .dep-%: .%
	touch -r $< $@

.SECONDEXPANSION:

# Dependency propagation (convert 'DEPS_foo = bar' to '.foo: .bar')
$(foreach p,$(PKGS),.$(p)): .%: $$(foreach d,$$(DEPS_$$*),.dep-$$(d))

.DELETE_ON_ERROR:
