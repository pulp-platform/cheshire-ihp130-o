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

# ABC script with retiming and sequential opt
set abc_sequential_script [file join [file dirname [info script]] abc-sequential.script]
# ABC script without DFF optimizations
set abc_combinational_script [file join [file dirname [info script]] abc-speed-opt.script]

# read library files
foreach file $lib_list {
	yosys read_liberty -lib "$file"
}

# read design
foreach file $vlog_files {
	yosys read_verilog -sv "$file"
}

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

# -----------------------------------------------------------------------------
# this section heavily borrows from the yosys synth command:
# synth - check
yosys hierarchy -check -top $top_design
yosys proc
yosys tee -q -o "${report_dir}/${top_design}_rtl_initial.rpt" stat
yosys write_verilog "$work_dir/${top_design}_yosys_rtl_initial.v"

# synth - coarse:
# yosys synth -run coarse -noalumacc
yosys proc
yosys opt_expr
yosys opt_clean
yosys check
yosys opt -nodffe -nosdff
yosys fsm
yosys opt -full
yosys wreduce 
# yosys peepopt -bmux
yosys peepopt
yosys opt_clean
yosys share
yosys opt_clean
yosys memory -nomap
yosys opt_clean

#synth - fine:
yosys memory_collect
yosys opt -fast
yosys memory_map
yosys opt -full

# yosys opt_dff -sat
yosys opt -full
yosys share
yosys clean

yosys write_verilog -norename ${work_dir}/${top_design}_netlist_abstract.v
yosys tee -q -o "${report_dir}/${top_design}_abstract.rpt" stat -tech cmos

# remove iff https://github.com/YosysHQ/yosys/issues/3833 is fixed
# yosys techmap -extern t:*shiftx*
# yosys techmap -extern t:*shift*

yosys techmap
yosys share
yosys opt -fast
yosys clean -purge

# -----------------------------------------------------------------------------
yosys tee -q -o "${report_dir}/${top_design}_generic.rpt" stat -tech cmos
yosys tee -q -o "${report_dir}/${top_design}_generic.json" stat -json -tech cmos

if {[envVarValid "YOSYS_FLATTEN_HIER"]} {
	yosys flatten
}

yosys clean -purge

# -----------------------------------------------------------------------------

# LSOracle hard-disabled for now
if { [envVarValid "YOSYS_USE_LSORACLE"] && 0 } {
	set lso_script_path "${work_dir}/lsoracle.script"
    set lso_script [open $lso_script_path w]
    puts $lso_script "ps -a"   
    puts $lso_script "oracle --combine --size 2000 --config $::env(LSORACLE_KAYPAR_CONF)"
    puts $lso_script "ps -m"
    puts $lso_script "crit_path_stats"
    puts $lso_script "ntk_stats"
    close $lso_script

    # LSOracle synthesis
    yosys tee -q -o "${report_dir}/${top_design}_pre_lso_stats.rpt" stat
    yosys lsoracle -script $lso_script_path -lso_exe $::env(LSORACLE_EXE)
    yosys tee -q -o "${report_dir}/${top_design}_post_lso_stats.rpt" stat
    yosys opt -purge
    # yosys techmap t:*lut*
    yosys techmap
    yosys tee -q -o "${report_dir}/${top_design}_post2_lso_stats.rpt" stat
    yosys clean -purge
}

# -----------------------------------------------------------------------------
yosys tee -q -o "${report_dir}/${top_design}_pre_tech.rpt" stat -tech cmos
yosys tee -q -o "${report_dir}/${top_design}_pre_tech.json" stat -json -tech cmos

# rename DFFs from the driven signal
yosys splitnets -driver -ports -format __I
# do not use '-ports 'with blackboxed flow to avoid changing ports
yosys rename -wire -suffix _reg t:*DFF*
yosys select -write ${report_dir}/${top_design}_registers.rpt t:*DFF*
# rename all other cells
yosys autoname t:*DFF* %n
yosys clean -purge

# mapping to technology
if { [envVarValid "YOSYS_USE_SEQ_ABC"] } {
    puts "Using sequential abc optimizations with retiming"
    # sequential optimizations requires D-FF mapping after abc
    set abc_seq_script [processAbcScript $abc_sequential_script]
    # yosys abc -dff -liberty "$tech_cells" -D $period_ps -script $abc_seq_script -exe /usr/scratch2/pisoc12/sem23f30/abc-patched/abc
    yosys abc -dff -liberty "$tech_cells" -D $period_ps -script $abc_seq_script
    yosys dfflibmap -liberty "$tech_cells"
} else {
    puts "Using combinational-only abc optimizations"
    yosys dfflibmap -liberty "$tech_cells"
    set abc_comb_script [processAbcScript $abc_combinational_script]
    yosys abc -liberty "$tech_cells" -D $period_ps -script $abc_comb_script
} 

yosys clean -purge

# -----------------------------------------------------------------------------
# prep for openROAD
yosys write_verilog -norename -noexpr -attr2comment ${work_dir}/${top_design}_netlist_debug.v

yosys setundef -zero
yosys clean -purge

yosys hilomap -singleton -hicell {*}[split ${tech_tiehi} " "] -locell {*}[split ${tech_tielo} " "]

# final reports
yosys tee -q -o "${report_dir}/${top_design}_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_area.rpt" stat -top $top_design {*}$liberty_args
yosys tee -q -o "${report_dir}/${top_design}_area_logic.rpt" stat -top $top_design -liberty "$tech_cells"

# final netlist
yosys write_verilog -noattr -noexpr -nohex -nodec $netlist

# cleanup
yosys clean
