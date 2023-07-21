############
## Global ##
############

# The following are some internal references whose paths might change across stages
set SLO_PHY_TCLK_CLK [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_tx.clk_slow_\$_DFF_PN0__Q/CLK]
set SLO_PHY_TCLK_Q   [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_tx.clk_slow_\$_DFF_PN0__Q/Q]
set SLO_PHY_RCLK_CLK [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.ddr_rcv_clk_o_\$_DFFE_PN1P__Q/CLK]
set SLO_PHY_RCLK_Q   [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.ddr_rcv_clk_o_\$_DFFE_PN1P__Q/Q]

set SLO_PHY_TCLK_DRC [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_tx.data_out_q_\$_DFF_PN0__Q*/CLK]
set SLO_PHY_TCLK_DRQ [get_pins \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_tx.data_out_q_\$_DFF_PN0__Q*/Q]

set HYP_TX_DLINE  \i_iguana_soc.i_hyperbus.genblk1.genblk1.i_delay_tx_clk_90.i_delay.i_delay_line
set HYP_RX_DLINE  \i_iguana_soc.i_hyperbus.i_phy.genblk1.i_phy.i_trx.i_delay_rx_rwds_90.i_delay.i_delay_line
set HYP_RX_DLINV  \i_iguana_soc.i_hyperbus.i_phy.genblk1.i_phy.i_trx.i_rwds_clk_inverter.i_inv
set HYP_DDR_MUXES \i_iguana_soc.i_hyperbus.i_phy.genblk1.i_phy.i_trx.gen_ddr_tx_data.__*.i_ddr_tx_data.i_ddrmux.i_mux

set ASYNC_PINS_DMIREQ [get_pins -of_objects [get_nets -hierarchical {i_iguana_soc.i_cheshire_soc.i_dbg_dmi_jtag.i_dmi_cdc.i_cdc_req.async_*}]]
set ASYNC_PINS_DMIRSP [get_pins -of_objects [get_nets -hierarchical {i_iguana_soc.i_cheshire_soc.i_dbg_dmi_jtag.i_dmi_cdc.i_cdc_resp.async_*}]]
set ASYNC_PINS_SLIN   [get_pins -of_objects [get_nets -hierarchical {i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_rx.i_cdc_in.async_*}]]
set ASYNC_PINS_CLINT  [get_pins -hierarchical \i_iguana_soc.i_cheshire_soc.i_clint.i_sync_edge.i_sync.reg_q_\$_DFF_PN0__Q/D]

# We define a single leaf register as a reference clock pin for master interfaces to avoid accumulating CTS delays
set VGA_REFPIN  [get_pins \i_iguana_soc.i_cheshire_soc.gen_vga.i_axi_vga.i_axi_vga_timing_fsm.hstate_q_\$_DFF_PN0__Q/CLK]
set SPIH_REFPIN [get_pins \i_iguana_soc.i_cheshire_soc.gen_spi_host.i_spi_host.cio_sck_o_\$_DFFE_PN0N__Q/CLK]
set I2C_REFPIN  [get_pins \i_iguana_soc.i_cheshire_soc.gen_i2c.i_i2c.i2c_core.u_i2c_fsm.scl_i_q_\$_DFF_PN1__Q/CLK]
set UART_REFPIN [get_pins \i_iguana_soc.i_cheshire_soc.gen_uart.i_uart.i_apb_uart.UART_TX.CState_\$_DFF_PN0__Q/CLK]
set GPIO_REFPIN [get_pins \i_iguana_soc.i_cheshire_soc.gen_gpio.i_gpio.data_in_q_\$_DFF_P__Q/CLK]

#############################
## Driving Cells and Loads ##
#############################

# As a default, drive multiple GPIO pads and be driven by such a pad.
# sg13g2_pad_in PAD Pin = 1.10943 pF; accomodate for driving up to 12 such pads
set_load [expr 12 * 1.10943] [all_outputs]
set_driving_cell [all_inputs] -lib_cell sg13g2_pad_io -pin pad_io

# Serial link drives one pad per IO, but may have larger capacity (e.g. FPGA)
set PINS_SL_FAST [get_ports {slink_clk_o slink_*_o}]
set_load -max 3 ${PINS_SL_FAST}
set_load -min 9 ${PINS_SL_FAST}

# See S*KL* family hyperram data sheet
set PINS_HYP_FAST [get_ports hyper_*]
set_load -max 3 ${PINS_HYP_FAST}
set_load -min 9 ${PINS_HYP_FAST}

##################
## Input Clocks ##
##################

# We target 148 MHz
set TCK_SYS 9.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 25.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports rtc_i]

set TCK_SLI [expr 4 * $TCK_SYS]
create_clock -name clk_sli -period $TCK_SLI [get_ports slink_clk_i]

# Model incoming Hyperbus RWDS clock as shifted system clock passing through out chip, a
# HyperRAM device, and back to our pads (defined on pad to enable RWDS output delay constraint):
# * System clock pad input delay (TT 0.9ns @ hyper capacities)
# * Quarter-period delay line
# * Hyper clock pad output delay (TT 3.2ns @ hyper capacities)
# * HyperRAM device read CK -> RWDS flank delay (avg. 5.75ns)
# * Round-trip PCB wiring delay (1.04ns, 2*8cm at 0.5c).
set HYP_TGT_DLY [expr $TCK_SYS / 4]
set HYP_ASM_RTT [expr fmod(0.9 + $HYP_TGT_DLY + 3.2 + 5.75 + 1.04, $TCK_SYS)]
set HYP_RWDSI_FORM [list [expr $HYP_ASM_RTT] [expr $HYP_ASM_RTT + $TCK_SYS / 2]]
create_clock -name clk_hyp_rwdsi -period $TCK_SYS -waveform $HYP_RWDSI_FORM [get_pins \pad_hyper_rwds.i_pad/pad_io]

######################
## Generated Clocks ##
######################

# Create slow clock driving TX output (worst case: divided by 4)
create_generated_clock -name clk_gen_slo_drv \
    -edges {1 5 9} \
    -source $SLO_PHY_TCLK_CLK $SLO_PHY_TCLK_Q

# Create clock for serial link TX (worst case: divided by 4, +90 deg)
create_generated_clock -name clk_gen_slo \
    -edges {3 7 11} \
    -source $SLO_PHY_RCLK_CLK $SLO_PHY_RCLK_Q

set HYP_MIN_DLY 0.5
set_assigned_delay -corner ff -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner ff -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_TGT_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_TGT_DLY

# Do not produce timing arcs from the TX back to the RX clock or from the RX clock to its TX-timed IO
set_false_path -from [get_ports hyper_rwds_io] -through [get_pins \pad_hyper_rwds.i_pad/pad_io]
set_false_path -from [get_clocks clk_hyp_rwdsi] -to [get_ports hyper_rwds_io]

##################################
## Clock Groups & Uncertainties ##
##################################

# Define which collections of clocks are asynchronous to each other
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys clk_gen_slo clk_gen_slo_drv clk_hyp_rwdsi} \
     -group {clk_sli}

# We set reasonable uncertainties and transitions for all nonvirtual clocks
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]

####################
## Cdcs and Syncs ##
####################

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
set_false_path -hold                  -through $ASYNC_PINS_DMIREQ -through $ASYNC_PINS_DMIREQ
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_DMIREQ -through $ASYNC_PINS_DMIREQ -ignore_clock_latency

# Constrain `cdc_2phase` for DMI response
set_false_path -hold                  -through $ASYNC_PINS_DMIRSP -through $ASYNC_PINS_DMIRSP
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_DMIRSP -through $ASYNC_PINS_DMIRSP -ignore_clock_latency

# Constrain `cdc_fifo_gray` for serial link in
set_false_path -hold                  -through $ASYNC_PINS_SLIN -through $ASYNC_PINS_SLIN
set_max_delay  [expr $TCK_SYS * 0.35] -through $ASYNC_PINS_SLIN -through $ASYNC_PINS_SLIN -ignore_clock_latency

# Constrain CLINT RTC sync
set_false_path -hold                  -to $ASYNC_PINS_CLINT
set_max_delay  [expr $TCK_SYS * 0.35] -to $ASYNC_PINS_CLINT -ignore_clock_latency

#############
## SoC Ins ##
#############

# We assume test mode is disabled. This is required to stop spurious clock propagation at some muxes
set_case_analysis 0 [get_ports test_mode_i]

# Reset and boot mode should propagate to system domain within a clock cycle.
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

set_input_delay  -min -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.10 ]     [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.50 ]     [get_ports {jtag_tdi_i jtag_tms_i}]
set_output_delay -min -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.10 / 2 ] [get_ports jtag_tdo_o]
set_output_delay -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_JTG * 0.50 / 2 ] [get_ports jtag_tdo_o]

set_max_delay $TCK_JTG  -from [get_ports jtag_trst_ni]
set_false_path -hold    -from [get_ports jtag_trst_ni]

#########
## VGA ##
#########

# Allow VGA IO to take two cycles to propagate
set VGA_IO_CYC 2

# Time all IO (*including* generated hsync and vsync) with the internal system clock
# which launches and captures it. Since we are the master and provide clocks (hsync
# and vsync), IO timing w.r.t our own external clock is not a requirement
set_multicycle_path -setup $VGA_IO_CYC              -through [get_ports vga_*]
set_multicycle_path -hold  [ expr $VGA_IO_CYC - 1 ] -through [get_ports vga_*]

set_output_delay -min -add_delay -clock clk_sys -reference_pin $VGA_REFPIN [expr $TCK_SYS * $VGA_IO_CYC * 0.10] [get_ports vga_*]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $VGA_REFPIN [expr $TCK_SYS * $VGA_IO_CYC * 0.35] [get_ports vga_*]

##############
## SPI Host ##
##############

# Allow SPI Host IO to take two cycles to propagate
set SPIH_IO_CYC 2

# Time all IO (*including* generated clock) with the system clock which launches and captures it
set_multicycle_path -setup $SPIH_IO_CYC              -through [get_ports spih*]
set_multicycle_path -hold  [ expr $SPIH_IO_CYC - 1 ] -through [get_ports spih*]

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.10 ] [get_ports spih_sd*]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports spih_sd*]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.10 ] [get_ports {spih_sck_o spih_sd* spih_csb*}]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $SPIH_REFPIN [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports {spih_sck_o spih_sd* spih_csb*}]

#########
## I2C ##
#########

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]

##########
## UART ##
##########

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports uart_rx_i]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports uart_rx_i]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports uart_tx_o]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $UART_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports uart_tx_o]

##########
## GPIO ##
##########

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports gpio_*_io]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports gpio_*_io]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports gpio_*_io]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $GPIO_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports gpio_*_io]

#################
## Serial Link ##
#################

set SL_MAX_SKEW 0.55
set SL_IN       [get_ports slink_*_i]
set SL_OUT      [get_ports slink_*_o]
set SL_OUT_CLK  [get_ports slink_clk_o]

# DDR Input: Maximize assumed *transition* (unstable) interval by maximizing input delay span.
# Transitions happen *between* sampling input clock edges, so centered around T/4 *after* sampling edges.
# We assume that the transition takes up almost a full half period, so (T/4 - (T/4-skew), T/4 + (T/4-skew)).
set_input_delay -min -add_delay             -clock clk_sli -network_latency_included [expr               + $SL_MAX_SKEW] $SL_IN
set_input_delay -min -add_delay -clock_fall -clock clk_sli -network_latency_included [expr               + $SL_MAX_SKEW] $SL_IN
set_input_delay -max -add_delay             -clock clk_sli -network_latency_included [expr  $TCK_SLI / 2 - $SL_MAX_SKEW] $SL_IN
set_input_delay -max -add_delay -clock_fall -clock clk_sli -network_latency_included [expr  $TCK_SLI / 2 - $SL_MAX_SKEW] $SL_IN

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

set SLINK_TX \i_iguana_soc.i_cheshire_soc.gen_serial_link.i_serial_link.gen_phy_channels.__0.i_serial_link_physical.i_serial_link_physical_tx
foreach pin [get_fanout -from [get_pins $SLINK_TX.data_out_q_\$_DFF_PN0__Q/Q] -level 1] {
  if {[string match "*/X" [get_full_name $pin]]} {
    puts [get_full_name $pin]
    set_false_path -hold -rise_from clk_gen_slo_drv -to $pin
  }
}
foreach pin [get_fanout -from [get_pins $SLINK_TX.data_out_q_\$_DFF_PN0__Q_1/Q] -level 1] { 
  if {[string match "*/X" [get_full_name $pin]]} {
    puts [get_full_name $pin]
    set_false_path -hold -rise_from clk_gen_slo_drv -to $pin
  }
}
foreach pin [get_fanout -from [get_pins $SLINK_TX.data_out_q_\$_DFF_PN0__Q_2/Q] -level 1] { 
  if {[string match "*/X" [get_full_name $pin]]} {
    puts [get_full_name $pin]
    set_false_path -hold -rise_from clk_gen_slo_drv -to $pin
  }
}
foreach pin [get_fanout -from [get_pins $SLINK_TX.data_out_q_\$_DFF_PN0__Q_3/Q] -level 1] { 
  if {[string match "*/X" [get_full_name $pin]]} {
    puts [get_full_name $pin]
    set_false_path -hold -rise_from clk_gen_slo_drv -to $pin
  }
}

##############
## Hyperbus ##
##############

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
set_multicycle_path -setup 2 -through $HYP_RST
set_multicycle_path -hold  1 -through $HYP_RST
set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.10] $HYP_RST
set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.35] $HYP_RST
