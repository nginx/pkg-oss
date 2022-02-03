# libinjection

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version

LIBINJECTION_URL:= $(GITHUB)//libinjection/libinjection.git

PKGS += libinjection

$(TARBALLS)/libinjection-$(LIBINJECTION_GITHASH).tar.xz:
	$(call download_git,$(LIBINJECTION_URL),,$(LIBINJECTION_GITHASH))

.sum-libinjection: libinjection-$(LIBINJECTION_GITHASH).tar.xz
	$(call check_githash,$(LIBINJECTION_GITHASH))
	touch $@

libinjection: libinjection-$(LIBINJECTION_GITHASH).tar.xz .sum-libinjection
	$(UNPACK)
	$(MOVE)

.libinjection: libinjection
	touch $@
