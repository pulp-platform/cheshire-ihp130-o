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

yosys tee -q -o "${work_dir}/${top_design}_rtl.rpt" stat

# blackbox requested modules
if { [info exists ::env(YOSYS_BLACKBOX_MODULES)] } {
    foreach module $::env(YOSYS_BLACKBOX_MODULES) {
        puts "Blackboxing the module ${module}"
        yosys setattr -mod -set keep_hierarchy 1 $module
	    yosys blackbox $module
    }
}

# keep some hierarchies (only relevant if YOSYS_FLATTEN_HIER exists)
if { [info exists ::env(YOSYS_KEEP_HIER_INST)] } {
    foreach sel $::env(YOSYS_KEEP_HIER_INST) {
        puts "Keeping hierarchy of selection: $sel"
        yosys setattr -set keep_hierarchy 1 $sel
    }
}

yosys hierarchy -top $top_design

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
yosys techmap -extern t:*shiftx*
yosys techmap -extern t:*shift*
yosys techmap
yosys share
yosys opt -full
yosys clean -purge

yosys dfflibmap -liberty "${tech_cells}"
yosys abc -liberty "${tech_cells}" -constr abc.constr -D 4000

# clean partial netlist
yosys setundef -zero
yosys splitnets -driver
yosys opt_clean -purge

yosys hilomap -hicell {*}[split ${tiehi} " "] -locell {*}[split ${tielo} " "]

yosys write_verilog -simple-lhs -noattr -noexpr -nohex -nodec $work_dir/${top_design}.mapped.v
yosys tee -q -a "${report_dir}/part_{top_design}_area.rpt" stat -top ${top_design} {*}$lib_list
