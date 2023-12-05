// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Jannis Schönleber <janniss@iis.ee.ethz.ch>

// replaces the hyperbus default delay line with the one from macro_cells

module configurable_delay #(
  parameter int unsigned NUM_STEPS,
  localparam DELAY_SEL_WIDTH = $clog2(NUM_STEPS)
) (
  input  logic                        clk_i,
  input  logic [DELAY_SEL_WIDTH-1:0]  delay_i,
  output logic                        clk_o
);
  (* keep *)(* dont_touch = "true" *)
  delay_line_D4_O1_6P000 i_delay_line (
    .clk_i,
    .delay_i,
    .clk_o
  );

endmodule
