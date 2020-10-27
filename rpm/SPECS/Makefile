SHELL=		/bin/bash

BASE_VERSION=	1.19.4
BASE_RELEASE=	1
PLUS_VERSION=	22
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCPATH?=	../SOURCES
BUILD_ENV_PATH=	${HOME}/rpmbuild
MODULE_TARGET?=	oss
MODSRC_PREFIX=
MODSRC_PATH=	$(SRCPATH)
BUILD_DIR=	%{bdir}
DOCS?=		../../docs

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
MODULE_PACKAGE_URL=	http://nginx.org/
MODULE_PACKAGE_LICENSE=2-clause BSD-like license

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

modname = $(shell echo $1 | cut -c 14- | cut -d '.' -f 1 | tr '-' '_')

default:
	@echo "valid targets: all base $(addprefix module-, $(MODULES)) test test-debug"

all:	base modules
	@echo "===> all done"

modules:	$(addprefix module-, $(MODULES))

specs:	nginx.spec $(addsuffix .spec, $(addprefix nginx-module-, $(MODULES)))

$(BASE_SRC):
	wget http://nginx.org/download/$(BASE_SRC)

$(SRCPATH)/$(BASE_SRC):
	@cd $(SRCPATH) && wget http://nginx.org/download/$(BASE_SRC)

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

module-%: nginx-module-%.spec check-compat-% $(SRCPATH)/$(BASE_SRC)
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
	for src in $(MODULE_SOURCES_$(call modname, $@)); do \
		s="`printf "Source%d: %s\n" $${i} $${src}`" ; \
		sources="$${sources}\n$${s}" ; \
		s="`printf "tar zxf %%{SOURCE%d\}" $${i}`" ; \
		prepsources="$${prepsources}\n$${s}" ; \
		i=$$(($${i}+1)) ; \
	done ; \
	i=100 ; \
	patches= ; \
	preppatches= ; \
	for src in $(MODULE_PATCHES_$(call modname, $@)); do \
		s="`printf "Patch%d: %s\n" $${i} $${src}`" ; \
		patches="$${patches}\n$${s}" ; \
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
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	files=`echo "$$MODULE_FILES_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	cat $(MODULE_SPEC_TEMPLATE) | sed \
		-e "s#%%NAME%%#$${pkgname}#g" \
		-e "s#%%MODULE_PACKAGE_VENDOR%%#$(MODULE_PACKAGE_VENDOR)#g" \
		-e "s#%%MODULE_PACKAGE_URL%%#$(MODULE_PACKAGE_URL)#g" \
		-e "s#%%MODULE_PACKAGE_LICENSE%%#$(MODULE_PACKAGE_LICENSE)#g" \
		-e "s#%%SUMMARY%%#$(MODULE_SUMMARY_PREFIX) $(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%SHORT_SUMMARY%%#$(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%TARGET_VERSION%%#$(TARGET_VERSION)#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $@))#g" \
		-e "s#%%VERSION%%#$(MODULE_VERSION_$(call modname, $@))#g" \
		-e "s#%%RELEASE%%#$(MODULE_RELEASE_$(call modname, $@))#g" \
		-e "s#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g" \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $@))#g" \
		-e "s#%%COPYRIGHT_SOURCE%%#$${module_copyright}#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_PATCHES%%#$${patches}#g" \
		-e "s#%%MODULE_PREP_SOURCES%%#$${prepsources}#g" \
		-e "s#%%MODULE_PREP_PATCHES%%#$${preppatches}#g" \
		-e "s#%%MODULE_DEFINITIONS%%#$${definitions}#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_CC_OPT%%#$(MODULE_CC_OPT_$(call modname, $@))#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_LD_OPT%%#$(MODULE_LD_OPT_$(call modname, $@))#g" \
		-e "s#%%MODULE_LD_OPT_DEBUG%%#$(MODULE_LD_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_FILES%%#$${files}#g" \
		-e "s#%%MODULE_POST%%#$${post}#g" \
		> $@.tmp && \
	cat nginx-module-$*.rpm-changelog | sed \
		-e 's#%%TARGET_VERSION%%#$(TARGET_VERSION)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $@))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $@))#g" \
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
		hg clone http://hg.nginx.org/nginx-tests ; \
	fi ; \
	}

test: base nginx-tests
	@echo "===> Running tests with regular binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module.so" | sort -t / -k 2`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ;  \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove . ; \
	}

test-debug: base nginx-tests
	@echo "===> Running tests with debug binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module-debug.so" | sort -t / -k 2`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ;  \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx-debug TEST_NGINX_GLOBALS="$$globals" prove . ; \
	}

prepare-build-env: $(BASE_SRC)
	@{ \
	set -e ; \
	cwd=`pwd` ; \
	case $$cwd in $(BUILD_ENV_PATH)*) \
		echo "You are in $(BUILD_ENV_PATH), skipping" >&2 ; \
		exit 1 ; \
	esac ; \
	if [ -e $(BUILD_ENV_PATH) ]; then \
		echo "$(BUILD_ENV_PATH) is already exists and going to be removed." ; \
		echo "Press Enter to continue or Ctrl+C to exit" ; \
		read ; \
		rm -rf $(BUILD_ENV_PATH) ; \
	fi ; \
	mkdir -p $(BUILD_ENV_PATH) ; \
	pd=`dirname $${cwd}` ; \
	cp -rP $${pd}/SPECS $(BUILD_ENV_PATH)/ ; \
	cp -rP $${pd}/SOURCES $(BUILD_ENV_PATH)/ ; \
	cp $(BASE_SRC) $(BUILD_ENV_PATH)/SOURCES/ ; \
	cp -pr $(DOCS) $(BUILD_ENV_PATH); \
	echo "Build environment has been created in: $(BUILD_ENV_PATH)" ; \
	echo ; \
	echo "Please do the following in order to get available build targets:" ; \
	echo "    cd $(BUILD_ENV_PATH)/SPECS" ; \
	echo "    make" ; \
	}

clean:
	@rm -f base module-*
	@rm -f nginx.spec nginx-module-*.spec nginx-module-*.skip
	@rm -rf nginx-tests
	@rm -f $(BASE_SRC) $(SRCPATH)/$(BASE_SRC)
	@rm -f nginx.rpm-changelog nginx-module-*.rpm-changelog

.PHONY:	default all modules specs test test-debug clean

.SECONDARY:
