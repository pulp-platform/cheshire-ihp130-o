# VSIM GUI debugging


Run

```
cd target/sim/vsim/
questa-2022.3 vsim

source compile.iguana.tcl;

vsim -c tb_iguana -t 1ps -vopt -voptargs="-O5 +acc" +BOOTMODE=0 +PRELMODE=1 +BINARY=../../../sw/tests/helloworld.dram.elf -permissive -suppress 3009 -suppress 8386 -error 7
log -r /*
```