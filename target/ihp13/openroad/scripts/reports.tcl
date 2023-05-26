proc save_reports { drvs report_name } {
    puts "Generating $report_name reports..."
    puts "$report_name Setup"
    report_checks -path_delay max
    # > "reports/$report_name.setup.rpt"
    puts "$report_name Hold"
    report_checks -path_delay min
    # > "reports/$report_name.hold.rpt"
    if { $drvs } {
        puts "$report_name DRVs"
        report_check_types -violators -max_slew -max_capacitance -max_fanout
        # > "reports/$report_name.drvs.rpt"
    }
}