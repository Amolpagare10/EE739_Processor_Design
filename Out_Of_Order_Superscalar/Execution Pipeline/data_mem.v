module data_memory (clk, rst, addr, data, valid);
    input clk, rst;
    input [15:0] addr;
    output reg [15:0] data;
    output reg valid;

    reg [15:0] data_mem [0:255];

    initial begin
        data_mem[0] = 16'hAB32;
        data_mem[1] = 16'h41F0;
        data_mem[2] = 16'h0D3C;
        data_mem[3] = 16'hCE09;
        data_mem[4] = 16'h178A;
        data_mem[5] = 16'hFF21;
        data_mem[6] = 16'h00BE;
        data_mem[7] = 16'h7342;
        data_mem[8] = 16'h9213;
        data_mem[9] = 16'h60C5;
        data_mem[10] = 16'hA5A5;
        data_mem[11] = 16'hD33F;
        data_mem[12] = 16'h1004;
        data_mem[13] = 16'hEEEE;
        data_mem[14] = 16'h5A1C;
        data_mem[15] = 16'hBC00;
        data_mem[16] = 16'h9F2D;
        data_mem[17] = 16'hAF21;
        data_mem[18] = 16'h4E3C;
        data_mem[19] = 16'hC7B2;
        data_mem[20] = 16'hFE12;
        data_mem[21] = 16'h8811;
        data_mem[22] = 16'h1122;
        data_mem[23] = 16'h0099;
        data_mem[24] = 16'hABCD;
        data_mem[25] = 16'h7F7F;
        data_mem[26] = 16'h1001;
        data_mem[27] = 16'h1208;
        data_mem[28] = 16'h3456;
        data_mem[29] = 16'h7777;
        data_mem[30] = 16'hFFFF;
        data_mem[31] = 16'hC001;
    end

    always @(posedge clk) begin
        if (rst) begin
            data <= 16'b0;
            valid <= 1'b0;
        end else begin
            data <= data_mem[addr];
            valid <= 1'b1;
        end
        
    end
endmodule

