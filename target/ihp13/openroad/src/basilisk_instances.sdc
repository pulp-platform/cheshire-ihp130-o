# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Paul Scheffler <paulsc@iis.ee.ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>

# Backend constraints

############
## Global ##
############

# technology dependent
set DFF_CLK_PIN CLK
set DFF_DATA_PIN D
set DFF_OUTP_PIN Q

set MUX_CONTROL_PIN S
set MUX_OUT_PIN X
set CLKGATE_GATE_PIN GATE

# top-level cheshire paths
set CHESHIRE        i_iguana_soc.i_cheshire_soc
set CHS_CLINT       $CHESHIRE.i_clint
set CHS_SLINK       $CHESHIRE.gen_serial_link.i_serial_link
set CHS_SLINK_PHY0  $CHS_SLINK/gen_phy_channels.__0.i_serial_link_physical
set CHS_SLINK_TX    $CHS_SLINK_PHY0.i_serial_link_physical_tx
set CHS_SLINK_RX    $CHS_SLINK_PHY0.i_serial_link_physical_rx
set CHS_VGA         $CHESHIRE.gen_vga.i_axi_vga
set CHS_SPI         $CHESHIRE.gen_spi_host.i_spi_host
set CHS_I2C         $CHESHIRE.gen_i2c.i_i2c
set CHS_UART        $CHESHIRE.gen_uart.i_uart
set CHS_GPIO        $CHESHIRE.gen_gpio.i_gpio
set CHS_DEBUG       $CHESHIRE.i_dbg_dmi_jtag
set HYPERBUS        i_iguana_soc.i_hyperbus
set HYPERBUS_PHY    $HYPERBUS/i_phy.genblk1.i_phy

# NOTE:
# OpenROAD flattens the hierarchy (but leaves '/' in the instance names)
# this means for all ports, it always uses the name of the net connected to the port from the top
# so for .port_o(blabla) it uses blabla and module/port_o is gone.

# SYNTHESIS:
# make sure net clk_slow is preserved by name (should be the case as its a clock)
# preserve module-instance i_serial_link for ddr_rcv_clk_o
set SLO_PHY_TCLK_REG [get_fanin -to $CHS_SLINK_TX/clk_slow -startpoints_only -only_cells]
set SLO_PHY_TCLK_Q   [get_pins -of_objects $SLO_PHY_TCLK_REG -filter "name == $DFF_OUTP_PIN"]
set SLO_PHY_TCLK_CLK [get_pins -of_objects $SLO_PHY_TCLK_REG -filter "name == $DFF_CLK_PIN"]

# port i_serial_link/ddr_rcv_clk_o
set SLO_PHY_RCLK_REG [get_cells *ddr_rcv_clk_o*]
set SLO_PHY_RCLK_Q   [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_OUTP_PIN"]
set SLO_PHY_RCLK_CLK [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_CLK_PIN"]

# SYNTHESIS:
# preserve all modules of type 'cdc_?phase_*' (2phase and 4phase) 
# so we can use the ports to find asyncs
# preserver all modules of type 'clint_sync_*' so we can use serial_i to find the first register
# (remember: OpenROAD flattens so ports are now nets)
set ASYNC_PINS_DMIREQ [get_nets $CHS_DEBUG/i_dmi_cdc/i_cdc_req/*async_*]
set ASYNC_PINS_DMIRSP [get_nets $CHS_DEBUG/i_dmi_cdc/i_cdc_resp/*async_*]
set ASYNC_PINS_SLIN   [get_nets $CHS_SLINK_RX/i_cdc_in/*async_*]
# port i_clint/i_sync_edge/i_sync/serial_i
set CLINT_ASYNC_REG   [lindex [get_fanout -from $CHESHIRE.rtc_i -endpoints_only -only_cells] 0]
set ASYNC_PINS_CLINT  [get_pins -of_objects $CLINT_ASYNC_REG -filter "name == $DFF_DATA_PIN"]

# We define a single leaf register as a reference clock pin for master interfaces to avoid accumulating CTS delays
# this can really be the clock pin of any register in the peripheral
# port i_axi_vga/hsync_o
set VGA_REF_REG  [lindex [get_fanin -to $CHESHIRE.vga_hsync_o -startpoints_only -only_cells] 0]
set VGA_REFPIN   [get_pins -of_objects $VGA_REF_REG -filter "name == $DFF_CLK_PIN"]
# port i_spi_host/cio_csk_o
set SPIH_REF_REG [lindex [get_fanin -to $CHESHIRE.spih_sck_o -startpoints_only -only_cells] 0]
set SPIH_REFPIN  [get_pins -of_objects $SPIH_REF_REG -filter "name == $DFF_CLK_PIN"]
# port i_i2c/cio_scl_i
set I2C_REF_REG  [lindex [get_fanout -from i_iguana_soc.i2c_scl_i -endpoints_only -only_cells] 0]
set I2C_REFPIN   [get_pins -of_objects $I2C_REF_REG -filter "name == $DFF_CLK_PIN"]
# port i_uart/sout_o
set UART_REF_REG [lindex [get_fanin -to $CHESHIRE.uart_tx_o -startpoints_only -only_cells] 0]
set UART_REFPIN  [get_pins -of_objects $UART_REF_REG -filter "name == $DFF_CLK_PIN"]
# port i_gpio/cio_gpio_o_0_
set GPIO_REF_REG [lindex [get_fanin -to i_iguana_soc.gpio32_o_0_ -startpoints_only -only_cells] 0]
set GPIO_REFPIN  [get_pins -of_objects $GPIO_REF_REG -filter "name == $DFF_CLK_PIN"]

set HYP_TX_DLINE  $HYPERBUS/*i_delay_tx_clk_90.i_delay.i_delay_line
set HYP_RX_DLINE  $HYPERBUS_PHY*i_delay_rx_rwds_90.i_delay.i_delay_line
set HYP_RX_DLINV  $HYPERBUS_PHY.i_trx/i_rwds_clk_inverter.i_inv
set HYP_DDR_DATA_MUXES $HYPERBUS_PHY.i_trx/gen_ddr_tx_data.*.i_ddr_tx_data.i_ddrmux.i_mux
set HYP_DDR_RWDS_MUX $HYPERBUS_PHY.i_trx/i_ddr_tx_rwds.i_ddrmux.i_mux