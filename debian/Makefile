SHELL=		/bin/bash

CONTRIB?=	../contrib
CONTRIB:=	$(abspath $(CONTRIB))

include $(CONTRIB)/src/nginx/version

BASE_VERSION=	$(NGINX_VERSION)
BASE_RELEASE=	1
PLUS_VERSION=	$(NGINX_PLUS_VERSION)
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCDIR=		nginx-$(BASE_VERSION)
SRCPATH?=	../..
DOCS?=		../docs
BUILD_ENV_PATH=	${HOME}/debuild
MODULE_TARGET?=	oss

ifeq ($(MODULE_TARGET), plus)
MODULE_CONTROL_TEMPLATE=   nginx-plus-module.control.in
TARGET_SUFFIX=	-plus
MODULE_SUMMARY_PREFIX=NGINX Plus
TARGET_VERSION=$(PLUS_VERSION)
MODULE_PACKAGE_PREFIX=nginx-plus-module
else
MODULE_CONTROL_TEMPLATE=   nginx-module.control.in
MODULE_SUMMARY_PREFIX=nginx
TARGET_VERSION=$(BASE_VERSION)
MODULE_PACKAGE_PREFIX=nginx-module
endif

MODULE_TARGET_PREFIX=$(TARGET_VERSION)+

MODULE_PACKAGE_VENDOR=	Sergey Budnevitch <sb@nginx.com>
MODULE_PACKAGE_URL=	https://nginx.org/

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

export CR=\\n

modname = $(shell echo $1 | tr '-' '_')

default:
	@echo "valid targets: all base $(addprefix module-, $(MODULES)) test test-debug"

list-base:
	@printf "%-20s\t%s\n" nginx $(BASE_VERSION)-$(BASE_RELEASE)

list-module-%:
	@printf "%-20s\t%s\n" $* $(MODULE_VERSION_$(call modname, $*))-$(MODULE_RELEASE_$(call modname, $*))

list-all-modules: $(addprefix list-module-, $(MODULES))

list-base-modules: $(addprefix list-module-, $(BASE_MODULES))

list: list-base list-all-modules

all:	base base-modules
	@echo "===> all done"

base-modules:	$(addprefix module-, $(BASE_MODULES))

modules:	$(addprefix module-, $(MODULES))

rules:	rules-base $(addprefix rules-module-, $(MODULES))

base:	rules-base
	@echo "===> Building base package" ; \
	$(SHELL) -c "cd debuild-base/$(SRCDIR) ; export DEB_BUILD_OPTIONS=parallel=$(NPROC) ; time -p debuild -us -uc" && \
	find debuild-base/ -maxdepth 1 -type f -exec cp {} ../../ \; && \
	ln -s debuild-base/$(SRCDIR)/debian/nginx/usr/sbin base

$(BASE_SRC):
	cd $(CONTRIB) && make .sum-nginx
	ln -s $(CONTRIB)/tarballs/$(BASE_SRC) $(BASE_SRC)

nginx.deb-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx.deb-changelog

rules-base: $(BASE_SRC) nginx.deb-changelog
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	mkdir -p debuild-base ; \
	cp $(BASE_SRC) debuild-base/nginx_$(BASE_VERSION).orig.tar.gz ; \
	tar -C debuild-base -xf debuild-base/nginx_$(BASE_VERSION).orig.tar.gz ; \
	mkdir -p debuild-base/$(SRCDIR)/debian ; \
	mkdir -p debuild-base/$(SRCDIR)/debian/source ; \
	echo "3.0 (quilt)" > debuild-base/$(SRCDIR)/debian/source/format ; \
	echo "9" > debuild-base/$(SRCDIR)/debian/compat ; \
	cat nginx.rules.in | sed \
		-e 's#%%CODENAME%%#$(CODENAME)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> debuild-base/$(SRCDIR)/debian/rules ; \
	cat nginx.deb-changelog | sed \
		-e 's#%%CODENAME%%#$(CODENAME)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		> debuild-base/$(SRCDIR)/debian/changelog ; \
	cat nginx.control.in | sed \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		> debuild-base/$(SRCDIR)/debian/control ; \
	cp debuild-base/$(SRCDIR)/CHANGES debuild-base/$(SRCDIR)/CHANGES.ru nginx.* nginx-debug.default nginx-debug.service debuild-base/$(SRCDIR)/debian/ ; \
	cp $(DOCS)/nginx.copyright debuild-base/$(SRCDIR)/debian/copyright ; \
	chmod +x debuild-base/$(SRCDIR)/debian/rules ; \
	ln -s debuild-base/$(SRCDIR)/debian/rules rules-base ; \
	}

module-%: rules-module-%
	@echo "===> Building nginx-$@ package" ; \
	$(SHELL) -c "cd debuild-$@/$(SRCDIR) ; export DEB_BUILD_OPTIONS=parallel=$(NPROC) ; time -p debuild -us -uc" && \
	find debuild-$@/ -maxdepth 1 -type f -exec cp {} ../../ \; && \
	ln -s debuild-$@/$(SRCDIR)/debian/$(MODULE_PACKAGE_PREFIX)-$*/usr/lib/nginx/modules $@

nginx-module-%.deb-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx-module-$*.deb-changelog
	@{ \
	if [ "$(MODULE_TARGET)" = "plus" ]; then \
		sed -i -e 's,nginx-module-,nginx-plus-module-,g' $(CURDIR)/nginx-module-$*.deb-changelog ; \
	fi ; \
	}


rules-module-%: $(BASE_SRC) nginx-module-%.deb-changelog .deps-module-%
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	curdir=`pwd` ; \
	module_asis=`echo $@ | cut -d '-' -f 3-` ; \
	builddir=`echo debuild-module-$${module_asis}` ; \
	mkdir -p $${builddir} ; \
	if [ "$(MODULE_TARGET)" = "oss" ]; then \
		module_version="$(MODULE_VERSION_PREFIX_$(call modname, $*))$(MODULE_VERSION_$(call modname, $*))" ; \
		orig_name="nginx-module-$${module_asis}_$${module_version}.orig.tar.gz" ; \
	else \
		module_version="$(MODULE_VERSION_PREFIX_$(call modname, $*))$(MODULE_VERSION_$(call modname, $*))" ; \
		orig_name="nginx-plus-module-$${module_asis}_$${module_version}.orig.tar.gz" ; \
	fi ; \
	cp $(BASE_SRC) $${builddir}/$${orig_name} ; \
	tar -C $${builddir} -xf $${builddir}/$${orig_name} ; \
	mkdir -p $${builddir}/$(SRCDIR)/debian/extra ; \
	mkdir -p $${builddir}/$(SRCDIR)/debian/source ; \
	echo "3.0 (quilt)" > $${builddir}/$(SRCDIR)/debian/source/format ; \
	echo "9" > $${builddir}/$(SRCDIR)/debian/compat ; \
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
	cat $(MODULE_CONTROL_TEMPLATE) | sed \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%MODULE_PACKAGE_VENDOR%%#$(MODULE_PACKAGE_VENDOR)#g" \
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
	cat nginx-module.rules.in | sed \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%CODENAME%%#$(CODENAME)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%TARGET_SUFFIX%%#$(TARGET_SUFFIX)#g" \
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
	cat nginx-module.postinst.in | sed \
		-e "s#%%MODULE_POST%%#$$post#g" \
	> $${builddir}/$(SRCDIR)/debian/nginx$(TARGET_SUFFIX)-module-$${module_asis}.postinst ; \
	chmod +x $${builddir}/$(SRCDIR)/debian/rules ; \
	ln -s $${builddir}/$(SRCDIR)/debian/rules $@ ; \
	}

.deps-module-%:
	touch $@

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
	if [ -d $$pwd/debuild-module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx/objs/src/http/modules/perl:$$pwd/debuild-module-perl/nginx-$(BASE_VERSION)/debian/build-nginx/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/debuild-module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/debuild-module-modsecurity/$(SRCDIR)/debian/build-nginx/extra/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/debuild-module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/debuild-module-opentracing/$(SRCDIR)/debian/build-nginx/extra/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/debuild-module-lua ]; then \
		globals_http="lua_package_path '$$pwd/debuild-module-lua/nginx-$(BASE_VERSION)/debian/extra/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/debuild-module-lua/nginx-$(BASE_VERSION)/debian/extra/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
	if [ -d $$pwd/debuild-module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/debuild-module-perl/$(SRCDIR)/debian/build-nginx-debug/objs/src/http/modules/perl:$$pwd/debuild-module-perl/nginx-$(BASE_VERSION)/debian/build-nginx/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/debuild-module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/debuild-module-modsecurity/$(SRCDIR)/debian/build-nginx-debug/extra/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/debuild-module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/debuild-module-opentracing/$(SRCDIR)/debian/build-nginx-debug/extra/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/debuild-module-lua ]; then \
		globals_http="lua_package_path '$$pwd/debuild-module-lua/nginx-$(BASE_VERSION)/debian/extra/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/debuild-module-lua/nginx-$(BASE_VERSION)/debian/extra/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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

clean:
	@rm -rf base module-* rules-base rules-module-* debuild-base debuild-module-* nginx-tests $(BASE_SRC) .deps-module-*
	@rm -f nginx.deb-changelog nginx-module-*.deb-changelog

.PHONY:	default list list-base list-all-modules list-base-modules all modules rules test test-debug clean

.SECONDARY:
