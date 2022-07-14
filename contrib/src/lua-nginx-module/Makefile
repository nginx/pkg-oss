# lua-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
LUA_NGINX_MODULE_URL := $(GITHUB)/openresty/lua-nginx-module/archive/v$(LUA_NGINX_MODULE_VERSION).tar.gz

PKGS += lua-nginx-module

$(TARBALLS)/lua-nginx-module-$(LUA_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(LUA_NGINX_MODULE_URL),lua-nginx-module)

.sum-lua-nginx-module: lua-nginx-module-$(LUA_NGINX_MODULE_VERSION).tar.gz

lua-nginx-module: lua-nginx-module-$(LUA_NGINX_MODULE_VERSION).tar.gz .sum-lua-nginx-module
	$(UNPACK)
	$(APPLY) $(SRC)/lua-nginx-module/config.patch
	$(APPLY) $(SRC)/lua-nginx-module/0001-bugfix-update-handling-of-multiple-headers-changed-i.patch
	$(MOVE)

DEPS_lua-nginx-module = luajit2 $(DEPS_luajit2) ngx_devel_kit $(DEPS_ngx_devel_kit)

.lua-nginx-module: lua-nginx-module
	touch $@
