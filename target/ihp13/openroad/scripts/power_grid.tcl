puts "Power Grid"

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
    puts $name
    puts "Was:"
    puts [odb::dbTechLayer_getDirection $layer]
    odb::dbTechLayer_setDirection $layer $direction
    puts "Now:"
    puts [odb::dbTechLayer_getDirection $layer]
}

setLayerDirection Metal1 HORIZONTAL
setLayerDirection Metal2 VERTICAL
setLayerDirection Metal3 HORIZONTAL

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
##  Core Power
##########################################################################

proc sram_power { name macro } {
    # Macro Grid and Rings
    define_pdn_grid -macro -cells $macro -name ${name}_grid \
        -grid_over_boundary -voltage_domains {CORE}

    add_pdn_ring -grid ${name}_grid      \
        -layer        {Metal3 Metal2} \
        -widths       {0.52 0.52}     \
        -spacings     {0.80 0.80}     \
        -core_offsets {2.50 2.50}     \
        -add_connect

    add_pdn_stripe -grid ${name}_grid -layer {TopMetal1} -width {2.50} -pitch {100} -offset {10} -extend_to_core_ring -starts_with POWER

    # Connection of Stripes on Macro to Macro Power Ring
    add_pdn_connect -grid ${name}_grid -layers {Metal2 TopMetal1}
    add_pdn_connect -grid ${name}_grid -layers {Metal3 TopMetal1}
    # Connection of Stripes on Macro to Macro Power Pins
    add_pdn_connect -grid ${name}_grid -layers {Metal4 TopMetal1}
    # Connection of Stripes on Macro to Core Power Stripes
    add_pdn_connect -grid ${name}_grid -layers {TopMetal1 TopMetal2}
}

sram_power "sram0" "RM_IHPSG13_1P_64x64_c2_bm_bist"
sram_power "sram1" "RM_IHPSG13_1P_256x64_c2_bm_bist"
sram_power "sram2" "RM_IHPSG13_1P_1024x64_c2_bm_bist"

##########################################################################
##  Core Power
##########################################################################

# standard cell grid and rings
define_pdn_grid -name {grid} -voltage_domains {CORE}

# M2 - M3
#add_pdn_ring -grid {grid}         \
#    -layer        {Metal2 Metal3} \
#    -widths       {30 30}         \
#    -spacings     {10 10}         \
#    -core_offsets {15 15 15 15}   \
#    -add_connect                  \
#    -connect_to_pads              \
#    -connect_to_pad_layers TopMetal2

# M4 - M5
add_pdn_ring -grid {grid}         \
    -layer        {Metal4 Metal5} \
    -widths       {30 30}         \
    -spacings     {10 10}         \
    -core_offsets {15 15 15 15}   \
    -add_connect                  
#    -connect_to_pads              
#    -connect_to_pad_layers TopMetal2

# Top 1 - Top 2
#add_pdn_ring -grid {grid}               \
#    -layer        {TopMetal1 TopMetal2} \
#    -widths       {30 30}               \
#    -spacings     {10 10}               \
#    -core_offsets {15 15 15 15}         \
#    -add_connect                        \
#    -connect_to_pads                    \
#    -connect_to_pad_layers TopMetal2

# M1 Standardcell Rows
if {[info exists OPEN_CELLS]} {
    add_pdn_stripe -grid {grid} -layer {Metal1} -width {0.44} -offset {0} -followpins -extend_to_core_ring
} else {
    add_pdn_stripe -grid {grid} -layer {Metal1} -width {0.52} -offset {0} -followpins -extend_to_core_ring
}

# Top 2 Stripe - horizontal
add_pdn_stripe -grid {grid} -layer {TopMetal2} -width {8.0}  -pitch {300} -offset {65.00} -extend_to_core_ring
#-spacing {12} 
# Top 1 Stripe - vertical
#add_pdn_stripe -grid {grid} -layer {TopMetal1} -width {5.04} -pitch {200} -offset {5.25} -extend_to_core_ring
#-spacing {7.56} 
# M5 - horizontal
#add_pdn_stripe -grid {grid} -layer {Metal5} -width {0.84} -spacing {1.68} -pitch {168} -offset {6.93} -extend_to_core_ring

# M3 - horizontal
#add_pdn_stripe -grid {grid} -layer {Metal3} -width {0.42} -spacing {1.68} -pitch {168} -offset {0.63} -extend_to_core_ring

if {[info exists OPEN_CELLS]} {
    add_pdn_connect -grid {grid} -layers {Metal1 Metal2}
    add_pdn_connect -grid {grid} -layers {Metal1 Metal5}

    add_pdn_connect -grid {grid} -layers {Metal5 TopMetal1}
    add_pdn_connect -grid {grid} -layers {Metal1 TopMetal2}
    add_pdn_connect -grid {grid} -layers {Metal4 TopMetal2}
    add_pdn_connect -grid {grid} -layers {TopMetal1 TopMetal2}
    
    #add_pdn_connect -grid {grid} -layers {Metal3 TopMetal1}
} else {
    add_pdn_connect -grid {grid} -layers {Metal1 Metal2}
    add_pdn_connect -grid {grid} -layers {Metal3 Metal4}
    add_pdn_connect -grid {grid} -layers {Metal5 TopMetal1}
    add_pdn_connect -grid {grid} -layers {Metal1 TopMetal1}
    add_pdn_connect -grid {grid} -layers {Metal3 TopMetal1}
}

##########################################################################
##  Generate
##########################################################################

pdngen

setLayerDirection Metal1 VERTICAL
setLayerDirection Metal2 HORIZONTAL
setLayerDirection Metal3 VERTICAL

##########################################################################
##  Verification
##########################################################################

if { $verify } {
    set_pdnsim_net_voltage -net VDD -voltage 1.2
    set_pdnsim_net_voltage -net VSS -voltage 0
    check_power_grid -net VDD
    check_power_grid -net VSS
}
