# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Floorplanning stage of the chip
# Macros mostly at the bottom and top with a few on the sides
# aranged to leave a large roughly circular center for logic

puts "Floorplan: Ring"

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
source scripts/floorplan-util.tcl


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
# set RamSize1024   [dbCellDim [dbInstCellName [dbGetInstByName $axi_data_0_high ]]]
set RamSize1024_W 784.48
set RamSize1024_H 336.46

# RM_IHPSG13_1P_256x64_c2_bm_bist
# all other macros
# set RamSize256   [dbCellDim [dbInstCellName [dbGetInstByName $cva6_icache_tag_0 ]]]
set RamSize256_W 784.48
set RamSize256_H 118.78


##########################################################################
# Chip sizes and margins
##########################################################################
set chipW            6250.0
set chipH            5498.0
# thickness of annular ring for pads
set padMargin         310.0

# thickness of annular ring for power-ring
set floorMargin       110.0
# extra keepout annular ring inside floor (only applies to macros!)
set floorPaddingX		    2.0
set floorPaddingY		    5.0

# minimum macro-to-macro distance
set macroMargin 		   10.0
# halo around each macro
set haloBlockL         10.0
set haloBlockR         10.0
set haloBlockB         10.0
set haloBlockT         10.0

set floor_leftX			  [expr $padMargin + $floorMargin + $floorPaddingX]
set floor_bottomY		  [expr $padMargin + $floorMargin + $floorPaddingY]
set floor_rightX		  [expr $chipW - $padMargin - $floorMargin - $floorPaddingX]
set floor_topY			  [expr $chipH - $padMargin - $floorMargin - $floorPaddingY]
set floor_midpointX 	[expr $floor_leftX + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY 	[expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]

##########################################################################
# Placing 
##########################################################################
puts "Place Macros"
# routing channels between groups of side-by-side macros
set channelX   70.0
# routing channels between groups of macros on-top of eachother
# used to seperate the tags from the data caches
set channelY 1000.0

##########################################################################
# Place axi_llc_data_ways data macro
##########################################################################
# First group placed in top-left corner

# LLC Way-0
set X [expr $floor_leftX]
set Y [expr $floor_topY - $RamSize1024_H]
placeInstance $axi_data_0_high $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_0_high
set X [expr $X]
set Y [expr $Y - $macroMargin - $RamSize1024_H]
placeInstance $axi_data_0_low $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_0_low

# LLC Way-1
set X [expr $X + $macroMargin + $RamSize1024_W + $channelX]
set Y [expr $floor_topY - $RamSize1024_H]
placeInstance $axi_data_1_high $X $Y R0
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $axi_data_1_high
set X [expr $X]
set Y [expr $Y - $macroMargin - $RamSize1024_H]
placeInstance $axi_data_1_low $X $Y R0
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $axi_data_1_low

# Second group placed in top-right corner

# LLC Way-3
set X [expr $floor_rightX - $RamSize1024_W]
set Y [expr $floor_topY - $RamSize1024_H]
placeInstance $axi_data_3_high $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_3_high
set X [expr $X ]
set Y [expr $Y - $macroMargin - $RamSize1024_H]
placeInstance $axi_data_3_low $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_3_low

# LLC Way-2
set X [expr $X - $macroMargin - $RamSize1024_W - $channelX]
set Y [expr $floor_topY - $RamSize1024_H]
placeInstance $axi_data_2_high $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $axi_data_2_high
set X [expr $X ]
set Y [expr $Y - $macroMargin - $RamSize1024_H]
placeInstance $axi_data_2_low $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $axi_data_2_low


##########################################################################
# Place axi_llc_hit_miss_unit tag macro
##########################################################################
# Tags go in the top-middle

# left column
# axi_hitmiss_tag_0
set X [expr $floor_midpointX - $macroMargin/2 - $RamSize256_W]
set Y [expr $floor_topY - $RamSize256_H]
placeInstance $axi_hitmiss_tag_0 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_0

# axi_hitmiss_tag_1
set X [expr $X ]
set Y [expr $Y - $macroMargin - $RamSize256_H]
placeInstance $axi_hitmiss_tag_1 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_1

# right column
# axi_hitmiss_tag_2
set X [expr $floor_midpointX + $macroMargin/2]
set Y [expr $floor_topY - $RamSize256_H]
placeInstance $axi_hitmiss_tag_2 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_2

# axi_hitmiss_tag_3
set X [expr $X ]
set Y [expr $Y - $macroMargin - $RamSize256_H]
placeInstance $axi_hitmiss_tag_3 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_3



# ##########################################################################
# Place data sram 
# ########################################################################## 
# L1-Data cache goes into the bottom-left corner

# cva6_wt_dcache_data_3_high
set X [expr $floor_leftX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_3_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_3_high

# cva6_wt_dcache_data_2_high
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_2_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_2_high

# cva6_wt_dcache_data_1_high
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_1_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_1_high


# cva6_wt_dcache_data_0_high
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_0_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_0_high


# cva6_wt_dcache_data_3_low
set X [expr $floor_leftX + $macroMargin + $RamSize256_W + $channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_3_low $X $Y R180
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_3_low
add_macro_blockage 0 $cva6_wt_dcache_data_3_low $cva6_wt_dcache_data_3_high

# cva6_wt_dcache_data_2_low
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_2_low $X $Y R180
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_2_low
add_macro_blockage 0 $cva6_wt_dcache_data_2_low $cva6_wt_dcache_data_2_high

# cva6_wt_dcache_data_1_low
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_1_low $X $Y R180
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_1_low
add_macro_blockage 0 $cva6_wt_dcache_data_1_low $cva6_wt_dcache_data_1_high

# cva6_wt_dcache_data_0_low
set X [expr $X]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_data_0_low $X $Y R180
addHaloToBlock $channelX $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_0_low
add_macro_blockage 0 $cva6_wt_dcache_data_0_low $cva6_wt_dcache_data_0_high


##########################################################################
# Place cva6_wt_dcache_tag
##########################################################################
# L1 Data tags go in bottom-left, above the data

# cva6_wt_dcache_tag_3
set X [expr $floor_leftX]
set Y [expr $Y + $channelY]
placeInstance $cva6_wt_dcache_tag_3 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_3

# cva6_wt_dcache_tag_2
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_tag_2 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_2

# cva6_wt_dcache_tag_1
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_tag_1 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_1

# cva6_wt_dcache_tag_0
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_wt_dcache_tag_0 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_0


##########################################################################
# Place cva6_icache_data
##########################################################################
# L1-Instruction cache goes into the bottom-right corner

# cva6_icache_data_3_high
set X [expr $floor_rightX - $RamSize256_W]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_3_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_3_high

# cva6_icache_data_2_high
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_2_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_2_high

# cva6_icache_data_1_high
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_1_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_1_high

# cva6_icache_data_0_high
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_0_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_0_high

# cva6_icache_data_3_low
set X [expr $X - $macroMargin - $RamSize256_W - $channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_3_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $cva6_icache_data_3_low
add_macro_blockage 0 $cva6_icache_data_3_low $cva6_icache_data_3_high

# cva6_icache_data_2_low
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_2_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $cva6_icache_data_2_low
add_macro_blockage 0 $cva6_icache_data_2_low $cva6_icache_data_2_high

# cva6_icache_data_1_low
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_1_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $cva6_icache_data_1_low
add_macro_blockage 0 $cva6_icache_data_1_low $cva6_icache_data_1_high

# cva6_icache_data_0_low
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_data_0_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $cva6_icache_data_0_low
add_macro_blockage 0 $cva6_icache_data_0_low $cva6_icache_data_0_high

##########################################################################
# Place cva6_icache_tag
##########################################################################
# L1 Instruction tags go in bottom-right, above the data

# cva6_icache_tag_0
set X [expr $floor_rightX - $RamSize256_W]
set Y [expr $Y + $channelY]
placeInstance $cva6_icache_tag_0 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_0

# cva6_icache_tag_1
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_tag_1 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_1

# cva6_icache_tag_2
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_tag_2 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_2

# cva6_icache_tag_3
set X [expr $X ]
set Y [expr $Y + $macroMargin + $RamSize256_H]
placeInstance $cva6_icache_tag_3 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_3


##########################################################################
# Place delay lines
##########################################################################
# delay lines are placed by EDA tool
set X [expr $floor_leftX]
placeInstance $delay_line_rx $X 3399.9 R0
addHaloToBlock 1 1 1 1 $delay_line_rx

placeInstance $delay_line_tx $X 3450.3 R0
addHaloToBlock 1 1 1 1 $delay_line_tx

cut_rows -halo_width_y 10 -halo_width_x 15