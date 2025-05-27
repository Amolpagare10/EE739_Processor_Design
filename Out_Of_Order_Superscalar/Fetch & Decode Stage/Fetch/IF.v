module IF_stage(clk, rst, fetch_stall_i, rs_full_i, pc_c_IF_i, pc_en_c_IF_i,
                pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o);
    input clk;
    input rst; // Active high
    input fetch_stall_i; // From decoder
    input rs_full_i;     // From RS
    input [15:0] pc_c_IF_i; // new PC from decoder/controller
    input pc_en_c_IF_i;     // enable from controller
    
    output reg [15:0] pc1_IF_o; // To decoder
    output reg [15:0] pc2_IF_o; // To decoder
    output reg [15:0] inst1_IF_o; // To decoder
    output reg [15:0] inst2_IF_o;  // To decoder

    reg [15:0] pc;                  // Internal PC register
    reg [15:0] inst_mem [0:255];    // 256 x 16-bit icache

    wire stall = fetch_stall_i || rs_full_i;

    // Instruction memory 
    initial begin
        inst_mem[0] = 16'hAB32;
        inst_mem[1] = 16'h41F0;
        inst_mem[2] = 16'h0D3C;
        inst_mem[3] = 16'hCE09;
        inst_mem[4] = 16'h178A;
        inst_mem[5] = 16'hFF21;
        inst_mem[6] = 16'h00BE;
        inst_mem[7] = 16'h7342;
        inst_mem[8] = 16'h9213;
        inst_mem[9] = 16'h60C5;
        inst_mem[10] = 16'hA5A5;
        inst_mem[11] = 16'hD33F;
        inst_mem[12] = 16'h1004;
        inst_mem[13] = 16'hEEEE;
        inst_mem[14] = 16'h5A1C;
        inst_mem[15] = 16'hBC00;
        inst_mem[16] = 16'h9F2D;
        inst_mem[17] = 16'hAF21;
        inst_mem[18] = 16'h4E3C;
        inst_mem[19] = 16'hC7B2;
        inst_mem[20] = 16'hFE12;
        inst_mem[21] = 16'h8811;
        inst_mem[22] = 16'h1122;
        inst_mem[23] = 16'h0099;
        inst_mem[24] = 16'hABCD;
        inst_mem[25] = 16'h7F7F;
        inst_mem[26] = 16'h1001;
        inst_mem[27] = 16'h1208;
        inst_mem[28] = 16'h3456;
        inst_mem[29] = 16'h7777;
        inst_mem[30] = 16'hFFFF;
        inst_mem[31] = 16'hC001;
    end

    // Instruction Fetch Logic
    always @(posedge clk or posedge rst) begin
        if (rst) 
        begin
            pc <= 16'h0000;
            inst1_IF_o <= 16'h0000;
            inst2_IF_o <= 16'h0000;
            pc1_IF_o <= 16'h0000;
            pc2_IF_o <= 16'h0000;
        end 
        else if (!stall) 
        begin
            if (pc_en_c_IF_i)
                pc <= pc_c_IF_i;
            else
                pc <= pc + 16'd2;
            inst1_IF_o <= inst_mem[pc[5:0]];
            inst2_IF_o <= inst_mem[pc[5:0] + 1];
            pc1_IF_o <= pc;
            pc2_IF_o <= pc + 16'd1;
        end
        else 
        begin
            // If stall, retain previous values
            pc <= pc; 
            inst1_IF_o <= inst1_IF_o; 
            inst2_IF_o <= inst2_IF_o; 
            pc1_IF_o <= pc1_IF_o; 
            pc2_IF_o <= pc2_IF_o; 
        end
    end
endmodule
