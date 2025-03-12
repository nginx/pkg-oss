# quickjs

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
QUICKJS_URL := $(GITHUB)/bellard/quickjs/archive/$(QUICKJS_GITHASH).tar.gz

PKGS += quickjs

$(TARBALLS)/quickjs-$(QUICKJS_VERSION)-$(QUICKJS_GITHASH).tar.gz:
	$(call download_pkg,$(QUICKJS_URL),quickjs)

.sum-quickjs: quickjs-$(QUICKJS_VERSION)-$(QUICKJS_GITHASH).tar.gz

quickjs: quickjs-$(QUICKJS_VERSION)-$(QUICKJS_GITHASH).tar.gz .sum-quickjs
	$(UNPACK)
	$(APPLY) $(SRC)/quickjs/quickjs.makefile.patch
	$(MOVE)

.quickjs: quickjs
	cd $< && $(MAKE) $(_SMP_MFLAGS) install PREFIX=$(PREFIX)
	touch $@
