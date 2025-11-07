toupper = $(shell echo $1 | tr '[:lower:]-' '[:upper:]_' )
dep_v = $(shell echo $(call toupper,$1)_VERSION )
dep_h = $(shell echo $(call toupper,$1)_GITHASH )
dep_checksum = $(shell test -f "$(CONTRIB)/src/$1/SHA512SUMS" && \
						awk '( index($$2,"$($(call dep_v,$1))") > 1 || index($$2,"$($(call dep_h,$1))") > 1 ) {print $$1}' "$(CONTRIB)/src/$1/SHA512SUMS" )
attest_version = $(shell test -n '$($(call dep_h,$1))' && echo $($(call dep_v,$1))-$($(call dep_h,$1)) || echo $($(call dep_v,$1)))

attest-module-%:
	@$(foreach dep,$(MODULE_CONTRIB_DEPS_$*),echo $(dep) $(call attest_version,$(dep)) $(call dep_checksum,$(dep)) >> attest-module-$* ;)

attest: attest-base $(addprefix attest-module-, $(MODULES))

attest-base:
	if [ "$(BASE_TARGET)" = "oss" ]; then \
	    checksum=$$(grep "$(BASE_VERSION)" "$(CONTRIB)/src/nginx/SHA512SUMS" | cut -d' ' -f1) ; \
	    printf "%s %s %s\n" "nginx" "$(BASE_VERSION)" "$$checksum" >> "$@"; \
	fi
