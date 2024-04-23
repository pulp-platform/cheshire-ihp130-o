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
set SLO_PHY_RCLK_REG [get_fanin -to $CHESHIRE.slink_rcv_clk_o -startpoints_only -only_cells]
set SLO_PHY_RCLK_Q   [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_OUTP_PIN"]
set SLO_PHY_RCLK_CLK [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_CLK_PIN"]

# SYNTHESIS:
# preserve all modules of type 'cdc_?phase_*' (2phase and 4phase) 
# so we can use the ports to find asyncs
# preserver all modules of type 'clint_sync_*' so we can use serial_i to find the first register
# (remember: OpenROAD flattens to ports are now nets)
set ASYNC_PINS_DMIREQ [get_nets $CHS_DEBUG/i_dmi_cdc/i_cdc_req/*async_*]
set ASYNC_PINS_DMIRSP [get_nets $CHS_DEBUG/i_dmi_cdc/i_cdc_resp/*async_*]
set ASYNC_PINS_SLIN   [get_nets $CHS_SLINK_RX/i_cdc_in/async_*]
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
set HYP_RX_DLINV  $HYPERBUS_PHY.i_trx.i_rwds_clk_inverter.i_inv
set HYP_DDR_MUXES $HYPERBUS_PHY.i_trx.gen_ddr_tx_data.*.i_ddr_tx_data.i_ddrmux.i_mux


#############################
## Driving Cells and Loads ##
#############################

# As a default, drive multiple GPIO pads and be driven by such a pad.
# ixc013_i16x PAD Pin = 1.10943 pF; accomodate for driving up to 12 such pads
set_load [expr 12 * 1.10943] [all_outputs]
set_driving_cell [all_inputs] -lib_cell ixc013_b16m -pin PAD

# Serial link drives one pad per IO, but may have larger capacity (e.g. FPGA)
set PINS_SL_FAST [get_ports {slink_clk_o slink_*_o}]
set_load -min 3 ${PINS_SL_FAST}
set_load -max 9 ${PINS_SL_FAST}

# See S*KL* family hyperram data sheet
set PINS_HYP_FAST [get_ports hyper_*]
set_load -min 3 ${PINS_HYP_FAST}
set_load -max 9 ${PINS_HYP_FAST}


##################
## Input Clocks ##
##################
puts "Clocks..."

# We target 90 MHz
set TCK_SYS 11.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 50.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports rtc_i]

set TCK_SLI [expr 4 * $TCK_SYS]
create_clock -name clk_sli -period $TCK_SLI [get_ports slink_clk_i]

set TCK_USB [expr 1000/48]
create_clock -name clk_usb -period $TCK_USB [get_ports test_mode_i]

# Model incoming Hyperbus RWDS clock as shifted system clock leaving chip via Hyperbus CK pad, 
# going through a HyperRAM device, and back to our RWDS pad (defined on pad to enable RWDS output delay constraint):
# * System clock pad input delay (TT 0.9ns @ hyper capacities)
# * Quarter-period delay line
# * Hyperbus CK pad output delay (TT 3.2ns @ hyper capacities)
# * HyperRAM device read CK -> RWDS flank delay (avg. 5.75ns) 
# * Round-trip PCB wiring delay (1.04ns, 2*8cm at 0.5c).
# Datasheet: https://www.infineon.com/dgdl/Infineon-S27KL0642_S27KS0642_3.0_V_1.8_V_64_Mb_(8_MB)_HyperRAM_Self-Refresh_DRAM-DataSheet-v09_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ee8a1c47164
set HYP_TGT_DLY [expr $TCK_SYS / 4]
set HYP_ASM_RTT [expr fmod(0.9 + $HYP_TGT_DLY + 3.2 + 5.75 + 1.04, $TCK_SYS)]
set HYP_RWDSI_FORM [list [expr $HYP_ASM_RTT] [expr $HYP_ASM_RTT + $TCK_SYS / 2]]
create_clock -name clk_hyp_rwdsi -period $TCK_SYS -waveform $HYP_RWDSI_FORM [get_pins pad_hyper_rwds.i_pad/PAD]


######################
## Generated Clocks ##
######################

# Create slow clock driving TX output (worst case: divided by 4)
puts "SLINK slow TX clk: master-clk from [get_full_name $SLO_PHY_TCLK_CLK] & drives pins [get_full_name $SLO_PHY_TCLK_Q]"
create_generated_clock -name clk_gen_slo_drv \
    -edges {1 5 9} \
    -source $SLO_PHY_TCLK_CLK \
    $SLO_PHY_TCLK_Q

# Create clock for serial link TX (worst case: divided by 4, +90 deg)
puts "SLINK slow RX clk: master-clk from [get_full_name $SLO_PHY_RCLK_CLK] & drives pins [get_full_name $SLO_PHY_RCLK_Q]"
create_generated_clock -name clk_gen_slo \
    -edges {3 7 11} \
    -source $SLO_PHY_RCLK_CLK \
    $SLO_PHY_RCLK_Q

set HYP_MIN_DLY 0.5
set_assigned_delay -corner ff -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner ff -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_TGT_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_TGT_DLY

# Do not produce timing arcs from the TX back to the RX clock or from the RX clock to its TX-timed IO
set_false_path -from [get_ports hyper_rwds_io] -through [get_pins pad_hyper_rwds.i_pad/PAD]
set_false_path -from [get_clocks clk_hyp_rwdsi] -to [get_ports hyper_rwds_io]
# ToDo: This looks extremely suspicious to me, doesn't this false-path all paths from hyper_rwds_io to everywhere
# meaning it is only timed as an output and even then with big exceptions?

# the clk is used to mux between output data (to make it double-data rate)
# this makes sure the clock-tree does not bleed through the mux into the data paths
set_sense -clock -stop_propagation [get_pins $HYP_DDR_MUXES/S]


##################################
## Clock Groups & Uncertainties ##
##################################

# Define which collections of clocks are asynchronous to each other
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys clk_gen_slo clk_gen_slo_drv clk_hyp_rwdsi} \
     -group {clk_sli} \
     -group {clk_usb}

# We set reasonable uncertainties and transitions for all nonvirtual clocks
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


####################
## Cdcs and Syncs ##
####################
puts "CDC/Sync..."

# We do *not* false-path *any* Cdcs in the Hyperbus, as all clocks (System, PHY, return) are plesiochronous.
# Instead, we leverage regular STA to avoid hold violations (RX --> PHY uses a RTT estimate, which may be
# corrected if needed with the RX delay line.) This includes the following ignored crossings:
# * i_iguana/i_hyperbus/i_cdc_2phase_trans
# * i_iguana/i_hyperbus/i_cdc_2phase_b
# * i_iguana/i_hyperbus/i_cdc_fifo_tx
# * i_iguana/i_hyperbus/i_cdc_fifo_rx
# * i_iguana/i_hyperbus/i_phy/genblk1.i_phy/i_trx/i_rx_rwds_cdc_fifo

# For the following input syncs, no constraints are necessary as model their inputs as source-synchronous.
# Even if they are not, their clocks do not drive any on-chip logic, so are completely outside STA:
# * i_iguana/i_cheshire_soc/i_plic/u_prim_flop_2sync/gen_syncs[*].i_sync
# * i_iguana/i_cheshire_soc/gen_i2c.i_i2c/i2c_core/u_i2c_sync_scl/gen_syncs[0].i_sync
# * i_iguana/i_cheshire_soc/gen_i2c.i_i2c/i2c_core/u_i2c_sync_sda/gen_syncs[0].i_sync

# Constrain `cdc_2phase` for DMI request
set_false_path -hold                  -through $ASYNC_PINS_DMIREQ
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_DMIREQ -ignore_clock_latency

# Constrain `cdc_2phase` for DMI response
set_false_path -hold                  -through $ASYNC_PINS_DMIRSP
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_DMIRSP -ignore_clock_latency

# Constrain `cdc_fifo_gray` for serial link in
set_false_path -hold                  -through $ASYNC_PINS_SLIN
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_SLIN -ignore_clock_latency

# Constrain CLINT RTC sync
set_false_path -hold                  -to $ASYNC_PINS_CLINT
set_max_delay  [expr $TCK_SYS * 0.35] -to $ASYNC_PINS_CLINT -ignore_clock_latency

#############
## SoC Ins ##
#############
puts "Input/Outputs..."

# We assume test mode is disabled. This is required to stop spurious clock propagation at some muxes
# set_case_analysis 0 [get_ports test_mode_i]

# Reset and boot mode should propagate to system domain within a clock cycle.
# the reset synchronizer makes sure de-assertion should be within the first clock half-cycle
# `network_latency_included` ensures IO timing w.r.t. the *externally applied*
# clock (i.e. the one at the clock pad_instead of the internal clock tree.
set_input_delay -min -add_delay -clock clk_sys -network_latency_included [ expr $TCK_SYS * 0.10 ] [get_ports {rst_ni boot_mode_*_i}]
set_input_delay -max -add_delay -clock clk_sys -network_latency_included [ expr $TCK_SYS * 0.50 ] [get_ports {rst_ni boot_mode_*_i}]

# Test mode can propagate to all domains within reasonable delay
set_false_path -hold                    -from [get_ports test_mode_i]
set_max_delay  [ expr $TCK_SYS * 0.75 ] -from [get_ports test_mode_i]

##########
## JTAG ##
##########
puts "JTAG..."

set_input_delay  -min -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.10 ]     [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.50 ]     [get_ports {jtag_tdi_i jtag_tms_i}]
set_output_delay -min -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.10 / 2 ] [get_ports jtag_tdo_o]
set_output_delay -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.50 / 2 ] [get_ports jtag_tdo_o]

set_max_delay $TCK_JTG  -from [get_ports jtag_trst_ni]
set_false_path -hold    -from [get_ports jtag_trst_ni]


#########
## VGA ##
#########
puts "VGA..."

# Allow VGA IO to take two cycles to propagate
set VGA_IO_CYC 2

# Time all IO (*including* generated hsync and vsync) with the internal system clock
# which launches and captures it. Since we are the master and provide clocks (hsync
# and vsync), IO timing w.r.t our own external clock is not a requirement
set_multicycle_path -setup $VGA_IO_CYC              -to [get_ports vga_*]
set_multicycle_path -hold  [ expr $VGA_IO_CYC - 1 ] -to [get_ports vga_*]

set_output_delay -min -add_delay -clock clk_sys -reference_pin $VGA_REFPIN [expr $TCK_SYS * $VGA_IO_CYC * 0.10] [get_ports vga_*]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $VGA_REFPIN [expr $TCK_SYS * $VGA_IO_CYC * 0.35] [get_ports vga_*]


##############
## SPI Host ##
##############
puts "SPI..."

# Allow SPI Host IO to take two cycles to propagate
set SPIH_IO_CYC 2

# Time all IO (*including* generated clock) with the system clock which launches and captures it
set_multicycle_path -setup $SPIH_IO_CYC              -to [get_ports spih*]
set_multicycle_path -hold  [ expr $SPIH_IO_CYC - 1 ] -to [get_ports spih*]

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.10 ] [get_ports spih_sd*]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports spih_sd*]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.10 ] [get_ports {spih_sck_o spih_sd* spih_csb*}]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports {spih_sck_o spih_sd* spih_csb*}]

#########
## I2C ##
#########
puts "I2C..."

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]


##########
## UART ##
##########
puts "UART..."

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports uart_rx_i]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports uart_rx_i]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports uart_tx_o]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports uart_tx_o]


##########
## GPIO ##
##########
puts "GPIO..."

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports gpio_*_io]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports gpio_*_io]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports gpio_*_io]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports gpio_*_io]


#################
## Serial Link ##
#################
puts "Serial Link..."

set SL_MAX_SKEW 0.55
set SL_IN       [get_ports slink_?_i]
set SL_OUT      [get_ports slink_?_o]
set SL_OUT_CLK  [get_ports slink_clk_o]

# DDR Input: Maximize assumed *transition* (unstable) interval by maximizing input delay span.
# Transitions happen *between* sampling input clock edges, so centered around T/4 *after* sampling edges.
# We assume that the transition takes up almost a full half period, so (T/4 - (T/4-skew), T/4 + (T/4-skew)).
set_input_delay -min -add_delay             -clock clk_sli -network_latency_included [expr               + $SL_MAX_SKEW] $SL_IN
set_input_delay -min -add_delay -clock_fall -clock clk_sli -network_latency_included [expr               + $SL_MAX_SKEW] $SL_IN
set_input_delay -max -add_delay             -clock clk_sli -network_latency_included [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN
set_input_delay -max -add_delay -clock_fall -clock clk_sli -network_latency_included [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN

# DDR Output: Maximize *stable* interval we provide by maximizing output delay span (i.e. range in
# which the target device may sample). This allows our outputs to transition only in a small margin.
# The stable interval is centered around the centered clock sent for sampling, so (-T/4+skew, T/4-skew)
set_output_delay -min -add_delay             -clock clk_gen_slo -reference_pin $SL_OUT_CLK [expr -$TCK_SLI / 4 + $SL_MAX_SKEW] $SL_OUT
set_output_delay -min -add_delay -clock_fall -clock clk_gen_slo -reference_pin $SL_OUT_CLK [expr -$TCK_SLI / 4 + $SL_MAX_SKEW] $SL_OUT
set_output_delay -max -add_delay             -clock clk_gen_slo -reference_pin $SL_OUT_CLK [expr  $TCK_SLI / 4 - $SL_MAX_SKEW] $SL_OUT
set_output_delay -max -add_delay -clock_fall -clock clk_gen_slo -reference_pin $SL_OUT_CLK [expr  $TCK_SLI / 4 - $SL_MAX_SKEW] $SL_OUT

# Do not consider noncritical edges between driving and sent TX clock
set_false_path -setup -rise_from [get_clocks clk_gen_slo_drv] -rise_to [get_clocks clk_gen_slo]
set_false_path -setup -fall_from [get_clocks clk_gen_slo_drv] -fall_to [get_clocks clk_gen_slo]
set_false_path -hold  -rise_from [get_clocks clk_gen_slo_drv] -fall_to [get_clocks clk_gen_slo]
set_false_path -hold  -fall_from [get_clocks clk_gen_slo_drv] -rise_to [get_clocks clk_gen_slo]

# Unfortunately, STA considers any cell with a clock and data pins checked with this clock an endpoint.
# Here, we generate the clock `clk_gen_slo_drv` driving the TX data register, then mux TX data with that clock
# to convert from SDR to DDR. Even when the output remains stable, the first-level cells of the converting mux
# may switch, producing an LSB endpoint event on each rising edge when the SDR holding register swaps its data;
# this violates hold on the following falling edge checking the active-low LSB phase.
# TODO @fischeti: This would not happen with a single-s glitch-free clock mux like in hyperbus; consider adapting RTL.
# # Do not allow PHY (System) clock to leak to DDR outputs and be timed as output transitions
# -through [get_pins $SLINK_TX/data_out_q_reg_0_/Q]

# set SLO_CLK_CELLS     [get_cells -filter ref_name==sg13g2_mux2_1 [get_fanout -only_cells -from $SLO_PHY_TCLK_Q]]
set SLO_CLK_CELLS     [get_fanout -only_cells -from $SLO_PHY_TCLK_Q]
set SLO_CLK_MUX_PINS  [get_pins -of_objects $SLO_CLK_CELLS -filter "name == $MUX_CONTROL_PIN"]
set_sense -clock -stop_propagation $SLO_CLK_MUX_PINS


##############
## Hyperbus ##
##############
if { ![info exists ::env(HYPER_CONF)] || $::env(HYPER_CONF) ne "NO_HYPERBUS"} {
  puts "Hyperbus..."
  set HYP_MAX_SLEW 0.55
  set HYP_IO       [get_ports {hyper_dq* hyper_rwds*}]
  set HYP_CS       [get_ports hyper_cs_*]
  set HYP_RST      [get_ports hyper_reset_no]
  set HYP_OUT_CLK  [get_ports hyper_ck_o]

  # DDR Input: As for serial link, maximize the assumed *transition* interval by maximizing input delay span.
  # However here, transitions happen *at* edge-aligned input clock edges, so they are centered *at* the edges.
  # Therefore, the input transition interval becomes (T/4 - (T/4-skew), T/4 + (T/4-skew)).
  set_input_delay -min -add_delay             -clock clk_hyp_rwdsi -network_latency_included [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -min -add_delay -clock_fall -clock clk_hyp_rwdsi -network_latency_included [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -max -add_delay             -clock clk_hyp_rwdsi -network_latency_included [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -max -add_delay -clock_fall -clock clk_hyp_rwdsi -network_latency_included [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO

  # DDR Output: Maximize *stable* interval we provide by maximizing output delay span.
  # This is exactly analogous to the serial link case, as the sending clock is center-aligned with data.
  set_output_delay -min -add_delay             -clock clk_sys -reference_pin $HYP_OUT_CLK [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_output_delay -min -add_delay -clock_fall -clock clk_sys -reference_pin $HYP_OUT_CLK [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_output_delay -max -add_delay             -clock clk_sys -reference_pin $HYP_OUT_CLK [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO
  set_output_delay -max -add_delay -clock_fall -clock clk_sys -reference_pin $HYP_OUT_CLK [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO

  # CS is *synchronous* (edge aligned) with output clock at pad, *not* DDR
  set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr              + $HYP_MAX_SLEW] $HYP_CS
  set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS / 2 - $HYP_MAX_SLEW] $HYP_CS

  # We multicycle the passthrough reset as it does not quite reach through the chip in one cycle
  set_multicycle_path -setup 2 -to $HYP_RST
  set_multicycle_path -hold  1 -to $HYP_RST
  set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.10] $HYP_RST
  set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.35] $HYP_RST
}