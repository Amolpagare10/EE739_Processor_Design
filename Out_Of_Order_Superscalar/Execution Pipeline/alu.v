module alu(clk, rst, complement_bit, op, a, b, cin, s, comp_o, c_o, z_o);
    input clk;
    input rst;
    input complement_bit;
    input [2:0] op;
    input [15:0] a, b;
    input cin;
    output reg [15:0] s;
    output reg comp_o;
    output reg c_o;
    output reg z_o;

    wire [15:0] b_eff = (complement_bit) ? (~b + 16'd1) : b; 
    wire [16:0] add_result = {1'b0, a} + {1'b0, b_eff} + cin;
    wire [15:0] nand_result = ~(a & b_eff);

    always @(clk) begin
        if (rst) begin
            s = 16'b0;
            c_o = 1'b0;
            comp_o = 1'bZ;
            z_o = 1'b0;
        end else begin
            s = 16'b0;
            c_o = 1'b0;
            comp_o = 1'b0;
            z_o = 1'b0;

            if (op == 3'b000) begin
                // ADD
                s = add_result[15:0];
                c_o = add_result[16];
            end
            else if (op == 3'b001) begin
                // NAND
                s = nand_result;
            end
            else if (op == 3'b010) begin
                // SUB
                {c_o, s} = {1'b0, a} - {1'b0, b};
            end
            else if (op == 3'b011) begin
                // a < b
                comp_o = (a < b) ? 1'b1 : 1'b0;
            end
            else if (op == 3'b100) begin
                // a <= b
                comp_o = (a <= b) ? 1'b1 : 1'b0;
            end
            else begin
                s = 16'b0;
                c_o = 1'b0;
                comp_o = 1'b0;
            end

            if (s == 16'b0)
                z_o = 1'b1;
            else
                z_o = 1'b0;
        end
    end

endmodule
