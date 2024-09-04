# nginx-tests

NGINX_TESTS_URL := https://github.com/nginx/nginx-tests

PKGS += nginx-tests

$(TARBALLS)/nginx-tests:
	git clone $(NGINX_TESTS_URL) $@

.sum-nginx-tests: nginx-tests ;

clean: clean-nginx-tests

clean-nginx-tests:
	$(RM) -R $(TARBALLS)/nginx-tests
