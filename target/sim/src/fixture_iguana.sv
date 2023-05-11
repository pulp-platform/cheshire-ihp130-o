module fixture_iguana;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import iguana_pkg::*;


  ///////////
  //  DUT  //
  ///////////

  // logic       clk;
  // logic       rst_n;
  // logic       test_mode;
  // logic [1:0] boot_mode;
  // logic       rtc;

  // axi_llc_req_t axi_llc_mst_req;
  // axi_llc_rsp_t axi_llc_mst_rsp;

  // logic jtag_tck;
  // logic jtag_trst_n;
  // logic jtag_tms;
  // logic jtag_tdi;
  // logic jtag_tdo;

  // logic uart_tx;
  // logic uart_rx;

  // logic i2c_sda_o;
  // logic i2c_sda_i;
  // logic i2c_sda_en_n;
  // logic i2c_scl_o;
  // logic i2c_scl_i;
  // logic i2c_scl_en_n;

  // logic                 spih_sck_o;
  // logic                 spih_sck_en_n;
  // logic [SpihNumCs-1:0] spih_csb_o;
  // logic [SpihNumCs-1:0] spih_csb_en_n;
  // logic [ 3:0]          spih_sd_o;
  // logic [ 3:0]          spih_sd_i;
  // logic [ 3:0]          spih_sd_en_n;

  // logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  // logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  // logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  // logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;
//
  // iguana #(
  //   .Cfg                ( IguanaCfg )
  // ) dut (
  //   .clk_i              ( clk       ),
  //   .rst_ni             ( rst_n     ),
  //   .test_mode_i        ( test_mode ),
  //   .boot_mode_i        ( boot_mode ),
  //   .rtc_i              ( rtc       ),
  //   .axi_llc_mst_req_o  ( axi_llc_mst_req ),
  //   .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
  //   .axi_ext_mst_req_i  ( '0 ),
  //   .axi_ext_mst_rsp_o  ( ),
  //   .axi_ext_slv_req_o  ( ),
  //   .axi_ext_slv_rsp_i  ( '0 ),
  //   .reg_ext_slv_req_o  ( ),
  //   .reg_ext_slv_rsp_i  ( '0 ),
  //   .intr_ext_i         ( '0 ),
  //   .meip_ext_o         ( ),
  //   .seip_ext_o         ( ),
  //   .mtip_ext_o         ( ),
  //   .msip_ext_o         ( ),
  //   .dbg_active_o       ( ),
  //   .dbg_ext_req_o      ( ),
  //   .dbg_ext_unavail_i  ( '0 ),
  //   .jtag_tck_i         ( jtag_tck    ),
  //   .jtag_trst_ni       ( jtag_trst_n ),
  //   .jtag_tms_i         ( jtag_tms    ),
  //   .jtag_tdi_i         ( jtag_tdi    ),
  //   .jtag_tdo_o         ( jtag_tdo    ),
  //   .jtag_tdo_oe_o      ( ),
  //   .uart_tx_o          ( uart_tx ),
  //   .uart_rx_i          ( uart_rx ),
  //   .uart_rts_no        ( ),
  //   .uart_dtr_no        ( ),
  //   .uart_cts_ni        ( 1'b0 ),
  //   .uart_dsr_ni        ( 1'b0 ),
  //   .uart_edwardd_ni        ( 1'b0 ),
  //   .uart_rin_ni        ( 1'b0 ),
  //   .i2c_sda_o          ( i2c_sda_o  ),
  //   .i2c_sda_i          ( i2c_sda_i  ),
  //   .i2c_sda_en_o       ( i2c_sda_en_n ),
  //   .i2c_scl_o          ( i2c_scl_o  ),
  //   .i2c_scl_i          ( i2c_scl_i  ),
  //   .i2c_scl_en_o       ( i2c_scl_en_n ),
  //   .spih_sck_o         ( spih_sck_o  ),
  //   .spih_sck_en_no     ( spih_sck_en_n ),
  //   .spih_csb_o         ( spih_csb_o  ),
  //   .spih_csb_en_no     ( spih_csb_en_n ),
  //   .spih_sd_o          ( spih_sd_o   ),
  //   .spih_sd_en_no      ( spih_sd_en_n  ),
  //   .spih_sd_i          ( spih_sd_i   ),
  //   .gpio_i             ( '0 ),
  //   .gpio_o             ( ),
  //   .gpio_en_no         ( ),
  //   .slink_rcv_clk_i    ( slink_rcv_clk_i ),
  //   .slink_rcv_clk_o    ( slink_rcv_clk_o ),
  //   .slink_i            ( slink_i ),
  //   .slink_o            ( slink_o ),
  //   .vga_hsync_o        ( ),
  //   .vga_vsync_o        ( ),
  //   .vga_red_o          ( ),
  //   .vga_green_o        ( ),
  //   .vga_blue_o         ( ),
  //   .hyp_clk_phy_i      ( ),
  //   .hyp_rst_phy_ni     ( ),
  //   .hyper_ck_no        ( ),
  //   .hyper_ck_o         ( ),
  //   .hyper_cs_no        ( ),
  //   .hyper_dq_i         ( ),
  //   .hyper_dq_o         ( ),
  //   .hyper_dq_oe_o      ( ),
  //   .hyper_reset_no     ( ),
  //   .hyper_rwds_i       ( ),
  //   .hyper_rwds_o       ( ),
  //   .hyper_rwds_oe_no   ( ),
  //   .i2c_scl_en_no      ( ),
  //   .i2c_sda_en_no      ( )
  // );
//

  logic       clk;
  logic       rst_n;
  logic       test_mode;
  logic [1:0] boot_mode;
  logic       rtc;
  // External AXI LLC (DRAM) port
  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;
  // JTAG interface
  wire jtag_tck;
  wire jtag_trst_n;
  wire jtag_tms;
  wire jtag_tdi;
  wire jtag_tdo;
  // UART interface
  wire uart_tx;
  wire uart_rx;
  // I2C interface
  wire i2c_sda;
  wire i2c_scl;
  // SPI host interface
  wire                 spih_sck;
  wire [SpihNumCs-1:0] spih_csb;
  wire [ 3:0]          spih_sd;
  // Serial link interface
  wire [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  wire [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  wire [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  wire [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;


  // hyperbus
  wire       hyper_cs_no;
  wire       hyper_ck_o;
  wire       hyper_ck_no;
  wire       hyper_rwds;
  wire [7:0] hyper_dq;
  // logic       hyper_dq_oe_o;
  wire       hyper_reset_no;

  // hyperbus clocks
  // logic       hyper_clk_phy_i;
  // logic       hyper_rst_phy_ni;
  ////////////////////////////
  //  Chip Adapter Adapter  //
  ////////////////////////////

  iguana_chip i_chip (
    .clk_io             ( clk       ),
    .rst_io             ( rst_n     ),
    .boot_mode_0_io     ( boot_mode[0] ),
    .boot_mode_1_io     ( boot_mode[1] ),
    .testmode_io        ( test_mode ),
    .rtc_io             ( rtc       ),
    .jtag_tck_io        ( jtag_tck  ),
    .jtag_trst_n_io     ( jtag_trst_n ),
    .jtag_tms_io        ( jtag_tms  ),
    .jtag_tdi_io        ( jtag_tdi  ),
    .jtag_tdo_io        ( jtag_tdo  ),
    .uart_rx_io         ( uart_rx   ),
    .uart_tx_io         ( uart_tx   ),
    .i2c_sda_io         ( i2c_sda   ),
    .i2c_scl_io         ( i2c_scl   ),
    .spih_sck_io        ( spih_sck  ),
    .spih_csb_0_io      ( spih_csb[0] ),
    .spih_csb_1_io      ( spih_csb[1] ),
    .spih_sd_0_io       ( spih_sd[0] ),
    .spih_sd_1_io       ( spih_sd[1] ),
    .spih_sd_2_io       ( spih_sd[2] ),
    .spih_sd_3_io       ( spih_sd[3] ),
    .slink_link_clk_i_io( slink_rcv_clk_i[0] ),
    .slink_link_clk_o_io( slink_rcv_clk_o[0] ),
    .slink_link_i_0_io  ( slink_i[0][0] ),
    .slink_link_i_1_io  ( slink_i[0][1] ),
    .slink_link_i_2_io  ( slink_i[0][2] ),
    .slink_link_i_3_io  ( slink_i[0][3] ),
    .slink_link_o_0_io  ( slink_o[0][0] ),
    .slink_link_o_1_io  ( slink_o[0][1] ),
    .slink_link_o_2_io  ( slink_o[0][2] ),
    .slink_link_o_3_io  ( slink_o[0][3] ),
    .hyperbus_cs_n_io   ( hyper_cs_no ),
    .hyperbus_ck_io     ( hyper_ck_o ),
    .hyperbus_ck_n_io   ( hyper_ck_no ),
    .hyperbus_rwds_io   ( hyper_rwds ),
    .hyperbus_dq_0_io   ( hyper_dq[0] ),
    .hyperbus_dq_1_io   ( hyper_dq[1] ),
    .hyperbus_dq_2_io   ( hyper_dq[2] ),
    .hyperbus_dq_3_io   ( hyper_dq[3] ),
    .hyperbus_dq_4_io   ( hyper_dq[4] ),
    .hyperbus_dq_5_io   ( hyper_dq[5] ),
    .hyperbus_dq_6_io   ( hyper_dq[6] ),
    .hyperbus_dq_7_io   ( hyper_dq[7] ),
    // .hyperbus_clk_phy_io( hyper_clk_phy_i),
    // .hyperbus_rst_phy_n_io ( hyper_rst_phy_ni),
    .hyperbus_reset_n_io ( hyper_reset_no )
  );


  ///////////////
  // HyperBus  //
  //////////////

  s27ks0641 i_hyper (
    .RWDS ( hyper_rwds ),
    .CSNeg ( hyper_cs_no ),
    .CK ( hyper_ck_o ),
    .CKNeg ( hyper_ck_no ),
    .RESETNeg ( hyper_reset_no ),
    .DQ0 ( hyper_dq[0] ),
    .DQ1 ( hyper_dq[1] ),
    .DQ2 ( hyper_dq[2] ),
    .DQ3 ( hyper_dq[3] ),
    .DQ4 ( hyper_dq[4] ),
    .DQ5 ( hyper_dq[5] ),
    .DQ6 ( hyper_dq[6] ),
    .DQ7 ( hyper_dq[7] )
  );

  ///////////
  //  VIP  //
  ///////////

  vip_cheshire_soc #(
    .DutCfg            ( IguanaCfg ),
    .axi_ext_llc_req_t ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t )
  ) vip (.*);

endmodule