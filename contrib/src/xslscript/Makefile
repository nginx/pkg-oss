# xslscript

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
XSLSCRIPT_URL := https://hg.nginx.org/xslscript/archive/$(XSLSCRIPT_VERSION).tar.gz

PKGS += xslscript

$(TARBALLS)/xslscript-$(XSLSCRIPT_VERSION).tar.gz:
	$(call download_pkg,$(XSLSCRIPT_URL),xslscript)

.sum-xslscript: xslscript-$(XSLSCRIPT_VERSION).tar.gz

xslscript: xslscript-$(XSLSCRIPT_VERSION).tar.gz .sum-xslscript
	$(UNPACK)
	$(MOVE)

.xslscript: xslscript
	cd $< && chmod +x ./xslscript.pl
	touch $@
