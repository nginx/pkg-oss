# grpc

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
GRPC_URL := $(GITHUB)/grpc/grpc/archive/v$(GRPC_VERSION).tar.gz

PKGS += grpc

$(TARBALLS)/grpc-$(GRPC_VERSION).tar.gz:
	$(call download_pkg,$(GRPC_URL),grpc)

.sum-grpc: grpc-$(GRPC_VERSION).tar.gz

grpc: grpc-$(GRPC_VERSION).tar.gz .sum-grpc
	$(UNPACK)
	$(MOVE)

