# UNTESTED!
# get environment variables
set work_dir	$::env(WORK)

# save current selection
yosys select -set cur_selection

# get list of all modules
tee -q -o "${work_dir}/module_list.log" ls
set ls_out [exec cat "${work_dir}/module_list.log"]
set ls_list [split $ls_out "\n"]
set modules [lrange $ls_list 2 end]

# Writeout internal representation
foreach module $modules {
	regsub {^\s*\$\w*\\} $module "" name
	set name [string trim $name]
	select $name
	tee -q -o "${work_dir}/${name}.rtlil" write_rtlil -selected 
}

# restore current selection
yosys select @cur_selection