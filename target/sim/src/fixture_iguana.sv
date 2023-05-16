module fixture_iguana;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import iguana_pkg::*;


  ///////////
  //  DUT  //
  ///////////

  logic       clk;
  logic       rst_n;
  logic       test_mode;
  logic [1:0] boot_mode;
  logic       rtc;
  // External AXI LLC (DRAM) port here for implicit connection not needed!!
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
  wire [HyperBusNumPhys-1:0][HyperBusNumChips-1:0] hyper_cs_no;
  wire [HyperBusNumPhys-1:0]               hyper_ck_o;
  wire [HyperBusNumPhys-1:0]               hyper_ck_no;
  wire [HyperBusNumPhys-1:0]               hyper_rwds;
  wire [HyperBusNumPhys-1:0][7:0]          hyper_dq;
  wire [HyperBusNumPhys-1:0]               hyper_reset_no;
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
    .hyperbus_dq_0_io   ( hyper_dq[0][0] ),
    .hyperbus_dq_1_io   ( hyper_dq[0][1] ),
    .hyperbus_dq_2_io   ( hyper_dq[0][2] ),
    .hyperbus_dq_3_io   ( hyper_dq[0][3] ),
    .hyperbus_dq_4_io   ( hyper_dq[0][4] ),
    .hyperbus_dq_5_io   ( hyper_dq[0][5] ),
    .hyperbus_dq_6_io   ( hyper_dq[0][6] ),
    .hyperbus_dq_7_io   ( hyper_dq[0][7] ),
    .hyperbus_clk_phy_io( clk ),
    .hyperbus_rst_phy_n_io ( rst_n ),
    .hyperbus_reset_n_io ( hyper_reset_no )
  );


  ///////////////
  // HyperBus  //
  //////////////

  // use generate for multi chip or phy (look into hyperbus_fixture)
  s27ks0641 # (
    .TimingModel   ( "S27KS0641DPBHI020"    )
  ) i_hyper ( // needs to be named i_hyper as we patch that it sdf annotation works
    .RWDS ( hyper_rwds ),
    .CSNeg ( hyper_cs_no ),
    .CK ( hyper_ck_o ),
    .CKNeg ( hyper_ck_no ),
    .RESETNeg ( hyper_reset_no ),
    .DQ0 ( hyper_dq[0][0] ),
    .DQ1 ( hyper_dq[0][1] ),
    .DQ2 ( hyper_dq[0][2] ),
    .DQ3 ( hyper_dq[0][3] ),
    .DQ4 ( hyper_dq[0][4] ),
    .DQ5 ( hyper_dq[0][5] ),
    .DQ6 ( hyper_dq[0][6] ),
    .DQ7 ( hyper_dq[0][7] )
  );


  initial begin
      automatic string sdf_file_path = "../models/s27ks0641.sdf";
      $sdf_annotate(sdf_file_path, i_hyper);
  end

  ///////////
  //  VIP  //
  ///////////

  vip_cheshire_soc #(
    .DutCfg            ( IguanaCfg ),
    .axi_ext_llc_req_t ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t )
  ) vip (.*);

endmodule