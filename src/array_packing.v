//Here we have some functions which allow us to pack and unpack data into arrays
//The reason why we want to do this is because verilog modules do not allow for 2D inputs 
//These functions will allow us to pack and unpack data into arrays

`define PACK_ARRAY_2D(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST)    genvar pk_idx;\
generate for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) begin;\
assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0];\
end; endgenerate

`define PACK_ARRAY_3D(PK_WIDTH,PK_LEN,PK_DEPTH,PK_SRC,PK_DEST)    genvar pk_idx; genvar pk_idy;\
generate for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) for (pk_idy=0; pk_idy<(PK_DEPTH); pk_idy=pk_idy+1) begin;\
assign PK_DEST[(PK_DEPTH*PK_WIDTH*pk_idy + (PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):(PK_DEPTH*PK_WIDTH*pk_idy + (PK_WIDTH)*pk_idx)] = PK_SRC[pk_idy][pk_idx][((PK_WIDTH)-1):0];\
end; endgenerate

`define UNPACK_ARRAY_2D(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)  genvar unpk_idx;\
generate for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin;\
assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)];\
end; endgenerate

`define UNPACK_ARRAY_3D(PK_WIDTH,PK_LEN,PK_DEPTH,PK_DEST,PK_SRC)  genvar unpk_idx; genvar unpk_idy;\
generate for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin; for (unpk_idy=0; unpk_idy<(PK_LEN); unpk_idy=unpk_idy+1) begin;\
assign PK_DEST[unpk_idy][unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[(PK_DEPTH*PK_WIDTH*unpk_idy +(PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):(PK_DEPTH*PK_WIDTH*unpk_idy +(PK_WIDTH)*unpk_idx)];\
end; end; endgenerate