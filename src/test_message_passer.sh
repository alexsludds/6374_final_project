#!/bin/bash
echo "Running message passer test bench"
iverilog -o pe_message_passer.vvp pe_message_passer_tb.v pe_message_passer.v
vvp pe_message_passer.vvp