`timescale 1ns/10ps
// Multi-precision adder test-bench
module pe_array_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests
	
	parameter ARRAY_SIZE_1D = 2;
	parameter EXTENSION_AMOUNT = 2;

	reg sys_clk;
	reg start;
	reg [9:0] test_err;
	reg [9:0] test_count;	
	reg ready;
	wire [7:0] A_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	wire [7:0] B_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	wire [31:0] s_out_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	reg [7:0] a_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0] = '{default:0};
	reg [7:0] b_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0] = '{default:0};
	reg [31:0] s_out_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0] = '{default:0};
	reg [2:0] command_to_execute = 0;
	reg ack;

	event terminate_sim;

	// Modify the module name for the design being tested
	pe_array # (
        .ARRAY_SIZE_1D(ARRAY_SIZE_1D),
		.EXTENSION_AMOUNT(EXTENSION_AMOUNT),
        .long_shift_amount(4),
        .PRECISION(8),
        .OUTPUT_PRECISION(32)) u_DUT  
    (
        .CLK(sys_clk),
        .ready(ready),
        .array_ack(ack),
        .A_array(A_array),
        .B_array(B_array),
        .s_out_array(s_out_array),
        .a_overwrite(a_overwrite),
        .b_overwrite(b_overwrite),
        .s_out_overwrite(s_out_overwrite),
        .command_to_execute(command_to_execute));

	initial begin 
		//Here we write test examples into the overwrite arrays
		//The default for a is just four ones in the pe array
		a_overwrite[0][0] = 1;
		a_overwrite[0][1] = 2;
		a_overwrite[1][0] = 3;
		a_overwrite[1][1] = 4;

		//Same for b
		b_overwrite[0][0] = 1;
		b_overwrite[1][0] = 1;
		b_overwrite[0][1] = 1;
		b_overwrite[1][1] = 1;
	end
 	
	always @(posedge sys_clk) begin
		if (test_count == NUM_TEST) begin
					-> terminate_sim;
		end
		else if (test_count == 0) begin
			$display("Performing Test (%d)", test_count);
			//Test array loading.
			//For testing shifting we first need to load in the overwrite arrays
			ack = 1;
			wait(ready == 0)
			
			command_to_execute <= 3'b101;
			
			ack <= 0;
			wait (ready == 1)

			//Now we need to test if the A_out and B_out array is correct
			if (A_array[0][0] != 1 || A_array[0][1] != 2 || A_array[1][0] != 3 || A_array[1][1] != 4 || B_array[0][0] != 1 || B_array[0][1] != 1 || B_array[1][0] != 1 || B_array[1][1] != 1) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 1) begin
			$display("Performing Test (%d)", test_count);
			//The real test. Now that we have loaded the data we need to shift it around a bit.
			//Let's shift up down left right and then see if the correct data is still in A,B
			//Up
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b001;
			
			ack <= 0;
			wait (ready == 1)

			//left
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b011;
			
			ack <= 0;
			wait (ready == 1)

			//Down
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b010;
			
			ack <= 0;
			wait (ready == 1)

			//Right
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b100;
			
			ack <= 0;
			wait (ready == 1)
						
			//Now we verify that the result is correct
			if (A_array[0][0] != 1 || A_array[0][1] != 2 || A_array[1][0] != 3 || A_array[1][1] != 4 || B_array[0][0] != 1 || B_array[0][1] != 1 || B_array[1][0] != 1 || B_array[1][1] != 1) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 2) begin
			$display("Performing Test (%d)", test_count);
			//Here we are going to multiply all of the values are we have loaded in
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b000;
			
			ack <= 0;
			wait (ready == 1)
			//Now that the values are multiplied we can check their values
			if (s_out_array[0][0] != 1 || s_out_array[0][1] != 2 || s_out_array[1][0] != 3 || s_out_array[1][1] != 4) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 3) begin
			//I want to test that s_out accumlates in place. Here we are going to do the multiply again, but the results should be double of last time
			ack = 1;
			wait(ready == 0)
			
			command_to_execute <= 3'b000;
			ack <= 0;
			wait (ready == 1)

			//Now that the values are multiplied we can check their values
			if (s_out_array[0][0] != 2 || s_out_array[0][1] != 4 || s_out_array[1][0] != 6 || s_out_array[1][1] != 8) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 4) begin
			//Test overwrite s_out
			$display("Performing Test (%d)", test_count);
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b110;
			
			ack <= 0;
			wait (ready == 1)
			if (s_out_array[0][0] != 0 || s_out_array[0][1] != 0 || s_out_array[1][0] != 0 || s_out_array[1][1] != 0) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 5) begin
			//Test going beyond the bounds of the array
			$display("Performing Test (%d)", test_count);
			//Here we are going to shift up 4 times 
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b001;
			
			ack <= 0;
			wait (ready == 1)

			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b001;
			
			ack <= 0;
			wait (ready == 1)

			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b001;
			
			ack <= 0;
			wait (ready == 1)

			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b001;
			
			ack <= 0;
			wait (ready == 1)

			//Now that we have shifted up 4 times we are going to look at shift back 
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b010;
			
			ack <= 0;
			wait (ready == 1)
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b010;
			
			ack <= 0;
			wait (ready == 1)
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b010;
			
			ack <= 0;
			wait (ready == 1)
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b010;
			
			ack <= 0;
			wait (ready == 1)
			//NOTE! This is a known issue in this system. When we shift data out and then shift it back in we get high-z.
			//Now we verify that the result is correct
			if (A_array[0][0] != 0 || A_array[0][1] != 0 || A_array[1][0] != 0 || A_array[1][1] != 0) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			
			test_count = test_count + 1;
		end
		else if (test_count == 6) begin
			//Test reset
			$display("Performing Test (%d)", test_count);
			ack = 1;
			wait(ready == 0)

			command_to_execute <= 3'b111;
			
			ack <= 0;
			wait (ready == 1)
			if (A_array[0][0] != 0 || A_array[0][1] != 0 || A_array[1][0] != 0 || A_array[1][1] != 0 || B_array[0][0] != 0 || B_array[0][1] != 0 || B_array[1][0] != 0 || B_array[1][1] != 0 ) begin
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
