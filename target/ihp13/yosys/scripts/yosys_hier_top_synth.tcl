# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Todo: Split into multiple steps
# Something like: readlib read-design, elaborate, synthesize, techmap

# get environment variables
source [file join [file dirname [info script]] yosys_common.tcl]

# read library files
foreach file $lib_list {
	yosys read_liberty -lib "$file"
}

# read design
foreach file $vlog_files {
	yosys read_verilog -sv "$file"
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

# Synthesize the rest
# -----------------------------------------------------------------------------
# this section heavily borrows from the yosys synth command:
# synth - check
yosys hierarchy -check -top $top_design
yosys tee -q -o "${report_dir}/${top_design}_rtl_initial.rpt" stat
yosys write_verilog "$work_dir/${top_design}_yosys_rtl_initial.v"

# synth - coarse:
yosys synth -run coarse:fine -noalumacc

# synth - fine:
yosys memory_collect
yosys opt -fast
yosys memory_map
yosys opt -full

yosys opt_dff -sat
yosys opt -fast
yosys clean

# remove iff https://github.com/YosysHQ/yosys/issues/3833 is fixed
yosys techmap
yosys share
yosys opt -full
yosys clean -purge

# -----------------------------------------------------------------------------

yosys tee -q -o "${report_dir}/${top_design}_generic.rpt" stat -tech cmos
yosys tee -q -o "${report_dir}/${top_design}_generic.json" stat -json -tech cmos

if {[envVarValid "YOSYS_FLATTEN_HIER"]} {
	yosys flatten
}

# rename all cells using the initial RTL names
yosys autoname t:*
# rename DFFs using the signal connected to the D-pin
# yosys rename -src t:$*DFF*
yosys clean -purge

# -----------------------------------------------------------------------------
# mapping to technology
set abc_seq_script [processAbcScript scripts/abc-sequential.script]
yosys abc -dff -liberty "$tech_cells" -D $period_ps -script $abc_seq_script

yosys dfflibmap -liberty "$tech_cells"

# set abc_comb_script [processAbcScript scripts/abc-speed-opt.script]
# yosys abc -liberty "$tech_cells" -D $period_ps -script $abc_comb_script

yosys clean -purge

# -----------------------------------------------------------------------------
# prep for openROAD

yosys setundef -zero
yosys splitnets -ports -format LRT
# only use 'yosys splitnets' with hybrid flow
yosys clean -purge
yosys autoname t:*

yosys hilomap -singleton -hicell {*}[split ${tech_tiehi} " "] -locell {*}[split ${tech_tielo} " "]

# Write the netlist of the top-most module to a verilog file
yosys write_verilog -noattr -noexpr -nohex -nodec $work_dir/${top_design}.mapped.v

# read design over blackboxes
foreach module $module_list {
	yosys read_verilog -overwrite $work_dir/${module}.mapped.v
}

# re-establish hierarchy (checks merge)
yosys hierarchy -top $top_design

# final reports
yosys tee -q -o "${report_dir}/${top_design}_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_area.rpt" stat -top $top_design {*}$liberty_args

# final netlist
yosys write_verilog -norename ${work_dir}/${top_design}_netlist_debug.v
yosys write_verilog -noattr -noexpr -nohex -nodec $netlist