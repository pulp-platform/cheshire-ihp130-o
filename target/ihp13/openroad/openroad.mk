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

# Project variables
# if you are running the entire flow these are set by iguana.mk
# in that case do not change them here
TOP_DESIGN 	?= iguana_chip
PROJ_NAME	?= $(TOP_DESIGN)
NETLIST		?= $(TARGET_DIR)/yosys/out/$(PROJ_NAME).yosys.v
# emtpy if the netlist includes hyperbus, otherwise HYPER_CONF=NO_HYPERBUS
HYPER_CONF	 ?= 
L1CACHE_WAYS ?=

OPENROAD_OUT_DIR	?= $(OPENROAD_DIR)
SAVE				?= $(OPENROAD_OUT_DIR)/save
REPORTS				?= $(OPENROAD_OUT_DIR)/reports
LOG_PATH			:= "$(OPENROAD_OUT_DIR)/$(PROJ_NAME)_$(shell date +"%Y-%m-%d_%H_%M_%Z").log"

backend-all: run-openroad

run-openroad:
	mkdir -p $(SAVE)
	mkdir -p $(REPORTS)
	$(MAKE) or-run-snapshot
	cd $(OPENROAD_DIR) && ln -fs $(LOG_PATH) $(PROJ_NAME).log
	cd $(OPENROAD_DIR) && \
	NETLIST="$(NETLIST)" \
	TOP_DESIGN="$(TOP_DESIGN)" \
	PROJ_NAME="$(PROJ_NAME)" \
	SAVE="$(SAVE)" \
	REPORTS="$(REPORTS)" \
	HYPER_CONF="$(HYPER_CONF)" \
	L1CACHE_WAYS="$(L1CACHE_WAYS)" \
	PDK="$(TARGET_DIR)/pdk" \
	$(OPENROAD) scripts/chip.tcl -gui \
		-log $(LOG_PATH) \
		2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }';

or-run-snapshot:
	zip -r $(SAVE)/$(PROJ_NAME)_source.zip \
		    $(subst $(IG_ROOT)/,,$(IG_ROOT)/iguana.mk) \
	        $(subst $(IG_ROOT)/,,$(NETLIST)) \
	        $(subst $(IG_ROOT)/,,$(YOSYS_DIR)/scripts) \
	        $(subst $(IG_ROOT)/,,$(YOSYS_DIR)/*.mk) \
	        $(subst $(IG_ROOT)/,,$(YOSYS_REPORTS)/$(RTL_NAME)*) \
	        $(subst $(IG_ROOT)/,,$(PICKLE_OUT)/$(RTL_NAME).*) \
	        $(subst $(IG_ROOT)/,,$(OPENROAD_DIR)/openroad.mk) \
	        $(subst $(IG_ROOT)/,,$(OPENROAD_DIR)/scripts)

PHONY: run-openroad backend-all or-run-snapshot