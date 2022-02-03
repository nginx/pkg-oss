# ModSecurity

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version

MODSECURITY_GITURL := $(GITHUB)/SpiderLabs/ModSecurity.git

PKGS += modsecurity

$(TARBALLS)/modsecurity-$(MODSECURITY_GITHASH).tar.xz:
	#$(call download_pkg,$(MODSECURITY_URL),modsecurity)
	$(call download_git,$(MODSECURITY_GITURL),,$(MODSECURITY_GITHASH))

.sum-modsecurity: modsecurity-$(MODSECURITY_GITHASH).tar.xz
	$(call check_githash,$(MODSECURITY_GITHASH))

modsecurity: modsecurity-$(MODSECURITY_GITHASH).tar.xz .sum-modsecurity
	$(UNPACK)
	$(APPLY) $(SRC)/modsecurity/older-libmaxminddb-compatibility.patch
	$(APPLY) $(SRC)/modsecurity/PR2580.patch
	$(MOVE)

.modsecurity: modsecurity
	cd $< && \
		./configure --prefix $(PREFIX) --without-lmdb --without-lua && \
		make $(_SMP_MFLAGS) install && \
		TERM=foo make check-TESTS
	rm -f /tmp/audit_test.log /tmp/audit_test_parallel.log
	rm -rf /tmp/test
	touch $@
