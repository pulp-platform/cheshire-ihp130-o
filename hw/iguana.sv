// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz  <tbenz@ethz.ch>

/// Top-level implementation of Iguana
module iguana import cheshire_pkg::*;#(
    parameter cheshire_cfg_t CheshireCfg = CheshireCfgASICDefault,
    parameter int unsigned HypNumPhys  = 1,
    parameter int unsigned HypNumChips = 1
) (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   logic               testmode_i,

    // Boot mode selection
    input   logic [1:0]         boot_mode_i,

    // DDR-Link
    input   logic [3:0]         ddr_link_i,
    output  logic [3:0]         ddr_link_o,

    input   logic               ddr_link_clk_i,
    output  logic               ddr_link_clk_o,

    // VGA Controller
    output  logic                                   vga_hsync_o,
    output  logic                                   vga_vsync_o,
    output  logic [CheshireCfg.VgaRedWidth-1:0]     vga_red_o,
    output  logic [CheshireCfg.VgaGreenWidth-1:0]   vga_green_o,
    output  logic [CheshireCfg.VgaBlueWidth-1:0]    vga_blue_o,

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
    output logic                spim_sck_o,
    output logic                spim_sck_en_no,
    output logic [ 1:0]         spim_csb_o,
    output logic [ 1:0]         spim_csb_en_no,
    output logic [ 3:0]         spim_sd_o,
    output logic [ 3:0]         spim_sd_en_no,
    input  logic [ 3:0]         spim_sd_i,

    // CLINT
    input  logic                rtc_i,

    // hyperbus clocks
    input  logic                hyp_clk_phy_i,
    input  logic                hyp_rst_phy_ni,

    // hyperbus
    output logic [HypNumPhys-1:0][HypNumChips-1:0] hyper_cs_no,
    output logic [HypNumPhys-1:0]                  hyper_ck_o,
    output logic [HypNumPhys-1:0]                  hyper_ck_no,
    output logic [HypNumPhys-1:0]                  hyper_rwds_o,
    input  logic [HypNumPhys-1:0]                  hyper_rwds_i,
    output logic [HypNumPhys-1:0]                  hyper_rwds_oe_no,
    input  logic [HypNumPhys-1:0][7:0]             hyper_dq_i,
    output logic [HypNumPhys-1:0][7:0]             hyper_dq_o,
    output logic [HypNumPhys-1:0]                  hyper_dq_oe_o,
    output logic [HypNumPhys-1:0]                  hyper_reset_no
);

    // local AXI LLC -> Hyper
    axi_a48_d64_mst_u0_llc_req_t dram_req;
    axi_a48_d64_mst_u0_llc_resp_t dram_resp;

    // hyper cfg
    reg_a48_d32_req_t external_reg_req;
    reg_a48_d32_rsp_t external_reg_rsp;

    // local output enable flipped
    logic        i2c_sda_en;
    logic        i2c_scl_en;
    logic        spim_sck_en;
    logic [ 1:0] spim_csb_en;
    logic [ 3:0] spim_sd_en;
    logic        hyper_rwds_oe;

    // the SoC
    cheshire_soc #(
        .CheshireCfg(CheshireCfg)
    ) i_cheshire_soc (
        .clk_i,
        .rst_ni,
        .testmode_i,
        .boot_mode_i,
        .boot_addr_i        ( iguana_pkg::iguana_boot_addr ),
        .dram_req_o         ( dram_req                     ),
        .dram_resp_i        ( dram_resp                    ),
        .ddr_link_i,
        .ddr_link_o,
        .ddr_link_clk_i,
        .ddr_link_clk_o,
        .vga_hsync_o,
        .vga_vsync_o,
        .jtag_tck_i,
        .jtag_trst_ni,
        .jtag_tms_i,
        .jtag_tdi_i,
        .jtag_tdo_o,
        .uart_tx_o,
        .uart_rx_i,
        .i2c_sda_o,
        .i2c_sda_i,
        .i2c_sda_en_o       ( i2c_sda_en                    ),
        .i2c_scl_o,
        .i2c_scl_i,
        .i2c_scl_en_o       ( i2c_scl_en                    ),
        .spim_sck_o,
        .spim_sck_en_o      ( spim_sck_en                   ),
        .spim_csb_o,
        .spim_csb_en_o      ( spim_csb_en                   ),
        .spim_sd_o,
        .spim_sd_en_o       ( spim_sd_en                    ),
        .spim_sd_i,
        .rtc_i,
        .clk_locked_i       ( 1'b0                          ), // tied-off
        .external_reg_req_o ( external_reg_req              ),
        .external_reg_rsp_i ( external_reg_rsp              )
    );

    // hyperbus memory
    hyperbus #(
        .NumChips         ( HypNumChips                               ),
        .NumPhys          ( HypNumPhys                                ),
        .IsClockODelayed  ( 1'b0                                      ),
        .AxiAddrWidth     ( cheshire_pkg::AxiAddrWidth                ),
        .AxiDataWidth     ( cheshire_pkg::AxiDataWidth                ),
        .AxiIdWidth       ( cheshire_pkg::AxiXbarSlaveIdWidth + 32'd1 ),
        .AxiUserWidth     ( cheshire_pkg::AxiUserWidth                ),
        .axi_req_t        ( axi_a48_d64_mst_u0_llc_req_t              ),
        .axi_rsp_t        ( axi_a48_d64_mst_u0_llc_resp_t             ),
        .axi_w_chan_t     ( axi_a48_d64_mst_u0_llc_w_chan_t           ),
        .axi_b_chan_t     ( axi_a48_d64_mst_u0_llc_b_chan_t           ),
        .axi_ar_chan_t    ( axi_a48_d64_mst_u0_llc_ar_chan_t          ),
        .axi_r_chan_t     ( axi_a48_d64_mst_u0_llc_r_chan_t           ),
        .axi_aw_chan_t    ( axi_a48_d64_mst_u0_llc_aw_chan_t          ),
        .RegAddrWidth     ( cheshire_pkg::AxiAddrWidth                ),
        .RegDataWidth     ( 32'd32                                    ),
        .reg_req_t        ( reg_a48_d32_req_t                         ),
        .reg_rsp_t        ( reg_a48_d32_rsp_t                         ),
        .axi_rule_t       ( cheshire_pkg::address_rule_48_t           ),
        .RxFifoLogDepth   ( 32'd2                                     ),
        .TxFifoLogDepth   ( 32'd2                                     ),
        .RstChipBase      ( 'h0                                       ),
        .RstChipSpace     ( 'h1_0000                                  ),
        .PhyStartupCycles ( 300 * 200                                 ),
        .AxiLogDepth      ( 32'd3                                     )
    ) i_hyperbus (
        .clk_phy_i       ( hyp_clk_phy_i    ),
        .rst_phy_ni      ( hyp_rst_phy_ni   ),
        .clk_sys_i       ( clk_i            ),
        .rst_sys_ni      ( rst_ni           ),
        .test_mode_i     ( testmode_i       ),
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
    assign spim_sck_en_no   = ~spim_sck_en;
    assign spim_csb_en_no   = ~spim_csb_en;
    assign spim_sd_en_no    = ~spim_sd_en;
    assign hyper_rwds_oe_no = ~hyper_rwds_oe;

endmodule
