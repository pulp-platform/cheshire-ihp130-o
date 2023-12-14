#
# This is the io-definion for Basilisk QFN88
#
# - Every "Offset: xxx" line defines a possible placement location/slot for one pad.
# - The "#pin no.: nn" comment shows the corresponding pin number for the QFN88 package.

# [QFN88]
# pin number not include pad_corner, total used die 129 pins
# parameter:
#                  package  die
#   pins                 88  148
#     I/O                68   68
#     Core power         12   24
#     Core ground         -   24
#     Pad  power          8   16
#     Pad  ground         -   16
#                                     [um]
#   grid is multiple of          -, -
#   pad dimensions area     310.0 x   60.0
#   total silicon area
#   die (innovus) area     6250.0 x 5498.0
#   core area              5430.0 x 4678.0
#   pad pitch               140.0    130.0
#                                     [mA]
#   max core current                    -
#   max IO current                      -

make_io_sites -horizontal_site IOSite \
    -vertical_site IOSite \
    -corner_site IOSite \
    -offset 0 \
    -rotation_horizontal R0 \
    -rotation_vertical R0 \
    -rotation_corner R0

#Edge: LEFT (top to bottom)
place_pad -row IO_WEST  -location 5060.0 "pad_vccio_0.i_pad"       ; # pin no: 1
place_pad -row IO_WEST  -location 4930.0 "pad_vccio_1.i_pad"       ; # pin no: 1
place_pad -row IO_WEST  -location 4800.0 "pad_gndio_0.i_pad"       ; # 
place_pad -row IO_WEST  -location 4670.0 "pad_gndio_1.i_pad"       ; #     
place_pad -row IO_WEST  -location 4540.0 "pad_uart_rx.i_pad"       ; # pin no: 2
place_pad -row IO_WEST  -location 4410.0 "pad_uart_tx.i_pad"       ; # pin no: 3
place_pad -row IO_WEST  -location 4280.0 "pad_gpio_11.i_pad"       ; # pin no: 4
place_pad -row IO_WEST  -location 4150.0 "pad_hyper_cs_0_n.i_pad"  ; # pin no: 5
place_pad -row IO_WEST  -location 4020.0 "pad_hyper_cs_1_n.i_pad"  ; # pin no: 6
place_pad -row IO_WEST  -location 3890.0 "pad_hyper_ck.i_pad"      ; # pin no: 7
place_pad -row IO_WEST  -location 3760.0 "pad_hyper_ck_n.i_pad"    ; # pin no: 8
place_pad -row IO_WEST  -location 3630.0 "pad_hyper_rwds.i_pad"    ; # pin no: 9
place_pad -row IO_WEST  -location 3500.0 "pad_hyper_reset_n.i_pad" ; # pin no: 10
place_pad -row IO_WEST  -location 3370.0 "pad_gndco_0.i_pad"       ; # 
place_pad -row IO_WEST  -location 3240.0 "pad_gndco_1.i_pad"       ; # 
place_pad -row IO_WEST  -location 3110.0 "pad_vddco_0.i_pad"       ; # pin no: 11
place_pad -row IO_WEST  -location 2980.0 "pad_vddco_1.i_pad"       ; # pin no: 11
place_pad -row IO_WEST  -location 2850.0 "pad_gndco_2.i_pad"       ; # 
place_pad -row IO_WEST  -location 2720.0 "pad_vddco_2.i_pad"       ; # pin no: 12
place_pad -row IO_WEST  -location 2590.0 "pad_vddco_3.i_pad"       ; # pin no: 12
place_pad -row IO_WEST  -location 2460.0 "pad_gndco_3.i_pad"       ; # 
place_pad -row IO_WEST  -location 2330.0 "pad_vddco_4.i_pad"       ; # pin no: 13
place_pad -row IO_WEST  -location 2200.0 "pad_vddco_5.i_pad"       ; # pin no: 13
place_pad -row IO_WEST  -location 2070.0 "pad_gndco_4.i_pad"       ; # 
place_pad -row IO_WEST  -location 1940.0 "pad_gndco_5.i_pad"       ; # 
place_pad -row IO_WEST  -location 1810.0 "pad_hyper_dq_0.i_pad"    ; # pin no: 14
place_pad -row IO_WEST  -location 1680.0 "pad_hyper_dq_1.i_pad"    ; # pin no: 15
place_pad -row IO_WEST  -location 1550.0 "pad_hyper_dq_2.i_pad"    ; # pin no: 16
place_pad -row IO_WEST  -location 1420.0 "pad_hyper_dq_3.i_pad"    ; # pin no: 17
place_pad -row IO_WEST  -location 1290.0 "pad_hyper_dq_4.i_pad"    ; # pin no: 18
place_pad -row IO_WEST  -location 1160.0 "pad_hyper_dq_5.i_pad"    ; # pin no: 19
place_pad -row IO_WEST  -location 1030.0 "pad_hyper_dq_6.i_pad"    ; # pin no: 20
place_pad -row IO_WEST  -location  900.0 "pad_hyper_dq_7.i_pad"    ; # pin no: 21
place_pad -row IO_WEST  -location  770.0 "pad_gndio_2.i_pad"       ; # 
place_pad -row IO_WEST  -location  640.0 "pad_gndio_3.i_pad"       ; # 
place_pad -row IO_WEST  -location  510.0 "pad_vccio_2.i_pad"       ; # pin no: 22
place_pad -row IO_WEST  -location  380.0 "pad_vccio_3.i_pad"       ; # pin no: 22

#Edge: BOTTOM (left to right)
place_pad -row IO_SOUTH -location  575.0 "pad_vccio_4.i_pad"       ; # pin no: 23
place_pad -row IO_SOUTH -location  715.0 "pad_vccio_5.i_pad"       ; # pin no: 23
place_pad -row IO_SOUTH -location  855.0 "pad_gndio_4.i_pad"       ; #
place_pad -row IO_SOUTH -location  995.0 "pad_gndio_5.i_pad"       ; #
place_pad -row IO_SOUTH -location 1135.0 "pad_i2c_sda.i_pad"       ; # pin no: 24
place_pad -row IO_SOUTH -location 1275.0 "pad_i2c_scl.i_pad"       ; # pin no: 25
place_pad -row IO_SOUTH -location 1415.0 "pad_slink_clk_i.i_pad"   ; # pin no: 26
place_pad -row IO_SOUTH -location 1555.0 "pad_slink_0_i.i_pad"     ; # pin no: 27
place_pad -row IO_SOUTH -location 1695.0 "pad_slink_1_i.i_pad"     ; # pin no: 28
place_pad -row IO_SOUTH -location 1835.0 "pad_slink_2_i.i_pad"     ; # pin no: 29
place_pad -row IO_SOUTH -location 1975.0 "pad_slink_3_i.i_pad"     ; # pin no: 30
place_pad -row IO_SOUTH -location 2115.0 "pad_gpio_6.i_pad"        ; # pin no: 31
place_pad -row IO_SOUTH -location 2255.0 "pad_gpio_7.i_pad"        ; # pin no: 32
place_pad -row IO_SOUTH -location 2395.0 "pad_gndco_6.i_pad"       ; #
place_pad -row IO_SOUTH -location 2535.0 "pad_gndco_7.i_pad"       ; #
place_pad -row IO_SOUTH -location 2675.0 "pad_vddco_6.i_pad"       ; # pin no: 33
place_pad -row IO_SOUTH -location 2815.0 "pad_vddco_7.i_pad"       ; # pin no: 33
place_pad -row IO_SOUTH -location 2955.0 "pad_gndco_8.i_pad"       ; #
place_pad -row IO_SOUTH -location 3095.0 "pad_vddco_8.i_pad"       ; # pin no: 34
place_pad -row IO_SOUTH -location 3235.0 "pad_vddco_9.i_pad"       ; # pin no: 34
place_pad -row IO_SOUTH -location 3375.0 "pad_gndco_9.i_pad"       ; #
place_pad -row IO_SOUTH -location 3515.0 "pad_vddco_10.i_pad"      ; # pin no: 35
place_pad -row IO_SOUTH -location 3655.0 "pad_vddco_11.i_pad"      ; # pin no: 35
place_pad -row IO_SOUTH -location 3795.0 "pad_gndco_10.i_pad"      ; #
place_pad -row IO_SOUTH -location 3935.0 "pad_gndco_11.i_pad"      ; #
place_pad -row IO_SOUTH -location 4075.0 "pad_gpio_8.i_pad"        ; # pin no: 36
place_pad -row IO_SOUTH -location 4215.0 "pad_gpio_9.i_pad"        ; # pin no: 37
place_pad -row IO_SOUTH -location 4355.0 "pad_gpio_10.i_pad"       ; # pin no: 38
place_pad -row IO_SOUTH -location 4495.0 "pad_slink_clk_o.i_pad"   ; # pin no: 39
place_pad -row IO_SOUTH -location 4635.0 "pad_slink_0_o.i_pad"     ; # pin no: 40
place_pad -row IO_SOUTH -location 4775.0 "pad_slink_1_o.i_pad"     ; # pin no: 41
place_pad -row IO_SOUTH -location 4915.0 "pad_slink_2_o.i_pad"     ; # pin no: 42
place_pad -row IO_SOUTH -location 5055.0 "pad_slink_3_o.i_pad"     ; # pin no: 43
place_pad -row IO_SOUTH -location 5195.0 "pad_gndio_6.i_pad"       ; #
place_pad -row IO_SOUTH -location 5335.0 "pad_gndio_7.i_pad"       ; #
place_pad -row IO_SOUTH -location 5475.0 "pad_vccio_6.i_pad"       ; # pin no: 44
place_pad -row IO_SOUTH -location 5615.0 "pad_vccio_7.i_pad"       ; # pin no: 44

#Edge: RIGHT (bottom to top)
place_pad -row IO_EAST  -location  380.0 "pad_vccio_8.i_pad"       ; # pin no: 45
place_pad -row IO_EAST  -location  510.0 "pad_vccio_9.i_pad"       ; # pin no: 45
place_pad -row IO_EAST  -location  640.0 "pad_gndio_8.i_pad"       ; #   
place_pad -row IO_EAST  -location  770.0 "pad_gndio_9.i_pad"       ; # 
place_pad -row IO_EAST  -location  900.0 "pad_vga_red_2.i_pad"     ; # pin no: 46
place_pad -row IO_EAST  -location 1030.0 "pad_vga_red_1.i_pad"     ; # pin no: 47
place_pad -row IO_EAST  -location 1160.0 "pad_vga_red_0.i_pad"     ; # pin no: 48
place_pad -row IO_EAST  -location 1290.0 "pad_vga_green_2.i_pad"   ; # pin no: 49
place_pad -row IO_EAST  -location 1420.0 "pad_vga_green_1.i_pad"   ; # pin no: 50
place_pad -row IO_EAST  -location 1550.0 "pad_vga_green_0.i_pad"   ; # pin no: 51
place_pad -row IO_EAST  -location 1680.0 "pad_vga_blue_1.i_pad"    ; # pin no: 52
place_pad -row IO_EAST  -location 1810.0 "pad_vga_blue_0.i_pad"    ; # pin no: 53
place_pad -row IO_EAST  -location 1940.0 "pad_vga_hsync.i_pad"     ; # pin no: 54
place_pad -row IO_EAST  -location 2070.0 "pad_gndco_12.i_pad"      ; # 
place_pad -row IO_EAST  -location 2200.0 "pad_gndco_13.i_pad"      ; # 
place_pad -row IO_EAST  -location 2330.0 "pad_vddco_12.i_pad"      ; # pin no: 55
place_pad -row IO_EAST  -location 2460.0 "pad_vddco_13.i_pad"      ; # pin no: 55
place_pad -row IO_EAST  -location 2590.0 "pad_gndco_14.i_pad"      ; # 
place_pad -row IO_EAST  -location 2720.0 "pad_vddco_14.i_pad"      ; # pin no: 56
place_pad -row IO_EAST  -location 2850.0 "pad_vddco_15.i_pad"      ; # pin no: 56
place_pad -row IO_EAST  -location 2980.0 "pad_gndco_15.i_pad"      ; # 
place_pad -row IO_EAST  -location 3110.0 "pad_vddco_16.i_pad"      ; # pin no: 57
place_pad -row IO_EAST  -location 3240.0 "pad_vddco_17.i_pad"      ; # pin no: 57
place_pad -row IO_EAST  -location 3370.0 "pad_gndco_16.i_pad"      ; # 
place_pad -row IO_EAST  -location 3500.0 "pad_gndco_17.i_pad"      ; # 
place_pad -row IO_EAST  -location 3630.0 "pad_vga_vsync.i_pad"     ; # pin no: 58
place_pad -row IO_EAST  -location 3760.0 "pad_spih_csb_0.i_pad"    ; # pin no: 59
place_pad -row IO_EAST  -location 3890.0 "pad_spih_csb_1.i_pad"    ; # pin no: 60
place_pad -row IO_EAST  -location 4020.0 "pad_spih_sck.i_pad"      ; # pin no: 61
place_pad -row IO_EAST  -location 4150.0 "pad_spih_sd_0.i_pad"     ; # pin no: 62
place_pad -row IO_EAST  -location 4280.0 "pad_spih_sd_1.i_pad"     ; # pin no: 63
place_pad -row IO_EAST  -location 4410.0 "pad_spih_sd_2.i_pad"     ; # pin no: 64
place_pad -row IO_EAST  -location 4540.0 "pad_spih_sd_3.i_pad"     ; # pin no: 65
place_pad -row IO_EAST  -location 4670.0 "pad_gndio_10.i_pad"      ; # 
place_pad -row IO_EAST  -location 4800.0 "pad_gndio_11.i_pad"      ; # 
place_pad -row IO_EAST  -location 4930.0 "pad_vccio_10.i_pad"      ; # pin no: 66
place_pad -row IO_EAST  -location 5060.0 "pad_vccio_11.i_pad"      ; # pin no: 66

#Edge: TOP (right to left)
place_pad -row IO_NORTH -location 5615.0 "pad_vccio_12.i_pad"      ; # pin no: 67
place_pad -row IO_NORTH -location 5475.0 "pad_vccio_13.i_pad"      ; # pin no: 67
place_pad -row IO_NORTH -location 5335.0 "pad_gndio_12.i_pad"      ; #
place_pad -row IO_NORTH -location 5195.0 "pad_gndio_13.i_pad"      ; #
place_pad -row IO_NORTH -location 5055.0 "pad_jtag_trst_n.i_pad"   ; # pin no: 68
place_pad -row IO_NORTH -location 4915.0 "pad_jtag_tck.i_pad"      ; # pin no: 69
place_pad -row IO_NORTH -location 4775.0 "pad_jtag_tdo.i_pad"      ; # pin no: 70
place_pad -row IO_NORTH -location 4635.0 "pad_jtag_tdi.i_pad"      ; # pin no: 71
place_pad -row IO_NORTH -location 4495.0 "pad_jtag_tms.i_pad"      ; # pin no: 72
place_pad -row IO_NORTH -location 4355.0 "pad_rtc.i_pad"           ; # pin no: 73
place_pad -row IO_NORTH -location 4215.0 "pad_boot_mode_0.i_pad"   ; # pin no: 74
place_pad -row IO_NORTH -location 4075.0 "pad_boot_mode_1.i_pad"   ; # pin no: 75
place_pad -row IO_NORTH -location 3935.0 "pad_rst_n.i_pad"         ; # pin no: 76
place_pad -row IO_NORTH -location 3795.0 "pad_gndco_18.i_pad"      ; #
place_pad -row IO_NORTH -location 3655.0 "pad_gndco_19.i_pad"      ; #
place_pad -row IO_NORTH -location 3515.0 "pad_vddco_18.i_pad"      ; # pin no: 77
place_pad -row IO_NORTH -location 3375.0 "pad_vddco_19.i_pad"      ; # pin no: 77
place_pad -row IO_NORTH -location 3235.0 "pad_gndco_20.i_pad"      ; #
place_pad -row IO_NORTH -location 3095.0 "pad_vddco_20.i_pad"      ; # pin no: 78
place_pad -row IO_NORTH -location 2955.0 "pad_vddco_21.i_pad"      ; # pin no: 78
place_pad -row IO_NORTH -location 2815.0 "pad_gndco_21.i_pad"      ; #
place_pad -row IO_NORTH -location 2675.0 "pad_vddco_22.i_pad"      ; # pin no: 79
place_pad -row IO_NORTH -location 2535.0 "pad_vddco_23.i_pad"      ; # pin no: 79
place_pad -row IO_NORTH -location 2395.0 "pad_gndco_22.i_pad"      ; #
place_pad -row IO_NORTH -location 2255.0 "pad_gndco_23.i_pad"      ; #
place_pad -row IO_NORTH -location 2115.0 "pad_clk.i_pad"           ; # pin no: 80
place_pad -row IO_NORTH -location 1975.0 "pad_test_mode.i_pad"     ; # pin no: 81
place_pad -row IO_NORTH -location 1835.0 "pad_gpio_0.i_pad"        ; # pin no: 82
place_pad -row IO_NORTH -location 1695.0 "pad_gpio_1.i_pad"        ; # pin no: 83
place_pad -row IO_NORTH -location 1555.0 "pad_gpio_2.i_pad"        ; # pin no: 84
place_pad -row IO_NORTH -location 1415.0 "pad_gpio_3.i_pad"        ; # pin no: 85
place_pad -row IO_NORTH -location 1275.0 "pad_gpio_4.i_pad"        ; # pin no: 86
place_pad -row IO_NORTH -location 1135.0 "pad_gpio_5.i_pad"        ; # pin no: 87
place_pad -row IO_NORTH -location  995.0 "pad_gndio_14.i_pad"      ; # 
place_pad -row IO_NORTH -location  855.0 "pad_gndio_15.i_pad"      ; # 
place_pad -row IO_NORTH -location  715.0 "pad_vccio_14.i_pad"      ; # pin no: 88
place_pad -row IO_NORTH -location  575.0 "pad_vccio_15.i_pad"      ; # pin no: 88

place_corners $iocorner

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST {*}$iofill
place_io_fill -row IO_EAST {*}$iofill


# Connect built-in rings
connect_by_abutment

# The bond pads are integrated into the IO cell
# We need to assign the terminals a location that aligns to the bond pad.
place_io_terminals *.i_pad/PAD

remove_io_rows











































































