# opentelemetry-proto

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
OPENTELEMETRY_PROTO_URL := $(GITHUB)/open-telemetry/opentelemetry-proto/archive/v$(OPENTELEMETRY_PROTO_VERSION).tar.gz

PKGS += opentelemetry-proto

$(TARBALLS)/opentelemetry-proto-$(OPENTELEMETRY_PROTO_VERSION).tar.gz:
	$(call download_pkg,$(OPENTELEMETRY_PROTO_URL),opentelemetry-proto)

.sum-opentelemetry-proto: opentelemetry-proto-$(OPENTELEMETRY_PROTO_VERSION).tar.gz

opentelemetry-proto: opentelemetry-proto-$(OPENTELEMETRY_PROTO_VERSION).tar.gz .sum-opentelemetry-proto
	$(UNPACK)
	$(MOVE)

