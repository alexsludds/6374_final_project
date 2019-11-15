`timescale 1ns/10ps

module mpadd32_shift (CLK, RST_N, s_out, a_in, b_in, write, start, ready);

	input CLK, RST_N;
	input [255:0] a_in, b_in;
	input write, start;
	output [256:0] s_out;
	output ready;

	reg [256:0] sum;
	reg [255:0] a, b;
	reg ready;
	reg [2:0] counter;
	reg carry;

	reg [31:0] a0;
	reg [31:0] a1;
	reg [31:0] a2;
	reg [31:0] a3;
	reg [31:0] a4;
	reg [31:0] a5;
	reg [31:0] a6;
	reg [31:0] a7;

	reg [31:0] b0;
	reg [31:0] b1;
	reg [31:0] b2;
	reg [31:0] b3;
	reg [31:0] b4;
	reg [31:0] b5;
	reg [31:0] b6;
	reg [31:0] b7;

	reg [31:0] s0;
	reg [31:0] s1;
	reg [31:0] s2;
	reg [31:0] s3;
	reg [31:0] s4;
	reg [31:0] s5;
	reg [31:0] s6;
	reg [32:0] s7;

	assign s_out = {s7, s6, s5, s4, s3, s2, s1, s0};

	always @(posedge CLK) begin
		if (~RST_N) begin
			ready <= 1'b0;
		end
		else begin
			if (start) begin
				{carry, s0} <= a0 + b0;
				counter <= counter + 3'b001;
				//Shift all of the registers down
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end
			else if (counter == 3'b001) begin
				{carry, s1} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b010) begin
				{carry, s2} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b011) begin
				{carry, s3} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b100) begin
				{carry, s4} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b101) begin
				{carry, s5} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b110) begin
				{carry, s6} <= a0 + b0 + carry;
				counter <= counter + 3'b001;
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
			end 
			else if (counter == 3'b111) begin
				s7 <= a0 + b0 + carry;
				//Here we have to write all of the values to the output.
				{a0,a1,a2,a3,a4,a5,a6,a7} <= {a1,a2,a3,a4,a5,a6,a7,32'b0};
				{b0,b1,b2,b3,b4,b5,b6,b7} <= {b1,b2,b3,b4,b5,b6,b7,32'b0};
				counter <= 3'b000;
				ready <= 1'b1;
			end
			


			else begin
				if (write) begin
					a0 <= a_in[31:0];
	 				a1 <= a_in[63:32];
					a2 <= a_in[95:64];
					a3 <= a_in[127:96];
					a4 <= a_in[159:128];
					a5 <= a_in[191:160];
					a6 <= a_in[223:192];
					a7 <= a_in[255:224];

					b0 <= b_in[31:0];
	 				b1 <= b_in[63:32];
					b2 <= b_in[95:64];
					b3 <= b_in[127:96];
					b4 <= b_in[159:128];
					b5 <= b_in[191:160];
					b6 <= b_in[223:192];
					b7 <= b_in[255:224];

					counter <= 3'b000;
					carry <= 1'b0;
				end
				ready <= 1'b0;
			end
		end
	end

endmodule

