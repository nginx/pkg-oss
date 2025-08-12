# nginx-acme
#
# https://github.com/nginx/nginx-acme/

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_ACME_URL := $(GITHUB)/nginx/nginx-acme/releases/download/v$(NGINX_ACME_VERSION)/nginx-acme-$(NGINX_ACME_VERSION).tar.gz

CARGO := $(shell command -v cargo 2> /dev/null)

ifdef CARGO
PKGS += nginx-acme
PKGS += vendor-nginx-acme
endif

DEPS_nginx-acme = vendor-nginx-acme $(DEPS_vendor-nginx-acme)

$(TARBALLS)/nginx-acme-$(NGINX_ACME_VERSION).tar.gz:
	$(call download_pkg,$(NGINX_ACME_URL),nginx-acme)

.sum-nginx-acme: nginx-acme-$(NGINX_ACME_VERSION).tar.gz

TAR_COMMAND = $(shell if tar --version 2>/dev/null | grep -q "GNU"; then \
    echo 'tar -zcf "../../$${name}.tar.gz" vendor --transform "s,vendor,$${name},"'; \
  else \
    echo 'tar -zcf "../../$${name}.tar.gz" -s ",^vendor,$${name}," vendor'; \
  fi)

cargo_vendor_archive = \
	TMP_DIR=.tmp-$$( basename $1) ; \
	rm -rf $${TMP_DIR} ; \
	mkdir $${TMP_DIR} ; \
	tar xf "$1" -C $${TMP_DIR} ; \
	cd $${TMP_DIR}/* ; \
	$(CARGO) vendor --locked --respect-source-config; \
	name=$$(basename `pwd`)-vendor ; \
	eval $(TAR_COMMAND) ; \
	cd ../.. ; \
	rm -rf $${TMP_DIR} ; \
	mv $${name}.tar.gz $(TARBALLS)/ ;

$(TARBALLS)/nginx-acme-$(NGINX_ACME_VERSION)-vendor.tar.gz: nginx-acme-$(NGINX_ACME_VERSION).tar.gz .sum-nginx-acme
	$(call cargo_vendor_archive,$<)

.sum-vendor-nginx-acme: nginx-acme-$(NGINX_ACME_VERSION)-vendor.tar.gz
	touch $@

.vendor-nginx-acme: .sum-vendor-nginx-acme
	touch $@

nginx-acme: nginx-acme-$(NGINX_ACME_VERSION).tar.gz .sum-nginx-acme
	$(UNPACK)
	$(MOVE)

.nginx-acme: nginx-acme
	touch $@
