#!/bin/bash
# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

source /usr/scratch/schneematt/janniss/Documents/openroad-iis-install/build.env
/usr/scratch/schneematt/janniss/Documents/openroad-iis-install/install/bin/openroad scripts/chip.tcl -log "openroad_$(date +"%Y_%m_%d_%I_%M_%p").log"
