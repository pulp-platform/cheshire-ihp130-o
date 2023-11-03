# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

# Helper scripts writing reports

proc save_reports { drvs report_name } {
    global report_dir
    set report [open ${report_dir}/${report_name}.rpt "w"]

    puts $report "Generating $report_name reports..."
    puts $report "$report_name Setup"
    puts $report [report_checks -path_delay max]
    puts $report "$report_name Hold"
    puts $report [report_checks -path_delay min]
    if { $drvs } {
        puts $report "$report_name DRVs"
        puts $report [report_check_types -violators -max_fanout]
    }
    close $report
}
