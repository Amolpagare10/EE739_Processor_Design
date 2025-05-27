`timescale 1ns / 1ps

module tb_architectural_register_file;

    // Inputs
    reg clk;
    reg rst;
    reg rename_en;
    reg [2:0] rename_addr;
    reg [5:0] rename_tag;
    reg write_en;
    reg [2:0] write_addr;
    reg [15:0] write_data;
    reg [2:0] read_addr;

    // Outputs
    wire [15:0] read_data;
    wire read_busy;
    wire [5:0] read_tag;

    // Instantiate the DUT
    ARF dut (
        .clk(clk),
        .rst(rst),
        .rename_en(rename_en),
        .rename_addr(rename_addr),
        .rename_tag(rename_tag),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr(read_addr),
        .read_data(read_data),
        .read_busy(read_busy),
        .read_tag(read_tag)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to read and display state of a register
    task read_and_display(input [2:0] addr);
        begin
            read_addr = addr;
            #1;
            $display("READ R%0d => busy: %b, tag: %d, data: 0x%04h", addr, read_busy, read_tag, read_data);
        end
    endtask

    integer i;

    // Test procedure
    initial begin
        $display("==== Starting ARF Extensive Test ====");
        clk = 0;
        rst = 1;
        rename_en = 0;
        write_en = 0;
        rename_addr = 0;
        rename_tag = 0;
        write_addr = 0;
        write_data = 0;
        read_addr = 0;

        // Reset and wait
        #10;
        rst = 0;
        #5;

        // Check all registers after reset
        $display("After reset:");
        for (i = 0; i < 8; i = i + 1) begin
            read_and_display(i);
        end

        // Rename multiple registers
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            rename_en = 1;
            rename_addr = i;
            rename_tag = 6'd10 + i;
        end
        @(posedge clk);
        rename_en = 0;

        $display("\nAfter renaming R0-R3:");
        for (i = 0; i < 4; i = i + 1) begin
            read_and_display(i);
        end

        // Writeback to R1 and R3
        @(posedge clk);
        write_en = 1;
        write_addr = 1;
        write_data = 16'hAAAA;
        @(posedge clk);
        write_en = 1;
        write_addr = 3;
        write_data = 16'h3333;
        @(posedge clk);
        write_en = 0;

        $display("\nAfter writeback to R1 and R3:");
        read_and_display(1);
        read_and_display(3);

        // Writeback to a register that was not renamed (R6)
        @(posedge clk);
        write_en = 1;
        write_addr = 6;
        write_data = 16'hBEEF;
        @(posedge clk);
        write_en = 0;

        $display("\nWriteback to R6 (not renamed):");
        read_and_display(6);

        // Simultaneous rename and writeback
        @(posedge clk);
        rename_en = 1;
        rename_addr = 5;
        rename_tag = 6'd42;
        write_en = 1;
        write_addr = 0;
        write_data = 16'hDEAD;
        @(posedge clk);
        rename_en = 0;
        write_en = 0;

        $display("\nSimultaneous rename R5 and writeback R0:");
        read_and_display(0);
        read_and_display(5);

        $display("\nFinal state of all registers:");
        for (i = 0; i < 8; i = i + 1) begin
            read_and_display(i);
        end

        $display("==== End of ARF Test ====");
        $stop;
    end

endmodule
