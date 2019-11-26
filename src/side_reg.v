`timescale 1ns/10ps

/*
Here we have a large shift register at the side of the array. It is to hold values that overflow from the array while we are shifting around data.
For the sake of simplicity I have implemented it by taking the message passer module and modifying it.
*/

module side_reg 
    # (parameter PRECISION = 8,
       parameter SIZE = 32) //Here size is the number of values that we can store inside of the register before we overflow
    (
        CLK,
        ready,
        ack,
        inp,
        oup,
        image_to_shift,
        shift_direction,
        command_to_execute);
    //CLK here is the CLK
    //reset is a chip wide reset. All registers should dump their data
    //s_out is the output product of the array
    //isu is input shift up. This input is where data that will be shifted from below comes from.
    //osu is output shift up. This is where data that we want to shift up goes. 
    //The ready signal is raised after either a multiply or a shift. It is set to zero when a new operation is raised (shift_left, shift_right, shift_up,shift_down, start_multiply rise)
    //shift_direction is a 2 bit signal which determines where we are on the array. We encode it as:
    //UP = 00, DOWN=01,LEFT=10,RIGHT=11
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
    input [1:0] shift_direction;
    input [2:0] command_to_execute;

    reg [PRECISION-1:0] reg_array [0:SIZE-1];
    integer si;
    initial begin
        for(si = 0; si < SIZE; si = si + 1) begin 
            reg_array[si] = 0;
        end
    end

    input [PRECISION-1:0] inp;
    
    output reg [PRECISION-1:0] oup = 0;

    input image_to_shift; //We are going to assume that we only ever shift one image relative to the other. Here we only shift A.

    integer i;
	always @(posedge CLK) begin
        if (ack) begin 
            ready <= 0;
        end
        else begin
            //On each clock cycle we check command_to_execute and use that in a case statement      
            if (command_to_execute == 3'b000) begin //000 - multiply
                //If they tell the side register to multiply nothing happens. We are ready.
                ready = 1;
            end
            //001 - shift_up
            else if (command_to_execute == 3'b001 && shift_direction == 2'b00 && image_to_shift == 0) begin  
                //Here we are shifting data up, and the config direction is up so we shift data into the register
                for(i=0; i < SIZE-2; i = i+1) begin 
                    reg_array[i+1][PRECISION-1:0] <= reg_array[i][PRECISION-1:0];
                end
                reg_array[0][PRECISION-1:0] <= inp;
                ready = 1;
            end
            else if (command_to_execute == 3'b001 && shift_direction == 2'b01 && image_to_shift == 0) begin  
                //Here we are shifting data up, and the config direction is down, so we move data out
                oup = reg_array[0][PRECISION-1:0];
                for(i=0; i < SIZE-1; i = i+1) begin 
                    reg_array[i][PRECISION-1:0] <= reg_array[i+1][PRECISION-1:0];
                end
                ready = 1;
            end
            else if (command_to_execute == 3'b001 && shift_direction == 2'b10 && image_to_shift == 0) begin  
                //Here we are shifting data up, and the config direction is left so do nothing
                ready = 1;
            end
            else if (command_to_execute == 3'b001 && shift_direction == 2'b11 && image_to_shift == 0) begin  
                //Here we are shifting data up, and the config direction is right so we do nothing
                ready = 1;
            end
            //010 - shift_down
            else if (command_to_execute == 3'b010 && shift_direction == 2'b00 && image_to_shift == 0) begin  
                //Here we are shifting data down, and the config direction is up so we move data out
                
                oup = reg_array[0][PRECISION-1:0];
                for(i=0; i < SIZE-1; i = i+1) begin 
                    reg_array[i][PRECISION-1:0] <= reg_array[i+1][PRECISION-1:0];
                end
                ready = 1;
            end
            else if (command_to_execute == 3'b010 && shift_direction == 2'b01 && image_to_shift == 0) begin  
                //Here we are shifting data down, and the config direction is down so we move data into the register
                for(i=0; i < SIZE-2; i = i+1) begin 
                    reg_array[i+1][PRECISION-1:0] <= reg_array[i][PRECISION-1:0];
                end
                reg_array[0][PRECISION-1:0] <= inp;
                ready = 1;
            end
            else if (command_to_execute == 3'b010 && shift_direction == 2'b10 && image_to_shift == 0) begin  
                //Here we are shifting data down, and the config direction is left so we do nothing
                ready = 1;
            end
            else if (command_to_execute == 3'b010 && shift_direction == 2'b11 && image_to_shift == 0) begin  
                //Here we are shifting data down, and the config direction is right so we do nothing
                ready = 1;
            end
            //011 - shift_left
            else if (command_to_execute == 3'b011 && shift_direction == 2'b00 && image_to_shift == 0) begin  
                //Here we are shifting data left, and the config direction is up so we shift data
                ready = 1;
            end
            else if (command_to_execute == 3'b011 && shift_direction == 2'b01 && image_to_shift == 0) begin  
                //Here we are shifting data left, and the config direction is down so we shift data
                ready = 1;
            end
            else if (command_to_execute == 3'b011 && shift_direction == 2'b10 && image_to_shift == 0) begin  
                //Here we are shifting data left, and the config direction is left so we move data into the register
                for(i=0; i < SIZE-2; i = i+1) begin 
                    reg_array[i+1][PRECISION-1:0] <= reg_array[i][PRECISION-1:0];
                end
                reg_array[0][PRECISION-1:0] <= inp;
                ready = 1;
            end
            else if (command_to_execute == 3'b011 && shift_direction == 2'b11 && image_to_shift == 0) begin  
                //Here we are shifting data left, and the config direction is right so we move data out
                oup = reg_array[0][PRECISION-1:0];
                for(i=0; i < SIZE-1; i = i+1) begin 
                    reg_array[i][PRECISION-1:0] <= reg_array[i+1][PRECISION-1:0];
                end
                ready = 1;
            end
            //100 - shift_right
            else if (command_to_execute == 3'b100 && shift_direction == 2'b00 && image_to_shift == 0) begin  
                //Here we are shifting data right, and the config direction is up so we do nothing
                ready = 1;
            end
            else if (command_to_execute == 3'b100 && shift_direction == 2'b01 && image_to_shift == 0) begin  
                //Here we are shifting data right, and the config direction is down so we do nothing
                ready = 1;
            end
            else if (command_to_execute == 3'b100 && shift_direction == 2'b10 && image_to_shift == 0) begin  
                //Here we are shifting data right, and the config direction is left so we move data out
                oup = reg_array[0][PRECISION-1:0];
                for(i=0; i < SIZE-1; i = i+1) begin 
                    reg_array[i][PRECISION-1:0] <= reg_array[i+1][PRECISION-1:0];
                end
                ready = 1;
            end
            else if (command_to_execute == 3'b100 && shift_direction == 2'b11 && image_to_shift == 0) begin  
                //Here we are shifting data right, and the config direction is right so we move data into the register
                for(i=0; i < SIZE-2; i = i+1) begin 
                    reg_array[i+1][PRECISION-1:0] <= reg_array[i][PRECISION-1:0];
                end
                reg_array[0][PRECISION-1:0] <= inp;
                ready = 1;
            end
                        
            else if (command_to_execute == 3'b101) begin //101 - Overwrite A and B values
                //If we are overwriting values in the array then we are going to flush the registers
                for(i=0; i < SIZE; i = i+1) begin 
                    reg_array[i] <= 0;
                end
                
                ready = 1;
            end
            else if (command_to_execute == 3'b110) begin //110 - Overwrite S_out values
                //If we are overwriting the partial sums for some reason then we don't do anything.
                ready = 1;
            end
            else if (command_to_execute == 3'b111) begin //111 - reset
                //If we send an array_wide reset signal then we reset the array
                for(i=0; i < SIZE; i = i+1) begin 
                    reg_array[i] <= 0;
                end
                ready = 1'b1;
            end
        end 
    end 
endmodule
