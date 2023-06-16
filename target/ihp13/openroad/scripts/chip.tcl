set DESIGN_NAME iguana_yosys
set time [elapsed_run_time]

set step_by_step_debug 0
set routing_repairs 1

source scripts/checkpoint.tcl
source scripts/reports.tcl

# initialize technology
source scripts/init_tech.tcl

# read and check design
puts "Read netlist"
read_verilog ../yosys/build/iguana_chip_yosys_blackboxed.v
link_design iguana_chip__6142509188972423790

puts "Read constraints"
read_sedward src/iguana.sedward

puts "Check constraints"
check_setup
save_reports 0 "$DESIGN_NAME.initial"
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"

# floorplan -> Few seconds
source scripts/yosys_macros.tcl
source scripts/floorplan.tcl
save_checkpoint $DESIGN_NAME.floorplan
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Floorplan"
    gui::pause
}

## power intent -> Few seconds
source scripts/power_grid.tcl
save_checkpoint $DESIGN_NAME.power_grid
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Power Grid"
    gui::pause
}

#Add Placement blockage
proc add_macro_blockage {negative_padding name1 name2} {
  set block [ord::get_db_block]
  set inst1 [odb::dbBlock_findInst $block $name1]
  set inst2 [odb::dbBlock_findInst $block $name2]
  set bb1 [odb::dbInst_getBBox $inst1]
  set bb2 [odb::dbInst_getBBox $inst2]
  # Find min max of X and Y
  set minx [expr min( [odb::dbBox_xMin $bb1], [odb::dbBox_xMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set miny [expr min( [odb::dbBox_yMin $bb1], [odb::dbBox_yMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set maxx [expr max( [odb::dbBox_xMax $bb1], [odb::dbBox_xMax $bb2]) - [ord::microns_to_dbu $negative_padding]]
  set maxy [expr max( [odb::dbBox_yMax $bb1], [odb::dbBox_yMax $bb2]) - [ord::microns_to_dbu $negative_padding]]

  set blockage [odb::dbBlockage_create [ord::get_db_block] $minx $miny $maxx $maxy]
  return $blockage
}

add_macro_blockage 0 $axi_hitmiss_tag_1 $axi_hitmiss_tag_2
add_macro_blockage 0 $axi_hitmiss_tag_3 $axi_data_3_high
add_macro_blockage 0 $axi_data_3_low $axi_data_2_high
add_macro_blockage 0 $axi_data_2_low $axi_data_1_high
add_macro_blockage 0 $axi_data_1_low $axi_data_0_high

add_macro_blockage 0 $cva6_wt_edwardache_data_3_high $cva6_wt_edwardache_data_0_high
add_macro_blockage 0 $cva6_wt_edwardache_data_3_low $cva6_wt_edwardache_data_0_low

add_macro_blockage 0 $cva6_wt_edwardache_tag_2 $cva6_wt_edwardache_tag_1
add_macro_blockage 0 $cva6_wt_edwardache_tag_0 $cva6_icache_tag_0
add_macro_blockage 0 $cva6_icache_tag_1 $cva6_icache_tag_2
add_macro_blockage 0 $cva6_icache_tag_3 $cva6_icache_data_3_high
add_macro_blockage 0 $cva6_icache_data_3_low $cva6_icache_data_2_high
add_macro_blockage 0 $cva6_icache_data_2_low $cva6_icache_data_1_high
add_macro_blockage 0 $cva6_icache_data_1_low $cva6_icache_data_0_high

#gui::pause

cut_rows -halo_width_y 5 -halo_width_x 5

### Repair config 
# Dont touch IO pads as "remove_buffers" removes some of them
set_dont_touch [get_cells -hierarchical -filter "ref_name == spongebob"]
set_dont_touch [get_cells -hierarchical -filter "ref_name == ixc013_i16m"]
set_dont_touch [get_cells -hierarchical -filter "ref_name == sandypup"]
# Dont use pads for buffering during repair_design
set_dont_use $dont_use_cells

# Used for estimate_parasitics
set_wire_rc -clock -layer Metal4
set_wire_rc -signal -layer Metal3

puts "Remove buffers"
remove_buffers
# Unset dont touch or repair_hold crashes
unset_dont_touch [get_cells -hierarchical -filter "ref_name == spongebob"]
unset_dont_touch [get_cells -hierarchical -filter "ref_name == ixc013_i16m"]
unset_dont_touch [get_cells -hierarchical -filter "ref_name == sandypup"]
# Set dont touch for io nets -> repair_hold otherwise tries to insert hold buffer into that net
set_dont_touch [get_nets *_io]

#set_debug_level RSZ repair_net 3
save_reports 0 "$DESIGN_NAME.removed_buffers"
puts "Repair design"
repair_design -max_utilization 100
save_reports 0 "$DESIGN_NAME.preplace_repaired"

set_placement_padding -instances [get_cells *i_bootrom*] -right 5 -left 5
set_placement_padding -instances [get_cells *float_regfile_gen.gen_asic_fp_regfile.i_ariane_fp_regfile*] -right 7 -left 7
set_placement_padding -instances [get_cells *gen_asic_regfile.i_ariane_regfile*] -right 7 -left 7
set_placement_padding -instances [get_cells *i_scoreboard*] -right 5 -left 5
set_placement_padding -instances [get_cells *i_multiplier*] -right 5 -left 5
#Hotspots: Bootrom, Regfiles, Scoreboard, Multiplier

puts "Global Placement"
global_placement \
    -density 0.70 \
    -pad_left 1 \
    -pad_right 1

if { $step_by_step_debug } {
    puts "Pause after Global Placement"
    gui::pause
}

puts "Buffer ports"
buffer_ports
# Hangs if placement density overlay is enabled or timing path
puts "Repair tie fanout"
source scripts/repair_tie.tcl

puts "Estimate parasitics"
estimate_parasitics -placement
#repair_design -max_wire_length 1000
puts "Repair design"
repair_design -max_utilization 100

puts "Detailed placement"
detailed_placement
#improve_placement
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

#### cts -> Takes forever with 14 buffers ca. 2.5h

puts "Repair clock inverters"
repair_clock_inverters

puts "Clock Tree Synthesis"
set_wire_rc -clock -layer TopMetal1
clock_tree_synthesis -root_buf $ctsBuf -buf_list $ctsBuf \
                     -sink_clustering_enable \
                     -sink_clustering_size 8 \
                     -sink_clustering_max_diameter 100 \
                     -balance_levels

set_propagated_clock [all_clocks]

# Repair wire length between clock pad and clock-tree root
puts "Repair clock nets"
repair_clock_nets

# legalize cts cells
puts "Detailed placement"
detailed_placement
puts "Estimate parasitics"
estimate_parasitics -placement

# repair all setup timing
save_reports 0 "$DESIGN_NAME.post_cts_unrepaired"
puts "Repair setup"
repair_timing -setup -repair_tns 100 -max_utilization 100
# place inserted cells
puts "Detailed placement"
detailed_placement
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

#### global routing -> Few seconds
set_global_routing_layer_adjustment Metal1-TopMetal2 0.0
set_routing_layers -signal Metal2-TopMetal2 -clock Metal2-TopMetal2

puts "Global route"
global_route -guide_file reports/route.guide \
    -congestion_report_file reports/congestion.rpt \
    -congestion_iterations 20 \
    -allow_congestion \
    -verbose

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

if { $routing_repairs } {
    grt::set_verbose 0
    puts "Repair setup"
    repair_timing -setup -repair_tns 100 -max_utilization 100
    #repair_timing -setup -repair_tns 100 -max_utilization 100
    #repair_timing -setup -repair_tns 100 -max_utilization 100
    estimate_parasitics -global_routing
    save_reports 0 "$DESIGN_NAME.global_route_setup_repaired"
    puts "Repair hold"
    repair_timing -hold -allow_setup_violations -max_buffer_percent 100 -max_utilization 100 -hold_margin 0.2
    estimate_parasitics -global_routing
    save_reports 1 "$DESIGN_NAME.global_route_hold_repaired"
    puts "Repair design"
    repair_design -max_utilization 100
    # -cap_margin 0.02
    # place inserted cells
    puts "Detailed placement"
    detailed_placement
    puts "Check placement"
    check_placement -verbose

    # Final Global Routing with inserted cells
    puts "Global route"
    global_route -guide_file route.guide \
        -congestion_report_file congestion.rpt \
        -congestion_iterations 20 \
        -allow_congestion \
        -verbose
    
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
# Prints whole report to console -> Slow
#check_antennas -report_file antenna_post_route.log
#repair_antennas ANTENNACELLN2JI
#check_antennas -report_file antenna_final.log

### detail route
set_propagated_clock [all_clocks]
set_thread_count 8

puts "Detailed route"
detailed_route -output_drc reports/route_drc.rpt \
               -output_maze reports/maze.log \
               -bottom_routing_layer Metal1 \
               -top_routing_layer TopMetal2 \
               -save_guide_updates \
               -verbose 1

save_checkpoint $DESIGN_NAME.routed
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"

save_reports 1 "$DESIGN_NAME.routed"
report_design_area
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
if { $step_by_step_debug } {
    puts "Pause after Detailed Routing"
    gui::pause
}

exit

puts "Filler placement"
filler_placement "FEED1JI FEED2JI FEED3JI FEED5JI FEED10JI FEED25JI"
puts "Check placement"
check_placement
save_checkpoint $DESIGN_NAME.final
puts "Write DEF"
write_def out/$DESIGN_NAME.final.def
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"

### Def to GDS
puts "Def to GDS"
exec klayout -zz -rm scripts/def2stream.py
set deltaT [expr [elapsed_run_time] - $time]
set time [elapsed_run_time]
puts "Time: $time sec deltaT: $deltaT"
