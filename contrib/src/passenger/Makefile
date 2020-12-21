# passenger

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
PASSENGER_URL := http://s3.amazonaws.com/phusion-passenger/releases/passenger-$(PASSENGER_VERSION).tar.gz

PKGS += passenger

$(TARBALLS)/passenger-$(PASSENGER_VERSION).tar.gz:
	$(call download_pkg,$(PASSENGER_URL),passenger)

.sum-passenger: passenger-$(PASSENGER_VERSION).tar.gz

passenger: passenger-$(PASSENGER_VERSION).tar.gz .sum-passenger
	$(UNPACK)
	$(APPLY) $(SRC)/passenger/build-nginx.rb.patch
	$(APPLY) $(SRC)/passenger/src-nginx_module-ContentHandler.c.patch
	$(MOVE)

.passenger: passenger
	touch $@
