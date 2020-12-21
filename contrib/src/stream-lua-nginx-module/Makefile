# stream-lua-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
STREAM_LUA_NGINX_MODULE_URL := $(GITHUB)/openresty/stream-lua-nginx-module/archive/v$(STREAM_LUA_NGINX_MODULE_VERSION).tar.gz

PKGS += stream-lua-nginx-module

$(TARBALLS)/stream-lua-nginx-module-$(STREAM_LUA_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(STREAM_LUA_NGINX_MODULE_URL),stream-lua-nginx-module)

.sum-stream-lua-nginx-module: stream-lua-nginx-module-$(STREAM_LUA_NGINX_MODULE_VERSION).tar.gz

stream-lua-nginx-module: stream-lua-nginx-module-$(STREAM_LUA_NGINX_MODULE_VERSION).tar.gz .sum-stream-lua-nginx-module
	$(UNPACK)
	$(APPLY) $(SRC)/stream-lua-nginx-module/config.patch
	$(MOVE)

DEPS_stream-lua-nginx-module = luajit2 $(DEPS_luajit2) ngx_devel_kit $(DEPS_ngx_devel_kit)

.stream-lua-nginx-module: stream-lua-nginx-module
	touch $@
