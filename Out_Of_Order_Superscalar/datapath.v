//Datapath

module datapath (
    input clk,
    input rst,
	 
	 output [15:0] register_data,  //User has access to read all the architectural RF
	 input [2:0] register_address
);

    // Program Counter stage signals
    wire [15:0] pc_decode, pc_scheduler, pc_exe, pc_rob, pc_out;
    wire        valid_decode, valid_scheduler, valid_exe, valid_rob, pc_external;

    // Stall control signals
    wire        stall_req, resume_scheduler, resume_exe;
    wire [5:0]  stall_opcode;

    // Controller outputs
    wire stop_fetch, clear_ifid, flush;

    // RS status
    wire rs_full, rs_empty;
	 wire [42:0] instructions_out_alu;
	 wire [42:0] instructions_out_ls;

    // IF_ID_combined outputs
    wire [2:0] ra1_ID, ra2_ID, rb1_ID, rb2_ID;
    wire [2:0] jmp1_pc_reg_ID, jmp2_pc_reg_ID;
    wire [15:0] rrf_data1, rrf_data2;
    wire [46:0] input_entry_1_ID, input_entry_2_ID;

    // New wires for IF stage
    wire [15:0] pc_c_IF;
    wire        pc_en_c_IF;
    wire        IF_ID_reg_clear;

    // Wires from IF stage to ROB, ALU, LSU
    wire [15:0] inst1_IF, inst2_IF;
    wire [15:0] pc1_IF, pc2_IF;

    // Wires from ID stage to ROB, ALU, LSU
    wire [2:0] rd1_ID, rd2_ID;
    wire [15:0] result1_alu, result2_alu;
    wire [15:0] rd1_ID_data, rd2_ID_data;
    wire [15:0] imm1_ID, imm2_ID;

    // RRF communication
	 wire broadcast_valid;
	 wire [5:0] broadcast_tag;
	 wire [15:0] broadcast_data;
	 
	wire read_valid;
	wire read_busy;
	wire [5:0] read_forward_tag;


    // ALU handler outputs
    wire complement_bit;
    wire alu_invalid;
    wire [2:0] alu_ra, alu_rb;

    // LSU outputs
    wire [15:0] data_out_lsu;
    wire [2:0] dest_reg_lsu;
    wire write_enable_lsu;

    // ROB commit outputs
    wire [15:0] commit_pc, commit_result;
    wire [2:0]  commit_rd;
    wire        commit_valid;
	 
	 wire [15:0] arf_out [0:7];
	 
    // Controller
    Controller controller_inst (
         .clk(clk),
         .reset(rst),

         .pc_decode(pc_decode),
         .valid_decode(valid_decode),
         .pc_scheduler(pc_scheduler),
         .valid_scheduler(valid_scheduler),
         .pc_exe(pc_exe),
         .valid_exe(valid_exe),
         .pc_rob(pc_rob),
         .valid_rob(valid_rob),

         .pc_out(pc_out),
         .pc_external(pc_external),

         .stall_req(stall_req),
         .stall_opcode(stall_opcode),
         .resume_scheduler(resume_scheduler),
         .resume_exe(resume_exe),

         .stop_fetch(stop_fetch),
         .clear_ifid(clear_ifid),
         .flush(flush)
    );

    // IF_ID combined stage
    IF_ID_combined IF_ID_combined_inst (
         .clk(clk),
         .rst(rst),
         .fetch_stall_i(stop_fetch),
         .rs_full_i(rs_full),
         .pc_c_IF_i(pc_c_IF),
         .pc_en_c_IF_i(pc_en_c_IF),
         .IF_ID_reg_clear_i(IF_ID_reg_clear),

         .ra1_ID_o(ra1_ID),
         .ra2_ID_o(ra2_ID),
         .rb1_ID_o(rb1_ID),
         .rb2_ID_o(rb2_ID),
         .jmp1_pc_reg_ID_o(jmp1_pc_reg_ID),
         .jmp2_pc_reg_ID_o(jmp2_pc_reg_ID),
         .rrf_in_data1(rrf_data1),
         .rrf_in_data2(rrf_data2),
         .input_entry_1_ID_o(input_entry_1_ID),
         .input_entry_2_ID_o(input_entry_2_ID),
			.pc1(pc1),
			.pc2(pc2)
    );

    // Reservation Station
    reservation_station rs_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(1'b1),
        .rd_en(1'b1),
        .input_entry_1(input_entry_1_ID),
        .input_entry_2(input_entry_2_ID),
        .full(rs_full),
        .empty(rs_empty),
        .rrf_tag(broadcast_tag),
        .rrf_data(broadcast_data),
        .instructions_out_alu(instructions_out_alu),
        .instructions_out_ls(instructions_out_ls)
    );


    // Unified Register File
    unified_register_file regfile_inst (
        .clk(clk),
        .rst(rst),
        .alloc_req(1'b0),
        .alloc_tag(rrf_tag),
        .alloc_valid(),
        .rrf_write_en(1'b0),
        .rrf_write_tag(rrf_tag),
        .rrf_write_data(rrf_data),
        .broadcast_valid(broadcast_valid),
        .broadcast_tag(broadcast_tag),
        .broadcast_data(broadcast_data),
        .commit_en(1'b0),
        .commit_rrf_tag(commit_rd_tag),
        .commit_arf_addr(rd1_tag),
        .read_addr(ra1_ID),
        .read_data(rrf_data),
        .read_valid(read_valid),
        .read_busy(read_busy),
        .read_forward_tag(read_forward_tag),
    );
 
    // ALU Handler 1
    alu_handler alu_handler_inst1 (
        .inst_i(inst1_IF),
        .complement_bit_o(complement_bit),
        .alu_invalid_o(alu_invalid),
        .rd_o(instructions_out_alu[5:0]),
        .ra_o(alu_ra),
        .rb_o(alu_rb),
        .imm_o(imm1_ID)
    );

    // ALU 1
    alu alu_inst1 (
        .clk(clk),
        .rst(rst),
        .complement_bit(complement_bit),
        .op(instructions_out_alu[83:80]), 
        .a(instructions_out_alu[79:64]),
        .b(instructions_out_alu[63:47]),
        .cin(1'b0),
        .s(result1_alu),
        .comp_o(),
        .c_o(),
        .z_o()
    );
	 
	  // ALU Handler 2
    alu_handler alu_handler_inst2 (
        .inst_i(inst1_IF),
        .complement_bit_o(complement_bit),
        .alu_invalid_o(alu_invalid),
        .rd_o(instructions_out_alu[5:0]),
        .ra_o(alu_ra),
        .rb_o(alu_rb),
        .imm_o(imm1_ID)
    );

    // ALU 2
    alu alu_inst2 (
        .clk(clk),
        .rst(rst),
        .complement_bit(complement_bit),
        .op(instructions_out_alu[41:38]),
        .a(instructions_out_alu[37:22]),
        .b(instructions_out_alu[21:6]),
        .cin(1'b0),
        .s(result2_alu),
        .comp_o(),
        .c_o(),
        .z_o()
    );

    // LSU 1
    lsu lsu_inst1 (
        .clk(clk),
        .rst(rst),
        .ra_lsu_i(rrf_data1),
        .rb_lsu_i(rrf_data2),
        .imm_lsu_i(imm1_ID),
        .opcode_lsu_i(instructions_out_ls[83:80]), 
        .pc_lsu_i(pc1_IF),
        .regfile_data_rb(rrf_data2),
        .dest_reg_i(rd1_ID),
        .data_out_o(data_out_lsu),
        .dest_reg_o(dest_reg_lsu),
        .write_enable_o(write_enable_lsu)
    );
	 
	 
    // LSU 2
    lsu lsu_inst2 (
        .clk(clk),
        .rst(rst),
        .ra_lsu_i(rrf_data1),
        .rb_lsu_i(rrf_data2),
        .imm_lsu_i(imm1_ID),
        .opcode_lsu_i(instructions_out_ls[41:38]), 
        .pc_lsu_i(pc1_IF),
        .regfile_data_rb(rrf_data2),
        .dest_reg_i(rd1_ID),
        .data_out_o(data_out_lsu),
        .dest_reg_o(dest_reg_lsu),
        .write_enable_o(write_enable_lsu)
    );

	// Instantiate the reorder buffer
	reorder_buffer rob (
		 .clk(clk),
		 .rst(rst),
		 .pc1_i(pc1),
		 .pc2_i(pc2),
		 .rd1_id(rd1_tag),
		 .rd2_id(rd2_tag),
		 .valid1(valid1),
		 .valid2(valid2),
		 .commit_en(commit_en),

		 .rrf_data(rrf_data),
		 .arf(arf),

		 .commit_pc(commit_pc),
		 .commit_rd_tag(commit_rd_tag),
		 .commit_valid(commit_valid)
	);


	writeback_stage wb (
		 .clk(clk),
		 .rst(rst),
		 .commit_valid(commit_valid),
		 .commit_rd_tag(commit_rd_tag),
		 .commit_data(rrf_data[commit_rd_tag]),   
		 .arf_out(arf_out)		 
	);



endmodule
