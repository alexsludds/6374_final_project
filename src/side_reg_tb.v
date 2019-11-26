// Multi-precision adder test-bench
module processing_element_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests

	reg sys_clk;
	wire ready;
	reg start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	reg [7:0] inp = 0;
	wire [7:0] oup;
	reg [31:0] s_out_overwrite = 0;
	reg [1:0] shift_direction = 0;
	reg [2:0] command_to_execute = 0;
	reg image_to_shift;
	reg ack;

    reg [7:0] test_0 = 0;
    reg [7:0] test_1 = 0;
    reg [7:0] test_2 = 0;
    reg [7:0] test_3 = 0;
    reg [7:0] test_4 = 0;

	event terminate_sim;

	// Modify the module name for the design being tested

	side_reg #(.PRECISION(8),.SIZE(6)) u_DUT  (
        .CLK(sys_clk),
        .ready(ready),
        .ack(ack),
        .inp(inp),
        .oup(oup),
        .image_to_shift(image_to_shift),
        .shift_direction(shift_direction),
        .command_to_execute(command_to_execute)
		);

	always @(posedge sys_clk) begin
		if (test_count == NUM_TEST) begin
					-> terminate_sim;
		end
		else if (test_count == 0) begin
			//We are going to preconfigure the side reg to be on top of the array
            shift_direction = 2'b00;
            image_to_shift <= 1'b0;
            $display("Performing Test (%d)", test_count);
            //This test will consist of moving different values into the array and then moving them out
			ack = 1;
            wait (ready == 0)
			inp <= 8'b00000001;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000011;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000111;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00001111;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)

            //Now we are going to ready out the values by changing the shift direction to down and check what comes out
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
            test_0 <= oup;
            

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
            test_1 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
            test_2 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
            test_3 <= oup;

            //Final check, shifting out an empty array should give zero
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
            test_4 <= oup;
			if (test_0 == 8'b00001111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
                test_err <= test_err + 1;
            end
            if (test_1 == 8'b00000111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
                test_err <= test_err + 1;
            end
            if (test_2 == 8'b00000011) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
                test_err <= test_err + 1;
            end
            if (test_3 == 8'b00000001) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
                test_err <= test_err + 1;
            end
            if (test_4 == 8'b00000000) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
			end 
            else begin
                $display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
                test_err <= test_err + 1;
            end
            test_count <= test_count + 1;
		end

        else if (test_count == 1) begin
			//We are going to preconfigure the side reg to be on top of the array
            shift_direction = 2'b01;
            image_to_shift <= 1'b0;
            $display("Performing Test (%d)", test_count);
            //This test will consist of moving different values into the array and then moving them out
			ack = 1;
            wait (ready == 0)
			inp <= 8'b00000001;
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000011;
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000111;
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00001111;
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)

            //Now we are going to ready out the values by changing the shift direction to down and check what comes out
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
            test_0 <= oup;
            

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
            test_1 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
            test_2 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
            test_3 <= oup;

            //Final check, shifting out an empty array should give zero
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
            test_4 <= oup;
			if (test_0 == 8'b00001111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
                test_err <= test_err + 1;
            end
            if (test_1 == 8'b00000111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
                test_err <= test_err + 1;
            end
            if (test_2 == 8'b00000011) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
                test_err <= test_err + 1;
            end
            if (test_3 == 8'b00000001) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
                test_err <= test_err + 1;
            end
            if (test_4 == 8'b00000000) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
			end 
            else begin
                $display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
                test_err <= test_err + 1;
            end
            test_count <= test_count + 1;
		end

        else if (test_count == 2) begin // Test shifting left
			//We are going to preconfigure the side reg to be on top of the array
            shift_direction = 2'b10;
            image_to_shift <= 1'b0;
            $display("Performing Test (%d)", test_count);
            //This test will consist of moving different values into the array and then moving them out
			ack = 1;
            wait (ready == 0)
			inp <= 8'b00000001;
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000011;
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000111;
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00001111;
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)

            //Now we are going to ready out the values by changing the shift direction to down and check what comes out
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
            test_0 <= oup;
            

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
            test_1 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
            test_2 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
            test_3 <= oup;

            //Final check, shifting out an empty array should give zero
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
            test_4 <= oup;
			if (test_0 == 8'b00001111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
                test_err <= test_err + 1;
            end
            if (test_1 == 8'b00000111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
                test_err <= test_err + 1;
            end
            if (test_2 == 8'b00000011) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
                test_err <= test_err + 1;
            end
            if (test_3 == 8'b00000001) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
                test_err <= test_err + 1;
            end
            if (test_4 == 8'b00000000) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
			end 
            else begin
                $display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
                test_err <= test_err + 1;
            end
            test_count <= test_count + 1;
		end

        else if (test_count == 3) begin
			//We are going to preconfigure the side reg to be on top of the array
            shift_direction = 2'b11;
            image_to_shift <= 1'b0;
            $display("Performing Test (%d)", test_count);
            //This test will consist of moving different values into the array and then moving them out
			ack = 1;
            wait (ready == 0)
			inp <= 8'b00000001;
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000011;
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00000111;
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)

            ack = 1;
            wait (ready == 0)
			inp <= 8'b00001111;
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)

            //Now we are going to ready out the values by changing the shift direction to down and check what comes out
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
            test_0 <= oup;
            

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
            test_1 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
            test_2 <= oup;

            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
            test_3 <= oup;

            //Final check, shifting out an empty array should give zero
            ack = 1;
            wait (ready == 0)
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
            test_4 <= oup;
			if (test_0 == 8'b00001111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_0,8'b00001111);
                test_err <= test_err + 1;
            end
            if (test_1 == 8'b00000111) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_1,8'b00000111);
                test_err <= test_err + 1;
            end
            if (test_2 == 8'b00000011) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_2,8'b00000011);
                test_err <= test_err + 1;
            end
            if (test_3 == 8'b00000001) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
			end 
            else begin
                $display("ERROR First value shifted in was measured to be (%d), meant to be (%d)",test_3,8'b00000001);
                test_err <= test_err + 1;
            end
            if (test_4 == 8'b00000000) begin
				$display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
			end 
            else begin
                $display("First value shifted in was measured to be (%d), meant to be (%d)",test_4,8'b00000000);
                test_err <= test_err + 1;
            end
            test_count <= test_count + 1;
		end

		else begin
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