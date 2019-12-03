#!/bin/bash
echo "Running place and route on system test bench"
xrun -sv ../../src/system_tb.v ../../src/TreeAdder.sv ../../src/TreeAdderElement.sv ../../src/ShadowReg.sv ../../src/pe_array.v ../../src/pe_message_passer.v ../../src/pe.v +access+r
