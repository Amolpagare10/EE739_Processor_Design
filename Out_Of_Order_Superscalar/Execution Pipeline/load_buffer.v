module load_buffer (clk, rst, opcode_lsu_i, address_lsu_i, pc_lsu_i,
                    ext_add_valid_i, data_lsu_i, data_valid_i, dest_reg_i, 
                    data_out_o, dest_reg_o, write_enable_o);
    input clk;
    input rst; // active high
    input [3:0] opcode_lsu_i;
    input [15:0] address_lsu_i;
    input [15:0] pc_lsu_i;
    input ext_add_valid_i;      // new instruction added to buffer
    input [15:0] data_lsu_i;     // data from memory
    input data_valid_i;          // memory data valid
    input [2:0] dest_reg_i;      // destination register

    output reg [15:0] data_out_o; // output to regfile
    output reg [2:0] dest_reg_o;
    output reg write_enable_o;

    // Each entry: {valid[56], opcode[55:52], pc[51:36], address[35:20], data[19:4], data_valid[3], dest[2:0]}
    reg [56:0] load_buffer [15:0];
    integer i;
    reg found;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                load_buffer[i] <= 57'b0;

            data_out_o <= 16'b0;
            dest_reg_o <= 3'b0;
            write_enable_o <= 1'b0;

        end else begin
            write_enable_o <= 1'b0; // default no write

            // Case 1: Add instruction to load buffer
            if (ext_add_valid_i) begin
                found = 0;
                for (i = 0; i < 16; i = i + 1) begin
                    if (!load_buffer[i][56] && !found) begin
                        load_buffer[i][56]     <= 1'b1;         // valid
                        load_buffer[i][55:52]  <= opcode_lsu_i;
                        load_buffer[i][51:36]  <= pc_lsu_i;
                        load_buffer[i][35:20]  <= address_lsu_i;
                        load_buffer[i][19:4]   <= 16'b0;        // placeholder data
                        load_buffer[i][3]      <= 1'b0;         // data not valid yet
                        load_buffer[i][2:0]    <= dest_reg_i;
                        found = 1;
                    end
                end
            end

            // Case 2: Data becomes valid, match by address
            if (data_valid_i) begin
                found = 0;
                for (i = 0; i < 16; i = i + 1) begin
                    if (load_buffer[i][56] && !load_buffer[i][3] && !found) begin // valid & data not written yet
                        if (load_buffer[i][35:20] == address_lsu_i) begin
                            // Update entry with memory data
                            load_buffer[i][19:4] <= data_lsu_i;
                            load_buffer[i][3]    <= 1'b1;

                            // Output to register file
                            data_out_o <= data_lsu_i;
                            dest_reg_o <= load_buffer[i][2:0];
                            write_enable_o <= 1'b1;

                            // Invalidate entry after write
                            load_buffer[i][56] <= 1'b0;
                            found = 1;
                        end
                    end
                end
            end
        end
    end
endmodule
