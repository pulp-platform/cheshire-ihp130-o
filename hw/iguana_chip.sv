// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>
// - Tobias Senti <tsenti@student.ethz.ch>
// - Paul Scheffler <paulsc@iis.ee.ethz.ch>

module iguana_chip import iguana_pkg::*; import cheshire_pkg::*; (
  inout wire clk_i,
  inout wire rst_ni,
  inout wire test_mode_i,
  inout wire boot_mode_0_i,
  inout wire boot_mode_1_i,
  inout wire rtc_i,
  // JTAG interface
  inout wire jtag_tck_i,
  inout wire jtag_trst_ni,
  inout wire jtag_tms_i,
  inout wire jtag_tdi_i,
  inout wire jtag_tdo_o,
  // UART interface
  inout wire uart_tx_o,
  inout wire uart_rx_i,
  // I2C interface
  inout wire i2c_sda_io,
  inout wire i2c_scl_io,
  // SPI host interface
  inout wire spih_sck_o,
  inout wire spih_csb_0_o,
  inout wire spih_csb_1_o,
  inout wire spih_sd_0_io,
  inout wire spih_sd_1_io,
  inout wire spih_sd_2_io,
  inout wire spih_sd_3_io,
  // GPIO interface
  inout wire gpio_0_io,
  inout wire gpio_1_io,
  inout wire gpio_2_io,
  inout wire gpio_3_io,
  inout wire gpio_4_io,
  inout wire gpio_5_io,
  inout wire gpio_6_io,
  inout wire gpio_7_io,
  inout wire gpio_8_io,
  inout wire gpio_9_io,
  inout wire gpio_10_io,
  inout wire gpio_11_io,
  // Serial link interface
  inout wire slink_clk_i,
  inout wire slink_0_i,
  inout wire slink_1_i,
  inout wire slink_2_i,
  inout wire slink_3_i,
  inout wire slink_clk_o,
  inout wire slink_0_o,
  inout wire slink_1_o,
  inout wire slink_2_o,
  inout wire slink_3_o,
  // VGA interface
  inout wire vga_hsync_o,
  inout wire vga_vsync_o,
  inout wire vga_red_0_o,
  inout wire vga_red_1_o,
  inout wire vga_red_2_o,
  inout wire vga_green_0_o,
  inout wire vga_green_1_o,
  inout wire vga_green_2_o,
  inout wire vga_blue_0_o,
  inout wire vga_blue_1_o,
  // Hyperbus
  inout wire hyper_reset_no,
  inout wire hyper_cs_0_no,
  inout wire hyper_cs_1_no,
  inout wire hyper_ck_o,
  inout wire hyper_ck_no,
  inout wire hyper_rwds_io,
  inout wire hyper_dq_0_io,
  inout wire hyper_dq_1_io,
  inout wire hyper_dq_2_io,
  inout wire hyper_dq_3_io,
  inout wire hyper_dq_4_io,
  inout wire hyper_dq_5_io,
  inout wire hyper_dq_6_io,
  inout wire hyper_dq_7_io
);

  // SoC IO
  logic       soc_clk_i;
  logic       soc_rtc_i;
  logic       soc_rst_ni;
  logic       soc_test_mode_i;
  logic [1:0] soc_boot_mode_i;

  mc_pad_in     pad_clk         ( .pad_io ( clk_i         ), .d_o ( soc_clk_i          ) );
  mc_pad_in     pad_rtc         ( .pad_io ( rtc_i         ), .d_o ( soc_rtc_i          ) );
  mc_pad_io_pu  pad_rst_n       ( .pad_io ( rst_ni        ), .d_o ( soc_rst_ni         ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_test_mode   ( .pad_io ( test_mode_i   ), .d_o ( soc_test_mode_i    ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_boot_mode_0 ( .pad_io ( boot_mode_0_i ), .d_o ( soc_boot_mode_i[0] ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_boot_mode_1 ( .pad_io ( boot_mode_1_i ), .d_o ( soc_boot_mode_i[1] ), .d_i ( ), .oe_i ( 1'b0 ) );

  // JTAG interface
  logic soc_jtag_tck_i;
  logic soc_jtag_trst_ni;
  logic soc_jtag_tms_i;
  logic soc_jtag_tdi_i;
  logic soc_jtag_tdo_o;
  logic soc_jtag_tdo_oe_o;

  mc_pad_io_pd  pad_jtag_tck    ( .pad_io ( jtag_tck_i   ), .d_o ( soc_jtag_tck_i   ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pu  pad_jtag_trst_n ( .pad_io ( jtag_trst_ni ), .d_o ( soc_jtag_trst_ni ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_jtag_tms    ( .pad_io ( jtag_tms_i   ), .d_o ( soc_jtag_tms_i   ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_jtag_tdi    ( .pad_io ( jtag_tdi_i   ), .d_o ( soc_jtag_tdi_i   ), .d_i ( ), .oe_i ( 1'b0 ) );
  mc_pad_io_pd  pad_jtag_tdo    ( .pad_io ( jtag_tdo_o   ), .d_i ( soc_jtag_tdo_o   ), .d_o ( ), .oe_i ( soc_jtag_tdo_oe_o ) );

  // UART interface
  logic soc_uart_tx_o;
  logic soc_uart_rx_i;

  mc_pad_io_pu  pad_uart_tx  ( .pad_io ( uart_tx_o ), .d_i ( soc_uart_tx_o ), .d_o ( ), .oe_i ( 1'b1 ) );
  mc_pad_io_pu  pad_uart_rx  ( .pad_io ( uart_rx_i ), .d_o ( soc_uart_rx_i ), .d_i ( ), .oe_i ( 1'b0 ) );

  // I2C interface
  logic soc_i2c_sda_o;
  logic soc_i2c_sda_i;
  logic soc_i2c_sda_en_o;
  logic soc_i2c_scl_o;
  logic soc_i2c_scl_i;
  logic soc_i2c_scl_en_o;

  mc_pad_io_pu  pad_i2c_sda  ( .pad_io ( i2c_sda_io ), .d_i ( soc_i2c_sda_o ), .d_o ( soc_i2c_sda_i ), .oe_i ( soc_i2c_sda_en_o ) );
  mc_pad_io_pu  pad_i2c_scl  ( .pad_io ( i2c_scl_io ), .d_i ( soc_i2c_scl_o ), .d_o ( soc_i2c_scl_i ), .oe_i ( soc_i2c_scl_en_o ) );

  // SPI host interface
  logic                 soc_spih_sck_o;
  logic                 soc_spih_sck_en_o;
  logic [SpihNumCs-1:0] soc_spih_csb_o;
  logic [SpihNumCs-1:0] soc_spih_csb_en_o;
  logic [ 3:0]          soc_spih_sd_o;
  logic [ 3:0]          soc_spih_sd_en_o;
  logic [ 3:0]          soc_spih_sd_i;

  mc_pad_io     pad_spih_sck   ( .pad_io ( spih_sck_o   ), .d_i ( soc_spih_sck_o    ), .oe_i ( soc_spih_sck_en_o    ), .d_o ( ) );
  mc_pad_io_pu  pad_spih_csb_0 ( .pad_io ( spih_csb_0_o ), .d_i ( soc_spih_csb_o[0] ), .oe_i ( soc_spih_csb_en_o[0] ), .d_o ( ) );
  mc_pad_io_pu  pad_spih_csb_1 ( .pad_io ( spih_csb_1_o ), .d_i ( soc_spih_csb_o[1] ), .oe_i ( soc_spih_csb_en_o[1] ), .d_o ( ) );
  mc_pad_io     pad_spih_sd_0  ( .pad_io ( spih_sd_0_io ), .d_i ( soc_spih_sd_o[0]  ), .oe_i ( soc_spih_sd_en_o[0]  ), .d_o ( soc_spih_sd_i[0] ) );
  mc_pad_io     pad_spih_sd_1  ( .pad_io ( spih_sd_1_io ), .d_i ( soc_spih_sd_o[1]  ), .oe_i ( soc_spih_sd_en_o[1]  ), .d_o ( soc_spih_sd_i[1] ) );
  mc_pad_io     pad_spih_sd_2  ( .pad_io ( spih_sd_2_io ), .d_i ( soc_spih_sd_o[2]  ), .oe_i ( soc_spih_sd_en_o[2]  ), .d_o ( soc_spih_sd_i[2] ) );
  mc_pad_io     pad_spih_sd_3  ( .pad_io ( spih_sd_3_io ), .d_i ( soc_spih_sd_o[3]  ), .oe_i ( soc_spih_sd_en_o[3]  ), .d_o ( soc_spih_sd_i[3] ) );

  // GPIO interface
  logic [GpioNumWired-1:0]  soc_gpio_i;
  logic [GpioNumWired-1:0]  soc_gpio_o;
  logic [GpioNumWired-1:0]  soc_gpio_en_o;

  mc_pad_io     pad_gpio_0  ( .pad_io ( gpio_0_io  ), .d_i ( soc_gpio_o[0]  ), .d_o ( soc_gpio_i[0]  ), .oe_i ( soc_gpio_en_o[0]  ) );
  mc_pad_io     pad_gpio_1  ( .pad_io ( gpio_1_io  ), .d_i ( soc_gpio_o[1]  ), .d_o ( soc_gpio_i[1]  ), .oe_i ( soc_gpio_en_o[1]  ) );
  mc_pad_io     pad_gpio_2  ( .pad_io ( gpio_2_io  ), .d_i ( soc_gpio_o[2]  ), .d_o ( soc_gpio_i[2]  ), .oe_i ( soc_gpio_en_o[2]  ) );
  mc_pad_io     pad_gpio_3  ( .pad_io ( gpio_3_io  ), .d_i ( soc_gpio_o[3]  ), .d_o ( soc_gpio_i[3]  ), .oe_i ( soc_gpio_en_o[3]  ) );
  mc_pad_io     pad_gpio_4  ( .pad_io ( gpio_4_io  ), .d_i ( soc_gpio_o[4]  ), .d_o ( soc_gpio_i[4]  ), .oe_i ( soc_gpio_en_o[4]  ) );
  mc_pad_io     pad_gpio_5  ( .pad_io ( gpio_5_io  ), .d_i ( soc_gpio_o[5]  ), .d_o ( soc_gpio_i[5]  ), .oe_i ( soc_gpio_en_o[5]  ) );
  mc_pad_io     pad_gpio_6  ( .pad_io ( gpio_6_io  ), .d_i ( soc_gpio_o[6]  ), .d_o ( soc_gpio_i[6]  ), .oe_i ( soc_gpio_en_o[6]  ) );
  mc_pad_io     pad_gpio_7  ( .pad_io ( gpio_7_io  ), .d_i ( soc_gpio_o[7]  ), .d_o ( soc_gpio_i[7]  ), .oe_i ( soc_gpio_en_o[7]  ) );
  mc_pad_io     pad_gpio_8  ( .pad_io ( gpio_8_io  ), .d_i ( soc_gpio_o[8]  ), .d_o ( soc_gpio_i[8]  ), .oe_i ( soc_gpio_en_o[8]  ) );
  mc_pad_io     pad_gpio_9  ( .pad_io ( gpio_9_io  ), .d_i ( soc_gpio_o[9]  ), .d_o ( soc_gpio_i[9]  ), .oe_i ( soc_gpio_en_o[9]  ) );
  mc_pad_io     pad_gpio_10 ( .pad_io ( gpio_10_io ), .d_i ( soc_gpio_o[10] ), .d_o ( soc_gpio_i[10] ), .oe_i ( soc_gpio_en_o[10] ) );
  mc_pad_io     pad_gpio_11 ( .pad_io ( gpio_11_io ), .d_i ( soc_gpio_o[11] ), .d_o ( soc_gpio_i[11] ), .oe_i ( soc_gpio_en_o[11] ) );

  // Serial link interface
  logic [SlinkNumChan-1:0]                    soc_slink_clk_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] soc_slink_i;
  logic [SlinkNumChan-1:0]                    soc_slink_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] soc_slink_o;

  mc_pad_in     pad_slink_clk_i ( .pad_io ( slink_clk_i ), .d_o ( soc_slink_clk_i[0] ) );
  mc_pad_in     pad_slink_0_i   ( .pad_io ( slink_0_i   ), .d_o ( soc_slink_i[0][0]  ) );
  mc_pad_in     pad_slink_1_i   ( .pad_io ( slink_1_i   ), .d_o ( soc_slink_i[0][1]  ) );
  mc_pad_in     pad_slink_2_i   ( .pad_io ( slink_2_i   ), .d_o ( soc_slink_i[0][2]  ) );
  mc_pad_in     pad_slink_3_i   ( .pad_io ( slink_3_i   ), .d_o ( soc_slink_i[0][3]  ) );
  mc_pad_io     pad_slink_clk_o ( .pad_io ( slink_clk_o ), .d_i ( soc_slink_clk_o[0] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_slink_0_o   ( .pad_io ( slink_0_o   ), .d_i ( soc_slink_o[0][0]  ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_slink_1_o   ( .pad_io ( slink_1_o   ), .d_i ( soc_slink_o[0][1]  ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_slink_2_o   ( .pad_io ( slink_2_o   ), .d_i ( soc_slink_o[0][2]  ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_slink_3_o   ( .pad_io ( slink_3_o   ), .d_i ( soc_slink_o[0][3]  ), .oe_i ( 1'b1 ), .d_o ( ) );

  // VGA interface
  logic                                 soc_vga_hsync_o;
  logic                                 soc_vga_vsync_o;
  logic [CheshireCfg.VgaRedWidth  -1:0] soc_vga_red_o;
  logic [CheshireCfg.VgaGreenWidth-1:0] soc_vga_green_o;
  logic [CheshireCfg.VgaBlueWidth -1:0] soc_vga_blue_o;

  mc_pad_io     pad_vga_hsync   ( .pad_io ( vga_hsync_o   ), .d_i ( soc_vga_hsync_o    ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_vsync   ( .pad_io ( vga_vsync_o   ), .d_i ( soc_vga_vsync_o    ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_red_0   ( .pad_io ( vga_red_0_o   ), .d_i ( soc_vga_red_o[0]   ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_red_1   ( .pad_io ( vga_red_1_o   ), .d_i ( soc_vga_red_o[1]   ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_red_2   ( .pad_io ( vga_red_2_o   ), .d_i ( soc_vga_red_o[2]   ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_green_0 ( .pad_io ( vga_green_0_o ), .d_i ( soc_vga_green_o[0] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_green_1 ( .pad_io ( vga_green_1_o ), .d_i ( soc_vga_green_o[1] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_green_2 ( .pad_io ( vga_green_2_o ), .d_i ( soc_vga_green_o[2] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_blue_0  ( .pad_io ( vga_blue_0_o  ), .d_i ( soc_vga_blue_o[0]  ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_vga_blue_1  ( .pad_io ( vga_blue_1_o  ), .d_i ( soc_vga_blue_o[1]  ), .oe_i ( 1'b1 ), .d_o ( ) );

  // Hyperbus
  logic [HypNumPhys-1:0]                  soc_hyper_reset_no;
  logic [HypNumPhys-1:0][HypNumChips-1:0] soc_hyper_cs_no;
  logic [HypNumPhys-1:0]                  soc_hyper_ck_o;
  logic [HypNumPhys-1:0]                  soc_hyper_ck_no;
  logic [HypNumPhys-1:0]                  soc_hyper_rwds_o;
  logic [HypNumPhys-1:0]                  soc_hyper_rwds_i;
  logic [HypNumPhys-1:0]                  soc_hyper_rwds_oe_o;
  logic [HypNumPhys-1:0][7:0]             soc_hyper_dq_o;
  logic [HypNumPhys-1:0][7:0]             soc_hyper_dq_i;
  logic [HypNumPhys-1:0]                  soc_hyper_dq_oe_o;

  mc_pad_io     pad_hyper_reset_n ( .pad_io ( hyper_reset_no ), .d_i ( soc_hyper_reset_no[0] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_hyper_cs_0_n  ( .pad_io ( hyper_cs_0_no  ), .d_i ( soc_hyper_cs_no[0][0] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_hyper_cs_1_n  ( .pad_io ( hyper_cs_1_no  ), .d_i ( soc_hyper_cs_no[0][1] ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_hyper_ck      ( .pad_io ( hyper_ck_o     ), .d_i ( soc_hyper_ck_o[0]     ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_hyper_ck_n    ( .pad_io ( hyper_ck_no    ), .d_i ( soc_hyper_ck_no[0]    ), .oe_i ( 1'b1 ), .d_o ( ) );
  mc_pad_io     pad_hyper_rwds    ( .pad_io ( hyper_rwds_io  ), .d_i ( soc_hyper_rwds_o[0]   ), .d_o ( soc_hyper_rwds_i[0]  ), .oe_i ( soc_hyper_rwds_oe_o[0] ) );
  mc_pad_io     pad_hyper_dq_0    ( .pad_io ( hyper_dq_0_io  ), .d_i ( soc_hyper_dq_o[0][0]  ), .d_o ( soc_hyper_dq_i[0][0] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_1    ( .pad_io ( hyper_dq_1_io  ), .d_i ( soc_hyper_dq_o[0][1]  ), .d_o ( soc_hyper_dq_i[0][1] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_2    ( .pad_io ( hyper_dq_2_io  ), .d_i ( soc_hyper_dq_o[0][2]  ), .d_o ( soc_hyper_dq_i[0][2] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_3    ( .pad_io ( hyper_dq_3_io  ), .d_i ( soc_hyper_dq_o[0][3]  ), .d_o ( soc_hyper_dq_i[0][3] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_4    ( .pad_io ( hyper_dq_4_io  ), .d_i ( soc_hyper_dq_o[0][4]  ), .d_o ( soc_hyper_dq_i[0][4] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_5    ( .pad_io ( hyper_dq_5_io  ), .d_i ( soc_hyper_dq_o[0][5]  ), .d_o ( soc_hyper_dq_i[0][5] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_6    ( .pad_io ( hyper_dq_6_io  ), .d_i ( soc_hyper_dq_o[0][6]  ), .d_o ( soc_hyper_dq_i[0][6] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );
  mc_pad_io     pad_hyper_dq_7    ( .pad_io ( hyper_dq_7_io  ), .d_i ( soc_hyper_dq_o[0][7]  ), .d_o ( soc_hyper_dq_i[0][7] ), .oe_i ( soc_hyper_dq_oe_o[0]   ) );

  // SoC instance
  iguana_soc i_iguana_soc (
    .clk_i            ( soc_clk_i       ),
    .rst_ni           ( soc_rst_ni      ),
    .test_mode_i      ( soc_test_mode_i ),
    .boot_mode_i      ( soc_boot_mode_i ),
    .rtc_i            ( soc_rtc_i       ),
    .jtag_tck_i       ( soc_jtag_tck_i    ),
    .jtag_trst_ni     ( soc_jtag_trst_ni  ),
    .jtag_tms_i       ( soc_jtag_tms_i    ),
    .jtag_tdi_i       ( soc_jtag_tdi_i    ),
    .jtag_tdo_o       ( soc_jtag_tdo_o    ),
    .jtag_tdo_oe_o    ( soc_jtag_tdo_oe_o ),
    .uart_tx_o        ( soc_uart_tx_o ),
    .uart_rx_i        ( soc_uart_rx_i ),
    .i2c_sda_o        ( soc_i2c_sda_o    ),
    .i2c_sda_i        ( soc_i2c_sda_i    ),
    .i2c_sda_en_o     ( soc_i2c_sda_en_o ),
    .i2c_scl_o        ( soc_i2c_scl_o    ),
    .i2c_scl_i        ( soc_i2c_scl_i    ),
    .i2c_scl_en_o     ( soc_i2c_scl_en_o ),
    .spih_sck_o       ( soc_spih_sck_o    ),
    .spih_sck_en_o    ( soc_spih_sck_en_o ),
    .spih_csb_o       ( soc_spih_csb_o    ),
    .spih_csb_en_o    ( soc_spih_csb_en_o ),
    .spih_sd_o        ( soc_spih_sd_o     ),
    .spih_sd_en_o     ( soc_spih_sd_en_o  ),
    .spih_sd_i        ( soc_spih_sd_i     ),
    .gpio_i           ( soc_gpio_i    ),
    .gpio_o           ( soc_gpio_o    ),
    .gpio_en_o        ( soc_gpio_en_o ),
    .slink_rcv_clk_i  ( soc_slink_clk_i ),
    .slink_rcv_clk_o  ( soc_slink_clk_o ),
    .slink_i          ( soc_slink_i     ),
    .slink_o          ( soc_slink_o     ),
    .vga_hsync_o      ( soc_vga_hsync_o ),
    .vga_vsync_o      ( soc_vga_vsync_o ),
    .vga_red_o        ( soc_vga_red_o   ),
    .vga_green_o      ( soc_vga_green_o ),
    .vga_blue_o       ( soc_vga_blue_o  ),
    .hyper_cs_no      ( soc_hyper_cs_no     ),
    .hyper_ck_o       ( soc_hyper_ck_o      ),
    .hyper_ck_no      ( soc_hyper_ck_no     ),
    .hyper_rwds_o     ( soc_hyper_rwds_o    ),
    .hyper_rwds_i     ( soc_hyper_rwds_i    ),
    .hyper_rwds_oe_o  ( soc_hyper_rwds_oe_o ),
    .hyper_dq_i       ( soc_hyper_dq_i      ),
    .hyper_dq_o       ( soc_hyper_dq_o      ),
    .hyper_dq_oe_o    ( soc_hyper_dq_oe_o   ),
    .hyper_reset_no   ( soc_hyper_reset_no  )
  );

  // Supply pads for IO
  mc_pad_vddio pad_vccio_0();
  mc_pad_vddio pad_vccio_1();
  mc_pad_vddio pad_vccio_2();
  mc_pad_vddio pad_vccio_3();
  mc_pad_vddio pad_vccio_4();
  mc_pad_vddio pad_vccio_5();
  mc_pad_vddio pad_vccio_6();
  mc_pad_vddio pad_vccio_7();
  mc_pad_vddio pad_vccio_8();
  mc_pad_vddio pad_vccio_9();
  mc_pad_vddio pad_vccio_10();
  mc_pad_vddio pad_vccio_11();
  mc_pad_vddio pad_vccio_12();
  mc_pad_vddio pad_vccio_13();
  mc_pad_vddio pad_vccio_14();
  mc_pad_vddio pad_vccio_15();

  // Ground pads for IO
  mc_pad_gndio pad_gndio_0();
  mc_pad_gndio pad_gndio_1();
  mc_pad_gndio pad_gndio_2();
  mc_pad_gndio pad_gndio_3();
  mc_pad_gndio pad_gndio_4();
  mc_pad_gndio pad_gndio_5();
  mc_pad_gndio pad_gndio_6();
  mc_pad_gndio pad_gndio_7();
  mc_pad_gndio pad_gndio_8();
  mc_pad_gndio pad_gndio_9();
  mc_pad_gndio pad_gndio_10();
  mc_pad_gndio pad_gndio_11();
  mc_pad_gndio pad_gndio_12();
  mc_pad_gndio pad_gndio_13();
  mc_pad_gndio pad_gndio_14();
  mc_pad_gndio pad_gndio_15();

  // Supply pads for core
  mc_pad_vddco pad_vddco_0();
  mc_pad_vddco pad_vddco_1();
  mc_pad_vddco pad_vddco_2();
  mc_pad_vddco pad_vddco_3();
  mc_pad_vddco pad_vddco_4();
  mc_pad_vddco pad_vddco_5();
  mc_pad_vddco pad_vddco_6();
  mc_pad_vddco pad_vddco_7();
  mc_pad_vddco pad_vddco_8();
  mc_pad_vddco pad_vddco_9();
  mc_pad_vddco pad_vddco_10();
  mc_pad_vddco pad_vddco_11();
  mc_pad_vddco pad_vddco_12();
  mc_pad_vddco pad_vddco_13();
  mc_pad_vddco pad_vddco_14();
  mc_pad_vddco pad_vddco_15();
  mc_pad_vddco pad_vddco_16();
  mc_pad_vddco pad_vddco_17();
  mc_pad_vddco pad_vddco_18();
  mc_pad_vddco pad_vddco_19();
  mc_pad_vddco pad_vddco_20();
  mc_pad_vddco pad_vddco_21();
  mc_pad_vddco pad_vddco_22();
  mc_pad_vddco pad_vddco_23();

  // Ground pads for core
  mc_pad_gndco pad_gndco_0();
  mc_pad_gndco pad_gndco_1();
  mc_pad_gndco pad_gndco_2();
  mc_pad_gndco pad_gndco_3();
  mc_pad_gndco pad_gndco_4();
  mc_pad_gndco pad_gndco_5();
  mc_pad_gndco pad_gndco_6();
  mc_pad_gndco pad_gndco_7();
  mc_pad_gndco pad_gndco_8();
  mc_pad_gndco pad_gndco_9();
  mc_pad_gndco pad_gndco_10();
  mc_pad_gndco pad_gndco_11();
  mc_pad_gndco pad_gndco_12();
  mc_pad_gndco pad_gndco_13();
  mc_pad_gndco pad_gndco_14();
  mc_pad_gndco pad_gndco_15();
  mc_pad_gndco pad_gndco_16();
  mc_pad_gndco pad_gndco_17();
  mc_pad_gndco pad_gndco_18();
  mc_pad_gndco pad_gndco_19();
  mc_pad_gndco pad_gndco_20();
  mc_pad_gndco pad_gndco_21();
  mc_pad_gndco pad_gndco_22();
  mc_pad_gndco pad_gndco_23();

endmodule
