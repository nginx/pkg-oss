# lua-resty-lrucache

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
LUA_RESTY_LRUCACHE_URL := $(GITHUB)/openresty/lua-resty-lrucache/archive/v$(LUA_RESTY_LRUCACHE_VERSION).tar.gz

PKGS += lua-resty-lrucache

$(TARBALLS)/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION).tar.gz:
	$(call download_pkg,$(LUA_RESTY_LRUCACHE_URL),lua-resty-lrucache)

.sum-lua-resty-lrucache: lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION).tar.gz

lua-resty-lrucache: lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION).tar.gz .sum-lua-resty-lrucache
	$(UNPACK)
	$(MOVE)

.lua-resty-lrucache: lua-resty-lrucache
	touch $@
