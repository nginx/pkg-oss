SHELL=		/bin/bash

CONTRIB?=	../../contrib
CONTRIB:=	$(abspath $(CONTRIB))

BASE_TARGET?=	oss

ifeq ($(BASE_TARGET), plus)
BASE_SUFFIX=-plus
DOCS?=		../../docs-plus
MODULE_TARGET?=	plus
endif

DOCS?=		../../docs
MODULE_TARGET?=	oss

include $(CONTRIB)/src/nginx$(BASE_SUFFIX)/version

BASE_VERSION=	$(NGINX_VERSION)
BASE_RELEASE=	1
PLUS_VERSION=	$(NGINX_PLUS_VERSION)
PLUS_RELEASE=   $(BASE_RELEASE)
BASE_SRC=	nginx$(BASE_SUFFIX)-$(BASE_VERSION).tar.gz
SRCPATH?=	../SOURCES
BUILD_ENV_PATH=	${HOME}/rpmbuild
MODSRC_PREFIX=
BUILD_DIR=	%{bdir}

ifeq ($(MODULE_TARGET), plus)
MODULE_SUMMARY_PREFIX=	NGINX Plus
TARGET_VERSION=$(PLUS_VERSION)
MODULE_SUFFIX=-plus
MODULE_PACKAGE_URL=	https://www.nginx.com/
MODULE_PACKAGE_LICENSE=	Proprietary (EULA included)
else
MODULE_SUMMARY_PREFIX=	nginx
TARGET_VERSION=$(BASE_VERSION)
MODULE_PACKAGE_URL=	https://nginx.org/
MODULE_PACKAGE_LICENSE=2-clause BSD-like license
endif

MODULE_SPEC_TEMPLATE=	nginx$(MODULE_SUFFIX)-module.spec.in
MODULE_PACKAGE_PREFIX=nginx$(MODULE_SUFFIX)-module
MODULE_TARGET_PREFIX=$(TARGET_VERSION)+

PACKAGE_VENDOR=	NGINX Packaging <nginx-packaging@f5.com>

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
	cd $(CONTRIB) && make .sum-nginx$(BASE_SUFFIX)
	cd $(SRCPATH) && ln -s $(CONTRIB)/tarballs/$(BASE_SRC) $(BASE_SRC)

base:	nginx.spec $(SRCPATH)/$(BASE_SRC)
	@echo "===> Building base package" ; \
	$(SHELL) -c "time -p rpmbuild -D \"_topdir `pwd`/../\" -ba nginx$(BASE_SUFFIX).spec" && \
	ln -s ../BUILD/nginx$(BASE_SUFFIX)-$(BASE_VERSION)/objs base

nginx.rpm-changelog:
	@echo "===> Generating $@"
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/nginx$(BASE_SUFFIX).rpm-changelog

nginx.spec: nginx.rpm-changelog
ifeq ($(BASE_TARGET), plus)
	cp $(DOCS)/nginx-modules-reference.pdf $(SRCPATH)
	cp $(CONTRIB)/tarballs/dashboard.html $(SRCPATH)
	cp $(DOCS)/EULA* $(SRCPATH)
endif
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	cp -p $(DOCS)/nginx.copyright $(SRCPATH) ; \
	patch_files=`find $(CONTRIB)/src/nginx$(BASE_SUFFIX)/ \
		-type f -name '*.patch' -printf "%f\n" | sort`; \
	patches=`for i in $$patch_files; do echo $$i; done | \
			awk '{ printf "Patch%03d: %s\n", NR, $$0 }'`; \
	for patch in $$patch_files; do \
		cp -v $(CONTRIB)/src/nginx$(BASE_SUFFIX)/$$patch $(SRCPATH) ; \
	done; \
	sed nginx$(BASE_SUFFIX).spec.in \
		-e 's#%%PACKAGE_VENDOR%%#$(PACKAGE_VENDOR)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%PLUS_VERSION%%#$(PLUS_VERSION)#g' \
		-e 's#%%PLUS_RELEASE%%#$(PLUS_RELEASE)#g' \
		-e "s#%%BASE_PATCHES%%#$$patches#g" \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> nginx$(BASE_SUFFIX).spec ; \
	sed nginx$(BASE_SUFFIX).rpm-changelog \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%PLUS_VERSION%%#$(PLUS_VERSION)#g' \
		-e 's#%%PLUS_RELEASE%%#$(PLUS_RELEASE)#g' \
	>> nginx$(BASE_SUFFIX).spec ; \
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
	@cd $(DOCS) && DEST=$(CURDIR) VERSIONMASK=1 make $(CURDIR)/$@

nginx-module-%.spec: nginx-module-%.rpm-changelog
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	i=100 ; \
	sources= ; \
	prepsources= ; \
	for src in $(MODULE_SOURCES_$(call modname, $*)); do \
		ln -sf $(CONTRIB)/tarballs/$${src} $(SRCPATH)/$${src} ; \
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
		ln -sf $${src} $(SRCPATH)/$${pn} ; \
		s="`printf "Patch%d: %s\n" $${i} $${pn}`" ; \
		patches="$${patches}\n$${s}" ; \
		s="`printf "cd %%{bdir}/$${bdn}"`" ; \
		preppatches="$${preppatches}\n$${s}" ; \
		s="`printf "%%patch%d -p1" $${i}`" ; \
		preppatches="$${preppatches}\n$${s}" ; \
		i=$$(($${i}+1)) ; \
	done ; \
	module_copyright=`echo $@ | sed -e "s#.spec#.copyright#"` ; \
	cp -p $(DOCS)/$${module_copyright} $(SRCPATH) ; \
	pkgname=$(shell echo $@ | cut -d '.' -f 1) ; \
	pkgname=`echo $${pkgname} | sed -e "s#^nginx-#nginx$(MODULE_SUFFIX)-#"` ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	files=`echo "$$MODULE_FILES_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	sed $(MODULE_SPEC_TEMPLATE) \
		-e "s#%%NAME%%#$${pkgname}#g" \
		-e "s#%%PACKAGE_VENDOR%%#$(PACKAGE_VENDOR)#g" \
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
		-e "s#%%BASE_SUFFIX%%#$(BASE_SUFFIX)#g" \
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
	sed nginx-module-$*.rpm-changelog \
		-e 's#%%TARGET_VERSION%%#$(TARGET_VERSION)#g' \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
		>> $@.tmp && \
	mv $@.tmp $@ ; \
	}

check-compat-%:
	@module=`echo $@ | cut -d '-' -f 3 | tr '-' '_'` ; \
	case "$${module}" in \
		brotli) \
		if [	`rpm --eval '0%{?suse_version}'` -gt 0 -a `rpm --eval '0%{?suse_version}'` -lt 1500 -o \
				`rpm --eval '0%{?fedora}'` -gt 0 -a `rpm --eval '0%{?fedora}'` -lt 29 -o \
				`rpm --eval '0%{?amzn}'` -eq 1 ]; then \
			echo "Brotli can't be build on SLES < 15, Fedora < 29 or Amazon Linux 1" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		;; \
		geoip) \
		if [ `rpm --eval '0%{?rhel}'` -ge 8 ] || [ `rpm --eval '0%{?amzn}'` -gt 2 ]; then \
			echo "GeoIP can not be build on RHEL/CentOS >= 8 or Amazon Linux >2" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		;; \
		geoip2) \
		if [ `rpm --eval '0%{?suse_version}'` -gt 0 -a `rpm --eval '0%{?suse_version}'` -lt 1500 ]; then \
			echo "GeoIP2 can not be built on SuSe linux < 15 due to libmaxminddb absence" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		;; \
		lua) \
		ARCH=`rpm --eval '%{_arch}'` ; \
		if [ "$$ARCH" = "ppc64le" -o "$$ARCH" = "s390x" ]; then \
			echo "Lua module can not be built on $$ARCH" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		;; \
		modsecurity) \
		if [ "`rpm --eval '%{_arch}'`" = "ppc64le" ]; then \
			echo "ModSecurity can not be built on ppc64le" > \
			nginx-module-$${module}.skip ; \
		fi ; \
		;; \
		opentracing) \
		if [ "`rpm --eval '0%{?suse_version}'`" -gt 0 -a "`rpm --eval '0%{?suse_version}'`" -lt 1500 ]; then \
			echo "OpenTracing can not be built on SLES < 15 due to absence of yaml-cpp" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		if [ "`rpm --eval '0%{?amzn}'`" -eq 1 ]; then \
			echo "OpenTracing can not be built on Amazon Linux due to old yaml-cpp library" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		if [ "`rpm --eval '%{_arch}'`" = "ppc64le" ]; then \
			echo "OpenTracing can not be built on ppc64le" > \
			nginx-module-$${module}.skip ; \
			exit ; \
		fi ; \
		if [ `rpm --eval '0%{?rhel}'` -gt 0 ]; then \
			cmake3 -version >/dev/null 2>&1 ; \
			if [ $$? -ne 0 ]; then \
			echo "OpenTracing requires cmake3 on RHEL/CentOS/Amazon Linux" > \
			nginx-module-$${module}.skip ; \
			fi ; \
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
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-modsecurity/../modsecurity/local/lib:$$LD_LIBRARY_PATH ; \
	fi ;  \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib:$$LD_LIBRARY_PATH ; \
	fi ;  \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/../BUILD/$(MODULE_PACKAGE_PREFIX)-lua-$(BASE_VERSION)/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/../BUILD/$(MODULE_PACKAGE_PREFIX)-lua-$(BASE_VERSION)/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-modsecurity/../modsecurity-$(MODSECURITY_GITHASH)/local/lib:$$LD_LIBRARY_PATH ; \
	fi ;  \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$pwd/module-opentracing/../opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ;  \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/../BUILD/$(MODULE_PACKAGE_PREFIX)-lua-$(BASE_VERSION)/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/../BUILD/$(MODULE_PACKAGE_PREFIX)-lua-$(BASE_VERSION)/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
	@rm -f nginx.rpm-changelog nginx-*.rpm-changelog nginx-module-*.rpm-changelog
	@rm -f .deps-module-*
	@find $(SRCPATH)/ -type l -delete

.PHONY:	default list list-base list-all-modules list-base-modules all modules specs test test-debug clean

.SECONDARY:
