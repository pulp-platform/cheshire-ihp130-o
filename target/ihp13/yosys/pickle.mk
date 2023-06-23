# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Description:
# First step of preprocessing, put all used RTL into one large file

# Directories
BUILD		?= build

# Tools
BENDER 		?= bender	# https://github.com/pulp-platform/bender
MORTY		?= morty	# https://github.com/pulp-platform/morty

# Project variables
TOP_DESIGN	?= iguana_padframe_fixture
PICKLE_FILE ?= $(BUILD)/$(TOP_DESIGN).pickle.sv

$(PICKLE_FILE): sources.json
	@$(MAKE) pickle

pickle: sources.json $(MORTY)
	@mkdir -p $(BUILD)
	sed "s| << riscv::XLEN-2| << (riscv::XLEN-2)|g" $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv > ariane_pkg.tmp
	mv ariane_pkg.tmp $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv
	$(MORTY) -f $< -q -o $(PICKLE_FILE) -D VERILATOR=1 --keep_defines --top $(TOP_DESIGN)
	# applying patches
	cat patches/reg_bus_interface_ugly_copy.sv >> $(PICKLE_FILE)  	# Todo: fix REGBUS copy in morty
	sed "s/\s*req_q <= (store_req_t'.*/      req_q <= (store_req_t'{mode: axi_llc_pkg::tag_mode_e'(2'b0), default: '0});/g" $(PICKLE_FILE) > $(PICKLE_FILE).tmp
	sed "s/module slib_mv_filter #(parameter WIDTH = 4, THRESHOLD = 10).*/module slib_mv_filter #(parameter WIDTH = 4, parameter THRESHOLD = 10) (/g" $(PICKLE_FILE).tmp > $(PICKLE_FILE)
	patch -u $(PICKLE_FILE) -i patches/serial_link_ddr_in_ff.patch # Todo: Change in source as per IEEE 1364.1 
	patch -u $(PICKLE_FILE) -i patches/clic_implicit_conversion.patch # Todo: Make conversion explicit in RTL
	patch -u $(PICKLE_FILE) -i patches/hyperbus_w2phy_forloops.patch # Todo: Change hyperbus source RTL instead?
	sed -i "s|default: return '{default: '{0, 0}};|default: return cva6_id_map_t'{default: '0};|g" $(PICKLE_FILE)
	rm $(PICKLE_FILE).tmp

# patch -u $@ -i patches/get_permutations.patch
morty: 
	@if ! which svase > /dev/null 2>&1; then \
        echo "Not yet integrated, you will have to go get it yourself."; \
		echo "https://github.com/pulp-platform/morty/releases"; \
    fi

.PHONY: pickle morty
