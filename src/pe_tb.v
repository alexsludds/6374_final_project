`timescale 1ns/10ps

// Multi-precision adder test-bench
module pe_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests
	parameter PRECISION = 8;
	parameter OUTPUT_PRECISION = 32;

	reg sys_clk, reset;
	reg write, start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	wire ready;

	wire [OUTPUT_PRECISION-1:0] s_golden;
	reg [PRECISION-1:0] a = 0;
	reg [PRECISION-1:0] b = 0;
	reg [OUTPUT_PRECISION-1:0] s_in = 0;
	wire [OUTPUT_PRECISION-1:0] s_out;

	assign s_golden = s_in + {{(OUTPUT_PRECISION-PRECISION){1'b0}},a * b};

	event terminate_sim;

	processing_element #(.PRECISION(PRECISION), .OUTPUT_PRECISION(OUTPUT_PRECISION)) u_DUT (.CLK(sys_clk), .reset(reset), .s_out(s_out), .s_in(s_in), .a_in(a), .b_in(b), .start_multiply(start), .ready(ready));

	always @(posedge sys_clk) begin
		if (reset == 1'b1) begin
			if (test_count == NUM_TEST) begin
					-> terminate_sim;
			end
			start <= 1'b1;
			//In the first couple of tests we are going to check some state specifics
			if (ready) begin
				$display("TEST %d: A = %h, B = %h, S_in = %h, S_out = %h, S_golden = %h", test_count + 1, a, b, s_in, s_out, s_golden);
				if (s_out != s_golden) begin
					$display("ERROR (%d)", test_count);
					test_err <= test_err + 1;
				end
				test_count <= test_count + 1;
				a <= a + 5;
				b <= b + 7;
				s_in <= s_in + 2;
			end
		end
    end

	// End of simulation
    	initial @(terminate_sim) begin
        	$display("END OF SIMULATION (Time: %g ns)", $time);
        	if(test_err == 0) begin
            		$display("TEST RESULT: PASSED (%d / %d)", test_count, test_count);
        	end
        	else begin
            		$display("TEST RESULT: FAILED (%d / %d)", test_err, test_count);
        	end
        	$display("##################\n");
        	#1  $finish;
    	end

	// Initial conditions
	initial begin
	    	sys_clk = 1'b0; reset = 1'b0;
			start = 1'b0;
        	test_err = 0; test_count = 0;
		#CLOCK_PERIOD reset = 1'b1;
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
