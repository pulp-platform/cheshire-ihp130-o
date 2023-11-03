# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Tools
OPENROAD 		?= openroad

# Directories
# directory of the path to the last called Makefile (this one)
OPENROAD_DIR    := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
IG_ROOT		    ?= $(realpath $(OPENROAD_DIR)/../../..)
TARGET_DIR		?= $(realpath $(OPENROAD_DIR)/..)
SAVE			:= $(OPENROAD_DIR)/save
REPORTS			:= $(OPENROAD_DIR)/reports

# Project variables
TOP_DESIGN 	?= iguana_chip
PROJ_NAME	?= $(TOP_DESIGN)

NETLIST		?= $(TARGET_DIR)/yosys/out/$(PROJ_NAME).yosys.v


backend-all: run-openroad

run-openroad:
	mkdir -p $(SAVE)
	mkdir -p $(REPORTS)
	cd $(OPENROAD_DIR) && \
	NETLIST="$(NETLIST)" \
	TOP_DESIGN="$(TOP_DESIGN)" \
	PROJ_NAME="$(PROJ_NAME)" \
	SAVE="$(SAVE)" \
	REPORTS="$(REPORTS)" \
	$(OPENROAD) scripts/chip.tcl -gui \
		2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }' \
		| tee "$(OPENROAD_DIR)/openroad_$(shell date +"%Y-%m-%d_%H_%M_%Z").log";

PHONY: run-openroad backend-all