# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

# Map the name of the macros to a generic interface name

set srams [get_cells *RM_IHP*]

foreach s $srams {
    set name [get_full_name $s]
    puts $name
}

set delay_line [get_cells *i_delay_line*]

foreach s $delay_line {
    set name [get_full_name $s]
    puts $name
}
