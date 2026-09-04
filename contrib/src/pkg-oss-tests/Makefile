# pkg-oss-tests

PKG_OSS_TESTS_URL := https://github.com/thresheek/pkg-oss-tests

PKGS += pkg-oss-tests

$(TARBALLS)/pkg-oss-tests:
	git clone $(PKG_OSS_TESTS_URL) $@

.sum-pkg-oss-tests: pkg-oss-tests ;

clean: clean-pkg-oss-tests

clean-pkg-oss-tests:
	$(RM) -R $(TARBALLS)/pkg-oss-tests
