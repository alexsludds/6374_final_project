#!/bin/bash
echo "Running system test bench"
xrun -sv system_tb.v TreeAdder.sv TreeAdderElement.sv ShadowReg.sv pe_array.v pe_message_passer.v pe.v +access+r
