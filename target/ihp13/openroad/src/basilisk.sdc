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

source src/basilisk_instances.sdc


#############################
## Driving Cells and Loads ##
#############################

# As a default, drive multiple GPIO pads and be driven by such a pad.
# ixc013_i16x PAD Pin = 1.10943 pF; accomodate for driving up to 12 such pads plus 7pF trace
set_load [expr 12 * 1.10943 + 7.0] [all_outputs]
set_driving_cell [all_inputs] -lib_cell ixc013_b16m -pin PAD

# Serial link drives one pad per IO, but may have larger capacity (e.g. FPGA)
set PINS_SL_FAST [get_ports {slink_clk_o slink_*_o}]
set_load -min 4 ${PINS_SL_FAST}
set_load -max 16 ${PINS_SL_FAST}

# See S*KL* family hyperram data sheet + 7pF traces (pretty heavy)
# trace: 2cm length, 150um width, 4-layer stackup 150um trace-to-plane, permitivity: 4
set PINS_HYP_FAST [get_ports hyper_*]
set_load -min 4 ${PINS_HYP_FAST}
set_load -max 16 ${PINS_HYP_FAST}


##################
## Input Clocks ##
##################
puts "Clocks..."

# We target 80 MHz
set TCK_SYS 12.5
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 40.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports rtc_i]

set TCK_SLI [expr 4 * $TCK_SYS]
create_clock -name clk_sli -period $TCK_SLI [get_ports slink_clk_i]

set TCK_USB [expr 1000/48]
create_clock -name clk_usb -period $TCK_USB [get_ports usb_clk_i]

create_clock -name clk_sens -period $TCK_SYS [get_ports sens_clk_i]
create_clock -name clk_sens_ind -period $TCK_SYS [get_ports sens_ind_clk_i]

# Model incoming Hyperbus RWDS clock as shifted system clock leaving chip via Hyperbus CK pad, 
# going through a HyperRAM device, and back to our RWDS pad (defined on pad to enable RWDS output delay constraint):
# * System clock pad input delay (TT 0.9ns @ hyper capacities)
# * Quarter-period delay line
# * Hyperbus CK pad output delay (TT 3.2ns @ hyper capacities)
# * HyperRAM device read CK -> RWDS flank delay (avg. 5.75ns) 
# * Round-trip PCB wiring delay (1.04ns, 2*8cm at 0.5c).
# Datasheet: https://www.infineon.com/dgdl/Infineon-S27KL0642_S27KS0642_3.0_V_1.8_V_64_Mb_(8_MB)_HyperRAM_Self-Refresh_DRAM-DataSheet-v09_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ee8a1c47164
# set HYP_TGT_DLY [expr $TCK_SYS / 4] -> dline generated with max of 6ns -> target is middle at 3.5ns + 0.3ns estimated load
set HYP_TGT_DLY 3.8
set HYP_ASM_RTT [expr fmod(0.9 + $HYP_TGT_DLY + 3.2 + 5.75 + 1.04, $TCK_SYS)]
set HYP_RWDSI_FORM [list [expr $HYP_ASM_RTT] [expr $HYP_ASM_RTT + $TCK_SYS / 2]]
create_clock -name clk_hyp_rwdsi -period $TCK_SYS -waveform $HYP_RWDSI_FORM [get_pins pad_hyper_rwds.i_pad/PAD]

# a reasonable amount less than HYP_TGT_DLY to model fast-fast vs typical-typical
set HYP_MIN_DLY 3.5

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

# We define delays through delay_line instead of using a generated_clock so it properly checks min/max delay (hold/setup)
# this also replaces timings from libs
set_assigned_delay -corner ff -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner ff -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_MIN_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_TX_DLINE/clk_i] -to [get_pins $HYP_TX_DLINE/clk_o] -cell $HYP_TGT_DLY
set_assigned_delay -corner tt -from [get_pins $HYP_RX_DLINE/clk_i] -to [get_pins $HYP_RX_DLINE/clk_o] -cell $HYP_TGT_DLY

# Do not produce timing arcs from the TX back to the RX clock or from the RX clock to its TX-timed IO
set_false_path -from [get_ports hyper_rwds_io] -through [get_pins pad_hyper_rwds.i_pad/PAD]
set_false_path -from [get_clocks clk_hyp_rwdsi] -to [get_ports hyper_rwds_io]
# ToDo: This looks extremely suspicious to me, doesn't this false-path all paths from hyper_rwds_io to everywhere
# meaning it is only timed as an output and even then with big exceptions?

##################################
## Clock Groups & Uncertainties ##
##################################

# Define which collections of clocks are asynchronous to each other
# 'allow_paths' re-activates checks on datapaths between clock domains
# this way we must constrain them seperately or we get unmet timings
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys clk_gen_slo clk_gen_slo_drv clk_hyp_rwdsi} \
     -group {clk_sli} \
     -group {clk_usb} \
     -group {clk_sens} \
     -group {clk_sens_ind} \
     -allow_paths

# We set reasonable uncertainties and transitions for all nonvirtual clocks
set CLK_UNCERTAINTY   0.1
set_clock_uncertainty $CLK_UNCERTAINTY [all_clocks]
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

# REASONING:
# max_delay checks should be as short as possible so the crossing paths are also short 
# -> maximize state-resolution time of flops (avoid metastability)
# min_delay checks are slightly negative to compensate for clock uncertainty,
# this should ideally prevent the tool from adding hold-fixing buffers in the path
# https://gist.github.com/brabect1/7695ead3d79be47576890bbcd61fe426#encouraged-sdc-techniques

# Constrain `cdc_2phase` for DMI request
set_max_delay [expr $TCK_SYS * 0.20   ] -through $ASYNC_PINS_DMIREQ -ignore_clock_latency
set_min_delay [expr - $CLK_UNCERTAINTY] -through $ASYNC_PINS_DMIREQ -ignore_clock_latency

# Constrain `cdc_2phase` for DMI response
set_max_delay [expr $TCK_SYS * 0.20   ] -through $ASYNC_PINS_DMIRSP -ignore_clock_latency
set_min_delay [expr - $CLK_UNCERTAINTY] -through $ASYNC_PINS_DMIRSP -ignore_clock_latency

# Constrain `cdc_fifo_gray` for serial link in
set_max_delay [expr $TCK_SYS * 0.20   ] -through $ASYNC_PINS_SLIN -ignore_clock_latency
set_min_delay [expr - $CLK_UNCERTAINTY] -through $ASYNC_PINS_SLIN -ignore_clock_latency

# Constrain CLINT RTC sync
set_max_delay [expr $TCK_SYS * 0.20   ] -to $ASYNC_PINS_CLINT -ignore_clock_latency
set_min_delay [expr - $CLK_UNCERTAINTY] -to $ASYNC_PINS_CLINT -ignore_clock_latency

# Constrain USB CDCs
# the USB CDCs for data and enable are handled differently for some reason
# so we abandon trying to explicitly set every path
set_max_delay -from clk_sys -to clk_usb [expr $TCK_USB * 0.30]    -ignore_clock_latency
set_min_delay -from clk_sys -to clk_usb [expr - $CLK_UNCERTAINTY] -ignore_clock_latency

#############
## Sensors ##
#############
puts "Aging sensors..."
set_output_delay -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_SYS * 0.25 ] [get_ports sens_error_0_o]
set_output_delay -max -add_delay -clock clk_jtg -network_latency_included [ expr $TCK_SYS * 0.25 ] [get_ports sens_error_1_o]


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
# set_false_path -hold                    -from [get_ports test_mode_i]
# set_max_delay  [ expr $TCK_SYS * 0.75 ] -from [get_ports test_mode_i]

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

# The data pins are bidirectional, output-enable should not arrive before output-data as to not cause problems (setup)
# similarly data should be stable while OE switches the pad back to being an input (hold)
# We have OE-negative so rise and fall are flipped


#########
## I2C ##
#########
puts "I2C..."

set_input_delay  -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_input_delay  -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]
set_output_delay -min -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.10 ] [get_ports i2c_*_io]
set_output_delay -max -add_delay -clock clk_sys -reference_pin $I2C_REFPIN [ expr $TCK_SYS * 0.35 ] [get_ports i2c_*_io]

# output enable shuld toggle while data is stable see SPI for full reasoning
foreach pad [get_cells pad_i2c*.i_pad] {
  set oen [get_pins -of_objects $pad -filter "name == OEN"]
  set din [get_pins -of_objects $pad -filter "name == DIN"]
  set_data_check -fall_from $oen -to $din -clock clk_sys -setup [ expr $TCK_SYS * 0.10 ]
  set_data_check -rise_from $oen -to $din -clock clk_sys -hold  [ expr $TCK_SYS * 0.10 ]
}


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


##########
## USB  ##
##########
puts "USB..."
# the paths can go from GPIO to the pad and because its bidir back to the USB inputs -> false_path
foreach pad [list 0 1 2 3 4 5 6 7] {
    set_false_path -from clk_sys -through [get_pins *pad_gpio_$pad.i_pad/PAD] -to clk_usb
    set_false_path -from clk_usb -through [get_pins *pad_gpio_$pad.i_pad/PAD] -to clk_sys
    set_false_path -from [get_ports gpio_${pad}_io] -to clk_usb
}

# a negative setup means the constraint signal must arrive no later than the value after the reference goes high
# a negative hold means the constraint signal must arrive no earler than the value after the reference goes low
# if we swap which is the constraint and reference signal, it creates a window of legality for each transition
foreach port [list 0 1 2 3] {
  set cells [get_fanout -only_cells -from [get_nets $CHESHIRE.usb_dm_o_${port}*]]
  set dm_pad [lsearch -inline -glob [lmap cell $cells {get_name $cell}] "*i_pad"]
  set dm [get_pins -of_objects $dm_pad -filter "name == DIN"]

  set cells [get_fanout -only_cells -from [get_nets $CHESHIRE.usb_dp_o_${port}*]]
  set dp_pad [lsearch -inline -glob [lmap cell $cells {get_name $cell}] "*i_pad"]
  set dp [get_pins -of_objects $dp_pad -filter "name == DIN"]

  set_data_check -fall_from $dm -to $dp -clock clk_usb -setup [ expr -$CLK_UNCERTAINTY - $TCK_USB * 0.1 ]
  set_data_check -fall_from $dm -to $dp -clock clk_usb -hold  [ expr -$CLK_UNCERTAINTY - $TCK_USB * 0.1 ]
  set_data_check -fall_from $dp -to $dm -clock clk_usb -setup [ expr -$CLK_UNCERTAINTY - $TCK_USB * 0.1 ]
  set_data_check -fall_from $dp -to $dm -clock clk_usb -hold  [ expr -$CLK_UNCERTAINTY - $TCK_USB * 0.1 ]
}

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
  set HYP_OUT_DOUT [get_pins {pad_hyper_dq*.i_pad/DIN pad_hyper_rwds.i_pad/DIN}]
  set HYP_OUT_DOEN [get_pins {pad_hyper_dq*.i_pad/OEN pad_hyper_rwds.i_pad/OEN}]
  set HYP_OUT_COUT [get_pins pad_hyper_ck.i_pad/DIN]

  # DDR Input: As for serial link, maximize the assumed *transition* interval by maximizing input delay span.
  # However here, transitions happen *at* edge-aligned input clock edges, so they are centered *at* the edges.
  # Therefore, the input transition interval becomes (T/4 - (T/4-skew), T/4 + (T/4-skew)).
  set_input_delay -min -add_delay             -clock clk_hyp_rwdsi -network_latency_included [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -min -add_delay -clock_fall -clock clk_hyp_rwdsi -network_latency_included [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -max -add_delay             -clock clk_hyp_rwdsi -network_latency_included [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO
  set_input_delay -max -add_delay -clock_fall -clock clk_hyp_rwdsi -network_latency_included [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_IO

  # DDR Output: Maximize *stable* interval we provide by maximizing output delay span.
  # This is exactly analogous to the serial link case, as the sending clock is center-aligned with data.
  # We carefully *exclude* the output enable here by using pre-pad timing.
  set_output_delay -min -add_delay             -clock clk_sys -reference_pin $HYP_OUT_COUT [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_OUT_DOUT
  set_output_delay -min -add_delay -clock_fall -clock clk_sys -reference_pin $HYP_OUT_COUT [expr -$TCK_SYS / 4 + $HYP_MAX_SLEW] $HYP_OUT_DOUT
  set_output_delay -max -add_delay             -clock clk_sys -reference_pin $HYP_OUT_COUT [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_OUT_DOUT
  set_output_delay -max -add_delay -clock_fall -clock clk_sys -reference_pin $HYP_OUT_COUT [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] $HYP_OUT_DOUT

  # The output enable is *not* DDR timed! It should *not* respect falling edge deadlines, only the rising-edge one!
  # Failing to constrain this correctly will result in buggy IO timing, as the OE is designed to control *two* data beats!
  set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_COUT [expr -(3 *$TCK_SYS) / 4 + $HYP_MAX_SLEW] $HYP_OUT_DOEN
  set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_COUT [expr      $TCK_SYS  / 4 - $HYP_MAX_SLEW] $HYP_OUT_DOEN

  # CS is *synchronous* (edge aligned) with output clock at pad, *not* DDR
  set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr              + $HYP_MAX_SLEW] $HYP_CS
  set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS / 2 - $HYP_MAX_SLEW] $HYP_CS

  # for all outputs, assuming rising launch is edge 0 and falling is 0'
  # we always specify capture to setup (max) 0' and also edge 1
  # as well as hold (min) from data coming from -1 and being captured at 0 (must be stable a bit after edge) and same for 0'
  # the hold condition for 0' is false (it unnecessary increases the minimum hold to a half cycle) as the data  launching at 0' would use it, not 0
  # similarly (but less important) the setup check from launching 0 to capturing 1 is unnecessary because its captured at falling edge 0' instead
  # the setup should be ocluded but is still a false check so we remove it

  # Do not allow PHY (System) clock to leak to DDR outputs and be timed as output transitions
  # the clk is used to mux between output data (to make it double-data rate)
  # this makes sure the clock-tree does not bleed through the mux into the data paths
  set_sense -clock -stop_propagation [get_pins $HYP_DDR_DATA_MUXES/S]

  # the clk is now stopped and doesn't bleed through but the paths gets timed as a data-path instead
  # this is fine but only produces reasonable results after CTS, before CTS it misleads repair_timing into erroneously placing buffers in the clock net
  # IMPORTANT!!!!! remove these false paths post-CTS via unset_path_exceptions
  foreach mux [get_cells $HYP_DDR_DATA_MUXES] {
    set mux_out [get_name $mux]/$MUX_OUT_PIN
    set mux_ctrl [get_name $mux]/$MUX_CONTROL_PIN
    set pad [get_name [get_fanout -from $mux_out -only_cells -endpoints_only]]
    set_false_path -from clk_i -through $mux_ctrl -through $mux_out -to $pad/DIN
  }

  set mux_out $HYP_DDR_RWDS_MUX/$MUX_OUT_PIN
  set mux_ctrl $HYP_DDR_RWDS_MUX/$MUX_CONTROL_PIN
  set pad [get_name [get_fanout -from $mux_out -only_cells -endpoints_only]]
  set_false_path -from clk_i -through $mux_ctrl -through $mux_out -to $pad/DIN


  # We multicycle the passthrough reset as it does not quite reach through the chip in one cycle
  set_multicycle_path -setup 2 -to $HYP_RST
  set_multicycle_path -hold  1 -to $HYP_RST
  set_output_delay -min -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.10] $HYP_RST
  set_output_delay -max -add_delay -clock clk_sys -reference_pin $HYP_OUT_CLK [expr $TCK_SYS * 2 * 0.35] $HYP_RST

  group_path -name "Hyper90degCS" -to [get_pins -of_objects "*hyper_cs_no_*__reg" -filter "name == $DFF_DATA_PIN"]
  set_multicycle_path -setup 0 -to [get_pins -of_objects "*hyper_cs_no_*__reg" -filter "name == $DFF_DATA_PIN"]
  set_multicycle_path -hold 0 -to [get_pins -of_objects "*hyper_cs_no_*__reg" -filter "name == $DFF_DATA_PIN"]
  
  group_path -name "Hyper90degClkGate" -to [get_pins -of_objects "*i_clock_diff_out.i_hyper_ck_gating.i_clkgate" -filter "name == $CLKGATE_GATE_PIN"]
  set_multicycle_path -setup 0 -to [get_pins -of_objects "*i_clock_diff_out.i_hyper_ck_gating.i_clkgate" -filter "name == $CLKGATE_GATE_PIN"]
  set_multicycle_path -hold 0 -to [get_pins -of_objects "*i_clock_diff_out.i_hyper_ck_gating.i_clkgate" -filter "name == $CLKGATE_GATE_PIN"]
}