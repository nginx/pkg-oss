# opentracing-cpp

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
OPENTRACING_CPP_URL := $(GITHUB)/opentracing/opentracing-cpp/archive/v$(OPENTRACING_CPP_VERSION).tar.gz

PKGS += opentracing-cpp

$(TARBALLS)/opentracing-cpp-$(OPENTRACING_CPP_VERSION).tar.gz:
	$(call download_pkg,$(OPENTRACING_CPP_URL),opentracing-cpp)

.sum-opentracing-cpp: opentracing-cpp-$(OPENTRACING_CPP_VERSION).tar.gz

opentracing-cpp: opentracing-cpp-$(OPENTRACING_CPP_VERSION).tar.gz .sum-opentracing-cpp
	$(UNPACK)
	$(APPLY) $(SRC)/opentracing-cpp/CMakeLists.txt.patch
	$(APPLY) $(SRC)/opentracing-cpp/fix-ftbfs-glibc-2.34.patch
	$(MOVE)

.opentracing-cpp: opentracing-cpp
	cd $< && \
		mkdir -p .build && \
		cd .build && \
		$(CMAKE) ../ && \
		DESTDIR=$(PREFIX) make $(_SMP_MFLAGS) install
	touch $@
