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