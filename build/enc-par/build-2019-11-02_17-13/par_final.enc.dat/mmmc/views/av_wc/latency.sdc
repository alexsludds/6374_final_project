set_clock_latency -source -early -max -rise  -0.169772 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -early -max -fall  -0.172397 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -late -max -rise  -0.169772 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -late -max -fall  -0.172397 [get_ports {CLK}] -clock clk_input 
