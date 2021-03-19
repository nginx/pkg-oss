# thrift

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
THRIFT_URL := $(GITHUB)/apache/thrift/archive/v$(THRIFT_VERSION).tar.gz

PKGS += thrift

$(TARBALLS)/thrift-$(THRIFT_VERSION).tar.gz:
	$(call download_pkg,$(THRIFT_URL),thrift)

.sum-thrift: thrift-$(THRIFT_VERSION).tar.gz

# patches reflect changes made in hunter version of thrift
thrift: thrift-$(THRIFT_VERSION).tar.gz .sum-thrift
	$(UNPACK)
	$(APPLY) $(SRC)/thrift/CMakeLists.txt.patch
	$(APPLY) $(SRC)/thrift/lib-cpp-CMakeLists.txt.patch
	$(APPLY) $(SRC)/thrift/build-cmake-ThriftMacros.cmake.patch
	$(APPLY) $(SRC)/thrift/build-cmake-Config.cmake.in.patch
	$(MOVE)

.thrift: thrift
	cd $< && \
		mkdir -p .build && \
		cd .build && \
		cmake \
			-DBUILD_TESTING=OFF \
			-DBUILD_TUTORIALS=OFF \
			-DBUILD_COMPILER=OFF \
			-DBUILD_C_GLIB=OFF \
			-DBUILD_HASKELL=OFF \
			-DBUILD_JAVA=OFF \
			-DBUILD_PYTHON=OFF \
			-DWITH_QT4=OFF \
			-DWITH_QT5=OFF \
			-DWITH_SHARED_LIB=OFF \
			-DWITH_PLUGIN=OFF \
			-DWITH_LIBEVENT=OFF \
			-DWITH_OPENSSL=OFF \
			-DWITH_ZLIB=OFF \
			-DBUILD_SHARED_LIBS=ON \
			-DCMAKE_INSTALL_LIBDIR=lib \
			../ && \
		DESTDIR=$(PREFIX) make $(_SMP_MFLAGS) install
	touch $@
