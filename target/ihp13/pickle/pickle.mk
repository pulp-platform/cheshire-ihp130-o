# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Authors:
# -Philippe Sauter <phsauter@ethz.ch>
# -Paul Scheffler  <paulsc@iis.ee.ethz.ch>

# First step of preprocessing, put all used RTL into one large file

MORTY ?= morty  # https://github.com/pulp-platform/morty
SVASE ?= svase  # https://github.com/pulp-platform/svase
SV2V  ?= sv2v   # https://https://github.com/zachjs/sv2v

PICKLE_DIR ?= $(IG_ROOT)/target/ihp13/pickle
PICKLE_OUT ?= $(PICKLE_DIR)/out

TOP_DESIGN ?= iguana_chip

# add tools to PATH as necessary like this:
export PATH := $(PATH):/usr/scratch/pisoc11/sem23f30/tools/bin/

###########
# Patches #
###########

# Patches to make to RTL before pickling
define rtl-patches
	sed -i "s| << riscv::XLEN-2| << (riscv::XLEN-2)|g" $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv
endef

# Function to apply replacements and patches at a given pickled stage
define apply-patches
	$(foreach file, $(wildcard $(PICKLE_DIR)/patches/$1/*.sed),
	sed -i -f $(file) $@)
	$(foreach file, $(wildcard $(PICKLE_DIR)/patches/$1/*.patch),
	patch --no-backup-if-mismatch -u $@ -i $(file))
	$(foreach file, $(wildcard $(PICKLE_DIR)/patches/$1/*.append),
	cat $(file) >> $@)
endef

#########
# Morty #
#########

# Generate sources manifest for use by Morty
$(PICKLE_OUT)/$(TOP_DESIGN).sources.json: $(CHS_HW_ALL) $(IG_ROOT)/Bender.yml $(IG_ROOT)/hw/*
	mkdir -p $(dir $@)
	$(BENDER) sources -f $(foreach t,$(BENDER_SYNTH_TARGETS),-t $(t))  > $@

# Pickle all synthesizable RTL into a single file
$(PICKLE_OUT)/$(TOP_DESIGN).morty.sv: $(PICKLE_OUT)/$(TOP_DESIGN).sources.json $(wildcard $(PICKLE_DIR)/patches/morty/*) $(IG_CVA6_PKG_FILE)
	$(call rtl-patches,)
	$(MORTY) -q -f $< -o $@ -D VERILATOR=1 -D SYNTHESIS=1 -D MORTY=1 -D TARGET_ASIC=1 --keep_defines --top $(TOP_DESIGN)
	$(call apply-patches,morty)

ig-ihp13-morty-all: $(PICKLE_OUT)/$(TOP_DESIGN).morty.sv

#########
# SVase #
#########

# Pre-elaborate SystemVerilog pickle
$(PICKLE_OUT)/$(TOP_DESIGN).svase.sv: $(PICKLE_OUT)/$(TOP_DESIGN).morty.sv $(wildcard $(PICKLE_DIR)/patches/svase/*)
	$(SVASE) $(TOP_DESIGN) $@ $<
	sed -i 's/module $(TOP_DESIGN)[[:digit:]_]\+/module $(TOP_DESIGN)/' $(PICKLE_OUT)/$(TOP_DESIGN).svase.sv
	$(call apply-patches,svase)

ig-ihp13-svase-all: $(PICKLE_OUT)/$(TOP_DESIGN).svase.sv

########
# SV2V #
########

# Convert pickle to Verilog
$(PICKLE_OUT)/$(TOP_DESIGN).sv2v.v: $(PICKLE_OUT)/$(TOP_DESIGN).svase.sv $(wildcard $(PICKLE_DIR)/patches/sv2v/*)
	$(SV2V) --oversized-numbers --verbose --write $@ $<
	$(call apply-patches,sv2v)

ig-ihp13-pickle-all: $(PICKLE_OUT)/$(TOP_DESIGN).sv2v.v

.PHONY: ig-ihp13-morty-all ig-ihp13-svase-all ig-ihp13-pickle-all