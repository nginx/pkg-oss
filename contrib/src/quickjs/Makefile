# quickjs

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
QUICKJS_GITURL := $(GITHUB)/bellard/quickjs

PKGS += quickjs

$(TARBALLS)/quickjs-$(QUICKJS_VERSION).tar.xz:
	$(call download_git,$(QUICKJS_GITURL),,$(QUICKJS_GITHASH))

.sum-quickjs: quickjs-$(QUICKJS_VERSION).tar.xz
	$(call check_githash,$(QUICKJS_GITHASH))
	touch $@

quickjs: quickjs-$(QUICKJS_VERSION).tar.xz .sum-quickjs
	$(UNPACK)
	$(APPLY) $(SRC)/quickjs/quickjs.makefile.patch
	$(MOVE)

.quickjs: quickjs
	cd $< && $(MAKE) $(_SMP_MFLAGS) install PREFIX=$(PREFIX)
	touch $@
