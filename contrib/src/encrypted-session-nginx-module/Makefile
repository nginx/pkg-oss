# encrypted-session-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
ENCRYPTED_SESSION_NGINX_MODULE_URL := $(GITHUB)/openresty/encrypted-session-nginx-module/archive/v$(ENCRYPTED_SESSION_NGINX_MODULE_VERSION).tar.gz

PKGS += encrypted-session-nginx-module

$(TARBALLS)/encrypted-session-nginx-module-$(ENCRYPTED_SESSION_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(ENCRYPTED_SESSION_NGINX_MODULE_URL),encrypted-session-nginx-module)

.sum-encrypted-session-nginx-module: encrypted-session-nginx-module-$(ENCRYPTED_SESSION_NGINX_MODULE_VERSION).tar.gz

encrypted-session-nginx-module: encrypted-session-nginx-module-$(ENCRYPTED_SESSION_NGINX_MODULE_VERSION).tar.gz .sum-encrypted-session-nginx-module
	$(UNPACK)
	$(MOVE)

DEPS_encrypted-session-nginx-module = ngx_devel_kit $(DEPS_ngx_devel_kit)

.encrypted-session-nginx-module: encrypted-session-nginx-module
	touch $@
