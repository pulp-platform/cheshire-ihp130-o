# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Power planning

utl::report "Power Grid"
# ToDo: Check connectivity on left and right power pad cells

##########################################################################
# Reset
##########################################################################

if {[info exists power_grid_defined]} {
    pdngen -ripup
    pdngen -reset
} else {
    set power_grid_defined 1
}

# depending on the power grid this can be useful to change the direction of
# certain layers so it properly connects everywhere, don't forget to reset
# it at the end of this script!
proc setLayerDirection { name direction } {
    set tech [ord::get_db_tech]
    set layer [odb::dbTech_findLayer $tech $name]
    utl::report $name
    utl::report "Was:"
    utl::report [odb::dbTechLayer_getDirection $layer]
    odb::dbTechLayer_setDirection $layer $direction
    utl::report "Now:"
    utl::report [odb::dbTechLayer_getDirection $layer]
}

# setLayerDirection Metal1 HORIZONTAL


##########################################################################
# Global Connections
##########################################################################

# std cells
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS} -ground
# pads
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDCORE} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSSCORE} -ground
# rams
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDARRAY} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDARRAY!} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD!} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS!} -ground

# pads
add_global_connection -net {VDDIO} -inst_pattern {.*} -pin_pattern {VDDPAD} -power
add_global_connection -net {VSSIO} -inst_pattern {.*} -pin_pattern {VSSPAD} -ground

# connection
global_connect

# voltage domains
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}
# standard cell grid and rings
define_pdn_grid -name {core_grid} -voltage_domains {CORE}


##########################################################################
#  Settings
##########################################################################

# Verify connections
set verify 0


##########################################################################
##  Power settings
##########################################################################
# Core Power Ring
## Space between pads and core -> used for power ring
set PowRingSpace  110
## Spacing must be larger than pitch of TopMetal2
set pgcrSpacing 10
## Width must be within constraints for TopMetal2
set pgcrWidth 30
## Offset from Core to power ring
set pgcrOffset [expr ($PowRingSpace - $pgcrSpacing - 2 * $pgcrWidth) / 2]

# TopMetal Core Power Grid
set tpgWidth    16;  # arbitrary number
set tpgPitch   280;  # multiple of the x-axis pad-to-pad distance (140u)
set tpgSpacing  [expr $tpgPitch/2 - $tpgWidth];  # equally spaced

# Macro Power Rings -> M3 and M2
## Spacing must be larger than pitch of M2
set mprSpacing 2
## Width
set mprWidth 2
## Offset from Macro to power ring
set mprOffsetX 4
set mprOffsetY 2

# macro power grid (stripes on TopMetal1)
set mpgWidth 8
set mpgSpacing 8

##########################################################################
##  SRAM power rings
##########################################################################
proc sram_power { name macro } {
    global mprWidth mprSpacing mprOffsetX mprOffsetY mpgWidth mpgSpacing
    # Macro Grid and Rings
    define_pdn_grid -macro -cells $macro -name ${name}_grid \
        -grid_over_boundary -voltage_domains {CORE} \
        -halo {4 4}

    # TODO: Ring is usually not complete -> relying on stripes for power next to macros
    # Some sort of meta-macro-ring around an entire group of macros would be nice
    # power-ring around a larger blockage?
    add_pdn_ring -grid ${name}_grid \
        -layer        {Metal3 Metal4} \
        -widths       "$mprWidth $mprWidth" \
        -spacings     "$mprSpacing $mprSpacing" \
        -core_offsets "$mprOffsetX $mprOffsetY" \
        -add_connect

    # temporary, find out how to get sram-height properly
    set sram  [[ord::get_db] findMaster $macro]
    set sramHeight  [ord::dbu_to_microns [$sram getHeight]]
    set stripe_dist [expr $sramHeight - 12 - 2*$mpgWidth - $mpgSpacing]
    utl::report "stripe_dist of $macro: $stripe_dist"

    # for the large macros there is enough space for an additional stripe
    if {$stripe_dist > 170} {
        set stripe_dist [expr $stripe_dist/2]
    }

    add_pdn_stripe -grid ${name}_grid -layer {TopMetal1} -width $mpgWidth -spacing $mpgSpacing \
                   -pitch $stripe_dist -offset {12} -extend_to_core_ring -starts_with POWER -snap_to_grid

    # Connection of Macro Power Ring to standard-cell rails
    add_pdn_connect -grid ${name}_grid -layers {Metal4 Metal1}
    # Connection of Stripes on Macro to Macro Power Ring
    add_pdn_connect -grid ${name}_grid -layers {TopMetal1 Metal2}
    add_pdn_connect -grid ${name}_grid -layers {TopMetal1 Metal3}
    # Connection of Stripes on Macro to Macro Power Pins
    add_pdn_connect -grid ${name}_grid -layers {TopMetal1 Metal4}
    # Connection of Stripes on Macro to Core Power Stripes
    add_pdn_connect -grid ${name}_grid -layers {TopMetal2 TopMetal1}
}

##########################################################################
##  Core Power
##########################################################################

# M2 - M3 for easy connect to standard cell tracks
# TODO: when using this second ring it messes up the vias in the power-ring
# add_pdn_ring -grid {core_grid} \
#    -layer        {Metal2 Metal3} \
#    -widths       "$pgcrWidth $pgcrWidth" \
#    -spacings     "$pgcrSpacing $pgcrSpacing" \
#    -core_offsets "$pgcrOffset $pgcrOffset" \
#    -add_connect

# Top 1 - Top 2
add_pdn_ring -grid {core_grid} \
   -layer        {TopMetal1 TopMetal2} \
   -widths       "$pgcrWidth $pgcrWidth" \
   -spacings     "$pgcrSpacing $pgcrSpacing" \
   -core_offsets "$pgcrOffset $pgcrOffset" \
   -add_connect                        \
   -connect_to_pads                    \
   -connect_to_pad_layers TopMetal2

# M1 Standardcell Rows (tracks)
add_pdn_stripe -grid {core_grid} -layer {Metal1} -width {0.44} -offset {0} \
               -followpins -extend_to_core_ring

# Top power grid
# Top 2 Stripe
add_pdn_stripe -grid {core_grid} -layer {TopMetal2} -width $tpgWidth \
               -pitch $tpgPitch -spacing $tpgSpacing -offset {115} \
               -extend_to_core_ring

# Top 1 Stripe
# Deactivated to increase routing resources above/around macros (they occupy M1-M4)
# add_pdn_stripe -grid {core_grid} -layer {TopMetal1} -width $tpgWidth \
#                -pitch $tpgPitch -spacing $tpgSpacing -offset {30.0} -extend_to_core_ring

# "The add_pdn_connect command is used to define which layers in the power grid are to be connected together. 
#  During power grid generation, vias will be added for overlapping power nets and overlapping ground nets."
# M1 is declared vertical but tracks still horizontal
# vertical TopMetal2 to below horizonals (M1 has horizontal power tracks)
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal1}
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal2}
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal4}
# add_pdn_connect -grid {core_grid} -layers {TopMetal2 TopMetal1}
# Power-ring to power-ring connection
add_pdn_connect -grid {core_grid} -layers {TopMetal1 Metal2}
add_pdn_connect -grid {core_grid} -layers {TopMetal2 Metal3}
# Power-ring to standardcell rails
add_pdn_connect -grid {core_grid} -layers {Metal3 Metal1}
add_pdn_connect -grid {core_grid} -layers {Metal3 Metal2}


sram_power "sram_64x64"   "RM_IHPSG13_1P_64x64_c2_bm_bist"  
sram_power "sram_256x48"  "RM_IHPSG13_1P_256x48_c2_bm_bist" 
sram_power "sram_256x64"  "RM_IHPSG13_1P_256x64_c2_bm_bist" 
sram_power "sram_512x64"  "RM_IHPSG13_1P_512x64_c2_bm_bist" 
sram_power "sram_1024x64" "RM_IHPSG13_1P_1024x64_c2_bm_bist"
sram_power "sram_2048x64" "RM_IHPSG13_1P_2048x64_c2_bm_bist"

##########################################################################
##  Generate
##########################################################################

pdngen -failed_via_report ${report_dir}/${proj_name}_pdngen.rpt

# setLayerDirection Metal1 VERTICAL


##########################################################################
##  Verification
##########################################################################

if { $verify } {
    set_pdnsim_net_voltage -net VDD -voltage 1.2
    set_pdnsim_net_voltage -net VSS -voltage 0
    check_power_grid -net VDD
    check_power_grid -net VSS
}
