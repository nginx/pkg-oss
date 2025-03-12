# ngx_http_substitutions_filter_module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
SUBSTITUTIONS_FILTER_NGINX_MODULE_URL := $(GITHUB)/yaoweibin/ngx_http_substitutions_filter_module/archive/$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.gz

PKGS += ngx_http_substitutions_filter_module

$(TARBALLS)/ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.gz:
	$(call download_pkg,$(SUBSTITUTIONS_FILTER_NGINX_MODULE_URL),ngx_http_substitutions_filter_module)

.sum-ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.gz

ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.gz .sum-ngx_http_substitutions_filter_module
	$(UNPACK)
	$(MOVE)

.ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module
	touch $@
