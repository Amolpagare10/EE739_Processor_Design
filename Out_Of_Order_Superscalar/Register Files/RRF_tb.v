`timescale 1ns / 1ps

module rename_register_file_tb;

    // Inputs
    reg clk;
    reg rst;
    reg we;
    reg [5:0] write_tag;
    reg [15:0] write_data;
    reg busy_set;
    reg [5:0] busy_tag;
    reg [5:0] read_tag;

    // Outputs
    wire [15:0] read_data;
    wire read_valid;
    wire read_busy;
    wire broadcast_valid;
    wire [5:0] broadcast_tag;
    wire [15:0] broadcast_data;

    // Instantiate the module under test
    rename_register_file uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .write_tag(write_tag),
        .write_data(write_data),
        .busy_set(busy_set),
        .busy_tag(busy_tag),
        .read_tag(read_tag),
        .read_data(read_data),
        .read_valid(read_valid),
        .read_busy(read_busy),
        .broadcast_valid(broadcast_valid),
        .broadcast_tag(broadcast_tag),
        .broadcast_data(broadcast_data)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("Starting RRF Testbench...");
        $dumpfile("rrf_tb.vcd");
        $dumpvars(0, rename_register_file_tb);

        // Initialize Inputs
        clk = 0;
        rst = 1;
        we = 0;
        write_tag = 0;
        write_data = 0;
        busy_set = 0;
        busy_tag = 0;
        read_tag = 0;

        // Apply reset
        #10;
        rst = 0;

        // Test 1: Write to tag 10
        @(posedge clk);
        we = 1;
        write_tag = 6'd10;
        write_data = 16'hABCD;

        @(posedge clk);
        we = 0;

        // Test 2: Check broadcast
        if (broadcast_valid && broadcast_tag == 6'd10 && broadcast_data == 16'hABCD)
            $display("PASS: Broadcast correct");
        else
            $display("FAIL: Broadcast incorrect");

        // Test 3: Set busy for tag 10
        @(posedge clk);
        busy_set = 1;
        busy_tag = 6'd10;

        @(posedge clk);
        busy_set = 0;

        // Test 4: Read from tag 10
        #2;
        read_tag = 6'd10;
        #1;
        if (read_data == 16'hABCD && read_valid == 1 && read_busy == 1)
            $display("PASS: Read correct data, valid and busy");
        else
            $display("FAIL: Read incorrect for tag 10");

        // Test 5: Write to tag 12 and don't set busy
        @(posedge clk);
        we = 1;
        write_tag = 6'd12;
        write_data = 16'hDEAD;
        @(posedge clk);
        we = 0;

        // Read from tag 12
        #2;
        read_tag = 6'd12;
        #1;
        if (read_data == 16'hDEAD && read_valid == 1 && read_busy == 0)
            $display("PASS: Read correct data, not busy");
        else
            $display("FAIL: Read incorrect for tag 12");

        // Test 6: Out-of-bounds read
        read_tag = 6'd60;
        #1;
        if (read_data == 16'b0 && read_valid == 0 && read_busy == 0)
            $display("PASS: Out-of-bounds read correctly handled");
        else
            $display("FAIL: Out-of-bounds read failed");

        #10;
        $display("Testbench finished.");
        $finish;
    end

endmodule

