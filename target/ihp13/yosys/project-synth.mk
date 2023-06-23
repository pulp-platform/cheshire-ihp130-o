# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Author:  Philippe Sauter <phsauter@student.ethz.ch>

# For now a temp solution to scoreboard and wt_cache
# Later on this should be more global and better define what is being synthesized and how

# modules Yosys will treat as blackboxes
export YOSYS_BLACKBOX_MODULES := wt_edwardache_wbuffer__661782502538798917 \
								 scoreboard__12987190515781439146 \
								 axi_dw_converter__17375826215113237230 \
								 generic_delay_D4_O1_3P750_CG0

# a list of yosys selection strings, all matching selections will be 
# kept as a seperate hierarchical element, all others will be flattened
export YOSYS_KEEP_HIER_INST := '*i_bootrom*' \
								'*gen_asic_regfile_i_ariane_regfile*' \
								'*gen_asic_fp_regfile_i_ariane_fp_regfile*' \
								'*i_scoreboard*' \
								'*i_multiplier*'

# modules synthesized using Nina and then added to Yosys netlist
BBOXED_NINA_MODULES ?= wt_edwardache_wbuffer__661782502538798917 \
							scoreboard__12987190515781439146 \
							axi_dw_converter__17375826215113237230