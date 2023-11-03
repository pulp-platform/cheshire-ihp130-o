# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# get environment variables
source [file join [file dirname [info script]] yosys_common.tcl]

# read library files
read_liberty "${tech_cells}"
foreach file $tech_macros {
	read_liberty "${file}"
}

# load netlist
read_verilog $netlist
link_design $top_design

# constraints
read_sdc ../openroad/src/basilisk.sdc

# timing report
report_checks -path_delay max -path_group clk_sys
report_checks -path_delay max -path_group clk_jtg
report_checks -path_delay max -path_group clk_rtc
report_checks -path_delay max -path_group clk_sli
report_checks -path_delay max -path_group clk_hyp_rwdsi

exit