# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Author:  Paul Scheffler  <paulsc@student.ethz.ch>
#
# First step of preprocessing, put all used RTL into one large file

MORTY ?= morty  # https://github.com/pulp-platform/morty
SVASE ?= svase  # https://github.com/pulp-platform/svase
SV2V  ?= sv2v   # https://https://github.com/zachjs/sv2v

PICKLE_DIR ?= $(IG_ROOT)/target/ihp13/pickle

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
$(PICKLE_DIR)/out/iguana_chip.sources.json: $(IG_ROOT)/Bender.yml ig-all
	mkdir -p $(dir $@)
	$(BENDER) sources -f -t rtl -t asic -t ihp13 -t cva6 -t cv64a6_imafdcsclic_sv39  > $@

# Pickle all synthesizable RTL into a single file
$(PICKLE_DIR)/out/iguana_chip.morty.sv: $(PICKLE_DIR)/out/iguana_chip.sources.json $(wildcard $(PICKLE_DIR)/patches/morty/*)
	$(call rtl-patches,)
	$(MORTY) -q -f $< -o $@ -D VERILATOR=1 -D SYNTHESIS=1 -D MORTY=1 --keep_defines --top iguana_chip
	$(call apply-patches,morty)

ig-ihp13-morty-all: $(PICKLE_DIR)/out/iguana_chip.morty.sv

#########
# SVase #
#########

# Pre-elaborate SystemVerilog pickle
$(PICKLE_DIR)/out/iguana_chip.svase.sv: $(PICKLE_DIR)/out/iguana_chip.morty.sv $(wildcard $(PICKLE_DIR)/patches/svase/*)
	$(SVASE) iguana_chip $@ $<
	$(call apply-patches,svase)

ig-ihp13-svase-all: $(PICKLE_DIR)/out/iguana_chip.svase.sv

########
# SV2V #
########

# Convert pickle to Verilog
$(PICKLE_DIR)/out/iguana_chip.sv2v.v: $(PICKLE_DIR)/out/iguana_chip.svase.sv $(wildcard $(PICKLE_DIR)/patches/sv2v/*)
	$(SV2V) --oversized-numbers --verbose --write $@ $<
	$(call apply-patches,sv2v)

ig-ihp13-pickle-all: $(PICKLE_DIR)/out/iguana_chip.sv2v.v
