#=========================================================================
# Constraints file
#-------------------------------------------------------------------------
#
# This file contains various constraints for your chip including the
# target clock period, the capacitive load of output pins, and any
# input/output delay constraints.
#

# This constraint sets the target clock period for the chip in
# nanoseconds. You should set this constraint carefully. 
# If the period is unrealistically small then the tools will
# spend forever trying to meet timing and ultimately fail. If the period
# is too large the tools will have no trouble but you will get a very
# conservative implementation. 

create_clock CLK -name clk_input -period 100.0
set_input_delay 0.1 -clock clk_input [get_ports "RST_N a_in b_in write start"]
set_output_delay 0.1 -clock clk_input [get_ports "s_out ready"] 

# This constrainst sets the load capacitance in picofarads of the
# output pins of your design. 4fF is reasonable if your design is
# driving another block of on-chip logic.

set_load -pin_load 0.004 [all_outputs]

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. INVX1 is a small inverter and is
# reasonable if another block of on-chip logic is driving your inputs.

set_driving_cell -lib_cell INVX1 [all_inputs]
