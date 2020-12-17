SHELL=		/bin/sh

BASE_VERSION=	1.19.5
BASE_RELEASE=	1
PLUS_VERSION=	23
PLUS_RELEASE=	${BASE_RELEASE}
BASE_SRC=	nginx-$(BASE_VERSION).tar.gz
SRCDIR=		nginx-$(BASE_VERSION)
MODULE_SRCDIR=	$(SRCDIR)
DOCS?=		../docs
SRCPATH?=	../..
MODSRC_PREFIX=	../

MODULE_TARGET?= oss

ifeq ($(MODULE_TARGET), plus)
APKBUILD_TEMPLATE=	APKBUILD-plus-module.in
TARGET_SUFFIX=  -plus
MODULE_SUMMARY_PREFIX=NGINX Plus
TARGET_VERSION=$(PLUS_VERSION)
MODULE_PACKAGE_PREFIX=nginx-plus-module
else
APKBUILD_TEMPLATE=	APKBUILD-module.in
MODULE_SUMMARY_PREFIX=nginx
TARGET_VERSION=$(BASE_VERSION)
MODULE_PACKAGE_PREFIX=nginx-module
endif

MODULE_TARGET_PREFIX=$(TARGET_VERSION).

ARCH=		$(shell uname -m)

default:
	@echo "valid targets: all base $(addprefix module-, $(MODULES)) test test-debug"

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
	ln -s abuild-base/pkg/nginx/usr/sbin base && \
	touch base

$(BASE_SRC):
	wget http://nginx.org/download/$(BASE_SRC)

abuild-base: $(BASE_SRC)
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	mkdir -p abuild-base ; \
	cp $(BASE_SRC) abuild-base/ ; \
	cp nginx.* default.conf abuild-base/ ; \
	cp $(DOCS)/nginx.copyright abuild-base/COPYRIGHT ; \
	cat nginx.initd.in | sed -e 's#%%DAEMON%%#nginx#g' > abuild-base/nginx.initd ; \
	cat nginx.initd.in | sed -e 's#%%DAEMON%%#nginx-debug#g' > abuild-base/nginx-debug.initd ; \
	cat APKBUILD-base.in | sed \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> abuild-base/APKBUILD ; \
	}

module-%: ${HOME}/.abuild/abuild.conf abuild-module-%
	@echo "===> Building nginx-$@ package" ; \
	/usr/bin/time -p $(SHELL) -c "cd abuild-$@/ && abuild checksum && abuild unpack && abuild prepare && abuild -K build && abuild rootpkg" && \
	ln -s abuild-$@/pkg/$(MODULE_PACKAGE_PREFIX)-$*/usr/lib/nginx/modules $@ && \
	touch $@

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
	module_copyright="nginx-module-$${module_asis}.copyright" ; \
	cp -p $(DOCS)/$${module_copyright} $${builddir}/COPYRIGHT ; \
	if [ "$(MODULE_TARGET)" = "oss" ]; then \
		postinstall_script=$${builddir}/nginx-module-$${module_asis}.post-install ; \
	else \
		postinstall_script=$${builddir}/nginx-plus-module-$${module_asis}.post-install ; \
	fi ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	addcontroltags=`echo "$$MODULE_ADD_CONTROL_TAGS_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $@)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	cat $(APKBUILD_TEMPLATE) | sed \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%SUMMARY%%#nginx $(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%SHORT_SUMMARY%%#$(MODULE_SUMMARY_$(call modname, $@))#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $@))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $@))#g" \
		-e "s#%%MODULE_VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $@))#g" \
		-e 's#%%BASE_MODULE_CONFIGURE_ARGS%%#$(BASE_MODULE_CONFIGURE_ARGS)#g' \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $@))#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_BUILD_DEPENDS%%#$(MODULE_BUILD_DEPENDS_$(call modname, $@))#g" \
		-e "s#%%MODULE_DEPENDS%%#$(MODULE_DEPENDS_$(call modname, $@))#g" \
		-e "s#%%MODULE_PROVIDES%%#$(MODULE_PROVIDES_$(call modname, $@))#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_CC_OPT%%#$(MODULE_CC_OPT_$(call modname, $@))#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%MODULE_LD_OPT%%#$(MODULE_LD_OPT_$(call modname, $@))#g" \
		-e "s#%%MODULE_LD_OPT_DEBUG%%#$(MODULE_LD_OPT_DEBUG_$(call modname, $@))#g" \
		-e "s#%%ADD_CONTROL_TAGS%%#$${addcontroltags}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_SRCDIR%%#$(MODULE_SRCDIR)#g" \
	> $${builddir}/APKBUILD ; \
	cat nginx-module.post-install.in | sed \
		-e "s#%%MODULE_POST%%#$$post#g" \
	> $${postinstall_script} ; \
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
	if [ -d $$pwd/abuild-module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/abuild-module-modsecurity/src/modsecurity-v$(LIBMODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/abuild-module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/abuild-module-opentracing/src/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
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
	if [ -d $$pwd/abuild-module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/abuild-module-modsecurity/src/modsecurity-v$(LIBMODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/abuild-module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/abuild-module-opentracing/src/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	cd nginx-tests && TEST_NGINX_BINARY=$$pwd/base/nginx-debug TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

clean:
	@rm -rf base abuild-base abuild-module-* module-* $(BASE_SRC) nginx-tests

.PHONY:	default all modules abuild test test-debug clean

.SECONDARY:
