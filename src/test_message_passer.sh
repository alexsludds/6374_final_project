#!/bin/bash
echo "Running message passer test bench"
xrun -sv pe_message_passer_tb.v pe_message_passer.v pe.v +access+r
xrun -sv dual_pe_message_passer_tb.v pe_message_passer.v pe.v +access+r
