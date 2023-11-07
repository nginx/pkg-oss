# abseil-cpp

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
ABSEIL_URL := $(GITHUB)/abseil/abseil-cpp/archive/refs/tags/$(ABSEIL_VERSION).tar.gz

PKGS += abseil-cpp

$(TARBALLS)/abseil-cpp-$(ABSEIL_VERSION).tar.gz:
	$(call download_pkg,$(ABSEIL_URL),abseil-cpp)

.sum-abseil-cpp: abseil-cpp-$(ABSEIL_VERSION).tar.gz

abseil-cpp: abseil-cpp-$(ABSEIL_VERSION).tar.gz .sum-abseil-cpp
	$(UNPACK)
	$(APPLY) $(SRC)/abseil-cpp/b957f0ccd00481cd4fd663d8320aa02ae0564f18.patch
	$(MOVE)

