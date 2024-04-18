# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>
# - Paul Scheffler <paulsc@iis.ee.ethz.ch>

include tools.mk

IG_ROOT  ?= $(shell $(BENDER) path iguana)
CHS_ROOT := $(shell $(BENDER) path cheshire)
HYP_ROOT := $(shell $(BENDER) path hyperbus)

.PHONY: ig-clean-deps ig-all ig-sim-all hyp-sim-all

ig-all: chs-all ig-sim-all

################
# Dependencies #
################

BENDER_ROOT ?= $(IG_ROOT)/.bender

# Ensure both Bender dependencies and (essential) submodules are checked out
$(BENDER_ROOT)/.ig_deps: $(BENDER_ROOT)/.chs_deps
	cd $(IG_ROOT) && git submodule update --init --recursive
	@touch $@

# Make sure dependencies are more up-to-date than any targets run
ifeq ($(shell test -f $(BENDER_ROOT)/.ig_deps && echo 1),)
-include $(BENDER_ROOT)/.ig_deps
endif

# Running this target will reset dependencies (without updating the checked-in Bender.lock)
ig-clean-deps:
	rm -rf .bender
	cd $(IG_ROOT) && git submodule deinit -f --all

# Include Cheshire targets
include $(CHS_ROOT)/cheshire.mk

####################
# HW Configuration #
####################
# name of the project/chip itself
PROJ_NAME 	:= basilsik
# name of the top-module in the design
TOP_DESIGN 	:= iguana_chip
# default (empty): use hyperbus, options: NO_HYPERBUS
HYPER_CONF			:= NO_HYPERBUS
HYPER_CONF			:= 
L1CACHE_WAYS 		:= 2
SCOREBOARD_ENTRIES 	:= 4
# default (empty or ORIG): monolithic cheshire bootrom; SPLIT: bootrom split into parts
BOOTROM_CONF        := SPLIT
BOOTROM_NUM_PARTS 	:= 2
# default (empty or ORIG): default fpnew_fma; OPT: hand optimized fused-muladd in fpnew_fma
FMA_CONF        	:= OPT
# name used for netlist/synthesis related files
#RTL_NAME	:= basilisk
RTL_NAME	 := basilisk_dkong


IG_CVA6_CONFIG := cv64a6_imafdcsclic_sv39
IG_CVA6_PKG_FILE := $(shell $(BENDER) path cva6)/core/include/$(IG_CVA6_CONFIG)_config_pkg.sv
# deactivate hypervisor extension (large and not needed), cut D-cache in half, switch to WT cache
IG_CVA6_PKG_PARAMS := \
	CVA6ConfigHExtEn=0 \
	CVA6ConfigDcacheByteSize=16384 \
	CVA6ConfigDcacheSetAssoc=$(L1CACHE_WAYS) \
	CVA6ConfigDcacheType=WT \
	CVA6ConfigDataUserWidth=64 \
	CVA6ConfigIcacheByteSize=16384 \
	CVA6ConfigIcacheSetAssoc=$(L1CACHE_WAYS) \
	CVA6ConfigNrScoreboardEntries=$(SCOREBOARD_ENTRIES)

RTL_CONF_JSON := $(IG_ROOT)/hw/generated/$(RTL_NAME).json
# document the RTL configuration
ig-hw-conf-json:
	mkdir -p $(IG_ROOT)/hw/generated/
	@jq -n \
		--arg hyp "$(HYPER_CONF)" \
		--argjson l1 $(L1CACHE_WAYS) \
		--argjson sbe $(SCOREBOARD_ENTRIES) \
		--arg rtl "$(RTL_NAME)" \
		--arg boot "$(BOOTROM_CONF)" \
		--arg fma "$(FMA_CONF)" \
		'{ "Hyperbus": $$hyp, "Bootrom": $$boot, "FMA": $$fma, "L1-Cache Ways": $$l1, "Scoreboard Entries": $$sbe, "RTL name": $$rtl }' \
		> $(RTL_CONF_JSON)

# configure CVA6 for this project
ig-hw-cva6:
	@cp -n $(IG_CVA6_PKG_FILE) $(IG_CVA6_PKG_FILE).orig
	@cp $(IG_CVA6_PKG_FILE).orig $(IG_CVA6_PKG_FILE)
	@echo "cva6: configure $(notdir $(IG_CVA6_PKG_FILE))"
	for param_val in $(IG_CVA6_PKG_PARAMS); do \
		param=$$(echo "$$param_val" | cut -d '=' -f 1); \
		value=$$(echo "$$param_val" | cut -d '=' -f 2); \
		echo "param: $$param ; value: $$value"\
		echo "cva6: setting $$param = $$value"; \
		sed "s|\(\s*localparam\s*\)$$param\(\s*=\s*\)[a-zA-Z0-9_]*\(.*\)|\1$$param\2$$value\3|g" \
			$(IG_CVA6_PKG_FILE) > $(IG_CVA6_PKG_FILE).tmp; \
		mv $(IG_CVA6_PKG_FILE).tmp $(IG_CVA6_PKG_FILE);  \
	done
	$(MAKE) ig-hw-conf-json


# BOOTROM CONFIGURATION
IG_CHS_BOOTROM_DIR := $(shell $(BENDER) path cheshire)/hw/bootrom
IG_CHS_BOOTROM_FILE := $(IG_CHS_BOOTROM_DIR)/cheshire_bootrom.sv

# use split default-bootrom instead for better routability
ig-hw-bootrom-split:
	@cp -n $(IG_CHS_BOOTROM_FILE) $(IG_CHS_BOOTROM_FILE).orig
	cd $(IG_CHS_BOOTROM_DIR) && ln -sfr $(IG_ROOT)/hw/cheshire_bootrom_split.sv cheshire_bootrom.sv

ig-hw-bootrom-orig:
	if [ -e "$(IG_CHS_BOOTROM_FILE).orig" ]; then \
		rm $(IG_CHS_BOOTROM_FILE); \
        cp $(IG_CHS_BOOTROM_FILE).orig $(IG_CHS_BOOTROM_FILE); \
    fi

ifeq ($(BOOTROM_CONF), ORIG)
    BOOTROM_CONF_TARGET = ig-hw-bootrom-orig
else ifeq ($(BOOTROM_CONF), SPLIT)
    BOOTROM_CONF_TARGET = ig-hw-bootrom-split
else ifeq ($(BOOTROM_CONF),)
    BOOTROM_CONF_TARGET = ig-hw-bootrom-orig
else
    $(error Invalid value for BOOTROM_CONF: $(BOOTROM_CONF))
endif

ig-hw-gen-split-bootrom: $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.bin
	$(IG_ROOT)/scripts/gen_bootrom_split.py --sv-module cheshire_bootrom --num-parts $(BOOTROM_NUM_PARTS) $(CHS_ROOT)/hw/bootrom/cheshire_bootrom.bin > $(IG_ROOT)/hw/cheshire_bootrom_split.sv


# FUSED-MULADD CONFIGURATION
IG_CHS_FMA_DIR := $(shell $(BENDER) path fpnew)/src/
IG_CHS_FMA_FILE := $(IG_CHS_FMA_DIR)/fpnew_fma.sv

ig-hw-fma-opt:
	@cp -n $(IG_CHS_FMA_FILE) $(IG_CHS_FMA_FILE).orig
	cd $(IG_CHS_FMA_DIR) && ln -sfr $(IG_ROOT)/hw/fpnew_fma_opt.sv fpnew_fma.sv

ig-hw-fma-orig:
	if [ -e "$(IG_CHS_FMA_FILE).orig" ]; then \
		rm $(IG_CHS_FMA_FILE); \
        cp $(IG_CHS_FMA_FILE).orig $(IG_CHS_FMA_FILE); \
    fi

ifeq ($(FMA_CONF), ORIG)
    FMA_CONF_TARGET = ig-hw-fma-orig
else ifeq ($(FMA_CONF), OPT)
    FMA_CONF_TARGET = ig-hw-fma-opt
else ifeq ($(FMA_CONF),)
    FMA_CONF_TARGET = ig-hw-fma-orig
else
    $(error Invalid value for FMA_CONF: $(FMA_CONF))
endif

.PHONY: ig-hw-bootrom-split ig-hw-bootrom-orig ig-hw-gen-split-bootrom ig-hw-fma-opt ig-hw-fma-orig

# these are used in pickle.mk
HW_CONF_TARGETS 	 := ig-hw-cva6 $(BOOTROM_CONF_TARGET) $(FMA_CONF_TARGET) ig-hw-conf-json
MORTY_DEFINES 		 := VERILATOR SYNTHESIS MORTY TARGET_ASIC $(HYPER_CONF)
BENDER_PROJ_TARGETS  := asic ihp13 cva6 $(IG_CVA6_CONFIG)
BENDER_SYNTH_TARGETS := rtl $(BENDER_PROJ_TARGETS)

########################
# IHP13 Implementation #
########################

include $(IG_ROOT)/target/ihp13/pickle/pickle.mk
include $(IG_ROOT)/target/ihp13/yosys/yosys.mk
include $(IG_ROOT)/target/ihp13/openroad/openroad.mk


##############
# Simulation #
##############
IG_SIM_DIR := $(IG_ROOT)/target/sim
SIM_PRE_COMPILE := set BOOTMODE 0; set PRELMODE 0; set BINARY "$(CHS_ROOT)/sw/tests/helloworld.spm.elf";
#SIM_PRE_COMPILE := set BOOTMODE 0; set PRELMODE 1; set BINARY "$(CHS_ROOT)/sw/tests/helloworld.spm.elf";
#SIM_PRE_COMPILE := set BOOTMODE 3; set PRELMODE 0; set BINARY "$(CHS_ROOT)/sw/tests/helloworld.gpt.memh";
#SIM_PRE_COMPILE := set BOOTMODE 0; set PRELMODE 1; set BINARY "$(CHS_ROOT)/sw/tests/helloworld.dram.elf";
BENDER_SIM_TARGETS :=  simulation test hyper_test $(BENDER_PROJ_TARGETS)

# Forward relevant Hyperbus targets
$(HYP_ROOT)/models/s27ks0641/s27ks0641.v:
	@echo "[PULP] Fetch Hyperbus model"
	@$(MAKE) -C $(HYP_ROOT) models/s27ks0641 > /dev/null

$(IG_SIM_DIR)/models/s27ks0641.sdf: $(HYP_ROOT)/models/s27ks0641/s27ks0641.v
	mkdir -p $(dir $@)
	cp $(HYP_ROOT)/models/s27ks0641/s27ks0641.sdf $@
	sed -i "s|(INSTANCE dut)|(INSTANCE i_hyper)|g" $@
	sed -i "s|(INSTANCE dut/|(INSTANCE |g" $@

# TODO: find more flexible system wrt file-paths (changing PROJ_NAME)
# add simulatables into variable in each .mk then setup sims here?
$(IG_SIM_DIR)/vsim/compile.ihp13.%.tcl: Bender.yml
	$(BENDER) script vsim -t $* $(foreach t,$(BENDER_SIM_TARGETS),-t $(t)) --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CHS_ROOT)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

ig-sim-rtl: $(IG_SIM_DIR)/vsim/compile.ihp13.rtl.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -c -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl; run -all'

ig-sim-rtl-gui: $(IG_SIM_DIR)/vsim/compile.ihp13.rtl.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl;'


ig-sim-sv2v: $(IG_SIM_DIR)/vsim/compile.ihp13.sv2v.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -c -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl; run -all'

ig-sim-sv2v-gui: $(IG_SIM_DIR)/vsim/compile.ihp13.sv2v.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl;'


ig-sim-synth: $(IG_SIM_DIR)/vsim/compile.ihp13.synth.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -c -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl; run -all'

ig-sim-synth-gui: $(IG_SIM_DIR)/vsim/compile.ihp13.synth.tcl
	rm -rf target/sim/vsim/work
	cd target/sim/vsim; questa-2022.3 vsim -do '$(SIM_PRE_COMPILE); source $<; source start.iguana.tcl;'

ig-sim-split-bootrom:
	rm -rf target/sim/vsim/work
	cd target/sim/vsim && questa-2022.3 vsim -c -do compile.bootrom.rtl.tcl
	cd target/sim/vsim && questa-2022.3 vsim tb_cheshire_bootrom -c -do "run -all; exit"

IG_SIM_ALL += $(IG_SIM_DIR)/models/s27ks0641.sdf
IG_SIM_ALL += $(IG_SIM_DIR)/vsim/compile.ihp13.rtl.tcl
IG_SIM_ALL += $(IG_SIM_DIR)/vsim/compile.ihp13.sv2v.tcl
IG_SIM_ALL += $(IG_SIM_DIR)/vsim/compile.ihp13.synth.tcl
IG_SIM_ALL += $(IG_SIM_DIR)/vsim/compile.ihp13.gate.tcl

.PHONY: ig-sim-rtl ig-sim-sv2v ig-sim-svase ig-sim-synth ig-sim-split-bootrom


######################
# Nonfree Components #
######################

IG_NONFREE_REMOTE ?= git@iis-git.ee.ethz.ch:pulp-restricted/basilisk-nonfree.git
IG_NONFREE_COMMIT ?= main

ig-nonfree:
	git clone $(IG_NONFREE_REMOTE) $(IG_ROOT)/target/nonfree
	cd $(IG_ROOT)/target/nonfree && git checkout $(IG_NONFREE_COMMIT)

-include $(IG_ROOT)/target/nonfree/nonfree.mk

#################################
# Phonies (KEEP AT END OF FILE) #
#################################

.PHONY: ig-all ig-clean-deps ig-sw-all ig-hw-all ig-bootrom-all ig-sim-all 
.PHONY: ig-hw-cva6 ig-hw-conf-json ig-nonfree ig-sim-clean

IG_ALL += $(CHS_ALL) $(IG_SIM_ALL)

ig-all:         $(CHS_ALL)
ig-sw-all:      $(CHS_SW_ALL)
ig-hw-all:      $(CHS_HW_ALL) ig-hw-cva6
ig-bootrom-all: $(CHS_BOOTROM_ALL)
ig-sim-all:     $(CHS_SIM_ALL) $(IG_SIM_ALL)

ig-sim-clean:
	rm -rf $(IG_SIM_DIR)/vsim/compile.ihp13.*
	rm -rf $(IG_SIM_DIR)/vsim/work
	rm -f $(IG_SIM_DIR)/vsim/trace_hart*
	rm -f $(IG_SIM_DIR)/vsim/transcript
