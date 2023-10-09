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

# link files/modules together
yosys hierarchy -check -top $top_design

yosys tee -q -o "${report_dir}/${top_design}_rtl_initial.rpt" stat
yosys write_verilog "${work_dir}/${top_design}_yosys_rtl_initial.v"

set hier_file ${work_dir}/${top_design}_full_hierarchy.log
set module_file [open ${report_dir}/${top_design}_hier_d${hier_depth}_modules.log "w"]

yosys tee -q -o $hier_file hierarchy -top $top_design

set ls_out [exec cat $hier_file]
set ls_list [split $ls_out "\n"]
set modules [lrange $ls_list 5 end]
set modules_final [list]

# indentation gives hierarchy level/depth
set spaces [expr $hier_depth*4 +1]
puts "spaces: $spaces"

# create a *.tmp.v file per module on this level
foreach module $modules {
	puts "line: $module"
	if {$hier_depth <= 0} {
		set count [regsub "Used module:\\s+\\\\(\[a-zA-Z0-9_\]+)" $module {\1} name]
	} else {
		set count [regsub "Used module:\\s{$spaces}\\\\(\[a-zA-Z0-9_\]+)" $module {\1} name]
	}
	if {$count > 0 && [lsearch $modules_final $name] == -1} {
		puts "name: $name"
		lappend modules_final $module
		puts $module_file $name

		yosys select -module $name
		yosys write_verilog -selected -noattr -noexpr -nohex -nodec ${work_dir}/${name}.rtl.v
	}
}

close $module_file