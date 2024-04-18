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

# constraints file
set abc_constr [file join [file dirname [info script]] ../src/abc.constr]

# ABC script without DFF optimizations
set abc_combinational_script [file join [file dirname [info script]] abc-speed-opt-new.script]
# ABC script with sequential opt
set abc_sequential_script [file join [file dirname [info script]] abc-sequential.script]
# ABC script with retiming and sequential opt
set abc_seq_retime_script [file join [file dirname [info script]] abc-sequential-retime.script]

# process abc file (written to WORK directory)
set abc_comb_script   [processAbcScript $abc_combinational_script]
set abc_seq_script    [processAbcScript $abc_sequential_script]
set abc_retime_script [processAbcScript $abc_seq_retime_script]

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

# preserve hierarchy of selected modules/instances
if { [info exists ::env(YOSYS_KEEP_HIER_INST)] } {
    foreach sel $::env(YOSYS_KEEP_HIER_INST) {
        puts "Keeping hierarchy of selection: $sel"
        yosys select -list {*}$sel
        yosys setattr -set keep_hierarchy 1 {*}$sel
    }
}

# map dont_touch attribute commonly applied to output-nets of async regs to keep
yosys attrmap -rename dont_touch keep
# copy the keep attribute to their driving cells (retain on net for debugging)
yosys attrmvcp -copy -attr keep

# -----------------------------------------------------------------------------
# this section heavily borrows from the yosys synth command:
# synth - check
yosys hierarchy -check -top $top_design
yosys proc
yosys tee -q -o "${report_dir}/${proj_name}_initial.rpt" stat

# synth - coarse:
# yosys synth -run coarse -noalumacc
yosys opt_expr
yosys opt_clean
yosys check
yosys opt -nodffe -nosdff
yosys fsm -fm_set_fsm_file ${report_dir}/${proj_name}_fsm_map.log
yosys opt -full
yosys tee -q -o "${report_dir}/${proj_name}_initial_opt.rpt" stat
yosys wreduce 
yosys peepopt
yosys opt_clean
yosys share
yosys opt
yosys booth
# yosys alumacc
# yosys opt -fast removed to save time
yosys memory
yosys opt -fast

yosys opt_dff -sat -nodffe -nosdff
yosys share
yosys opt -fast
yosys clean -purge

#yosys write_verilog -norename ${work_dir}/${proj_name}_abstract.yosys.v
yosys tee -q -o "${report_dir}/${proj_name}_abstract.rpt" stat -tech cmos

yosys techmap
yosys opt -fast
yosys clean -purge

# -----------------------------------------------------------------------------
yosys tee -q -o "${report_dir}/${proj_name}_generic.rpt" stat -tech cmos
yosys tee -q -o "${report_dir}/${proj_name}_generic.json" stat -json -tech cmos

if {[envVarValid "YOSYS_FLATTEN_HIER"]} {
	yosys flatten
}

yosys clean -purge

# the abc dress command currently has a problem when it optimizes away FFs and replaces them with
# constant gates (generic tie-cells), it can't construct the miter-circuit for equivalence checking anymore
# because the number of comb-inputs/outputs from before to after don't match (after has less of both due to the removed FFs)
yosys opt_dff -nodffe -nosdff
yosys techmap
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
    yosys tee -q -o "${report_dir}/${proj_name}_pre_lso_stats.rpt" stat
    yosys lsoracle -script $lso_script_path -lso_exe $::env(LSORACLE_EXE)
    yosys tee -q -o "${report_dir}/${proj_name}_post_lso_stats.rpt" stat
    yosys opt -purge
    # yosys techmap t:*lut*
    yosys techmap
    yosys tee -q -o "${report_dir}/${proj_name}_post2_lso_stats.rpt" stat
    yosys clean -purge
}

# -----------------------------------------------------------------------------
yosys tee -q -o "${report_dir}/${proj_name}_pre_tech.rpt" stat -tech cmos
yosys tee -q -o "${report_dir}/${proj_name}_pre_tech.json" stat -json -tech cmos

yosys splitnets -ports -format __v
# rename DFFs from the driven signal
yosys rename -wire -suffix _reg t:*DFF*
yosys select -write ${report_dir}/${proj_name}_registers.rpt t:*DFF*
# rename all other cells
yosys autoname t:*DFF* %n
yosys clean -purge

# print paths to important instances
yosys select -write ${report_dir}/${proj_name}_registers.rpt t:*DFF*

set report [open ${report_dir}/${proj_name}_instances.rpt "w"]
close $report
if { [info exists ::env(YOSYS_REPORT_INSTS)] } {
    foreach sel $::env(YOSYS_REPORT_INSTS) {
        puts "Keeping hierarchy of selection: $sel"
        yosys tee -q -a ${report_dir}/${proj_name}_instances.rpt  select -list {*}$sel
    }
}

# -----------------------------------------------------------------------------
# mapping to technology

if { [envVarValid "YOSYS_USE_ABC_SEQ"] } {
    puts "Using sequential abc optimizations"
    # Notes on using sequential-abc:
    # Sequential abc optimizations (and retiming) requires D-FF mapping after abc. However, Yosys has a large amount of internal FF variants
    # and considers their connectivity when passing logic clouds to abc, we need to guide it.
    # 
    # Init-val:    Ideally, it should never be 1, this can be achieved using dfflegalize (https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/dfflegalize.html)
    #              another option is to include 'strash; scleanup' at the beginning of your abc-script, this seems to mitigate the problems with mixed init-val
    # 
    # Clk-Domains: Yosys considers each unique combination of clock, reset and enable signals (and also polarity) as its own clock domain
    #              This can easily cause the logic-clouds given to abc to be very small, this needs to be mitigated.
    #              dfflegalize has the -mince and -minsrst (minimum clk-enable/synch-reset) arguments. If a module contains 
    #              a number of FFs in a clk-domain below this number, they are unmaped into simpler DFFs with muxes on the data-pin.
    #              Another approach is to use dffunmap to turn ALL synch-reset and clk-enables into muxes on the data-pin.
    #  
    #              There is no similar option for async-resets and clk-polarity (as they can't be totally unmapped) but we can restrict which types
    #              are used by using the -cell "" option in dfflegalize. With this we limit each async reset and clock to one polarity only (here the positive).
    #              We need to list all cells otherwise it will think it can't use the unlisted cells.
    #              dfflegalize -mince 100 -minsrst 100 \ 
    #                          -cell \$_DFF_PP?_ 0    -cell \$_DFFE_PP??_ 0    -cell \$_ALDFF_P?_ 0    -cell \$_ALDFFE_P??_ 0 \
    #                          -cell \$_SR_PP_ 0      -cell \$_DFFSR_PPP_ 0    -cell \$_DFFSRE_PPP?_ 0 \
    #                          -cell \$_SDFF_P??_ 0   -cell \$_SDFFE_P???_ 0   -cell \$_SDFFCE_P???_ 0 \
    #                          -cell \$_DLATCH_PP?_ 0 -cell \$_DLATCHSR_PPP_ 0
    # 
    # FF-mapping:  At the end all FFs need to be mapped to tech cells, using 'dfflibmap -info -liberty <file>' you can see which FFs your PDK has available.
    #              Since we need to map FFs after abc and we unmap enable and rsts intentionally, the PDK requires a simple DFF cell to make sure everything can be mapped.
    #              It may also be a valid approach to use dfflibmap -prepare instead of dfflegalize to make sure it only has cells present in the PDK.
    
    # since IHP130 only has one DFF type, I convert all FFs into this type instead of using dffunmap & dfflegalize
    yosys dfflibmap -prepare -liberty "$tech_cells"

    # # remove integrated enable and synch-resets from FFs
    # yosys dffunmap
    # # force init-value to 0 (and minimize clock and async-reset polarities used; here already handled by dfflibmap -prepare)
    # yosys dfflegalize -cell \$_DFF_PN0_ 0

    # now we should have the minimum number of clock-domains possible -> run abc
    if { [envVarValid "YOSYS_USE_ABC_RETIME"] } {
        puts "Using sequential abc optimizations with retiming"
        yosys abc -dff -liberty "$tech_cells" -D $period_ps -script $abc_retime_script -constr $abc_constr -showtmp
    } else {
        yosys abc -dff -liberty $tech_cells -D $period_ps -script $abc_seq_script -constr $abc_constr -showtmp
    }
    yosys dfflibmap -liberty "$tech_cells"   
} else {
    puts "Using combinational-only abc optimizations"
    yosys dfflibmap -liberty "$tech_cells"
    yosys abc -liberty "$tech_cells" -D $period_ps -script $abc_comb_script -constr $abc_constr -liberty_args "-S 20 -G 3" -showtmp
    # yosys abc -liberty "$tech_cells" -D $period_ps -script $abc_comb_script -constr $abc_constr -showtmp
} 

yosys clean -purge

# -----------------------------------------------------------------------------
# prep for openROAD
yosys write_verilog -norename -noexpr -attr2comment ${work_dir}/${proj_name}_debug.yosys.v

yosys setundef -zero
yosys clean -purge

yosys hilomap -singleton -hicell {*}[split ${tech_tiehi} " "] -locell {*}[split ${tech_tielo} " "]

# final reports
yosys tee -q -o "${report_dir}/${proj_name}_synth.rpt" check
yosys tee -q -o "${report_dir}/${proj_name}_area.rpt" stat -top $top_design {*}$liberty_args
yosys tee -q -o "${report_dir}/${proj_name}_area_logic.rpt" stat -top $top_design -liberty "$tech_cells"

# final netlist
yosys write_verilog -noattr -noexpr -nohex -nodec $netlist

