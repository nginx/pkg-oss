# nginx-tests

NGINX_TESTS_URL := http://hg.nginx.org/nginx-tests

PKGS += nginx-tests

$(TARBALLS)/nginx-tests:
	hg clone $(NGINX_TESTS_URL) $@

.sum-nginx-tests: nginx-tests ;

clean: clean-nginx-tests

clean-nginx-tests:
	$(RM) -R $(TARBALLS)/nginx-tests
