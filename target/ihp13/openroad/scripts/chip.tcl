# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti      <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# The main OpenRoad chip flow

set DESIGN_NAME basilisk_yosys
set time [elapsed_run_time]

set step_by_step_debug 0
set routing_repairs 1
set_thread_count 16

source scripts/checkpoint.tcl
source scripts/reports.tcl

# initialize technology
source scripts/init_tech.tcl

# read and check design
puts "Read netlist"
read_verilog ../yosys/build/basilisk.yosys.v
link_design basilisk_chip

puts "Read constraints"
read_sdc -echo src/basilisk.sdc > reports/read_sdc.rpt

puts "Check constraints"
check_setup -verbose > reports/check_setup.rpt
report_checks -unconstrained -format end -no_line_splits > reports/report_checks_unconstrained.rpt
report_checks -format end -no_line_splits > reports/report_checks.rpt
report_check_types -max_slew -max_cap -max_fanout >> reports/report_checks.rpt

save_reports 0 "$DESIGN_NAME.initial"
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"

# floorplan -> Few seconds
puts "Create Floorplan"
source scripts/floorplan-ring.tcl
save_checkpoint $DESIGN_NAME.floorplan
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Floorplan"
    gui::pause
}

## power intent -> Few seconds
puts "Create Power Grid"
source scripts/power_grid_stripes.tcl
save_checkpoint $DESIGN_NAME.power_grid
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Power Grid"
    gui::pause
}


### Repair config 
# Dont touch IO pads as "remove_buffers" removes some of them
set_dont_touch [get_cells * -filter "ref_name == ixc013_i16x"]
set_dont_touch [get_cells * -filter "ref_name == ixc013_b16m"]
set_dont_touch [get_cells * -filter "ref_name == ixc013_b16mpup"]
# Dont use pads for buffering during repair_design
set_dont_use $dont_use_cells

# Used for estimate_parasitics
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal3

puts "Remove buffers"
remove_buffers
# Unset dont touch or repair_hold crashes
unset_dont_touch [get_cells * -filter "ref_name == ixc013_i16x"]
unset_dont_touch [get_cells * -filter "ref_name == ixc013_b16m"]
unset_dont_touch [get_cells * -filter "ref_name == ixc013_b16mpup"]
# Set dont touch for io nets -> repair_hold otherwise tries to insert hold buffer into that net
set_dont_touch [get_nets *_io]

#set_debug_level RSZ repair_net 3
save_reports 0 "$DESIGN_NAME.removed_buffers"
puts "Repair design"
repair_design -max_utilization 100
repair_timing
save_reports 0 "$DESIGN_NAME.preplace_repaired"

puts "Post synth-opt area"
report_design_area
report_worst_slack -min -digits 3
puts "Post synth-opt wns"
report_worst_slack -max -digits 3
puts "Post synth-opt tns"
report_tns -digits 3


###############################################################################
# GLOBAL PLACEMENT                                                            #
###############################################################################
set GPL_ARGS {  -density 0.65
                -pad_left 1
                -pad_right 1 }
#                -timing_driven
#                -skip_initial_place }
# according to OR "on large designs" '-skip_initial_place' reduces the
# HPWL (half perimeter wire length) by roughly 5%

puts "Global Placement"
global_placement {*}$GPL_ARGS

if { $step_by_step_debug } {
    puts "Pause after Global Placement"
    gui::pause
}


#############################################################################
# DETAILED PLACEMENT                                                        #
#############################################################################
set DPL_ARGS {}
# set DPL_ARGS { -max_displacement {600 200} }

puts "Buffer ports"
buffer_ports
# Hangs if placement density overlay is enabled or timing path
puts "Repair tie fanout"
source scripts/repair_tie.tcl

puts "Estimate parasitics"
estimate_parasitics -placement
puts "Repair design"
repair_design -max_utilization 100

puts "Detailed placement"
detailed_placement {*}$DPL_ARGS
puts "Optimize mirroring"
optimize_mirroring

puts "Estimate parasitics"
estimate_parasitics -placement
save_reports 0 "$DESIGN_NAME.placed"
save_checkpoint $DESIGN_NAME.placed
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Detailed Placement"
    gui::pause
}


###############################################################################
# CLOCK TREE SYNTHESIS                                                        #
###############################################################################
puts "Repair clock inverters"
repair_clock_inverters

puts "Clock Tree Synthesis"
set_wire_rc -clock -layer TopMetal1
clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot \
                     -sink_clustering_enable \
                     -obstruction_aware

set_propagated_clock [all_clocks]

# Repair wire length between clock pad and clock-tree root
puts "Repair clock nets"
repair_clock_nets

# legalize cts cells
puts "Detailed placement"
detailed_placement {*}$DPL_ARGS
puts "Estimate parasitics"
estimate_parasitics -placement

# repair all setup timing
save_reports 0 "$DESIGN_NAME.post_cts_unrepaired"
puts "Repair hold"
repair_timing -hold -hold_margin 0.05 -repair_tns 70 -allow_setup_violations -max_utilization 100
puts "Repair setup"
repair_timing -hold -repair_tns 70 -max_utilization 100
# place inserted cells
puts "Detailed placement"
detailed_placement {*}$DPL_ARGS
puts "Check placement"
check_placement -verbose

puts "Estimate parasitics"
estimate_parasitics -placement
save_reports 0 "$DESIGN_NAME.post_cts"
save_checkpoint $DESIGN_NAME.post_cts
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Clock Tree Synthesis"
    gui::pause
}


###############################################################################
# GLOBAL ROUTE                                                                #
###############################################################################
# reduce routing resources (max utilization) of layers by 10%
# to spread out a bit more to other layers
set_global_routing_layer_adjustment Metal1-TopMetal2 0.10
set_routing_layers -signal Metal2-TopMetal2 -clock Metal2-TopMetal1

puts "Global route"
global_route -guide_file reports/route.guide \
    -congestion_report_file reports/congestion.rpt \
    -congestion_iterations 30 \
    -allow_congestion
# default params but -allow_congestion
# it goes on even if it didn't find a solution (may be able to fix afterwards)

repair_antennas -iterations 5
check_placement -verbose

puts "Estimate parasitics"
estimate_parasitics -global_routing
save_reports 0 "$DESIGN_NAME.global_route"
save_checkpoint $DESIGN_NAME.global_route
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Global Routing"
    gui::pause
}

###############################################################################
# REPAIR ROUTED TIMING                                                        #
###############################################################################
if { $routing_repairs } {
    grt::set_verbose 0
    puts "Repair setup"
    repair_timing -setup -repair_tns 80 -max_utilization 100
    estimate_parasitics -global_routing
    save_reports 0 "$DESIGN_NAME.global_route_setup_repaired"
    save_checkpoint $DESIGN_NAME.global_route

    puts "Repair hold"
    repair_timing -hold -hold_margin 0.05 -repair_tns 80 -allow_setup_violations -max_utilization 100 -verbose
    puts "Repair hold done"
    estimate_parasitics -global_routing
    #save_reports 0 "$DESIGN_NAME.global_route_hold_repaired"

    puts "Repair design"
    repair_design -max_utilization 100
    # -cap_margin 0.02
    # place inserted cells
    puts "Detailed placement"
    detailed_placement {*}$DPL_ARGS
    puts "Check placement"
    check_placement -verbose

    # Final global routing
    puts "Global route"
    global_route -guide_file reports/route_repair.guide \
                -congestion_report_file reports/congestion_repair.rpt \
                -congestion_iterations 30 \
                -allow_congestion
    
    puts "Estimate parasitics"
    estimate_parasitics -global_routing
    save_reports 1 "$DESIGN_NAME.global_route_repaired"
    save_checkpoint $DESIGN_NAME.routing_repairs
    set deltaT [expr [elapsed_run_time] - $time]
    set time [elapsed_run_time]
    puts "Time: $time sec deltaT: $deltaT"
    if { $step_by_step_debug } {
        puts "Pause after Routing Repairs"
        gui::pause
    }
}

# "No diode with LEF class CORE ANTENNACELL found"
# repair_antennas -iterations 5
# check_placement -verbose
# check_antennas -report_file reports/antenna.log


puts "Detailed route"
detailed_route -output_drc reports/route_drc.rpt \
               -output_maze reports/maze.log \
               -bottom_routing_layer Metal1 \
               -top_routing_layer TopMetal2 \
               -droute_end_iter 15 \
               -verbose 1
# save_checkpoint $DESIGN_NAME.drt_iter15
# save_reports 1 "$DESIGN_NAME.drt_iter15"

detailed_route -output_drc reports/route_drc2.rpt \
               -output_maze reports/maze2.log \
               -bottom_routing_layer Metal1 \
               -top_routing_layer TopMetal2 \
               -droute_end_iter 30 \
               -save_guide_updates \
               -verbose 1

save_reports 1 "$DESIGN_NAME.routed"
save_checkpoint $DESIGN_NAME.routed
report_design_area
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Detailed Routing"
    gui::pause
}


puts "Filler placement"
filler_placement sg13g2_fill*
puts "Check placement"
check_placement
save_checkpoint $DESIGN_NAME.final
puts "Write DEF"
write_def out/$DESIGN_NAME.final.def
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"

### Def to GDS
# puts "Def to GDS"
# exec klayout -zz -rm scripts/def2stream.py
# set deltaT [expr [elapsed_run_time] - $time]
# set time [elapsed_run_time]
# puts "Time: $time sec deltaT: $deltaT"
