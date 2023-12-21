# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Power planning

utl::report "Power Grid"


##########################################################################
# Reset
##########################################################################

if {[info exists power_grid_defined]} {
    pdngen -ripup
    pdngen -reset
} else {
    set power_grid_defined 1
}

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

setLayerDirection Metal1 VERTICAL
setLayerDirection Metal2 HORIZONTAL
setLayerDirection Metal3 VERTICAL


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

# pads
add_global_connection -net {VDDIO} -inst_pattern {.*} -pin_pattern {VDDPAD} -power
add_global_connection -net {VSSIO} -inst_pattern {.*} -pin_pattern {VSSPAD} -ground

# connection
global_connect

# voltage domains
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}


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
set PowRingSpace  100
## Spacing must be larger than pitch of Top2
set pgcrSpacing 10
## Max width of Metal 2
set pgcrWidth 30
## Offset from Core to power ring
set pgcrOffset [expr ($PowRingSpace - $pgcrSpacing - 2 * $pgcrWidth) / 2]

# Macro Power Rings -> M1 and M2
## Spacing must be larger than pitch of M2
set mprSpacing 0.8
## Width
set mprWidth 0.52
## Offset from Macro to power ring
set mprOffset [expr $mprSpacing * 2]

# Core Top Power Grid
set tpgWidth 8
set tpgSpacing 16
set tpgPitch 120


##########################################################################
##  SRAM power rings
##########################################################################
proc sram_power { name macro mprWidth mprSpacing mprOffset} {
    # Macro Grid and Rings
    define_pdn_grid -macro -cells $macro -name ${name}_grid \
        -grid_over_boundary -voltage_domains {CORE}

    utl::report "test"
    add_pdn_ring -grid ${name}_grid \
        -layer        {Metal2 Metal3} \
        -widths       "$mprWidth $mprWidth" \
        -spacings     "$mprSpacing $mprSpacing" \
        -core_offsets "$mprOffset $mprOffset" \
        -add_connect
    utl::report "test2"
    add_pdn_stripe -grid ${name}_grid -layer {TopMetal1} -width {2.50} \
    #               -pitch {100} -offset {10} -extend_to_core_ring -starts_with POWER

    # Connection of Stripes on Macro to Macro Power Ring
    add_pdn_connect -grid ${name}_grid -layers {Metal2 TopMetal1}
    add_pdn_connect -grid ${name}_grid -layers {Metal3 TopMetal1}
    # Connection of Stripes on Macro to Macro Power Pins
    add_pdn_connect -grid ${name}_grid -layers {Metal4 TopMetal1}
    # Connection of Stripes on Macro to Core Power Stripes
    add_pdn_connect -grid ${name}_grid -layers {TopMetal1 TopMetal2}
}

# sram_power "sram0" "RM_IHPSG13_1P_64x64_c2_bm_bist"   $mprWidth $mprSpacing $mprOffset
# sram_power "sram1" "RM_IHPSG13_1P_256x64_c2_bm_bist"  $mprWidth $mprSpacing $mprOffset
# sram_power "sram2" "RM_IHPSG13_1P_1024x64_c2_bm_bist" $mprWidth $mprSpacing $mprOffset


##########################################################################
##  Core Power
##########################################################################

# standard cell grid and rings
define_pdn_grid -name {core_grid} -voltage_domains {CORE}

# M2 - M3
add_pdn_ring -grid {core_grid} \
   -layer        {Metal2 Metal3} \
   -widths       "$pgcrWidth $pgcrWidth" \
   -spacings     "$pgcrSpacing $pgcrSpacing" \
   -core_offsets "$pgcrOffset $pgcrOffset" \
   -add_connect

# Top 1 - Top 2
add_pdn_ring -grid {core_grid} \
   -layer        {TopMetal1 TopMetal2} \
   -widths       "$pgcrWidth $pgcrWidth" \
   -spacings     "$pgcrSpacing $pgcrSpacing" \
   -core_offsets "$pgcrOffset $pgcrOffset" \
   -add_connect                        \
   -connect_to_pads                    \
   -connect_to_pad_layers TopMetal2

# M1 Standardcell Rows
add_pdn_stripe -grid {core_grid} -layer {Metal1} -width {0.44} -offset {0} \
               -followpins -extend_to_core_ring

# Top power grid
# Top 2 Stripe
add_pdn_stripe -grid {core_grid} -layer {TopMetal2} -width $tpgWidth \
               -pitch $tpgPitch -spacing $tpgSpacing -offset {35.0} -extend_to_core_ring 
# Top 1 Stripe
add_pdn_stripe -grid {core_grid} -layer {TopMetal1} -width $tpgWidth \
               -pitch $tpgPitch -spacing $tpgSpacing -offset {30.0} -extend_to_core_ring

# The add_pdn_connect command is used to define which layers in the power grid are to be connected together. 
# During power grid generation, vias will be added for overlapping power nets and overlapping ground nets.
# M1 is declared vertical but tracks still horizontal
# adjacent layers (for Manhattan grid routing)
add_pdn_connect -grid {grid} -layers {Metal1 Metal2}
add_pdn_connect -grid {grid} -layers {Metal3 Metal4}
add_pdn_connect -grid {grid} -layers {Metal5 TopMetal1}
# horizontal M1 tracks to above verticals
add_pdn_connect -grid {grid} -layers {Metal1 Metal3}
add_pdn_connect -grid {grid} -layers {Metal1 Metal5}
add_pdn_connect -grid {grid} -layers {Metal1 TopMetal2}



##########################################################################
##  Generate
##########################################################################

pdngen


##########################################################################
##  Verification
##########################################################################

if { $verify } {
    set_pdnsim_net_voltage -net VDD -voltage 1.2
    set_pdnsim_net_voltage -net VSS -voltage 0
    check_power_grid -net VDD
    check_power_grid -net VSS
}
