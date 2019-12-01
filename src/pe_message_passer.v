`timescale 1ns/10ps
`include "pe.v"

module message_passer 
    # (parameter PRECISION = 8,
       parameter OUTPUT_PRECISION = 32)
    (
        CLK,
        ready,
        ack,
        A,
        B,
        s_out,
        isu,
        osu,
        isl,
        osl,
        isd,
        osd,
        isr,
        osr,
        image_to_shift,
        a_overwrite,
        b_overwrite,
        s_out_overwrite,
        command_to_execute);
    //CLK here is the CLK
    //reset is a chip wide reset. All registers should dump their data
    //s_out is the output product of the array
    //isu is input shift up. This input is where data that will be shifted from below comes from.
    //osu is output shift up. This is where data that we want to shift up goes. 
    //The ready signal is raised after either a multiply or a shift. It is set to zero when a new operation is raised (shift_left, shift_right, shift_up,shift_down, start_multiply rise)
    //command_to_execute determines what we are going to do on this clock cycle. Here are the commands:
    //000 - multiply
    //001 - shift_up
    //010 - shift_down
    //011 - shift_left
    //100 - shift_right
    //101 - Overwrite A and B values
    //110 - Overwrite S_out values
    //111 - reset

	input CLK;
    output reg ready = 0;
    input ack;
    input [2:0] command_to_execute;

    output reg [PRECISION-1:0] A = 0;
    output reg [PRECISION-1:0] B = 0;
    output reg [OUTPUT_PRECISION-1:0] s_out = 0;

    input [PRECISION-1:0] isl;
    input [PRECISION-1:0] isu;
    input [PRECISION-1:0] isr;
    input [PRECISION-1:0] isd;
    
    output reg [PRECISION-1:0] osl = 0;
    output reg [PRECISION-1:0] osd = 0;
    output reg [PRECISION-1:0] osr = 0;
    output reg [PRECISION-1:0] osu = 0;

    input image_to_shift;

    input [PRECISION-1:0] a_overwrite;
    input [PRECISION-1:0] b_overwrite;
    input [OUTPUT_PRECISION-1:0] s_out_overwrite;

    reg start_multiply;
    wire [OUTPUT_PRECISION-1:0] returned_from_pe;
    wire pe_ready;
    reg pe_ack;
    //Here we instantiate an instance of a pe
    processing_element #(.PRECISION(PRECISION), .OUTPUT_PRECISION(OUTPUT_PRECISION)) pe_inst (.CLK(CLK),.s_in(s_out),.s_out(returned_from_pe),.a_in(A),.b_in(B),.start_multiply(start_multiply),.pe_ready(pe_ready),.pe_ack(pe_ack));

	always @(posedge CLK) begin
        if (ack) begin 
            ready <= 0;
        end
        else begin
            //On each clock cycle we check command_to_execute and use that in a case statement        
            if (command_to_execute == 3'b000) begin //000 - multiply
                pe_ack = 1;
                pe_ack <= 0;
                start_multiply <= 1'b1;
                wait (pe_ready == 1);
                s_out = returned_from_pe;
                start_multiply = 1'b0;
                ready = 1;
            end
            else if (command_to_execute == 3'b001) begin  //001 - shift_up
                if (image_to_shift == 0) begin
                    osu = A;
                    A = isu;
                    ready = 1;
                end
                else if (image_to_shift == 1) begin
                    osu = B;
                    B = isu;
                    ready = 1;
                end
            end
            else if (command_to_execute == 3'b010) begin //010 - shift_down
                if (image_to_shift == 0) begin
                    osd = A;
                    A = isd;
                    ready = 1;
                end
                else if (image_to_shift == 1) begin
                    osd = B;
                    B = isd;
                    ready = 1;
                end
            end
            else if (command_to_execute == 3'b011) begin //011 - shift_left
                if (image_to_shift == 0) begin
                    osl = A;
                    A = isl;
                    ready = 1;
                end
                else if (image_to_shift == 1) begin
                    osl = B;
                    B = isl;
                    ready = 1;
                end
            end
            else if (command_to_execute == 3'b100) begin //100 - shift_right
                if (image_to_shift == 0) begin
                    osr = A;
                    A = isr;
                    ready = 1;
                end
                else if (image_to_shift == 1) begin
                    osr = B;
                    B = isr;
                    ready = 1;
                end
            end
            else if (command_to_execute == 3'b101) begin //101 - Overwrite A and B values
                A = a_overwrite;
                B = b_overwrite;
                ready = 1;
            end
            else if (command_to_execute == 3'b110) begin //110 - Overwrite S_out values
                s_out = s_out_overwrite;
                ready = 1;
            end
            else if (command_to_execute == 3'b111) begin //111 - reset
                A = {PRECISION{1'b0}};
                B = {PRECISION{1'b0}};
                s_out = {OUTPUT_PRECISION{1'b0}};
                ready = 1'b1;
            end
        end 
    end 
endmodule