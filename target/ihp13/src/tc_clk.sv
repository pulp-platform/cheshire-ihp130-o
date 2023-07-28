// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
// Authors:
//
// -Thomas Benz <tbenz@iis.ee.ethz.ch>
// -Tobias Senti <tsenti@student.ethz.ch>

module tc_clk_inverter (
    input  logic clk_i,
    output logic clk_o
  );

  sg13g2_inv_1 i_inv (
    .A ( clk_i ),
    .Y ( clk_o )
  );

endmodule

module tc_clk_mux2 (
    input  logic clk0_i,
    input  logic clk1_i,
    input  logic clk_sel_i,
    output logic clk_o
  );

  sg13g2_mux2_1 i_mux (
    .A0 ( clk0_i    ),
    .A1 ( clk1_i    ),
    .S   ( clk_sel_i ),
    .X   ( clk_o     )
  );

endmodule

module tc_clk_gating #(
    parameter bit IS_FUNCTIONAL = 1'b1
  )(
    input  logic clk_i,
    input  logic en_i,
    input  logic test_en_i,
    output logic clk_o
  );

  sg13g2_slgcp_1 i_clkgate (
    .GATE ( en_i ),
    .SCE  ( test_en_i   ),
    .CLK  ( clk_i ),
    .GCLK ( clk_o )
  );

endmodule
