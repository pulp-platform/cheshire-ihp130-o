# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Authors:
# -Philippe Sauter <phsauter@ethz.ch>
# -Paul Scheffler  <paulsc@iis.ee.ethz.ch>

# First step of preprocessing, put all used RTL into one large file

# Tools
BENDER	?= bender
MORTY 	?= morty
SVASE 	?= svase
SV2V  	?= sv2v

# Directories
# directory of the path to the last called Makefile (this one)
PICKLE_DIR	:= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
IG_DIR		?= $(realpath $(PICKLE_DIR)/../../..)
PICKLE_OUT 	?= $(PICKLE_DIR)/out

# Project variables
TOP_DESIGN 	?= iguana_chip
PROJ_NAME	?= $(TOP_DESIGN)

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
BENDER_SOURCES := $(PICKLE_OUT)/$(PROJ_NAME).sources.json
MORTY_OUT := $(PICKLE_OUT)/$(PROJ_NAME).morty.sv

# Generate sources manifest for use by Morty
$(BENDER_SOURCES): $(CHS_HW_ALL) $(IG_ROOT)/Bender.yml $(wildcard $(IG_ROOT)/hw/*.sv)
	mkdir -p $(dir $@)
	$(BENDER) sources -f $(foreach t,$(BENDER_SYNTH_TARGETS),-t $(t))  > $@

# Pickle all synthesizable RTL into a single file
$(MORTY_OUT): $(BENDER_SOURCES) $(wildcard $(PICKLE_DIR)/patches/morty/*) $(IG_CVA6_PKG_FILE)
	$(call rtl-patches,)
	$(MORTY) -q -f $< -o $@ -D VERILATOR=1 -D SYNTHESIS=1 -D MORTY=1 -D TARGET_ASIC=1 --keep_defines --top $(TOP_DESIGN)
	$(call apply-patches,morty)

run-morty: $(MORTY_OUT)

#########
# SVase #
#########
SVASE_OUT := $(PICKLE_OUT)/$(PROJ_NAME).svase.sv

# Pre-elaborate SystemVerilog pickle
$(SVASE_OUT): $(MORTY_OUT) $(wildcard $(PICKLE_DIR)/patches/svase/*)
	$(SVASE) $(TOP_DESIGN) $@ $<
	sed -i 's/module $(TOP_DESIGN)[[:digit:]_]\+/module $(TOP_DESIGN)/' $(SVASE_OUT)
	$(call apply-patches,svase)

run-svase: $(SVASE_OUT)

########
# SV2V #
########
SV2V_OUT := $(PICKLE_OUT)/$(PROJ_NAME).sv2v.v

# Convert pickle to Verilog
$(SV2V_OUT): $(SVASE_OUT) $(wildcard $(PICKLE_DIR)/patches/sv2v/*)
	$(SV2V) --oversized-numbers --verbose --write $@ $<
	$(call apply-patches,sv2v)

run-pickle: $(SV2V_OUT)

pickle-all: run-pickle

.PHONY: run-morty run-svase run-sv2v run-pickle pickle-all