# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Floorplanning stage of the chip
# Two 'pillars' of macros on the left and right
# Currently no good power grid for this variant

puts "Floorplan: Pillar"

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
ICeWall::load_footprint src/basilisk.strategy

initialize_floorplan \
  -die_area  [ICeWall::get_die_area] \
  -core_area [ICeWall::get_core_area] \
  -site      CoreSite

ICeWall::init_footprint src/basilisk.sigmap


##########################################################################
# Tracks 
##########################################################################
puts "Metal Tracks"
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
source scripts/floorplan_util.tcl


##########################################################################
# Macro paths
##########################################################################
puts "Macro Names"
source scripts/macros.tcl

##########################################################################
# RAM size
##########################################################################
# RM_IHPSG13_1P_1024x64_c2_bm_bist
# only for axi_llc_data_ways data macro
# set RamSize1024   [odb::dbDatabase_findMaster [ord::get_db] "RM_IHPSG13_1P_1024x64_c2_bm_bist"]
# set RamSize1024_W [ord::dbu_to_microns [odb::dbMaster_getWidth  $RamSize1024]]
# set RamSize1024_H [ord::dbu_to_microns [odb::dbMaster_getHeight $RamSize1024]]
set RamSize1024_W 784.48
set RamSize1024_H 336.46

# RM_IHPSG13_1P_256x64_c2_bm_bist
# all other macros
# set RamSize256   [odb::dbDatabase_findMaster [ord::get_db] "RM_IHPSG13_1P_256x64_c2_bm_bist"]
# set RamSize256_W [ord::dbu_to_microns [odb::dbMaster_getWidth  $RamSize256]]
# set RamSize256_H [ord::dbu_to_microns [odb::dbMaster_getHeight $RamSize256]]
set RamSize256_W 784.48
set RamSize256_H 118.78


##########################################################################
# Chip sizes and margins
##########################################################################
# entire Place-and-Route area (with pads, without sealring)
set chipArea         [ord::get_die_area]
set chipW            [lindex $chipArea 2]
set chipH            [lindex $chipArea 3]
# thickness of annular ring from pads
set padMargin         310.0

# thickness of annular ring for power-ring
set floorMargin       120.0
# extra keepout annular ring inside floor (only applies to macros!)
set floorPaddingX		    0.0
set floorPaddingY		    2.0

# minimum macro-to-macro distance
set macroMargin 		    2.0
# blockage halo around each macro
set haloBlock           2.0

set floor_leftX			[expr $padMargin + $floorMargin + $floorPaddingX + $macroMargin]
set floor_bottomY		[expr $padMargin + $floorMargin + $floorPaddingY + $macroMargin]
set floor_rightX		[expr $chipW - $padMargin - $floorMargin - $floorPaddingX - $macroMargin]
set floor_topY			[expr $chipH - $padMargin - $floorMargin - $floorPaddingY - $macroMargin]
set floor_midpointX [expr $floor_leftX   + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY [expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]

##########################################################################
# Placing 
##########################################################################
puts "Placing Macros"
##########################################################################
# Place axi_llc_data_ways data macro
##########################################################################
# First group placed in top-left corner

# LLC Way-0
set X [expr $floor_leftX]
set Y [expr $floor_topY - $RamSize1024_W]
placeInstance $axi_data_0_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_0_high
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_0_low $X $Y R90
addHaloToBlock $haloBlock $axi_data_0_low

# LLC Way-1
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_1_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_1_high
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_1_low $X $Y R90
addHaloToBlock $haloBlock $axi_data_1_low

# Second group placed in top-left, one row lower

# LLC Way-3
set X [expr $floor_leftX]
set Y [expr $Y - $macroMargin - $RamSize1024_W]
placeInstance $axi_data_3_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_3_high
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_3_low $X $Y R90
addHaloToBlock $haloBlock $axi_data_3_low

# LLC Way-2
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_2_high $X $Y R90
addHaloToBlock $haloBlock $axi_data_2_high
set X [expr $X + $macroMargin + $RamSize1024_H]
set Y [expr $Y]
placeInstance $axi_data_2_low $X $Y R90
addHaloToBlock $haloBlock $axi_data_2_low


##########################################################################
# Place axi_llc_hit_miss_unit tag macro
##########################################################################
# Tags go in the top-right corner

# left column
# axi_hitmiss_tag_0
set X [expr $floor_rightX - $RamSize256_H]
set Y [expr $floor_topY - $RamSize256_W]
placeInstance $axi_hitmiss_tag_0 $X $Y R270
addHaloToBlock $haloBlock $axi_hitmiss_tag_0

# axi_hitmiss_tag_1
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $axi_hitmiss_tag_1 $X $Y R270
addHaloToBlock $haloBlock $axi_hitmiss_tag_1

# right column
# axi_hitmiss_tag_2
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $axi_hitmiss_tag_2 $X $Y R270
addHaloToBlock $haloBlock $axi_hitmiss_tag_2

# axi_hitmiss_tag_3
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $axi_hitmiss_tag_3 $X $Y R270
addHaloToBlock $haloBlock $axi_hitmiss_tag_3



# ##########################################################################
# Place data sram 
# ########################################################################## 
# L1-Data cache goes into the bottom-left corner

# cva6_wt_dcache_data_0_high
set X [expr $floor_leftX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_0_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_0_high

# cva6_wt_dcache_data_1_high
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_1_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_1_high

# cva6_wt_dcache_data_2_high
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_2_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_2_high

# cva6_wt_dcache_data_3_high
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_3_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_3_high


# cva6_wt_dcache_data_0_low
set X [expr $floor_leftX]
set Y [expr $Y + $macroMargin + $RamSize256_W]
placeInstance $cva6_wt_dcache_data_0_low $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_0_low

# cva6_wt_dcache_data_1_low
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_1_low $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_1_low

# cva6_wt_dcache_data_2_low
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_2_low $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_2_low

# cva6_wt_dcache_data_3_low
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_data_3_low $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_data_3_low


##########################################################################
# Place cva6_wt_dcache_tag
##########################################################################
# L1 Data tags go in bottom-left, above the data
set channel 0.0

# cva6_wt_dcache_tag_0
set X [expr $floor_leftX]
set Y [expr $Y + $macroMargin + $channel + $RamSize256_W]
placeInstance $cva6_wt_dcache_tag_0 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_0


# cva6_wt_dcache_tag_1
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_tag_1 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_1


# cva6_wt_dcache_tag_2
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_tag_2 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_2


# cva6_wt_dcache_tag_3
set X [expr $X + $macroMargin + $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_wt_dcache_tag_3 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_dcache_tag_3

##########################################################################
# Place cva6_icache_data
##########################################################################
# L1-Instruction cache goes into the bottom-right corner

# cva6_icache_data_0_high
set X [expr $floor_rightX - $RamSize256_H]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_0_high $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_0_high

# cva6_icache_data_1_high
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_1_high $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_1_high

# cva6_icache_data_2_high
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_2_high $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_2_high

# cva6_icache_data_3_high
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_3_high $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_3_high


# cva6_icache_data_0_low
set X [expr $floor_rightX - $RamSize256_H]
set Y [expr $Y + $macroMargin + $RamSize256_W]
placeInstance $cva6_icache_data_0_low $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_0_low

# cva6_icache_data_1_low
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_1_low $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_1_low

# cva6_icache_data_2_low
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_2_low $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_2_low

# cva6_icache_data_3_low
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_data_3_low $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_data_3_low


##########################################################################
# Place cva6_icache_tag
##########################################################################
# L1 Instruction tags go in bottom-right, above the data
set channel 0.0

# cva6_icache_tag_0
set X [expr $floor_rightX - $RamSize256_H]
set Y [expr $Y + $macroMargin + $channel + $RamSize256_W]
placeInstance $cva6_icache_tag_0 $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_tag_0

# cva6_icache_tag_1
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_tag_1 $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_tag_1

# cva6_icache_tag_2
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_tag_2 $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_tag_2

# cva6_icache_tag_3
set X [expr $X - $macroMargin - $RamSize256_H]
set Y [expr $Y]
placeInstance $cva6_icache_tag_3 $X $Y R270
addHaloToBlock $haloBlock $cva6_icache_tag_3


##########################################################################
# Place delay lines
##########################################################################
if { ![info exists ::env(HYPER_CONF)] || $::env(HYPER_CONF) ne "NO_HYPERBUS"} {
  set X [expr $floor_leftX]
  placeInstance $delay_line_rx $X 3250 R0
  addHaloToBlock $haloBlock $delay_line_rx

  placeInstance $delay_line_tx $X 3320 R0
  addHaloToBlock $haloBlock $delay_line_tx
}
