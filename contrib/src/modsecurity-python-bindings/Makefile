# modsecurity-python-bindings

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version

MODSECURITY_PYTHON_BINDINGS_URL:= $(GITHUB)/SpiderLabs/ModSecurity-Python-bindings.git

PKGS += modsecurity-python-bindings

$(TARBALLS)/modsecurity-python-bindings-$(MODSECURITY_PYTHON_BINDINGS_GITHASH).tar.xz:
	$(call download_git,$(MODSECURITY_PYTHON_BINDINGS_URL),,$(MODSECURITY_PYTHON_BINDINGS_GITHASH))

.sum-modsecurity-python-bindings: modsecurity-python-bindings-$(MODSECURITY_PYTHON_BINDINGS_GITHASH).tar.xz
	$(call check_githash,$(MODSECURITY_PYTHON_BINDINGS_GITHASH))
	touch $@

modsecurity-python-bindings: modsecurity-python-bindings-$(MODSECURITY_PYTHON_BINDINGS_GITHASH).tar.xz .sum-modsecurity-python-bindings
	$(UNPACK)
	$(MOVE)

.modsecurity-python-bindings: modsecurity-python-bindings
	touch $@
