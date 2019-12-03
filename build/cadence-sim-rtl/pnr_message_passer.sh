#!/bin/bash

echo "Running place and route + testbench for pe message passing module"

xrun ../../src/pe_message_passer.v ../../src/pe_message_passer_tb.v +access+r
