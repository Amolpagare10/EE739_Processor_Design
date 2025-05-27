module lsu (clk, rst, ra_lsu_i, rb_lsu_i, imm_lsu_i, opcode_lsu_i, pc_lsu_i,
            regfile_data_rb, dest_reg_i, data_out_o, dest_reg_o, write_enable_o);
            
    input clk;
    input rst;
    input [2:0] ra_lsu_i;
    input [2:0] rb_lsu_i;
    input [15:0] imm_lsu_i;
    input [3:0] opcode_lsu_i;
    input [15:0] pc_lsu_i;
    input [15:0] regfile_data_rb;  // Data from regfile[rb]
    input [2:0] dest_reg_i;

    output [15:0] data_out_o;
    output [2:0] dest_reg_o;
    output write_enable_o;

    // LSU pipeline registers
    reg [15:0] addr_stage1, addr_stage2;
    reg [15:0] pc_stage1, pc_stage2;
    reg [2:0] dest_stage1, dest_stage2;
    reg ext_add_valid_stage2;
    reg [3:0] opcode_stage1, opcode_stage2;

    wire [15:0] mem_data;
    wire mem_valid;

    // Load Buffer instance
    load_buffer u_load_buffer (
        .clk(clk),
        .rst(rst),
        .opcode_lsu_i(opcode_stage2),
        .address_lsu_i(addr_stage2),
        .pc_lsu_i(pc_stage2),
        .ext_add_valid_i(ext_add_valid_stage2),
        .data_lsu_i(mem_data),
        .data_valid_i(mem_valid),
        .dest_reg_i(dest_stage2),
        .data_out_o(data_out_o),
        .dest_reg_o(dest_reg_o),
        .write_enable_o(write_enable_o)
    );

    // Memory instance
    data_memory u_data_memory (
        .clk(clk),
        .rst(rst),
        .addr(addr_stage2),
        .data(mem_data),
        .valid(mem_valid)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr_stage1 <= 0;
            pc_stage1 <= 0;
            dest_stage1 <= 0;
            opcode_stage1 <= 0;

            addr_stage2 <= 0;
            pc_stage2 <= 0;
            dest_stage2 <= 0;
            opcode_stage2 <= 0;

            ext_add_valid_stage2 <= 0;
        end else begin
            // Address calculation
            if (opcode_lsu_i == 4'b0100 || opcode_lsu_i == 4'b0101) begin // Lw or Sw
                addr_stage1 <= regfile_data_rb + imm_lsu_i;
            end else if (opcode_lsu_i == 4'b0011) begin // LLI
                addr_stage1 <= imm_lsu_i;
            end else begin
                addr_stage1 <= 0;
            end
            pc_stage1 <= pc_lsu_i;
            dest_stage1 <= dest_reg_i;
            opcode_stage1 <= opcode_lsu_i;

            // Load buffer entry
            addr_stage2 <= addr_stage1;
            pc_stage2 <= pc_stage1;
            dest_stage2 <= dest_stage1;
            opcode_stage2 <= opcode_stage1;
            ext_add_valid_stage2 <= 1'b1;
        end
    end

endmodule
