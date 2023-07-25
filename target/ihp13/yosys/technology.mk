# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

TECH_CELLS 	?= $(TECH_ROOT)/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
TECH_MACROS	?= $(addprefix $(IG_ROOT)/target/ihp13/pdk/future/sg13g2_sram/,RM_IHPSG13_1P_64x64_c2_bm_bist_dummy.lib \
										RM_IHPSG13_1P_256x64_c2_bm_bist_dummy.lib \
										RM_IHPSG13_1P_1024x64_c2_bm_bist_dummy.lib ) \
				$(IG_ROOT)/target/ihp13/pdk/future/sg13g2_pad/sg13g2_pad_typ_1p2V_3p3V_25C.lib \
				$(IG_ROOT)/target/ihp13/macro_cells/mc_sg13g2_delay/delay_line_D4_O1_6P000.lib

TECH_CELL_TIEHI_CELL	:= sg13g2_tiehi
TECH_CELL_TIEHI_PIN 	:= L_HI
TECH_CELL_TIEHI 		:= $(TECH_CELL_TIEHI_CELL) $(TECH_CELL_TIEHI_PIN)

TECH_CELL_TIELO_CELL	:= sg13g2_tielo
TECH_CELL_TIELO_PIN 	:= L_LO
TECH_CELL_TIELO 		:= $(TECH_CELL_TIELO_CELL) $(TECH_CELL_TIELO_PIN)