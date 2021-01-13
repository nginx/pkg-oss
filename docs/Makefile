#!/usr/bin/make

DEST?=	tmp
VERSIONMASK?=	0
XSLS?=	xslscript.pl

PACKAGES=	nginx							\
		nginx-module-auth-spnego				\
		nginx-module-brotli					\
		nginx-module-encrypted-session				\
		nginx-module-geoip					\
		nginx-module-geoip2					\
		nginx-module-headers-more				\
		nginx-module-image-filter				\
		nginx-module-lua					\
		nginx-module-modsecurity				\
		nginx-module-ndk					\
		nginx-module-njs					\
		nginx-module-opentracing				\
		nginx-module-passenger					\
		nginx-module-perl					\
		nginx-module-rtmp					\
		nginx-module-set-misc					\
		nginx-module-subs-filter				\
		nginx-module-xslt

all:		changes changelogs

changes:	$(DEST)/CHANGES

changelogs:	$(addsuffix .rpm-changelog, $(addprefix $(DEST)/, $(PACKAGES))) \
		$(addsuffix .deb-changelog, $(addprefix $(DEST)/, $(PACKAGES)))

$(DEST)/CHANGES:		changes.dtd				\
				nginx.xml				\
				change_log_conf.xml			\
				changes.xslt

	mkdir -p $(DEST)

	xmllint --noout --valid nginx.xml
	xsltproc --stringparam format generic				\
		-o $@ changes.xslt nginx.xml

$(DEST)/%.rpm-changelog:	changes.dtd 				\
				%.xml 				\
				change_log_conf.xml 			\
				changes.xslt
	mkdir -p $(DEST)
	xmllint --noout --valid $*.xml
	xsltproc --stringparam pkgname $* --stringparam format rpm	\
		--stringparam versionmask $(VERSIONMASK)		\
		-o $@ changes.xslt $*.xml

$(DEST)/%.deb-changelog:	changes.dtd 				\
				%.xml 				\
				change_log_conf.xml 			\
				changes.xslt
	mkdir -p $(DEST)
	xmllint --noout --valid $*.xml
	xsltproc --stringparam pkgname $* --stringparam format deb	\
		--stringparam versionmask $(VERSIONMASK)		\
		-o $@ changes.xslt $*.xml

changes.xslt:	changes.xsls
	$(XSLS) -o $@ $<

clean:
	rm -rf $(DEST)
