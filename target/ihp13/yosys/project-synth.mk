# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>


# modules Yosys will treat as blackboxes
# export YOSYS_BLACKBOX_MODULES := generic_delay_D4_O1_3P750_CG0

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