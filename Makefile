BRANCH=		$(shell hg branch)

ifeq (,$(findstring stable,$(BRANCH)))
FLAVOR=		mainline
else
FLAVOR=		stable
endif

CURRENT_VERSION_STRING=$(shell curl -fs https://version.nginx.com/nginx/$(FLAVOR))

CURRENT_VERSION=$(word 1,$(subst -, ,$(CURRENT_VERSION_STRING)))
CURRENT_RELEASE=$(word 2,$(subst -, ,$(CURRENT_VERSION_STRING)))

CURRENT_VERSION_STRING_NJS=$(shell curl -fs https://version.nginx.com/njs/$(FLAVOR))
CURRENT_VERSION_NJS=$(word 2,$(subst +, ,$(word 1,$(subst -, ,$(CURRENT_VERSION_STRING_NJS)))))
CURRENT_RELEASE_NJS=$(word 2,$(subst -, ,$(CURRENT_VERSION_STRING_NJS)))

VERSION?=	$(shell curl -fs https://hg.nginx.org/nginx/raw-file/$(BRANCH)/src/core/nginx.h | fgrep 'define NGINX_VERSION' | cut -d '"' -f 2)
RELEASE?=	1

VERSION_NJS?= $(shell curl -fs https://hg.nginx.org/njs/raw-file/default/src/njs.h | fgrep 'define NJS_VERSION' | cut -d '"' -f 2)
RELEASE_NJS?= 1

PACKAGER?=	$(shell hg config ui.username)

TARBALL?=	https://nginx.org/download/nginx-$(VERSION).tar.gz

TARBALL_NJS?=	https://hg.nginx.org/njs/archive/$(VERSION_NJS).tar.gz

BASE_MAKEFILES=	alpine/Makefile \
		debian/Makefile \
		rpm/SPECS/Makefile

MODULES=	geoip image-filter perl xslt
EXTERNAL_MODULES=	auth-spnego brotli encrypted-session fips-check geoip2 headers-more lua modsecurity ndk njs opentracing passenger rtmp set-misc subs-filter

ifeq ($(shell sha512sum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = sha512sum
else ifeq ($(shell shasum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = shasum -a 512
else ifeq ($(shell openssl version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = openssl dgst -r -sha512
else
SHA512SUM = $(error SHA-512 checksumming not found)
endif

default:
	@{ \
		echo "Latest available $(FLAVOR) nginx package version: $(CURRENT_VERSION)-$(CURRENT_RELEASE)" ; \
		echo "Next $(FLAVOR) release version: $(VERSION)-$(RELEASE)" ; \
		echo "Latest available $(FLAVOR) njs package version: $(CURRENT_VERSION_NJS)-$(CURRENT_RELEASE_NJS)" ; \
		echo "Next njs version: $(VERSION_NJS)" ; \
		echo ; \
		echo "Valid targets: release revert commit tag" ; \
	}

version-check:
	@{ \
		if [ "$(VERSION)-$(RELEASE)" = "$(CURRENT_VERSION)-$(CURRENT_RELEASE)" ]; then \
			echo "Version $(VERSION)-$(RELEASE) is the latest one, nothing to do." >&2 ; \
			exit 1 ; \
		fi ; \
	}

version-check-njs:
	@{ \
		if [ "$(VERSION_NJS)-$(RELEASE_NJS)" = "$(CURRENT_VERSION_NJS)-$(CURRENT_RELEASE_NJS)" ]; then \
			echo "Version $(VERSION_NJS)-$(RELEASE_NJS) is the latest one, nothing to do." >&2 ; \
			exit 1 ; \
		fi ; \
	}

nginx-$(VERSION).tar.gz:
	curl -o nginx-$(VERSION).tar.gz -fL $(TARBALL)

njs-$(VERSION_NJS).tar.gz:
	curl -o njs-$(VERSION_NJS).tar.gz -fL $(TARBALL_NJS)

release: version-check nginx-$(VERSION).tar.gz
	@{ \
		set -e ; \
		echo "==> Preparing $(FLAVOR) release $(VERSION)-$(RELEASE)" ; \
		$(SHA512SUM) nginx-$(VERSION).tar.gz >>contrib/src/nginx/SHA512SUMS ; \
		sed -e "s,^NGINX_VERSION :=.*,NGINX_VERSION := $(VERSION),g" -i contrib/src/nginx/version ; \
		for f in $(BASE_MAKEFILES); do \
			echo "--> $${f}" ; \
			sed -e "s,^BASE_RELEASE=.*,BASE_RELEASE=	$(RELEASE),g" \
				-i $${f} ; \
		done ; \
		reldate=`date +"%Y-%m-%d"` ; \
		reltime=`date +"%H:%M:%S %z"` ; \
		packager=`echo "$(PACKAGER)" | sed -e 's,<,\\\\\\&lt\;,' -e 's,>,\\\\\\&gt\;,'` ; \
		CHANGESADD="\n\n\n<changes apply=\"nginx\" ver=\"$(VERSION)\" rev=\"$(RELEASE)\"\n         date=\"$${reldate}\" time=\"$${reltime}\"\n         packager=\"$${packager}\">\n<change>\n<para>\n$(VERSION)-$(RELEASE)\n</para>\n</change>\n\n</changes>" ; \
		sed -i -e "s,title=\"nginx\">,title=\"nginx\">$${CHANGESADD}," docs/nginx.xml ; \
		for module in $(MODULES); do \
			echo "--> changelog for nginx-module-$${module}" ; \
			module_underscore=`echo $${module} | tr '-' '_'` ; \
			CHANGESADD="\n\n\n<changes apply=\"nginx-module-$${module}\" ver=\"$(VERSION)\" rev=\"$(RELEASE)\"\n         date=\"$${reldate}\" time=\"$${reltime}\"\n         packager=\"$${packager}\">\n<change>\n<para>\nbase version updated to $(VERSION)-$(RELEASE)\n</para>\n</change>\n\n</changes>" ; \
			sed -i -e "s,title=\"nginx_module_$${module_underscore}\">,title=\"nginx_module_$${module_underscore}\">$${CHANGESADD}," docs/nginx-module-$${module}.xml ; \
		done ; \
		for module in $(EXTERNAL_MODULES); do \
			echo "--> changelog for nginx-module-$${module}" ; \
			module_version=`fgrep apply docs/nginx-module-$${module}.xml | head -1 | cut -d '"' -f 4` ; \
			module_underscore=`echo $${module} | tr '-' '_'` ; \
			CHANGESADD="\n\n\n<changes apply=\"nginx-module-$${module}\" ver=\"$${module_version}\" rev=\"$(RELEASE)\" basever=\"$(VERSION)\"\n         date=\"$${reldate}\" time=\"$${reltime}\"\n         packager=\"$${packager}\">\n<change>\n<para>\nbase version updated to $(VERSION)-$(RELEASE)\n</para>\n</change>\n\n</changes>" ; \
			sed -i -e "s,title=\"nginx_module_$${module_underscore}\">,title=\"nginx_module_$${module_underscore}\">$${CHANGESADD}," docs/nginx-module-$${module}.xml ; \
		done ; \
		echo ; \
		echo "Done. Please carefully check the diff. Use \"make revert\" to revert any changes." ; \
		echo ; \
	}

release-njs: version-check-njs njs-$(VERSION_NJS).tar.gz
	@{ \
		set -e ; \
		echo "==> Preparing $(FLAVOR) njs release $(VERSION_NJS)-$(RELEASE_NJS)" ; \
		$(SHA512SUM) njs-$(VERSION_NJS).tar.gz > contrib/src/njs/SHA512SUMS ; \
		sed -e "s,^NJS_VERSION :=.*,NJS_VERSION := $(VERSION_NJS),g" -i contrib/src/njs/version ; \
		reldate=`date +"%Y-%m-%d"` ; \
		reltime=`date +"%H:%M:%S %z"` ; \
		packager=`echo "$(PACKAGER)" | sed -e 's,<,\\\\\\&lt\;,' -e 's,>,\\\\\\&gt\;,'` ; \
		echo "--> changelog for nginx-module-njs" ; \
		CHANGESADD="\n\n\n<changes apply=\"nginx-module-njs\" ver=\"$(VERSION_NJS)\" rev=\"$(RELEASE_NJS)\" basever=\"$(CURRENT_VERSION)\"\n         date=\"$${reldate}\" time=\"$${reltime}\"\n         packager=\"$${packager}\">\n<change>\n<para>\nnjs updated to $(VERSION_NJS)</para>\n</change>\n\n</changes>" ; \
		sed -i -e "s,title=\"nginx_module_njs\">,title=\"nginx_module_njs\">$${CHANGESADD}," docs/nginx-module-njs.xml ; \
		echo ; \
		echo "Done. Please carefully check the diff. Use \"make revert\" to revert any changes." ; \
		echo ; \
	}

revert:
	@hg revert -v contrib/src/nginx/ docs/ $(BASE_MAKEFILES) contrib/src/njs/

commit:
	@hg commit -vm 'Updated nginx to $(VERSION)'

tag:
	@hg tag -v $(VERSION)-$(RELEASE)

.PHONY: version-check release revert commit tag
