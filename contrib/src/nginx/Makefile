# nginx

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_URL := $(NGINX)/nginx-$(NGINX_VERSION).tar.gz

PKGS += nginx

$(TARBALLS)/nginx-$(NGINX_VERSION).tar.gz:
	$(call download_pkg,$(NGINX_URL),nginx)

.sum-nginx: nginx-$(NGINX_VERSION).tar.gz

nginx: nginx-$(NGINX_VERSION).tar.gz .sum-nginx
	$(UNPACK)
	$(MOVE)

.nginx: nginx
	cd $< && ./configure \
		--prefix=$(PREFIX) \
		--with-compat \
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
	cd $< && $(MAKE) $(_SMP_MFLAGS) install
	touch $@
