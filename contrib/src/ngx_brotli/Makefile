# ngx_brotli

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGX_BROTLI_URL := $(GITHUB)/google/ngx_brotli/archive/v$(NGX_BROTLI_VERSION)rc.tar.gz

PKGS += ngx_brotli

$(TARBALLS)/ngx_brotli-$(NGX_BROTLI_VERSION).tar.gz:
	$(call download_pkg,$(NGX_BROTLI_URL),ngx_brotli)

.sum-ngx_brotli: ngx_brotli-$(NGX_BROTLI_VERSION).tar.gz

ngx_brotli: ngx_brotli-$(NGX_BROTLI_VERSION).tar.gz .sum-ngx_brotli
	$(UNPACK)
	$(MOVE)

.ngx_brotli: ngx_brotli
	touch $@
