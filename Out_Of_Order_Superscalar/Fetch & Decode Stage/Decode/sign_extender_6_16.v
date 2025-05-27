module sign_extender_6_16(
    input [5:0] in,
    output reg [15:0] out
);
    always @(*) begin
        if (in[5] == 1'b1) begin
            out = {10'b1111111111, in};
        end else begin
            out = {10'b0000000000, in};
        end
    end
endmodule