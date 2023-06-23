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
set report_dir	$::env(REPORTS)
set hier_dept   $::env(HIER_DEPTH)
set tiehi		$::env(TIE_HIGH)
set tielo		$::env(TIE_LOW)

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

set module_file  [open [file join $work_dir ${top_design}_hier_d${hier_depth}_modules.log] "r"]
set module_lines [split [read $module_file] "\n"]
set module_list [list]
foreach line $module_lines {
	if {[string length $line] > 0} {
		lappend module_list $line
	}
}

# Declare all synthesized modules as blackboxes
foreach module $module_list {
    yosys blackbox $module
}

yosys hierarchy -top $top_design

yosys proc
yosys synth -top $top_design
yosys techmap
yosys opt -purge

yosys dfflibmap -liberty "${tech_cells}"
yosys abc -liberty "${tech_cells}" -constr abc.constr -D 5000

# clean partial netlist
yosys setundef -zero
yosys splitnets -driver
yosys opt_clean -purge

yosys hilomap -singleton -hicell {*}[split ${tiehi} " "] -locell {*}[split ${tielo} " "]

# Write the netlist of the top-most module to a verilog file
yosys write_verilog -noattr -noexpr -nohex -nodec $work_dir/${top_design}.mapped.v

# read design
foreach module $module_list {
	yosys read_verilog -overwrite $work_dir/${module}.mapped.v
}
yosys hierarchy -top $top_design
yosys tee -q -o "${report_dir}/synth.rpt" check
yosys tee -q -o "${report_dir}/area_clean.rpt" stat -top ${top_design} {*}$lib_list

yosys write_verilog -simple-lhs -noattr -noexpr -nohex -nodec $build_dir/${top_design}_yosys-hier_tech.v