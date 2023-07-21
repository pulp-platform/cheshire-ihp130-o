# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>
# Description:
# Make sure all used tools are accessible by loading them
# into the PATH used inside the Makefiles

# TODO change once we have correct tools installed with DZ
OPENROAD_ROOT := /usr/scratch/schneematt/janniss/Documents/openroad-build/install
# sourcing yosys, yosys-abc and sv2v
export PATH := $(OPENROAD_ROOT)/bin:$(PATH)
# sourcing svase and morty
export PATH := $(PATH):/usr/scratch/schneematt/janniss/Documents/svase/build
# LSOracle plugin
LSORACLE_PLUGIN = /usr/scratch//pisoc11/sem23f30/tools/lsoracle/build/yosys-plugin/oracle.so
# LSOracle binary
# export LSORACLE_EXE := /usr/scratch/pisoc11/sem23f30/tools/lsoracle/build/core/lsoracle
# OpenSTA (sta)
export PATH := $(PATH):/usr/scratch/pisoc11/sem23f30/tools/opensta/app

PIP3_ROOT   := $(shell python3 -m site --user-base)
export PATH := $(PATH):$(PIP3_ROOT)/bin

procpath: $(PIP3_ROOT)/bin/procpath

$(PROCPATH):
	pip3 install --user procpath

.PHONY: procpath

tools.log:
	@which morty  > $@
	@which svase >> $@
	@which sv2v  >> $@
	@which yosys >> $@