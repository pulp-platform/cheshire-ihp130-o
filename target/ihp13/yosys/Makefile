# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Description:
# Synthesis flow from bender sources.json to finished netlist
# Has three main targets:
# - synth/run-yosys: fully open-source netlist with normal synthesis approach
# - run-yosys-hier: fully open-source netlist, flattened N-levels below top
# - blackboxed-theory: mixed open/closed source netlist, side-step yosys issues

# Directories
# Todo: create a common 'project.mk' to set project config variables (or use iguana.mk for that?)
SCRIPT_DIR	:= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PRJ_ROOT 	?= $(realpath $(SCRIPT_DIR)../../../..)
IC_ROOT		?= $(realpath $(CURDIR)/..)
BUILD		?= $(CURDIR)/build
WORK		?= $(CURDIR)/WORK
REPORTS		?= $(CURDIR)/reports
TECH_DIR	?= $(IC_ROOT)/technology/lib

# sed -n "s|^\s*Chip area.*module '\\\([^']*\)': \([0-9.]*\)|\1, \2|p" area_clean.rpt > area.csv

# Tools
include tools.mk

# Project variables
include technology.mk
include project-synth.mk

TOP_DESIGN	?= iguana_chip
# TOP_DESIGN	?= highscore
# TOP_DESIGN	?= scoreboard
PICKLE_FILE := $(BUILD)/$(TOP_DESIGN).pickle.sv
SVASE_FILE	:= $(BUILD)/$(TOP_DESIGN).svase.sv
SV2V_FILE	:= $(BUILD)/$(TOP_DESIGN).sv2v.v
VLOG_FILES  := $(SV2V_FILE)
UNIQUE_TOP	:= $(shell sed -n 's|module \($(TOP_DESIGN)__[[:alnum:]_]*\)\s.*$$|\1|p' $(SVASE_FILE) | tail -1)
SYNTH_TOP	:= $(UNIQUE_TOP)
NETLIST		:= $(BUILD)/$(TOP_DESIGN)_yosys.v

# Preprocessing
include pickle.mk
include svase.mk
include sv2v.mk

# as dependency: re-generate netlist only when sv2v is out-of-date
$(NETLIST): $(SV2V_FILE)
	@$(MAKE) run-yosys

synth: tools.log run-yosys

# synthesize using yosys
run-yosys: $(VLOG_FILES)
	@mkdir -p $(BUILD)
	@mkdir -p $(WORK)
	@mkdir -p $(REPORTS)
	@rm -f yosys.log
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
	yosys -m $(LSORACLE_PLUGIN) -c scripts/yosys_synthesis.tcl \
	 	2>&1 | TZ=UTC gawk '{ print strftime("[%Y-%m-%d %H:%M:%S %Z]", systime()), $$0 }' \
		| tee yosys.log | grep -E "\[.*\] [0-9\.]+ Executing";

# analyze timing of netlist
run-sta: $(NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	VLOG_NETLIST="$(NETLIST)" \
	TOP_DESIGN="$(UNIQUE_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	REPORTS="$(REPORTS)" \
	sta scripts/opensta_timings.tcl

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
HIER_TEMP_FILES    = $(wiledwardard $(WORK)-hier/*.tmp.v)
HIER_PART_FILES    = ${HIER_TEMP_FILES:tmp.v=mapped.v} 
HIER_NETLIST	  := $(BUILD)-hier/$(UNIQUE_TOP)_yosys-hier_tech.v

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
	yosys -c scripts/yosys_hier_top_synth.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | $(SYNTH_TOP) |"), $$0 }' \
		| tee -a yosys-hier.log;
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
	yosys -c scripts/yosys_gen_hier_list.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | ENTIRE-DESIGN |"), $$0 }' \
		| tee yosys-hier.log;
	@touch $(HIER_LIST_SUCCESS)

# synthesize each subtree
$(WORK)-hier/%.mapped.v: $(HIER_LIST_SUCCESS) $(WORK)-hier/%.tmp.v
	@echo "Starting $* ..." \
		| gawk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $$0 }' \
		| tee -a yosys-hier.log;
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
	yosys -m $(LSORACLE_PLUGIN) -c scripts/yosys_hier_part_synth.tcl \
	 	2>&1 | gawk '{ print strftime("%Y-%m-%d %H:%M:%S | $* |"), $$0 }' \
		| tee $(WORK)-hier/log/yosys-hier-$*.log;
	rm -f $(WORK)-hier/$*.tmp.v
	@echo "MAPPED HIERARCHICAL MODULE $*" \
		| gawk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $$0 }' \
		| tee -a yosys-hier.log;

# analyze timing of hier-synth netlist
run-sta-hier: $(HIER_NETLIST)
	@mkdir -p $(REPORTS)
	@rm -f opensta.log
	VLOG_NETLIST="$(HIER_NETLIST)" \
	TOP_DESIGN="$(UNIQUE_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	REPORTS="$(REPORTS)" \
	sta scripts/opensta_timings.tcl

.PHONY: run-yosys-hier run-yosys-hier-synth run-sta-hier 


# Blackboxed yosys + nina synthesis
# Since yosys has some (currently unsolved) issues with a few modules,
# this flow makes it possible to do most of the work in yosys while
# leaving a few modules to be synthesized with nina
BBOXED_NINA_FILES := $(foreach module,$(BBOXED_NINA_MODULES),$(WORK)/nina_split_$(module).v)
BBOXED_NETLIST := $(TOP_DESIGN)_yosys_blackboxed.v
BBOXED_VAR_FILE := $(IC_ROOT)/nina/reports/yosys_variables.tcl
YOSYS_LIBERTY_ARGS := $(foreach cells,$(TECH_CELLS),-liberty $(cells)) \
                      $(foreach macros,$(TECH_MACROS),-liberty $(macros))

NINA_SPLITNET_CMD = read_verilog "$(WORK)/nina_$*.v"; \
						splitnets;;; \
						write_verilog -noattr -noexpr -nohex -nodec "$@";

BBOXEDIZE_YOSYS_CMD = read_verilog -overwrite "$(WORK)/$(BBOXED_NETLIST)"; \
						splitnets -ports -format LRT;;;  \
						tee -q -o $(REPORTS)/$(TOP_DESIGN)_blackboxed_area.rpt stat -top $(SYNTH_TOP) $(YOSYS_LIBERTY_ARGS);  \
						write_verilog -noattr -noexpr -nohex -nodec "$(BUILD)/$(BBOXED_NETLIST)";

# run nina on missing modules
$(IC_ROOT)/nina/netlists/%.v: $(SVASE_FILE)
	@mkdir -p $(IC_ROOT)/nina/netlists
	@mkdir -p $(IC_ROOT)/nina/reports
	@echo "Building $* with Nina..."
	@echo "set top_design $*" > $(BBOXED_VAR_FILE)
	@echo "set vlog_file $(SVASE_FILE)" >> $(BBOXED_VAR_FILE)
	@cd $(IC_ROOT)/nina && \
	nina-2022.03 edwardnxt_shell -f $(IC_ROOT)/nina/scripts/synth_yosys_module.tcl \
	| tee $(WORK)/nina__$*.log | grep -E "[[:space:]#]+Beginning";
	rm $(BBOXED_VAR_FILE)

# post-processing on nina-netlists
$(WORK)/nina_split_%.v: $(IC_ROOT)/nina/netlists/%.v
	cp $< $(WORK)/nina_$*.v
	@echo "Splitting nets in $* with Yosys..."
	yosys -p '$(NINA_SPLITNET_CMD)' 2>&1 \
	 | tee $(WORK)/yosys_splitnet_$*.log | grep -E "[0-9.].*Executing";

# blackboxed-flow, not sensitive to yosys netlist, will only regen nina modules
blackboxedize: $(BBOXED_NINA_FILES)
	cp $(NETLIST) $(WORK)/$(BBOXED_NETLIST)
	@for module in $(BBOXED_NINA_MODULES); do \
		echo "Adding module $$module from nina to yosys netlist..."; \
		sed "/module $$module/,/endmodule/d" $(WORK)/$(BBOXED_NETLIST) > $(WORK)/$(BBOXED_NETLIST).tmp; \
		{ cat $(WORK)/nina_split_$$module.v; cat $(WORK)/$(BBOXED_NETLIST).tmp; } \
		 > $(WORK)/$(BBOXED_NETLIST); \
	done
	yosys -p '$(BBOXEDIZE_YOSYS_CMD)' \
	 | grep -E "[0-9.].*Executing";

# blackboxed-flow, sensitive to yosys netlist (will regenerate to renew)
blackboxed-theory: $(NETLIST) $(BBOXED_NINA_FILES)
	@$(MAKE) blackboxedize

clean:
	if [ -f $(WORK)/procpath.pid ]; then \
		pkill -F $(WORK)/procpath.pid; \
	fi
	rm -rf $(BUILD)
	rm -rf $(WORK)
	rm -rf $(REPORTS) 
	rm -f $(CURDIR)/*.log
 
.PHONY: blackboxedize blackboxed-theory clean
