`timescale 1ns/10ps

module processing_element 
    # (parameter PRECISION = 8,
       parameter NUM_IMAGES = 2,
       parameter OUTPUT_PRECISION = 32)
    (CLK, reset, s_out, start_multiply, ready, isu, osu, isl, osl, isd, osd, isr, osr, shift_left, shift_right, shift_up, shift_down, image_shifting,error);
    //CLK here is the CLK
    //reset is a chip wide reset. All registers should dump their data
    //s_out is the output product of the array
    //isu is input shift up. This input is where data that will be shifted from below comes from.
    //osu is output shift up. This is where data that we want to shift up goes. 
    //The ready signal is raised after either a multiply or a shift. It is set to zero when a new operation is raised (shift_left, shift_right, shift_up,shift_down, start_multiply rise)
    //shift_x means that we will shift data in the x direction.
    //image_shifting is the number of the image we are shifting. 
    //error is pulled high if there is ever an error

	input CLK, reset;
	input [PRECISION-1:0] a_in, b_in;
	input start_multiply;
	output reg [OUTPUT_PRECISION-1:0] s_out;
	output reg ready;

    reg [NUM_IMAGES*PRECISION-1:0] image_storage;
    reg [4:0] image_multiply_counter = 0; //Note, if we ever process more than 16 images in the test bench we will need to change this
    reg [PRECISION-1:0] temporary_shifting_reg;

	always @(posedge CLK) begin
		if (~reset) begin
			ready <= 1'b0;
		end
		else begin
            //Here we are going to check if we have to do message passing on this cycle
            always @(posedge shift_up) begin
                //Take the image at image_shifting and move it to the output. We have to be careful about blocking... move the input into a temp register and then shift 
                temporary_shifting_reg <= isu;
                osu <= image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION];
                image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION] <= temporary_shifting_reg;
            end
            always @(posedge shift_down) begin
                temporary_shifting_reg <= isd;
                osd <= image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION];
                image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION] <= temporary_shifting_reg;
            end
            always @(posedge shift_left) begin 
                temporary_shifting_reg <= isl;
                osl <= image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION];
                image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION] <= temporary_shifting_reg;
            end 
            always @(posedge shift_right) begin
                temporary_shifting_reg <= isr;
                osr <= image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION];
                image_storage[image_shifting*PRECISION + PRECISION - 1 : image_shifting*PRECISION] <= temporary_shifting_reg;
            end
            //Here we are going to check if we have to do an multiplication
            always @(posedge start_multiply) begin
                //Here we are being told to step through all images that we have and pairwise multiply them, adding them to the output register
                //Right now this is just configured for two images, will expand this later by adding something like a state machine
                s_out = s_out + {(OUTPUT_PRECISION-2*PRECISION){1'b0}, image_storage[2*PRECISION-1:PRECISION]*image_storage[PRECISION-1:0]};
                //Right now because we only are doing two images we just raise the ready signal immediately.
                ready = 1'b1;
            end
		end
	end

endmodule

