`timescale 1ns/10ps


module pe_array 
    # (
        parameter ARRAY_SIZE_1D = 1,
	parameter EXTENSION_AMOUNT = 4,
        parameter command_width = 4,
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
        s_out_overwrite,
        shift_direction,
        command_to_execute);
	
	parameter EXTENDED_ARRAY_SIZE_1D = ARRAY_SIZE_1D + 2*EXTENSION_AMOUNT;
    input CLK;
    output reg ready;
    
    input [OUTPUT_PRECISION-1:0] s_out_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    input [PRECISION-1:0] a_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    input [PRECISION-1:0] b_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	//Here we are going to take the overwrite array inputs and convert them into the correct size
	wire [OUTPUT_PRECISION-1:0] s_out_overwrite_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	wire [PRECISION-1:0] a_overwrite_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	wire [PRECISION-1:0] b_overwrite_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	
	// generate 
	// genvar i0;
	// genvar j0;
	// for(i0 = 0; i0 < ARRAY_SIZE_1D; i0++)begin
	// 	for(j0 = 0; j0<ARRAY_SIZE_1D; j0++)begin
	// 		assign s_out_overwrite_wire[EXTENSION_AMOUNT+i0-1][EXTENSION_AMOUNT+j0-1] = s_out_overwrite[i0][j0];
	// 		assign a_overwrite_wire[EXTENSION_AMOUNT+i0-1][EXTENSION_AMOUNT+j0-1] = a_overwrite[i0][j0];
	// 		assign b_overwrite_wire[EXTENSION_AMOUNT+i0-1][EXTENSION_AMOUNT+j0-1] = b_overwrite[i0][j0];
	// 	end
	// end
	// endgenerate	

    generate 
	genvar il;
	genvar jl;
	for(il = 0; il < EXTENDED_ARRAY_SIZE_1D; il++)begin
		for(jl = 0; jl<EXTENDED_ARRAY_SIZE_1D; jl++)begin
            if (~(il >= EXTENSION_AMOUNT && il < ARRAY_SIZE_1D + EXTENSION_AMOUNT && jl >= EXTENSION_AMOUNT && jl < ARRAY_SIZE_1D + EXTENSION_AMOUNT)) begin
                assign s_out_overwrite_wire[il][jl] = 0;
                assign a_overwrite_wire[il][jl] = 0;
                assign b_overwrite_wire[il][jl] = 0;
            end
            else begin
                assign s_out_overwrite_wire[il][jl] = s_out_overwrite[il-EXTENSION_AMOUNT][jl-EXTENSION_AMOUNT];
                assign a_overwrite_wire[il][jl] = a_overwrite[il-EXTENSION_AMOUNT][jl-EXTENSION_AMOUNT];
                assign b_overwrite_wire[il][jl] = b_overwrite[il-EXTENSION_AMOUNT][jl-EXTENSION_AMOUNT];
            end
		end
	end
	endgenerate


	output [PRECISION-1:0] A_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] A_array_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	output [PRECISION-1:0] B_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] B_array_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	output [OUTPUT_PRECISION-1:0] s_out_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
	wire [OUTPUT_PRECISION-1:0] s_out_wire [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	
	generate 
	genvar i1;
	genvar j1;
	for(i1 = 0; i1 < ARRAY_SIZE_1D; i1++)begin
		for(j1 = 0; j1<ARRAY_SIZE_1D; j1++)begin
			assign A_array[i1][j1] = A_array_wire[EXTENSION_AMOUNT+i1-1][EXTENSION_AMOUNT+j1-1];
			assign B_array[i1][j1] = B_array_wire[EXTENSION_AMOUNT+i1-1][EXTENSION_AMOUNT+j1-1];
			assign s_out_array[i1][j1] = s_out_wire[EXTENSION_AMOUNT+i1-1][EXTENSION_AMOUNT+j1-1];
		end
	end
	endgenerate
	
    //This module is going to combine together all of the subparts that have been created (message passer, pe, etc)
    wire  ready_array [EXTENDED_ARRAY_SIZE_1D-1:0][EXTENDED_ARRAY_SIZE_1D-1:0];
	//Here we make ready the and of all of the ready values in the ready array
	assign ready = ready_array[1][1];
    input [1:0] shift_direction;
    input [command_width-1:0] command_to_execute;
    input array_ack;

    wire [PRECISION-1:0] osu_array [EXTENDED_ARRAY_SIZE_1D-1+2:0][EXTENDED_ARRAY_SIZE_1D-1+2:0];
    wire [PRECISION-1:0] osd_array [EXTENDED_ARRAY_SIZE_1D-1+2:0][EXTENDED_ARRAY_SIZE_1D-1+2:0];
    wire [PRECISION-1:0] osl_array [EXTENDED_ARRAY_SIZE_1D-1+2:0][EXTENDED_ARRAY_SIZE_1D-1+2:0];
    wire [PRECISION-1:0] osr_array [EXTENDED_ARRAY_SIZE_1D-1+2:0][EXTENDED_ARRAY_SIZE_1D-1+2:0];

     genvar x;
     genvar y;
     generate
     for (x=0; x < EXTENDED_ARRAY_SIZE_1D; x=x+1) begin
     for (y=0; y < EXTENDED_ARRAY_SIZE_1D; y=y+1)

     begin: gen_code_label
         message_passer #(.PRECISION(PRECISION),.OUTPUT_PRECISION(OUTPUT_PRECISION)) mp (
         .CLK(CLK),
         .ready(ready_array[x][y]),
         .ack(array_ack),
         .A(A_array_wire[x][y][PRECISION-1:0]),
         .B(B_array_wire[x][y][PRECISION-1:0]),
         .s_out(s_out_wire[x][y][OUTPUT_PRECISION-1:0]),
         .isu(osu_array[x+1][y+1+1][PRECISION-1:0]),
         .osu(osu_array[x+1][y+1][PRECISION-1:0]),
         .isl(osl_array[x+1+1][y+1][PRECISION-1:0]),
         .osl(osl_array[x+1][y+1][PRECISION-1:0]),
         .isd(osd_array[x+1][y-1+1][PRECISION-1:0]),
         .osd(osd_array[x+1][y+1][PRECISION-1:0]),
         .isr(osr_array[x-1+1][y+1][PRECISION-1:0]),
         .osr(osr_array[x+1][y+1][PRECISION-1:0]),
         .a_overwrite(a_overwrite_wire[x][y][PRECISION-1:0]),
         .b_overwrite(b_overwrite_wire[x][y][PRECISION-1:0]),
         .s_out_overwrite(s_out_overwrite_wire[x][y][OUTPUT_PRECISION-1:0]),
         .command_to_execute(command_to_execute));
        end
    end
    endgenerate

endmodule

