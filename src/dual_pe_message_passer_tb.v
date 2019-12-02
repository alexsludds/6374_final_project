`timescale 1ns/10ps
// Multi-precision adder test-bench
module processing_element_tb ();

	parameter CLOCK_PERIOD = 100; // 10 MHz clock
	parameter NUM_TEST = 10; // Number of tests

	reg sys_clk;
	wire ready1;
	wire ready2;
	wire ready;
	assign ready = ready1 & ready2;
	reg start;
	reg [9:0] test_err;
	reg [9:0] test_count;

	reg [7:0] isu = 0;
	wire [7:0] osu;
	wire [7:0] osu2;
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
	reg [2:0] command_to_execute = 0;
	wire [7:0] A;
	wire [7:0] B;
	wire [7:0] A2;
	wire [7:0] B2;
	reg ack;

	event terminate_sim;

	// Here we are going to tie together two message passers and see what happens
	//We are only going to tie them in just the up direction

	message_passer #(.PRECISION(8),.OUTPUT_PRECISION(32)) u_DUT  (
        .CLK(sys_clk),
	.ready(ready1),
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
        .command_to_execute(command_to_execute)
		);

	message_passer #(.PRECISION(8),.OUTPUT_PRECISION(32)) u_DUT_2  (
        .CLK(sys_clk),
		.ready(ready2),
		.ack(ack),
		.A(A2),
		.B(B2),
        .s_out(s_out),
	.isu(osu),
        .osu(osu2),
        .isl(isl),
        .osl(osl),
        .isd(isd),
        .osd(osd),
        .isr(isr),
        .osr(osr),
        .a_overwrite(a_overwrite),
        .b_overwrite(b_overwrite),
        .s_out_overwrite(s_out_overwrite),
        .command_to_execute(command_to_execute)
		);

	always @(posedge sys_clk) begin
		if (test_count == NUM_TEST) begin
					-> terminate_sim;
		end
		else if (test_count == 0) begin
			//Test shift up
			//After the first shift we should have 105 on the output of the first PE
			ack = 1;
			wait (ready == 0)
			$display("Performing Test (%d)", test_count);
			isu <= 8'b01101001;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)
	


			ack = 1;
			wait (ready == 0)
			isu <= 8'b01101001;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)



			ack = 1;
			wait (ready == 0)
			isu <= 8'b01101001;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)

			ack = 1;
			wait (ready == 0)
			isu <= 8'b01101001;
			command_to_execute <= 3'b001;
			ack <= 0;
			wait (ready == 1)


			
			if (A != 8'b01101001 || A2 != 8'b01101001 || osu != 8'b01101001 || osu2 != 8'b01101001) begin
				$display("Shift up of A meant to be 01101001 is A=(%d), osu=(%d)",A, osu);
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
