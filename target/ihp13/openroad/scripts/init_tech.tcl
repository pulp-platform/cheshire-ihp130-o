# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Initialize the PDK

puts "Init tech"

# LIB
define_corners tt ff

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_fast_1p32V_m40C.lib

read_liberty -corner tt ../pdk/future/sg13g2_iocell/sg13g2_iocell_typ_1p2V_3p3V_25C.lib
read_liberty -corner ff ../pdk/future/sg13g2_iocell/sg13g2_iocell_fast_1p32V_3p3V_m40C.lib

# Read Patched SRAMs TODO: add proper corners when released!
read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_64x64_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_64x64_c2_bm_bist_fast_1p32V_m55C.lib

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_256x48_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_256x48_c2_bm_bist_fast_1p32V_m55C.lib

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_256x64_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_256x64_c2_bm_bist_fast_1p32V_m55C.lib

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_512x64_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_512x64_c2_bm_bist_fast_1p32V_m55C.lib

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_1024x64_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_1024x64_c2_bm_bist_fast_1p32V_m55C.lib

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_2048x64_c2_bm_bist_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lib/RM_IHPSG13_1P_2048x64_c2_bm_bist_fast_1p32V_m55C.lib

# Delay Line
read_liberty -corner tt ../src/mc_delay/delay_line_D4_O1_6P000.mid_guess.lib
read_liberty -corner ff ../src/mc_delay/delay_line_D4_O1_6P000.min_guess.lib

# tech lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef

# cell lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_lef ../pdk/future/sg13g2_iocell/sg13g2_iocell.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_64x64_c2_bm_bist.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_256x48_c2_bm_bist.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_256x64_c2_bm_bist.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_512x64_c2_bm_bist.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_1024x64_c2_bm_bist.lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_sram/lef/RM_IHPSG13_1P_2048x64_c2_bm_bist.lef
read_lef ../src/mc_delay/delay_line_D4_O1_6P000.abst.lef

set ctsBuf [ list sg13g2_buf_16 sg13g2_buf_8 sg13g2_buf_4 ]
set ctsBufRoot sg13g2_buf_16

set iocorner corner
set iofill [ list filler1u filler2u filler4u filler10u ]

# TODO: eventually re-enable sg13g2_dfrbp_2
set dont_use_cells {ixc013_i16x ixc013_b16m ixc013_b16mpup ixc013_b16mpdn sg13g2_dfrbp_2}
