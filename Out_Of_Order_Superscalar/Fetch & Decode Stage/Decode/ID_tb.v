`timescale 1ns/1ps

module tb_ID_Stage;

    // Inputs
    reg clk, rst;
    reg [15:0] pc1_ID_i, pc2_ID_i;
    reg [15:0] inst1_ID_i, inst2_ID_i;

    // Outputs
    wire [2:0] rd1_ID_o, rd2_ID_o;
    wire [2:0] ra1_ID_o, ra2_ID_o;
    wire [2:0] rb1_ID_o, rb2_ID_o;
    wire [15:0] imm1_ID_o, imm2_ID_o;
    wire complement_bit1_ID_o, complement_bit2_ID_o;
    wire [15:0] jmp1_pc_ID_o, jmp2_pc_ID_o;
    wire [15:0] ret1_pc_ID_o, ret2_pc_ID_o;
    wire [15:0] br1_pc_ID_o, br2_pc_ID_o;
    wire [2:0] jmp1_pc_reg_ID_o, jmp2_pc_reg_ID_o;
    wire [15:0] inst1_ID_o, inst2_ID_o;
    wire [15:0] pc1_ID_o, pc2_ID_o;

    // Instantiate the DUT
    ID_Stage dut (
        .clk(clk), .rst(rst),
        .pc1_ID_i(pc1_ID_i), .pc2_ID_i(pc2_ID_i),
        .inst1_ID_i(inst1_ID_i), .inst2_ID_i(inst2_ID_i),
        .rd1_ID_o(rd1_ID_o), .rd2_ID_o(rd2_ID_o),
        .ra1_ID_o(ra1_ID_o), .ra2_ID_o(ra2_ID_o),
        .rb1_ID_o(rb1_ID_o), .rb2_ID_o(rb2_ID_o),
        .imm1_ID_o(imm1_ID_o), .imm2_ID_o(imm2_ID_o),
        .complement_bit1_ID_o(complement_bit1_ID_o), .complement_bit2_ID_o(complement_bit2_ID_o),
        .jmp1_pc_ID_o(jmp1_pc_ID_o), .jmp2_pc_ID_o(jmp2_pc_ID_o),
        .ret1_pc_ID_o(ret1_pc_ID_o), .ret2_pc_ID_o(ret2_pc_ID_o),
        .br1_pc_ID_o(br1_pc_ID_o), .br2_pc_ID_o(br2_pc_ID_o),
        .jmp1_pc_reg_ID_o(jmp1_pc_reg_ID_o), .jmp2_pc_reg_ID_o(jmp2_pc_reg_ID_o),
        .inst1_ID_o(inst1_ID_o), .inst2_ID_o(inst2_ID_o),
        .pc1_ID_o(pc1_ID_o), .pc2_ID_o(pc2_ID_o)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to print instruction decoding results
    task display_outputs;
        begin
            $display("Time: %0t", $time);
            $display("  inst1: %h | PC: %h | rd: %b | ra: %b | rb: %b | imm: %h | comp: %b", inst1_ID_o, pc1_ID_o, rd1_ID_o, ra1_ID_o, rb1_ID_o, imm1_ID_o, complement_bit1_ID_o);
            $display("  inst2: %h | PC: %h | rd: %b | ra: %b | rb: %b | imm: %h | comp: %b", inst2_ID_o, pc2_ID_o, rd2_ID_o, ra2_ID_o, rb2_ID_o, imm2_ID_o, complement_bit2_ID_o);
        end
    endtask

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        pc1_ID_i = 16'h0000;
        pc2_ID_i = 16'h0002;
        inst1_ID_i = 16'h0000;
        inst2_ID_i = 16'h0000;

        #10 rst = 0;

        // ALU Test (opcode = 0000)
        inst1_ID_i = 16'b0000001010011000; // Dummy ALU instruction
        inst2_ID_i = 16'b0001100101110100;
        pc1_ID_i = 16'h0100;
        pc2_ID_i = 16'h0102;
        #10 display_outputs;

        // Branch Test (opcode = 1000)
        inst1_ID_i = 16'b1000001010000011; // Dummy Branch instruction
        inst2_ID_i = 16'b1001011100000000;
        pc1_ID_i = 16'h0200;
        pc2_ID_i = 16'h0202;
        #10 display_outputs;

        // Jump Test (opcode = 1100)
        inst1_ID_i = 16'b1100001000000111; // Dummy Jump instruction
        inst2_ID_i = 16'b1111010000000111;
        pc1_ID_i = 16'h0300;
        pc2_ID_i = 16'h0302;
        #10 display_outputs;
        
        #20;
        rst =1;
        #20;
        rst = 0;

        // LLI, LW, SW (opcode = 0100)
        // inst1_ID_i = 16'b0100000011000011; // Dummy LW
        inst1_ID_i = 16'b0011001000000011; // Dummy LLI
        inst2_ID_i = 16'b0101110100000010; // Dummy SW
        pc1_ID_i = 16'h0400;
        pc2_ID_i = 16'h0402;
        #10 display_outputs;

        // LM/SM Instructions (opcode = 0110)
        inst1_ID_i = 16'b0110000001000000;
        inst2_ID_i = 16'b0111010011000000;
        pc1_ID_i = 16'h0500;
        pc2_ID_i = 16'h0502;
        #50 display_outputs;

        // Invalid opcode
        inst1_ID_i = 16'b1110000000000000; // invalid
        inst2_ID_i = 16'b1110000000000000; // invalid
        pc1_ID_i = 16'h0600;
        pc2_ID_i = 16'h0602;
        #10 display_outputs;

        $finish;
    end
endmodule
