# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>

# get environment variables
set vlog_netlist  $::env(VLOG_NETLIST)
set top_design    $::env(TOP_DESIGN)
set tech_cells    $::env(TECH_CELLS)
set tech_macros   $::env(TECH_MACROS)
set report_dir	  $::env(REPORTS)

# read library files
read_liberty "${tech_cells}"
foreach file $tech_macros {
	read_liberty "${file}"
}

# load netlist
read_verilog $vlog_netlist
link_design $top_design

# constraints
read_sdc ../../common/openroad/src/iguana.sdc

# timing report
report_checks -path_delay max -path_group clk_hyp
report_checks -path_delay max -path_group clk_jtag
report_checks -path_delay max -path_group clk_main

exit