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

# floorplan -> Few seconds
utl::report "Create Floorplan"
if { [info exists ::env(L1CACHE_WAYS)] && $::env(L1CACHE_WAYS) eq "2"} {
    source scripts/floorplan_slabs_2way.tcl
} else {
    source scripts/floorplan_slabs.tcl
}
save_checkpoint ${proj_name}.floorplan
report_image "${proj_name}.floorplan" true

## power intent -> Few seconds
utl::report "Create Power Grid"
source scripts/power_grid_stripes.tcl
save_checkpoint ${proj_name}.power_grid
report_image "${proj_name}.power" true

# Used for estimate_parasitics
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal3


###############################################################################
# Restructure Netlist                                                         #
###############################################################################
utl::report "Repair tie fanout"
source scripts/repair_tie.tcl

report_metrics "${proj_name}.pre_opt_netlist"
# Dont touch IO pads as "remove_buffers" removes some of them
set_dont_touch [get_cells * -filter "ref_name == ixc013_i16x"]
set_dont_touch [get_cells * -filter "ref_name == ixc013_b16m"]
set_dont_touch [get_cells * -filter "ref_name == ixc013_b16mpup"]
# Dont use pads for buffering during repair_design
set_dont_use $dont_use_cells

utl::report "Remove buffers"
remove_buffers

# Hangs if placement density overlay is enabled or timing path
utl::report "Repair synth netlist"
repair_design -verbose
repair_timing -setup -repair_tns 80

puts "Repaired synth area"
report_design_area
report_worst_slack -min -digits 3
puts "Repaired synth wns"
report_worst_slack -max -digits 3
puts "Repaired synth tns"
report_tns -digits 3

file mkdir ${save_dir}/${proj_name}.restructure
restructure -target timing \
            -slack_threshold 5.0 \
            -liberty_file "../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib" \
            -tielo_port sg13g2_tielo/L_LO \
            -tiehi_port sg13g2_tiehi/L_HI \
            -work_dir ${save_dir}/${proj_name}.restructure

puts "Restructured area"
report_design_area
report_worst_slack -min -digits 3
puts "Restructured wns"
report_worst_slack -max -digits 3
puts "Restructured tns"
report_tns -digits 3

utl::report "Remove buffers"
remove_buffers
utl::report "Buffer ports"
buffer_ports
utl::report "Repair restructured netlist"
repair_design -verbose
repair_timing -setup -repair_tns 80

puts "Restructured and repaired area"
report_design_area
report_worst_slack -min -digits 3
puts "Restructured and repaired wns"
report_worst_slack -max -digits 3
puts "Restructured and repaired tns"
report_tns -digits 3

# Unset dont touch or repair_hold crashes
unset_dont_touch [get_cells * -filter "ref_name == ixc013_i16x"]
unset_dont_touch [get_cells * -filter "ref_name == ixc013_b16m"]
unset_dont_touch [get_cells * -filter "ref_name == ixc013_b16mpup"]
# Set dont touch for io nets -> repair_hold otherwise tries to insert hold buffer into that net
set_dont_touch [get_nets *_io]

report_metrics "${proj_name}.pre_place"
save_checkpoint ${proj_name}.pre_place


###############################################################################
# GLOBAL PLACEMENT                                                            #
###############################################################################
set GPL_ARGS {  -density 0.55
                -pad_left 1
                -pad_right 1 }
#                -timing_driven
#                -skip_initial_place }
# according to OR "on large designs" '-skip_initial_place' reduces the
# HPWL (half perimeter wire length) by roughly 5%

utl::report "Global Placement"
global_placement {*}$GPL_ARGS
report_metrics "${proj_name}.gpl"
report_image "${proj_name}.gpl" true true
save_checkpoint ${proj_name}.gpl

utl::report "Estimate parasitics"
estimate_parasitics -placement
utl::report "Repair design"
# needs to be after estimate_parasitics otherwise repair_design hangs
repair_design -max_utilization 100 -verbose
repair_timing -setup -repair_tns 80 -max_utilization 100

utl::report "Global Placement (2)"
global_placement {*}$GPL_ARGS
report_metrics "${proj_name}.gpl2"
report_image "${proj_name}.gpl2" true true
save_checkpoint ${proj_name}.gpl2



#############################################################################
# DETAILED PLACEMENT                                                        #
#############################################################################
# set_placement_padding -instances [get_cells *i_bootrom*] -right 3 -left 3
set DPL_ARGS {}
# set DPL_ARGS { -max_displacement {600 200} }

utl::report "Detailed placement"
detailed_placement {*}$DPL_ARGS
utl::report "Optimize mirroring"
optimize_mirroring

utl::report "Estimate parasitics"
estimate_parasitics -placement
report_metrics "${proj_name}.dpl"
save_checkpoint ${proj_name}.dpl
report_image "${proj_name}.dpl" true true

# repair_timing if report is still bad

###############################################################################
# CLOCK TREE SYNTHESIS                                                        #
###############################################################################
utl::report "Repair clock inverters"
repair_clock_inverters

utl::report "Clock Tree Synthesis"
set_wire_rc -clock -layer Metal4
clock_tree_synthesis -buf_list $ctsBuf -root_buf $ctsBufRoot \
                     -sink_clustering_enable \
                     -obstruction_aware

set_propagated_clock [all_clocks]

# Repair wire length between clock pad and clock-tree root
utl::report "Repair clock nets"
repair_clock_nets

# legalize cts cells
utl::report "Detailed placement"
detailed_placement {*}$DPL_ARGS
utl::report "Estimate parasitics"
estimate_parasitics -placement

# repair all setup timing
report_metrics "${proj_name}.cts_unrepaired"
# This may be too early to try hold fixing and will create unnecessary hold buffers
# We should wait until we have some routing info
# utl::report "Repair hold"
# repair_timing -hold -hold_margin 0.05 -repair_tns 80 -allow_setup_violations -max_utilization 75
utl::report "Repair setup"
repair_timing -setup -repair_tns 95 -max_utilization 100
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
# reduce routing resources (max utilization) of layers by 10%
# to spread out a bit more to other layers
set_global_routing_layer_adjustment Metal2-TopMetal2 0.10
set_routing_layers -signal Metal2-TopMetal2 -clock Metal2-TopMetal1

utl::report "Global route"
global_route -guide_file ${report_dir}/${proj_name}_route.guide \
    -congestion_report_file ${report_dir}/${proj_name}_congestion.rpt \
    -congestion_iterations 30 \
    -allow_congestion
# default params but -allow_congestion
# it goes on even if it didn't find a solution (may be able to fix afterwards)

# repair_antennas -iterations 5
# check_placement -verbose

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
    repair_design

    utl::report "GRT incremental..."
    # Running DPL to fix overlapped instances
    # Run to get modified net by DPL
    global_route -start_incremental
    detailed_placement
    # Route only the modified net by DPL
    global_route -end_incremental \
                -congestion_report_file ${report_dir}/congestion_repaired_initial.rpt \
                -allow_congestion
    report_metrics "${proj_name}.grt_repaired_initial"
    save_checkpoint ${proj_name}.grt_repaired_initial
    report_image "${proj_name}.grt_repair_initial" true true false true

    # Repair timing using global route parasitics
    utl::report "Repair setup and hold violations..."
    estimate_parasitics -global_routing
    repair_timing -setup -repair_tns 90 -max_utilization 100
    report_metrics "${proj_name}.grt_repaired_setup"
    save_checkpoint ${proj_name}.grt_repaired_setup

    estimate_parasitics -global_routing
    repair_timing -hold -hold_margin 0.05 -repair_tns 90 -allow_setup_violations -max_utilization 100 -verbose
    utl::report "Repair hold done"
    report_metrics "${proj_name}.grt_repaired_hold"
    save_checkpoint ${proj_name}.grt_repaired_hold
    report_image "${proj_name}.grt_hold_repair" true true false true

    utl::report "GRT incremental (2)..."
    # Running DPL to fix overlapped instances
    # Run to get modified net by DPL
    global_route -start_incremental
    detailed_placement
    # Route only the modified net by DPL
    global_route -end_incremental \
                -congestion_report_file ${report_dir}/congestion_repaired.rpt

    estimate_parasitics -global_routing
    report_metrics "${proj_name}.grt_repaired"
    save_checkpoint ${proj_name}.grt_repaired
    report_image "${proj_name}.grt_repaired" true true false true
}

# "No diode with LEF class CORE ANTENNACELL found"
# repair_antennas -iterations 5
# check_placement -verbose
# check_antennas -report_file ${report_dir}/antenna.log


utl::report "Detailed route"
detailed_route -output_drc ${report_dir}/${proj_name}_route_drc.rpt \
               -output_maze ${report_dir}${proj_name}_maze.log \
               -bottom_routing_layer Metal2 \
               -top_routing_layer TopMetal2 \
               -droute_end_iter 5 \
               -save_guide_updates \
               -verbose 1

report_metrics "${proj_name}.drt"
save_checkpoint ${proj_name}.drt
report_image "${proj_name}.drt" true false false true
report_design_area


# utl::report "Filler placement"
# filler_placement sg13g2_fill*
# utl::report "Check placement"
# check_placement
# report_metrics "${proj_name}.grt_repaired"
# save_checkpoint ${proj_name}.final
# report_image "${proj_name}.final" true true false true
# utl::report "Write DEF"
# write_def out/${proj_name}.final.def

# ## Def to GDS
# utl::report "Def to GDS"
# exec klayout -zz -rm scripts/def2stream.py
# set deltaT [expr [elapsed_run_time] - $time]
# set time [elapsed_run_time]
# utl::report "Time: $time sec deltaT: $deltaT"
