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
	$(MOVE)

DEPS_jaeger-client-cpp = opentracing-cpp $(DEPS_opentracing-cpp)

# note the https://github.com/google/myanmar-tools/issues/42
.jaeger-client-cpp: jaeger-client-cpp
	cd $< && \
		mkdir -p .build && \
		cd .build && \
		CXXFLAGS="-Wno-error=deprecated-copy" OpenTracing_DIR=$(TOPSRC)/opentracing-cpp/.build cmake -DCMAKE_BUILD_TYPE=Release -DJAEGERTRACING_PLUGIN=ON -DHUNTER_CONFIGURATION_TYPES=Release -DOPENTRACING_INC=$(TOPSRC)/local/usr/local/include ../ && \
		make $(_SMP_MFLAGS)
	cd $< && install -s .build/libjaegertracing_plugin.so $(PREFIX)/
	touch $@
