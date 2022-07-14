# spnego-http-auth-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
SPNEGO_HTTP_AUTH_NGINX_MODULE_GITURL := $(GITHUB)/stnoonan/spnego-http-auth-nginx-module.git

PKGS += spnego-http-auth-nginx-module

$(TARBALLS)/spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.xz:
	$(call download_git,$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITURL),,$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH))

.sum-spnego-http-auth-nginx-module: spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.xz
	$(call check_githash,$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH))
	touch $@

spnego-http-auth-nginx-module: spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.xz .sum-spnego-http-auth-nginx-module
	$(UNPACK)
	$(APPLY) $(SRC)/spnego-http-auth-nginx-module/extra-patch-ngx_http_auth_spnego_module.c
	$(MOVE)

.spnego-http-auth-nginx-module: spnego-http-auth-nginx-module
	touch $@
