#!/bin/bash
echo "Running pe array test bench"
iverilog -o pe_array.vvp pe_array_tb.v pe_array.v
vvp pe_array.vvp