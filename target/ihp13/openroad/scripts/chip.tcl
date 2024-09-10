# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti      <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# The main OpenRoad chip flow

set proj_name $::env(PROJ_NAME)
set netlist $::env(NETLIST)
set top_design $::env(TOP_DESIGN)
set report_dir $::env(REPORTS)
set save_dir $::env(SAVE)
set pdk_dir $::env(PDK)
set time [elapsed_run_time]

set step_by_step_debug 0
set use_routing_repairs 1
set threads 32

source scripts/checkpoint.tcl
source scripts/reports.tcl

# initialize technology
set dzcockpit_dir "../../nonfree"
if {[file isdirectory $dzcockpit_dir] && [file exists ${dzcockpit_dir}/or_init_tech.tcl]} {
    source ${dzcockpit_dir}/or_init_tech.tcl
} else {
    source scripts/init_tech.tcl
} 

# read and check design
utl::report "Read netlist"
read_verilog $netlist
link_design $top_design

utl::report "Read constraints"
read_sdc src/basilisk.sdc

utl::report "Check constraints"
check_setup -verbose                                      > ${report_dir}/${proj_name}_checks.rpt
report_checks -unconstrained -format end -no_line_splits >> ${report_dir}/${proj_name}_checks.rpt
report_checks -format end -no_line_splits                >> ${report_dir}/${proj_name}_checks.rpt
report_checks -format end -no_line_splits                >> ${report_dir}/${proj_name}_checks.rpt

utl::report "Create Floorplan"
if { [info exists ::env(L1CACHE_WAYS)] && $::env(L1CACHE_WAYS) eq "2"} {
    source scripts/floorplan_ring_2way.tcl
} else {
    source scripts/floorplan_ring_4way.tcl
}
save_checkpoint ${proj_name}.floorplan
report_image "${proj_name}.floorplan" true

## power intent -> Few seconds
utl::report "Create Power Grid"
source scripts/power_grid_stripes.tcl
save_checkpoint ${proj_name}.power_grid
report_image "${proj_name}.power" true


###############################################################################
# Initial Repair Netlist                                                      #
###############################################################################
# Used for estimate_parasitics
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal4
# Dont touch IO pads as "remove_buffers" removes them otherwise
set_dont_touch [get_nets -of_objects [get_pins */PAD]]
set clock_nets [get_nets -of_objects [get_pins -of_objects "*_reg" -filter "name == CLK"]]
set_dont_touch $clock_nets
set_dont_use $dont_use_cells

utl::report "Repair tie fanout"
source scripts/repair_tie.tcl

utl::report "Remove buffers"
remove_buffers

# utl::report "Repair design"
# repair_design -verbose

report_metrics "${proj_name}.pre_place"
save_checkpoint ${proj_name}.pre_place


###############################################################################
# GLOBAL PLACEMENT                                                            #
###############################################################################
set_thread_count $threads

set GPL_ARGS {  -density 0.65 
                -routability_driven
                -routability_check_overflow 0.40
                -routability_inflation_ratio_coef 1.2
                -routability_max_inflation_ratio 1.2
                -max_phi_coef 1.04 }

set GPL2_ARGS {  -density 0.65
                -routability_driven
                -routability_check_overflow 0.60
                -routability_inflation_ratio_coef 1.2
                -routability_max_inflation_ratio 1.2
                -timing_driven
                -max_phi_coef 1.02 }
# check_overflow: Higher means routability starts being considered earlier in placement
#                 too early -> very dense regions, too late -> little to no effect
# inflation_ratio: By how much the virtual area of offending cells is increased
#                  this increases the calculated density they cause, reducing physical density
# target_rc_metric: probably influences strength of the wire-force attracting cells
#                   higher values cause more fluctuation in density (higher peaks), not necessarily bad

# rough placement to get parasitics for steiner-tree so we can run repair_timing
utl::report "Global Placement (1)"
global_placement {*}$GPL_ARGS
report_metrics "${proj_name}.gpl"
report_image "${proj_name}.gpl" true true
save_checkpoint ${proj_name}.gpl

utl::report "Estimate parasitics"
estimate_parasitics -placement
utl::report "Repair design"
save_checkpoint ${proj_name}.gpl_fix
repair_design -verbose
utl::report "Repair setup"
repair_timing -setup -skip_pin_swap -verbose -repair_tns 70

# old versions of repair_timing may swap non-equal pins, deactivated for now to avoid problems
# Likely introduced in:  https://github.com/The-OpenROAD-Project/OpenROAD/pull/3215

save_checkpoint ${proj_name}.gpl_repaired

# actual global placement
utl::report "Global Placement (2)"
global_placement {*}$GPL2_ARGS
report_metrics "${proj_name}.gpl2"
report_image "${proj_name}.gpl2" true true
save_checkpoint ${proj_name}.gpl2


#############################################################################
# DETAILED PLACEMENT                                                        #
#############################################################################
set DPL_ARGS {}

utl::report "Detailed placement"
detailed_placement {*}$DPL_ARGS
utl::report "Optimize mirroring"
optimize_mirroring

utl::report "Estimate parasitics"
estimate_parasitics -placement
report_metrics "${proj_name}.dpl"
save_checkpoint ${proj_name}.dpl
report_image "${proj_name}.dpl" true true


###############################################################################
# CLOCK TREE SYNTHESIS                                                        #
###############################################################################
unset_dont_touch $clock_nets
utl::report "Repair clock inverters"
repair_clock_inverters

utl::report "Clock Tree Synthesis"
set_wire_rc -clock -layer Metal4
clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot \
                     -sink_clustering_enable \
                     -obstruction_aware

# Repair wire length between clock pad and clock-tree root
utl::report "Repair clock nets"
repair_clock_nets

source src/basilisk_postcts.sdc

# legalize cts cells
utl::report "Detailed placement"
detailed_placement {*}$DPL_ARGS
utl::report "Estimate parasitics"
estimate_parasitics -placement

# repair all setup timing
report_metrics "${proj_name}.cts_unrepaired"


utl::report "Repair setup"
repair_timing -setup -skip_pin_swap -verbose -repair_tns 90
# place inserted cells
utl::report "Detailed placement"
detailed_placement {*}$DPL_ARGS
utl::report "Check placement"
check_placement -verbose

utl::report "Estimate parasitics"
estimate_parasitics -placement
report_cts -out_file ${report_dir}/${proj_name}.cts.rpt
report_metrics "${proj_name}.cts"
save_checkpoint ${proj_name}.cts
report_image "${proj_name}.cts" true false true


###############################################################################
# GLOBAL ROUTE                                                                #
###############################################################################
# reduce routing resources (max utilization) of lower layers by 20-35%
# to spread out a bit more to other layers
# OR strongly prefers routing with M2/M3 first and then when it
# eventually needs M4/M5 it probably struggles with finding space to drop down
# -> reduce M2 and M3 significantly
# also reduce TM1 as we do not want it to route there (bigger tracks etc)
set_global_routing_layer_adjustment Metal2-Metal3 0.30
set_global_routing_layer_adjustment TopMetal1 0.20
set_routing_layers -signal Metal2-TopMetal1 -clock Metal2-TopMetal1

utl::report "Global route"
global_route -guide_file ${report_dir}/${proj_name}_route.guide \
    -congestion_report_file ${report_dir}/${proj_name}_congestion.rpt \
    -congestion_iterations 80 \
    -allow_congestion
# default params but -allow_congestion
# it goes on even if it didn't find a solution (may be able to fix afterwards)

utl::report "Estimate parasitics"
estimate_parasitics -global_routing
report_metrics "${proj_name}.grt"
save_checkpoint ${proj_name}.grt
report_image "${proj_name}.grt" true false false true


###############################################################################
# REPAIR ROUTED TIMING                                                        #
###############################################################################
if { $use_routing_repairs } {
    grt::set_verbose 0
    # Repair design using global route parasitics
    utl::report "Perform buffer insertion..."
    repair_design -verbose

    utl::report "GRT incremental..."
    # Run to get modified net by DPL
    global_route -start_incremental
    # Running DPL to fix overlapped instances
    detailed_placement
    # Route only the modified net by DPL
    global_route -end_incremental \
                -congestion_report_file ${report_dir}/congestion_repaired_initial.rpt \
                -guide_file ${report_dir}/${proj_name}_route.guide \
                -verbose
    report_metrics "${proj_name}.grt_repaired_initial"
    save_checkpoint ${proj_name}.grt_repaired_initial
    report_image "${proj_name}.grt_repair_initial" true true false true

    # Repair timing using global route parasitics
    utl::report "Repair setup and hold violations..."
    estimate_parasitics -global_routing
    repair_timing -skip_pin_swap -recover_power 80 -verbose
    repair_timing -skip_pin_swap -setup -verbose -repair_tns 100
    repair_timing -skip_pin_swap -hold  -verbose -repair_tns 100

    report_metrics "${proj_name}.grt_repaired_timing"
    save_checkpoint ${proj_name}.grt_repaired_timing
    # report_image "${proj_name}.grt_repaired_timing" true true false true

    utl::report "GRT (2)..."
    # Running DPL to fix overlapped instances
    detailed_placement
    global_route -guide_file ${report_dir}/${proj_name}_route.guide \
        -congestion_report_file ${report_dir}/${proj_name}_congestion.rpt \
        -congestion_iterations 80
    estimate_parasitics -global_routing
    repair_timing -skip_pin_swap -hold -hold_margin 0.1 -verbose -repair_tns 100
    global_route -start_incremental
    # Running DPL to fix overlapped instances
    detailed_placement
    # Route only the modified net by DPL
    global_route -end_incremental \
                -congestion_report_file ${report_dir}/congestion_repaired_initial.rpt \
                -guide_file ${report_dir}/${proj_name}_route.guide \
                -verbose
    report_metrics "${proj_name}.grt_repaired"
    save_checkpoint ${proj_name}.grt_repaired
    report_image "${proj_name}.grt_repaired" true true false true
}

# Requires LEF cell with class 'CORE ANTENNACELL', otherwise you need to give a cell
repair_antennas
# check_antennas


utl::report "Detailed route"
set_thread_count $threads
detailed_route -output_drc ${report_dir}/${proj_name}_route_drc.rpt \
               -bottom_routing_layer Metal2 \
               -top_routing_layer TopMetal1 \
               -droute_end_iter 40 \
               -drc_report_iter_step 5 \
               -clean_patches \
               -save_guide_updates \
               -verbose 1

save_checkpoint ${proj_name}.drt
report_image "${proj_name}.drt" true false false true
report_design_area


utl::report "Filler placement"
filler_placement sg13g2_fill*
utl::report "Check placement"
check_placement
save_checkpoint ${proj_name}.final
report_image "${proj_name}.final" true true false true
utl::report "Write DEF"
write_def out/${proj_name}.final.def
