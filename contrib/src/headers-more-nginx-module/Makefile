# headers-more-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
HEADERS_MORE_NGINX_MODULE_URL := $(GITHUB)/openresty/headers-more-nginx-module/archive/v$(HEADERS_MORE_NGINX_MODULE_VERSION).tar.gz

PKGS += headers-more-nginx-module

$(TARBALLS)/headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(HEADERS_MORE_NGINX_MODULE_URL),headers-more-nginx-module)

.sum-headers-more-nginx-module: headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_VERSION).tar.gz

headers-more-nginx-module: headers-more-nginx-module-$(HEADERS_MORE_NGINX_MODULE_VERSION).tar.gz .sum-headers-more-nginx-module
	$(UNPACK)
	$(MOVE)

.headers-more-nginx-module: headers-more-nginx-module
	touch $@
