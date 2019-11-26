// Multi-precision adder test-bench
module processing_element_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests

	reg sys_clk;
	input ready;
	reg start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	wire [31:0] s_out;
	reg [7:0] a_overwrite = 0;
	reg [7:0] b_overwrite = 0;
	reg [31:0] s_out_overwrite = 0;
	reg [1:0] shift_direction = 0;
	reg [2:0] command_to_execute = 0;
	reg image_to_shift;
	wire [7:0] A;
	wire [7:0] B;
	reg ack;

	event terminate_sim;

	// Modify the module name for the design being tested

	pe_array #(.PRECISION(8),.OUTPUT_PRECISION(32)) u_DUT  (
        .CLK(sys_clk),
		.ready(ready),
		.array_ack(array_ack),
		// .A_array(A_array),
        // .B_array(B_array),
        // .s_out_array(s_out_array),
        // .a_overwrite(a_overwrite),
        // .b_overwrite(b_overwrite),
        // .s_out_overwrite(s_out_overwrite),
        .shift_direction(shift_direction),
		.image_to_shift(image_to_shift),
        .command_to_execute(command_to_execute)
		);

	always @(posedge sys_clk) begin
		if (test_count == NUM_TEST) begin
					-> terminate_sim;
		end
		else if (test_count == 0) begin
			//Test shift up
			ack = 1;
			$display("Performing Test (%d)", test_count);
			isu <= 8'b01101001;
			image_to_shift <= 1'b0;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
			if (osu != 8'b0 || A != 8'b01101001) begin
				$display("Shift up of A meant to be 01101001 is A=(%d), osu=(%d)",A, osu);
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		
		else begin //In the event NUM_TEST is below the number of tests
			test_count <= test_count + 1;
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
	    sys_clk = 1'b0;
        test_err = 0; test_count = 0;
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