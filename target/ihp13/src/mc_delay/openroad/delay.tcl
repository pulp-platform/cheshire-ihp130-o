# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Authors:
#  - Thomas Benz <tbenz@iis.ee.ethz.ch>

# ToDo: Timing should be on point, it fixes slack too much
#       -> check window-constraint, maybe add hold-margin and relax slack-margin?

# flow parameters
if {![info exists ::env(DESIGN_NAME)]} {
    set DESIGN_NAME delay_line_D4_O1_6P000
} else {
    set DESIGN_NAME $::env(DESIGN_NAME)
}

set pdk_dir ../../../pdk/ihp-sg13g2/ihp-sg13g2/libs.ref/sg13g2_stdcell

exec mkdir -p reports

# lib
define_corners tt
read_liberty -corner tt ${pdk_dir}/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_lef ${pdk_dir}//lef/sg13g2_tech.lef
read_lef ${pdk_dir}//lef/sg13g2_stdcell.lef


# read netlist
read_verilog ${DESIGN_NAME}.v
link_design ${DESIGN_NAME}

read_sdc delay_line_D4_O1_6P000.sdc


set ASPECT 2.0
set UTIL 80
set DENSITY [expr (1.0*$UTIL)/100]

# --- TRIAL PLACEMENT ---
# creates an oversized floorplan to repair netlist so we can get post-repair design-area
initialize_floorplan -utilization [expr $UTIL/3] -aspect_ratio $ASPECT -site CoreSite -core_space 0

# initialize tracks
make_tracks Metal1    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal2    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal3    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal4    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks Metal5    -x_offset 0 -x_pitch 0.48 -y_offset 0 -y_pitch 0.42
make_tracks TopMetal1 -x_offset 1.64 -x_pitch 3.28 -y_offset 1.64 -y_pitch 3.28
make_tracks TopMetal2 -x_offset 2.00 -x_pitch 4.00 -y_offset 2.00 -y_pitch 4.00

set_wire_rc -signal -layer Metal3
set_wire_rc -clock  -layer Metal3

# global placement
# low final overflow so global-place actually solves it instead of detailed_placement
global_placement -density $DENSITY -skip_io -routability_driven -overflow 0.00000001
detailed_placement
optimize_mirroring

estimate_parasitics -placement
repair_design -max_utilization 100
repair_timing -setup -repair_tns 100
repair_timing -hold  -repair_tns 100

# detail placement
detailed_placement
optimize_mirroring

# --- TRIAL PLACEMENT COMPLETED ---

# properly resize floorplan to achieve target utilization
set area [sta::format_area [rsz::design_area] 0]
set area [expr $area / $DENSITY]

set block      [ord::get_db_block]
set first_row  [lindex [$block getRows] 0]
set row_site   [$first_row getSite]
# the step size is 1 core-site high and 1 core-site wide
set x_step     [ord::dbu_to_microns [$row_site getWidth]]
set y_step     [ord::dbu_to_microns [$row_site getHeight]]

set width  [expr {ceil(sqrt($area / $ASPECT))}]
set height [expr {ceil($width * $ASPECT)}]

set width_rounded [expr {ceil($width/$x_step) * $x_step}]
set height_rounded [expr {ceil($height/$y_step) * $y_step}]
set coords [list 0.0 0.0 $width_rounded $height_rounded]

# initialize the proper floorplan
initialize_floorplan -die_area $coords -core_area $coords -site CoreSite

# very low target overflow to get close-to-usable placement
global_placement -density $DENSITY -timing_driven -skip_io -overflow 0.00000001
# fix placement
detailed_placement
optimize_mirroring

# move pins
place_pins -hor_layers Metal2 -ver_layers Metal3

# no fixing here, we do it after GRT again
estimate_parasitics -placement

# global route
set_global_routing_layer_adjustment Metal1-Metal3 0.0
set_routing_layers -signal Metal2-Metal3 -clock Metal2-Metal3
global_route -guide_file reports/route.guide -verbose

# final timing repair
estimate_parasitics -global_routing
repair_timing -repair_tns 100
global_route -start_incremental
detailed_placement
optimize_mirroring
global_route -end_incremental -guide_file reports/route.guide -verbose

# detail place
set_thread_count 8
detailed_route -output_drc reports/route_drc.rpt \
               -output_maze reports/maze.log \
               -bottom_routing_layer Metal2 \
               -top_routing_layer Metal3 \
               -save_guide_updates \
               -verbose 1

# add fillers
filler_placement "*fill*"
check_placement
report_checks -path_delay min -format full_clock_expanded >  reports/timings.rpt
report_checks -path_delay max -format full_clock_expanded >> reports/timings.rpt

# write files out
exec mkdir -p out
write_timing_model out/$DESIGN_NAME.lib
write_lef out/$DESIGN_NAME.lef
write_abstract_lef out/$DESIGN_NAME.abst.lef
write_def out/$DESIGN_NAME.def
write_verilog out/$DESIGN_NAME.v
write_sdf out/$DESIGN_NAME.sdf
write_sdc out/$DESIGN_NAME.sdc
# write_spef out/$DESIGN_NAME.spef
