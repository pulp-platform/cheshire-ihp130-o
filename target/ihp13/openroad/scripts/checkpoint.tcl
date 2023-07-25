# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>

# Helper macros to save and load checkpoints

proc save_checkpoint { checkpoint_name } {
    puts "Saving checkpoint $checkpoint_name"
    write_def save/$checkpoint_name.def
    write_verilog save/$checkpoint_name.v
}

proc load_checkpoint { checkpoint_name } {
    puts "Loading checkpoint $checkpoint_name"
    read_verilog save/$checkpoint_name.v
    read_def save/$checkpoint_name.def
}
