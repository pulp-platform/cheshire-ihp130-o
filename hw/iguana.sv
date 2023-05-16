// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz  <tbenz@ethz.ch>
// Tobias Senti <tsenti@student.ethz.ch>

`include "axi/typedef.svh"
`include "register_interface/typedef.svh"
`include "cheshire/typedef.svh"

/// Top-level implementation of Iguana
module iguana import iguana_pkg::*; import cheshire_pkg::*;#(
    parameter cheshire_cfg_t IguanaCfg = DefaultCfg,
    parameter int unsigned HypNumPhys  = HyperBusNumPhys,
    parameter int unsigned HypNumChips = HyperBusNumChips
  ) (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   logic               test_mode_i,

    // Boot mode selection
    input   logic [1:0]         boot_mode_i,

    // Serial Link
    input   logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
    output  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
    input   logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
    output  logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,

    // VGA Controller
    output  logic                                 vga_hsync_o,
    output  logic                                 vga_vsync_o,
    output  logic [IguanaCfg.VgaRedWidth-1:0]     vga_red_o,
    output  logic [IguanaCfg.VgaGreenWidth-1:0]   vga_green_o,
    output  logic [IguanaCfg.VgaBlueWidth-1:0]    vga_blue_o,

    // JTAG Interface
    input   logic               jtag_tck_i,
    input   logic               jtag_trst_ni,
    input   logic               jtag_tms_i,
    input   logic               jtag_tdi_i,
    output  logic               jtag_tdo_o,

    // UART Interface
    output logic                uart_tx_o,
    input  logic                uart_rx_i,

    // I2C Interface
    output logic                i2c_sda_o,
    input  logic                i2c_sda_i,
    output logic                i2c_sda_en_no,
    output logic                i2c_scl_o,
    input  logic                i2c_scl_i,
    output logic                i2c_scl_en_no,

    // SPI Host Interface
    output logic                spih_sck_o,
    output logic                spih_sck_en_no,
    output logic [ SpihNumCs-1:0]         spih_csb_o,
    output logic [ SpihNumCs-1:0]         spih_csb_en_no,
    output logic [ 3:0]         spih_sd_o,
    output logic [ 3:0]         spih_sd_en_no,
    input  logic [ 3:0]         spih_sd_i,

    // CLINT
    input  logic                rtc_i,

    // hyperbus clocks
    input  logic                hyp_clk_phy_i,
    input  logic                hyp_rst_phy_ni,

    // GPIO interface
    input  logic [ 7:0]         gpio_i,
    output logic [ 7:0]         gpio_o,
    output logic [ 7:0]         gpio_en_no,

    // Hyperbus
    output logic [HypNumPhys-1:0][HypNumChips-1:0] hyper_cs_no,
    output logic [HypNumPhys-1:0]                  hyper_ck_o,
    output logic [HypNumPhys-1:0]                  hyper_ck_no,
    output logic [HypNumPhys-1:0]                  hyper_rwds_o,
    input  logic [HypNumPhys-1:0]                  hyper_rwds_i,
    output logic [HypNumPhys-1:0]                  hyper_rwds_oe_no,
    input  logic [HypNumPhys-1:0][7:0]             hyper_dq_i,
    output logic [HypNumPhys-1:0][7:0]             hyper_dq_o,
    output logic [HypNumPhys-1:0]                  hyper_dq_oe_no,
    output logic [HypNumPhys-1:0]                  hyper_reset_no
  );
  // local AXI LLC -> Hyper
  axi_llc_req_t dram_req;
  axi_llc_rsp_t dram_resp;

  // hyperbus cfg
  reg_req_t external_reg_req;
  reg_rsp_t external_reg_rsp;

  // local output enable flipped
  logic        i2c_sda_en;
  logic        i2c_scl_en;
  logic        spih_sck_en;
  logic [ 1:0] spih_csb_en;
  logic [ 3:0] spih_sd_en;
  logic        hyper_rwds_oe;
  logic        hyper_dq_oe_o;
  logic [31:0] gpio_en;

  // gpio shortened
  logic [31:0] gpio_all_i;
  logic [31:0] gpio_all_o;
  logic [31:0] gpio_all_en_no;

  assign gpio_all_i = {24'b0, gpio_i};
  assign gpio_o = gpio_all_o[7:0];
  assign gpio_en_no = gpio_all_en_no[7:0];

  // the SoC
  cheshire_soc #(
    .Cfg               ( IguanaCfg      ),
    .ExtHartinfo       ( '0             ),
    .axi_ext_llc_req_t ( axi_llc_req_t  ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t ),
    .reg_ext_req_t     ( reg_req_t   ),
    .reg_ext_rsp_t     ( reg_rsp_t   )
  ) i_cheshire_soc (
    .clk_i,
    .rst_ni,
    .test_mode_i,
    .boot_mode_i,
    .rtc_i,
    // DRAM
    .axi_llc_mst_req_o ( dram_req  ),
    .axi_llc_mst_rsp_i ( dram_resp ),
    // AXI Crossbar ports
    .axi_ext_mst_req_i ( '0 ),
    .axi_ext_mst_rsp_o (    ),
    .axi_ext_slv_req_o (    ),
    .axi_ext_slv_rsp_i ( '0 ),
    // REG slaves
    .reg_ext_slv_req_o ( external_reg_req ),
    .reg_ext_slv_rsp_i ( external_reg_rsp ),
    // Interrupts
    .intr_ext_i ( '0 ),
    .meip_ext_o (    ),
    .seip_ext_o (    ),
    .mtip_ext_o (    ),
    .msip_ext_o (    ),
    // Debug Interface to external harts
    .dbg_active_o      (    ),
    .dbg_ext_req_o     (    ),
    .dbg_ext_unavail_i ( '0 ),
    // JTAG
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o (),
    // UART
    .uart_tx_o,
    .uart_rx_i,
    .uart_rts_no (      ),
    .uart_dtr_no (      ),
    .uart_cts_ni ( 1'b0 ),
    .uart_dsr_ni ( 1'b0 ),
    .uart_edwardd_ni ( 1'b0 ),
    .uart_rin_ni ( 1'b0 ),
    // I2C
    .i2c_sda_o,
    .i2c_sda_i,
    .i2c_sda_en_o ( i2c_sda_en ),
    .i2c_scl_o,
    .i2c_scl_i,
    .i2c_scl_en_o ( i2c_scl_en ),
    // SPI Host
    .spih_sck_o,
    .spih_sck_en_o ( spih_sck_en ),
    .spih_csb_o,
    .spih_csb_en_o ( spih_csb_en ),
    .spih_sd_o,
    .spih_sd_en_o  ( spih_sd_en  ),
    .spih_sd_i,
    // GPIO
    .gpio_i (gpio_all_i),
    .gpio_o (gpio_all_o),
    .gpio_en_o     (gpio_en),
    // Serial Link Interface
    .slink_rcv_clk_i,
    .slink_rcv_clk_o,
    .slink_i,
    .slink_o,
    // VGA
    .vga_hsync_o,
    .vga_vsync_o,
    .vga_red_o,
    .vga_green_o,
    .vga_blue_o
  );

  typedef struct packed {
    int unsigned idx;
    logic [IguanaCfg.AddrWidth-1:0] start_addr;
    logic [IguanaCfg.AddrWidth-1:0] end_addr;
  } hyper_addr_rule_t;

  // hyperbus memory
  hyperbus #(
    .NumChips         ( HypNumChips                                    ),
    .NumPhys          ( HypNumPhys                                     ),
    .IsClockODelayed  ( 0                                              ),
    .AxiAddrWidth     ( IguanaCfg.AddrWidth                            ),
    .AxiDataWidth     ( IguanaCfg.AxiDataWidth                         ),
    .AxiIdWidth       ( $bits(axi_slv_id_t) + IguanaCfg.LlcNotBypass   ),
    .AxiUserWidth     ( IguanaCfg.AxiUserWidth                         ),
    .axi_req_t        ( axi_llc_req_t                                  ),
    .axi_rsp_t        ( axi_llc_rsp_t                                  ),
    .axi_w_chan_t     ( axi_llc_w_chan_t                               ),
    .axi_b_chan_t     ( axi_llc_b_chan_t                               ),
    .axi_ar_chan_t    ( axi_llc_ar_chan_t                              ),
    .axi_r_chan_t     ( axi_llc_r_chan_t                               ),
    .axi_aw_chan_t    ( axi_llc_aw_chan_t                              ),
    .RegAddrWidth     ( IguanaCfg.AddrWidth                            ),
    .RegDataWidth     ( 32'd32                                         ),
    .reg_req_t        ( reg_req_t                                      ),
    .reg_rsp_t        ( reg_rsp_t                                      ),
    .axi_rule_t       ( hyper_addr_rule_t                              ),
    .RstChipBase      ( IguanaCfg.LlcOutRegionStart                    ),
    .RstChipSpace     ( 32'(RegOutHyperBusSize)                        )
  ) i_hyperbus (
    .clk_phy_i       ( hyp_clk_phy_i    ),
    .rst_phy_ni      ( hyp_rst_phy_ni   ),
    .clk_sys_i       ( clk_i            ),
    .rst_sys_ni      ( rst_ni           ),
    .test_mode_i     ( test_mode_i      ),
    .axi_req_i       ( dram_req         ),
    .axi_rsp_o       ( dram_resp        ),
    .reg_req_i       ( external_reg_req ),
    .reg_rsp_o       ( external_reg_rsp ),
    .hyper_cs_no,
    .hyper_ck_o,
    .hyper_ck_no,
    .hyper_rwds_o,
    .hyper_rwds_i,
    .hyper_rwds_oe_o ( hyper_rwds_oe    ),
    .hyper_dq_i,
    .hyper_dq_o,
    .hyper_dq_oe_o,
    .hyper_reset_no
  );

  // flip the polarity of the output enables
  assign i2c_sda_en_no    = ~i2c_sda_en;
  assign i2c_scl_en_no    = ~i2c_scl_en;
  assign spih_sck_en_no   = ~spih_sck_en;
  assign spih_csb_en_no   = ~spih_csb_en;
  assign spih_sd_en_no    = ~spih_sd_en;
  assign hyper_rwds_oe_no = ~hyper_rwds_oe;
  assign gpio_all_en_no   = ~gpio_en;
  assign hyper_dq_oe_no   = ~hyper_dq_oe_o;

endmodule
