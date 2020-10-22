#!/usr/bin/make

DEST?=	tmp
VERSIONMASK?=	0
XSLS?=	xslscript.pl

PACKAGES=	nginx							\
		nginx-module-geoip					\
		nginx-module-image-filter				\
		nginx-module-njs					\
		nginx-module-perl					\
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
