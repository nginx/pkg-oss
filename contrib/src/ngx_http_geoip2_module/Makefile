# ngx_http_geoip2_module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
GEOIP2_NGINX_MODULE_URL := $(GITHUB)/leev/ngx_http_geoip2_module/archive/$(GEOIP2_NGINX_MODULE_VERSION).tar.gz

PKGS += ngx_http_geoip2_module

$(TARBALLS)/ngx_http_geoip2_module-$(GEOIP2_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(GEOIP2_NGINX_MODULE_URL),ngx_http_geoip2_module)

.sum-ngx_http_geoip2_module: ngx_http_geoip2_module-$(GEOIP2_NGINX_MODULE_VERSION).tar.gz

ngx_http_geoip2_module: ngx_http_geoip2_module-$(GEOIP2_NGINX_MODULE_VERSION).tar.gz .sum-ngx_http_geoip2_module
	$(UNPACK)
	$(MOVE)

.ngx_http_geoip2_module: ngx_http_geoip2_module
	touch $@
