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
  logic   [47:0]  sba_addr;
  logic   [63:0]  sba_addr_long;
  logic           sba_we;
  logic   [63:0]  sba_wdata;
  logic   [ 7:0]  sba_strb;
  logic           sba_gnt;
  logic   [63:0]  sba_rdata;
  logic           sba_rvalid;
  logic           sba_err;

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
    .ndmreset_o           (                   ),
    .dmactive_o           (                   ),
    .debug_req_o          ( /* NC */          ),
    .unavailable_i        ( '0                ),
    .hartinfo_i           ( hartinfo          ),
    .slave_req_i          ( '0                ),
    .slave_we_i           ( '0                ),
    .slave_addr_i         ( '0                ),
    .slave_be_i           ( '0                ),
    .slave_wdata_i        ( '0                ),
    .slave_rdata_o        ( /* NC */          ),
    .master_req_o         ( sba_req           ),
    .master_add_o         ( sba_addr_long     ),
    .master_we_o          ( sba_we            ),
    .master_wdata_o       ( sba_wdata         ),
    .master_be_o          ( sba_strb          ),
    .master_gnt_i         ( sba_gnt           ),
    .master_r_valid_i     ( sba_rvalid        ),
    .master_r_rdata_i     ( sba_rdata         ),
    .master_r_err_i       ( sba_err           ),
    .master_r_other_err_i ( 1'b0              ),
    .dmi_rst_ni           ( dmi_rst_n         ),
    .dmi_req_valid_i      ( dmi_req_valid     ),
    .dmi_req_ready_o      ( dmi_req_ready     ),
    .dmi_req_i            ( dmi_req           ),
    .dmi_resp_valid_o     ( dmi_resp_valid    ),
    .dmi_resp_ready_i     ( dmi_resp_ready    ),
    .dmi_resp_o           ( dmi_resp          )
  );

  // From DM --> AXI X-Bar
  axi_from_mem #(
    .MemAddrWidth    ( 48                        ),
    .AxiAddrWidth    ( AxiAddrWidth              ),
    .DataWidth       ( 64                        ),
    .MaxRequests     ( 2                         ),
    .AxiProt         ( '0                        ),
    .axi_req_t       ( axi_a48_d64_slv_u0_req_t  ),
    .axi_rsp_t       ( axi_a48_d64_slv_u0_resp_t )
  ) i_axi_from_mem_dbg (
    .clk_i,
    .rst_ni,
    .mem_req_i       ( sba_req                   ),
    .mem_addr_i      ( sba_addr                  ),
    .mem_we_i        ( sba_we                    ),
    .mem_wdata_i     ( sba_wdata                 ),
    .mem_be_i        ( sba_strb                  ),
    .mem_gnt_o       ( sba_gnt                   ),
    .mem_rsp_valid_o ( sba_rvalid                ),
    .mem_rsp_rdata_o ( sba_rdata                 ),
    .mem_rsp_error_o ( sba_err                   ),
    .slv_aw_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .slv_ar_cache_i  ( axi_pkg::CACHE_MODIFIABLE ),
    .axi_req_o       ( axi_req                   ),
    .axi_rsp_i       ( axi_rsp                   )
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

  axi_dw_converter #(
    .AxiSlvPortDataWidth  ( AxiDataWidth                 ),
    .AxiMstPortDataWidth  ( 32                           ),
    .AxiAddrWidth         ( AxiAddrWidth                 ),
    .AxiIdWidth           ( AxiXbarSlaveIdWidth          ),
    .aw_chan_t            ( axi_a48_d32_slv_u0_aw_chan_t ),
    .mst_w_chan_t         ( axi_a48_d32_slv_u0_w_chan_t  ),
    .slv_w_chan_t         ( axi_a48_d64_slv_u0_w_chan_t  ),
    .b_chan_t             ( axi_a48_d32_slv_u0_b_chan_t  ),
    .ar_chan_t            ( axi_a48_d32_slv_u0_ar_chan_t ),
    .mst_r_chan_t         ( axi_a48_d32_slv_u0_r_chan_t  ),
    .slv_r_chan_t         ( axi_a48_d64_slv_u0_r_chan_t  ),
    .axi_mst_req_t        ( axi_a48_d32_slv_u0_req_t     ),
    .axi_mst_resp_t       ( axi_a48_d32_slv_u0_resp_t    ),
    .axi_slv_req_t        ( axi_a48_d64_slv_u0_req_t     ),
    .axi_slv_resp_t       ( axi_a48_d64_slv_u0_resp_t    )
  ) i_axi_dw_converter_regbus (
    .clk_i,
    .rst_ni,
    .slv_req_i            ( axi_req        ),
    .slv_resp_o           ( axi_rsp        ),
    .mst_req_o            ( axi_narrow_req ),
    .mst_resp_i           ( axi_narrow_rsp )
  );

  axi_to_reg #(
    .ADDR_WIDTH         ( AxiAddrWidth              ),
    .DATA_WIDTH         ( 32                        ),
    .ID_WIDTH           ( AxiXbarSlaveIdWidth       ),
    .USER_WIDTH         ( AxiUserWidth              ),
    .AXI_MAX_WRITE_TXNS ( 4                         ),
    .AXI_MAX_READ_TXNS  ( 4                         ),
    .DECOUPLE_W         ( 1                         ),
    .axi_req_t          ( axi_a48_d32_slv_u0_req_t  ),
    .axi_rsp_t          ( axi_a48_d32_slv_u0_resp_t ),
    .reg_req_t          ( reg_a48_d32_req_t         ),
    .reg_rsp_t          ( reg_a48_d32_rsp_t         )
  ) i_axi_to_reg (
    .clk_i,
    .rst_ni,
    .testmode_i,
    .axi_req_i          ( axi_narrow_req ),
    .axi_rsp_o          ( axi_narrow_rsp ),
    .reg_req_o          ( reg_req        ),
    .reg_rsp_i          ( reg_rsp        )
  );

  logic rom_req, rom_rvalid;
  logic [15:0] rom_addr;
  logic [31:0] rom_data_q, rom_data_d;

  reg_to_mem #(
    .AW         ( 16                ),
    .DW         ( 32                ),
    .req_t      ( reg_a48_d32_req_t ),
    .rsp_t      ( reg_a48_d32_rsp_t )
  ) i_reg_to_rom (
    .clk_i,
    .rst_ni,
    .reg_req_i  ( reg_req    ),
    .reg_rsp_o  ( reg_rsp    ),
    .req_o      ( rom_req    ),
    .gnt_i      ( rom_req    ),
    .we_o       (            ),
    .addr_o     ( rom_addr   ),
    .wdata_o    (            ),
    .wstrb_o    (            ),
    .rdata_i    ( rom_data_q ),
    .rvalid_i   ( rom_rvalid ),
    .rerror_i   ( '0         )
  );

  cheshire_bootrom #(
    .AddrWidth  ( 16         ),
    .DataWidth  ( 32         )
  ) i_bootrom (
    .clk_i,
    .rst_ni,
    .req_i      ( rom_req    ),
    .addr_i     ( rom_addr   ),
    .data_o     ( rom_data_d )
  );

  // State
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_state
    if(~rst_ni) begin
      rom_data_q <= '0;
      rom_rvalid <= '0;
    end else begin
      rom_data_q <= rom_data_d;
      rom_rvalid <= rom_req;
    end
  end

endmodule
