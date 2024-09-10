# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>

# Automatic collection of SRAMs and delay-line macros
# Used for automatic macro placement
set macros [list]

set srams [get_cells *RM_IHP*]
foreach inst $srams {
    lappend macros $inst
}

set delay_lines [get_cells *i_delay_line*]
foreach inst $delay_lines {
    lappend macros $inst
}

# Macro names as produced by the yosys synthesis
# Used for manual macro placement

set CHESHIRE        i_iguana_soc.i_cheshire_soc
set CHS_L1_CACHE  	$CHESHIRE.gen_cva6_cores.__0.i_core_cva6/gen_cache_wt.i_cache_subsystem
set CHS_ICACHE 		$CHS_L1_CACHE.i_cva6_icache
set CHS_DCACHE 		$CHS_L1_CACHE.i_wt_dcache.i_wt_dcache_mem
set CHS_LLC_CACHE	$CHESHIRE.gen_llc.i_llc/i_axi_llc_top_raw
set HYPERBUS        i_iguana_soc.i_hyperbus

# CVA6 L1 I-Cache
# tag sram
set cva6_icache_tag_0   $CHS_ICACHE.gen_sram.__0.tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_icache_tag_1   $CHS_ICACHE.gen_sram.__1.tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_icache_tag_2   $CHS_ICACHE.gen_sram.__2.tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_icache_tag_3   $CHS_ICACHE.gen_sram.__3.tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut

# data sram
set cva6_icache_data_0_low   $CHS_ICACHE.gen_sram.__0.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_low
set cva6_icache_data_0_high  $CHS_ICACHE.gen_sram.__0.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_high

set cva6_icache_data_1_low   $CHS_ICACHE.gen_sram.__1.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_low
set cva6_icache_data_1_high  $CHS_ICACHE.gen_sram.__1.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_high

set cva6_icache_data_2_low   $CHS_ICACHE.gen_sram.__2.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_low
set cva6_icache_data_2_high  $CHS_ICACHE.gen_sram.__2.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_high

set cva6_icache_data_3_low   $CHS_ICACHE.gen_sram.__3.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_low
set cva6_icache_data_3_high  $CHS_ICACHE.gen_sram.__3.data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.gen_256x128xBx1.i_cut_high

# CVA6 L1 D-Cache (write-through)
# tag sram 
set cva6_wt_dcache_tag_0   $CHS_DCACHE.gen_tag_srams.__0.i_tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_wt_dcache_tag_1   $CHS_DCACHE.gen_tag_srams.__1.i_tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_wt_dcache_tag_2   $CHS_DCACHE.gen_tag_srams.__2.i_tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut
set cva6_wt_dcache_tag_3   $CHS_DCACHE.gen_tag_srams.__3.i_tag_sram.i_tc_sram.genblk2.genblk1.gen_256x45xBx1.i_cut

# data sram
set cva6_wt_dcache_data_0_low    $CHS_DCACHE.gen_data_banks.__0.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__0.i_cut
set cva6_wt_dcache_data_0_high   $CHS_DCACHE.gen_data_banks.__1.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__0.i_cut

set cva6_wt_dcache_data_1_low    $CHS_DCACHE.gen_data_banks.__0.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__1.i_cut
set cva6_wt_dcache_data_1_high   $CHS_DCACHE.gen_data_banks.__1.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__1.i_cut

set cva6_wt_dcache_data_2_low    $CHS_DCACHE.gen_data_banks.__0.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__2.i_cut
set cva6_wt_dcache_data_2_high   $CHS_DCACHE.gen_data_banks.__1.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__2.i_cut

set cva6_wt_dcache_data_3_low    $CHS_DCACHE.gen_data_banks.__0.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__3.i_cut
set cva6_wt_dcache_data_3_high   $CHS_DCACHE.gen_data_banks.__1.i_data_sram.i_tc_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_256x256xBx1.gen_cuts.__3.i_cut

# Cheshire Last-Level-Cache
# axi_llc_hit_miss_unit tag macro
set axi_hitmiss_tag_0	$CHS_LLC_CACHE.i_hit_miss_unit.i_tag_store.gen_tag_macros.__0.i_tag_store.gen_256x36xBx1.i_cut
set axi_hitmiss_tag_1	$CHS_LLC_CACHE.i_hit_miss_unit.i_tag_store.gen_tag_macros.__1.i_tag_store.gen_256x36xBx1.i_cut
set axi_hitmiss_tag_2	$CHS_LLC_CACHE.i_hit_miss_unit.i_tag_store.gen_tag_macros.__2.i_tag_store.gen_256x36xBx1.i_cut
set axi_hitmiss_tag_3	$CHS_LLC_CACHE.i_hit_miss_unit.i_tag_store.gen_tag_macros.__3.i_tag_store.gen_256x36xBx1.i_cut

# axi_llc_data_ways data macro
set axi_data_0          $CHS_LLC_CACHE.i_llc_ways.gen_data_ways.__0.i_data_way.i_data_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_2048x64xBx1.i_cut
set axi_data_1		    $CHS_LLC_CACHE.i_llc_ways.gen_data_ways.__1.i_data_way.i_data_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_2048x64xBx1.i_cut
set axi_data_2		    $CHS_LLC_CACHE.i_llc_ways.gen_data_ways.__2.i_data_way.i_data_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_2048x64xBx1.i_cut
set axi_data_3		    $CHS_LLC_CACHE.i_llc_ways.gen_data_ways.__3.i_data_way.i_data_sram.genblk2.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.genblk1.gen_2048x64xBx1.i_cut

# Hyberbus Delay Lines
set delay_line_tx	$HYPERBUS/genblk1.genblk1.i_delay_tx_clk_90.i_delay.i_delay_line
set delay_line_rx	$HYPERBUS/i_phy.genblk1.i_phy.i_trx.i_delay_rx_rwds_90.i_delay.i_delay_line
