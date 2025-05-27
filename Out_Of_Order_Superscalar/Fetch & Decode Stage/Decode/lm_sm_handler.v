module lm_sm_handler(clk, inst_i, rd1_o, rd2_o, rb1_o, rb2_o, imm1_o, imm2_o);
    input clk;
    input [15:0] inst_i;
    output reg [2:0] rd1_o, rd2_o, rb1_o, rb2_o;
    output reg [15:0] imm1_o, imm2_o;

    integer i;
    
    always @ (posedge clk)
    begin
        case(inst_i[15:12])
            4'b0110: // LM
            begin
                for(i = 0; i < 4; i = i + 1) begin
                    if(inst_i[2*i] == 1'b1) begin
                        rb1_o <= i[2:0];
                        rd1_o <= inst_i[11:9];
                    end
                    else begin
                        rb1_o <= 3'bZZZ;
                        rd1_o <= 3'bZZZ;
                    end
                end
                imm1_o <= 16'b0;
            end
            4'b0111: // SM
            begin
                for(i = 0; i < 4; i = i + 1) begin
                    if(inst_i[2*i] == 1'b1) begin
                        rb1_o <= i[2:0];
                        rd1_o <= inst_i[11:9];
                    end
                    else begin
                        rb1_o <= 3'bZZZ;
                        rd1_o <= 3'bZZZ;
                    end
                end
                imm1_o <= 16'b0;
            end
            default:
            begin
                rd1_o <= 3'bZZZ;
                rb1_o <= 3'bZZZ;
                imm1_o <= 16'b0;
            end
        endcase
    end

    always @ (inst_i)
    begin
        case(inst_i[15:12])
            4'b0110: // LM
            begin
                for(i = 0; i < 4; i = i + 1) begin
                    if(inst_i[2*i+1] == 1'b1) begin
                        rb2_o <= i[2:0];
                        rd2_o <= inst_i[11:9];
                    end
                    else begin
                        rb2_o <= 3'bZZZ;
                        rd2_o <= 3'bZZZ;
                    end
                end
                imm2_o <= 16'b0;
            end
            4'b0111: // SM
            begin
                for(i = 0; i < 4; i = i + 1) begin
                    if(inst_i[2*i+1] == 1'b1) begin
                        rb2_o <= i[2:0];
                        rd2_o <= inst_i[11:9];
                    end
                    else begin
                        rb2_o <= 3'bZZZ;
                        rd2_o <= 3'bZZZ;
                    end
                end
                imm2_o <= 16'b0;
            end
            default:
            begin
                rd2_o <= 3'bZZZ;
                rb2_o <= 3'bZZZ;
                imm2_o <= 16'b0;
            end
        endcase
    end

endmodule