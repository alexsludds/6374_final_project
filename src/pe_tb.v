`timescale 1ns/10ps

// Multi-precision adder test-bench
module pe_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests
	parameter PRECISION = 8;
	parameter OUTPUT_PRECISION = 32;

	reg sys_clk;
	reg reset = 0;
	reg start = 0;
	reg [9:0] test_err;
	reg [9:0] test_count;

	wire ready;

	reg [PRECISION-1:0] a = 0;
	reg [PRECISION-1:0] b = 0;
	reg ack;
	wire [OUTPUT_PRECISION-1:0] s_out;

	event terminate_sim;

	processing_element #(.PRECISION(PRECISION), .OUTPUT_PRECISION(OUTPUT_PRECISION)) u_DUT (
	.CLK(sys_clk),
        .reset(reset),
        .s_out(s_out),
        .a_in(a),
        .b_in(b),
        .start_multiply(start),
        .pe_ready(ready),
        .pe_ack(ack));

	always @(posedge sys_clk) begin
		if (test_count == NUM_TEST) begin
					-> terminate_sim;
		end
		else if (test_count == 0) begin
			//Test multiply with zero initial conditions
			ack = 1;
			wait (ready == 0);
			$display("Performing Test (%d)", test_count);
			a <= 8'b00111101;
			b <= 8'b01110001;
			start <= 1;

			ack <= 0;
			wait (ready == 1)
			$display("Multiplier test result:(%d)",s_out);
			if (s_out != 32'b01101011101101) begin
				$display("ERROR (%d)", test_count);
				$display("Multiplier test result:(%d)",s_out);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 1) begin
			//Test multiply with accumulation
			ack = 1;
			wait (ready == 0);
			$display("Performing Test (%d)", test_count);
			a <= 8'b00111101;
			b <= 8'b01110001;
			start <= 1;

			ack <= 0;
			wait (ready == 1)
			$display("Multiplier test result:(%d)",s_out);
			if (s_out != 32'b011010111011010) begin
				$display("ERROR (%d)", test_count);
				$display("Multiplier test result:(%d)",s_out);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 2) begin
			//Test reset
			ack = 1;
			wait (ready == 0);
			$display("Performing Test (%d)", test_count);
			reset  <= 1;

			ack <= 0;
			wait (ready == 1)
			if (s_out != 32'b0) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else begin
			test_count <= test_count + 1;
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
	    	sys_clk = 1'b0;
        	test_err = 0; test_count = 0;
		#(CLOCK_PERIOD/2) $display("START OF SIMULATION (Time: %g ns)", $time);
    	end

	// System clock generator
	always begin
		#(CLOCK_PERIOD/2) sys_clk = ~sys_clk;
	end

endmodule
