#!/bin/bash
echo "Running pe array test bench"
xrun -sv pe_array.v pe_array_tb.v pe_message_passer.v pe.v +access+r
