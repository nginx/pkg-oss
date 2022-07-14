# headers-more-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
HEADERS_MORE_NGINX_MODULE_GITURL := $(GITHUB)/openresty/headers-more-nginx-module.git

PKGS += headers-more-nginx-module

$(TARBALLS)/headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_GITHASH).tar.xz:
	$(call download_git,$(HEADERS_MORE_NGINX_MODULE_GITURL),,$(HEADERS_MORE_NGINX_MODULE_GITHASH))

.sum-headers-more-nginx-module: headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_GITHASH).tar.xz
	$(call check_githash,$(HEADERS_MORE_NGINX_MODULE_GITHASH))
	touch $@

headers-more-nginx-module: headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_GITHASH).tar.xz .sum-headers-more-nginx-module
	$(UNPACK)
	$(MOVE)

.headers-more-nginx-module: headers-more-nginx-module
	touch $@
