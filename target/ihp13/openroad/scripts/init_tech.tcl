puts "Init tech"
# LIB
define_corners tt ff

read_liberty -corner tt ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_liberty -corner ff ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_fast_1p32V_m40C.lib

read_liberty -corner tt ../pdk/future/sg13g2_pad/sg13g2_pad_typ_1p2V_3p3V_25C.lib
read_liberty -corner ff ../pdk/future/sg13g2_pad/sg13g2_pad_fast_1p32V_3p3V_m40C.lib

# Read Patched SRAMs TODO: add proper corners when released!
read_liberty -corner tt ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_64x64_c2_bm_bist_dummy.lib
read_liberty -corner ff ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_64x64_c2_bm_bist_dummy.lib

read_liberty -corner tt ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_256x64_c2_bm_bist_dummy.lib
read_liberty -corner ff ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_256x64_c2_bm_bist_dummy.lib

read_liberty -corner tt ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_1024x64_c2_bm_bist_dummy.lib
read_liberty -corner ff ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_1024x64_c2_bm_bist_dummy.lib

# Delay Line
read_liberty -corner tt ../macro_cells/mc_sg13g2_delay/delay_line_D4_O1_6P000.lib
read_liberty -corner ff ../macro_cells/mc_sg13g2_delay/delay_line_D4_O1_6P000.lib

# tech lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef

# cell lef
read_lef ../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_lef ../pdk/future/sg13g2_pad/sg13g2_pad.lef
read_lef ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_64x64_c2_bm_bist.lef
read_lef ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_256x64_c2_bm_bist.lef
read_lef ../pdk/future/sg13g2_sram/RM_IHPSG13_1P_1024x64_c2_bm_bist.lef
read_lef ../macro_cells/mc_sg13g2_delay/delay_line_D4_O1_6P000.lef

set OPEN_CELLS 1
set ctsBuf [ list sg13g2_buf_16 sg13g2_buf_8 sg13g2_buf_4 ]

set dont_use_cells {sg13g2_pad_in sg13g2_pad_io sg13g2_pad_io_pu sg13g2_dfrbp_2}

#set_wire_rc -signal -layer Metal4
#set_wire_rc -clock -layer TopMetal1
