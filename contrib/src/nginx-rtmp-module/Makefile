# nginx-rtmp-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_RTMP_MODULE_URL := $(GITHUB)/arut/nginx-rtmp-module/archive/v$(NGINX_RTMP_MODULE_VERSION).tar.gz

PKGS += nginx-rtmp-module

$(TARBALLS)/nginx-rtmp-module-$(NGINX_RTMP_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(NGINX_RTMP_MODULE_URL),nginx-rtmp-module)

.sum-nginx-rtmp-module: nginx-rtmp-module-$(NGINX_RTMP_MODULE_VERSION).tar.gz

nginx-rtmp-module: nginx-rtmp-module-$(NGINX_RTMP_MODULE_VERSION).tar.gz .sum-nginx-rtmp-module
	$(UNPACK)
	$(APPLY) $(SRC)/nginx-rtmp-module/PR1340.patch
	$(MOVE)

.nginx-rtmp-module: nginx-rtmp-module
	touch $@
