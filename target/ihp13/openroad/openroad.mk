# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

TECH_ROOT		?= $(IG_ROOT)/target/ihp13/pdk/ihp-sg13g2/

ig-setup-openroad:
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/reports
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/save

ig-openroad: ig-setup-openroad
	TECH_ROOT="$(TECH_ROOT)" \
	cd $(IG_ROOT)/target/ihp13/openroad && bash scripts/start.sh
