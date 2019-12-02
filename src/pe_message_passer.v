`timescale 1ns/10ps

module message_passer 
    # (parameter PRECISION = 8,
       parameter OUTPUT_PRECISION = 32,
	parameter command_width = 4)
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
    input [command_width-1:0] command_to_execute;

    output reg [PRECISION-1:0] A = 0;
    output reg [PRECISION-1:0] B = 0;
    output reg [OUTPUT_PRECISION-1:0] s_out = 0;

    input [PRECISION-1:0] isl;
    input [PRECISION-1:0] isu;
    input [PRECISION-1:0] isr;
    input [PRECISION-1:0] isd;
    
    output wire [PRECISION-1:0] osl;
    output wire [PRECISION-1:0] osd;
    output wire [PRECISION-1:0] osr;
    output wire [PRECISION-1:0] osu;

    	assign osl = A;
   	assign osu = A;
	assign osd = A;
	assign osr = A;

    input [PRECISION-1:0] a_overwrite;
    input [PRECISION-1:0] b_overwrite;
    input [OUTPUT_PRECISION-1:0] s_out_overwrite;

    reg start_multiply;
    wire [OUTPUT_PRECISION-1:0] returned_from_pe;
    wire pe_ready;
    reg pe_ack;
	reg pe_reset = 0;
    //Here we instantiate an instance of a pe
    processing_element #(.PRECISION(PRECISION), .OUTPUT_PRECISION(OUTPUT_PRECISION)) pe_inst (.CLK(CLK),.reset(reset),.s_out(returned_from_pe),.a_in(A),.b_in(B),.start_multiply(start_multiply),.pe_ready(pe_ready),.pe_ack(pe_ack));

	always @(posedge CLK) begin
        if (ack) begin 
            ready <= 0;
        end
        else begin
            //On each clock cycle we check command_to_execute and use that in a case statement        
            if (command_to_execute == 0) begin //multiply
                pe_ack = 1;
		wait (pe_ready == 0);
                pe_ack = 0;
                start_multiply = 1'b1;
                wait (pe_ready == 1);
		s_out = returned_from_pe;
                start_multiply <= 1'b0;
                ready = 1;
            end
            else if (command_to_execute == 1) begin  //shift_up
		    A = isu;
		    ready = 1;
            end
            else if (command_to_execute == 2) begin //shift_down

                    A = isd;
                    ready = 1;

            end
            else if (command_to_execute == 3) begin //shift_left


                    A = isl;
                    ready = 1;

            end
            else if (command_to_execute == 4) begin //shift_right


                    A = isr;
                    ready = 1;

            end
            else if (command_to_execute == 5) begin //Overwrite A values
                A = a_overwrite;
                ready = 1;
            end
	    else if (command_to_execute == 6) begin //Overwrite B values
                B = b_overwrite;
                ready = 1;
            end
            else if (command_to_execute == 7) begin //Overwrite S_out values
                s_out = s_out_overwrite;
                ready = 1;
            end
            else if (command_to_execute == 8) begin //reset
		pe_reset = 1;
                A = {PRECISION{1'b0}};
                B = {PRECISION{1'b0}};
                s_out = {OUTPUT_PRECISION{1'b0}};
		pe_reset = 0;
                ready = 1'b1;
            end
        end 
    end 
endmodule
