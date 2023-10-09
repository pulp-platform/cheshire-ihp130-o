onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label boot_mode_i /tb_iguana/fix/i_dut/i_iguana_soc/boot_mode_i*
add wave -noupdate -label rst_ni /tb_iguana/fix/i_dut/i_iguana_soc/rst_ni*
add wave -noupdate -label clk_i /tb_iguana/fix/i_dut/i_iguana_soc/clk_i*
add wave -noupdate -label rtc_i /tb_iguana/fix/i_dut/i_iguana_soc/rtc_i*
add wave -noupdate -expand -group chip-jtag -label jtag_tck_i /tb_iguana/fix/i_dut/i_iguana_soc/jtag_tck_i*
add wave -noupdate -expand -group chip-jtag -label jtag_trst_ni /tb_iguana/fix/i_dut/i_iguana_soc/jtag_trst_ni*
add wave -noupdate -expand -group chip-jtag -label jtag_tms_i /tb_iguana/fix/i_dut/i_iguana_soc/jtag_tms_i*
add wave -noupdate -expand -group chip-jtag -label htag_tdi_i /tb_iguana/fix/i_dut/i_iguana_soc/jtag_tdi_i*
add wave -noupdate -expand -group chip-jtag -label jtag_tdo_o /tb_iguana/fix/i_dut/i_iguana_soc/jtag_tdo_o*
add wave -noupdate -expand -group chip-jtag -label jtag_tdo_oe_o /tb_iguana/fix/i_dut/i_iguana_soc/jtag_tdo_oe_o*
add wave -noupdate -expand -group chip-uart -label uart_tx_o /tb_iguana/fix/i_dut/i_iguana_soc/uart_tx_o*
add wave -noupdate -expand -group chip-uart -label uart_rx_i /tb_iguana/fix/i_dut/i_iguana_soc/uart_rx_i*

add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_rst_no /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_rst_no*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_req_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_req_o*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_reg_valid_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_req_valid_o*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_reg_ready_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_req_ready_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_resp_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_resp_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_resp_ready_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_resp_ready_o*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dmi-reg-interface -label dmi_resp_valid_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/dmi_resp_valid_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label tck_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/tck_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label tms_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/tms_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label trst_ni /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/trst_ni*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label td_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/td_i*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label tdo_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/td_o*
add wave -noupdate -group {jtag to dbg-intf bridge} -expand -group dbg-jtag -label tdo_oe_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dmi_jtag/tdo_oe_o*

add wave -noupdate -group {debug module} -label ndmreset_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/ndmreset_o*
add wave -noupdate -group {debug module} -label dmactive_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/dmactive_o*
add wave -noupdate -group {debug module} -label debug_req_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/debug_req_o*
add wave -noupdate -group {debug module} -label unavailable_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/unavailable_i*
add wave -noupdate -group {debug module} -label hartinfo_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/hartinfo_i*
add wave -noupdate -group {debug module} -label sig_halted /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/halted*
add wave -noupdate -group {debug module} -label sig_resumeack /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/resumeack*
add wave -noupdate -group {debug module} -label sig_haltreq /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/haltreq*
add wave -noupdate -group {debug module} -label sig_resumereq /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/i_dbg_dm_top/resumereq*

add wave -noupdate -group {core cva6} -label clk_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_cva6_cores*0*i_core_cva6/clk_i*
add wave -noupdate -group {core cva6} -label debug_req_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_cva6_cores*0*i_core_cva6/debug_req_i*
add wave -noupdate -group {core cva6} -label axi_req_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_cva6_cores*0*i_core_cva6/axi_req_o*
add wave -noupdate -group {core cva6} -label axi_resp_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_cva6_cores*0*i_core_cva6/axi_resp_i*
add wave -noupdate -group {core cva6} -label sig_pc_commit /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_cva6_cores*0*i_core_cva6/pc_commit*

add wave -noupdate -group {uart module} -label reg_req_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/reg_req_i*
add wave -noupdate -group {uart module} -label reg_rsp_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/reg_rsp_o*
add wave -noupdate -group {uart module} -label sin_i /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/sin_i*
add wave -noupdate -group {uart module} -label sout_o /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/sout_o*

add wave -noupdate -label TXCLK /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/TXCLK*
add wave -noupdate -label TXSTART /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/TXSTART*
add wave -noupdate -label CLEAR /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/CLEAR*
add wave -noupdate -label DIN /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/DIN*
add wave -noupdate -label TXFINISHED /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/TXFINISHED*
add wave -noupdate -label CState /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/CState*
add wave -noupdate -label NState /tb_iguana/fix/i_dut/i_iguana_soc/i_cheshire_soc/gen_uart/i_uart/i_apb_uart/UART_TX/NState*

TreeUpdate [SetDefaultTree]
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3378517846 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {563086666 ps} {3378925528 ps}
