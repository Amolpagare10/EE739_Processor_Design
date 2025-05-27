module jump_handler(inst_i, pc_i, jmp_pc_o, ret_pc_o, rd_o, jmp_pc_reg_o, imm_o);
    input [15:0] inst_i;
    input [15:0] pc_i; 

    output reg [15:0] jmp_pc_o, ret_pc_o;
    output reg [2:0] rd_o, jmp_pc_reg_o;
    output reg [15:0] imm_o;

    always @ (inst_i or pc_i)
    begin 
        case (inst_i[15:12])
            4'b1100: //JAL
            begin
                jmp_pc_o <= pc_i + (2*{7'b0, inst_i[8:0]});
                ret_pc_o <= pc_i + 16'h0002;
                rd_o <= inst_i[11:9];
                jmp_pc_reg_o <= 3'bZZZ;
                imm_o <= 16'b0;
            end
            4'b1101: //JLR
            begin 
                jmp_pc_reg_o <= inst_i[8:6];
                ret_pc_o <= pc_i + 16'h0002;
                rd_o <= inst_i[11:9];
                jmp_pc_o <= 16'bZ;
                imm_o <= 16'b0;
            end
            4'b1111: //JRI
            begin
                imm_o <= 2*{7'b0, inst_i[8:0]};
                jmp_pc_reg_o <= inst_i[11:9];
                ret_pc_o <= 16'bZ;
                rd_o <= 3'bZZZ;
                jmp_pc_o <= 16'bZ;
            end
            default: 
            begin
                jmp_pc_o <= 16'bZ;
                ret_pc_o <= 16'bZ;
                rd_o <= 3'bZZZ;
                jmp_pc_reg_o <= 3'bZZZ;
                imm_o <= 16'b0;
            end
        endcase
    end
endmodule