# ngx_http_geoip2_module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGX_HTTP_GEOIP2_MODULE_URL := $(GITHUB)/leev/ngx_http_geoip2_module/archive/$(NGX_HTTP_GEOIP2_MODULE_VERSION).tar.gz

PKGS += ngx_http_geoip2_module

$(TARBALLS)/ngx_http_geoip2_module-$(NGX_HTTP_GEOIP2_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(NGX_HTTP_GEOIP2_MODULE_URL),ngx_http_geoip2_module)

.sum-ngx_http_geoip2_module: ngx_http_geoip2_module-$(NGX_HTTP_GEOIP2_MODULE_VERSION).tar.gz

ngx_http_geoip2_module: ngx_http_geoip2_module-$(NGX_HTTP_GEOIP2_MODULE_VERSION).tar.gz .sum-ngx_http_geoip2_module
	$(UNPACK)
	$(MOVE)

.ngx_http_geoip2_module: ngx_http_geoip2_module
	touch $@
