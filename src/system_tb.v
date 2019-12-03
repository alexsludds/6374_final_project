
/*
Quick Overview:

In this file, we load imgA and imgB into 2D register arrays (i.e. pixel arrays). The data is loaded from .csv files.

You should only need to touch the parameters marked "USER PARAMETERS".

The outputs of the loading process - the 2D img register arrays - are called:
CSV_equivalent_A
CSV_equivalent_B

*/



`timescale 1ns/10ps

module system_tb();
    
      parameter DEBUG = 1;
    parameter CLKHALFPERIOD = 1ns;
    parameter NDEC_MAX = 3;
    parameter DECIMATION_SPAM = 16;
    reg [64-1:0] coords [2:0][8:0];
    reg [64-1:0] argmax_X;
    reg [64-1:0] argmax_Y;
    reg [64-1:0] argmax_Val;
  
      // ==================================== PARAMS/VARIABLES ARE INVOLVED WITH DATA IMPORTING - BEGIN =========
      // ==== USER PARAMETERS - BEGIN
      parameter INPUTFILENAME_A = "../../src/img2d_A_2.csv";
      parameter INPUTFILENAME_B = "../../src/img2d_B_2.csv";
    parameter IMGSIDELENGTH = 64; //this should be the actual img side length in pixels
    parameter CELL_DATASIZE = 64; //max data size in the CSV cell
    parameter ADDER_DATASIZE = 64; //data bitwidth in the tree adder
    parameter EXTENSION_AMOUNT = 4;
      // ==== USER PARAMETERS - END
      
      // Limits for preventing infinite loops
      parameter IMGSIDELENGTHMAX = 256; //max side length of img in CSV (prevents infinite loops)
      parameter FILE_ENTRIES_MAX=IMGSIDELENGTHMAX**2; //total number of csv cells
      
      reg [60*8:0] fileNameString_A; //holds the filename for the input file, allows iteration
      reg [60*8:0] fileNameString_B; //holds the filename for the input file, allows iteration
      integer data_file;
      integer scan_file;
      integer csvEntryCounter; //tracks number of cells read from the CSV file
      integer csvEntrySideLength; //gives the side length of a presumably square 2D array
      integer csvValSum; //sum of the values in the CSV
      reg [(CELL_DATASIZE-1):0] captured_data;
      reg [(CELL_DATASIZE-1):0] captured_data_list [FILE_ENTRIES_MAX:0]; //stores csv as 1D list
      
      // for-loop iterator variables
      integer n;
      integer x;
      integer y;
      
      // ==== These registers are where the 2D CSV contents end up ====
      reg [(CELL_DATASIZE-1):0] CSV_equivalent_A [IMGSIDELENGTH-1 : 0] [IMGSIDELENGTH-1 : 0] ;
      reg [(CELL_DATASIZE-1):0] CSV_equivalent_B [IMGSIDELENGTH-1 : 0] [IMGSIDELENGTH-1 : 0] ;
      // 1D equivalents of the above
      reg [((CELL_DATASIZE * (IMGSIDELENGTH**2))-1):0] CSV_equivalent_A_1D; //2D unrolled to 1D
      reg [((CELL_DATASIZE * (IMGSIDELENGTH**2))-1):0] CSV_equivalent_B_1D;
      //[((DATA_SIZE_BITS * (IMG_SIDELENGTH**2))-1):0]
      
      // ==================================== PARAMS/VARIABLES ARE INVOLVED WITH DATA IMPORTING - END =========
      
      // ======= SYSTEM-WIDE - begin ========
      reg sys_clk;
    reg [10:0] random_counter = 0;
      reg loadEN; //should probably replace this with a command code from the controller
      parameter CMD_WIDTH = 4; //width of a cmd word
      reg [(CMD_WIDTH-1):0] cmdword;
      wire [(CELL_DATASIZE-1):0] shadowreg_A_parallelOut [(IMGSIDELENGTH-1):0] [(IMGSIDELENGTH-1):0];
      wire [(CELL_DATASIZE-1):0] shadowreg_B_parallelOut [(IMGSIDELENGTH-1):0] [(IMGSIDELENGTH-1):0];
      wire [(CELL_DATASIZE-1):0] treeadder_parallel_out [(IMGSIDELENGTH-1):0] [(IMGSIDELENGTH-1):0];
      wire [(CELL_DATASIZE-1):0] multiplier_out [(IMGSIDELENGTH-1):0] [(IMGSIDELENGTH-1):0];
      
      // ======= COMMANDS - begin ===========
    parameter CMD_MULTIPLIER = 0;
    parameter CMD_SHIFT_UP = 1;
    parameter CMD_SHIFT_DOWN = 2;
    parameter CMD_SHIFT_LEFT = 3;
    parameter CMD_SHIFT_RIGHT = 4;
    parameter CMD_A_OVERWRITE = 5;
    parameter CMD_B_OVERWRITE = 6;
    parameter CMD_S_OUT_OVERWRITE = 7;
    parameter CMD_RESET = 8;
      parameter CMD_TOPLOAD_SHADOW_A=9; //this causes the registers to load pixel values from shadow register A
      parameter CMD_TOPLOAD_SHADOW_B=10; //this causes the registers to load pixel values from shadow register B
      parameter CMD_SUMDECIMATE = 11; //this causes the registers to load pixel values from the sum inputs
      parameter CMD_TOPLOAD_MULTIPLIER = 12;
      parameter CMD_DONOTHING = 15;
      //wire [((CELL_DATASIZE * (IMGSIDELENGTH**2))-1):0] shadowreg_A_parallelOut_1D; //implements the above 2D array in 1D unrolled format
      //wire [((CELL_DATASIZE * (IMGSIDELENGTH**2))-1):0] shadowreg_B_parallelOut_1D; //implements the above 2D array in 1D unrolled format
      // ======= SYSTEM-WIDE - end ========
    
    // this function causes the TreeAdder to fully decimate its contents into 1 bin ([0][0])
      
      // ==================================== MODULE INSTANTIATIONS - BEGIN ====================================
      
      // ======= SHADOW REGISTERS - begin ========
      ShadowReg #(.DATA_SIZE_BITS(CELL_DATASIZE), .IMG_SIDELENGTH(IMGSIDELENGTH)) shadowreg_A(
        .clk(sys_clk),
        .loadEN(loadEN),
        .parallelIn(CSV_equivalent_A),
        .parallelOut(shadowreg_A_parallelOut)
      );
      
      ShadowReg #(.DATA_SIZE_BITS(CELL_DATASIZE), .IMG_SIDELENGTH(IMGSIDELENGTH)) shadowreg_B(
        .clk(sys_clk),
        .loadEN(loadEN),
        .parallelIn(CSV_equivalent_B),
        .parallelOut(shadowreg_B_parallelOut)
      );
      // ======= SHADOW REGISTERS - end ========
      
      // ======= TREEADDER - begin =============
      
      TreeAdder #(.IMGSIDELENGTH(IMGSIDELENGTH), .ADDER_DATASIZE(ADDER_DATASIZE), .CMD_WIDTH(CMD_WIDTH)) treeadder_01(
        .clk(sys_clk), 
        .cmdinput(cmdword),
        .adder_top_mult_in(multiplier_out),
        .adder_top_shadowA_in(shadowreg_A_parallelOut),
        .adder_top_shadowB_in(shadowreg_B_parallelOut),
        .adder_pix_out(treeadder_parallel_out)
      );
      // ======= TREEADDER - end ===============
    //============= PE_ARRAY - begin  ==================
    reg ready;
    wire [CELL_DATASIZE-1:0] A_array [IMGSIDELENGTH-1:0][IMGSIDELENGTH-1:0];
    wire [CELL_DATASIZE-1:0] B_array [IMGSIDELENGTH-1:0][IMGSIDELENGTH-1:0];
    reg ack;
    
      pe_array # (
        .ARRAY_SIZE_1D(IMGSIDELENGTH),
        .EXTENSION_AMOUNT(EXTENSION_AMOUNT),
        .command_width(CMD_WIDTH),
        .PRECISION(CELL_DATASIZE),
        .OUTPUT_PRECISION(CELL_DATASIZE)) pe_DUT  
    (
        .CLK(sys_clk),
        .ready(ready),
        .array_ack(ack),
        .A_array(A_array),
        .B_array(B_array),
        .s_out_array(multiplier_out),
        .a_overwrite(treeadder_parallel_out),
        .b_overwrite(treeadder_parallel_out),
        .s_out_overwrite(treeadder_parallel_out),
        .command_to_execute(cmdword));
      //===========PE_ARRAY - end =============
      
      // ==================================== MODULE INSTANTIATIONS - END =======================================
    
    initial begin
        
        // =========================================== CSV LOADING PROCESS - BEGIN ===========================
        // Load IMG_A file
        fileNameString_A = INPUTFILENAME_A;
        csvEntryCounter = 0;
        data_file = $fopen(fileNameString_A, "r");
        
        // parse the CSV and load it into a 1D list
        for (n=0; n<FILE_ENTRIES_MAX; n=n+1) begin
          if(!$feof(data_file)) begin
            csvEntryCounter = csvEntryCounter + 1;
            scan_file = $fscanf(data_file, "%d,", captured_data);
            captured_data_list[n] = captured_data;
          end
        end
        
        //after the CSV has been read, the dimensionality of the array is determined
        csvEntryCounter = csvEntryCounter - 1; //last value in the CSV is read twice, so chop the last value off
        csvEntrySideLength = $sqrt(csvEntryCounter);
        
        csvValSum = 0;
        for (n=0; n<csvEntryCounter; n=n+1) begin
          csvValSum = csvValSum + captured_data_list[n];
        end
        
        //format the data into both 1D and 2D formats
        for (y=0; y<IMGSIDELENGTH; y=y+1) begin : yloop_A
          for (x=0; x<IMGSIDELENGTH; x=x+1) begin : xloop_A
            CSV_equivalent_A[x][y] = captured_data_list[y*IMGSIDELENGTH + x]; //2D formatted
            // lowBit = ((y*IMGSIDELENGTH + x) * CELL_DATASIZE);
            // highBit = (((y*IMGSIDELENGTH + x + 1) * CELL_DATASIZE) - 1);
            // expression = lowbit +: CELL_DATASIZE
            CSV_equivalent_A_1D[((y*IMGSIDELENGTH + x) * CELL_DATASIZE) +: CELL_DATASIZE] = captured_data_list[y*IMGSIDELENGTH + x]; //1D formatted
          end
        end
        
        if (DEBUG) begin
            $display("============================================");
            $display("==== Opened file: %s", fileNameString_A);
            $display("CSV file parsed, entries found = %d", csvEntryCounter);
            $display("Assuming square array shape, sidelength = %d", csvEntrySideLength);
            $display("Sum of all values in the CSV = %d", csvValSum);
            $display("Some sample values in the register-based CSV equivalent array (X,Y - origin topleft): ");
            $display("(0,0) %d", CSV_equivalent_A[0][0]);
            $display("(1,1) %d", CSV_equivalent_A[1][1]);
            $display("(2,2) %d", CSV_equivalent_A[2][2]);
            $display("(3,3) %d", CSV_equivalent_A[3][3]);
        end
        // =========================================== CSV LOADING PROCESS - END ===========================
        
        
        
        // =========================================== CSV LOADING PROCESS - BEGIN ===========================
        // Load IMG_B file
        fileNameString_B = INPUTFILENAME_B;
        csvEntryCounter = 0;
        data_file = $fopen(fileNameString_B, "r");
        
        // parse the CSV and load it into a 1D list
        for (n=0; n<FILE_ENTRIES_MAX; n=n+1) begin
          if(!$feof(data_file)) begin
            csvEntryCounter = csvEntryCounter + 1;
            scan_file = $fscanf(data_file, "%d,", captured_data);
            captured_data_list[n] = captured_data;
          end
        end
        
        //after the CSV has been read, the dimensionality of the array is determined
        csvEntryCounter = csvEntryCounter - 1; //last value in the CSV is read twice, so chop the last value off
        csvEntrySideLength = $sqrt(csvEntryCounter);
        
        csvValSum = 0;
        for (n=0; n<csvEntryCounter; n=n+1) begin
          csvValSum = csvValSum + captured_data_list[n];
        end
        
        for (y=0; y<IMGSIDELENGTH; y=y+1) begin : yloop_B
          for (x=0; x<IMGSIDELENGTH; x=x+1) begin : xloop_B
            CSV_equivalent_B[x][y] = captured_data_list[y*IMGSIDELENGTH + x];
            CSV_equivalent_B_1D[((y*IMGSIDELENGTH + x) * CELL_DATASIZE) +: CELL_DATASIZE] = captured_data_list[y*IMGSIDELENGTH + x];
          end
        end
        
        if (DEBUG) begin
            $display("============================================");
            $display("==== Opened file: %s", fileNameString_B);
            $display("CSV file parsed, entries found = %d", csvEntryCounter);
            $display("Assuming square array shape, sidelength = %d", csvEntrySideLength);
            $display("Sum of all values in the CSV = %d", csvValSum);
            $display("Some sample values in the register-based CSV equivalent array (X,Y - origin topleft): ");
            $display("(0,0) %d", CSV_equivalent_B[0][0]);
            $display("(1,1) %d", CSV_equivalent_B[1][1]);
            $display("(2,2) %d", CSV_equivalent_B[2][2]);
            $display("(3,3) %d", CSV_equivalent_B[3][3]);
        end
        // =========================================== CSV LOADING PROCESS - END ===========================
    //generate the coordinates of the search
        //(0,0)
        coords[0][0] = 0; // x val
        coords[1][0] = 0; // y val]
        //(1,0)
        coords[0][1] = 1; // x val
        coords[1][1] = 0; // y val
        //(1,1)
        coords[0][2] = 1; // x val
        coords[1][2] = 1; // y val
        //(0,1)
        coords[0][3] = 0; // x val
        coords[1][3] = 1; // y val
        //(-1,1)
        coords[0][4] = -1; // x val
        coords[1][4] = 1; // y val
        //(-1,0)
        coords[0][5] = -1; // x val
        coords[1][5] = 0; // y val
        //(-1,-1)
        coords[0][6] = -1; // x val
        coords[1][6] = -1; // y val
        //(0,-1)
        coords[0][7] = 0; // x val
        coords[1][7] = -1; // y val
        //(1,-1)
        coords[0][8] = 1; // x val
        coords[1][8] = -1; // y val
        
        ack = 1;
        //We want to reset at the start of the testbench to make sure all pe's are zero
        while (ready != 0) begin
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
        end
    
        cmdword <= CMD_RESET;
        ack <= 0;
        while (ready != 1) begin
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
        end
        cmdword = CMD_DONOTHING;
        #CLKHALFPERIOD
        sys_clk = 0;
        #CLKHALFPERIOD
        sys_clk = 1;
        #CLKHALFPERIOD
        sys_clk = 0;


        $display("Stopping point: (%d)",1);
        //clk occurs on rising edge
        //change control values right after clk=1

        // ================ copy CSVs into shadow registers
        sys_clk = 1;
        loadEN = 1; //load csv into both shadowregs
        #CLKHALFPERIOD
        sys_clk = 0;
        
        $display("Stopping point: (%d)",2);
        
        // 1.
        //==============================UPLOAD TO PE_A
        // ========== copy shadowA into treeadder
        #CLKHALFPERIOD
        sys_clk = 1;
        loadEN = 0;
        cmdword = CMD_TOPLOAD_SHADOW_A; //load contents of shadowA into treeadder
        #CLKHALFPERIOD
        sys_clk = 0;
        // =========== decimate treeadder by NDEC_MAX
        #CLKHALFPERIOD //treeadder now has shadowA
        sys_clk = 1;
        #CLKHALFPERIOD
        sys_clk = 0;
        
        // ================================================================================= TREEADDER LOADED SUCCESSFULLY
        // $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        // $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        // $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        // $display("TreeAdder contents (63,63) = %p", treeadder_parallel_out);


        // for (int cntr = 0; cntr<NDEC_MAX; cntr = cntr+1) begin
        //     cmdword = CMD_SUMDECIMATE;
        //     #CLKHALFPERIOD
        //     sys_clk = 0;
        //     #CLKHALFPERIOD
        //     sys_clk = 1;
        // end
        #CLKHALFPERIOD
        sys_clk = 0;
        cmdword = CMD_DONOTHING;
        
        // ================================================================================= TREEADDER DECIMATED SUCCESSFULLY        
        $display("Stopping point: (%d)",3);
        // =========== copy image in TreeAdder into PE_A
        //cmdword = ~~~~~~~~~~~PE_A load command ~~~~~~~~~~~~;
        ack = 1;
        cmdword = CMD_A_OVERWRITE;
        //wait(ready == 0)
        while (ready != 0) begin
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
        end
        #CLKHALFPERIOD
        sys_clk = 0;
        //cmdword <= CMD_A_OVERWRITE;

        ack <= 0;
        //wait(ready == 1)
        while (ready != 1) begin
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
        end
        #CLKHALFPERIOD
        sys_clk = 0;
        #CLKHALFPERIOD
        sys_clk = 0;
        #CLKHALFPERIOD
        sys_clk = 1;
        #CLKHALFPERIOD
        sys_clk = 0;
        #CLKHALFPERIOD
        sys_clk = 1;        
        
        #CLKHALFPERIOD
        sys_clk = 1;
        
        $display("Stopping point: (%d)",4);
        
        // 2.
        //==============================UPLOAD TO PE_B
        // ========== copy shadowB into treeadder
        #CLKHALFPERIOD
        sys_clk = 1;
        loadEN = 0;
        cmdword = CMD_TOPLOAD_SHADOW_B; //load contents of shadowA into treeadder
        #CLKHALFPERIOD
        sys_clk = 0;
        // =========== decimate treeadder by NDEC_MAX
        #CLKHALFPERIOD //treeadder now has shadowB
        sys_clk = 1;
        // for (int cntr = 0; cntr<NDEC_MAX; cntr = cntr+1) begin
        //     cmdword = CMD_SUMDECIMATE;
        //     #CLKHALFPERIOD
        //     sys_clk = 0;
        //     #CLKHALFPERIOD
        //     sys_clk = 1;
        // end
        cmdword = CMD_DONOTHING;
        $display("Stopping point: (%d)",5);
        // =========== copy image in TreeAdder into PE_B
        //cmdword = ~~~~~~~~~~~PE_B load command ~~~~~~~~~~~~;
        ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_B_OVERWRITE;
            
            ack <= 0;
            while (ready != 1) begin
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
        end
        #CLKHALFPERIOD
        sys_clk = 0;
        #CLKHALFPERIOD
        sys_clk = 1;
        
        $display("Stopping point: (%d)",6);
        
        //get the correlation values for the different offset positions
        for (int square3Counter = 0; square3Counter<9; square3Counter = square3Counter+1) begin
        case (square3Counter)
            0:begin
            $display("Stopping point: (%d)",7);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;
        
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            cmdword = CMD_SUMDECIMATE;
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];

            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);

                //cmdword = RIGHTSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword <= CMD_SHIFT_RIGHT;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            1:begin
            $display("Stopping point: (%d)",8);

            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
         
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;
            

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                 #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);

                //cmdword = UPSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_UP;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            2:begin
            $display("Stopping point: (%d)",9);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = LEFTSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_SHIFT_LEFT;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end         
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            3:begin
            $display("Stopping point: (%d)",10);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = LEFTSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_LEFT;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            4:begin
            $display("Stopping point: (%d)",11);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = DOWNSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_DOWN;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_DONOTHING;
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            end
            5:begin
            $display("Stopping point: (%d)",12);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;
        

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = DOWNSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_DOWN;
            
            ack <= 0;
                while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_DONOTHING;
            #CLKHALFPERIOD
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            end
            6:begin
            $display("Stopping point: (%d)",13);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;

            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = RIGHTSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_RIGHT;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            7:begin
            $display("Stopping point: (%d)",14);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;
        
            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
                //cmdword = RIGHTSHIFT;
            ack = 1;
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            cmdword = CMD_SHIFT_RIGHT;
            
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
                cmdword = CMD_DONOTHING;
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
            8:begin
            $display("Stopping point: (%d)",15);
            ack = 1;
            //Trying to delay the function without using wait...
            while (ready != 0) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            cmdword = CMD_MULTIPLIER;
            ack <= 0;
            while (ready != 1) begin
                #CLKHALFPERIOD
                sys_clk = 0;
                #CLKHALFPERIOD
                sys_clk = 1;
            end
        
            // - copy multiply output to Treeadder
            cmdword = CMD_TOPLOAD_MULTIPLIER;
            #CLKHALFPERIOD  
            sys_clk = 0;
            #CLKHALFPERIOD
            sys_clk = 1;
            #CLKHALFPERIOD
            sys_clk = 0;
        
            cmdword = CMD_SUMDECIMATE;
            // decimate to 1 bin (i.e. just spam the clock for a bit)
            for (int cntr = 0; cntr<DECIMATION_SPAM; cntr = cntr+1) begin
                
                #CLKHALFPERIOD
                sys_clk = 1;
                #CLKHALFPERIOD
                sys_clk = 0;
            end
            cmdword = CMD_DONOTHING;
            coords[2][square3Counter] = treeadder_parallel_out[0][0];
            $display("Here multiply happens (%p)",treeadder_parallel_out[0][0]);
            end
            
        endcase
        end
        $display("Stopping point: (%d)",16);
        //now get the argmax (the coordinates with the highest correlation val)
        argmax_Val = 0;
        $display("contents of coords (%p)",coords[2]);
        for (int count = 0; count<9; count=count+1) begin
            if (coords[2][count] > argmax_Val) begin
                argmax_Val = coords[2][count];
                argmax_X = coords[0][count];
                argmax_Y = coords[1][count];
            end
        end
        // now we have the coordinates of the argmax!
        $display("Argmax val: (%d)",argmax_Val);
        $display("Argmax x,y is (%d),(%d):",argmax_X,argmax_Y);

        
        
        // ============================================ ACTUAL CLOCKED "initial begin" - BEGIN ===============
        /*
        #1
        sys_clk = 0;
        loadEN = 1;
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        loadEN = 0;
        // Shadow reg is now loaded (verified)
        $display("Shadow A contents (0,0) = %d", shadowreg_A_parallelOut[0][0]);
        $display("Shadow A contents (1,1) = %d", shadowreg_A_parallelOut[1][1]);
        
        cmdword = CMD_TOPLOAD_SHADOW_B; //load contents of shadowA into treeadder
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        cmdword = CMD_SUMDECIMATE;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        
        #1
        sys_clk = 1;
        #1
        sys_clk = 0;
        $display("TreeAdder contents (0,0) = %d", treeadder_parallel_out[0][0]);
        $display("TreeAdder contents (1,1) = %d", treeadder_parallel_out[1][1]);
        $display("TreeAdder contents (63,63) = %d", treeadder_parallel_out[63][63]);
        */
        // ============================================ ACTUAL CLOCKED "initial begin" - END ==================
    
    //=================================Running decimation simulatiobegin========================        

    // this array will store the offset coords in [1:0]
    // and the corresponding correlation scores in [2]
    //=================================Running decimation simulation end========================


    end
    
    // VCD dump
    initial begin
        $dumpfile("system_tb.vcd");
        // $dumpvars(0, pe_DUT);
        $dumpvars(0, shadowreg_A);
        // $dumpvars(0, shadowreg_B);
        // $dumpvars(0, treeadder_01);
        
    end


endmodule


//integer csvfile_output;
      
      //parameter MAXCOUNT=5;

//Write a CSV file
    
        //csvfile_output = $fopen("testoutputfile.csv"); //open output file
        
        //$fdisplay(csvfile_output, "Hello World"); //write to file
        
        //for (n=0; n<MAXCOUNT; n=n+1) begin
          //$fdisplay(csvfile_output, "Hello World,1,2,3"); //write 1 line to file
        //end
        
        //$fclose(csvfile_output); //close output file
