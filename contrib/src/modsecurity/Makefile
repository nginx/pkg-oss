# ModSecurity

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version

# The release tarball distributed from GitHub does not include
# all the required submodules (libinjection in particular), so
# we are building our own tarball by running build.sh + configure +
# make dist from desired version tag.
#
# MODSECURITY_URL := $(GITHUB)/SpiderLabs/ModSecurity/archive/v$(MODSECURITY_VERSION).tar.gz
MODSECURITY_URL := $(CONTRIB_NGINX)/modsecurity/modsecurity-v$(MODSECURITY_VERSION).tar.gz

PKGS += modsecurity

$(TARBALLS)/modsecurity-v$(MODSECURITY_VERSION).tar.gz:
	$(call download_pkg,$(MODSECURITY_URL),modsecurity)

.sum-modsecurity: modsecurity-v$(MODSECURITY_VERSION).tar.gz

modsecurity: modsecurity-v$(MODSECURITY_VERSION).tar.gz .sum-modsecurity
	$(UNPACK)
	$(APPLY) $(SRC)/modsecurity/older-libmaxminddb-compatibility.patch
	$(MOVE)

.modsecurity: modsecurity
	cd $< && \
		./configure --prefix $(PREFIX) --without-lmdb --without-lua && \
		make $(_SMP_MFLAGS) install && \
		TERM=foo make check-TESTS
	rm -f /tmp/audit_test.log /tmp/audit_test_parallel.log
	rm -rf /tmp/test
	touch $@
