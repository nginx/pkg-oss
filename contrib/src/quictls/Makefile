# quictls

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
QUICTLS_GITURL := $(GITHUB)/quictls/openssl

PKGS += quictls

$(TARBALLS)/quictls-$(QUICTLS_VERSION).tar.xz:
	$(call download_git,$(QUICTLS_GITURL),,$(QUICTLS_GITHASH))

.sum-quictls: quictls-$(QUICTLS_VERSION).tar.xz
	$(call check_githash,$(QUICTLS_GITHASH))
	touch $@

quictls: quictls-$(QUICTLS_VERSION).tar.xz .sum-quictls
	$(UNPACK)
	$(MOVE)

.quictls: quictls
	touch $@
