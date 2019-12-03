#=========================================================================
# Constraints file
#-------------------------------------------------------------------------
#
# This file contains various constraints for your chip including the
# target clock period, fanout, transition time and any
# input/output delay constraints.
#

set_time_unit -picoseconds
set_load_unit -femtofarads

# This constraint sets the target clock period for the chip in
# picoseconds. You should set this constraint carefully. 
# If the period is unrealistically small then the tools will
# spend forever trying to meet timing and ultimately fail. If the period
# is too large the tools will have no trouble but you will get a very
# conservative implementation. 

create_clock -name clk_input -period 5000 [ get_ports "CLK" ]
set_input_delay 100 -clock clk_input [get_ports "s_out_overwrite a_overwrite b_overwrite shift_direction command_to_execute array_ack"]
set_output_delay 100 -clock clk_input [get_ports "ready A_array B_array s_out_array"] 

# This constrainst sets the the maximum fanout a logic gate can have. This attribute 
# basically limits the number of gates driven by an output. 10 is reasonable number.

set_max_fanout 10 [current_design]

# The transition time is the amount of time it takes for a signal to change from one
# logic state to another. Setting a maximum transition limit on  
# a design sets the default maximum transition for a design.

set_max_transition 100 [current_design]

# The load on a net is comprised of the fanout and interconnect capacitance.
# Setting a maximum capacitance limit on a port specifies that the net connected to that port to
# have a total capacitance that is less than the value you specify. Setting a maximum
# capacitance limit on a design sets the default maximum capacitance for that design.

set_max_capacitance 10000 [current_design]
