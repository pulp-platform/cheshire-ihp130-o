# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Common setup used for all yosys scripts
array set env_vars {
    VLOG_FILES  vlog_files  ""
    TOP_DESIGN  top_design  ""
    TECH_CELLS  tech_cells  ""
    TECH_MACROS tech_macros ""
    tiehi       TIE_HIGH    ""
    tielo       TIE_LOW     ""
    HIER_DEPTH  hier_depth  0
    BUILD       build_dir   "[pwd]/build"
    WORK        work_dir    "[pwd]/WORK"
    REPORT      report_dir  "[pwd]/report"
}

foreach {env_var var fallback} [array get env_vars] {
    if {[info exists ::env($env_var)]} {
        set $var $::env($env_var)
    } else {
        set $var $fallback
    }
}

set lib_list [concat [split $tech_cells] [split $tech_macros] ]

proc readLibs { lib_list } {
    puts $lib_list
    foreach lib $lib_list {
        yosys read_liberty -lib "${lib}"
    }
}