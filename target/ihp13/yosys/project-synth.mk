# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# target clock-period in pico-seconds
export YOSYS_TARGET_PERIOD_PS := 12000

# modules Yosys will treat as blackboxes
export YOSYS_BLACKBOX_MODULES := 
								 

# disolve/flatten small modules:
# estimated transistor count below which modules will be disolved into parent
# this happens after generic mapping (techmap); TCOUNT/4 ~ Gate-Equivalent
# a negative value means no modules are disolved in this step
# NOT IMPLEMENTED
export YOSYS_DISOLVE_TCOUNT := (25000*4)

# flatten hierarchy (except for below selections)
export YOSYS_FLATTEN_HIER := 1

# a list of yosys selection strings, all selected instances will be 
# kept as a seperate hierarchical element, all others will be flattened
# https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/select.html
export YOSYS_KEEP_HIER_INST :=  "*/gen_bootrom.i_bootrom" \
								"*/gen_asic_regfile.i_ariane_regfile" \
								"*/float_regfile_gen*i_ariane_fp_regfile" \
								"*/gen_serial_link.i_serial_link" \
								"*/i_hyperbus" \
								"*/i_dbg_dmi_jtag" \
								"*/gen_uart.i_uart" \
								"*/gen_gpio.i_gpio" \
								"*/gen_i2c.i_i2c" \
								"*/gen_spi_host.i_spi_host" \
								"*/gen_vga.i_axi_vga" \
								"*/gen_llc.i_llc" \
								"*/i_scoreboard*" \
								"t:*cdc_fifo_gray__*" \
								"t:*cdc_2phase_src__*" \
								"t:*cdc_2phase_dst__*" \
								"t:*cdc_4phase_src__*" \
								"t:*cdc_4phase_dst__*"


export YOSYS_USE_LSORACLE := 0

# use abc-sequential.script (includes sequential optimizations)
export YOSYS_USE_ABC_SEQ := 0
# use abc-sequential-retime.script (includes retiming and sequential optimizations)
export YOSYS_USE_ABC_RETIME := 0
# if none activated, the abc-speed-opt script is used instead,
# it does not touch sequential elements
