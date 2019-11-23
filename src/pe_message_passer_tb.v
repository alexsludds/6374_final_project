// Multi-precision adder test-bench
module processing_element_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests

	reg sys_clk;
	wire ready;
	reg start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	reg [7:0] isu = 0;
	wire [7:0] osu;
	reg [7:0] isl = 0;
	wire [7:0] osl;
	reg [7:0] isd = 0;
	wire [7:0] osd;
	reg [7:0] isr = 0;
	wire [7:0] osr;
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

	message_passer #(.PRECISION(8),.OUTPUT_PRECISION(32)) u_DUT  (
        .CLK(sys_clk),
		.ready(ready),
		.ack(ack),
		.A(A),
		.B(B),
        .s_out(s_out),
        .isu(isu),
        .osu(osu),
        .isl(isl),
        .osl(osl),
        .isd(isd),
        .osd(osd),
        .isr(isr),
        .osr(osr),
        .a_overwrite(a_overwrite),
        .b_overwrite(b_overwrite),
        .s_out_overwrite(s_out_overwrite),
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
		else if (test_count == 1) begin
			//Test shift down
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			isd <= 8'b00000111;
			image_to_shift <= 1'b0;
			command_to_execute <= 3'b010;
			ack <= 0;
			wait (ready == 1)
			if (osd != 8'b01101001 || A != 8'b00000111) begin
				$display("Shift up of A meant to be 00000111 is A=(%d), osd=(%d)",A, osd);
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count = test_count + 1;
		end
		else if (test_count == 2) begin
			//Test shift left
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			isl <= 8'b10000110;
			image_to_shift <= 1'b1;
			command_to_execute <= 3'b011;
			ack <= 0;
			wait (ready == 1)
			if (osl != 8'b0 || B != 8'b10000110) begin
				$display("Shift up of B meant to be 01101001 is B=(%d), osl=(%d)",B, osl);
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count <= test_count + 1;
		end
		else if (test_count == 3) begin
			//Test shift right
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			isr <= 8'b10100110;
			image_to_shift <= 1'b1;
			command_to_execute <= 3'b100;
			ack <= 0;
			wait (ready == 1)
			if (osr != 8'b10000110 || B != 8'b10100110) begin
				$display("Shift up of B meant to be 01101001 is B=(%d), osr=(%d)",B, osr);
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count <= test_count + 1;
		end
		else if (test_count == 4) begin
			//Test multiplier. We already have preloaded in some values
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			command_to_execute <= 3'b000;
			ack <= 0;
			wait (ready == 1)
			$display("Multiplier test result:(%d)",s_out);
			if (s_out != 32'b010010001010) begin
				$display("ERROR (%d)", test_count);
				$display("Multiplier test result:(%d)",s_out);
				test_err <= test_err + 1;
			end
			test_count <= test_count + 1;
		end
		else if (test_count == 5) begin
			//Test overwrite A and B
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			a_overwrite <= 8'b00111101;
			b_overwrite <= 8'b01110001;
			command_to_execute <= 3'b101;
			ack <= 0;
			wait (ready == 1)
			if (A != 8'b00111101 || B!= 8'b01110001) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count <= test_count + 1;
		end
		else if (test_count == 6) begin
			//Test Overwrite S_out
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			s_out_overwrite <= 32'b01011101111101100100100101000100;
			command_to_execute <= 3'b110;
			ack = 0;
			wait (ready == 1)
			if (s_out != 32'b01011101111101100100100101000100) begin
				$display("ERROR (%d)", test_count);
				test_err <= test_err + 1;
			end
			test_count <= test_count + 1;
		end
		else if (test_count == 7) begin
			//Test Reset
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			command_to_execute <= 3'b111;
			ack = 0;
			wait (ready == 1)
			if (A != 8'b0 || B != 8'b0 || s_out != 8'b0) begin
				$display("ERROR (%d)", test_count);
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