# opentelemetry-cpp

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
OPENTELEMETRY_CPP_URL := $(GITHUB)/open-telemetry/opentelemetry-cpp/archive/v$(OPENTELEMETRY_CPP_VERSION).tar.gz

PKGS += opentelemetry-cpp

$(TARBALLS)/opentelemetry-cpp-$(OPENTELEMETRY_CPP_VERSION).tar.gz:
	$(call download_pkg,$(OPENTELEMETRY_CPP_URL),opentelemetry-cpp)

.sum-opentelemetry-cpp: opentelemetry-cpp-$(OPENTELEMETRY_CPP_VERSION).tar.gz

opentelemetry-cpp: opentelemetry-cpp-$(OPENTELEMETRY_CPP_VERSION).tar.gz .sum-opentelemetry-cpp
	$(UNPACK)
	$(MOVE)

