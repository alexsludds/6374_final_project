#=========================================================================
# TCL Script File for Synthesis using Cadence Genus Synthesis Solution
#-------------------------------------------------------------------------
# Modified on June 4, 2019 by Alex Ji: Update commands for Genus (from RTL Compiler)

# 

# The makefile will generate various variables which we now read in
# and then display

source make_generated_vars.tcl
echo ${SEARCH_PATH}
echo ${VERILOG_SRCS}
echo ${VERILOG_TOPLEVEL}

# The library setup is kept in a separate tcl file which we now source

source libs.tcl

# These two commands read in your verilog source and elaborate it

read_hdl ${VERILOG_SRCS}
elaborate

# This command will check your design for any errors

check_design > synth_check_design.rpt

# We now load in the constraints file

source synth.sdc
read_vcd -vcd_scope ${VCD_SCOPE} ${VCD_FILE_NAME}

# This actually does the synthesis. The syn_*_effort attribute indicates 
# how much time the synthesizer should spend optimizing your design to
# gates. Setting it to high means synthesis will take longer but will
# probably produce better results. Setting dp_ungroup_during_syn_map to false
# maintains the hierarchy during mapping.

set_db syn_generic_effort high
set_db syn_map_effort high
set_db dp_ungroup_during_syn_map false

syn_generic
syn_map

# We write out the results as a verilog netlist

write_hdl > synthesized.v

# We create a timing report for the worst case timing path, 
# an area report for each reference in the heirachy and a DRC report

report_timing > timing.rpt
report_area > cell_area.rpt
report_gates > gate_area.rpt
# power line added Oct 30 2011 by Arun Paidimarri
report_power -by_category > power.rpt
report_design_rules > design_rule_violations.rpt

# Used to exit Genus

exit
