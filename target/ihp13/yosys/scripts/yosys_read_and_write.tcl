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

yosys proc
yosys write_verilog $build_dir/iguana_chip_yosys_read.v