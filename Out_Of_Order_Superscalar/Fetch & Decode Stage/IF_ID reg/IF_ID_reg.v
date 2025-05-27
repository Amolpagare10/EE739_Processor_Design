module IF_ID_reg(clk, rst, IF_ID_reg_clear_i,
                 pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o,
                 pc1_ID_o, pc2_ID_o, inst1_ID_o, inst2_ID_o);
                 
    input clk, rst;
    input IF_ID_reg_clear_i;
    input [15:0] pc1_IF_o; //from IF
    input [15:0] pc2_IF_o; //from IF
    input [15:0] inst1_IF_o; //from IF
    input [15:0] inst2_IF_o;  //from IF

    output reg [15:0] pc1_ID_o; // To decoder
    output reg [15:0] pc2_ID_o; // To decoder
    output reg [15:0] inst1_ID_o; // To decoder
    output reg [15:0] inst2_ID_o;  // To decoder

    always @(posedge clk or posedge rst) begin
        if (rst || IF_ID_reg_clear_i) begin
            pc1_ID_o <= 16'h0000;
            pc2_ID_o <= 16'h0000;
            inst1_ID_o <= 16'h0000;
            inst2_ID_o <= 16'h0000;
        end else begin
            pc1_ID_o <= pc1_IF_o;
            pc2_ID_o <= pc2_IF_o;
            inst1_ID_o <= inst1_IF_o;
            inst2_ID_o <= inst2_IF_o;
        end
    end
endmodule 