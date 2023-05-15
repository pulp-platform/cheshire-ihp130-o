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

set lib_list "-liberty ${tech_cells} "
foreach file $tech_macros {
	append lib_list "-liberty ${file} "
}

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

# synthesis to generics: check -> coarse -> fine -> check
# proc two times to be sure :-)
yosys proc
yosys write_verilog $build_dir/${top_design}_yosys_generic_proc.v
yosys synth -top $top_design
yosys opt -purge
yosys write_verilog $build_dir/${top_design}_yosys_generic_synth.v

yosys techmap
yosys opt
yosys opt -purge

# mapping fto techcells
yosys dfflibmap -liberty "${tech_cells}"
yosys opt
yosys abc -liberty "${tech_cells}" -constr abc.constr -D 10000

yosys tee -o "${report_dir}/area_buff.rpt" stat -top ${top_design} {*}$lib_list
yosys write_verilog -noattr -noexpr -nohex -nodec $build_dir/${top_design}_yosys_tech_buff.v

yosys clean
yosys setundef -zero
yosys splitnets 
# -ports
yosys opt_clean -purge

yosys hilomap -singleton -hicell LOGIC1JI Q -locell LOGIC0JI Q

yosys tee -o "${report_dir}/synth.rpt" check
yosys tee -o "${report_dir}/area_clean.rpt" stat -top ${top_design} {*}$lib_list

# final netlist
yosys write_verilog -noattr -noexpr -nohex -nodec $build_dir/${top_design}_yosys_tech.v
yosys write_verilog -norename $build_dir/${top_design}_yosys_tech_debug.v

# cleanup
yosys clean
