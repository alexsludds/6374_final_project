`timescale 1ns/10ps

// 256-bit LFSR for pseudo-random number generation
module lfsr_256 (CLK, RST_N, state, init_val, en);
	
	input CLK, RST_N;
	input [255:0] init_val;
	input en;
	output [255:0] state;

	reg [255:0] state;

	always @(posedge CLK) begin
		if (~RST_N) begin
			state <= init_val;
		end
		else begin
			if (en) begin
				state <= {state[0], state[255] ^ state[0], state[254], state[253] ^ state[0], state[252:251],
					  state[250] ^ state[0], state[249:246], state[245] ^ state[0], state[244:1]};
			end
		end
	end

endmodule

// Multi-precision adder test-bench
module mpadd_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 1000; // Number of tests

	reg sys_clk, sys_rst_n;
	reg [3:0] state;
	reg en_a, en_b;
	reg write, start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	wire [255:0] a, b;
	wire [256:0] s_out, s_golden;
	wire ready;

	event terminate_sim;

	lfsr_256 u_lfsr_a (.CLK(sys_clk), .RST_N(sys_rst_n), .state(a), .init_val(256'h6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296), .en(en_a));
	lfsr_256 u_lfsr_b (.CLK(sys_clk), .RST_N(sys_rst_n), .state(b), .init_val(256'h4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5), .en(en_b));

	// Modify the module name for the design being tested
	//mpadd256_full u_DUT (.CLK(sys_clk), .RST_N(sys_rst_n), .s_out(s_out), .a_in(a), .b_in(b), .write(write), .start(start), .ready(ready));

	mpadd32 u_DUT (.CLK(sys_clk), .RST_N(sys_rst_n), .s_out(s_out), .a_in(a), .b_in(b), .write(write), .start(start), .ready(ready));

	//mpadd32_shift u_DUT (.CLK(sys_clk), .RST_N(sys_rst_n), .s_out(s_out), .a_in(a), .b_in(b), .write(write), .start(start), .ready(ready));


	assign s_golden = {1'b0, a} + {1'b0, b};

	always @(posedge sys_clk) begin
		if (sys_rst_n == 1'b1) begin
			if (state == 4'h0) begin
				if (test_count == NUM_TEST) begin
					-> terminate_sim;
				end
				if (test_count == 0) begin
					en_a <= 1'b1; en_b <= 1'b1;
					state <= 4'h1;
				end
			end
			if (state == 4'h1) begin
				en_a <= 1'b0; en_b <= 1'b0; write <= 1'b1;
				state <= 4'h2;
			end
			if (state == 4'h2) begin
				start <= 1'b1; write <= 1'b0;
				state <= 4'h3;
			end
			if (state == 4'h3) begin
				start <= 1'b0;
				if (ready) begin
					//$display("TEST %d: A = %h, B = %h, S_out = %h, S_golden = %h", test_count + 1, a, b, s_out, s_golden);
					if (s_out != s_golden) begin
						$display("ERROR (%d)", test_count);
						test_err <= test_err + 1;
					end
					if (test_count == NUM_TEST - 1) begin
						state <= 4'h0;
					end
					else begin
						en_a <= 1'b1; en_b <= 1'b1;
						state <= 4'h1;
					end
					test_count <= test_count + 1;
				end
			end
		end
    	end

	// End of simulation
    	initial @(terminate_sim) begin
        	$display("END OF SIMULATION (Time: %g ns)", $time);
        	if(test_err == 0) begin
            		$display("TEST RESULT: PASS (%d / %d)", test_count, test_count);
        	end
        	else begin
            		$display("TEST RESULT: FAIL (%d / %d)", test_err, test_count);
        	end
        	$display("##################\n");
        	#1  $finish;
    	end

	// Initial conditions
	initial begin
	    	sys_clk = 1'b0; sys_rst_n = 1'b0;
        	en_a = 1'b0; en_b = 1'b0;
		state = 4'h0;
		write = 1'b0; start = 1'b0;
        	test_err = 0; test_count = 0;
		#CLOCK_PERIOD sys_rst_n = 1'b1;
		#(CLOCK_PERIOD/2) $display("START OF SIMULATION (Time: %g ns)", $time);
    	end


	// VCD dump
	initial begin
		$dumpfile("mpadd.vcd");
		$dumpvars(0, u_DUT);
	end

	// System clock generator
	always begin
		#(CLOCK_PERIOD/2) sys_clk = ~sys_clk;
	end

endmodule
