`timescale 1ns/10ps

module ShadowReg
	# (
		parameter DATA_SIZE_BITS = 16,
		parameter IMG_SIDELENGTH = 64
	)
	(
		clk, loadEN, parallelIn, parallelOut
	);
	
	input clk;
	input loadEN;
	input [(DATA_SIZE_BITS-1):0] parallelIn [(IMG_SIDELENGTH-1):0] [(IMG_SIDELENGTH-1):0];
	output [(DATA_SIZE_BITS-1):0] parallelOut [(IMG_SIDELENGTH-1):0] [(IMG_SIDELENGTH-1):0];
	
	reg [(DATA_SIZE_BITS-1):0] shadowreg [(IMG_SIDELENGTH-1):0] [(IMG_SIDELENGTH-1):0];
	
	wire [(DATA_SIZE_BITS-1):0] shadowreg_in [(IMG_SIDELENGTH-1):0] [(IMG_SIDELENGTH-1):0];
	
	//assign shadowreg_in = (loadEN==1) ? parallelIn:shadowreg;
	//this generate block implements the above line
	genvar x,y;
	generate
	 for (y=0; y<IMG_SIDELENGTH; y=y+1) begin: yloop
	   for (x=0; x<IMG_SIDELENGTH; x=x+1) begin: xloop
	     assign shadowreg_in[x][y] = (loadEN==1) ? parallelIn[x][y]:shadowreg[x][y];
	   end
	 end
	endgenerate
	
	assign parallelOut = shadowreg;
	
	always @ (posedge clk) begin
		//shadowreg <= shadowreg_in;
		for (int yi=0; yi<IMG_SIDELENGTH; yi=yi+1) begin: yiloop
			for (int xi=0; xi<IMG_SIDELENGTH; xi=xi+1) begin: xiloop
				shadowreg[xi][yi] <= shadowreg_in[xi][yi];
			end
		end
	end
	
endmodule