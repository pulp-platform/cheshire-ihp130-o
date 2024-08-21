# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Paul Scheffler <paulsc@iis.ee.ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>

# Backend constraints

############
## Global ##
############

source src/basilisk_instances.sdc

set_propagated_clock [all_clocks]


##############
## Hyperbus ##
##############
if { ![info exists ::env(HYPER_CONF)] || $::env(HYPER_CONF) ne "NO_HYPERBUS"} {
  # the clk is now stopped and doesn't bleed through but the paths gets timed as a data-path instead
  # this is fine but only produces reasonable results after CTS, before CTS it misleads repair_timing into erroneously placing buffers in the clock net
  # IMPORTANT!!!!! remove these false paths post-CTS via unset_path_exceptions
  foreach mux [get_cells $HYP_DDR_DATA_MUXES] {
    set mux_out [get_name $mux]/$MUX_OUT_PIN
    set mux_ctrl [get_name $mux]/$MUX_CONTROL_PIN
    set pad [get_name [get_fanout -from $mux_out -only_cells -endpoints_only]]
    unset_path_exceptions -from clk_i -through $mux_ctrl -through $mux_out -to $pad/DIN
  }

  set mux_out $HYP_DDR_RWDS_MUX/$MUX_OUT_PIN
  set mux_ctrl $HYP_DDR_RWDS_MUX/$MUX_CONTROL_PIN
  set pad [get_name [get_fanout -from $mux_out -only_cells -endpoints_only]]
  unset_path_exceptions -from clk_i -through $mux_ctrl -through $mux_out -to $pad/DIN
}