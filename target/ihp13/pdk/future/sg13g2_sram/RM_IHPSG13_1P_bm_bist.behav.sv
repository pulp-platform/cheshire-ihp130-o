// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`ifdef RM_IHPSG13_ZEROINIT
`define RM_IHPSG13_DEFAULT '0
`else
`define RM_IHPSG13_DEFAULT 'x
`endif

`define RM_IHPSG13_PORT_MAP \
  input  logic  A_CLK, \
  input  addr_t A_ADDR, \
  input  data_t A_DIN, \
  input  data_t A_BM, \
  input  logic  A_MEN, \
  input  logic  A_WEN, \
  input  logic  A_REN, \
  input  logic  A_BIST_CLK, \
  input  addr_t A_BIST_ADDR, \
  input  data_t A_BIST_DIN, \
  input  data_t A_BIST_BM, \
  input  logic  A_BIST_MEN, \
  input  logic  A_BIST_WEN, \
  input  logic  A_BIST_REN, \
  input  logic  A_BIST_EN, \
  output data_t A_DOUT, \
  input  logic  A_DLY

module RM_IHPSG13_1P_bm_bist_internal #(
  parameter type addr_t = logic,
  parameter type data_t = logic
) (`RM_IHPSG13_PORT_MAP);

  // Internal state
  data_t mem [addr_t];

  logic clk, wen, men, ren;
  addr_t addr;
  data_t din;
  data_t bm;

  always_comb begin
    if ('0) begin
      clk   = A_BIST_CLK;
      addr  = A_BIST_ADDR;
      din   = A_BIST_DIN;
      bm    = A_BIST_BM;
      men   = A_BIST_MEN;
      wen   = A_BIST_WEN;
      ren   = A_BIST_REN;
    end else begin
      clk   = A_CLK;
      addr  = A_ADDR;
      din   = A_DIN;
      bm    = A_BM;
      men   = A_MEN;
      wen   = A_WEN;
      ren   = A_REN;
    end
  end

  always_ff @(posedge clk) begin
    if (men & (wen | ren) & ~mem.exists(addr)) mem[addr] = `RM_IHPSG13_DEFAULT;
    if (men & wen) mem[addr]  = (mem[addr] & ~bm) | (din & bm);
    if (men & ren) A_DOUT     = mem[addr];
  end

endmodule

module RM_IHPSG13_1P_64x64_c2_bm_bist #(
  // Constant parameters; do not override
  parameter type addr_t = logic [5:0],
  parameter type data_t = logic [63:0]
) (`RM_IHPSG13_PORT_MAP);

  RM_IHPSG13_1P_bm_bist_internal #(
    .addr_t ( addr_t ),
    .data_t ( data_t )
  ) i_internal (.*);

endmodule

module RM_IHPSG13_1P_256x64_c2_bm_bist #(
  // Constant parameters; do not override
  parameter type addr_t = logic [7:0],
  parameter type data_t = logic [63:0]
) (`RM_IHPSG13_PORT_MAP);

  RM_IHPSG13_1P_bm_bist_internal #(
    .addr_t ( addr_t ),
    .data_t ( data_t )
  ) i_internal (.*);

endmodule

module RM_IHPSG13_1P_1024x64_c2_bm_bist #(
  // Constant parameters; do not override
  parameter type addr_t = logic [9:0],
  parameter type data_t = logic [63:0]
) (`RM_IHPSG13_PORT_MAP);

  RM_IHPSG13_1P_bm_bist_internal #(
    .addr_t ( addr_t ),
    .data_t ( data_t )
  ) i_internal (.*);

endmodule
