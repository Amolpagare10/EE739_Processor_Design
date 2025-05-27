`timescale 1ns/1ps

module IF_stage_tb;

    reg clk;
    reg rst;
    reg fetch_stall_i;
    reg rs_full_i;
    reg [15:0] pc_c_IF_i;
    reg pc_en_c_IF_i;

    wire [15:0] pc1_IF_o;
    wire [15:0] pc2_IF_o;
    wire [15:0] inst1_IF_o;
    wire [15:0] inst2_IF_o;

    // Instantiate IF_stage
    IF_stage uut (
        .clk(clk),
        .rst(rst),
        .fetch_stall_i(fetch_stall_i),
        .rs_full_i(rs_full_i),
        .pc_c_IF_i(pc_c_IF_i),
        .pc_en_c_IF_i(pc_en_c_IF_i),
        .pc1_IF_o(pc1_IF_o),
        .pc2_IF_o(pc2_IF_o),
        .inst1_IF_o(inst1_IF_o),
        .inst2_IF_o(inst2_IF_o)
    );

    // Generate clock
    always #30 clk = ~clk;

    // Test sequence
    initial begin
        $display("Starting test...");
        clk = 0;
        rst = 1;
        fetch_stall_i = 0;
        rs_full_i = 0;
        pc_c_IF_i = 16'h0004;
        pc_en_c_IF_i = 0;

        #10; // Apply reset
        rst = 0;

        // Test: Without enabling pc update, output should not change
        #10;
        $display("Without pc_en_c_IF_i:");
        $display("PC1: %h, PC2: %h, INST1: %h, INST2: %h", pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o);
        
        #310;
        // Test: Enable PC update
        pc_en_c_IF_i = 1;
        #20;
        pc_en_c_IF_i = 0;
        $display("With pc_en_c_IF_i:");
        $display("PC1: %h, PC2: %h, INST1: %h, INST2: %h", pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o);

        // Test: Stall fetch
        fetch_stall_i = 0;
        #10;
        $display("With fetch_stall_i:");
        $display("PC1: %h, PC2: %h, INST1: %h, INST2: %h", pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o);

        // Resume fetch
        fetch_stall_i = 0;
        pc_en_c_IF_i = 0;
        #10;
        $display("Resume fetch:");
        $display("PC1: %h, PC2: %h, INST1: %h, INST2: %h", pc1_IF_o, pc2_IF_o, inst1_IF_o, inst2_IF_o);

        $stop;
    end

endmodule
