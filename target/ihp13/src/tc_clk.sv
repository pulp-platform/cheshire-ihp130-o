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
    /// This parameter is a hint for tool/technology specific mappings of this
    /// tech_cell. It indicates weather this particular clk gate instance is
    /// required for functional correctness or just instantiated for power
    /// savings. If IS_FUNCTIONAL == 0, technology specific mappings might
    /// replace this cell with a feed through connection without any gating.
    parameter bit IS_FUNCTIONAL = 1'b1
  )(
    input  logic clk_i,
    input  logic en_i,
    input  logic test_en_i,
    output logic clk_o
  );

  wire ena;

  sg13g2_or2_1 i_or (
    .A ( en_i      ),
    .B ( test_en_i ),
    .X ( ena       )
  );

//   sg13g2_slgcp_1 i_clkgate (
//     .GATE (     ),
//     .SCE  ( ena   ),
//     .CLK  ( clk_i ),
//     .GCLK ( clk_o )
//   );

  // latch based icg cell using latch and and cell
  // TODO: remove when DZ updated to the newer version on GitHub of the lib file
  wire latch_out;
  sg13g2_and2_1 i_and (
    .A ( clk_i ),
    .B ( latch_out ),
    .X ( clk_o )
  );

  sg13g2_dlhq_1 i_clkgate (
    .GATE ( ~clk_i  ),
    .D ( ena ),
    .Q ( latch_out )
  );

endmodule
