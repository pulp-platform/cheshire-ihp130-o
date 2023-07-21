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
set work_dir	  $::env(WORK)
set report_dir	$::env(REPORTS)
set tiehi		    $::env(TIE_HIGH)
set tielo		    $::env(TIE_LOW)

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

yosys hierarchy -top $top_design

yosys proc
yosys synth -top $top_design
yosys flatten
yosys opt_clean -purge

yosys lsoracle
yosys techmap
yosys opt -purge

yosys dfflibmap -liberty "${tech_cells}"
yosys abc -liberty "${tech_cells}" -constr $work_dir/../src/abc.constr -D 4000

# clean partial netlist
yosys setundef -zero
yosys splitnets -driver
yosys opt_clean -purge

yosys hilomap -hicell {*}[split ${tiehi} " "] -locell {*}[split ${tielo} " "]

yosys write_verilog -simple-lhs -noattr -noexpr -nohex -nodec $work_dir/${top_design}.mapped.v
yosys tee -q -a "${report_dir}/area_clean.rpt" stat -top ${top_design} {*}$lib_list
