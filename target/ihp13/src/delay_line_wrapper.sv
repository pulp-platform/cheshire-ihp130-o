// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Jannis Schönleber <janniss@iis.ee.ethz.ch>

// replaces the hyperbus default delay line with the one from macro_cells

module generic_delay_D4_O1_3P750_CG0 (
  input  logic       clk_i,
  input  logic       enable_i,
  input  logic [4-1:0] delay_i,
  output logic [1-1:0] clk_o
);

  delay_line_D4_O1_6P000 i_delay_line (
    .clk_i,
    .delay_i,
    .clk_o
  );

endmodule