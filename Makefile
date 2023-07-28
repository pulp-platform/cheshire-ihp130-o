# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

IG_ROOT ?= $(shell pwd)

include iguana.mk

# Inside the repo, forward all target
all:
	@$(MAKE) ig-all
