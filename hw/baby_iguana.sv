// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz  <tbenz@ethz.ch>

/// Top-level implementation of Baby Iguana <3
module baby_iguana import cheshire_pkg::*;#(
) (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   logic               testmode_i,

    // JTAG Interface
    input   logic               jtag_tck_i,
    input   logic               jtag_trst_ni,
    input   logic               jtag_tms_i,
    input   logic               jtag_tdi_i,
    output  logic               jtag_tdo_o
);

  axi_a48_d64_slv_u0_req_t  axi_req;
  axi_a48_d64_slv_u0_resp_t axi_rsp;

  axi_a48_d32_slv_u0_req_t  axi_narrow_req;
  axi_a48_d32_slv_u0_resp_t axi_narrow_rsp;

    // Regbus Peripherals
  reg_a48_d32_req_t reg_req;
  reg_a48_d32_rsp_t reg_rsp;

  /////////////
  //  Debug  //
  /////////////

  // DMI signals for JTAG DMI <-> DM communication
  logic dmi_rst_n;
  dm::dmi_req_t dmi_req;
  logic dmi_req_ready;
  logic dmi_req_valid;
  dm::dmi_resp_t dmi_resp;
  logic dmi_resp_ready;
  logic dmi_resp_valid;

  // System Bus Access for the debug module
  logic           sba_req;
  logic   [15:0]  sba_addr;
  logic   [63:0]  sba_addr_long;
  logic   [31:0]  sba_rdata, sba_rdata_q;
  logic           sba_rvalid;

  // Ignore the upper 16 bits
  assign sba_addr = sba_addr_long[47:0];

  dm::hartinfo_t [0:0] hartinfo;
  assign hartinfo[0] = ariane_pkg::DebugHartInfo;

  // Debug Module
  dm_top #(
    .NrHarts              ( 1                 ),
    .BusWidth             ( 64                ),
    .DmBaseAddress        ( 'h0               )
  ) i_dm_top (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .ndmreset_o           (                      ),
    .dmactive_o           (                      ),
    .debug_req_o          ( /* NC */             ),
    .unavailable_i        ( '0                   ),
    .hartinfo_i           ( hartinfo             ),
    .slave_req_i          ( '0                   ),
    .slave_we_i           ( '0                   ),
    .slave_addr_i         ( '0                   ),
    .slave_be_i           ( '0                   ),
    .slave_wdata_i        ( '0                   ),
    .slave_rdata_o        ( /* NC */             ),
    .master_req_o         ( sba_req              ),
    .master_add_o         ( sba_addr_long        ),
    .master_we_o          ( /* NC */             ),
    .master_wdata_o       ( /* NC */             ),
    .master_be_o          ( /* NC */             ),
    .master_gnt_i         ( sba_req              ),
    .master_r_valid_i     ( sba_rvalid           ),
    .master_r_rdata_i     ( {32'd0, sba_rdata_q} ),
    .master_r_err_i       ( 1'b0                 ),
    .master_r_other_err_i ( 1'b0                 ),
    .dmi_rst_ni           ( dmi_rst_n            ),
    .dmi_req_valid_i      ( dmi_req_valid        ),
    .dmi_req_ready_o      ( dmi_req_ready        ),
    .dmi_req_i            ( dmi_req              ),
    .dmi_resp_valid_o     ( dmi_resp_valid       ),
    .dmi_resp_ready_i     ( dmi_resp_ready       ),
    .dmi_resp_o           ( dmi_resp             )
  );

  // Debug Transfer Module + Debug Module Interface
  dmi_jtag #(
    .IdcodeValue      ( IDCode )
  ) i_dmi_jtag (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .dmi_rst_no       ( dmi_rst_n            ),
    .dmi_req_o        ( dmi_req              ),
    .dmi_req_ready_i  ( dmi_req_ready        ),
    .dmi_req_valid_o  ( dmi_req_valid        ),
    .dmi_resp_i       ( dmi_resp             ),
    .dmi_resp_ready_o ( dmi_resp_ready       ),
    .dmi_resp_valid_i ( dmi_resp_valid       ),
    .tck_i            ( jtag_tck_i           ),
    .tms_i            ( jtag_tms_i           ),
    .trst_ni          ( jtag_trst_ni         ),
    .td_i             ( jtag_tdi_i           ),
    .td_o             ( jtag_tdo_o           ),
    .tdo_oe_o         (                      )
  );


  ///////////////
  //  Bootrom  //
  ///////////////

  cheshire_bootrom #(
    .AddrWidth  ( 16         ),
    .DataWidth  ( 32         )
  ) i_bootrom (
    .clk_i,
    .rst_ni,
    .req_i      ( sba_req     ),
    .addr_i     ( sba_addr    ),
    .data_o     ( sba_rdata   )
  );

  // State
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_state
    if(~rst_ni) begin
      sba_rdata_q <= '0;
      sba_rvalid  <= '0;
    end else begin
      sba_rdata_q <= sba_rdata;
      sba_rvalid  <= sba_req;
    end
  end

endmodule
