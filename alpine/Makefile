SHELL=		/bin/sh

CONTRIB?=	../contrib
CONTRIB:=	$(abspath $(CONTRIB))
DOCS?=		../docs

BASE_TARGET?=	oss
MODULE_TARGET?=	oss

ifeq ($(BASE_TARGET), plus)
BASE_SUFFIX=-plus
endif

include $(CONTRIB)/src/nginx$(BASE_SUFFIX)/version

BASE_VERSION=	$(NGINX_VERSION)
BASE_RELEASE=	1
PLUS_VERSION=	$(NGINX_PLUS_VERSION)
PLUS_RELEASE=	1
BASE_SRC=	nginx$(BASE_SUFFIX)-$(BASE_VERSION).tar.gz
SRCDIR=	nginx$(BASE_SUFFIX)-$(BASE_VERSION)
MODULE_SRCDIR=	$(SRCDIR)
SRCPATH?=	../..
MODSRC_PREFIX=	../

ifeq ($(MODULE_TARGET), plus)
APKBUILD_TEMPLATE=	APKBUILD-plus-module.in
MODULE_SUFFIX=	-plus
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

ifeq ($(BASE_TARGET), plus)
BASE_CONFIGURE_ARGS+=\
	--build=nginx-plus-r$(PLUS_VERSION) \
	--with-http_auth_jwt_module \
	--with-http_f4f_module \
	--with-http_hls_module \
	--with-http_session_log_module
endif

export CR=\\n

modname = $(shell echo $1 | tr '-' '_')

${HOME}/.abuild:
	mkdir -p ${HOME}/.abuild

${HOME}/.abuild/abuild-key.rsa: | ${HOME}/.abuild
	cd ${HOME}/.abuild && umask 0007 && openssl genrsa -out abuild-key.rsa 2048
	openssl rsa -in ${HOME}/.abuild/abuild-key.rsa -pubout -out ${HOME}/.abuild/abuild-key.rsa.pub

${HOME}/.abuild/abuild.conf: ${HOME}/.abuild/abuild-key.rsa | ${HOME}/.abuild
	echo PACKAGER_PRIVKEY=\"${HOME}/.abuild/abuild-key.rsa\" > ${HOME}/.abuild/abuild.conf

list-base:
	@printf "%-20s\t%s\n" nginx $(BASE_VERSION)-$(BASE_RELEASE)

list-module-%:
	@printf "%-20s\t%s\n" $* $(MODULE_VERSION_$(call modname, $*))-$(MODULE_RELEASE_$(call modname, $*))

list-all-modules: $(addprefix list-module-, $(MODULES))

list-base-modules: $(addprefix list-module-, $(BASE_MODULES))

list: list-base list-all-modules

all:	base base-modules
	@echo "===> all done"

base-modules:	base $(addprefix module-, $(BASE_MODULES))

modules:	base $(addprefix module-, $(MODULES))

abuild:	abuild-base $(addprefix abuild-module-, $(MODULES))

base:	${HOME}/.abuild/abuild.conf | abuild-base
	@echo "===> Building base package" ; \
	/usr/bin/time -p $(SHELL) -c "cd abuild-base/ && abuild checksum && abuild unpack && abuild prepare && abuild -K build && abuild rootpkg" && \
	ln -s abuild-base/pkg/nginx$(BASE_SUFFIX)/usr/sbin base && \
	touch base

$(BASE_SRC):
	cd $(CONTRIB) && make .sum-nginx$(BASE_SUFFIX)
	ln -s $(CONTRIB)/tarballs/$(BASE_SRC) $(BASE_SRC)

abuild-base: $(BASE_SRC)
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	mkdir -p abuild-base ; \
	cp $(BASE_SRC) abuild-base/ ; \
	cp nginx$(BASE_SUFFIX).* abuild-base/ ; \
	patches=`find $(CONTRIB)/src/nginx$(BASE_SUFFIX)/ \
		-type f -name '*.patch' -printf  "%f\n" | sort |tr "\\n" " "` ; \
	for patch in $$patches; do \
		cp -v $(CONTRIB)/src/nginx$(BASE_SUFFIX)/$$patch abuild-base/ ; \
	done ;\
	cp $(DOCS)/nginx.copyright abuild-base/COPYRIGHT ; \
	if [ "$(BASE_TARGET)" = "plus" ]; then \
		cp -v $(DOCS)/EULA-* $(CONTRIB)/tarballs/dashboard.html $(DOCS)/nginx-modules-reference.pdf abuild-base/ ; \
		cp -vr $(DOCS)/swagger-ui abuild-base/; \
	fi; \
	cat nginx$(BASE_SUFFIX).initd.in | sed -e 's#%%DAEMON%%#nginx#g' > abuild-base/nginx$(BASE_SUFFIX).initd ; \
	cat nginx$(BASE_SUFFIX).initd.in | sed -e 's#%%DAEMON%%#nginx-debug#g' > abuild-base/nginx$(BASE_SUFFIX)-debug.initd ; \
	cat APKBUILD-base$(BASE_SUFFIX).in | sed \
		-e 's#%%BASE_VERSION%%#$(BASE_VERSION)#g' \
		-e 's#%%BASE_RELEASE%%#$(BASE_RELEASE)#g' \
		-e 's#%%PLUS_VERSION%%#$(PLUS_VERSION)#g' \
		-e 's#%%PLUS_RELEASE%%#$(PLUS_RELEASE)#g' \
		-e "s#%%BASE_PATCHES%%#$$patches#g" \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		> abuild-base/APKBUILD ; \
	}

module-%: ${HOME}/.abuild/abuild.conf | abuild-module-%
	@echo "===> Building nginx$(MODULE_SUFFIX)-$@ package"
	@/usr/bin/time -p $(SHELL) -c "cd abuild-$@/ && abuild checksum && abuild unpack && abuild prepare && abuild -K build && abuild rootpkg" && \
	ln -s abuild-$@/pkg/$(MODULE_PACKAGE_PREFIX)-$*/usr/lib/nginx/modules $@

abuild-module-%: $(BASE_SRC) .deps-module-%
	@echo "===> Creating $@"
	@{ \
	set -e ; \
	curdir=`pwd` ; \
	module_asis=`echo $@ | cut -d '-' -f 3-` ; \
	builddir=`echo abuild-module-$${module_asis}` ; \
	mkdir -p $${builddir} ; \
	cp $(BASE_SRC) $${builddir}/nginx-module-$${module_asis}-$(BASE_VERSION).tar.gz ; \
	sources= ; \
	for src in $(MODULE_SOURCES_$(call modname, $*)); do \
		cp $(CONTRIB)/tarballs/$${src} $${builddir}/ ; \
		sources="$${sources} $${src}" ; \
	done ; \
	for p in $(MODULE_PATCHES_$(call modname, $*)); do \
		dn=`dirname $${p}` ; \
		bdn=`basename $${dn}` ; \
		pn="$${bdn}~`basename $${p}`" ; \
		cp $${p} $${builddir}/$${pn} ; \
		sources="$${sources} $${pn}" ; \
	done ; \
	module_copyright="nginx-module-$${module_asis}.copyright" ; \
	cp -p $(DOCS)/$${module_copyright} $${builddir}/COPYRIGHT ; \
	postinstall_script=$${builddir}/nginx$(MODULE_SUFFIX)-module-$${module_asis}.post-install ; \
	definitions=`echo "$$MODULE_DEFINITIONS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	addcontroltags=`echo "$$MODULE_ADD_CONTROL_TAGS_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	prebuild=`echo "$$MODULE_PREBUILD_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	buildenv=`echo "$$MODULE_ENV_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	preinstall=`echo "$$MODULE_PREINSTALL_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	post=`echo "$$MODULE_POST_$(call modname, $*)" | sed -e ':a' -e 'N' -e '$$!ba' -e "s/\n/\$$CR/g"` ; \
	cat $(APKBUILD_TEMPLATE) | sed \
		-e "s#%%MODULE%%#$${module_asis}#g" \
		-e "s#%%SUMMARY%%#$(MODULE_SUMMARY_PREFIX) $(MODULE_SUMMARY_$(call modname, $*))#g" \
		-e "s#%%BASE_VERSION%%#$(BASE_VERSION)#g" \
		-e "s#%%BASE_RELEASE%%#$(BASE_RELEASE)#g" \
		-e 's#%%BASE_CONFIGURE_ARGS%%#$(BASE_CONFIGURE_ARGS)#g' \
		-e "s#%%PLUS_VERSION%%#$(PLUS_VERSION)#g" \
		-e "s#%%MODULE_VERSION%%#$(MODULE_VERSION_$(call modname, $*))#g" \
		-e "s#%%MODULE_RELEASE%%#$(MODULE_RELEASE_$(call modname, $*))#g" \
		-e "s#%%MODULE_VERSION_PREFIX%%#$(MODULE_VERSION_PREFIX_$(call modname, $*))#g" \
		-e "s#%%MODULE_CONFIGURE_ARGS%%#$(MODULE_CONFARGS_$(call modname, $*))#g" \
		-e "s#%%MODULE_SOURCES%%#$${sources}#g" \
		-e "s#%%MODULE_BUILD_DEPENDS%%#$(MODULE_BUILD_DEPENDS_$(call modname, $*))#g" \
		-e "s#%%MODULE_DEPENDS%%#$(MODULE_DEPENDS_$(call modname, $*))#g" \
		-e "s#%%MODULE_PROVIDES%%#$(MODULE_PROVIDES_$(call modname, $*))#g" \
		-e "s#%%MODULE_PREBUILD%%#$${prebuild}#g" \
		-e "s#%%MODULE_PREINSTALL%%#$${preinstall}#g" \
		-e "s#%%MODULE_CC_OPT%%#$(MODULE_CC_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_CC_OPT_DEBUG%%#$(MODULE_CC_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT%%#$(MODULE_LD_OPT_$(call modname, $*))#g" \
		-e "s#%%MODULE_LD_OPT_DEBUG%%#$(MODULE_LD_OPT_DEBUG_$(call modname, $*))#g" \
		-e "s#%%ADD_CONTROL_TAGS%%#$${addcontroltags}#g" \
		-e "s#%%MODULE_ENV%%#$${buildenv}#g" \
		-e "s#%%MODULE_SRCDIR%%#$(MODULE_SRCDIR)#g" \
	> $${builddir}/APKBUILD ; \
	cat nginx-module.post-install.in | sed \
		-e "s#%%MODULE_POST%%#$$post#g" \
	> $${postinstall_script} ; \
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
	if [ -d $$pwd/module-perl ]; then \
		globals="$$globals env PERL5LIB=$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl:$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/abuild-module-modsecurity/src/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/abuild-module-opentracing/src/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-lua ]; then \
		globals_http="lua_package_path '$$pwd/abuild-module-lua/src/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/abuild-module-lua/src/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
		globals="$$globals env PERL5LIB=$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl:$$pwd/abuild-module-perl/src/$(MODULE_SRCDIR)/objs/src/http/modules/perl/blib/arch;" ; \
	fi ; \
	if [ -d $$pwd/module-modsecurity ]; then \
		export LD_LIBRARY_PATH=$$pwd/abuild-module-modsecurity/src/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-opentracing ]; then \
		export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$$pwd/abuild-module-opentracing/src/opentracing-cpp-$(OPENTRACING_CPP_VERSION)/usr/local/lib ; \
	fi ; \
	if [ -d $$pwd/module-lua -a ! -e nginx-module-lua.skip ]; then \
		globals_http="lua_package_path '$$pwd/abuild-module-lua/src/lua-resty-core-$(LUA_RESTY_CORE_VERSION)/lib/?.lua;$$pwd/abuild-module-lua/src/lua-resty-lrucache-$(LUA_RESTY_LRUCACHE_VERSION)/lib/?.lua;;';" ; \
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
		export LD_LIBRARY_PATH=$$pwd/abuild-module-modsecurity/src/modsecurity-v$(MODSECURITY_VERSION)/local/lib ; \
	fi ; \
	for so in `find module-$${module}/ -maxdepth 1 -type f -name "*module.so"`; do \
		globals="$$globals load_module $$pwd/$$so;" ; \
	done ; \
	if [ ! -d nginx-tests/module-$${module} ]; then \
		cp -r $${pwd}/abuild-module-$${module}/src/$${testdir} nginx-tests/module-$${module} ; \
		ln -fs ../lib nginx-tests/module-$${module}/lib ; \
	fi ; \
	cd nginx-tests/module-$${module} && TEST_NGINX_BINARY=$$pwd/base/nginx TEST_NGINX_GLOBALS="$$globals" prove $$PROVE_ARGS . ; \
	}

clean:
	@rm -rf base abuild-base abuild-module-* module-* $(BASE_SRC) nginx-tests .deps-module-*

.PHONY:	default all modules abuild test test-debug clean

.SECONDARY:
