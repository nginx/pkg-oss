# jaeger-client-cpp

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
JAEGER_CLIENT_CPP_URL := $(GITHUB)/jaegertracing/jaeger-client-cpp/archive/v$(JAEGER_CLIENT_CPP_VERSION).tar.gz

PKGS += jaeger-client-cpp

$(TARBALLS)/jaeger-client-cpp-$(JAEGER_CLIENT_CPP_VERSION).tar.gz:
	$(call download_pkg,$(JAEGER_CLIENT_CPP_URL),jaeger-client-cpp)

.sum-jaeger-client-cpp: jaeger-client-cpp-$(JAEGER_CLIENT_CPP_VERSION).tar.gz

jaeger-client-cpp: jaeger-client-cpp-$(JAEGER_CLIENT_CPP_VERSION).tar.gz .sum-jaeger-client-cpp
	$(UNPACK)
	$(APPLY) $(SRC)/jaeger-client-cpp/CMakeLists.txt.patch
ifeq ($(shell rpm --version 2>&1 || echo FAIL),)
ifeq ($(shell test `rpm --eval '0%{?rhel}'` -gt 0 -a `rpm --eval '0%{?rhel}'` -lt 8 && echo 1),1)
	$(APPLY) $(SRC)/jaeger-client-cpp/CMakeLists.txt.suppress-gcc-version-check.patch
endif
endif
	$(MOVE)

DEPS_jaeger-client-cpp = opentracing-cpp $(DEPS_opentracing-cpp) thrift $(DEPS_thrift)

# note the https://github.com/google/myanmar-tools/issues/42
.jaeger-client-cpp: jaeger-client-cpp
	cd $< && \
		mkdir -p .build && \
		cd .build && \
		OpenTracing_DIR=$(PREFIX)/usr/local/lib/cmake/OpenTracing \
		thrift_DIR=$(PREFIX)/usr/local/lib/cmake/thrift \
		$(CMAKE) \
			-DBUILD_TESTING=OFF \
			-DJAEGERTRACING_PLUGIN=ON \
			-DCMAKE_BUILD_TYPE=Release \
			-DHUNTER_CONFIGURATION_TYPES=Release \
			-DOPENTRACING_INC=$(TOPSRC)/local/usr/local/include \
		../ && \
		make $(_SMP_MFLAGS)
	cd $< && install -s .build/libjaegertracing_plugin.so $(PREFIX)/
	touch $@
