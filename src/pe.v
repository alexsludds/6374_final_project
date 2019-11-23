`timescale 1ns/10ps

module processing_element 
    # (parameter PRECISION = 8,
       parameter OUTPUT_PRECISION = 32)
    (
        CLK,
        s_in,
        s_out,
        a_in,
        b_in,
        start_multiply,
        pe_ready,
        pe_ack
        );

	input CLK;
    output reg pe_ready = 0;
	input [PRECISION-1:0] a_in, b_in;
	input start_multiply;
    input [OUTPUT_PRECISION-1:0] s_in;
	output reg [OUTPUT_PRECISION-1:0] s_out;
    input pe_ack;

	always @(posedge CLK) begin
        if (pe_ack) begin 
            pe_ready <= 0;
        end
        else begin
            if (start_multiply) begin 
                s_out = s_in + a_in * b_in;
                pe_ready = 1;
            end
        end
	end
endmodule