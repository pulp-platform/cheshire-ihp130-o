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
								"*/i_bootrom*/i_part*" \
								"*/i_core_cva6" \
								"*/i_cva6_icache" \
								"*/i_wt_dcache" \
								"*/i_scoreboard" \
								"*/i_multiplier" \
								"*/ex_stage_i" \
								"*/fpu_gen.fpu_i" \
								"*/i_clint" \
								"*/i_plic" \
								"*/i_dbg_dmi_jtag" \
								"*/gen_serial_link.i_serial_link" \
								"*/i_serial_link_physical*" \
								"*/i_hyperbus" \
								"*/gen_uart.i_uart" \
								"*/gen_gpio.i_gpio" \
								"*/gen_i2c.i_i2c" \
								"*/gen_spi_host.i_spi_host" \
								"*/gen_vga.i_axi_vga" \
								"*/gen_llc.i_llc" \
								"t:*_regfile__*" \
								"t:*_reg_top__*" \
								"t:*cdc_fifo_gray_*" \
								"t:*cdc_2phase_*" \
								"t:*cdc_4phase_*" \
								"t:*clint_sync_*"

# the paths (full names) of all instances matching these strings is reported
# for floorplaning or writing constraints
export YOSYS_REPORT_INSTS :=	"t:RM_IHPSG13_*" \
								"t:delay_line_*"


# use LSOracle (currently disabled in the script so this does nothing)
export YOSYS_USE_LSORACLE := 0

# use abc-sequential.script (includes sequential optimizations)
export YOSYS_USE_ABC_SEQ := 0
# use abc-sequential-retime.script (includes retiming and sequential optimizations)
export YOSYS_USE_ABC_RETIME := 0
# if none activated, the abc-speed-opt script is used instead,
# it does not touch sequential elements
