
#=========================================================================
# TCL Script File for RC Compiler Library Setup
#-------------------------------------------------------------------------

# The makefile will generate various variables which we now read in

source make_generated_vars.tcl

# The following commands setup the standard cell libraries

set_db library /mit/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/slow_vdd1v2_basicCells.lib

# The search path needs to point to the verilog source directory

set_db init_hdl_search_path ${SEARCH_PATH}


