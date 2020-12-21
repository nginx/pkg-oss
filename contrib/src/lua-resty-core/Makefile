# lua-resty-core

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
LUA_RESTY_CORE_URL := $(GITHUB)/openresty/lua-resty-core/archive/v$(LUA_RESTY_CORE_VERSION).tar.gz

PKGS += lua-resty-core

$(TARBALLS)/lua-resty-core-$(LUA_RESTY_CORE_VERSION).tar.gz:
	$(call download_pkg,$(LUA_RESTY_CORE_URL),lua-resty-core)

.sum-lua-resty-core: lua-resty-core-$(LUA_RESTY_CORE_VERSION).tar.gz

lua-resty-core: lua-resty-core-$(LUA_RESTY_CORE_VERSION).tar.gz .sum-lua-resty-core
	$(UNPACK)
	$(MOVE)

.lua-resty-core: lua-resty-core
	touch $@
