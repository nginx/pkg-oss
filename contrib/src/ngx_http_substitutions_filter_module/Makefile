# ngx_http_substitutions_filter_module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
SUBSTITUTIONS_FILTER_NGINX_MODULE_GITURL := $(GITHUB)/yaoweibin/ngx_http_substitutions_filter_module.git

PKGS += ngx_http_substitutions_filter_module

$(TARBALLS)/ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.xz:
	$(call download_git,$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITURL),,$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH))

.sum-ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.xz
	$(call check_githash,$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH))
	touch $@

ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module-$(SUBSTITUTIONS_FILTER_NGINX_MODULE_GITHASH).tar.xz .sum-ngx_http_substitutions_filter_module
	$(UNPACK)
	$(MOVE)

.ngx_http_substitutions_filter_module: ngx_http_substitutions_filter_module
	touch $@
