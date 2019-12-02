`timescale 1ns/10ps

module processing_element 
    # (parameter PRECISION = 8,
       parameter OUTPUT_PRECISION = 32)
    (
        CLK,
	reset,
        s_out,
        a_in,
        b_in,
        start_multiply,
        pe_ready,
        pe_ack
        );

	input CLK;
	input reset;
    output reg pe_ready = 0;
	input [PRECISION-1:0] a_in, b_in;
	input start_multiply;
    	reg [OUTPUT_PRECISION-1:0] s_in = 0;
	output reg [OUTPUT_PRECISION-1:0] s_out = 0;
    input pe_ack;

	always @(posedge CLK) begin
		if (pe_ack) begin 
		    pe_ready <= 0;
		end
		else begin
			if (reset == 1) begin
				s_in = 0;
				s_out = 0;
				pe_ready = 1;
			end
			else if (start_multiply == 1) begin 
				s_out = s_in + a_in * b_in;
				s_in = s_out;
				pe_ready = 1;
			end
		end
        end
endmodule
