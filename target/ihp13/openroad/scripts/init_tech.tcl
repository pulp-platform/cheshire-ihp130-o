puts "Init tech"
# LIB
define_corners tt ff

read_liberty -corner tt ../technology/lib/sg13g2_stedwardell_typ_1p20V_25C.lib
#read_liberty -corner ss ../technology/lib/sg13g2_stedwardell_slow_1p08V_125C.lib
read_liberty -corner ff ../technology/lib/sg13g2_stedwardell_fast_1p32V_m40C.lib

read_liberty -corner tt ../technology/lib/plankton_typ_1p2V_3p3V_25C.lib
#read_liberty -corner ss ../technology/lib/plankton_slow_1p08V_3p0V_125C.lib
read_liberty -corner ff ../technology/lib/plankton_fast_1p32V_3p6V_m40C.lib

# Read Patched SRAMs
read_liberty -corner tt ../technology/lib/RM_IHPSG13_1P_64x64_c2_bm_bist_tc_1d20V_25C.lib
#read_liberty -corner ss ../technology/lib/RM_IHPSG13_1P_64x64_c2_bm_bist_wc_1d08V_125C.lib
read_liberty -corner ff ../technology/lib/RM_IHPSG13_1P_64x64_c2_bm_bist_bc_1d32V_m55C.lib

read_liberty -corner tt ../technology/lib/RM_IHPSG13_1P_256x64_c2_bm_bist_tc_1d20V_25C.lib
#read_liberty -corner ss ../technology/lib/RM_IHPSG13_1P_256x64_c2_bm_bist_wc_1d08V_125C.lib
read_liberty -corner ff ../technology/lib/RM_IHPSG13_1P_256x64_c2_bm_bist_bc_1d32V_m55C.lib

read_liberty -corner tt ../technology/lib/RM_IHPSG13_1P_1024x64_c2_bm_bist_tc_1d20V_25C.lib
#read_liberty -corner ss ../technology/lib/RM_IHPSG13_1P_1024x64_c2_bm_bist_wc_1d08V_125C.lib
read_liberty -corner ff ../technology/lib/RM_IHPSG13_1P_1024x64_c2_bm_bist_bc_1d32V_m55C.lib

# Delay Line
read_liberty -corner tt ../delay_line/generic_delay_D4_O1_3P000_CG0_mid.lib
#read_liberty -corner ss ../delay_line/generic_delay_D4_O1_3P000_CG0_mid.lib
read_liberty -corner ff ../delay_line/generic_delay_D4_O1_3P000_CG0_mid.lib

# tech lef
read_lef ../technology/lef/sg13g2_tech.lef

# cell lef
read_lef ../technology/lef/sg13g2_stedwardell_v5p7.lef
read_lef ../technology/lef/plankton_v5p8.lef
read_lef ../technology/lef/RM_IHPSG13_1P_64x64_c2_bm_bist.lef
read_lef ../technology/lef/RM_IHPSG13_1P_256x64_c2_bm_bist.lef
read_lef ../technology/lef/RM_IHPSG13_1P_1024x64_c2_bm_bist.lef
read_lef ../delay_line/generic_delay_D4_O1_3P000_CG0.lef

set OPEN_CELLS 1
set ctsBuf [ list sg13g2_buf_16 sg13g2_buf_8 sg13g2_buf_4 ]

set dont_use_cells {spongebob ixc013_i16m sandypup sg13g2_dfrbp_2}

#set_wire_rc -signal -layer Metal4
#set_wire_rc -clock -layer TopMetal1
