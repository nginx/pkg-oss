# ngx_devel_kit

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGX_DEVEL_KIT_URL := $(GITHUB)/vision5/ngx_devel_kit/archive/v$(NGX_DEVEL_KIT_VERSION).tar.gz

PKGS += ngx_devel_kit

$(TARBALLS)/ngx_devel_kit-$(NGX_DEVEL_KIT_VERSION).tar.gz:
	$(call download_pkg,$(NGX_DEVEL_KIT_URL),ngx_devel_kit)

.sum-ngx_devel_kit: ngx_devel_kit-$(NGX_DEVEL_KIT_VERSION).tar.gz

ngx_devel_kit: ngx_devel_kit-$(NGX_DEVEL_KIT_VERSION).tar.gz .sum-ngx_devel_kit
	$(UNPACK)
	$(MOVE)

.ngx_devel_kit: ngx_devel_kit
	touch $@
