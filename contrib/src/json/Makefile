# json

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
JSON_URL := $(GITHUB)/nlohmann/json/archive/v$(JSON_VERSION).tar.gz

PKGS += json

$(TARBALLS)/json-$(JSON_VERSION).tar.gz:
	$(call download_pkg,$(JSON_URL),json)

.sum-json: json-$(JSON_VERSION).tar.gz

json: json-$(JSON_VERSION).tar.gz .sum-json
	$(UNPACK)
	$(MOVE)

.json: json
	cd $< && \
		mkdir -p .build && \
		cd .build && \
		$(CMAKE) \
			../ && \
		DESTDIR=$(PREFIX) make $(_SMP_MFLAGS) install
	touch $@
