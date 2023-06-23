# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Description:
# Third step of preprocessing, convert SystemVerilog to Verilog

# Directories
BUILD		?= build

# Tools
SV2V 		?= sv2v	# https://github.com/zachjs/sv2v

# Project variables
TOP_DESIGN	?= iguana
SVASE_FILE	?= $(BUILD)/$(TOP_DESIGN).svase.sv
SV2V_FILE	?= $(BUILD)/$(TOP_DESIGN).sv2v.v

# ERROR: 2nd expression of procedural for-loop is not constant!
# parameter [31:0] NoRounds = 32'd1; for all occurences
# advance = rand_number % NoRounds; -> advance = rand_number % 1; -> advance 0
# i < advance; -> i < 0;

# Warning: Number literal 'h100000000 exceeds 32 bits; truncating to 'h0.
# we use --oversized-numbers to avoid this warning --> Probably a TODO in svase
$(SV2V_FILE): $(SVASE_FILE)
	@$(MAKE) run-sv2v

run-sv2v: $(SVASE_FILE) $(SV2V)
	$(SV2V) --oversized-numbers --verbose --write $(SV2V_FILE) $<
	sed "s|i < advance;|i < 0;|g" $(SV2V_FILE) > $(SV2V_FILE).tmp
	sed "s|rst_addr_q <= boot_addr_i;|rst_addr_q <= 64'h0000000002000000;|g" $(SV2V_FILE).tmp > $(SV2V_FILE)
	rm $(SV2V_FILE).tmp
	patch -u $(SV2V_FILE) -i patches/wrong_assignment.patch
	patch -u $(SV2V_FILE) -i patches/i_core_cva6_ext_clic_irq_id.patch

sv2v:
	@if ! which sv2v > /dev/null 2>&1; then \
        echo "Not yet integrated, you will have to build it yourself."; \
		echo "git clone https://github.com/zachjs/sv2v.git; cd sv2v; make"; \
    fi
	
.PHONY: run-sv2v sv2v
