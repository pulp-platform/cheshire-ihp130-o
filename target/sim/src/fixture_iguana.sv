module fixture_iguana;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import iguana_pkg::*;

  ///////////
  //  DUT  //
  ///////////

  wire       clk;
  wire       rst_n;
  wire       test_mode;
  wire [1:0] boot_mode;
  wire       rtc;

  wire jtag_tck;
  wire jtag_trst_n;
  wire jtag_tms;
  wire jtag_tdi;
  wire jtag_tdo;

  wire uart_tx;
  wire uart_rx;

  wire i2c_sda;
  wire i2c_scl;

  wire                 spih_sck;
  wire [SpihNumCs-1:0] spih_csb;
  wire [ 3:0]          spih_sd;

  wire [GpioNumWired-1:0] gpio;

  wire [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  wire [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  wire [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  wire [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

  wire [HypNumPhys-1:0][HypNumChips-1:0]  hyper_cs_no;
  wire [HypNumPhys-1:0]                   hyper_ck_o;
  wire [HypNumPhys-1:0]                   hyper_ck_no;
  wire [HypNumPhys-1:0]                   hyper_rwds;
  wire [HypNumPhys-1:0][7:0]              hyper_dq;
  wire [HypNumPhys-1:0]                   hyper_reset_no;

  iguana_chip i_dut (
    .clk_i          ( clk   ),
    .rst_ni         ( rst_n ),
    .test_mode_i    ( test_mode    ),
    .boot_mode_0_i  ( boot_mode[0] ),
    .boot_mode_1_i  ( boot_mode[1] ),
    .rtc_i          ( rtc ),
    .jtag_tck_i     ( jtag_tck    ),
    .jtag_trst_ni   ( jtag_trst_n ),
    .jtag_tms_i     ( jtag_tms    ),
    .jtag_tdi_i     ( jtag_tdi    ),
    .jtag_tdo_o     ( jtag_tdo    ),
    .uart_tx_o      ( uart_tx ),
    .uart_rx_i      ( uart_rx ),
    .i2c_sda_io     ( i2c_sda ),
    .i2c_scl_io     ( i2c_scl ),
    .spih_sck_o     ( spih_sck    ),
    .spih_csb_0_o   ( spih_csb[0] ),
    .spih_csb_1_o   ( spih_csb[1] ),
    .spih_sd_0_io   ( spih_sd[0]  ),
    .spih_sd_1_io   ( spih_sd[1]  ),
    .spih_sd_2_io   ( spih_sd[2]  ),
    .spih_sd_3_io   ( spih_sd[3]  ),
    .gpio_0_io      ( gpio[ 0] ),
    .gpio_1_io      ( gpio[ 1] ),
    .gpio_2_io      ( gpio[ 2] ),
    .gpio_3_io      ( gpio[ 3] ),
    .gpio_4_io      ( gpio[ 4] ),
    .gpio_5_io      ( gpio[ 5] ),
    .gpio_6_io      ( gpio[ 6] ),
    .gpio_7_io      ( gpio[ 7] ),
    .gpio_8_io      ( gpio[ 8] ),
    .gpio_9_io      ( gpio[ 9] ),
    .gpio_10_io     ( gpio[10] ),
    .gpio_11_io     ( gpio[11] ),
    .slink_clk_i    ( slink_rcv_clk_i[0] ),
    .slink_0_i      ( slink_i[0][0] ),
    .slink_1_i      ( slink_i[0][1] ),
    .slink_2_i      ( slink_i[0][2] ),
    .slink_3_i      ( slink_i[0][3] ),
    .slink_clk_o    ( slink_rcv_clk_o[0] ),
    .slink_0_o      ( slink_o[0][0] ),
    .slink_1_o      ( slink_o[0][1] ),
    .slink_2_o      ( slink_o[0][2] ),
    .slink_3_o      ( slink_o[0][3] ),
    .vga_hsync_o    (  ),
    .vga_vsync_o    (  ),
    .vga_red_0_o    (  ),
    .vga_red_1_o    (  ),
    .vga_red_2_o    (  ),
    .vga_green_0_o  (  ),
    .vga_green_1_o  (  ),
    .vga_green_2_o  (  ),
    .vga_blue_0_o   (  ),
    .vga_blue_1_o   (  ),
    .hyper_reset_no ( hyper_reset_no ),
    .hyper_cs_0_no  ( hyper_cs_no[0][0] ),
    .hyper_cs_1_no  ( hyper_cs_no[0][1] ),
    .hyper_ck_o     ( hyper_ck_o  ),
    .hyper_ck_no    ( hyper_ck_no ),
    .hyper_rwds_io  ( hyper_rwds  ),
    .hyper_dq_0_io  ( hyper_dq[0][0] ),
    .hyper_dq_1_io  ( hyper_dq[0][1] ),
    .hyper_dq_2_io  ( hyper_dq[0][2] ),
    .hyper_dq_3_io  ( hyper_dq[0][3] ),
    .hyper_dq_4_io  ( hyper_dq[0][4] ),
    .hyper_dq_5_io  ( hyper_dq[0][5] ),
    .hyper_dq_6_io  ( hyper_dq[0][6] ),
    .hyper_dq_7_io  ( hyper_dq[0][7] )
  );

  ///////////////
  // HyperBus  //
  //////////////

  for (genvar i=0; i<HypNumChips; i++) begin : gen_hyp_chips

    s27ks0641 #(
      .TimingModel ( "S27KS0641DPBHI020" )
    ) i_hyper (
      .CK       ( hyper_ck_o  ),
      .CKNeg    ( hyper_ck_no ),
      .RESETNeg ( hyper_reset_no ),
      .RWDS     ( hyper_rwds[0] ),
      .CSNeg    ( hyper_cs_no[0][i] ),
      .DQ0      ( hyper_dq[0][0] ),
      .DQ1      ( hyper_dq[0][1] ),
      .DQ2      ( hyper_dq[0][2] ),
      .DQ3      ( hyper_dq[0][3] ),
      .DQ4      ( hyper_dq[0][4] ),
      .DQ5      ( hyper_dq[0][5] ),
      .DQ6      ( hyper_dq[0][6] ),
      .DQ7      ( hyper_dq[0][7] )
    );

    initial $sdf_annotate("../models/s27ks0641.sdf", i_hyper);

  end

  ///////////
  //  VIP  //
  ///////////

  // External AXI LLC (DRAM) port stub
  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  assign axi_llc_mst_req = '0;

  vip_cheshire_soc #(
    .DutCfg             ( CheshireCfg ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .ClkPeriodSys       ( 10ns ),
    .ClkPeriodJtag      ( 40ns ),
    .RstCycles          ( 20 )
  ) vip (.*);

endmodule
