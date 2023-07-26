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
# - run-yosys-hier: fully open-source netlist, flattened N-levels below top

# Directories
# Todo: create a common 'project.mk' to set project config variables (or use iguana.mk for that?)
YOSYS_DIR		?= $(IG_ROOT)/target/ihp13/yosys
TECH_ROOT		?= $(IG_ROOT)/target/ihp13/pdk/ihp-sg13g2/ihp-sg13g2/libs.ref
CUR_DIR 		?= $(IG_ROOT)/target/ihp13/yosys
BUILD				?= $(CUR_DIR)/build
WORK				?= $(CUR_DIR)/WORK
REPORTS			?= $(CUR_DIR)/reports

# sed -n "s|^\s*Chip area.*module '\\\([^']*\)': \([0-9.]*\)|\1, \2|p" area_clean.rpt > area.csv

# Tools: TODO remove
include $(IG_ROOT)/target/ihp13/yosys/tools.mk

# Project variables
include $(IG_ROOT)/target/ihp13/yosys/technology.mk
include $(IG_ROOT)/target/ihp13/yosys/project-synth.mk

TOP_DESIGN	?= iguana_chip
SV2V_FILE	  := $(IG_ROOT)/target/ihp13/pickle/out/$(TOP_DESIGN).sv2v.v
VLOG_FILES  := $(SV2V_FILE)
UNIQUE_TOP	:= $(shell sed -n 's|module \($(TOP_DESIGN)__[[:alnum:]_]*\)\s.*$$|\1|p' $(SV2V_FILE) 2> /dev/null | tail -1)
SYNTH_TOP	  := $(UNIQUE_TOP)
NETLIST		  := $(BUILD)/$(TOP_DESIGN)_yosys.v

# as dependency: re-generate netlist only when sv2v is out-of-date
$(NETLIST): $(SV2V_FILE)
	@$(MAKE) run-yosys

synth: tools.log run-yosys

# synthesize using yosys
run-yosys: $(VLOG_FILES)
	@mkdir -p $(BUILD)
	@mkdir -p $(WORK)
	@mkdir -p $(REPORTS)
	@rm -f $(CUR_DIR)/yosys.log
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	TIE_HIGH="$(TECH_CELL_TIEHI)" \
	TIE_LOW="$(TECH_CELL_TIELO)" \
	WORK="$(WORK)" \
	BUILD="$(BUILD)" \
	REPORTS="$(REPORTS)" \
	NETLIST="$(NETLIST)" \
	yosys -c $(CUR_DIR)/scripts/yosys_synthesis.tcl \
		2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M:%S %Z]", systime()), $$0 }' \
		| tee $(CUR_DIR)/yosys.log | grep -E "\[.*\] [0-9\.]+ Executing";

# analyze timing of netlist
run-sta: $(NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	VLOG_NETLIST="$(NETLIST)" \
	TOP_DESIGN="$(UNIQUE_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	REPORTS="$(REPORTS)" \
	sta $(CUR_DIR)/scripts/opensta_timings.tcl

.PHONY: synth run-yosys run-sta 


# CPU/MEM monitoring of yosys (useful for pin-pointing 'bad' commands)
PROFILER_DB := $(REPORTS)/yosys-usage.sqlite
PROFILER_SVG := $(REPORTS)/yosys-usage.svg

run-yosys-profiled: $(VLOG_FILES) run-profiler
	@$(MAKE) run-yosys
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


# Hierarchically split synthesis
# At a depth of N the tree is cut, each subtree is synthesized
# individually and then blackboxed during synthesis of the top-tree
# A precursor to automatic flattening of small modules and parallel synthesis
HIER_DEPTH        := 5
HIER_LIST_SUCCESS := $(WORK)-hier/.$(SYNTH_TOP)_hier_d$(HIER_DEPTH)_success
HIER_TEMP_FILES    = $(wildcard $(WORK)-hier/*.tmp.v)
HIER_PART_FILES    = ${HIER_TEMP_FILES:tmp.v=mapped.v} 
HIER_NETLIST	    := $(BUILD)-hier/$(UNIQUE_TOP)_yosys-hier_tech.v

# start hierarchically split synthesis
run-yosys-hier: $(VLOG_FILES)
	@rm -f yosys-hier.log
	@mkdir -p $(BUILD)-hier
	@mkdir -p $(REPORTS)-hier
	@mkdir -p $(WORK)-hier
	@rm -rf $(WORK)-hier/*
	@rm -f $(HIER_LIST_SUCCESS)
	@$(MAKE) run-yosys-hier-synth

# make subtrees ready, then load as blackboxes and synth entire tree
run-yosys-hier-synth: $(HIER_LIST_SUCCESS)
	@mkdir -p $(WORK)-hier/log
	@$(MAKE) $(HIER_PART_FILES)
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	TIE_HIGH="$(TECH_CELL_TIEHI)" \
	TIE_LOW="$(TECH_CELL_TIELO)" \
	HIER_DEPTH="${HIER_DEPTH}" \
	WORK="$(WORK)-hier" \
	BUILD="$(BUILD)-hier" \
	REPORTS="$(REPORTS)-hier" \
	yosys -c $(CUR_DIR)/scripts/yosys_hier_top_synth.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | $(SYNTH_TOP) |"), $$0 }' \
		| tee -a $(CUR_DIR)/yosys-hier.log;
#	awk -f scripts/combine_port_wire.awk $(HIER_NETLIST) > $(BUILD)-hier/tmp.v

# create placeholder files for all needed subtrees/modules
$(HIER_LIST_SUCCESS): $(VLOG_FILES)
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$(SYNTH_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	TIE_HIGH="$(TECH_CELL_TIEHI)" \
	TIE_LOW="$(TECH_CELL_TIELO)" \
	HIER_DEPTH="${HIER_DEPTH}" \
	WORK="$(WORK)-hier" \
	BUILD="$(BUILD)-hier" \
	yosys -c $(CUR_DIR)/scripts/yosys_gen_hier_list.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | ENTIRE-DESIGN |"), $$0 }' \
		| tee $(CUR_DIR)/yosys-hier.log;
	@touch $(HIER_LIST_SUCCESS)

# synthesize each subtree
$(WORK)-hier/%.mapped.v: $(HIER_LIST_SUCCESS) $(WORK)-hier/%.tmp.v
	@echo "Starting $* ..." \
		| gawk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $$0 }' \
		| tee -a $(CUR_DIR)/yosys-hier.log;
	VLOG_FILES="$(VLOG_FILES)" \
	TOP_DESIGN="$*" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	TIE_HIGH="$(TECH_CELL_TIEHI)" \
	TIE_LOW="$(TECH_CELL_TIELO)" \
	HIER_DEPTH="${HIER_DEPTH}" \
	WORK="$(WORK)-hier" \
	BUILD="$(BUILD)-hier" \
	REPORTS="$(REPORTS)-hier" \
	yosys -c $(CUR_DIR)/scripts/yosys_hier_part_synth.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | $* |"), $$0 }' \
		| tee $(WORK)-hier/log/yosys-hier-$*.log;
	rm -f $(WORK)-hier/$*.tmp.v
	@echo "MAPPED HIERARCHICAL MODULE $*" \
		| gawk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $$0 }' \
		| tee -a $(CUR_DIR)/yosys-hier.log;

# analyze timing of hier-synth netlist
run-sta-hier: $(HIER_NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	VLOG_NETLIST="$(HIER_NETLIST)" \
	TOP_DESIGN="$(UNIQUE_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	REPORTS="$(REPORTS)" \
	sta $(CUR_DIR)/scripts/opensta_timings.tcl

.PHONY: run-yosys-hier run-yosys-hier-synth run-sta-hier 

clean:
	if [ -f $(WORK)/procpath.pid ]; then \
		pkill -F $(WORK)/procpath.pid; \
	fi
	rm -rf $(BUILD)
	rm -rf $(WORK)
	rm -rf $(REPORTS) 
	rm -f $(CUR_DIR)/*.log

.PHONY: clean
