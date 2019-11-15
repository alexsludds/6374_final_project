set_clock_latency -source -early -min -rise  -0.0670216 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -early -min -fall  -0.0656371 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -late -min -rise  -0.0670216 [get_ports {CLK}] -clock clk_input 
set_clock_latency -source -late -min -fall  -0.0656371 [get_ports {CLK}] -clock clk_input 
