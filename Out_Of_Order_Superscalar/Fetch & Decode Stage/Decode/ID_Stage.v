module ID_Stage();
                
    input clk;
    input rst; //active high
    input [15:0] pc1_ID_i, pc2_ID_i;
    input [15:0] inst1_ID_i, inst2_ID_i; 

    //form Regfile moderator
    input [15:0] ra1_data, ra2_data;
    input ra1_valid, ra2_valid;
    input [15:0] rb1_data, rb2_data;
    input rb1_valid, rb2_valid;
    input [15:0] jmp1_reg_data, jmp2_reg_data;
    input jmp1_reg_valid, jmp2_reg_valid;
    input [2:0] rrf_tag_data_1, rrf_tag_data_2;

    // To RS
    output reg [46:0] input_entry_1_ID_o, input_entry_2_ID_o;
    // To Regfile moderator 
    output reg [2:0] ra1_ID_o, ra2_ID_o; 
    output reg [2:0] rb1_ID_o, rb2_ID_o;
    output reg [2:0] jmp1_pc_reg, jmp2_pc_reg;
    output reg [15:0] rrf_in_data1, rrf_in_data2

    wire [2:0] rd1, rd2; // Destination register
    wire [2:0] ra1, ra2;
    wire [2:0] rb1, rb2; 
    wire [15:0] imm1, imm2; // Immediate value
    wire complement_bit1, complement_bit2; // Complement bit
    wire [15:0] jmp1_pc, jmp2_pc; // Jump address
    wire [15:0] ret1_pc, ret2_pc; // Return address
    wire [15:0] br1_pc, br2_pc; // Branch address
    wire [2:0] jmp1_pc_reg, jmp2_pc_reg; // Jump register address
    wire [15:0] inst1_w, inst2_w; // Instruction output
    wire [15:0] pc1__w, pc2__w; // PC output
    
    // LSU handler internal signals for instruction 1
    wire [2:0] rd1_lsu, rb1_lsu;
    wire [15:0] imm1_lsu;

    // Branch handler internal signals for instruction 1
    wire [2:0] ra1_br, rb1_br;
    wire [15:0] br1_pc;

    // Jump handler internal signals for instruction 1
    wire [2:0] rd1_jmp, jmp1_pc_reg;
    wire [15:0] jmp1_pc, ret1_pc, imm1_jmp;

    // LM/SM handler internal signals for instruction 1
    wire [2:0] rd1a_lmsm, rb1a_lmsm, rd2a_lmsm, rb2a_lmsm;
    wire [15:0] imm1a_lmsm, imm2a_lmsm;

    // ALU handler internal signals for instruction 1
    wire [2:0] rd1_alu, ra1_alu, rb1_alu;
    wire [15:0] imm1_alu;
    wire complement1_bit_alu, alu1_invalid;

    // LSU handler internal signals for instruction 2
    wire [2:0] rd2_lsu, rb2_lsu;
    wire [15:0] imm2_lsu;

    // Branch handler internal signals for instruction 2
    wire [2:0] ra2_br, rb2_br;
    wire [15:0] br2_pc;

    // Jump handler internal signals for instruction 2
    wire [2:0] rd2_jmp, jmp2_pc_reg;
    wire [15:0] jmp2_pc, ret2_pc, imm2_jmp;

    // LM/SM handler internal signals for instruction 2
    wire [2:0] rd1b_lmsm, rb1b_lmsm, rd2b_lmsm, rb2b_lmsm;
    wire [15:0] imm1b_lmsm, imm2b_lmsm;

    // ALU handler internal signals for instruction 2
    wire [2:0] rd2_alu, ra2_alu, rb2_alu;
    wire [15:0] imm2_alu;
    wire complement2_bit_alu, alu2_invalid;

    wire inst1__ready = ra1_valid && rb1_valid;
    wire inst2__ready = ra2_valid && rb2_valid;

    alu_handler alu1(
        .inst_i(inst1_ID_i),
        .complement_bit_o(complement1_bit_alu),
        .alu_invalid_o(alu1_invalid),
        .rd_o(rd1_alu),
        .ra_o(ra1_alu),
        .rb_o(rb1_alu),
        .imm_o(imm1_alu)
    );
    alu_handler alu2(
        .inst_i(inst2_ID_i),
        .complement_bit_o(complement2_bit_alu),
        .alu_invalid_o(alu2_invalid),
        .rd_o(rd2_alu),
        .ra_o(ra2_alu),
        .rb_o(rb2_alu),
        .imm_o(imm2_alu)
    );
    lsu_handler lsu1(
        .inst_i(inst1_ID_i),
        .rd_o(rd1_lsu),
        .rb_o(rb1_lsu),
        .imm_o(imm1_lsu)
    );
    lsu_handler lsu2(
        .inst_i(inst2_ID_i),
        .rd_o(rd2_lsu),
        .rb_o(rb2_lsu),
        .imm_o(imm2_lsu)
    );
    branch_handler br_h1(
        .inst_i(inst1_ID_i),
        .pc_i(pc1_ID_i),
        .ra(ra1_br),
        .rb(rb1_br),
        .br_pc_o(br1_pc)
    );
    branch_handler br_h2(
        .inst_i(inst2_ID_i),
        .pc_i(pc2_ID_i),
        .ra(ra2_br),
        .rb(rb2_br),
        .br_pc_o(br2_pc)
    );
    jump_handler jmp_h1(
        .inst_i(inst1_ID_i),
        .pc_i(pc1_ID_i),
        .jmp_pc_o(jmp1_pc),
        .ret_pc_o(ret1_pc),
        .rd_o(rd1_jmp),
        .jmp_pc_reg_o(jmp1_pc_reg),
        .imm_o(imm1_jmp)
    );
    jump_handler jmp_h2(
        .inst_i(inst2_ID_i),
        .pc_i(pc2_ID_i),
        .jmp_pc_o(jmp2_pc),
        .ret_pc_o(ret2_pc),
        .rd_o(rd2_jmp),
        .jmp_pc_reg_o(jmp2_pc_reg),
        .imm_o(imm2_jmp)
    );
    lm_sm_handler lmsm_h1(
        .clk(clk),
        .inst_i(inst1_ID_i),
        .rd1_o(rd1a_lmsm),
        .rb1_o(rb1a_lmsm),
        .imm1_o(imm1a_lmsm),
        .rd2_o(rd2a_lmsm),
        .rb2_o(rb2a_lmsm),
        .imm2_o(imm2a_lmsm)
    );
    lm_sm_handler lmsm_h2(
        .clk(clk),
        .inst_i(inst2_ID_i),
        .rd1_o(rd1b_lmsm),
        .rb1_o(rb1b_lmsm),
        .imm1_o(imm1b_lmsm),
        .rd2_o(rd2b_lmsm),
        .rb2_o(rb2b_lmsm),
        .imm2_o(imm2b_lmsm)
    );

    // First instruction processing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset code left
            inst1_w <= 16'b0;
            pc1__w <= 16'b0;
            rd1 <= 3'b0;
            ra1 <= 3'b0;
            rb1 <= 3'b0;
            imm1 <= 16'b0;
            complement_bit1 <= 1'b0;
            jmp1_pc <= 16'b0;
            ret1_pc <= 16'b0;
            br1_pc <= 16'b0;
            jmp1_pc_reg <= 3'b0;
        end else begin
            inst1_w <= inst1_ID_i;
            pc1__w <= pc1_ID_i;
            case(inst1_ID_i[15:12])
                4'b0001, 4'b0010, 4'b0000: //ALU operations
                begin
                    ra1 <= ra1_alu;
                    rb1 <= rb1_alu;
                    rd1 <= rd1_alu;
                    imm1 <= imm1_alu;
                    complement_bit1 <= complement1_bit_alu;
                end
                4'b1100, 4'b1101, 4'b1111: // Jump Instructions
                begin
                    jmp1_pc <= jmp1_pc;
                    ret1_pc <= ret1_pc;
                    rd1 <= rd1_jmp;  
                    ra1 <= 3'bZZZ;
                    rb1 <= 3'bZZZ;
                    imm1 <= imm1_jmp;
                    complement_bit1 <= 1'b0;
                    jmp1_pc_reg <= jmp1_pc_reg;
                end
                4'b1000, 4'b1001: // Branch Instructions
                begin
                    br1_pc <= br1_pc; // In RS store PC + 2*imm in RRF and store the reg tag to rd
                    ra1 <= ra1_br;
                    rb1 <= rb1_br;
                    rd1 <= 3'bZZZ;
                    imm1 <= 16'b0;
                    complement_bit1 <= 1'b0;
                end
                4'b0011, 4'b0100, 4'b0101: // LLI, LW, SW Instructions
                begin 
                    ra1 <= 3'bZZZ;
                    rb1 <= rb1_lsu;
                    rd1 <= rd1_lsu;
                    imm1 <= imm1_lsu;
                    complement_bit1 <= 1'b0;
                end
                4'b0110, 4'b0111: //LM and SM Instructions
                begin
                    rb1 <= rb1a_lmsm;
                    rd1 <= rd1a_lmsm;
                    imm1 <= imm1a_lmsm;
                    rb2 <= rb2a_lmsm;
                    rd2 <= rd2a_lmsm;
                    imm2 <= imm2a_lmsm;
                    complement_bit1 <= 1'b0;
                end
                default: // Invalid Instruction
                begin
                    ra1 <= 3'bZZZ;
                    rb1 <= 3'bZZZ;
                    rd1 <= 3'bZZZ;
                    imm1 <= 16'b0;
                    complement_bit1 <= 1'b0;
                end
            endcase
        end

        if(inst1_ID_i[15:12] == 4'b0110 || inst1_ID_i[15:12] == 4'b0111) begin // ALU except ADI
            input_entry_1_ID_o <= {complement_bit1, rd1, inst1__ready, rb1_valid, rb1_data, ra1_valid, ra1_data, inst1_ID_i[15:12], 1'b1};
        end
        else if(inst1_ID_i[15:12] == 4'b0000) begin //ADI
            input_entry_1_ID_o <= {1'b0, rd1, ra1_valid, 1'b1, imm1, ra1_valid, ra1_data, inst1_ID_i[15:12], 1'b1}; 
        end
        else if(inst1_ID_i[15:12] == 4'b0011) begin // LLI
            input_entry_1_ID_o <= {1'b0, rd1, 1'b1, 1'b1, imm1, 1'b0, 16'b0, inst1_ID_i[15:12], 1'b1}
        end
        else if(inst1_ID_i[15:12] == 4'b0100) begin // LW, SW
            input_entry_1_ID_o <= {1'b0, rd1, rb1_valid, rb1_valid, rb1_data, 1'b1, imm1, inst1_ID_i[15:12], 1'b1}
        end // LM/SM left
        else if(inst1_ID_i[15:12] == 4'b1000 || inst1_ID_i[15:12] == 4'b1001) begin // Branch
            input_entry_1_ID_o <= {1'b0, rrf_tag_data_1 inst1__ready, rb1_valid, rb1_data, ra1_valid, ra1_data, inst1_ID_i[15:12], 1'b1}
        end
        else if(inst1_ID_i[15:12] == 4'b1100 ) begin // JAL
            input_entry_1_ID_o <= {1'b0, rd1, 1'b1, 1'b1, jmp1_pc, 1'b1, ret1_pc, inst1_ID_i[15:12], 16'b1}
        end
        else if(inst1_ID_i[15:12] == 4'b1101) begin // JLR
            input_entry_1_ID_o <= {1'b0, rd1, jmp1_reg_valid, jmp1_reg_valid, jmp1_reg_data 1'b1, ret1_pc, inst1_ID_i[15:12], 16'b1}
        end
        else if(inst1_ID_i[15:12] == 4'b1111) begin // JRI
            input_entry_1_ID_o <= {1'b0, 3'b0, ra1_valid, 1'b1, jmp1_pc, ra1_valid, ra1_data, inst1_ID_i[15:12], 16'b0}
        end
    end

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
(47) - Complement bit

Asynchronous write 
Synchronous read

*/

    // Second instruction processing    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            // Reset code left
            inst2_w <= 16'b0;
            pc2__w <= 16'b0;
            rd2 <= 3'b0;
            ra2 <= 3'b0;
            rb2 <= 3'b0;
            imm2 <= 16'b0;
            complement_bit2 <= 1'b0;
            jmp2_pc <= 16'b0;
            ret2_pc <= 16'b0;
            br2_pc <= 16'b0;
            jmp2_pc_reg <= 3'b0;
        end
        else begin
            inst2_w <= inst2_ID_i;
            pc2__w <= pc2_ID_i;
            case(inst2_ID_i[15:12])
                4'b0001, 4'b0010, 4'b0000: //ALU operations
                begin
                    ra2 <= ra2_alu;
                    rb2 <= rb2_alu;
                    rd2 <= rd2_alu;
                    imm2 <= imm2_alu;
                    complement_bit2 <= complement2_bit_alu;
                end
                4'b1100, 4'b1101, 4'b1111: // Jump Instructions
                begin
                    jmp2_pc <= jmp2_pc;
                    ret2_pc <= ret2_pc;
                    rd2 <= rd2_jmp;
                    ra2 <= 3'bZZZ;
                    rb2 <= 3'bZZZ;
                    imm2 <= imm2_jmp;
                    complement_bit2 <= 1'b0;
                    jmp2_pc_reg <= jmp2_pc_reg;
                end
                4'b1000, 4'b1001: // Branch Instructions
                begin
                    br2_pc <= br2_pc; // In RS store PC + 2*imm in RRF and store the reg tag to rd
                    ra2 <= ra2_br;
                    rb2 <= rb2_br;
                    rd2 <= 3'bZZZ;
                    imm2 <= 16'b0;
                    complement_bit2 <= 1'b0;
                end
                4'b0011, 4'b0100, 4'b0101: // LLI, LW, SW Instructions
                begin
                    ra2 <= 3'bZZZ;
                    rb2 <= rb2_lsu;
                    rd2 <= rd2_lsu;
                    imm2 <= imm2_lsu;
                    complement_bit1 <= 1'b0;
                end
                4'b0110, 4'b0111: //LM and SM Instructions
                begin
                    rb1 <= rb1b_lmsm; 
                    rd1 <= rd1b_lmsm;
                    imm1 <= imm1b_lmsm;
                    rb2 <= rb2b_lmsm;
                    rd2 <= rd2b_lmsm;
                    imm2 <= imm2b_lmsm;
                    complement_bit2 <= 1'b0;
                end
                default: // Invalid Instruction
                begin
                    ra2 <= 3'bZZZ;
                    rb2 <= 3'bZZZ;
                    rd2 <= 3'bZZZ;
                    imm2 <= 16'b0;
                    complement_bit2 <= 1'b0;
                end
            endcase
        end
    
    if(inst2_ID_i[15:12] == 4'b0110 || inst2_ID_i[15:12] == 4'b0111) begin // ALU except ADI
        input_entry_2_ID_o <= {complement_bit2, rd2, inst2__ready, rb2_valid, rb2_data, ra2_valid, ra2_data, inst2_ID_i[15:12], 1'b1};
    end
    else if(inst2_ID_i[15:12] == 4'b0000) begin //ADI
        input_entry_2_ID_o <= {1'b0, rd2, ra2_valid, 1'b1, imm2, ra2_valid, ra2_data, inst2_ID_i[15:12], 1'b1}; 
    end
    else if(inst2_ID_i[15:12] == 4'b0011) begin // LLI
        input_entry_2_ID_o <= {1'b0, rd2, 1'b1, 1'b1, imm2, 1'b0, 16'b0, inst2_ID_i[15:12], 1'b1}
    end
    else if(inst2_ID_i[15:12] == 4'b0100) begin // LW, SW
        input_entry_2_ID_o <= {1'b0, rd2, rb2_valid, rb2_valid, rb2_data, 1'b1, imm2, inst2_ID_i[15:12], 1'b1}
    end // LM/SM left
    else if(inst2_ID_i[15:12] == 4'b1000 || inst2_ID_i[15:12] == 4'b1001) begin // Branch
        input_entry_2_ID_o <= {1'b0, rrf_tag_data_2 inst2__ready, rb2_valid, rb2_data, ra2_valid, ra2_data, inst2_ID_i[15:12], 1'b1}
    end
    else if(inst2_ID_i[15:12] == 4'b1100 ) begin // JAL
        input_entry_2_ID_o <= {1'b0, rd2, 1'b1, 1'b1, jmp2_pc, 1'b1, ret2_pc, inst2_ID_i[15:12], 16'b1}
    end
    else if(inst2_ID_i[15:12] == 4'b1101) begin // JLR
        input_entry_2_ID_o <= {1'b0, rd2, jmp2_reg_valid, jmp2_reg_valid, jmp2_reg_data 1'b1, ret2_pc, inst2_ID_i[15:12], 16'b1}
    end
    else if(inst2_ID_i[15:12] == 4'b1111) begin // JRI
        input_entry_2_ID_o <= {1'b0, 3'b0, ra2_valid, 1'b1, jmp2_pc, ra2_valid, ra2_data, inst2_ID_i[15:12], 16'b0}
    end
end
    
endmodule

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