#!/bin/bash

# 1. clean
if [ -d "work" ]; then
    rm -rf work
fi

# 2. establish
vlib work

# 3. compile
vlog +incdir+../vip ../vip/*.sv
vlog +incdir+../tb ../tb/tb_top.sv
vlog ../rtl/*.v

# 4. open GUI and load signal/wave
# -do "..." 
# add wave -r /*
# run -all
vsim -voptargs=+acc -do "add wave -r /*; run -all; wave zoom full" top