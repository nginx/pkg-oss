BRANCH=		$(shell hg branch)

ifeq (,$(findstring stable,$(BRANCH)))
FLAVOR=		mainline
else
FLAVOR=		stable
endif

CURRENT_VERSION_STRING=$(shell curl -fs https://version.nginx.com/nginx/$(FLAVOR))

CURRENT_VERSION=$(word 1,$(subst -, ,$(CURRENT_VERSION_STRING)))
CURRENT_RELEASE=$(word 2,$(subst -, ,$(CURRENT_VERSION_STRING)))

VERSION?=	$(shell curl -fs https://hg.nginx.org/nginx/raw-file/$(BRANCH)/src/core/nginx.h | fgrep 'define NGINX_VERSION' | cut -d '"' -f 2)
RELEASE?=	1

PACKAGER?=	$(shell hg config ui.username)

BASE_MAKEFILES=	alpine/Makefile \
		debian/Makefile \
		rpm/SPECS/Makefile

MODULES=	geoip image-filter perl xslt
EXTERNAL_MODULES=	njs

default:
	@{ \
		echo "Latest available $(FLAVOR) nginx package version: $(CURRENT_VERSION)-$(CURRENT_RELEASE)" ; \
		echo "Next $(FLAVOR) release version: $(VERSION)-$(RELEASE)" ; \
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

release: version-check
	@{ \
		echo "==> Preparing $(FLAVOR) release $(VERSION)-$(RELEASE)" ; \
		for f in $(BASE_MAKEFILES); do \
			echo "--> $${f}" ; \
			sed -e "s,^BASE_VERSION=.*,BASE_VERSION=	$(VERSION),g" \
				-e "s,^BASE_RELEASE=.*,BASE_RELEASE=	$(RELEASE),g" \
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

revert:
	@hg revert -v docs/ $(BASE_MAKEFILES)

commit:
	@hg commit -vm 'Updated nginx to $(VERSION)'

tag:
	@hg tag -v $(VERSION)-$(RELEASE)

.PHONY: version-check release revert commit tag
