// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>
// - Tobias Senti <tsenti@student.ethz.ch>
// - Paul Scheffler <paulsc@iis.ee.ethz.ch>

module iguana_soc import iguana_pkg::*; import cheshire_pkg::*; (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic [1:0]  boot_mode_i,
  input  logic        rtc_i,
  // JTAG interface
  input  logic  jtag_tck_i,
  input  logic  jtag_trst_ni,
  input  logic  jtag_tms_i,
  input  logic  jtag_tdi_i,
  output logic  jtag_tdo_o,
  output logic  jtag_tdo_oe_o,
  // UART interface
  output logic  uart_tx_o,
  input  logic  uart_rx_i,
  // I2C interface
  output logic  i2c_sda_o,
  input  logic  i2c_sda_i,
  output logic  i2c_sda_en_o,
  output logic  i2c_scl_o,
  input  logic  i2c_scl_i,
  output logic  i2c_scl_en_o,
  // SPI host interface
  output logic                  spih_sck_o,
  output logic                  spih_sck_en_o,
  output logic [SpihNumCs-1:0]  spih_csb_o,
  output logic [SpihNumCs-1:0]  spih_csb_en_o,
  output logic [ 3:0]           spih_sd_o,
  output logic [ 3:0]           spih_sd_en_o,
  input  logic [ 3:0]           spih_sd_i,
  // GPIO/USB interface
  input logic                     usb_clk_i,
  input  logic [GpioNumWired-1:0] gpio_i,
  output logic [GpioNumWired-1:0] gpio_o,
  output logic [GpioNumWired-1:0] gpio_en_o,
  // Serial link interface
  input  logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
  output logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,
  input  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
  output logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
  // VGA interface
  output logic                                  vga_hsync_o,
  output logic                                  vga_vsync_o,
  output logic [VgaOutRedWidth-1:0]  vga_red_o,
  output logic [VgaOutRedWidth-1:0]  vga_green_o,
  output logic [VgaOutRedWidth-1:0]  vga_blue_o,
  // Hyperbus
  output logic [HypNumPhys-1:0][HypNumChips-1:0]  hyper_cs_no,
  output logic [HypNumPhys-1:0]                   hyper_ck_o,
  output logic [HypNumPhys-1:0]                   hyper_ck_no,
  output logic [HypNumPhys-1:0]                   hyper_rwds_o,
  input  logic [HypNumPhys-1:0]                   hyper_rwds_i,
  output logic [HypNumPhys-1:0]                   hyper_rwds_oe_o,
  input  logic [HypNumPhys-1:0][7:0]              hyper_dq_i,
  output logic [HypNumPhys-1:0][7:0]              hyper_dq_o,
  output logic [HypNumPhys-1:0]                   hyper_dq_oe_o,
  output logic [HypNumPhys-1:0]                   hyper_reset_no
);

  // Internal connections for Hyperbus
  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  reg_req_t [CheshireCfg.RegExtNumSlv-1:0] reg_ext_slv_req;
  reg_rsp_t [CheshireCfg.RegExtNumSlv-1:0] reg_ext_slv_rsp;

  logic [CheshireCfg.VgaRedWidth-1  :0] vga_red;
  logic [CheshireCfg.VgaGreenWidth-1:0] vga_green;
  logic [CheshireCfg.VgaBlueWidth-1 :0] vga_blue;

  assign vga_red_o   = vga_red  [CheshireCfg.VgaRedWidth-1   -:VgaOutRedWidth  ];
  assign vga_green_o = vga_green[CheshireCfg.VgaGreenWidth-1 -:VgaOutGreenWidth];
  assign vga_blue_o  = vga_blue [CheshireCfg.VgaBlueWidth-1  -:VgaOutBlueWidth ];

  // for GPIO width conversion (implicit)
  logic [31:0] gpio32_i;
  logic [31:0] gpio32_o;
  logic [31:0] gpio32_en_o;

  // assign gpio32_i   = gpio_i;
  // assign gpio_o     = gpio32_o;
  // assign gpio_en_o  = gpio32_en_o;

  // USB
  logic [UsbNumPorts-1:0] usb_dm_i;
  logic [UsbNumPorts-1:0] usb_dm_o;
  logic [UsbNumPorts-1:0] usb_dm_oe_o;
  logic [UsbNumPorts-1:0] usb_dp_i;
  logic [UsbNumPorts-1:0] usb_dp_o;
  logic [UsbNumPorts-1:0] usb_dp_oe_o;

  always_comb begin : io_mux
    // default: connect GPIO
    gpio32_i  = gpio_i;
    gpio_o    = gpio32_o;
    gpio_en_o = gpio32_en_o;
    // valid USB defaults
    usb_dm_i = '0;
    usb_dp_i = {UsbNumPorts{1'b1}};

    // if USB-enable bits in GPIO (MSBs) are set, connect USB
    // Port 0
    if(gpio32_o[28]) begin
      usb_dm_i[0] = gpio_i[0];
      usb_dp_i[0] = gpio_i[1];
      gpio_o[0] = usb_dm_o[0];
      gpio_o[1] = usb_dp_o[0];
      gpio_en_o[0] = usb_dm_oe_o[0];
      gpio_en_o[1] = usb_dp_oe_o[0];
     end
     // Port 1
    if(gpio32_o[29]) begin
      usb_dm_i[1] = gpio_i[2];
      usb_dp_i[1] = gpio_i[3];
      gpio_o[2] = usb_dm_o[1];
      gpio_o[3] = usb_dp_o[1];
      gpio_en_o[2] = usb_dm_oe_o[1];
      gpio_en_o[3] = usb_dp_oe_o[1];
     end
     // Port 2
    if(gpio32_o[30]) begin
      usb_dm_i[2] = gpio_i[4];
      usb_dp_i[2] = gpio_i[5];
      gpio_o[4] = usb_dm_o[2];
      gpio_o[5] = usb_dp_o[2];
      gpio_en_o[4] = usb_dm_oe_o[2];
      gpio_en_o[5] = usb_dp_oe_o[2];
     end
     // Port 3
    if(gpio32_o[31]) begin
      usb_dm_i[3] = gpio_i[6];
      usb_dp_i[3] = gpio_i[7];
      gpio_o[6] = usb_dm_o[3];
      gpio_o[7] = usb_dp_o[3];
      gpio_en_o[6] = usb_dm_oe_o[3];
      gpio_en_o[7] = usb_dp_oe_o[3];
     end
     
  end

  // Global reset synchronizer
  logic synced_rst_n;

  rstgen i_rstgen (
    .clk_i,
    .rst_ni,
    .test_mode_i,
    .rst_no  ( synced_rst_n ),
    .init_no ( )
  );

  // Cheshire
  cheshire_soc #(
    .Cfg                ( CheshireCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_rsp_t )
  ) i_cheshire_soc (
    .clk_i,
    .rst_ni             ( synced_rst_n ),
    .test_mode_i        ( 1'b0 ),
    .boot_mode_i,
    .rtc_i,
    // External AXI LLC (DRAM) port
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    // External AXI crossbar ports
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( ),
    .axi_ext_slv_rsp_i  ( '0 ),
    // External reg demux slaves
    .reg_ext_slv_req_o  ( reg_ext_slv_req ),
    .reg_ext_slv_rsp_i  ( reg_ext_slv_rsp ),
    // Interrupts from and to external targets
    .intr_ext_i         ( '0 ),
    .intr_ext_o         ( ),
    // Interrupt requests to external harts
    .xeip_ext_o         ( ),
    .mtip_ext_o         ( ),
    .msip_ext_o         ( ),
    // Debug interface to external harts
    .dbg_active_o       ( ),
    .dbg_ext_req_o      ( ),
    .dbg_ext_unavail_i  ( '0 ),
    // JTAG interface
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o,
    // UART interface
    .uart_tx_o,
    .uart_rx_i,
    // UART modem flow control
    .uart_rts_no        ( ),
    .uart_dtr_no        ( ),
    .uart_cts_ni        ( 1'b0 ),
    .uart_dsr_ni        ( 1'b0 ),
    .uart_dcd_ni        ( 1'b0 ),
    .uart_rin_ni        ( 1'b0 ),
    // I2C interface
    .i2c_sda_o,
    .i2c_sda_i,
    .i2c_sda_en_o,
    .i2c_scl_o,
    .i2c_scl_i,
    .i2c_scl_en_o,
    // SPI host interface
    .spih_sck_o,
    .spih_sck_en_o,
    .spih_csb_o,
    .spih_csb_en_o,
    .spih_sd_o,
    .spih_sd_en_o,
    .spih_sd_i,
    // GPIO interface
    .gpio_i             ( gpio32_i    ),
    .gpio_o             ( gpio32_o    ),
    .gpio_en_o          ( gpio32_en_o ),
    // Serial link interface
    .slink_rcv_clk_i,
    .slink_rcv_clk_o,
    .slink_i,
    .slink_o,
    // VGA interface
    .vga_hsync_o,
    .vga_vsync_o,
    .vga_red_o          ( vga_red   ),
    .vga_green_o        ( vga_green ),
    .vga_blue_o         ( vga_blue  ),
    // USB interface
    .usb_clk_i,
    .usb_rst_ni         ( synced_rst_n ),
    .usb_dm_i,
    .usb_dm_o,
    .usb_dm_oe_o,
    .usb_dp_i,
    .usb_dp_o,
    .usb_dp_oe_o
  );

  `ifndef NO_HYPERBUS
  // Hyperbus interface
  hyperbus #(
    .NumChips         ( HypNumChips ),
    .NumPhys          ( HypNumPhys  ),
    .IsClockODelayed  ( 1 ),
    .AxiAddrWidth     ( CheshireCfg.AddrWidth    ),
    .AxiDataWidth     ( CheshireCfg.AxiDataWidth ),
    .AxiIdWidth       ( $bits(axi_llc_id_t)      ),
    .AxiUserWidth     ( CheshireCfg.AxiUserWidth ),
    .axi_req_t        ( axi_llc_req_t     ),
    .axi_rsp_t        ( axi_llc_rsp_t     ),
    .axi_w_chan_t     ( axi_llc_w_chan_t  ),
    .axi_b_chan_t     ( axi_llc_b_chan_t  ),
    .axi_ar_chan_t    ( axi_llc_ar_chan_t ),
    .axi_r_chan_t     ( axi_llc_r_chan_t  ),
    .axi_aw_chan_t    ( axi_llc_aw_chan_t ),
    .RegAddrWidth     ( CheshireCfg.AddrWidth ),
    .RegDataWidth     ( 32 ),
    .reg_req_t        ( reg_req_t ),
    .reg_rsp_t        ( reg_rsp_t ),
    .axi_rule_t       ( hyper_addr_rule_t ),
    .RstChipBase      ( 32'(CheshireCfg.LlcOutRegionStart) ),
    .RstChipSpace     ( 32'(HypRstChipBytes) )
  ) i_hyperbus (
    // WARNING: Keeping system and PHY synchronous works only with careful constraints.
    // DO NOT copy-paste this to other projects without consideration; you were warned.
    .clk_phy_i        ( clk_i        ),
    .rst_phy_ni       ( synced_rst_n ),
    .clk_sys_i        ( clk_i        ),
    .rst_sys_ni       ( synced_rst_n ),
    .test_mode_i,
    .axi_req_i        ( axi_llc_mst_req ),
    .axi_rsp_o        ( axi_llc_mst_rsp ),
    .reg_req_i        ( reg_ext_slv_req ),
    .reg_rsp_o        ( reg_ext_slv_rsp ),
    .hyper_cs_no,
    .hyper_ck_o,
    .hyper_ck_no,
    .hyper_rwds_o,
    .hyper_rwds_i,
    .hyper_rwds_oe_o,
    .hyper_dq_i,
    .hyper_dq_o,
    .hyper_dq_oe_o,
    .hyper_reset_no
  );
  `else
    assign axi_llc_mst_rsp  =  '0;
    assign reg_ext_slv_rsp  =  '0;
    assign hyper_cs_no      = 1'b1;
    assign hyper_ck_o       = 1'b0;
    assign hyper_ck_no      = 1'b1;
    assign hyper_rwds_o     = 1'b0;
    assign hyper_rwds_oe_o  = 1'b0;
    assign hyper_dq_o       =  '0;
    assign hyper_dq_oe_o    = 1'b0;
    assign hyper_reset_no   = 1'b1;
  `endif

endmodule
