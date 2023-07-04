// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Tobias Senti <tsenti@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`define IHP13_TC_SRAM_TIEOFF \
  .A_BIST_CLK   ( '0 ), \
  .A_BIST_ADDR  ( '0 ), \
  .A_BIST_DIN   ( '0 ), \
  .A_BIST_BM    ( '0 ), \
  .A_BIST_MEN   ( '0 ), \
  .A_BIST_WEN   ( '0 ), \
  .A_BIST_REN   ( '0 ), \
  .A_BIST_EN    ( '0 ), \
  .A_DLY        ( '0 )

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);

  localparam P1l1 = (NumPorts == 1 & Latency == 1);

  // Assemble bit mask
  data_t [NumPorts-1:0] bm;

  for (genvar p = 0; p < NumPorts; ++p) begin : gen_bm_ports
      for (genvar b = 0; b < DataWidth; ++b) begin : gen_bm_bits
        assign bm[p][b] = be_i[p][b/ByteWidth];
      end
  end

  // Generate desired cuts
  if (NumWords == 256 && DataWidth == 36 && P1l1) begin: gen_256x36xBx1

    logic [63:0] wdata64, rdata64, bm64;

    assign rdata_o = rdata64;
    assign wdata64 = wdata_i;
    assign bm64    = bm;

    RM_IHPSG13_1P_256x64_c2_bm_bist i_cut (
     .A_CLK   ( clk_i   ),
     .A_ADDR  ( addr_i [0][7:0] ),
     .A_BM    ( bm64    ),
     .A_MEN   ( req_i   ),
     .A_WEN   ( we_i    ),
     .A_REN   ( ~we_i   ),
     .A_DIN   ( wdata64 ),
     .A_DOUT  ( rdata64 ),
     `IHP13_TC_SRAM_TIEOFF
    );

  end else if (NumWords == 256 & DataWidth == 64 & P1l1) begin : gen_256x64xBx1

    RM_IHPSG13_1P_256x64_c2_bm_bist i_cut (
     .A_CLK   ( clk_i   ),
     .A_ADDR  ( addr_i [0][7:0] ),
     .A_BM    ( bm      ),
     .A_MEN   ( req_i   ),
     .A_WEN   ( we_i    ),
     .A_REN   ( ~we_i   ),
     .A_DIN   ( wdata_i ),
     .A_DOUT  ( rdata_o ),
     `IHP13_TC_SRAM_TIEOFF
    );

  end else if (NumWords == 2048 & DataWidth == 64 & P1l1) begin : gen_2048x64xBx1

    data_t [1:0] rdata;
    logic cut_sel_d, cut_sel_q;

    // Select cut based on address MSB
    assign cut_sel_d = addr_i[0][10];
    assign rdata_o = rdata[cut_sel_q];

    always_ff @(posedge clk_i or negedge rst_ni) begin : proc_mem_sel_q
      if(~rst_ni)             cut_sel_q <= '0;
      else if (req_i & ~we_i) cut_sel_q <= cut_sel_d;
    end

    for (genvar c = 0; c < 2; ++c) begin : gen_cuts
      RM_IHPSG13_1P_1024x64_c2_bm_bist i_cut (
       .A_CLK   ( clk_i    ),
       .A_ADDR  ( addr_i [0][9:0] ),
       .A_BM    ( bm       ),
       .A_MEN   ( req_i & (cut_sel_d == c) ),
       .A_WEN   ( we_i     ),
       .A_REN   ( ~we_i    ),
       .A_DIN   ( wdata_i  ),
       .A_DOUT  ( rdata[c] ),
       `IHP13_TC_SRAM_TIEOFF
      );
    end

  end else begin : gen_blackbox

    `ifndef SYNTHESIS
    initial $fatal("No tc_sram for %m: NumWords %0d, DataWidth %0d NumPorts %0d, Latency %0d",
        NumWords, DataWidth, NumPorts);
    `endif

    // Instantiate a non-linkable blackbox with parameters for debugging
    `ifndef MORTY
    tc_sram_blackbox #(
      .NumWords     ( NumWords    ),
      .DataWidth    ( DataWidth   ),
      .ByteWidth    ( ByteWidth   ),
      .NumPorts     ( NumPorts    ),
      .Latency      ( Latency     ),
      .SimInit      ( SimInit     ),
      .PrintSimCfg  ( PrintSimCfg ),
      .ImplKey      ( ImplKey     )
    ) ();
    `endif

  end

endmodule
