# ModSecurity-nginx

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
MODSECURITY_NGINX_GITURL := $(GITHUB)/SpiderLabs/ModSecurity-nginx.git

PKGS += modsecurity-nginx

$(TARBALLS)/modsecurity-nginx-$(MODSECURITY_NGINX_GITHASH).tar.xz:
	$(call download_git,$(MODSECURITY_NGINX_GITURL),,$(MODSECURITY_NGINX_GITHASH))

.sum-modsecurity-nginx: modsecurity-nginx-$(MODSECURITY_NGINX_GITHASH).tar.xz
	$(call check_githash,$(MODSECURITY_NGINX_GITHASH))
	touch $@

modsecurity-nginx: modsecurity-nginx-$(MODSECURITY_NGINX_GITHASH).tar.xz .sum-modsecurity-nginx
	$(UNPACK)
	$(APPLY) $(SRC)/modsecurity-nginx/PR165.patch
	$(MOVE)

DEPS_modsecurity-nginx = modsecurity $(DEPS_modsecurity)

.modsecurity-nginx: modsecurity-nginx
	touch $@
