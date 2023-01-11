#!/usr/bin/make

DEST?=	tmp
VERSIONMASK?=	0
CONTRIB?=	../contrib
CONTRIB:=	$(abspath $(CONTRIB))
XSLS?=	$(CONTRIB)/xslscript/xslscript.pl

PACKAGES=	nginx-quic							\
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

$(XSLS):
	cd $(CONTRIB) && make .xslscript

$(DEST)/CHANGES:		changes.dtd				\
				nginx.xml				\
				change_log_conf.xml			\
				changes.xslt

	mkdir -p $(DEST)

	xmllint --noout --valid nginx-quic.xml
	xsltproc --stringparam format generic				\
		-o $@ changes.xslt nginx-quic.xml

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

changes.xslt:	changes.xsls $(XSLS)
	$(XSLS) -o $@ $<

clean:
	rm -rf $(DEST)
