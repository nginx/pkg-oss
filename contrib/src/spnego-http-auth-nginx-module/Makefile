# spnego-http-auth-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
SPNEGO_HTTP_AUTH_NGINX_MODULE_URL := $(GITHUB)/stnoonan/spnego-http-auth-nginx-module/archive/$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.gz

PKGS += spnego-http-auth-nginx-module

$(TARBALLS)/spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.gz:
	$(call download_pkg,$(SPNEGO_HTTP_AUTH_NGINX_MODULE_URL),spnego-http-auth-nginx-module)

.sum-spnego-http-auth-nginx-module: spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.gz

spnego-http-auth-nginx-module: spnego-http-auth-nginx-module-$(SPNEGO_HTTP_AUTH_NGINX_MODULE_GITHASH).tar.gz .sum-spnego-http-auth-nginx-module
	$(UNPACK)
	$(APPLY) $(SRC)/spnego-http-auth-nginx-module/extra-patch-ngx_http_auth_spnego_module.c
	$(MOVE)

.spnego-http-auth-nginx-module: spnego-http-auth-nginx-module
	touch $@
