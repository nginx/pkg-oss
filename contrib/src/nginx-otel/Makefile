# nginx-otel

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_OTEL_GITURL := $(GITHUB)/nginxinc/nginx-otel

PKGS += nginx-otel

$(TARBALLS)/nginx-otel-$(NGINX_OTEL_VERSION).tar.xz:
	$(call download_git,$(NGINX_OTEL_GITURL),,$(NGINX_OTEL_GITHASH))

.sum-nginx-otel: nginx-otel-$(NGINX_OTEL_VERSION).tar.xz
	$(call check_githash,$(NGINX_OTEL_GITHASH))
	touch $@

nginx-otel: nginx-otel-$(NGINX_OTEL_VERSION).tar.xz .sum-nginx-otel
	$(UNPACK)
	$(MOVE)

.nginx-otel: nginx-otel
	touch $@
