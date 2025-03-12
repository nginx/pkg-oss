# nginx-otel

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_OTEL_URL := $(GITHUB)/nginxinc/nginx-otel/archive/$(NGINX_OTEL_GITHASH).tar.gz

PKGS += nginx-otel

$(TARBALLS)/nginx-otel-$(NGINX_OTEL_VERSION)-$(NGINX_OTEL_GITHASH).tar.gz:
	$(call download_pkg,$(NGINX_OTEL_URL),nginx-otel)

.sum-nginx-otel: nginx-otel-$(NGINX_OTEL_VERSION)-$(NGINX_OTEL_GITHASH).tar.gz

nginx-otel: nginx-otel-$(NGINX_OTEL_VERSION)-$(NGINX_OTEL_GITHASH).tar.gz .sum-nginx-otel
	$(UNPACK)
	$(MOVE)

.nginx-otel: nginx-otel
	touch $@
