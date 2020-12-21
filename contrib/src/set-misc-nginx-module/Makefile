# set-misc-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
SET_MISC_NGINX_MODULE_URL := $(GITHUB)/openresty/set-misc-nginx-module/archive/v$(SET_MISC_NGINX_MODULE_VERSION).tar.gz

PKGS += set-misc-nginx-module

$(TARBALLS)/set-misc-nginx-module-$(SET_MISC_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(SET_MISC_NGINX_MODULE_URL),set-misc-nginx-module)

.sum-set-misc-nginx-module: set-misc-nginx-module-$(SET_MISC_NGINX_MODULE_VERSION).tar.gz

set-misc-nginx-module: set-misc-nginx-module-$(SET_MISC_NGINX_MODULE_VERSION).tar.gz .sum-set-misc-nginx-module
	$(UNPACK)
	$(MOVE)

DEPS_set-misc-nginx-module = ngx_devel_kit $(DEPS_ngx_devel_kit)

.set-misc-nginx-module: set-misc-nginx-module
	touch $@
