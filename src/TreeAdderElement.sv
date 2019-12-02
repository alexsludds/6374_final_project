
`timescale 1ns/10ps


/*
    The tree adder element is a 2x2 pixel square. These 4 pixels are summed in 1 clock cycle.
    
    The inputs to the pixel registers have a mux. The possible input sources are:
        1. The top level pixel grid.
        2. The output of some other summer in the TreeAdder.
            OR, if no previous summer is feeding this input, it instead takes a 0 as the input.
*/

module TreeAdderElement
    #(
        parameter ADDER_DATASIZE = 16,
        parameter CMD_WIDTH = 4
    )
    (
    clk, cmdinput,
    pixAA_top_mult_in, pixAB_top_mult_in, pixBA_top_mult_in, pixBB_top_mult_in,
    pixAA_top_shadowA_in, pixAB_top_shadowA_in, pixBA_top_shadowA_in, pixBB_top_shadowA_in,
    pixAA_top_shadowB_in, pixAB_top_shadowB_in, pixBA_top_shadowB_in, pixBB_top_shadowB_in,
    pixAA_sum_in, pixAB_sum_in, pixBA_sum_in, pixBB_sum_in,
    pixAA_out, pixAB_out, pixBA_out, pixBB_out,
    sumout
    );
    
    //parameter ADDER_DATASIZE = 16;
    //parameter CMD_WIDTH = 4;

    parameter cmdWidth=CMD_WIDTH;
    parameter pixBitwidth=ADDER_DATASIZE;
    parameter sumoutWidth=ADDER_DATASIZE;
    
    parameter CMD_TOPLOAD_SHADOW_A=9; //this causes the registers to load pixel values from shadow register A
    parameter CMD_TOPLOAD_SHADOW_B=10; //this causes the registers to load pixel values from shadow register B
    parameter CMD_SUMDECIMATE=11; //this causes the registers to load pixel values from the sum inputs
    parameter CMD_TOPLOAD_MULTIPLIER = 12; //load values from the output of the multiplier

    input clk;
    input [(cmdWidth-1):0] cmdinput;
    
    input [(pixBitwidth-1):0] pixAA_top_mult_in; // 1st row - multiplier inputs
    input [(pixBitwidth-1):0] pixAB_top_mult_in;
    input [(pixBitwidth-1):0] pixBA_top_mult_in; // 2nd row
    input [(pixBitwidth-1):0] pixBB_top_mult_in;
    
    input [(pixBitwidth-1):0] pixAA_top_shadowA_in; // 1st row - shadowA inputs
    input [(pixBitwidth-1):0] pixAB_top_shadowA_in;
    input [(pixBitwidth-1):0] pixBA_top_shadowA_in; // 2nd row
    input [(pixBitwidth-1):0] pixBB_top_shadowA_in;
    input [(pixBitwidth-1):0] pixAA_top_shadowB_in; // 1st row - shadowB inputs
    input [(pixBitwidth-1):0] pixAB_top_shadowB_in;
    input [(pixBitwidth-1):0] pixBA_top_shadowB_in; // 2nd row
    input [(pixBitwidth-1):0] pixBB_top_shadowB_in;
    input [(pixBitwidth-1):0] pixAA_sum_in; // 1st row - loopback summing inputs
    input [(pixBitwidth-1):0] pixAB_sum_in;
    input [(pixBitwidth-1):0] pixBA_sum_in; // 2nd row
    input [(pixBitwidth-1):0] pixBB_sum_in;
    
    output [(pixBitwidth-1):0] pixAA_out;
    output [(pixBitwidth-1):0] pixAB_out;
    output [(pixBitwidth-1):0] pixBA_out;
    output [(pixBitwidth-1):0] pixBB_out;
    output [(sumoutWidth-1):0] sumout; //output of the 4-pixel adder

    //REGs ########################################
    reg [(pixBitwidth-1):0] pixAA;
    reg [(pixBitwidth-1):0] pixAB;
    reg [(pixBitwidth-1):0] pixBA;
    reg [(pixBitwidth-1):0] pixBB;
    
    //REG inputs (wires) ########################################
    wire [(pixBitwidth-1):0] pixAA_in;
    wire [(pixBitwidth-1):0] pixAB_in;
    wire [(pixBitwidth-1):0] pixBA_in;
    wire [(pixBitwidth-1):0] pixBB_in;
    
    //Control signals (wires) ########################################

    //Output assignments ########################################
    assign pixAA_out = pixAA;
    assign pixAB_out = pixAB;
    assign pixBA_out = pixBA;
    assign pixBB_out = pixBB;
    assign sumout = pixAA + pixAB + pixBA + pixBB;
    
    // REG input assignments ############################################
    //inputs to the pixel registers are MUXed between: loading data from above, or loading data from an adder output in the same layer (decimation)
    assign pixAA_in = (cmdinput==CMD_SUMDECIMATE)? pixAA_sum_in : 
                      (cmdinput==CMD_TOPLOAD_SHADOW_A)? pixAA_top_shadowA_in :
                      (cmdinput==CMD_TOPLOAD_SHADOW_B)? pixAA_top_shadowB_in :
                      (cmdinput==CMD_TOPLOAD_MULTIPLIER)? pixAA_top_mult_in : pixAA;
    
    assign pixAB_in = (cmdinput==CMD_SUMDECIMATE)? pixAB_sum_in : 
                      (cmdinput==CMD_TOPLOAD_SHADOW_A)? pixAB_top_shadowA_in :
                      (cmdinput==CMD_TOPLOAD_SHADOW_B)? pixAB_top_shadowB_in :
                      (cmdinput==CMD_TOPLOAD_MULTIPLIER)? pixAB_top_mult_in : pixAB;
    
    assign pixBA_in = (cmdinput==CMD_SUMDECIMATE)? pixBA_sum_in : 
                      (cmdinput==CMD_TOPLOAD_SHADOW_A)? pixBA_top_shadowA_in :
                      (cmdinput==CMD_TOPLOAD_SHADOW_B)? pixBA_top_shadowB_in :
                      (cmdinput==CMD_TOPLOAD_MULTIPLIER)? pixBA_top_mult_in : pixBA;
    
    assign pixBB_in = (cmdinput==CMD_SUMDECIMATE)? pixBB_sum_in : 
                      (cmdinput==CMD_TOPLOAD_SHADOW_A)? pixBB_top_shadowA_in :
                      (cmdinput==CMD_TOPLOAD_SHADOW_B)? pixBB_top_shadowB_in :
                      (cmdinput==CMD_TOPLOAD_MULTIPLIER)? pixBB_top_mult_in : pixBB;
    
    // Sequential ALWAYS blocks ##########################################
    always @ (posedge clk) begin
        pixAA <= pixAA_in;
        pixAB <= pixAB_in;
        pixBA <= pixBA_in;
        pixBB <= pixBB_in;
    end
    
    
endmodule



/*
    The overall tree adder is NOT multi-level. Instead, it re-uses the same memory by looping the outputs of summers
    back into pixels inside the 1-level memory. This causes the summed values to get crunched progressively into
    the top left corner of the pixel grid over several clock cycles.
    
    The advantage of this is that it greatly reduces die area.
*/

/*
module TreeAdder(
    cmdinput, clk, 
    );

    input cmdinput;
    input clk;

*/
