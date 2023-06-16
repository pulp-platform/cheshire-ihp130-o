# Incoming clocks are assumed ideal, but need to pick up (TT) pad input delay
# set PAD_IN_DELAY  0.9
# set PAD_IN_CLKS  [get_clocks {clk_sys clk_jtg clk_rtc clk_sli clk_hyp_rwdsi clk_gen_hyp_rxdly clk_gen_hyp_rxinv}]
# set_clock_latency $PAD_IN_DELAY $PAD_IN_CLKS

# Outgoing clocks are assumed ideal, but need to pick up (TT) pad input AND output delay,
# As they are derived from an incoming clock assumed ideal that entered through a pad and
# then themselves exit through another pad (we ignore on-chip delays here).
# set PAD_OUT_DELAY 3.2
# set PAD_OUT_CLKS [get_clocks {clk_gen_slo clk_gen_slo_drv clk_gen_hyp_txdly}]
# set_clock_latency [expr $PAD_IN_DELAY + $PAD_OUT_DELAY] $PAD_OUT_CLKS

set_propagated_clock [all_clocks]