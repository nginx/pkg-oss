# ngx_http_substitutions_filter_module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_URL := $(GITHUB)/yaoweibin/ngx_http_substitutions_filter_module/archive/$(NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_GITHASH).tar.gz

PKGS += ngx_http_substitutions_filter_module

$(TARBALLS)/ngx_http_substitutions_filter_module-$(NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_GITHASH).tar.gz:
	$(call download_pkg,$(NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_URL),ngx_http_substitutions_filter_module)

.sum-ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_GITHASH).tar.gz

ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(NGX_HTTP_SUBSTITUTIONS_FILTER_MODULE_GITHASH).tar.gz .sum-ngx_http_substitutions_filter_module
	$(UNPACK)
	$(MOVE)

.ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module
	touch $@
