# secrules-language-tests 

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version

SECRULES_LANGUAGE_TESTS_URL:= $(GITHUB)/SpiderLabs/secrules-language-tests.git

PKGS += secrules-language-tests

$(TARBALLS)/secrules-language-tests-$(SECRULES_LANGUAGE_TESTS_GITHASH).tar.xz:
	$(call download_git,$(SECRULES_LANGUAGE_TESTS_URL),,$(SECRULES_LANGUAGE_TESTS_GITHASH))

.sum-secrules-language-tests: secrules-language-tests-$(SECRULES_LANGUAGE_TESTS_GITHASH).tar.xz
	$(call check_githash,$(SECRULES_LANGUAGE_TESTS_GITHASH))
	touch $@

secrules-language-tests: secrules-language-tests-$(SECRULES_LANGUAGE_TESTS_GITHASH).tar.xz .sum-secrules-language-tests
	$(UNPACK)
	$(MOVE)

.secrules-language-tests: secrules-language-tests
	touch $@
