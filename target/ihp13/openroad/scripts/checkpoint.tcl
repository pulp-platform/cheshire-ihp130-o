# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter   <phsauter@ethz.ch>

# Helper macros to save and load checkpoints

proc save_checkpoint { checkpoint_name } {
    global save_dir
    set checkpoint ${save_dir}/$checkpoint_name
    puts "Saving checkpoint $checkpoint_name"
    write_def ${checkpoint}.def
    write_verilog ${checkpoint}.v
    write_db ${checkpoint}.odb
    exec zip ${checkpoint}.zip ${checkpoint}.def ${checkpoint}.v ${checkpoint}.odb
}

proc load_checkpoint { checkpoint_name } {
    global save_dir
    puts "Loading checkpoint $checkpoint_name"
    exec unzip ${save_dir}/$checkpoint_name.zip ${save_dir}/
    read_db ${save_dir}/$checkpoint_name.odb
}

proc load_checkpoint_def { checkpoint_name } {
    global save_dir
    puts "Loading checkpoint $checkpoint_name"
    exec unzip ${save_dir}/$checkpoint_name.zip ${save_dir}/
    read_verilog ${save_dir}/$checkpoint_name.v
    read_def ${save_dir}/$checkpoint_name.def
}