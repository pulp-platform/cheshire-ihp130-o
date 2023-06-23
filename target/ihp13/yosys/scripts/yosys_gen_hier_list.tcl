# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>

# Todo: Split into multiple steps
# Something like: readlib read-design, elaborate, synthesize, techmap

# get environment variables
set vlog_files  $::env(VLOG_FILES)
set top_design  $::env(TOP_DESIGN)
set tech_cells  $::env(TECH_CELLS)
set tech_macros $::env(TECH_MACROS)
set build_dir   $::env(BUILD)
set work_dir	$::env(WORK)
set hier_depth	$::env(HIER_DEPTH)

set lib_list "-liberty ${tech_cells} "
foreach file $tech_macros {
	append lib_list "-liberty ${file} "
}

# read library files
yosys read_liberty -lib "${tech_cells}"
foreach file $tech_macros {
	yosys read_liberty -lib "${file}"
}

# read design
foreach file $vlog_files {
	yosys read_verilog -sv "${file}"
}
# link files/modules together
yosys hierarchy -check -top $top_design

yosys write_verilog $build_dir/${top_design}_yosys_generic_initial.v

set hier_file [file join $work_dir ${top_design}_full_hierarchy.log]
set module_file [open [file join $work_dir ${top_design}_hier_d${hier_depth}_modules.log] "w"]

yosys tee -q -o $hier_file hierarchy -top $top_design

set ls_out [exec cat $hier_file]
set ls_list [split $ls_out "\n"]
set modules [lrange $ls_list 5 end]
set modules_final [list]

# Writeout internal representation
set spaces [expr $hier_depth*4 +1]
puts "spaces: $spaces"

foreach module $modules {
	puts "module: $module"
	set count [regsub "Used module:\\s{$spaces}\\\\(\[a-zA-Z0-9_\]+)" $module {\1} name]
	if {$count > 0 && [lsearch $modules_final $name] == -1} {
		puts "name: $name"
		lappend modules_final $module
		puts $module_file $name

		set file [open [file join $work_dir ${name}.tmp.v] "w"]
		close $file
	}
}

close $module_file