# nginx-opentracing

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_OPENTRACING_URL := $(GITHUB)/opentracing-contrib/nginx-opentracing/archive/v$(NGINX_OPENTRACING_VERSION).tar.gz

PKGS += nginx-opentracing

$(TARBALLS)/nginx-opentracing-$(NGINX_OPENTRACING_VERSION).tar.gz:
	$(call download_pkg,$(NGINX_OPENTRACING_URL),nginx-opentracing)

.sum-nginx-opentracing: nginx-opentracing-$(NGINX_OPENTRACING_VERSION).tar.gz

nginx-opentracing: nginx-opentracing-$(NGINX_OPENTRACING_VERSION).tar.gz .sum-nginx-opentracing
	$(UNPACK)
	$(MOVE)

DEPS_nginx-opentracing = opentracing-cpp $(DEPS_opentracing-cpp)

.nginx-opentracing: nginx-opentracing
	touch $@
