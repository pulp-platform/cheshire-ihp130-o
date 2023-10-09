# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# target clock-period in pico-seconds
export YOSYS_TARGET_PERIOD_PS := 10000

# modules Yosys will treat as blackboxes
export YOSYS_BLACKBOX_MODULES := generic_delay_D4_O1_3P750_CG0
								 

# disolve/flatten small modules:
# estimated transistor count below which modules will be disolved into parent
# this happens after generic mapping (techmap); TCOUNT/4 ~ Gate-Equivalent
# a negative value means no modules are disolved in this step
export YOSYS_DISOLVE_TCOUNT := (25000*4)

# flatten hierarchy (except for below selections)
export YOSYS_FLATTEN_HIER := 1

# a list of yosys selection strings, all matching selections will be 
# kept as a seperate hierarchical element, all others will be flattened
export YOSYS_KEEP_HIER_INST := '*i_bootrom*' \
								'*gen_asic_regfile_i_ariane_regfile*' \
								'*gen_asic_fp_regfile_i_ariane_fp_regfile*' \
								'*i_scoreboard*' \
								'*i_multiplier*' \
								'*serial_link*' \
								'*i_hyperbus*' \
								'*i_dmi_cdc*' \
								'*i_sync*' \
								'*i_uart*' \
								'*i_gpio*' \
								'*i_i2c*' \
								'*i_spi*' \
								'*i_axi_vga*'


export YOSYS_USE_LSORACLE := 0

# use abc-sequential.script (includes retiming and sequential optimizations)
export YOSYS_USE_SEQ_ABC := 0
# if not activate, the abc-speed-opt script is used instead,
# it does not touch sequential elements
