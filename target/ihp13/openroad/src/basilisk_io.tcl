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
#   die (innovus) area     6230.0 x 5478.0
#   core area              5430.0 x 4678.0
#   pad pitch               138.0    130.0
#                                     [mA]
#   max core current                    -
#   max IO current                      -

make_io_sites -horizontal_site IOSite \
    -vertical_site IOSite \
    -corner_site IOSite \
    -offset 0 \
    -rotation_horizontal R0 \
    -rotation_vertical R0 \
    -rotation_corner MY

#Edge: LEFT (top to bottom)	Number of pins:	37		Start (center):	400	start (bottom-left)
place_pad	-row	IO_WEST	-location	5050	"pad_vccio_0.i_pad"	        ; # pin no: 1
place_pad	-row	IO_WEST	-location	4920	"pad_vccio_1.i_pad"	        ; # pin no: 1
place_pad	-row	IO_WEST	-location	4790	"pad_gndio_0.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	4660	"pad_gndio_1.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	4530	"pad_hyper_dq_4.i_pad"	    ; # pin no: 2
place_pad	-row	IO_WEST	-location	4400	"pad_hyper_dq_3.i_pad"	    ; # pin no: 3
place_pad	-row	IO_WEST	-location	4270	"pad_hyper_dq_2.i_pad"	    ; # pin no: 4
place_pad	-row	IO_WEST	-location	4140	"pad_hyper_dq_5.i_pad"	    ; # pin no: 5
place_pad	-row	IO_WEST	-location	4010	"pad_hyper_dq_0.i_pad"	    ; # pin no: 6
place_pad	-row	IO_WEST	-location	3880	"pad_hyper_dq_6.i_pad"	    ; # pin no: 7
place_pad	-row	IO_WEST	-location	3750	"pad_hyper_dq_7.i_pad"	    ; # pin no: 8
place_pad	-row	IO_WEST	-location	3620	"pad_hyper_dq_1.i_pad"	    ; # pin no: 9
place_pad	-row	IO_WEST	-location	3490	"pad_hyper_rwds.i_pad"	    ; # pin no: 10
place_pad	-row	IO_WEST	-location	3360	"pad_gndco_0.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	3230	"pad_gndco_1.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	3100	"pad_vddco_0.i_pad"	        ; # pin no: 11
place_pad	-row	IO_WEST	-location	2970	"pad_vddco_1.i_pad"	        ; # pin no: 11
place_pad	-row	IO_WEST	-location	2840	"pad_gndco_2.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	2710	"pad_vddco_2.i_pad"	        ; # pin no: 12
place_pad	-row	IO_WEST	-location	2580	"pad_vddco_3.i_pad"	        ; # pin no: 12
place_pad	-row	IO_WEST	-location	2450	"pad_gndco_3.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	2320	"pad_vddco_4.i_pad"	        ; # pin no: 13
place_pad	-row	IO_WEST	-location	2190	"pad_vddco_5.i_pad"	        ; # pin no: 13
place_pad	-row	IO_WEST	-location	2060	"pad_gndco_4.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	1930	"pad_gndco_5.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	1800	"pad_hyper_ck.i_pad"	    ; # pin no: 14
place_pad	-row	IO_WEST	-location	1670	"pad_hyper_ck_n.i_pad"	    ; # pin no: 15
place_pad	-row	IO_WEST	-location	1540	"pad_hyper_cs_0_n.i_pad"	; # pin no: 16
place_pad	-row	IO_WEST	-location	1410	"pad_hyper_cs_1_n.i_pad"	; # pin no: 17
place_pad	-row	IO_WEST	-location	1280	"pad_hyper_reset_n.i_pad"	; # pin no: 18
place_pad	-row	IO_WEST	-location	1150	"pad_i2c_scl.i_pad"	        ; # pin no: 19
place_pad	-row	IO_WEST	-location	1020	"pad_i2c_sda.i_pad"	        ; # pin no: 20
place_pad	-row	IO_WEST	-location	 890	"pad_boot_mode_0.i_pad"	    ; # pin no: 21
place_pad	-row	IO_WEST	-location	 760	"pad_gndio_2.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	 630	"pad_gndio_3.i_pad"	        ; #   
place_pad	-row	IO_WEST	-location	 500	"pad_vccio_2.i_pad"	        ; # pin no: 22
place_pad	-row	IO_WEST	-location	 370	"pad_vccio_3.i_pad"	        ; # pin no: 22
						
						
#Edge: BOTTOM (left to right)	Number of pins:	37		Start (center):	631	start (bottom-left)
place_pad	-row	IO_SOUTH	-location	 601	"pad_vccio_4.i_pad"	    ; # pin no: 23
place_pad	-row	IO_SOUTH	-location	 739	"pad_vccio_5.i_pad"	    ; # pin no: 23
place_pad	-row	IO_SOUTH	-location	 877	"pad_gndio_4.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	1015	"pad_gndio_5.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	1153	"pad_boot_mode_1.i_pad"	; # pin no: 24
place_pad	-row	IO_SOUTH	-location	1291	"pad_jtag_tdo.i_pad"	; # pin no: 25
place_pad	-row	IO_SOUTH	-location	1429	"pad_jtag_tdi.i_pad"	; # pin no: 26
place_pad	-row	IO_SOUTH	-location	1567	"pad_jtag_tms.i_pad"	; # pin no: 27
place_pad	-row	IO_SOUTH	-location	1705	"pad_jtag_tck.i_pad"	; # pin no: 28
place_pad	-row	IO_SOUTH	-location	1843	"pad_jtag_trst_n.i_pad"	; # pin no: 29
place_pad	-row	IO_SOUTH	-location	1981	"pad_rtc.i_pad"	        ; # pin no: 30
place_pad	-row	IO_SOUTH	-location	2119	"pad_rst_n.i_pad"	    ; # pin no: 31
place_pad	-row	IO_SOUTH	-location	2257	"pad_clk.i_pad"	        ; # pin no: 32
place_pad	-row	IO_SOUTH	-location	2395	"pad_gndco_6.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	2533	"pad_gndco_7.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	2671	"pad_vddco_6.i_pad"	    ; # pin no: 33
place_pad	-row	IO_SOUTH	-location	2809	"pad_vddco_7.i_pad"	    ; # pin no: 33
place_pad	-row	IO_SOUTH	-location	2947	"pad_gndco_8.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	3085	"pad_vddco_8.i_pad"	    ; # pin no: 34
place_pad	-row	IO_SOUTH	-location	3223	"pad_vddco_9.i_pad"	    ; # pin no: 34
place_pad	-row	IO_SOUTH	-location	3361	"pad_gndco_9.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	3499	"pad_vddco_10.i_pad"	; # pin no: 35
place_pad	-row	IO_SOUTH	-location	3637	"pad_vddco_11.i_pad"	; # pin no: 35
place_pad	-row	IO_SOUTH	-location	3775	"pad_gndco_10.i_pad"	; #   
place_pad	-row	IO_SOUTH	-location	3913	"pad_gndco_11.i_pad"	; #   
place_pad	-row	IO_SOUTH	-location	4051	"pad_gpio_11.i_pad"	    ; # pin no: 36
place_pad	-row	IO_SOUTH	-location	4189	"pad_gpio_10.i_pad"	    ; # pin no: 37
place_pad	-row	IO_SOUTH	-location	4327	"pad_gpio_9.i_pad"	    ; # pin no: 38
place_pad	-row	IO_SOUTH	-location	4465	"pad_gpio_8.i_pad"	    ; # pin no: 39
place_pad	-row	IO_SOUTH	-location	4603	"pad_slink_0_o.i_pad"	; # pin no: 40
place_pad	-row	IO_SOUTH	-location	4741	"pad_slink_1_o.i_pad"	; # pin no: 41
place_pad	-row	IO_SOUTH	-location	4879	"pad_slink_2_o.i_pad"	; # pin no: 42
place_pad	-row	IO_SOUTH	-location	5017	"pad_slink_3_o.i_pad"	; # pin no: 43
place_pad	-row	IO_SOUTH	-location	5155	"pad_gndio_6.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	5293	"pad_gndio_7.i_pad"	    ; #   
place_pad	-row	IO_SOUTH	-location	5431	"pad_vccio_6.i_pad"	    ; # pin no: 44
place_pad	-row	IO_SOUTH	-location	5569	"pad_vccio_7.i_pad"	    ; # pin no: 44
						
						
#Edge: RIGHT (bottom to top)	Number of pins:	37		Start (center):	400	start (bottom-left)
place_pad	-row	IO_EAST	    -location	 370	"pad_vccio_8.i_pad"	    ; # pin no: 45
place_pad	-row	IO_EAST	    -location	 500	"pad_vccio_9.i_pad"	    ; # pin no: 45
place_pad	-row	IO_EAST	    -location	 630	"pad_gndio_8.i_pad"	    ; #   
place_pad	-row	IO_EAST	    -location	 760	"pad_gndio_9.i_pad"	    ; #   
place_pad	-row	IO_EAST	    -location	 890	"pad_slink_clk_o.i_pad"	; # pin no: 46
place_pad	-row	IO_EAST	    -location	1020	"pad_slink_clk_i.i_pad"	; # pin no: 47
place_pad	-row	IO_EAST	    -location	1150	"pad_slink_0_i.i_pad"	; # pin no: 48
place_pad	-row	IO_EAST	    -location	1280	"pad_slink_1_i.i_pad"	; # pin no: 49
place_pad	-row	IO_EAST	    -location	1410	"pad_slink_2_i.i_pad"	; # pin no: 50
place_pad	-row	IO_EAST	    -location	1540	"pad_slink_3_i.i_pad"	; # pin no: 51
place_pad	-row	IO_EAST	    -location	1670	"pad_uart_rx.i_pad"	    ; # pin no: 52
place_pad	-row	IO_EAST	    -location	1800	"pad_uart_tx.i_pad"	    ; # pin no: 53
place_pad	-row	IO_EAST	    -location	1930	"pad_usb_clk.i_pad"	    ; # pin no: 54
place_pad	-row	IO_EAST	    -location	2060	"pad_gndco_12.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	2190	"pad_gndco_13.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	2320	"pad_vddco_12.i_pad"	; # pin no: 55
place_pad	-row	IO_EAST	    -location	2450	"pad_vddco_13.i_pad"	; # pin no: 55
place_pad	-row	IO_EAST	    -location	2580	"pad_gndco_14.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	2710	"pad_vddco_14.i_pad"	; # pin no: 56
place_pad	-row	IO_EAST	    -location	2840	"pad_vddco_15.i_pad"	; # pin no: 56
place_pad	-row	IO_EAST	    -location	2970	"pad_gndco_15.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	3100	"pad_vddco_16.i_pad"	; # pin no: 57
place_pad	-row	IO_EAST	    -location	3230	"pad_vddco_17.i_pad"	; # pin no: 57
place_pad	-row	IO_EAST	    -location	3360	"pad_gndco_16.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	3490	"pad_gndco_17.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	3620	"pad_gpio_0.i_pad"	    ; # pin no: 58
place_pad	-row	IO_EAST	    -location	3750	"pad_gpio_1.i_pad"	    ; # pin no: 59
place_pad	-row	IO_EAST	    -location	3880	"pad_gpio_2.i_pad"	    ; # pin no: 60
place_pad	-row	IO_EAST	    -location	4010	"pad_gpio_3.i_pad"	    ; # pin no: 61
place_pad	-row	IO_EAST	    -location	4140	"pad_gpio_4.i_pad"	    ; # pin no: 62
place_pad	-row	IO_EAST	    -location	4270	"pad_gpio_5.i_pad"	    ; # pin no: 63
place_pad	-row	IO_EAST	    -location	4400	"pad_gpio_6.i_pad"	    ; # pin no: 64
place_pad	-row	IO_EAST	    -location	4530	"pad_gpio_7.i_pad"	    ; # pin no: 65
place_pad	-row	IO_EAST	    -location	4660	"pad_gndio_10.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	4790	"pad_gndio_11.i_pad"	; #   
place_pad	-row	IO_EAST	    -location	4920	"pad_vccio_10.i_pad"	; # pin no: 66
place_pad	-row	IO_EAST	    -location	5050	"pad_vccio_11.i_pad"	; # pin no: 66
						
						
#Edge: TOP (right to left)	Number of pins:	37		Start (center):	631	start (bottom-left)
place_pad	-row	IO_NORTH	-location	5569	"pad_vccio_12.i_pad"	; # pin no: 67
place_pad	-row	IO_NORTH	-location	5431	"pad_vccio_13.i_pad"	; # pin no: 67
place_pad	-row	IO_NORTH	-location	5293	"pad_gndio_12.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	5155	"pad_gndio_13.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	5017	"pad_spih_sd_0.i_pad"	; # pin no: 68
place_pad	-row	IO_NORTH	-location	4879	"pad_spih_sd_1.i_pad"	; # pin no: 69
place_pad	-row	IO_NORTH	-location	4741	"pad_spih_sd_2.i_pad"	; # pin no: 70
place_pad	-row	IO_NORTH	-location	4603	"pad_spih_sd_3.i_pad"	; # pin no: 71
place_pad	-row	IO_NORTH	-location	4465	"pad_spih_sck.i_pad"	; # pin no: 72
place_pad	-row	IO_NORTH	-location	4327	"pad_spih_csb_0.i_pad"	; # pin no: 73
place_pad	-row	IO_NORTH	-location	4189	"pad_spih_csb_1.i_pad"	; # pin no: 74
place_pad	-row	IO_NORTH	-location	4051	"pad_vga_vsync.i_pad"	; # pin no: 75
place_pad	-row	IO_NORTH	-location	3913	"pad_vga_hsync.i_pad"	; # pin no: 76
place_pad	-row	IO_NORTH	-location	3775	"pad_gndco_18.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	3637	"pad_gndco_19.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	3499	"pad_vddco_18.i_pad"	; # pin no: 77
place_pad	-row	IO_NORTH	-location	3361	"pad_vddco_19.i_pad"	; # pin no: 77
place_pad	-row	IO_NORTH	-location	3223	"pad_gndco_20.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	3085	"pad_vddco_20.i_pad"	; # pin no: 78
place_pad	-row	IO_NORTH	-location	2947	"pad_vddco_21.i_pad"	; # pin no: 78
place_pad	-row	IO_NORTH	-location	2809	"pad_gndco_21.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	2671	"pad_vddco_22.i_pad"	; # pin no: 79
place_pad	-row	IO_NORTH	-location	2533	"pad_vddco_23.i_pad"	; # pin no: 79
place_pad	-row	IO_NORTH	-location	2395	"pad_gndco_22.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	2257	"pad_gndco_23.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	2119	"pad_vga_red_2.i_pad"	; # pin no: 80
place_pad	-row	IO_NORTH	-location	1981	"pad_vga_red_1.i_pad"	; # pin no: 81
place_pad	-row	IO_NORTH	-location	1843	"pad_vga_red_0.i_pad"	; # pin no: 82
place_pad	-row	IO_NORTH	-location	1705	"pad_vga_green_2.i_pad"	; # pin no: 83
place_pad	-row	IO_NORTH	-location	1567	"pad_vga_green_1.i_pad"	; # pin no: 84
place_pad	-row	IO_NORTH	-location	1429	"pad_vga_green_0.i_pad"	; # pin no: 85
place_pad	-row	IO_NORTH	-location	1291	"pad_vga_blue_1.i_pad"	; # pin no: 86
place_pad	-row	IO_NORTH	-location	1153	"pad_vga_blue_0.i_pad"	; # pin no: 87
place_pad	-row	IO_NORTH	-location	1015	"pad_gndio_14.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	 877	"pad_gndio_15.i_pad"	; #   
place_pad	-row	IO_NORTH	-location	 739	"pad_vccio_14.i_pad"	; # pin no: 88
place_pad	-row	IO_NORTH	-location	 601	"pad_vccio_15.i_pad"	; # pin no: 88

place_corners $iocorner

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST {*}$iofill
place_io_fill -row IO_EAST {*}$iofill


# Connect built-in rings
connect_by_abutment

# We need to assign the terminals a location that aligns to the bond pad.
# Otherwise OpenROAD doesn't find/see the IOs
place_io_terminals *.i_pad/PAD

remove_io_rows