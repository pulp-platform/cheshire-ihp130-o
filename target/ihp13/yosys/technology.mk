# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

TECH_DIR	?= $(TARGET_DIR)/pdk

TECH_CELLS_DIR		:= $(TECH_DIR)/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell
TECH_MACROS_DIR 	:= $(TECH_DIR)/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram
TECH_IOCELLS_DIR 	:= $(TECH_DIR)/future/sg13g2_iocell

TECH_CELLS 	:= $(TECH_CELLS_DIR)/lib/sg13g2_stdcell_typ_1p20V_25C.lib
TECH_MACROS	:= $(wildcard $(TECH_MACROS_DIR)/lib/*_typ_1p20V_25C.lib) \
				$(TECH_IOCELLS_DIR)/sg13g2_iocell_typ_1p2V_3p3V_25C.lib \
				$(TARGET_DIR)/src/mc_delay/delay_line_D4_O1_6P000.lib

TECH_CELL_TIEHI_CELL	:= sg13g2_tiehi
TECH_CELL_TIEHI_PIN 	:= L_HI
TECH_CELL_TIEHI 		:= $(TECH_CELL_TIEHI_CELL) $(TECH_CELL_TIEHI_PIN)

TECH_CELL_TIELO_CELL	:= sg13g2_tielo
TECH_CELL_TIELO_PIN 	:= L_LO
TECH_CELL_TIELO 		:= $(TECH_CELL_TIELO_CELL) $(TECH_CELL_TIELO_PIN)

# export them to the environment so its easily available in yosys
export YOSYS_TECH_CELLS 	:= $(TECH_CELLS)
export YOSYS_TECH_MACROS	:= $(TECH_MACROS)
export YOSYS_TECH_TIEHI 	:= $(TECH_CELL_TIEHI)
export YOSYS_TECH_TIELO 	:= $(TECH_CELL_TIELO)