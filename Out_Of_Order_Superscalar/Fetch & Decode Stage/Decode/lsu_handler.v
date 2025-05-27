module lsu_handler(inst_i, rd_o, rb_o, imm_o);
    input [15:0] inst_i;
    output reg [2:0] rd_o, rb_o;
    output reg [15:0] imm_o;

    always @ (inst_i)
    begin 
        case(inst_i[15:12])
            4'b0011: //LLI
            begin 
                rd_o <= inst_i[11:9];
                imm_o <= {7'b0, inst_i[8:0]};
                rb_o <= 3'bZZZ;
            end
            4'b0100: //LW
            begin 
                rd_o <= inst_i[11:9];
                rb_o <= inst_i[8:6];
                imm_o <= {10'b0 ,(inst_i[5:0])};
            end
            4'b0101: //SW
            begin 
                rd_o <= inst_i[11:9];
                rb_o <= inst_i[8:6];
                imm_o <= {10'b0 ,(inst_i[5:0])};
            end
            default:
            begin 
                rd_o <= 3'bZZZ;
                rb_o <= 3'bZZZ;
                imm_o <= 16'b0;
            end
        endcase
    end
endmodule