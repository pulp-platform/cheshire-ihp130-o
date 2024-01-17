set ROOT "/home/msc23h5/repos/basilisk"
vlog -sv "$ROOT/.bender/git/checkouts/cheshire-4d602a690802c1f8/hw/bootrom/cheshire_bootrom.sv"
vlog -sv +define+NO_BOOTROM_WRAP "$ROOT/hw/cheshire_bootrom_split.sv"
vlog -sv "$ROOT/target/sim/src/tb_cheshire_bootrom.sv"
exit