# nginx-fips-check-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_FIPS_CHECK_MODULE_URL := $(GITHUB)/ogarrett/nginx-fips-check-module/archive/v$(NGINX_FIPS_CHECK_MODULE_VERSION).tar.gz

PKGS += nginx-fips-check-module

$(TARBALLS)/nginx-fips-check-module-$(NGINX_FIPS_CHECK_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(NGINX_FIPS_CHECK_MODULE_URL),nginx-fips-check-module)

.sum-nginx-fips-check-module: nginx-fips-check-module-$(NGINX_FIPS_CHECK_MODULE_VERSION).tar.gz

nginx-fips-check-module: nginx-fips-check-module-$(NGINX_FIPS_CHECK_MODULE_VERSION).tar.gz .sum-nginx-fips-check-module
	$(UNPACK)
	$(MOVE)

.nginx-fips-check-module: nginx-fips-check-module
	touch $@
