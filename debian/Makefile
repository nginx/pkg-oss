SHELL=		/bin/bash

CONTRIB?=	../contrib
CONTRIB:=	$(abspath $(CONTRIB))

BASE_TARGET?=	oss

ifeq ($(BASE_TARGET), plus)
BASE_SUFFIX=-plus
DOCS?=		../docs-plus
MODULE_TARGET?=	plus
endif
ifeq ($(BASE_TARGET), quic)
BASE_SUFFIX=-quic
DOCS?=		../docs-quic
MODULE_TARGET?=	quic
endif

DOCS?=		../docs
MODULE_TARGET?=	oss

include $(CONTRIB)/src/nginx$(BASE_SUFFIX)/version

BASE_VERSION=	$(NGINX_VERSION)
BASE_RELEASE=	0.20230124
PLUS_VERSION=	$(NGINX_PLUS_VERSION)
PLUS_RELEASE=	1
BASE_SRC=	nginx$(BASE_SUFFIX)-$(BASE_VERSION).tar.gz
SRCDIR=		nginx$(BASE_SUFFIX)-$(BASE_VERSION)
SRCPATH?=	../..
BUILD_ENV_PATH=	${HOME}/debuild

ifeq ($(MODULE_TARGET), plus)
MODULE_SUFFIX=	-plus
MODULE_SUMMARY_PREFIX=NGINX Plus
TARGET_VERSION=$(PLUS_VERSION)
BASE_ORIG_NAME=nginx-plus_$(PLUS_VERSION).orig.tar.gz
MODULE_PACKAGE_URL=	https://www.nginx.com/
else ifeq ($(MODULE_TARGET), quic)
MODULE_SUMMARY_PREFIX=  nginx-quic
TARGET_VERSION=$(BASE_VERSION)
MODULE_SUFFIX=-quic
BASE_ORIG_NAME=nginx-quic_$(BASE_VERSION).orig.tar.gz
MODULE_PACKAGE_URL=     https://nginx.org/
MODULE_PACKAGE_LICENSE=2-clause BSD-like license
else
MODULE_SUMMARY_PREFIX=nginx
TARGET_VERSION=$(BASE_VERSION)
BASE_ORIG_NAME=nginx_$(BASE_VERSION).orig.tar.gz
MODULE_PACKAGE_URL=	https://nginx.org/
endif

MODULE_PACKAGE_PREFIX=nginx$(MODULE_SUFFIX)-module
MODULE_TARGET_PREFIX=$(TARGET_VERSION)+

PACKAGE_VENDOR=	NGINX Packaging <nginx-packaging@f5.com>

CODENAME=	$(shell lsb_release -cs)
ARCH=		$(shell uname -m)
NPROC=		$(shell getconf _NPROCESSORS_ONLN)
MODSRC_PREFIX=	extra/
BUILD_DIR=	$$(BUILDDIR_nginx)

BASE_MODULES=	geoip image-filter njs perl xslt

MODULES=

-include Makefile.module-*

BASE_CONFIGURE_ARGS=\
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/usr/lib/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--user=nginx \
	--group=nginx \
	--with-compat \
	--with-file-aio \
	--with-threads \
	--with-http_addition_module \
	--with-http_auth_request_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_mp4_module \
	--with-http_random_index_module \
	--with-http_realip_module \
	--with-http_secure_link_module \
	--with-http_slice_module \
	--with-http_ssl_module \
	--with-http_stub_status_module \
	--with-http_sub_module \
	--with-http_v2_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module

ifeq ($(BASE_TARGET), plus)
BASE_CONFIGURE_ARGS+= \
	--build=nginx-plus-r$(PLUS_VERSION) \
	--with-http_auth_jwt_module \
	--with-http_f4f_module \
	--with-http_hls_module \
	--with-http_session_log_module \
	--with-http_proxy_protocol_vendor_module \
	--with-stream_proxy_protocol_vendor_module
endif

ifeq ($(BASE_TARGET), quic)
BASE_CONFIGURE_ARGS+= \
	--build=nginx-quic-$(NGINX_QUIC_SOURCETAG) \
 	--with-http_v3_module \
	--with-stream_quic_module
endif

export CR=\\n

modname = $(shell echo $1 | tr '-' '_')

default:
	@echo "valid targets: all base $(addprefix module-, $(MODULES)) check-modules test test-debug"

list-base:
	@printf "%-20s\t%s\n" nginx $(BASE_VERSION)-$(BASE_RELEASE)

list-module-%:
	@printf "%-20s\t%s\n" $* $(MODULE_VERSION_$(call modname, $*))-$(MODULE_RELEASE_$(call modname, $*))

list-all-modules: $(addprefix list-module-, $(MODULES))

list-base-modules: $(addprefix list-module-, $(BASE_MODULES))

list: list-base list-all-modules

all:	base base-modules
	@echo "===> all done"

quictls:
	make -f Makefile.quictls

quic: quic-base quic-base-modules

quic-all:
	BASE_TARGET=quic MODULE_TARGET=quic make all modules test

quic-base:
	BASE_TARGET=quic make base

quic-base-modules:
	BASE_TARGET=quic MODULE_TARGET=quic make base-modules

quic-modules:
	BASE_TARGET=quic MODULE_TARGET=quic make modules

base-modules:	$(addprefix module-, $(BASE_MODULES))

modules:	$(addprefix module-, $(MODULES))

rules:	rules-base $(addprefix rules-module-, $(MODULES))

base:	rules-base
	@echo "===> Building base package" ; \
	$(SHELL) -c "cd debuild-base/$(SRCDIR) ; export DEB_BUILD_OPTIONS=parallel=$(NPROC) ; time -p debuild -us -uc" && \
	find debuild-base/ -maxdepth 1 -type f -exec cp {} ../../ \; && \
	ln -s debuild-base/$(SRCDIR)/debian/nginx$(BASE_SUFFIX)/usr/sbin base

$(BASE_SRC):
	cd $(CONTRIB) && make .sum-nginx$(BASE_SUFFIX)
	ln -s $(CONTRIB)/tarballs/$(BASE_SRC) $(BASE_SRC)

nginx.deb-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx$(BASE_SUFFIX).deb-changelog

rules-base: $(BASE_SRC) nginx.deb-changelog
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	mkdir -p debuild-base ; \
	cp $(BASE_SRC) debuild-base/$(BASE_ORIG_NAME); \
	tar -C debuild-base -xf debuild-base/$(BASE_ORIG_NAME) ; \
	mkdir -p debuild-base/$(SRCDIR)/debian ; \
	mkdir -p debuild-base/$(SRCDIR)/debian/source ; \
	echo "3.0 (quilt)" > debuild-base/$(SRCDIR)/debian/source/format ; \
	echo "11" > debuild-base/$(SRCDIR)/debian/compat ; \
	cp -ar debian$(BASE_SUFFIX)/. debuild-base/$(SRCDIR)/debian ; \
	for patch in `find $(CONTRIB)/src/nginx$(BASE_SUFFIX)/ -type f -name '*.patch' -printf "%f\n" | sort`; do \
		mkdir -p debuild-base/$(SRCDIR)/debian/patches ; \
		echo $$patch >> debuild-base/$(SRCDIR)/debian/patches/series ; \
		cp -v $(CONTRIB)/src/nginx$(BASE_SUFFIX)/$$patch debuild-base/$(SRCDIR)/debian/patches ; \
	done ; \
	sed debuild-base/$(SRCDIR)/debian/nginx$(BASE_SUFFIX).rules.in \
		-e 's#%%CODENAME%%#$(CODENAME)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> debuild-base/$(SRCDIR)/debian/rules ; \
	sed nginx$(BASE_SUFFIX).deb-changelog \
		-e 's#%%CODENAME%%#$(CODENAME)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%PLUS_VERSION%%#$(PLUS_VERSION)#g' \
		-e 's#%%PLUS_RELEASE%%#$(PLUS_RELEASE)#g' \
		> debuild-base/$(SRCDIR)/debian/changelog ; \
	sed debuild-base/$(SRCDIR)/debian/nginx$(BASE_SUFFIX).control.in \
		-e "s#%%PACKAGE_VENDOR%%#$(PACKAGE_VENDOR)#g" \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%PLUS_VERSION%%#$(PLUS_VERSION)#g' \
		> debuild-base/$(SRCDIR)/debian/control ; \
	if [ "$(BASE_TARGET)" = "plus" ]; then \
		cp	$(DOCS)/EULA-TRIAL \
			$(DOCS)/EULA-DEVELOPER \
			$(DOCS)/EULA-SUBSCRIPTION \
			$(DOCS)/CHANGES \
			$(DOCS)/nginx-modules-reference.pdf \
			debuild-base/$(SRCDIR)/debian/ ; \
		cp $(CONTRIB)/tarballs/dashboard.html debuild-base/$(SRCDIR)/debian/ ; \
		( cd debuild-base/$(SRCDIR) && \
			find debian/ -type f -exec file --mime {} \; | fgrep 'charset=binary' | cut -d ':' -f 1 > include-binaries && \
			mv include-binaries debian/source/ \
		) ; \
	elif [ "$(BASE_TARGET)" = "quic" ]; then \
		( cd debuild-base/$(SRCDIR) && \
			make -f docs/GNUmakefile changes ; \
		) ; \
		cp	debuild-base/$(SRCDIR)/tmp/nginx-$(BASE_VERSION)/CHANGES \
			debuild-base/$(SRCDIR)/tmp/nginx-$(BASE_VERSION)/CHANGES.ru \
			debuild-base/$(SRCDIR)/debian/ ; \
		rm -f debuild-base/$(SRCDIR)/tmp/nginx-$(BASE_VERSION)/CHANGES \
			debuild-base/$(SRCDIR)/tmp/nginx-$(BASE_VERSION)/CHANGES.ru ; \
	else \
		cp	debuild-base/$(SRCDIR)/CHANGES \
			debuild-base/$(SRCDIR)/CHANGES.ru \
			debuild-base/$(SRCDIR)/debian/ ; \
	fi; \
	cp $(DOCS)/nginx.copyright debuild-base/$(SRCDIR)/debian/copyright ; \
	chmod +x debuild-base/$(SRCDIR)/debian/rules ; \
	ln -s debuild-base/$(SRCDIR)/debian/rules rules-base ; \
	}

module-%: rules-module-% check-compat-%
	@if [ -e nginx-$@.skip ]; then \
	    echo "---> Skipping nginx-$@ package (`cat nginx-$@.skip`)" ; \
	else \
	    echo "===> Building nginx-$@ package" ; \
	    $(SHELL) -c "cd debuild-$@/$(SRCDIR) ; export DEB_BUILD_OPTIONS=parallel=$(NPROC) ; time -p debuild -us -uc" && \
	    find debuild-$@/ -maxdepth 1 -type f -exec cp {} ../../ \; && \
	    ln -s debuild-$@/$(SRCDIR)/debian/$(MODULE_PACKAGE_PREFIX)-$*/usr/lib/nginx/modules $@ ; \
	fi;

check-compat-%:
	@module=`echo $@ | cut -d '-' -f 3- | tr '-' '_'` ; \
	set -e ; \
	case "$${module}" in \
	    brotli) \
	    if [ "$(CODENAME)" = "stretch" ]; then \
	        echo "brotli can not be built on Debian 9" > \
	        nginx-module-$${module}.skip ; \
	    fi ; \
	    ;; \
	    lua) \
	    if [ "$(ARCH)" = "ppc64le" ]; then \
	        echo "Lua can not be built on $(ARCH) due to issues with LuaJIT" > \
	        nginx-module-$${module}.skip ; \
	    fi ; \
	    ;; \
	    modsecurity) \
	    if [ "$(ARCH)" = "ppc64le" ]; then \
	        echo "ModSecurity can not be built on $(ARCH)" > \
	        nginx-module-$${module}.skip ; \
	    fi ; \
	    ;; \
	esac

nginx-module-%.deb-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx-module-$*.deb-changelog
	@sed -i -e 's,nginx-module-,nginx$(MODULE_SUFFIX)-module-,g' $(CURDIR)/$@

rules-module-%: $(BASE_SRC) nginx-module-%.deb-changelog .deps-module-%
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	curdir=`pwd` ; \
	module_asis=`echo $@ | cut -d '-' -f 3-` ; \
	builddir=`echo debuild-module-$${module_asis}` ; \
	mkdir -p $${builddir} ; \
	module_version="$(MODULE_VERSION_PREFIX_$(call modname, $*))$(MODULE_VERSION_$(call modname, $*))" ; \
	orig_name="nginx$(MODULE_SUFFIX)-module-$${module_asis}_$${module_version}.orig.tar.gz" ; \
	cp $(BASE_SRC) $${builddir}/$${orig_name} ; \
	tar -C $${builddir} -xf $${builddir}/$${orig_name} ; \
	mkdir -p $${builddir}/$(SRCDIR)/debian/extra ; \
	mkdir -p $${builddir}/$(SRCDIR)/debian/source ; \
	echo "3.0 (quilt)" > $${builddir}/$(SRCDIR)/debian/source/format ; \
	echo "11" > $${builddir}/$(SRCDIR)/debian/compat ; \
	for f in rules postinst; do \
		cp debian/nginx-module.$$f.in $${builddir}/$(SRCDIR)/debian/nginx$(MODULE_SUFFIX)-module.$$f.in ; \
	done ; \
	cp -ar debian$(MODULE_SUFFIX)/. $${builddir}/$(SRCDIR)/debian ; \
	for src in $(MODULE_SOURCES_$(call modname, $*)); do \
		tar -C $${builddir}/$(SRCDIR)/debian/extra -xvf $(CONTRIB)/tarballs/$${src} ; \
		sn=`echo $${src} | sed -e 's/-[0-9].*$$//'` ; \
		if [ "$${sn}" = "$${src}" ] ; then \
			sn=$${src%-*} ; \
		fi ; \
		( cd $${builddir}/$(SRCDIR)/debian/extra && ln -s $${sn}-* $${sn} ) ; \
	done ; \
	for p in $(MODULE_PATCHES_$(call modname, $*)); do \
		dn=`dirname $${p}` ; \
		bdn=`basename $${dn}` ; \
		( cd $${builddir}/$(SRCDIR)/debian/extra/$${bdn} && patch -p1 < $${p} ) ; \
	done ; \
	( cd $${builddir}/$(SRCDIR) && find debian/ -type f -exec file --mime {} \; | fgrep 'charset=binary' | cut -d ':' -f 1 > include-binaries && mv include-binaries debian/source/ ) ; \
	module_copyright="nginx-module-$${module_asis}.copyright" ; \
	cp -p $(DOCS)/$${module_copyright} $${builddir}/$(SRCDIR)/debian/copyright ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	addcontroltags=`echo "$$MODULE_ADD_CONTROL_TAGS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	sed $${builddir}/$(SRCDIR)/debian/nginx$(MODULE_SUFFIX)-module.control.in \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%PACKAGE_VENDOR%%#$(PACKAGE_VENDOR)#g" \
		-e "s#%%MODULE_PACKAGE_URL%%#$(MODULE_PACKAGE_URL)#g" \
		-e "s#%%SUMMARY%%#$(MODULE_SUMMARY_PREFIX) $(MODULE_SUMMARY_$(call modname, $*))#g" \
		-e "s#%%SHORT_SUMMARY%%#$(MODULE_SUMMARY_$(call modname, $*))#g" \
		-e "s#%%CODENAME%%#$(CODENAME)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $*))#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
		-e "s#%%MODULE_BUILD_DEPENDS%%#$(MODULE_BUILD_DEPENDS_$(call modname, $*))#g" \
		-e "s#%%MODULE_DEPENDS%%#$(MODULE_DEPENDS_$(call modname, $*))#g" \
		-e "s#%%ADD_CONTROL_TAGS%%#$${addcontroltags}#g" \
	> $${builddir}/$(SRCDIR)/debian/control ; \
	cat nginx-module-$*.deb-changelog | sed \
		-e "s#%%TARGET_VERSION%%#$(TARGET_VERSION)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%CODENAME%%#$(CODENAME)#g" \
		-e "s#%%VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $*))#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
	> $${builddir}/$(SRCDIR)/debian/changelog ; \
	sed $${builddir}/$(SRCDIR)/debian/nginx$(MODULE_SUFFIX)-module.rules.in \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%CODENAME%%#$(CODENAME)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%MODULE_SUFFIX%%#$(MODULE_SUFFIX)#g" \
		-e "s#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g" \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $*))#g" \
		-e "s#%%MODULE_DEFINITIONS%%#$${definitions}#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_CC_OPT%%#$(MODULE_CC_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT%%#$(MODULE_LD_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT_DEBUG%%#$(MODULE_LD_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
	> $${builddir}/$(SRCDIR)/debian/rules ; \
	sed $${builddir}/$(SRCDIR)/debian/nginx$(MODULE_SUFFIX)-module.postinst.in \
		-e "s#%%MODULE_POST%%#$$post#g" \
	> $${builddir}/$(SRCDIR)/debian/nginx$(MODULE_SUFFIX)-module-$${module_asis}.postinst ; \
	chmod +x $${builddir}/$(SRCDIR)/debian/rules ; \
	ln -s $${builddir}/$(SRCDIR)/debian/rules $@ ; \
	}

.deps-module-%:
	touch $@

nginx-tests-quic:
	@{ \
	if [ ! -L "nginx-tests-quic" ]; then \
	    echo "===> Cloning QUIC tests" ; \
	    rm -rf ../nginx-tests; \
	    hg clone -r quic https://hg.nginx.org/nginx-tests-quic ../nginx-tests; \
	    ln -s ../nginx-tests nginx-tests-quic; \
	fi ; \
	}

ifeq ($(BASE_TARGET), quic)
nginx-tests: nginx-tests-quic
endif

nginx-tests:
	@{ \
	if [ -d "$(SRCPATH)/nginx-tests" ]; then \
		echo "===> Copying tests from $(SRCPATH)/nginx-tests" ; \
		cp -rP $(SRCPATH)/nginx-tests nginx-tests ; \
	else \
		echo "===> Cloning tests" ; \
		hg clone https://hg.nginx.org/nginx-tests ; \
	fi ; \
	}

test: base nginx-tests
	@echo "===> Running tests with regular binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	globals_http= ; \
	globals_stream= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module.so" | sort -t / -k 2`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx/objs/src/http/modules/perl:$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/debuild-module-modsecurity/$(SRCDIR)/debian/build-nginx/extra/modsecurity/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/debuild-module-opentracing/$(SRCDIR)/debian/build-nginx/extra/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/debuild-module-lua/$(SRCDIR)/debian/extra/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/debuild-module-lua/$(SRCDIR)/debian/extra/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
		globals_stream="$$globals_http" ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" TEST_NGINX_GLOBALS_HTTP="$$globals_http" TEST_NGINX_GLOBALS_STREAM="$$globals_stream" prove $$PROVE_ARGS . ; \
	}

test-debug: base nginx-tests
	@echo "===> Running tests with debug binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	globals_http= ; \
	globals_stream= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module-debug.so" | sort -t / -k 2`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx-debug/objs/src/http/modules/perl:$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/debuild-module-modsecurity/$(SRCDIR)/debian/build-nginx-debug/extra/modsecurity/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/debuild-module-opentracing/$(SRCDIR)/debian/build-nginx-debug/extra/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/debuild-module-lua/$(SRCDIR)/debian/extra/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/debuild-module-lua/$(SRCDIR)/debian/extra/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
		globals_stream="$$globals_http" ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx-debug TEST_NGINX_GLOBALS="$$globals" TEST_NGINX_GLOBALS_HTTP="$$globals_http" TEST_NGINX_GLOBALS_STREAM="$$globals_stream" prove $$PROVE_ARGS . ; \
	}

test-modules: $(addprefix test-module-, $(MODULES))

test-module-%: base nginx-tests module-%
	@{ \
	module=`echo $@ | cut -d '-' -f 3-` ; \
	testdir="$(MODULE_TESTS_$(shell echo $@ | cut -d '-' -f 3-))" ; \
	if [ -z "$$testdir" ]; then \
		echo "---> Skipping, no tests defined for $$module module" ; \
		exit 0 ; \
	fi ; \
	pwd=`pwd` ; \
	globals= ; \
	if [ "$$module" = "modsecurity" ]; then \
		export LD_LIBRARY_PATH=$$pwd/debuild-module-modsecurity/$(SRCDIR)/debian/build-nginx/extra/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	for so in `find module-$${module}/ -maxdepth 1 -type f -name "*module.so"`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ ! -d nginx-tests/module-$${module} ]; then \
		cp -r $${pwd}/debuild-module-$${module}/$(SRCDIR)/debian/extra/$${testdir} nginx-tests/module-$${module} ; \
		ln -fs ../lib nginx-tests/module-$${module}/lib ; \
	fi ; \
	cd nginx-tests/module-$${module} && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

check-modules:
	@{ \
	files=$@-files ; \
	rpath=$@-rpath ; \
	exitcode=0 ; \
	for module in $(MODULES); do \
		searchpath=debuild-module-$${module}/$(SRCDIR)/debian/nginx-module-$${module}/ ; \
		[ -d $${searchpath} ] || continue ; \
		case $${module} in \
			_placeholder) \
				echo "Skipping module-$${module} checks due to known good rpaths" ; \
			;; \
			*) \
				echo "Checking module-$${module} for rpaths" ; \
				for p in usr/bin/ usr/sbin/; do \
					find $${searchpath}$${p} -type f -executable -print > $${files} 2>/dev/null ; \
				done; \
				for p in usr/lib/ usr/lib64/; do \
					find $${searchpath}$${p} -type f -iname "*.so" -print >> $${files} 2>/dev/null ; \
				done; \
				echo -n > $${rpath} ; \
				while IFS= read -r line; do \
					RPATH=`objdump -x $${line} 2>/dev/null | grep -E 'R.*PATH' | sed 's,R.*PATH,,' | tr -d ' '` ; \
					if [ $${RPATH} ]; then \
						echo $${line}:$${RPATH} >> $${rpath} ; \
					fi; \
				done < $${files} ; \
				if [ -s $${rpath} ]; then \
					echo "RPATHs found!" ; \
					cat $${rpath} ; \
					exitcode=1 ; \
				fi ; \
			;; \
		esac ; \
	done ; \
	[ -f $${files} ] && rm -f $${files} ; \
	[ -f $${rpath} ] && rm -f $${rpath} ; \
	exit $${exitcode} ; \
	}

clean:
	@rm -rf base module-* rules-base rules-module-* debuild-base debuild-module-* nginx-tests $(BASE_SRC) .deps-module-*
	@rm -f nginx.deb-changelog nginx-*.deb.changelog nginx-module-*.deb-changelog nginx-module-*.skip
	@make -f Makefile.quictls clean

.PHONY:	default list list-base list-all-modules list-base-modules all modules rules test test-debug check-modules clean

.SECONDARY:
