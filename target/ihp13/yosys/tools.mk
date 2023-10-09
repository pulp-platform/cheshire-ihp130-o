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

# LSOracle currently not used
LSORACLE_ROOT := 
# LSOracle plugin
LSORACLE_PLUGIN := $(LSORACLE_ROOT)/yosys-plugin/oracle.so
# LSOracle binary
export LSORACLE_EXE := $(LSORACLE_ROOT)/core/lsoracle
# KayPar configuration file
export LSORACLE_KAYPAR_CONF := $(LSORACLE_ROOT)/core/test.ini


PIP3_ROOT   := $(shell python3 -m site --user-base)
export PATH := $(PATH):$(PIP3_ROOT)/bin

# procpath is used to log memory and cpu usage
procpath: $(PIP3_ROOT)/bin/procpath

$(PROCPATH):
	pip3 install --user procpath

.PHONY: procpath

tools.log:
	@which morty  > $@
	@which svase >> $@
	@which sv2v  >> $@
	@which yosys >> $@