#!/bin/bash

# 1. clean
if [ -d "work" ]; then
    rm -rf work
fi

# 2. establish
vlib work

# 3. compile (Interface -> RTL -> Top Testbench)
vlog +incdir+../vip +incdir+../tb ../vip/ahb_if.sv ../rtl/*.v ../tb/tb_top.sv

# 4. simulate
vsim -voptargs=+acc -do "add wave -r /*; run -all; wave zoom full" tb_top