# LuaJIT2

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
LUAJIT2_URL := $(GITHUB)/openresty/luajit2/archive/v$(LUAJIT2_VERSION).tar.gz

PKGS += luajit2

$(TARBALLS)/luajit2-$(LUAJIT2_VERSION).tar.gz:
	$(call download_pkg,$(LUAJIT2_URL),luajit2)

.sum-luajit2: luajit2-$(LUAJIT2_VERSION).tar.gz

luajit2: luajit2-$(LUAJIT2_VERSION).tar.gz .sum-luajit2
	$(UNPACK)
	$(APPLY) $(SRC)/luajit2/Makefile.patch
	$(APPLY) $(SRC)/luajit2/src-luaconf.h.patch
	$(MOVE)

.luajit2: luajit2
	cd $< && DESTDIR=$(PREFIX) CFLAGS="-fPIC" $(MAKE) install
	mv $(PREFIX)/usr/bin/luajit $(PREFIX)/usr/bin/nginx-luajit
	touch $@
