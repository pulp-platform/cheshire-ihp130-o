# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>
# - Paul Scheffler <paulsc@iis.ee.ethz.ch>

BENDER   ?= bender  # https://github.com/pulp-platform/bender

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

##############
# Simulation #
##############

# Forward relevant Hyperbus targets
$(HYP_ROOT)/models/s27ks0641/s27ks0641.v:
	@echo "[PULP] Fetch Hyperbus model"
	@$(MAKE) -C $(HYP_ROOT) models/s27ks0641 > /dev/null

$(IG_ROOT)/target/sim/models/s27ks0641.sdf: $(HYP_ROOT)/models/s27ks0641/s27ks0641.v
	mkdir -p $(dir $@)
	cp $(HYP_ROOT)/models/s27ks0641/s27ks0641.sdf $@
	sed -i "s|(INSTANCE dut)|(INSTANCE i_hyper)|g" $@
	sed -i "s|(INSTANCE dut/|(INSTANCE |g" $@

$(IG_ROOT)/target/sim/vsim/compile.ihp13.%.tcl: Bender.yml
	$(BENDER) script vsim -t $* -t asic -t ihp13 -t test -t hyper_test -t cva6 -t cv64a6_imafdcsclic_sv39 --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(CHS_ROOT)/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

IG_SIM_ALL += $(HYP_ROOT)/models/s27ks0641/s27ks0641.v
IG_SIM_ALL += $(IG_ROOT)/target/sim/models/s27ks0641.sdf
IG_SIM_ALL += $(IG_ROOT)/target/sim/vsim/compile.ihp13.rtl.tcl
IG_SIM_ALL += $(IG_ROOT)/target/sim/vsim/compile.ihp13.gate.tcl

########################
# IHP13 Implementation #
########################

include $(IG_ROOT)/target/ihp13/pickle/pickle.mk
include $(IG_ROOT)/target/ihp13/yosys/yosys.mk
include $(IG_ROOT)/target/ihp13/openroad/openroad.mk

#################################
# Phonies (KEEP AT END OF FILE) #
#################################

.PHONY: ig-all ig-clean-deps ig-sw-all ig-hw-all ig-bootrom-all ig-sim-all

IG_ALL += $(CHS_ALL) $(IG_SIM_ALL)

ig-all:         $(CHS_ALL)
ig-sw-all:      $(CHS_SW_ALL)
ig-hw-all:      $(CHS_HW_ALL)
ig-bootrom-all: $(CHS_BOOTROM_ALL)
ig-sim-all:     $(CHS_SIM_ALL) $(IG_SIM_ALL)
