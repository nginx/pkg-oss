# nginx-quic

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
NGINX_QUIC_URL := https://hg.nginx.org/nginx-quic/

PKGS += nginx-quic

$(TARBALLS)/nginx-quic-$(NGINX_VERSION).tar.gz:
	-test -d nginx-quic && rm -rf nginx-quic
	hg clone -r ${NGINX_QUIC_SOURCETAG} ${NGINX_QUIC_URL} nginx-quic
	cd nginx-quic && hg archive -t tar -p nginx-quic-$(NGINX_VERSION) - | gzip > $@
	rm -rf nginx-quic

.sum-nginx-quic: nginx-quic-$(NGINX_VERSION).tar.gz
	#pass
	touch $@

nginx-quic: nginx-quic-$(NGINX_VERSION).tar.gz .sum-nginx-quic
	$(UNPACK)
	$(MOVE)

.nginx-quic: nginx-quic
	cd $< && ./auto/configure \
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
		--with-stream_ssl_preread_module \
		--with-http_v3_module \
		--with-stream_quic_module
	cd $< && $(MAKE) $(_SMP_MFLAGS) install
	touch $@
