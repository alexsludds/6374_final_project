#!/bin/bash
echo "Running system test bench"
xrun -sv system_tb.v TreeAdder.sv ShadowReg.sv pe_array.v +access+r
