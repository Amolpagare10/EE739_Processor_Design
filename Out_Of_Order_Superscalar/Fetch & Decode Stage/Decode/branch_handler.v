module branch_handler(inst_i, pc_i, ra, rb, br_pc_o);
  input [15:0] inst_i; 
  input [15:0] pc_i;

  output reg [2:0] ra, rb; // rd location has PC + 2*imm
  output reg [15:0] br_pc_o;

  always @ (inst_i)
  begin
    br_pc_o <= pc_i + (2*{10'b0, inst_i[5:0]});
    ra <= inst_i[11:9];
    rb <= inst_i[8:6];
  end
endmodule
