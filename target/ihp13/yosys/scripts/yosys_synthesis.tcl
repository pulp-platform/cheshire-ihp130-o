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
set tiehi		$::env(TIE_HIGH)
set tielo		$::env(TIE_LOW)
set netlist		$::env(NETLIST)

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

# blackbox requested modules
if { [info exists ::env(YOSYS_BLACKBOX_MODULES)] } {
    foreach module $::env(YOSYS_BLACKBOX_MODULES) {
        puts "Blackboxing the module ${module}"
        yosys setattr -mod -set keep_hierarchy 1 ${module}
	    yosys blackbox ${module}
    }
}

if { [info exists ::env(YOSYS_KEEP_HIER_INST)] } {
    foreach sel $::env(YOSYS_KEEP_HIER_INST) {
        puts "Keeping hierarchy of selection: ${sel}"
        yosys setattr -set keep_hierarchy 1 ${sel}
    }
}

# similar to synth command
# -----------------------------------------------------------------------------
yosys hierarchy -check -top $top_design
yosys flatten
yosys autoname
yosys write_verilog $work_dir/${top_design}_yosys_rtl_initial.v

yosys proc -norom
yosys write_verilog $work_dir/${top_design}_yosys_rtl_proc.v
yosys tee -q -o "${report_dir}/${top_design}_rtl_proc_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_rtl_proc_stat.rpt" stat

# convert constructs and optimize RTL
# roughly split synth script/command:
yosys opt_expr
yosys opt_clean
yosys check
yosys opt -nodffe -nosdff
yosys fsm
yosys opt -full
yosys wreduce
yosys peepopt
yosys opt_clean
# debugging for scoreboard
# yosys debug techmap
# yosys debug alumacc
# yosys debug alumacc
yosys techmap
yosys alumacc

yosys share
yosys opt -fast
yosys memory -nomap
yosys opt_clean
yosys tee -q -o "${report_dir}/${top_design}_course_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_course_stat.rpt" stat
# yosys autoname t:$*DFF*

# fine
yosys opt -fast -full
yosys memory_map
yosys opt -full

# yosys debug techmap -autoproc
yosys techmap
# yosys simplemap

# yosys flatten
yosys opt -purge
# yosys rename -src t:$*DFF*

# hard-disabled for now
if { [info exists ::env(LSORACLE_EXE)] && 0 } {
	set lso_script_path "${work_dir}/lsoracle.script"
    set lso_script [open $lso_script_path w]
    puts $lso_script "ps -a"
# TODO: parametrize path for KayPar config file (needed to run LSOracle)    
    puts $lso_script "oracle --combine --size 2000 --config /usr/scratch/pisoc11/sem23f30/tools/lsoracle/build/core/test.ini"
    puts $lso_script "ps -m"
    puts $lso_script "crit_path_stats"
    puts $lso_script "ntk_stats"
    close $lso_script

    # LSOracle synthesis
    yosys tee -q -o "${report_dir}/${top_design}_pre_lso_stats.rpt" stat
    yosys lsoracle -script $lso_script_path -lso_exe $::env(LSORACLE_EXE)
    yosys tee -q -o "${report_dir}/${top_design}_post_lso_stats.rpt" stat
    yosys opt -purge
    # yosys techmap t:\$lut
    yosys techmap
    yosys tee -q -o "${report_dir}/${top_design}_post2_lso_stats.rpt" stat

}
yosys clean -purge

yosys tee -q -o "${report_dir}/${top_design}_pre_map_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_pre_map_stat.rpt" stat

# mapping to actual technology
yosys autoname t:$*DFF*
yosys dfflibmap -liberty "${tech_cells}"
yosys opt -fast
yosys abc -liberty "${tech_cells}" -constr abc.constr -D 10000
yosys clean -purge

yosys tee -q -o "${report_dir}/${top_design}_area_buff.rpt" stat -top ${top_design} {*}$lib_list
yosys write_verilog -noattr -noexpr -nohex -nodec $work_dir/${top_design}_yosys_tech_buff.v

# clean netlist
yosys setundef -zero
# do not use with blackboxed flow: yosys splitnets -ports -format LRT
yosys splitnets
yosys clean -purge

yosys hilomap -singleton -hicell {*}[split ${tiehi} " "] -locell {*}[split ${tielo} " "]

yosys tee -q -o "${report_dir}/${top_design}_synth.rpt" check
yosys tee -q -o "${report_dir}/${top_design}_area.rpt" stat -top ${top_design} {*}$lib_list

# final netlist
yosys write_verilog -norename $work_dir/${top_design}_yosys_tech_debug.v
yosys write_verilog -noattr -noexpr -nohex -nodec ${netlist}

# cleanup
yosys clean
