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

ICeWall::load_footprint src/iguana.package.strategy

initialize_floorplan \
  -die_area  [ICeWall::get_die_area] \
  -core_area [ICeWall::get_core_area] \
  -site      CoreSite

ICeWall::init_footprint src/iguana.sigmap

##########################################################################
# Tracks 
##########################################################################

make_tracks Metal1    -x_offset 0.21 -x_pitch 0.42 -y_offset 0.21 -y_pitch 0.42
make_tracks Metal2    -x_offset 0.21 -x_pitch 0.42 -y_offset 0.21 -y_pitch 0.42
make_tracks Metal3    -x_offset 0.21 -x_pitch 0.42 -y_offset 0.21 -y_pitch 0.42
make_tracks Metal4    -x_offset 0.21 -x_pitch 0.42 -y_offset 0.21 -y_pitch 0.42
make_tracks Metal5    -x_offset 0.21 -x_pitch 0.42 -y_offset 0.21 -y_pitch 0.42
make_tracks TopMetal1 -x_offset 1.64 -x_pitch 2.28 -y_offset 1.64 -y_pitch 2.28
make_tracks TopMetal2 -x_offset 2.00 -x_pitch 4.00 -y_offset 2.00 -y_pitch 4.00

##########################################################################
# Placing macros
##########################################################################

proc placeInstance { name x y orient } {
  set block [ord::get_db_block]
  set inst [odb::dbBlock_findInst $block $name]
  odb::dbInst_setPlacementStatus $inst "none"
  odb::dbInst_setOrient $inst $orient
  odb::dbInst_setLocation $inst [ord::microns_to_dbu $x] [ord::microns_to_dbu $y]
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

  odb::dbBlockage_create [ord::get_db_block] $minx $miny $maxx $maxy
  #set tech [ord::get_db_tech]
  #set layer [odb::dbTech_findRoutingLayer $tech 5]
  #odb::dbObstruction_create [ord::get_db_block] $layer $minx $miny $maxx $maxy
  #set layer [odb::dbTech_findRoutingLayer $tech 6]
  #odb::dbObstruction_create [ord::get_db_block] $layer $minx $miny $maxx $maxy
  #set layer [odb::dbTech_findRoutingLayer $tech 7]
  #odb::dbObstruction_create [ord::get_db_block] $layer $minx $miny $maxx $maxy
}

# cva6_icache
# tag sram
set cva6_icache_tag_0   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_0__tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist
set cva6_icache_tag_1   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_1__tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist
set cva6_icache_tag_2   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_2__tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist
set cva6_icache_tag_3   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_3__tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist

# data sram
set cva6_icache_data_0_low   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_0__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low
set cva6_icache_data_1_low   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_1__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low 
set cva6_icache_data_2_low   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_2__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low
set cva6_icache_data_3_low   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_3__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low 
set cva6_icache_data_0_high  i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_0__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high
set cva6_icache_data_1_high  i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_1__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high 
set cva6_icache_data_2_high  i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_2__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high 
set cva6_icache_data_3_high  i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_cva6_icache/gen_sram_3__data_sram/i_tc_sram/gen_256x128xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high


# cva6_wt_edwardache
# tag sram 
set cva6_wt_edwardache_tag_3   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_tag_srams_3__i_tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 
set cva6_wt_edwardache_tag_2   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_tag_srams_2__i_tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 
set cva6_wt_edwardache_tag_1   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_tag_srams_1__i_tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 
set cva6_wt_edwardache_tag_0   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_tag_srams_0__i_tag_sram/i_tc_sram/gen_256x45xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 

# data sram 
set cva6_wt_edwardache_data_3_high   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_0__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_3
set cva6_wt_edwardache_data_3_low    i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_0__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_2
set cva6_wt_edwardache_data_2_high   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_0__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_1
set cva6_wt_edwardache_data_2_low    i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_0__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_0
set cva6_wt_edwardache_data_1_high   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_1__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_3
set cva6_wt_edwardache_data_1_low    i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_1__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_2
set cva6_wt_edwardache_data_0_high   i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_1__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_1
set cva6_wt_edwardache_data_0_low    i_iguana/i_cheshire_soc/i_core_cva6/genblk3_i_cache_subsystem/i_wt_edwardache/i_wt_edwardache_mem/gen_data_banks_1__i_data_sram/i_tc_sram/gen_256x256xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_0

# axi_llc_hit_miss_unit tag macro
set axi_hitmiss_tag_3   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros_3__i_tag_store/gen_256x36xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 
set axi_hitmiss_tag_2   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros_2__i_tag_store/gen_256x36xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist
set axi_hitmiss_tag_1   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros_1__i_tag_store/gen_256x36xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 
set axi_hitmiss_tag_0   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros_0__i_tag_store/gen_256x36xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist 


# axi_llc_data_ways data macro
set axi_data_3_high   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_3__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high 
set axi_data_3_low    i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_3__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low 
set axi_data_2_high   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_2__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high 
set axi_data_2_low    i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_2__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low
set axi_data_1_high   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_1__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high
set axi_data_1_low    i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_1__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low 
set axi_data_0_high   i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_0__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_high 
set axi_data_0_low    i_iguana/i_cheshire_soc/gen_llc_i_llc/i_axi_llc_top_raw/i_llc_ways/gen_data_ways_0__i_data_way/i_data_sram/gen_2048x64xBx1_i_RM_IHPSG13_1P_256x64_c2_bm_bist_low


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
set floorW                 6000.0
set floorH                 6000.0
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
set X [ expr 6000 - $sram_initX_L - $RamSize1024_H ]
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

#set channel 100.0
#set channel_no_cell 200
#set channel_hori  30.0
#set channel_vert  30.0


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

set channel 140.0
set channel_hori  10.0
set channel_vert  0.0

# cva6_wt_edwardache_data_3_high
set X [ expr $sram_initX_L ]
set Y [ expr $sram_initY256_T - 900 ]
placeInstance  $cva6_wt_edwardache_data_3_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_3_high


# cva6_wt_edwardache_data_3_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_data_3_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_3_low


# cva6_wt_edwardache_data_2_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_edwardache_data_2_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_2_high


# cva6_wt_edwardache_data_2_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_data_2_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_2_low


# cva6_wt_edwardache_data_1_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_edwardache_data_1_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_1_high


# cva6_wt_edwardache_data_1_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_data_1_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_1_low


# cva6_wt_edwardache_data_0_high
set X [ expr $sram_initX_L ]
set Y [ expr $Y - $RamSize256_W - 2*$haloBlock - $channel_vert ]
placeInstance  $cva6_wt_edwardache_data_0_high $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_0_high


# cva6_wt_edwardache_data_0_low
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_data_0_low $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_data_0_low


##########################################################################
# Place cva6_wt_edwardache_tag
##########################################################################

set channel 140.0
set channel_hori  10.0
set channel_vert  0.0


# cva6_wt_edwardache_tag_3
set X [ expr $sram_initX_L ]
set Y [ expr $sram_initY256_T ]
placeInstance  $cva6_wt_edwardache_tag_3 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_tag_3


# cva6_wt_edwardache_tag_2
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_tag_2 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_tag_2


# cva6_wt_edwardache_tag_1
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel_hori ]
set Y $Y
placeInstance  $cva6_wt_edwardache_tag_1 $X $Y R90
addHaloToBlock $haloBlock $cva6_wt_edwardache_tag_1


# cva6_wt_edwardache_tag_0
set X [ expr $X + $RamSize256_H + 2*$haloBlock + $channel ]
set Y $Y
placeInstance  $cva6_wt_edwardache_tag_0 $X $Y MXR90
addHaloToBlock $haloBlock $cva6_wt_edwardache_tag_0


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