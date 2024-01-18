#! /bin/bash

export RISCV_64="/usr/pack/riscv-1.0-kgf/riscv64-gcc-11.2.0"
export PATH="${RISCV_64}/bin/:$PATH"
#export PATH=$PATH:/usr/scratch/pisoc11/sem23f30/tools/bin/
export PATH="/usr/scratch3/pisoc11/msc23h5/yosys-abc-fix/bin:$PATH"
export OPENROAD_OUT_DIR="/usr/scratch3/pisoc11/msc23h5/runs/openroad"
export YOSYS_OUT_DIR="/usr/scratch3/pisoc11/msc23h5/runs/yosys"
export PICKLE_OUT_DIR="/usr/scratch3/pisoc11/msc23h5/runs/pickle"