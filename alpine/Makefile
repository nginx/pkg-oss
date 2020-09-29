SHELL=		/bin/bash

BASE_VERSION=	1.18.0
BASE_RELEASE=	1
PLUS_VERSION=	21
PLUS_RELEASE=	${BASE_RELEASE}
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCDIR=		nginx-$(BASE_VERSION)
MODULE_SRCDIR=	$(SRCDIR)
SRCPATH?=	../..
MODSRC_PREFIX=	../

ARCH=		$(shell uname -m)

default:
	@echo "valid targets: all base $(addprefix module-, $(MODULES)) test test-debug"

MODULES=	geoip image-filter njs perl xslt

MODULE_SUMMARY_geoip=		GeoIP dynamic modules
MODULE_SUMMARY_image_filter=	image filter dynamic module
MODULE_SUMMARY_njs=		njs dynamic modules
MODULE_SUMMARY_perl=		Perl dynamic module
MODULE_SUMMARY_xslt=		xslt dynamic module

MODULE_VERSION_geoip=		$(BASE_VERSION)
MODULE_RELEASE_geoip=		1
MODULE_VERSION_image_filter=	$(BASE_VERSION)
MODULE_RELEASE_image_filter=	1
MODULE_VERSION_njs=		0.4.4
MODULE_RELEASE_njs=		1
MODULE_VERSION_perl=		$(BASE_VERSION)
MODULE_RELEASE_perl=		1
MODULE_VERSION_xslt=		$(BASE_VERSION)
MODULE_RELEASE_xslt=		1

MODULE_SOURCES_njs=		njs-$(MODULE_VERSION_njs).tar.gz
MODULE_CONFARGS_geoip=		--with-stream \
				--with-http_geoip_module=dynamic \
				--with-stream_geoip_module=dynamic
MODULE_CONFARGS_image_filter=	--with-http_image_filter_module=dynamic
MODULE_CONFARGS_njs=		--with-stream \
				--add-dynamic-module=$(MODSRC_PREFIX)njs-$(MODULE_VERSION_njs)/nginx
MODULE_CONFARGS_perl=		--with-http_perl_module=dynamic
MODULE_CONFARGS_xslt=		--with-http_xslt_module=dynamic

# geoip

MODULE_BUILD_DEPENDS_geoip=geoip-dev
MODULE_DEPENDS_geoip=geoip

define MODULE_ADD_CONTROL_TAGS_geoip
replaces="nginx-mod-http-geoip"
endef
export MODULE_ADD_CONTROL_TAGS_geoip

define MODULE_POST_geoip
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_geoip) for NGINX have been installed.
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

MODULE_DEPENDS_image_filter=libgd
MODULE_BUILD_DEPENDS_image_filter=gd-dev

define MODULE_ADD_CONTROL_TAGS_image_filter
replaces="nginx-mod-http-image-filter"
endef
export MODULE_ADD_CONTROL_TAGS_image_filter

define MODULE_POST_image_filter
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_image_filter) for NGINX has been installed.
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
MODULE_BUILD_DEPENDS_njs=libedit-dev

define MODULE_ADD_CONTROL_TAGS_njs
replaces="nginx-mod-http-js"
endef
export MODULE_ADD_CONTROL_TAGS_njs

define MODULE_PREBUILD_njs
	cd ../njs-$(MODULE_VERSION_njs) \&\& ./configure \&\& make njs
endef
export MODULE_PREBUILD_njs

define MODULE_PREINSTALL_njs
	mkdir -p "$$pkgdir"/usr/share/doc/nginx-module-njs
	install -m644 ../njs-$(MODULE_VERSION_njs)/CHANGES "$$pkgdir"/usr/share/doc/nginx-module-njs/
	mkdir -p "$$pkgdir"/usr/bin
	install -m755 -s ../njs-$(MODULE_VERSION_njs)/build/njs "$$pkgdir"/usr/bin/
endef
export MODULE_PREINSTALL_njs

define MODULE_POST_njs
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_njs) for NGINX have been installed.
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

MODULE_BUILD_DEPENDS_perl=perl-dev findutils

define MODULE_ADD_CONTROL_TAGS_perl
replaces="nginx-mod-http-perl"
endef
export MODULE_ADD_CONTROL_TAGS_perl

define MODULE_PREINSTALL_perl
	make DESTDIR=$$pkgdir INSTALLDIRS=vendor -f objs/Makefile install_perl_modules
	find $$pkgdir/ -type f -name .packlist -exec rm -f '{}' \\;
	find $$pkgdir/ -type f -name perllocal.pod -exec rm -f '{}' \\;
	find $$pkgdir/ -type f -empty -exec rm -f '{}' \\;
	find $$pkgdir/ -type f -iname '*.so' -exec chmod 0755 '{}' \\;
endef
export MODULE_PREINSTALL_perl

define MODULE_POST_perl
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_perl) for NGINX has been installed.
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

MODULE_DEPENDS_xslt=libxslt
MODULE_BUILD_DEPENDS_xslt=libxslt-dev

define MODULE_ADD_CONTROL_TAGS_xslt
replaces="nginx-mod-http-xslt-filter"
endef
export MODULE_ADD_CONTROL_TAGS_xslt

define MODULE_POST_xslt
cat <<BANNER
----------------------------------------------------------------------

The $(MODULE_SUMMARY_xslt) for NGINX has been installed.
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
	--with-perl_modules_path=/usr/lib/perl5/vendor_perl \
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

BASE_MODULE_CONFIGURE_ARGS=\
	--with-compat

export CR=\\n

modname = $(shell echo $1 | cut -d '-' -f 3- | tr '-' '_')

${HOME}/.abuild:
	mkdir -p ${HOME}/.abuild

${HOME}/.abuild/abuild-key.rsa: | ${HOME}/.abuild
	cd ${HOME}/.abuild && umask 0007 && openssl genrsa -out abuild-key.rsa 2048
	openssl rsa -in ${HOME}/.abuild/abuild-key.rsa -pubout -out ${HOME}/.abuild/abuild-key.rsa.pub

${HOME}/.abuild/abuild.conf: ${HOME}/.abuild/abuild-key.rsa | ${HOME}/.abuild
	echo PACKAGER_PRIVKEY=\"${HOME}/.abuild/abuild-key.rsa\" > ${HOME}/.abuild/abuild.conf

all:	base modules
	@echo "===> all done"

modules:	base $(addprefix module-, $(MODULES))

abuild:	abuild-base $(addprefix abuild-module-, $(MODULES))

base:	${HOME}/.abuild/abuild.conf abuild-base
	@echo "===> Building base package" ; \
	/usr/bin/time -p $(SHELL) -c "cd abuild-base/ && abuild checksum && abuild unpack && abuild prepare && abuild -K build && abuild rootpkg" && \
	ln -s abuild-base/pkg/nginx/usr/sbin base

$(BASE_SRC):
	wget http://nginx.org/download/$(BASE_SRC)

abuild-base: $(BASE_SRC)
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	mkdir -p abuild-base ; \
	cp $(BASE_SRC) abuild-base/ ; \
	cp nginx.* default.conf COPYRIGHT abuild-base/ ; \
	cat nginx.initd.in | sed -e 's#%%DAEMON%%#nginx#g' > abuild-base/nginx.initd ; \
	cat nginx.initd.in | sed -e 's#%%DAEMON%%#nginx-debug#g' > abuild-base/nginx-debug.initd ; \
	cat APKBUILD-base.in | sed \
		-e 's#%%MAIN_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%MAIN_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> abuild-base/APKBUILD ; \
	}

module-%: ${HOME}/.abuild/abuild.conf abuild-module-%
	@echo "===> Building nginx-$@ package" ; \
	/usr/bin/time -p $(SHELL) -c "cd abuild-$@/ && abuild checksum && abuild unpack && abuild prepare && abuild -K build && abuild rootpkg" && \
	ln -s abuild-$@/pkg/nginx-module-$*/usr/lib/nginx/modules $@

abuild-module-%: $(BASE_SRC)
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	curdir=`pwd` ; \
	module_asis=`echo $@ | cut -d '-' -f 3-` ; \
	builddir=`echo abuild-module-$${module_asis}` ; \
	mkdir -p $${builddir} ; \
	cp $(BASE_SRC) $${builddir}/nginx-module-$${module_asis}-$(BASE_VERSION).tar.gz ; \
	sources= ; \
	for src in $(MODULE_SOURCES_$(call modname, $@)); do \
		cp src/$${src} $${builddir}/ ; \
		sources="$${sources} $${src}" ; \
	done ; \
	for p in $(MODULE_PATCHES_$(call modname, $@)); do \
		cp src/$${p} $${builddir}/ ; \
		sources="$${sources} $${p}" ; \
	done ; \
	cp COPYRIGHT $${builddir}/ ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	addcontroltags=`echo "$$MODULE_ADD_CONTROL_TAGS_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	cat APKBUILD-module.in | sed \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%SUMMARY%%#nginx $(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%SHORT_SUMMARY%%#$(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%MAIN_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%MAIN_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $@))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $@))#g" \
		-e "s#%%MODULE_VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $@))#g" \
		-e 's#%%BASE_MODULE_CONFIGURE_ARGS%%#$(BASE_MODULE_CONFIGURE_ARGS)#g' \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $@))#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_BUILD_DEPENDS%%#$(MODULE_BUILD_DEPENDS_$(call modname, $@))#g" \
		-e "s#%%MODULE_DEPENDS%%#$(MODULE_DEPENDS_$(call modname, $@))#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_CC_OPT_NODEBUG%%#$(MODULE_CC_OPT_NODEBUG_$(call modname, $@))#g" \
		-e "s#%%ADD_CONTROL_TAGS%%#$${addcontroltags}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_SRCDIR%%#$(MODULE_SRCDIR)#g" \
	> $${builddir}/APKBUILD ; \
	cat nginx-module.post-install.in | sed \
		-e "s#%%MODULE_POST%%#$$post#g" \
	> $${builddir}/nginx-module-$${module_asis}.post-install ; \
	}

nginx-tests:
	@{ \
	if [ -d "$(SRCPATH)/nginx-tests" ]; then \
		echo "===> Copying tests from $(SRCPATH)/nginx-tests" ; \
		cp -rP $(SRCPATH)/nginx-tests nginx-tests ; \
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
	if [ -d $$pwd/abuild-module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl:$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

test-debug: base nginx-tests
	@echo "===> Running tests with debug binary/modules"
	@{ \
	pwd=`pwd` ; \
	globals= ; \
	for so in `find module-*/ -maxdepth 1 -type f -name "*module-debug.so" | sort -t / -k 2`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ -d $$pwd/abuild-module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl:$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx-debug TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

clean:
	@rm -rf base abuild-base abuild-module-* module-* $(BASE_SRC) nginx-tests

.PHONY:	default all modules abuild test test-debug clean

.SECONDARY:
