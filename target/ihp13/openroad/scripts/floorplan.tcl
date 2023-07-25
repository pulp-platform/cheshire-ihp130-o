# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

# Floorplanning stage of the chip

puts "Floorplan"

##########################################################################
# Mark all macros as unplaced
##########################################################################

set block [ord::get_db_block]
set insts [odb::dbBlock_getInsts $block]
foreach inst $insts {
  odb::dbInst_setPlacementStatus $inst "none"
}

##########################################################################
# Floorplan: Die Size and Padring 
##########################################################################

puts "Rotated Floorplan"
ICeWall::load_footprint src/iguana.strategy

initialize_floorplan \
  -die_area  [ICeWall::get_die_area] \
  -core_area [ICeWall::get_core_area] \
  -site      CoreSite

ICeWall::init_footprint src/iguana.sigmap


##########################################################################
# Tracks 
##########################################################################

make_tracks Metal1    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal2    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal3    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal4    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal5    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks TopMetal1 -x_offset 1.64 -x_pitch 3.28 -y_offset 1.64 -y_pitch 3.28
make_tracks TopMetal2 -x_offset 2.00 -x_pitch 4.00 -y_offset 2.00 -y_pitch 4.00


##########################################################################
# Placing macros
##########################################################################

proc placeInstance { name x y orient } {
  set block [ord::get_db_block]
  set inst [odb::dbBlock_findInst $block $name]
  odb::dbInst_setPlacementStatus $inst "none"
  if {$orient == "R90"} {
    set orient MX
  }
  if {$orient == "MXR90"} {
    set orient R0
  }

  odb::dbInst_setOrient $inst $orient
  odb::dbInst_setLocation $inst [ord::microns_to_dbu $y] [ord::microns_to_dbu $x]
  odb::dbInst_setPlacementStatus $inst "firm"
}

proc addHaloToBlock {halo name} {
  set block [ord::get_db_block]
  set inst [odb::dbBlock_findInst $block $name]

  set bbox [odb::dbInst_getBBox $inst]
  set minx [odb::dbBox_xMin $bbox]
  set miny [odb::dbBox_yMin $bbox]
  set maxx [odb::dbBox_xMax $bbox]
  set maxy [odb::dbBox_yMax $bbox]

  set minx [expr $minx - [ord::microns_to_dbu $halo]]
  set miny [expr $miny - [ord::microns_to_dbu $halo]]
  set maxx [expr $maxx + [ord::microns_to_dbu $halo]]
  set maxy [expr $maxy + [ord::microns_to_dbu $halo]]
}


##########################################################################
# RAM size
##########################################################################

# RM_IHPSG13_1P_1024x64_c2_bm_bist
# only for axi_llc_data_ways data macro
set RamSize1024   [odb::dbDatabase_findMaster [ord::get_db] "RM_IHPSG13_1P_1024x64_c2_bm_bist"]
set RamSize1024_W [ord::dbu_to_microns [odb::dbMaster_getWidth  $RamSize1024]]
set RamSize1024_H [ord::dbu_to_microns [odb::dbMaster_getHeight $RamSize1024]]

# RM_IHPSG13_1P_256x64_c2_bm_bist
# all other macros
set RamSize256   [odb::dbDatabase_findMaster [ord::get_db] "RM_IHPSG13_1P_256x64_c2_bm_bist"]
set RamSize256_W [ord::dbu_to_microns [odb::dbMaster_getWidth  $RamSize256]]
set RamSize256_H [ord::dbu_to_microns [odb::dbMaster_getHeight $RamSize256]]

# set haloBlock width 
set haloBlock     10.0

# offset to not start just ad the edge of the floor (maybe need to consider the pad ring)
set die_area               [ord::get_die_area]
set floorW                 [lindex $die_area 3]
set floorH                 [lindex $die_area 2]

set pad_length             310.0
set floorMargin            120.0
set macroMargin            50.0

set sram_initX_L           [expr $pad_length + $floorMargin + $haloBlock + $macroMargin]
set sram_initX1024_R       [expr $floorW - $pad_length - $floorMargin - $haloBlock - $RamSize1024_W - $macroMargin]
set sram_initX256_R        [expr $floorW - $pad_length - $floorMargin - $haloBlock - $RamSize256_W - $macroMargin]
set sram_initY             [expr $floorMargin + $pad_length + $haloBlock + $macroMargin]
set sram_initY256_T        [expr $floorH - $pad_length - $floorMargin - $haloBlock - $RamSize256_W - $macroMargin]

# delta is set to allow some space between two macros, to avoid routing congestions DRC errors and so on (previous 2.65)
set sram_delta_y           [expr 2 * $haloBlock]
set sram_delta_x           [expr 2 * $haloBlock]


##########################################################################
# Placing 
##########################################################################

##########################################################################
# Place axi_llc_data_ways data macro
##########################################################################
set channel 100.0
set channel_no_cell 200.0
set channel_hori  10.0
set channel_vert  10.0


# axi_data_0
set X [ expr $floorW - $sram_initX_L - $RamSize1024_H ]
set Y $sram_initY
placeInstance  $axi_data_0_low $X $Y MXR90
addHaloToBlock $haloBlock $axi_data_0_low
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_data_0_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_0_high


# axi_data_1
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_hori ]
set Y $Y
placeInstance  $axi_data_1_low $X $Y MXR90
addHaloToBlock $haloBlock $axi_data_1_low
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_data_1_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_1_high


# axi_data_2
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_hori ]
set Y $Y
placeInstance  $axi_data_2_low $X $Y MXR90
addHaloToBlock $haloBlock $axi_data_2_low
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_data_2_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_2_high


## axi_data_3
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_hori ]
set Y $Y
placeInstance  $axi_data_3_low $X $Y MXR90
addHaloToBlock $haloBlock $axi_data_3_low
set X [ expr $X - $RamSize1024_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_data_3_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_3_high


##########################################################################
# Place axi_llc_hit_miss_unit tag macro
##########################################################################

# axi_hitmiss_tag_3
set X [ expr $X - $RamSize256_H - 2*$haloBlock - $channel_hori ]
set Y [ expr $Y ]
placeInstance  $axi_hitmiss_tag_3 $X $Y MXR90
addHaloToBlock $haloBlock $axi_hitmiss_tag_3


# axi_hitmiss_tag_2
set X [ expr $X - $RamSize256_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_hitmiss_tag_2 $X $Y R90
addHaloToBlock $haloBlock $axi_hitmiss_tag_2


# axi_hitmiss_tag_1
set X [ expr $X - $RamSize256_H - 2*$haloBlock - $channel_hori ]
set Y $Y
placeInstance  $axi_hitmiss_tag_1 $X $Y MXR90
addHaloToBlock $haloBlock $axi_hitmiss_tag_1


# axi_hitmiss_tag_0
set X [ expr $X - $RamSize256_H - 2*$haloBlock - $channel_no_cell ]
set Y $Y
placeInstance  $axi_hitmiss_tag_0 $X $Y R90
addHaloToBlock $haloBlock $axi_hitmiss_tag_0


# ##########################################################################
# Place data sram 
# #########################################################################

set channel 250.0
set channel_hori  10.0
set channel_vert  0.0

# cva6_wt_dcache_data_3_high
set X [ expr $sram_initX_L ]
set Y [ expr $sram_initY256_T - 1100 ]
placeInstance  $cva6_wt_dcache_data_3_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_3_high


# cva6_wt_dcache_data_3_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_data_3_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_3_low


# cva6_wt_dcache_data_2_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_dcache_data_2_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_2_high


# cva6_wt_dcache_data_2_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_data_2_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_2_low


# cva6_wt_dcache_data_1_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_dcache_data_1_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_1_high


# cva6_wt_dcache_data_1_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_data_1_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_1_low


# cva6_wt_dcache_data_0_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_dcache_data_0_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_0_high


# cva6_wt_dcache_data_0_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_data_0_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_0_low


##########################################################################
# Place cva6_wt_dcache_tag
##########################################################################

set channel 250.0
set channel_hori  10.0
set channel_vert  0.0


# cva6_wt_dcache_tag_3
set X [ expr $sram_initX_L ]
set Y [ expr $sram_initY256_T ]
placeInstance  $cva6_wt_dcache_tag_3 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_3


# cva6_wt_dcache_tag_2
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_tag_2 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_2


# cva6_wt_dcache_tag_1
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y $Y
placeInstance  $cva6_wt_dcache_tag_1 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_1


# cva6_wt_dcache_tag_0
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_dcache_tag_0 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_0


##########################################################################
# Place cva6_icache_tag
##########################################################################

set channel 140.0
set channel_no_cell 140.0
set channel_hori  10.0
set channel_vert  0.0

# cva6_icache_tag_0
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y $sram_initY256_T
placeInstance  $cva6_icache_tag_0 $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_tag_0


# cva6_icache_tag_1
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_tag_1 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_tag_1


# cva6_icache_tag_2
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_tag_2 $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_tag_2


# cva6_icache_tag_3
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_tag_3 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_tag_3


##########################################################################
# Place cva6_icache_data
##########################################################################

# cva6_icache_data_3_high
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y $Y
placeInstance  $cva6_icache_data_3_high $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_data_3_high
# cva6_icache_data_3_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_3_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_data_3_low


# cva6_icache_data_2_high
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_2_high $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_data_2_high
# cva6_icache_data_2_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_2_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_data_2_low


# cva6_icache_data_1_high
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_1_high $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_data_1_high
# cva6_icache_data_1_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_1_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_data_1_low


# cva6_icache_data_0_high
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_0_high $X $Y R90
addHaloToBlock $haloBlock $cva6_icache_data_0_high
# cva6_icache_data_0_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y [ expr $Y ]
placeInstance  $cva6_icache_data_0_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_icache_data_0_low

# Cut rows under macros such that pdngen knows about the macros
cut_rows

##########################################################################
# Place delay line
##########################################################################

placeInstance $delay_line_rx 4218.48 1601.28 R0
placeInstance $delay_line_tx 4339.44 1656.96 R0
