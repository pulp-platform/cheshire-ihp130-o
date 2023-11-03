# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Description:
# Make sure all used tools are accessible by loading them
# into the PATH used inside the Makefiles

# add tools to PATH as necessary like this:
# export PATH := /usr/.../bin:$(PATH)

BENDER   := bender   # https://github.com/pulp-platform/bender
MORTY    := morty    # https://github.com/pulp-platform/morty
SVASE    := svase    # https://github.com/pulp-platform/svase
SV2V     := sv2v     # https://https://github.com/zachjs/sv2v
YOSYS    := yosys    # https://github.com/YosysHQ/yosys
OPENROAD := openroad # https://github.com/The-OpenROAD-Project/OpenROAD

# LSOracle could be used in Yosys, currently deactived and not used
# LSORACLE_ROOT := 
# LSOracle plugin
# LSORACLE_PLUGIN := $(LSORACLE_ROOT)/yosys-plugin/oracle.so
# LSOracle binary
# export LSORACLE_EXE := $(LSORACLE_ROOT)/core/lsoracle
# KayPar configuration file
# export LSORACLE_KAYPAR_CONF := $(LSORACLE_ROOT)/core/test.ini

tools.log:
	@which $(BENDER)    > $@
	@which $(MORTY)    >> $@
	@which $(SVASE)    >> $@
	@which $(SV2V)     >> $@
	@which $(YOSYS)    >> $@
	@which $(OPENROAD) >> $@

# we want to regenerate it everytime to always see the current tools
.PHONY: tools.log