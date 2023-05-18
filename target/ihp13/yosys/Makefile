# Directories
# Todo: create a common 'project.mk' to set project config variables (or use iguana.mk for that?)
SCRIPT_DIR	:= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PRJ_ROOT 	?= $(realpath $(SCRIPT_DIR)../../../..)
IC_ROOT		?= $(realpath $(CURDIR)/..)
BUILD		?= build
WORK		?= $(CURDIR)/WORK
REPORTS		?= $(CURDIR)/reports
TECH_DIR	?= $(IC_ROOT)/technology/lib

# Tools
include tools.mk

# Project variables
include technology.mk

TOP_DESIGN	?= iguana_chip
PICKLE_FILE := $(BUILD)/$(TOP_DESIGN).pickle.sv
SVASE_FILE	:= $(BUILD)/$(TOP_DESIGN).svase.sv
SV2V_FILE	:= $(BUILD)/$(TOP_DESIGN).sv2v.v
UNIQUE_TOP	 = $(shell sed -n 's|module \($(TOP_DESIGN)__[[:alnum:]_]*\)\s.*$$|\1|p' $(SVASE_FILE) | tail -1)

include pickle.mk
include svase.mk
include sv2v.mk

synth: tools.log run-yosys

tools.log:
	@which morty  > $@
	@which svase >> $@
	@which sv2v  >> $@
	@which yosys >> $@


run-yosys: $(SV2V_FILE)
	@mkdir -p $(BUILD)
	@mkdir -p $(WORK)
	@mkdir -p $(REPORTS)
	@rm -f yosys.log
	VLOG_FILES="$(SV2V_FILE)" \
	TOP_DESIGN="$(UNIQUE_TOP)" \
	TECH_CELLS="$(TECH_CELLS)" \
	TECH_MACROS="$(TECH_MACROS)" \
	BUILD="$(BUILD)" \
	WORK="$(WORK)" \
	REPORTS="$(REPORTS)" \
	yosys -c scripts/yosys_synthesis.tcl | tee -a yosys.log

clean:
	rm -rf $(BUILD)
	rm -rf $(WORK)
	rm -rf $(REPORTS) 
	rm -f $(CURDIR)/tools.log
	rm -f $(CURDIR)/svase.log
	rm -f $(CURDIR)/yosys.log

.PHONY: synth run-yosys clean test
