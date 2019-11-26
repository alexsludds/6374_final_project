#!/bin/bash
echo "Running side reg test bench"
iverilog -o side_reg.vvp side_reg_tb.v side_reg.v
vvp side_reg.vvp