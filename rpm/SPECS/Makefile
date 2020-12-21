SHELL=		/bin/bash

BASE_VERSION=	1.19.6
BASE_RELEASE=	1
PLUS_VERSION=	23
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCPATH?=	../SOURCES
BUILD_ENV_PATH=	${HOME}/rpmbuild
MODULE_TARGET?=	oss
MODSRC_PREFIX=
BUILD_DIR=	%{bdir}
DOCS?=		../../docs
CONTRIB?=	../../contrib
CONTRIB:=	$(abspath $(CONTRIB))

ifeq ($(MODULE_TARGET), plus)
MODULE_SPEC_TEMPLATE=	nginx-plus-module.spec.in
MODULE_SUMMARY_PREFIX=	NGINX Plus
TARGET_VERSION=$(PLUS_VERSION)
MODULE_PACKAGE_PREFIX=nginx-plus-module
else
MODULE_SPEC_TEMPLATE=	nginx-module.spec.in
MODULE_SUMMARY_PREFIX=	nginx
TARGET_VERSION=$(BASE_VERSION)
MODULE_PACKAGE_PREFIX=nginx-module
endif

MODULE_TARGET_PREFIX=$(TARGET_VERSION)+

MODULE_PACKAGE_VENDOR=	Nginx, Inc.
MODULE_PACKAGE_URL=	https://nginx.org/
MODULE_PACKAGE_LICENSE=2-clause BSD-like license

BASE_MODULES=	geoip image-filter njs perl xslt

MODULES=

-include Makefile.module-*

BASE_CONFIGURE_ARGS=\
	--prefix=%{_sysconfdir}/nginx \
	--sbin-path=%{_sbindir}/nginx \
	--modules-path=%{_libdir}/nginx/modules \
	--conf-path=%{_sysconfdir}/nginx/nginx.conf \
	--error-log-path=%{_localstatedir}/log/nginx/error.log \
	--http-log-path=%{_localstatedir}/log/nginx/access.log \
	--pid-path=%{_localstatedir}/run/nginx.pid \
	--lock-path=%{_localstatedir}/run/nginx.lock \
	--http-client-body-temp-path=%{_localstatedir}/cache/nginx/client_temp \
	--http-proxy-temp-path=%{_localstatedir}/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=%{_localstatedir}/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=%{_localstatedir}/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=%{_localstatedir}/cache/nginx/scgi_temp \
	--user=%{nginx_user} \
	--group=%{nginx_group} \
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

specs:	nginx.spec $(addsuffix .spec, $(addprefix nginx-module-, $(MODULES)))

$(SRCPATH)/$(BASE_SRC):
	cd $(CONTRIB) && make .sum-nginx
	cd $(SRCPATH) && ln -s $(CONTRIB)/tarballs/$(BASE_SRC) $(BASE_SRC)

base:	nginx.spec $(SRCPATH)/$(BASE_SRC)
	@echo "===> Building base package" ; \
	$(SHELL) -c "time -p rpmbuild -D \"_topdir `pwd`/../\" -ba nginx.spec" && \
	ln -s ../BUILD/nginx-$(BASE_VERSION)/objs base

nginx.rpm-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx.rpm-changelog

nginx.spec: nginx.rpm-changelog
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	cat nginx.spec.in | sed \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> nginx.spec ; \
	cat nginx.rpm-changelog | sed \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
	>> nginx.spec ; \
	cp -p $(DOCS)/nginx.copyright ../SOURCES/ ; \
	}

.deps-module-%:
	touch $@

module-%: nginx-module-%.spec check-compat-% $(SRCPATH)/$(BASE_SRC) .deps-module-%
	@if [ -e nginx-$@.skip ]; then \
	    echo "---> Skipping nginx-$@ package (`cat nginx-$@.skip`)" ; \
	else \
	    echo "===> Building nginx-$@ package" ; \
	    $(SHELL) -c "time -p rpmbuild -D \"_topdir `pwd`/../\" -ba nginx-$@.spec" && \
	    ln -s ../BUILD/$(MODULE_PACKAGE_PREFIX)-$*-$(BASE_VERSION)/objs $@ ; \
	fi

nginx-module-%.rpm-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx-module-$*.rpm-changelog

nginx-module-%.spec: nginx-module-%.rpm-changelog
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	i=100 ; \
	sources= ; \
	prepsources= ; \
	for src in $(MODULE_SOURCES_$(call modname, $*)); do \
		if [ -h ../SOURCES/$${src} ] ; then rm ../SOURCES/$${src} ; fi ; \
		ln -s $(CONTRIB)/tarballs/$${src} ../SOURCES/$${src} ; \
		s="`printf "Source%d: %s\n" $${i} $${src}`" ; \
		sources="$${sources}\n$${s}" ; \
		case "$${src}" in \
			*.tar.xz) \
				taropts="xvJfo" ; \
				;; \
			*) \
				taropts="xvzfo" ; \
				;; \
		esac ; \
		s="`printf "tar $${taropts} %%{SOURCE%d\}" $${i}`" ; \
		prepsources="$${prepsources}\n$${s}" ; \
		sn=`echo $${src} | sed -e 's/-[0-9].*$$//'` ; \
		if [ "$${sn}" = "$${src}" ] ; then \
			sn=$${src%-*} ; \
		fi ; \
		s="`printf "ln -s $${sn}-* $${sn}"`" ; \
		prepsources="$${prepsources}\n$${s}" ; \
		i=$$(($${i}+1)) ; \
	done ; \
	i=100 ; \
	patches= ; \
	preppatches= ; \
	for src in $(MODULE_PATCHES_$(call modname, $*)); do \
		dn=`dirname $${src}` ; \
		bdn=`basename $${dn}` ; \
		pn="$${bdn}_`basename $${src}`" ; \
		if [ -h ../SOURCES/$${pn} ] ; then rm ../SOURCES/$${pn} ; fi ; \
		ln -s $${src} ../SOURCES/$${pn} ; \
		s="`printf "Patch%d: %s\n" $${i} $${pn}`" ; \
		patches="$${patches}\n$${s}" ; \
		s="`printf "cd %%{bdir}/$${bdn}"`" ; \
		preppatches="$${preppatches}\n$${s}" ; \
		s="`printf "%%patch%d -p1" $${i}`" ; \
		preppatches="$${preppatches}\n$${s}" ; \
		i=$$(($${i}+1)) ; \
	done ; \
	module_copyright=`echo $@ | sed -e "s#.spec#.copyright#"` ; \
	cp -p $(DOCS)/$${module_copyright} ../SOURCES/ ; \
	pkgname=$(shell echo $@ | cut -d '.' -f 1) ; \
	if [ "$(MODULE_TARGET)" = "plus" ]; then \
		pkgname=`echo $${pkgname} | sed -e "s#^nginx-#nginx-plus-#"` ; \
	fi ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	files=`echo "$$MODULE_FILES_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	cat $(MODULE_SPEC_TEMPLATE) | sed \
		-e "s#%%NAME%%#$${pkgname}#g" \
		-e "s#%%MODULE_PACKAGE_VENDOR%%#$(MODULE_PACKAGE_VENDOR)#g" \
		-e "s#%%MODULE_PACKAGE_URL%%#$(MODULE_PACKAGE_URL)#g" \
		-e "s#%%MODULE_PACKAGE_LICENSE%%#$(MODULE_PACKAGE_LICENSE)#g" \
		-e "s#%%SUMMARY%%#$(MODULE_SUMMARY_PREFIX) $(MODULE_SUMMARY_$(call modname, $*))#g" \
		-e "s#%%SHORT_SUMMARY%%#$(MODULE_SUMMARY_$(call modname, $*))#g" \
		-e "s#%%TARGET_VERSION%%#$(TARGET_VERSION)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $*))#g" \
		-e "s#%%VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
		-e "s#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g" \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $*))#g" \
		-e "s#%%COPYRIGHT_SOURCE%%#$${module_copyright}#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_PATCHES%%#$${patches}#g" \
		-e "s#%%MODULE_PREP_SOURCES%%#$${prepsources}#g" \
		-e "s#%%MODULE_PREP_PATCHES%%#$${preppatches}#g" \
		-e "s#%%MODULE_DEFINITIONS%%#$${definitions}#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_CC_OPT%%#$(MODULE_CC_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT%%#$(MODULE_LD_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT_DEBUG%%#$(MODULE_LD_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_FILES%%#$${files}#g" \
		-e "s#%%MODULE_POST%%#$${post}#g" \
		> $@.tmp && \
	cat nginx-module-$*.rpm-changelog | sed \
		-e 's#%%TARGET_VERSION%%#$(TARGET_VERSION)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
		>> $@.tmp && \
	mv $@.tmp $@ ; \
	}

check-compat-%:
	@module=`echo $@ | cut -d '-' -f 3 | tr '-' '_'` ; \
	case "$${module}" in \
	    geoip) \
		if [ `rpm --eval '0%{?rhel}'` -ge 8 ]; then \
		    echo "GeoIP can not be build on RHEL/CentOS >= 8" > \
		    nginx-module-$${module}.skip ; \
		    exit ; \
		fi ; \
		;; \
	esac

nginx-tests:
	@{ \
	if [ -d "../nginx-tests" ]; then \
		echo "===> Copying tests from ../nginx-tests" ; \
		cp -rP ../nginx-tests nginx-tests ; \
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
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ;  \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/../BUILD/nginx-module-lua-$(BASE_VERSION)/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/../BUILD/nginx-module-lua-$(BASE_VERSION)/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ;  \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/../BUILD/nginx-module-lua-$(BASE_VERSION)/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/../BUILD/nginx-module-lua-$(BASE_VERSION)/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
	for so in `find module-$${module}/ -maxdepth 1 -type f -name "*module.so"`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ ! -d nginx-tests/module-$${module} ]; then \
		cp -r $${pwd}/module-$${module}/../$${testdir} nginx-tests/module-$${module} ; \
		ln -fs ../lib nginx-tests/module-$${module}/lib ; \
	fi ; \
	cd nginx-tests/module-$${module} && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

clean:
	@rm -f base module-*
	@rm -f nginx.spec nginx-module-*.spec nginx-module-*.skip
	@rm -rf nginx-tests
	@rm -f $(BASE_SRC) $(SRCPATH)/$(BASE_SRC)
	@rm -f nginx.rpm-changelog nginx-module-*.rpm-changelog
	@rm -f .deps-module-*
	@find ../SOURCES/ -type l -delete

.PHONY:	default list list-base list-all-modules list-base-modules all modules specs test test-debug clean

.SECONDARY:
