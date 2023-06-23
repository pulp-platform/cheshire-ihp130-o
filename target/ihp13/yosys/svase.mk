# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Description:
# Second step of preprocessing, simplify some constructs, propagate params
# and make all modules unique per parametrization

# Directories
BUILD		?= build

# Tools
SVASE 	?= svase	# https://github.com/paulsc96/svase/tree/iguana
SLANG		?= slang	# https://github.com/MikePopoloski/slang

# Project variables
TOP_DESIGN	?= iguana_padframe_fixture
PICKLE_FILE ?= $(BUILD)/$(TOP_DESIGN).pickle.sv
SVASE_FILE	?= $(BUILD)/$(TOP_DESIGN).svase.sv
UNIQUE_TOP	 = $(shell sed -n 's|module \($(TOP_DESIGN)[[:alnum:]_]*\)\s.*$$|\1|p' $(SVASE_FILE) | tail -1)

$(SVASE_FILE): $(PICKLE_FILE)
	@$(MAKE) run-svase

run-svase: $(PICKLE_FILE) $(SVASE)
	$(SVASE) $(TOP_DESIGN) $(SVASE_FILE) $< 2>&1 | tee svase.log
# Todo: fix this, is this even correct? (svase pass?) +1 due to regbus
	sed "s|RegOut.num_out|6'h0d|g" $(SVASE_FILE) > $(SVASE_FILE).tmp 
	sed "s|localparam int unsigned SlinkMaxClkDiv|//// localparam int unsigned SlinkMaxClkDiv|g" $(SVASE_FILE).tmp > $(SVASE_FILE)
	patch -u $(SVASE_FILE) -i patches/sub_per_hash.patch
# Needed for nina synthesis, not for yosys (enum member has same name as interface)
	patch -u $(SVASE_FILE) -i patches/protocol_e_axi_renaming.patch
	rm $(SVASE_FILE).tmp

run-slang: $(PICKLE_FILE) $(SLANG)
	sed -n 's|module \($(TOP_DESIGN)[[:alnum:]_]*\)\s.*$$|\1|p' $<
	$(SLANG) $< -Wrange-oob --allow-use-before-declare -Wrange-width-oob -error-limit=4419 -top $(UNIQUE_TOP)

svase:
	@if ! which svase > /dev/null 2>&1; then \
        echo "Not yet integrated, you will have to build it yourself."; \
		echo "git clone --recursive https://github.com/paulsc96/svase.git; cd svase; git checkout iguana;"; \
    fi

slang: svase

.PHONY: run-svase run-slang svase slang
