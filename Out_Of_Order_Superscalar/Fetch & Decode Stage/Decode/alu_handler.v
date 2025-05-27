module alu_handler(inst_i, complement_bit_o, alu_invalid_o, rd_o, ra_o, rb_o, imm_o);

  input [15:0] inst_i; 
  output reg complement_bit_o;
  output reg alu_invalid_o;
  output reg [2:0] rd_o, ra_o, rb_o; 
  output reg [15:0] imm_o; 

  always @ (inst_i)
  begin
    case (inst_i[15:12])
      4'b0000: // ADI
      begin
        rd_o <= inst_i[8:6];
        ra_o <= inst_i[11:9];
        rb_o <= 3'bZZZ; // No second operand
        imm_o <= {10'b0, inst_i[5:0]}; // Immediate value
        complement_bit_o <= 1'b0;
        alu_invalid_o <= 1'b0;
      end
      4'b0001: // Addition 
      begin
        case (inst_i[2:0])
          3'b000, 3'b010, 3'b001: // ADA, ADC, ADZ
          begin
            rd_o <= inst_i[5:3];
            rb_o <= inst_i[8:6];
            ra_o <= inst_i[11:9];
            imm_o <= 16'b0;
            complement_bit_o <= 1'b0;
            alu_invalid_o <= 1'b0;
          end
          3'b100, 3'b110, 3'b101: // ACA, ACC, ACZ
          begin
            rd_o <= inst_i[5:3];
            rb_o <= inst_i[8:6];
            ra_o <= inst_i[11:9];
            imm_o <= 16'b0;
            complement_bit_o <= 1'b1;
            alu_invalid_o <= 1'b0;
          end
          3'b011, 3'b111: // AWC, ACW
          begin 
            //complete the instruction ***********************
            complement_bit_o <= 1'b0;
            alu_invalid_o <= 1'b0;
          end
          default:
          begin
            rd_o <= 3'bZZZ;
            ra_o <= 3'bZZZ;
            rb_o <= 3'bZZZ;
            imm_o <= 16'b0;
            complement_bit_o <= 1'b0;
            alu_invalid_o <= 1'b1;
          end
        endcase
      end
      4'b0010: // NAND operations
      begin
        case (inst_i[2:0])
          3'b000, 3'b010, 3'b001: // NDU, NDC, NDZ
          begin
            rd_o <= inst_i[5:3];
            rb_o <= inst_i[8:6];
            ra_o <= inst_i[11:9];
            imm_o <= 16'b0;
            complement_bit_o <= 1'b0;
            alu_invalid_o <= 1'b0;
          end
          3'b100, 3'b110, 3'b101: // NCU, NCC, NCZ
          begin
            rd_o <= inst_i[5:3];
            rb_o <= inst_i[8:6];
            ra_o <= inst_i[11:9];
            imm_o <= 16'b0;
            complement_bit_o <= 1'b1;
            alu_invalid_o <= 1'b0;
          end
          default:
          begin
            rd_o <= 3'bZZZ;
            ra_o <= 3'bZZZ;
            rb_o <= 3'bZZZ;
            imm_o <= 16'b0;
            complement_bit_o <= 1'b0;
            alu_invalid_o <= 1'b1;
          end
        endcase
      end
      default:
      begin
        rd_o <= 3'bZZZ;
        ra_o <= 3'bZZZ;
        rb_o <= 3'bZZZ;
        imm_o <= 16'b0;
        complement_bit_o <= 1'b0;
        alu_invalid_o <= 1'b1;
      end
    endcase
  end
endmodule
