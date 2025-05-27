//16_entries_Reservation_station and scheduler_and size of each entry is 47 bits

//Description- 
/*

(0) - Busy
(1-4) - Opcode
(5-21) - Operand 1
(22) - (V1) If operand 1 is available
(23-38) - Operand 2
(39) - (V2) If operand 2 is available
(40) - Ready bit (V1.V2)
(41-46) - Destination register (Assuming indirect addressing mode,
											otherwise need to save direct address
											of memory somewhere)

Asynchronous write 
Synchronous read

*/


module reservation_station #(parameter ALU_UNITS=2, parameter LS_UNITS=2, parameter FPT_UNITS=0)(
    input clk, rst,
    input wr_en, rd_en,
    input [46:0] input_entry_1,input_entry_2,
    output full, empty,
	 
	 input [5:0] rrf_tag,  //Broadcasted by RRF
    input [15:0] rrf_data, 
    
    /*Output Opcode(4 bit) and 2 operands (16 bit each) and (6 bits) for destination rename register
    can schedule instructions equal to no of execution pipelines*/
    output [42*(ALU_UNITS)-1:0] instructions_out_alu, 
    output [42*(LS_UNITS)-1:0] instructions_out_ls
    //output [36*(FPT_UNITS)-1:0] instructions_out_fpt
);

    parameter RS_SIZE = 16;

    reg [46:0] rs[0:RS_SIZE-1];
    integer i;
    integer wr_ptr = 0;
    integer rd_ptr = 0;
    integer entry_count = 0;
    
	 integer type_a_count = 0;
    integer type_b_count = 0;
    integer total_scheduled = 0;  // Total number of instructions scheduled in this cycle
	 
	 // Dispatch process for scheduling
    always @(posedge clk) begin
        if (!rst) begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                rs[i] <= 0;
            end
            entry_count <= 0; 
        end else begin
         
            type_a_count <= 0;
            type_b_count <= 0;
            total_scheduled <= 0;

            if (rd_en && entry_count > 0) begin
   
                for (i = 0; i < RS_SIZE && total_scheduled < 4; i = i + 1) begin
                  
                    if (rs[i][40] == 1) begin

								// ALU instructions: 0001, 0000, 0010, 1100, 1111
							 if ((rs[i][4:1] == 4'b0001 || rs[i][4:1] == 4'b0000 || rs[i][4:1] == 4'b0010 || 
									rs[i][4:1] == 4'b1100 || rs[i][4:1] == 4'b1111) && type_a_count < 2 && total_scheduled < 4) begin
								  instructions_out_alu[42*(type_a_count+1)-1:42*(type_a_count)] <= {rs[i][4:1], rs[i][21:5], rs[i][38:23]}; 
								  type_a_count = type_a_count + 1;
								  total_scheduled = total_scheduled + 1;
								  rs[i][0] = 0;
							 end
							 
							 // Load/Store instructions: 0011, 0100, 0101
							 else if ((rs[i][4:1] == 4'b0011 || rs[i][4:1] == 4'b0100 || rs[i][4:1] == 4'b0101) && 
										 type_b_count < 2 && total_scheduled < 4) begin
								  instructions_out_ls[42*(type_b_count+1)-1:42*(type_b_count)] <= {rs[i][4:1], rs[i][21:5], rs[i][38:23]}; 
								  type_b_count = type_b_count + 1;
								  total_scheduled = total_scheduled + 1;
								  rs[i][0] = 0;
							 end
						end
                end
            end
        end
    end
	 
	 // For synchronous writing
    always @(posedge clk) begin
        if (wr_en && entry_count < RS_SIZE) begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                if (rs[i][0] == 0) begin // busy bit check
                    rs[i] <= input_entry_1; 
                    wr_ptr <= (i + 1) % RS_SIZE; 
                    entry_count <= entry_count + 1;
                    break;
                end
            end
            
            for (i = wr_ptr; i < RS_SIZE; i = i + 1) begin
                if (rs[i][0] == 0) begin 
                    rs[i] <= input_entry_2; 
                    wr_ptr <= (i + 1) % RS_SIZE; 
                    entry_count <= entry_count + 1;
                    break;
                end
            end
        end
    end
	 
	 
	 // To update result broadcasted by RRF
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                rs[i] <= 0;
            end
            entry_count <= 0;  
        end else begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                if (rs[i][21:16] == rrf_tag) begin  
                    rs[i][21:6] <= {16'b0, rrf_data};  
                end
                if (rs[i][38:32] == rrf_tag) begin 
                    rs[i][38:23] <= {16'b0, rrf_data};  
                end
            end
        end
    end
    
    // Full and empty signals based on the entry count
    assign empty = (entry_count == 0);
    assign full = (entry_count == RS_SIZE);

endmodule
