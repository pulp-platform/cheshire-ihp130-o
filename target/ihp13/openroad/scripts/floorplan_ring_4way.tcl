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

utl::report "Floorplan: Ring (4-way cache config)"

##########################################################################
# Mark all macros as unplaced
##########################################################################

set block [ord::get_db_block]
set insts [odb::dbBlock_getInsts $block]
foreach inst $insts {
  odb::dbInst_setPlacementStatus $inst "none"
}

##########################################################################
# RAM size
##########################################################################
set RamMaster64x64    [[ord::get_db] findMaster "RM_IHPSG13_1P_64x64_c2_bm_bist"]
set RamSize64x64_W    [ord::dbu_to_microns [$RamMaster64x64 getWidth]]
set RamSize64x64_H    [ord::dbu_to_microns [$RamMaster64x64 getHeight]]

set RamMaster256x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_256x64_c2_bm_bist"]
set RamSize256x64_W   [ord::dbu_to_microns [$RamMaster256x64 getWidth]]
set RamSize256x64_H   [ord::dbu_to_microns [$RamMaster256x64 getHeight]]

set RamMaster256x48   [[ord::get_db] findMaster "RM_IHPSG13_1P_256x48_c2_bm_bist"]
set RamSize256x48_W   [ord::dbu_to_microns [$RamMaster256x48 getWidth]]
set RamSize256x48_H   [ord::dbu_to_microns [$RamMaster256x48 getHeight]]

set RamMaster512x64   [[ord::get_db] findMaster "RM_IHPSG13_1P_512x64_c2_bm_bist"]
set RamSize512x64_W   [ord::dbu_to_microns [$RamMaster512x64 getWidth]]
set RamSize512x64_H   [ord::dbu_to_microns [$RamMaster512x64 getHeight]]

set RamMaster1024x64  [[ord::get_db] findMaster "RM_IHPSG13_1P_1024x64_c2_bm_bist"]
set RamSize1024x64_W  [ord::dbu_to_microns [$RamMaster1024x64 getWidth]]
set RamSize1024x64_H  [ord::dbu_to_microns [$RamMaster1024x64 getHeight]]

set RamMaster2048x64  [[ord::get_db] findMaster "RM_IHPSG13_1P_2048x64_c2_bm_bist"]
set RamSize2048x64_W  [ord::dbu_to_microns [$RamMaster2048x64 getWidth]]
set RamSize2048x64_H  [ord::dbu_to_microns [$RamMaster2048x64 getHeight]]


##########################################################################
# Chip sizes and margins
##########################################################################
set chipW            6230.0
set chipH            5478.0
# thickness of annular ring for pads
set padMargin         310.0

# thickness of annular ring for power-ring
set floorMargin        70.0
# extra keepout annular ring inside floor (only applies to macros!)
# large enough for a few standard cells between core-ring and macros
set floorPaddingX       8.0
set floorPaddingY      14.0

set coreMargin        [expr $padMargin + $floorMargin]

# minimum macro-to-macro distance
set macroMargin        10.0
# halo around each macro
set haloBlockL         1.0
set haloBlockR         1.0
set haloBlockB         1.0
set haloBlockT         1.0


##########################################################################
# Chip and Core Area
##########################################################################

utl::report "Rotated Floorplan"
initialize_floorplan -die_area "0 0 $chipW $chipH" \
                     -core_area "$coreMargin $coreMargin [expr $chipW-$coreMargin] [expr $chipH-$coreMargin]" \
                     -sites "CoreSite"

# ToDo: get sites from stdcell lef as union of all regex-matches "^\s*SITE\s+([0-9a-zA-Z_]+)\s*;\s*$"

# core gets snapped to site-grid -> adjust
set coreArea          [ord::get_core_area]
set coreArea_leftX    [lindex $coreArea 0]
set coreArea_bottomY  [lindex $coreArea 1]
set coreArea_rightX   [lindex $coreArea 2]
set coreArea_topY     [lindex $coreArea 3]

set floor_leftX       [expr $coreArea_leftX + $floorPaddingX]
set floor_bottomY     [expr $coreArea_bottomY + $floorPaddingY]
set floor_rightX      [expr $coreArea_rightX - $floorPaddingX]
set floor_topY        [expr $coreArea_topY - $floorPaddingY]
set floor_midpointX   [expr $floor_leftX + ($floor_rightX - $floor_leftX)/2]
set floor_midpointY   [expr $floor_bottomY + ($floor_topY - $floor_bottomY)/2]


##########################################################################
# Tracks 
##########################################################################
utl::report "Metal Tracks"
make_tracks Metal1    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal2    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal3    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal4    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal5    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks TopMetal1 -x_offset 1.64 -x_pitch 3.28 -y_offset 1.64 -y_pitch 3.28
make_tracks TopMetal2 -x_offset 2.00 -x_pitch 4.00 -y_offset 2.00 -y_pitch 4.00

# useful to align things (eg: standard-cell macros)
set siteHeight        [ord::dbu_to_microns [[dpl::get_row_site] getHeight]]


##########################################################################
# Pads/IOs 
##########################################################################
source src/basilisk_io.tcl


##########################################################################
# Placing macros
##########################################################################
source scripts/floorplan_util.tcl


##########################################################################
# Macro paths
##########################################################################
utl::report "Macro Names"
source scripts/macros_4way.tcl

##########################################################################
# Placing 
##########################################################################
utl::report "Place Macros"
# routing channels between groups of side-by-side macros
set channelX    30.0
set channelXMin 15.0

# routing channels between macros on-top of eachother
set channelY    30.0
set channelYMin 15.0



##########################################################################
# Place axi_llc_data_ways data macro
##########################################################################
# First group placed in top-left corner

# LLC Way-0
set X [expr $floor_leftX]
set Y [expr $floor_topY - $RamSize2048x64_H]
placeInstance $axi_data_0 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_0

# LLC Way-1
set X [expr $X + $RamSize2048x64_W + $channelXMin]
set Y [expr $floor_topY - $RamSize2048x64_H]
placeInstance $axi_data_1 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_1

# Second group placed in top-right corner
# LLC Way-3
set X [expr $X + $RamSize2048x64_W + $channelXMin]
set Y [expr $floor_topY - $RamSize2048x64_H]
placeInstance $axi_data_3 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_3

# LLC Way-2
set X [expr $X + $RamSize2048x64_W + $channelXMin]
set Y [expr $floor_topY - $RamSize2048x64_H]
placeInstance $axi_data_2 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_data_2


##########################################################################
# Place axi_llc_hit_miss_unit tag macro
##########################################################################
# Tags go in the top-right

# three horizontal at the top
# axi_hitmiss_tag_2
set X [expr $floor_rightX - $RamSize256x48_H - 1.2*$channelX - $RamSize256x48_W]
set Y [expr $floor_topY - $RamSize256x48_H]
placeInstance $axi_hitmiss_tag_2 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_2

# axi_hitmiss_tag_1
set X [expr $X - $channelXMin - $RamSize256x48_W]
set Y [expr $Y]
placeInstance $axi_hitmiss_tag_1 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_1

# axi_hitmiss_tag_0
set X [expr $X - $channelXMin - $RamSize256x48_W]
set Y [expr $Y]
placeInstance $axi_hitmiss_tag_0 $X $Y R0
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_0

cut_rows -halo_width_y 1 -halo_width_x 7.5

# one rotated on the right-side
# axi_hitmiss_tag_3
set X [expr $floor_rightX - $RamSize256x48_H]
set Y [expr $floor_topY - $RamSize256x48_W]
placeInstance $axi_hitmiss_tag_3 $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $axi_hitmiss_tag_3


##########################################################################
# Place cva6_icache_tag
##########################################################################
# L1 Instr tags go on the left side at the bottom, above the I-cache data

# I-Cache way-0 tags
set X [expr $floor_leftX]
set Y [expr $floor_bottomY + 3*$channelY + 3*$RamSize256x64_H + $channelYMin + $RamSize256x64_W]
placeInstance $cva6_icache_tag_0 $X $Y R90
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_0

# I-Cache way-1 tags
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_icache_tag_1 $X $Y R90
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_1

# I-Cache way-2 tags
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_icache_tag_2 $X $Y R90
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_2

# I-Cache way-3 tags
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_icache_tag_3 $X $Y R90
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_tag_3

set dLineY [expr $Y + $RamSize256x48_W + $channelYMin]


##########################################################################
# Place cva6_icache_data
##########################################################################
# L1-Instruction cache goes into the bottom-left corner

# I-Cache way-0 data[127:64]
set X [expr $floor_leftX]
set Y [expr $floor_bottomY + 3*$channelY + 3*$RamSize256x64_H]
placeInstance $cva6_icache_data_0_high $X $Y R90
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_0_high

# I-Cache way-1 data[127:64]
set X [expr $floor_leftX ]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_1_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_1_high

# I-Cache way-2 data[127:64]
set X [expr $X ]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_icache_data_2_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_2_high

# I-Cache way-3 data[127:64]
set X [expr $X ]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_icache_data_3_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_3_high

# I-Cache way-0 data[63:0]
set X [expr $X + $RamSize256x64_W + 3.5*$channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_0_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $channelX $haloBlockT $cva6_icache_data_0_low

# I-Cache way-1 data[63:0]
set X [expr $X ]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_icache_data_1_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_1_low

# I-Cache way-2 data[63:0]
set X [expr $X + $RamSize256x64_W + 3*$channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_icache_data_2_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_2_low

# I-Cache way-3 data[63:0]
set X [expr $X ]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_icache_data_3_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_icache_data_3_low

# add_macro_blockage $macroMargin $cva6_icache_data_1_low $cva6_icache_data_0_high


##########################################################################
# Place cva6_wt_dcache_tag
##########################################################################
# L1 Data tags go on the right side (rotated) at the bottom

# D-Cache way-0 tag
set X [expr $floor_rightX - $RamSize256x48_H]
set Y [expr $floor_bottomY + 2*$channelYMin +2*$RamSize256x64_W]
placeInstance $cva6_wt_dcache_tag_0 $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_0

# D-Cache way-1 tag
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_wt_dcache_tag_1 $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_1

# D-Cache way-2 tag
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_wt_dcache_tag_2 $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_2

# D-Cache way-3 tag
set X [expr $X ]
set Y [expr $Y + $RamSize256x48_W + $channelYMin]
placeInstance $cva6_wt_dcache_tag_3 $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_tag_3


###########################################################################
# Place data sram 
########################################################################### 
# L1-Data cache goes at the bottom, next to the I-cache data

# D-Cache way-0 data[63:0]
set X [expr $floor_rightX - $RamSize256x64_H]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_0_low $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_0_low

# D-Cache way-0 data[127:64]
set X [expr $X]
set Y [expr $Y + $RamSize256x64_W + $channelYMin]
placeInstance $cva6_wt_dcache_data_0_high $X $Y R270
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_0_high


# D-Cache way-1 data[127:64]
set X [expr $floor_rightX - $RamSize256x64_H - $RamSize256x64_W - 3*$channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_1_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_1_high

# D-Cache way-1 data[63:0]
set X [expr $X]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_wt_dcache_data_1_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_1_low


# D-Cache way-2 data[127:64]
set X [expr $X - $RamSize256x64_W - 3*$channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_2_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_2_high

# D-Cache way-2 data[63:0]
set X [expr $X]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_wt_dcache_data_2_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_2_low


# D-Cache way-3 data[127:64]
set X [expr $X - $RamSize256x64_W - 3*$channelX]
set Y [expr $floor_bottomY]
placeInstance $cva6_wt_dcache_data_3_high $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_3_high

# D-Cache way-3 data[63:0]
set X [expr $X]
set Y [expr $Y + $RamSize256x64_H + $channelY]
placeInstance $cva6_wt_dcache_data_3_low $X $Y R180
addHaloToBlock $haloBlockL $haloBlockB $haloBlockR $haloBlockT $cva6_wt_dcache_data_3_low

#add_macro_blockage 0 $cva6_wt_dcache_data_1_high $cva6_wt_dcache_data_0_low


# the blockages on-top of the macro blocks do not remove the std-cell rows between them
# when using pdngen, so we cut them manually with an extra X-halo
cut_rows -halo_width_y 1 -halo_width_x 2


##########################################################################
# Place delay lines
##########################################################################
# delay lines after cut since they are essentially multi-row standard cells

if { ![info exists ::env(HYPER_CONF)] || $::env(HYPER_CONF) ne "NO_HYPERBUS"} {
  set dLineMaster  [[ord::get_db] findMaster "delay_line_D4_O1_6P000"]
  set dLineSize_H  [ord::dbu_to_microns [$dLineMaster getHeight]]

  # alternating power rails means it repeats after two site-heights, not one
  set doubleSite [expr 2 * $siteHeight]

  # starting distance from bottom of core in double-sites
  set dLineY_numSites [expr {ceil(($dLineY - $coreArea_bottomY) / $doubleSite)}]
  set dLineY2_numSites [expr {ceil($dLineSize_H / $doubleSite)} + $dLineY_numSites]
  # distance from bottom in microns (steps are multiples of double-sites)
  set dLineY_rounded  [expr $dLineY_numSites * $doubleSite + $coreArea_bottomY]
  set dLineY2_rounded  [expr $dLineY2_numSites * $doubleSite + $coreArea_bottomY]

  set X [expr $floor_leftX]
  # 785 cell-rows above first (bottom of core-area)
  placeInstance $delay_line_rx $X $dLineY_rounded  R0
  placeInstance $delay_line_tx $X $dLineY2_rounded R0
}