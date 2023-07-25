# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

# Helper scripts writing reports

proc save_reports { drvs report_name } {
    puts "Generating $report_name reports..."
    puts "$report_name Setup"
    report_checks -path_delay max
    puts "$report_name Hold"
    report_checks -path_delay min
    if { $drvs } {
        puts "$report_name DRVs"
        report_check_types -violators -max_slew -max_capacitance -max_fanout
    }
}
