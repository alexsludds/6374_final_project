`timescale 1ns/10ps
`include "pe_message_passer.v"
`include "array_packing.v"

module pe_array 
    # (
        parameter ARRAY_SIZE_1D = 1,
	parameter EXTENSION_AMOUNT = 4,
        parameter long_shift_amount = 4,
        parameter PRECISION = 8,
        parameter OUTPUT_PRECISION = 32)
    (
        CLK,
        ready,
        array_ack,
        A_array,
        B_array,
        s_out_array,
        a_overwrite,
        b_overwrite,
        s_out_overwrite_array,
        shift_direction,
        image_to_shift,
        command_to_execute);
	
	parameter EXTENDED_ARRAY_SIZE_1D = ARRAY_SIZE_1D + 2*EXTENSION_AMOUNT;
    input CLK;
    output reg ready;
    
    input [PRECISION-1:0] s_out_overwrite_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    input [PRECISION-1:0] a_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    input [PRECISION-1:0] b_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	//Here we want to create an array of zeros that we insert the overwrite arrays into the center of.
	//
	output [PRECISION-1:0] A_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    	wire [PRECISION-1:0] A_array_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	
	generate 
	genvar i1;
	genvar j1;
	for(i1 = 0; i1 < ARRAY_SIZE_1D; i1++)begin
		for(j1 = 0; j1<ARRAY_SIZE_1D; j1++)begin
			assign A_array[i1][j1] = A_array_wire[EXTENSION_AMOUNT+i1-1][EXTENSION_AMOUNT+j1-1];
		end
	end
	endgenerate

	output [PRECISION-1:0] B_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    	wire [PRECISION-1:0] B_array_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	
	generate 
	genvar i2;
	genvar j2;
	for(i2 = 0; i2 < ARRAY_SIZE_1D; i2++)begin
		for(j2 = 0; j2<ARRAY_SIZE_1D; j2++)begin
			assign B_array[i2][j2] = B_array_wire[EXTENSION_AMOUNT+i2-1][EXTENSION_AMOUNT+j2-1];
		end
	end
	endgenerate
	
    	output [OUTPUT_PRECISION-1:0] s_out_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	wire [OUTPUT_PRECISION-1:0] s_out_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	
	generate 
	genvar i3;
	genvar j3;
	for(i3 = 0; i3 < ARRAY_SIZE_1D; i3++)begin
		for(j3 = 0; j3<ARRAY_SIZE_1D; j3++)begin
			assign s_out_array[i3][j3] = s_out_wire[EXTENSION_AMOUNT+i3-1][EXTENSION_AMOUNT+j3-1];
		end
	end
	endgenerate
	
    //This module is going to combine together all of the subparts that have been created (message passer, pe, etc)
    wire  ready_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
    input image_to_shift;
    input [1:0] shift_direction;
    input [2:0] command_to_execute;
    input array_ack;

    wire [PRECISION-1:0] osu_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osd_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osl_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osr_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];

     genvar x;
     genvar y;
     generate
     for (x=0; x < EXTENDED_ARRAY_SIZE_1D; x=x+1)
     for (y=0; y < EXTENDED_ARRAY_SIZE_1D; y=y+1)
     if() begin



     begin: gen_code_label
         message_passer #(.PRECISION(PRECISION),.OUTPUT_PRECISION(OUTPUT_PRECISION)) mp (
         .CLK(CLK),
         .ready(ready_array[x][y]),
         .ack(array_ack),
         .A(A_array_wire[x][y][PRECISION-1:0]),
         .B(B_array_wire[x][y][PRECISION-1:0]),
         .s_out(s_out_wire[x][y][OUTPUT_PRECISION-1:0]),
         .isu(osr_array[x][y+1][PRECISION-1:0]),
         .osu(osu_array[x][y][PRECISION-1:0]),
         .isl(osr_array[x+1][y][PRECISION-1:0]),
         .osl(osl_array[x][y][PRECISION-1:0]),
         .isd(osr_array[x][y-1][PRECISION-1:0]),
         .osd(osd_array[x][y][PRECISION-1:0]),
         .isr(osr_array[x-1][y][PRECISION-1:0]),
         .osr(osr_array[x][y][PRECISION-1:0]),
         .image_to_shift(image_to_shift),
         .a_overwrite(a_overwrite[x][y][PRECISION-1:0]),
         .b_overwrite(b_overwrite[x][y][PRECISION-1:0]),
         .s_out_overwrite(s_out_overwrite_array[x][y][OUTPUT_PRECISION-1:0]),
         .command_to_execute(command_to_execute));
    end
    endgenerate

endmodule

