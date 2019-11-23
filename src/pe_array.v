`timescale 1ns/10ps
`include "pe_message_passer.v"
`include "array_packing.v"

module pe_array 
    # (
        parameter ARRAY_SIZE_1D = 1,
        parameter long_shift_amount = 4,
        parameter PRECISION = 8,
        parameter OUTPUT_PRECISION = 32)
    (
        CLK,
        ready,
        array_ack,
        // A_array,
        // B_array,
        // s_out_array,
        // a_overwrite,
        // b_overwrite,
        // s_out_overwrite,
        shift_direction,
        image_to_shift,
        command_to_execute);

    input CLK;
    output reg ready;
    // output reg 
    
    // input [OUTPUT_PRECISION*ARRAY_SIZE_1D*ARRAY_SIZE_1D-1:0] s_out_overwrite;
    // wire [OUTPUT_PRECISION-1:0] unpacked_s_out_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    // `UNPACK_ARRAY_3D(ARRAY_SIZE_1D,ARRAY_SIZE_1D,OUTPUT_PRECISION,unpacked_s_out_overwrite,s_out_overwrite)
    // input [PRECISION-1:0] a_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    // input [PRECISION-1:0] b_overwrite [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0]; 
    wire [PRECISION-1:0] A_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] B_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [OUTPUT_PRECISION-1:0] s_out_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    //This module is going to combine together all of the subparts that have been created (message passer, pe, etc)
    wire  ready_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    input image_to_shift;
    input [1:0] shift_direction;
    input [2:0] command_to_execute;
    input array_ack;

    wire [PRECISION-1:0] osu_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osd_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osl_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];
    wire [PRECISION-1:0] osr_array [ARRAY_SIZE_1D-1:0][ARRAY_SIZE_1D-1:0];



    //Here we are going to create an array of message passers and wire them
    message_passer #(.PRECISION(PRECISION),.OUTPUT_PRECISION(OUTPUT_PRECISION)) mp (
        .CLK(CLK),
        .ready(ready_array[0][0]),
        .ack(array_ack),
        .A(A_array[0][0]),
        .B(B_array[0][0]),
        .s_out(s_out_array[0][0]),
        .isu(osu_array[0][0]),
        .osu(osu_array[0][0]),
        .isl(osl_array[0][0]),
        .osl(osl_array[0][0]),
        .isd(osd_array[0][0]),
        .osd(osd_array[0][0]),
        .isr(osr_array[0][0]),
        .osr(osr_array[0][0]),
        .image_to_shift(image_to_shift),
        .a_overwrite(a_overwrite[0][0]),
        .b_overwrite(b_overwrite[0][0]),
        .s_out_overwrite(s_out_overwrite[0][0]),
        .shift_direction(shift_direction),
        .command_to_execute(command_to_execute));


    // genvar x;
    // genvar y;
    // generate
    // for (x=0; x < ARRAY_SIZE_1D; x=x+1)
    // for (y=0; y < ARRAY_SIZE_1D; y=y+1)
    // begin: gen_code_label
    //     message_passer #(.PRECISION(PRECISION),.OUTPUT_PRECISION(OUTPUT_PRECISION)) mp (
    //     .CLK(CLK),
    //     .ready(),
    //     .ack(),
    //     .A(),
    //     .B(),
    //     .s_out(),
    //     .isu(),
    //     .osu(),
    //     .isl(),
    //     .osl(),
    //     isd,
    //     osd,
    //     isr,
    //     osr,
    //     image_to_shift,
    //     a_overwrite,
    //     b_overwrite,
    //     s_out_overwrite,
    //     shift_direction,
    //     command_to_execute);
    // end
    // endgenerate

	

endmodule

