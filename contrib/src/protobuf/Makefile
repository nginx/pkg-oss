# protobuf

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
PROTOBUF_URL := $(GITHUB)/protocolbuffers/protobuf/archive/refs/tags/v$(PROTOBUF_VERSION).tar.gz

PKGS += protobuf

$(TARBALLS)/protobuf-$(PROTOBUF_VERSION).tar.gz:
	$(call download_pkg,$(PROTOBUF_URL),protobuf)

.sum-protobuf: protobuf-$(PROTOBUF_VERSION).tar.gz

protobuf: protobuf-$(PROTOBUF_VERSION).tar.gz .sum-protobuf
	$(UNPACK)
	$(MOVE)

