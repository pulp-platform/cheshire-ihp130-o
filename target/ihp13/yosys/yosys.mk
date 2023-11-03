# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Description:
# Synthesis flow from bender sources.json to finished netlist
# Has three main targets:
# - synth/run-yosys: fully open-source netlist with normal synthesis approach
# - run-yosys-profiled: same as above but monitor CPU and RAM usage
# - run-yosys-hier: fully open-source netlist, flattened N-levels below top

# Tools
YOSYS 	?= yosys
STA 	?= sta

# Directories
# directory of the path to the last called Makefile (this one)
YOSYS_DIR 		:= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
IG_DIR		    ?= $(realpath $(YOSYS_DIR)/../../..)
TARGET_DIR		?= $(realpath $(YOSYS_DIR)/..)
BUILD			?= $(YOSYS_DIR)/out
WORK			?= $(YOSYS_DIR)/WORK
REPORTS			?= $(YOSYS_DIR)/reports

# Project variables
include $(YOSYS_DIR)/technology.mk
include $(YOSYS_DIR)/project-synth.mk

TOP_DESIGN		?= iguana_chip
PROJ_NAME		?= $(TOP_DESIGN)

SV2V_FILE		:= $(TARGET_DIR)/pickle/out/$(PROJ_NAME).sv2v.v
VLOG_FILES  	:= $(SV2V_FILE)
SYNTH_TOP		?= $(TOP_DESIGN)
NETLIST			:= $(BUILD)/$(PROJ_NAME).yosys.v

synth-all: run-yosys

# synthesize using yosys
run-yosys:
	@mkdir -p $(BUILD)
	@mkdir -p $(WORK)
	@mkdir -p $(REPORTS)
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	PROJ_NAME="$(PROJ_NAME)" \
	WORK="$(WORK)" \
	BUILD="$(BUILD)" \
	REPORTS="$(REPORTS)" \
	NETLIST="$(NETLIST)" \
	$(YOSYS) -c $(YOSYS_DIR)/scripts/yosys_synthesis.tcl \
		2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }' \
		| tee "$(YOSYS_DIR)/yosys_$(shell date +"%Y-%m-%d_%H_%M_%Z").log" \
		| grep -E "\[.*\] [0-9\.]+ Executing";

# make netlist  working dependency
$(NETLIST): $(SV2V_FILE)
	@$(MAKE) run-yosys


# analyze timing of netlist
run-sta: $(NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	NETLIST="$(NETLIST)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	REPORTS="$(REPORTS)" \
	$(STA) $(YOSYS_DIR)/scripts/opensta_timings.tcl

.PHONY: synth-all run-yosys run-sta 


# Hierarchically split synthesis
# At a depth of N the tree is cut, each subtree is synthesized
# individually and then blackboxed during synthesis of the top-tree
# A precursor to automatic flattening of small modules and parallel synthesis
HIER_DEPTH        := -1
HIER_BUILD        := $(BUILD)
HIER_NETLIST	  := $(HIER_BUILD)/$(PROJ_NAME)_yosys-hier_tech.v
HIER_WORK         := $(WORK)-hier
HIER_REPORTS      := $(REPORTS)-hier
HIER_LIST_SUCCESS := $(HIER_WORK)/.$(PROJ_NAME)_hier_d$(HIER_DEPTH)_success
HIER_TEMP_FILES    = $(wildcard $(HIER_WORK)/*.rtl.v)
HIER_PART_FILES    = ${HIER_TEMP_FILES:rtl.v=mapped.v} 

# start hierarchically split synthesis
run-yosys-hier: $(VLOG_FILES)
	@rm -f yosys-hier.log
	@mkdir -p $(HIER_BUILD)
	@mkdir -p $(HIER_REPORTS)
	@mkdir -p $(HIER_WORK)
	@rm -rf $(HIER_WORK)/*
	@rm -f $(HIER_LIST_SUCCESS)
	@cd $(YOSYS_DIR) && $(MAKE) -f yosys.mk run-yosys-hier-synth

# require subtrees be ready, make subtrees, then merge into top
run-yosys-hier-synth: $(HIER_LIST_SUCCESS)
	@mkdir -p $(HIER_WORK)/log
	@cd $(YOSYS_DIR) && $(MAKE) -f yosys.mk $(HIER_PART_FILES)
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	HIER_DEPTH="${HIER_DEPTH}" \
	PROJ_NAME="$(PROJ_NAME)" \
	WORK="$(HIER_WORK)" \
	BUILD="$(HIER_BUILD)" \
	REPORTS="$(HIER_REPORTS)" \
	$(YOSYS) -c scripts/yosys_hier_top_synth.tcl \
	 	2>&1 | gawk '{ print strftime("[%Y-%m-%d %H:%M %Z] $(SYNTH_TOP) |"), $$0 }' \
		| tee -a yosys-hier.log;

# create placeholder files for subtrees/modules
$(HIER_LIST_SUCCESS): $(VLOG_FILES)
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	HIER_DEPTH="${HIER_DEPTH}" \
	PROJ_NAME="$(PROJ_NAME)" \
	WORK="$(HIER_WORK)" \
	BUILD="$(HIER_BUILD)" \
	REPORTS="$(HIER_REPORTS)" \
	$(YOSYS) -c $(YOSYS_DIR)/scripts/yosys_gen_hier_list.tcl \
	 	2>&1 | gawk '{ print strftime("[%Y-%m-%d %H:%M %Z] ENTIRE-DESIGN |"), $$0 }' \
		| tee $(YOSYS_DIR)/yosys-hier.log;
	@touch $(HIER_LIST_SUCCESS)

# synthesize each subtree seperately
$(HIER_WORK)/%.mapped.v: $(HIER_WORK)/%.rtl.v
	@echo "Starting $* ..." \
		| gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }' \
		| tee -a $(YOSYS_DIR)/yosys-hier.log;
	VLOG_FILES="$<" \
	TOP_DESIGN="$*" \
	HIER_DEPTH="${HIER_DEPTH}" \
	PROJ_NAME="$(PROJ_NAME)" \
	WORK="$(HIER_WORK)" \
	BUILD="$(HIER_BUILD)" \
	REPORTS="$(HIER_REPORTS)" \
	NETLIST="$@" \
	$(YOSYS) -c $(YOSYS_DIR)/scripts/yosys_synthesis.tcl \
	 	2>&1 | gawk '{ print strftime("[%Y-%m-%d %H:%M %Z] $* |"), $$0 }' \
		| tee $(HIER_WORK)/log/yosys-hier-$*.log;
	rm -f $(HIER_WORK)/$*.tmp.v
	@echo "MAPPED HIERARCHICAL MODULE $*" \
		| gawk '{ print strftime("[%Y-%m-%d %H:%M %Z]"), $$0 }' \
		| tee -a $(YOSYS_DIR)/yosys-hier.log;

# analyze timing of hier-synth netlist
run-sta-hier: $(HIER_NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	NETLIST="$(HIER_NETLIST)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	REPORTS="$(REPORTS)" \
	$(STA) $(YOSYS_DIR)/scripts/opensta_timings.tcl

.PHONY: run-yosys-hier run-yosys-hier-synth run-sta-hier 


# CPU/MEM monitoring of yosys (useful for pin-pointing 'bad' commands)
PROFILER_DB := $(REPORTS)/yosys-usage.sqlite
PROFILER_SVG := $(REPORTS)/yosys-usage.svg

run-yosys-profiled: $(VLOG_FILES) run-profiler
	cd $(YOSYS_DIR) && $(MAKE) -f yosys.mk run-yosys
	-pkill -F $(WORK)/procpath.pid 2>/dev/null
	@rm -f $(WORK)/procpath.pid
	procpath plot -d $(PROFILER_DB) -f $(PROFILER_SVG) -q cpu -q rss

run-profiler: $(PROCPATH)
	@rm -f $(PROFILER_DB)
	@mkdir -p $(WORK)
	@mkdir -p $(REPORTS)
	@echo "Launching procpath (records process usage)..."
	procpath record -i 30 -d $(PROFILER_DB) '$$..children[?("yosys" in @.cmdline)]' & \
	echo $$! > $(WORK)/procpath.pid

.PHONY: run-yosys-profiler run-profiler


clean:
	if [ -f $(WORK)/procpath.pid ]; then \
		pkill -F $(WORK)/procpath.pid; \
	fi
	rm -rf $(BUILD)
	rm -rf $(WORK)
	rm -rf $(REPORTS) 
	rm -f $(YOSYS_DIR)/*.log

.PHONY: clean
