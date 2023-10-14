# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Directories
OPENROAD_DIR    := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
IG_ROOT		    ?= $(realpath $(OPENROAD_DIR)/../../..)
TECH_ROOT		?= $(IG_ROOT)/target/ihp13/pdk/ihp-sg13g2/
SAVE			:= $(OPENROAD_DIR)/save
REPORTS			:= $(OPENROAD_DIR)/reports

ig-setup-openroad:
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/reports
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/save

ig-openroad: ig-setup-openroad
	TECH_ROOT="$(TECH_ROOT)" \
	cd $(OPENROAD_DIR) && \
	$(OPENROAD) scripts/chip.tcl -gui \
		2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }' \
		| tee "$(OPENROAD_DIR)/openroad_$(shell date +"%Y-%m-%d_%H_%M_%Z").log";
PHONY: ig-openroad