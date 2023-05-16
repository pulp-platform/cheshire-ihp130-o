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