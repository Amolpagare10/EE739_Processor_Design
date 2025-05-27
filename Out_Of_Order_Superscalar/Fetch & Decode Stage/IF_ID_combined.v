module IF_ID_combined(
    input clk,
    input rst, // Active high
    input fetch_stall_i, // From decoder
    input rs_full_i,     // From RS
    input [15:0] pc_c_IF_i, // new PC from decoder/controller
    input pc_en_c_IF_i,     // enable from controller
    input IF_ID_reg_clear_i, // From controller

    // Outputs from decoder (from ID stage)
    output [2:0] ra1_ID_o, ra2_ID_o,
    output [2:0] rb1_ID_o, rb2_ID_o,
    output [2:0] jmp1_pc_reg_ID_o, jmp2_pc_reg_ID_o,
    output [15:0] rrf_in_data1, rrf_in_data2,
    output [46:0] input_entry_1_ID_o, input_entry_2_ID_o,
	 output [15:0] pc1,pc2
);

    // Internal wires between IF and ID stages
    wire [15:0] pc1_IF_w, pc2_IF_w;
    wire [15:0] inst1_IF_w, inst2_IF_w;
    wire [15:0] pc1_ID_reg_w, pc2_ID_reg_w;
    wire [15:0] inst1_ID_reg_w, inst2_ID_reg_w;

    // IF Stage instantiation
    IF_stage IF_stage_inst(
        .clk(clk),
        .rst(rst),
        .fetch_stall_i(fetch_stall_i),
        .rs_full_i(rs_full_i),
        .pc_c_IF_i(pc_c_IF_i),
        .pc_en_c_IF_i(pc_en_c_IF_i),
        .pc1_IF_o(pc1_IF_w),
        .pc2_IF_o(pc2_IF_w),
        .inst1_IF_o(inst1_IF_w),
        .inst2_IF_o(inst2_IF_w)
    );

    // IF/ID Register instantiation
    IF_ID_reg IF_ID_reg_inst(
        .clk(clk),
        .rst(rst),
        .IF_ID_reg_clear_i(IF_ID_reg_clear_i),
        .pc1_IF_o(pc1_IF_w),
        .pc2_IF_o(pc2_IF_w),
        .inst1_IF_o(inst1_IF_w),
        .inst2_IF_o(inst2_IF_w),
        .pc1_ID_o(pc1_ID_reg_w),
        .pc2_ID_o(pc2_ID_reg_w),
        .inst1_ID_o(inst1_ID_reg_w),
        .inst2_ID_o(inst2_ID_reg_w)
    );

    // ID Stage instantiation (new updated interface)
    ID_Stage ID_Stage_inst(
        .clk(clk),
        .rst(rst),
        .pc1_ID_i(pc1_ID_reg_w),
        .pc2_ID_i(pc2_ID_reg_w),
        .inst1_ID_i(inst1_ID_reg_w),
        .inst2_ID_i(inst2_ID_reg_w),

        // Inputs from Regfile moderator — these need to be connected externally in datapath
        .ra1_data(), .ra2_data(),
        .rb1_data(), .rb2_data(),
        .jmp1_reg_data(), .jmp2_reg_data(),
        .ra1_valid(), .ra2_valid(),
        .rb1_valid(), .rb2_valid(),
        .jmp1_reg_valid(), .jmp2_reg_valid(),
        .rrf_tag_data_1(), .rrf_tag_data_2(),

        // Outputs to Regfile moderator
        .ra1_ID_o(ra1_ID_o),
        .ra2_ID_o(ra2_ID_o),
        .rb1_ID_o(rb1_ID_o),
        .rb2_ID_o(rb2_ID_o),
        .jmp1_pc_reg(jmp1_pc_reg_ID_o),
        .jmp2_pc_reg(jmp2_pc_reg_ID_o),
        .rrf_in_data1(rrf_in_data1),
        .rrf_in_data2(rrf_in_data2),

        // Outputs to RS
        .input_entry_1_ID_o(input_entry_1_ID_o),
        .input_entry_2_ID_o(input_entry_2_ID_o)
    );
	 pc1 <= pc1_IF_w;
	 pc2 <= pc2_IF_w;

endmodule
