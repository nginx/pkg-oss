SHELL=		/bin/bash

BASE_VERSION=	1.14.1
BASE_RELEASE=	1
PLUS_VERSION=	15
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCPATH?=	../SOURCES
BUILD_ENV_PATH=	${HOME}/rpmbuild
MODULE_TARGET?=	oss
MODSRC_PREFIX=
MODSRC_PATH=	$(SRCPATH)
BUILD_DIR=	%{bdir}

ifeq ($(MODULE_TARGET), plus)
MODULE_SPEC_TEMPLATE=	nginx-plus-module.spec.in
MODULE_SUMMARY_PREFIX=	NGINX Plus
else
MODULE_SPEC_TEMPLATE=	nginx-module.spec.in
MODULE_SUMMARY_PREFIX=	nginx
endif

MODULE_PACKAGE_VENDOR=	Nginx, Inc.
MODULE_PACKAGE_URL=	http://nginx.org/
MODULE_PACKAGE_LICENSE=2-clause BSD-like license

MODULES=	geoip image-filter njs perl xslt

-include Makefile.module-*

MODULE_SUMMARY_geoip=		GeoIP dynamic modules
MODULE_SUMMARY_image_filter=	image filter dynamic module
MODULE_SUMMARY_njs=		njs dynamic modules
MODULE_SUMMARY_perl=		Perl dynamic module
MODULE_SUMMARY_xslt=		xslt dynamic module

MODULE_VERSION_geoip=		$(BASE_VERSION)
MODULE_RELEASE_geoip=		1
MODULE_VERSION_image_filter=	$(BASE_VERSION)
MODULE_RELEASE_image_filter=	1
MODULE_VERSION_njs=		0.2.6
MODULE_RELEASE_njs=		1
MODULE_VERSION_perl=		$(BASE_VERSION)
MODULE_RELEASE_perl=		1
MODULE_VERSION_xslt=		$(BASE_VERSION)
MODULE_RELEASE_xslt=		1

MODULE_SOURCES_njs=		njs-$(MODULE_VERSION_njs).tar.gz

MODULE_CONFARGS_geoip=		--with-http_geoip_module=dynamic \
				--with-stream_geoip_module=dynamic
MODULE_CONFARGS_image_filter=	--with-http_image_filter_module=dynamic
MODULE_CONFARGS_njs=		--add-dynamic-module=njs-$(MODULE_VERSION_njs)/nginx
MODULE_CONFARGS_perl=		--with-http_perl_module=dynamic
MODULE_CONFARGS_xslt=		--with-http_xslt_module=dynamic

# geoip

define MODULE_DEFINITIONS_geoip
%if 0%{?suse_version} >= 1315
BuildRequires: libGeoIP-devel
Requires: libGeoIP1
%else
BuildRequires: GeoIP-devel
Requires: GeoIP
%endif
endef
export MODULE_DEFINITIONS_geoip

define MODULE_POST_geoip
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_geoip) for nginx have been installed.
To enable these modules, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_http_geoip_module.so;
    load_module modules/ngx_stream_geoip_module.so;

Please refer to the modules documentation for further details:
http://nginx.org/en/docs/http/ngx_http_geoip_module.html
http://nginx.org/en/docs/stream/ngx_stream_geoip_module.html

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_geoip

# image-filter

define MODULE_DEFINITIONS_image_filter
BuildRequires: gd-devel
Requires: gd
endef
export MODULE_DEFINITIONS_image_filter

define MODULE_POST_image_filter
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_image_filter) for nginx has been installed.
To enable this module, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_http_image_filter_module.so;

Please refer to the module documentation for further details:
http://nginx.org/en/docs/http/ngx_http_image_filter_module.html

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_image_filter

# njs

MODULE_VERSION_PREFIX_njs=$(BASE_VERSION).

define MODULE_DEFINITIONS_njs
BuildRequires: libedit-devel
endef
export MODULE_DEFINITIONS_njs

define MODULE_PREBUILD_njs
cd %{bdir}/njs-$(MODULE_VERSION_njs) \&\& ./configure \&\& make njs
endef
export MODULE_PREBUILD_njs

define MODULE_PREINSTALL_njs
%{__install} -m644 %{bdir}/njs-$(MODULE_VERSION_njs)/CHANGES \
	$$RPM_BUILD_ROOT%{_datadir}/doc/nginx-module-njs/
%{__mkdir} -p $$RPM_BUILD_ROOT%{_bindir}
%{__install} -m755 %{bdir}/njs-$(MODULE_VERSION_njs)/build/njs \
	$$RPM_BUILD_ROOT%{_bindir}/
endef
export MODULE_PREINSTALL_njs

define MODULE_FILES_njs
%{_bindir}/njs
endef
export MODULE_FILES_njs

define MODULE_POST_njs
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_njs) for nginx have been installed.
To enable these modules, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_http_js_module.so;
    load_module modules/ngx_stream_js_module.so;

Please refer to the modules documentation for further details:
http://nginx.org/en/docs/njs/
http://nginx.org/en/docs/http/ngx_http_js_module.html
http://nginx.org/en/docs/stream/ngx_stream_js_module.html

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_njs

# perl

define MODULE_DEFINITIONS_perl
%if 0%{?suse_version} >= 1315
BuildRequires: perl
%else
BuildRequires: perl-devel
BuildRequires: perl-ExtUtils-Embed
%endif
Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $$version))
endef
export MODULE_DEFINITIONS_perl

define MODULE_PREINSTALL_perl
%{__make} DESTDIR=$$RPM_BUILD_ROOT INSTALLDIRS=vendor -f objs/Makefile install_perl_modules
find %{buildroot} -type f -name .packlist -exec rm -f '{}' \\;
find %{buildroot} -type f -name perllocal.pod -exec rm -f '{}' \\;
find %{buildroot} -type f -empty -exec rm -f '{}' \\;
find %{buildroot} -type f -iname '*.so' -exec chmod 0755 '{}' \\;
endef
export MODULE_PREINSTALL_perl

define MODULE_FILES_perl
%dir %{perl_vendorarch}/auto/nginx
%{perl_vendorarch}/nginx.pm
%{perl_vendorarch}/auto/nginx/nginx.so
%{perl_vendorarch}/auto/nginx/nginx-debug.so
%{_mandir}/man3/nginx.3pm*
endef
export MODULE_FILES_perl

define MODULE_POST_perl
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_perl) for nginx has been installed.
To enable this module, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_http_perl_module.so;

Please refer to the module documentation for further details:
http://nginx.org/en/docs/http/ngx_http_perl_module.html

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_perl

# xslt

define MODULE_DEFINITIONS_xslt
BuildRequires: libxslt-devel
Requires: libxslt
endef
export MODULE_DEFINITIONS_xslt

define MODULE_POST_xslt
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_xslt) for nginx has been installed.
To enable this module, add the following to /etc/nginx/nginx.conf
and reload nginx:

    load_module modules/ngx_http_xslt_filter_module.so;

Please refer to the module documentation for further details:
http://nginx.org/en/docs/http/ngx_http_xslt_module.html

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_xslt


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
	$(SHELL) -c "time -p rpmbuild -ba nginx.spec" && \
	ln -s ../BUILD/nginx-$(BASE_VERSION)/objs base

nginx.spec:
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	cat nginx.spec.in | sed \
		-e 's#%%MAIN_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%MAIN_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> nginx.spec ; \
	}

module-%: nginx-module-%.spec $(SRCPATH)/$(BASE_SRC)
	@echo "===> Building nginx-$@ package" ; \
	$(SHELL) -c "time -p rpmbuild -ba nginx-$@.spec" && \
	ln -s ../BUILD/nginx-$@-$(BASE_VERSION)/objs $@

nginx-module-%.spec:
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
	if [ -f ../SOURCES/$${module_copyright} ]; then \
		copyright_source=$${module_copyright} ; \
	else \
		copyright_source=COPYRIGHT ; \
	fi ; \
	module_changelog=`echo $@ | sed -e "s#.spec#.changelog.in#"` ; \
	if [ -f $${module_changelog} ]; then \
		changelog_file=$${module_changelog} ; \
	else \
		changelog_file=nginx-module.changelog.in ; \
	fi ; \
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
		-e "s#%%MAIN_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%MAIN_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $@))#g" \
		-e "s#%%VERSION%%#$(MODULE_VERSION_$(call modname, $@))#g" \
		-e "s#%%RELEASE%%#$(MODULE_RELEASE_$(call modname, $@))#g" \
		-e "s#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g" \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $@))#g" \
		-e "s#%%COPYRIGHT_SOURCE%%#$${copyright_source}#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_PATCHES%%#$${patches}#g" \
		-e "s#%%MODULE_PREP_SOURCES%%#$${prepsources}#g" \
		-e "s#%%MODULE_PREP_PATCHES%%#$${preppatches}#g" \
		-e "s#%%MODULE_DEFINITIONS%%#$${definitions}#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_CC_OPT_NODEBUG%%#$(MODULE_CC_OPT_NODEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_FILES%%#$${files}#g" \
		-e "s#%%MODULE_POST%%#$${post}#g" \
		> $@.tmp && \
	cat $${changelog_file} | grep -v "^#" >> $@.tmp && \
	mv $@.tmp $@ ; \
	}

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
	for so in `find module-*/ -maxdepth 1 -type f -name "*module.so"`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove . ; \
	}

test-debug: base nginx-tests
	@echo "===> Running tests with debug binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module-debug.so"`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/module-perl/src/http/modules/perl:$$pwd/module-perl/src/http/modules/perl/blib/arch;" ; \
	fi ; \
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
	echo "Build environment has been created in: $(BUILD_ENV_PATH)" ; \
	echo ; \
	echo "Please do the following in order to get available build targets:" ; \
	echo "    cd $(BUILD_ENV_PATH)/SPECS" ; \
	echo "    make" ; \
	}

clean:
	@rm -f base module-*
	@rm -f nginx.spec nginx-module-*.spec
	@rm -rf nginx-tests
	@rm -f $(BASE_SRC)

.PHONY:	default all modules specs test test-debug clean

.SECONDARY:
