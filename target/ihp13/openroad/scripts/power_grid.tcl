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

##########################################################################
# Global Connections
##########################################################################

# std cells
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS} -ground
# pads
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDEDWARDORE} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSSCORE} -ground
# rams
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDD!} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {VDDARRAY!} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {VSS!} -ground

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
    # Horizontal Macros
    define_pdn_grid -macro -cells $macro -name ${name}_h -orient {R0 R180 MX MY}\
        -grid_over_boundary -voltage_domains {CORE}

    add_pdn_ring -grid ${name}_h      \
        -layer        {Metal2 Metal3} \
        -widths       {0.52 0.52}     \
        -spacings     {0.80 0.80}     \
        -core_offsets {2.50 2.50}     \
        -add_connect

    add_pdn_stripe -grid ${name}_h -layer {Metal5} -width {2.50} -pitch {50} -offset {10} -extend_to_core_ring

    # Vertical Macros
    define_pdn_grid -macro -cells $macro -name ${name}_v -orient {R90 R270 MXR90 MYR90}\
        -grid_over_boundary -voltage_domains {CORE}

    add_pdn_ring -grid ${name}_v      \
        -layer        {Metal1 Metal2} \
        -widths       {0.52 0.52}     \
        -spacings     {0.80 0.80}     \
        -core_offsets {2.50 2.50}     \
        -add_connect

    add_pdn_stripe -grid ${name}_v -layer {TopMetal1} -width {2.50} -pitch {50} -offset {10} -extend_to_core_ring

    add_pdn_connect -grid ${name}_v -layers {Metal4 TopMetal1}
    add_pdn_connect -grid ${name}_v -layers {TopMetal1 TopMetal2}
}

sram_power "sram0" "RM_IHPSG13_1P_64x64_c2_bm_bist"
sram_power "sram1" "RM_IHPSG13_1P_256x64_c2_bm_bist"
sram_power "sram2" "RM_IHPSG13_1P_1024x64_c2_bm_bist"

##########################################################################
##  Core Power
##########################################################################

# standard cell grid and rings
define_pdn_grid -name {grid} -voltage_domains {CORE}

add_pdn_ring -grid {grid}         \
    -layer        {Metal2 Metal3} \
    -widths       {30 30}         \
    -spacings     {10 10}         \
    -core_offsets {25 25 25 25}   \
    -add_connect                  \
    -connect_to_pads              \
    -connect_to_pad_layers TopMetal2 \

add_pdn_ring -grid {grid}         \
    -layer        {Metal4 Metal5} \
    -widths       {30 30}         \
    -spacings     {10 10}         \
    -core_offsets {25 25 25 25}   \
    -add_connect                  \
    -connect_to_pads              \
    -connect_to_pad_layers TopMetal2

add_pdn_ring -grid {grid}               \
    -layer        {TopMetal1 TopMetal2} \
    -widths       {30 30}               \
    -spacings     {10 10}               \
    -core_offsets {25 25 25 25}         \
    -add_connect                        \
    -connect_to_pads                    \
    -connect_to_pad_layers TopMetal2

add_pdn_stripe -grid {grid} -layer {Metal1} -width {0.52} -pitch {3.52} -offset {0} -followpins -extend_to_core_ring
#add_pdn_stripe -grid {grid} -layer {TopMetal1} -width {10.0} -pitch {2000} -offset {500} -extend_to_core_ring

add_pdn_connect -grid {grid} -layers {Metal1 Metal2}
add_pdn_connect -grid {grid} -layers {Metal3 Metal4}
add_pdn_connect -grid {grid} -layers {Metal5 TopMetal1}
add_pdn_connect -grid {grid} -layers {Metal1 TopMetal1}

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
