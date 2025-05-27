`timescale 1ns/1ps

module load_buffer_tb;

  // Inputs
  reg clk, rst;
  reg [3:0] opcode_lsu_i;
  reg [15:0] address_lsu_i;
  reg [15:0] pc_lsu_i;
  reg ext_add_valid_i;
  reg [15:0] data_lsu_i;
  reg data_valid_i;
  reg [2:0] dest_reg_i;

  // Outputs
  wire [15:0] data_out_o;
  wire [2:0] dest_reg_o;
  wire write_enable_o;

  // Instantiate DUT
  load_buffer uut (
    .clk(clk),
    .rst(rst),
    .opcode_lsu_i(opcode_lsu_i),
    .address_lsu_i(address_lsu_i),
    .pc_lsu_i(pc_lsu_i),
    .ext_add_valid_i(ext_add_valid_i),
    .data_lsu_i(data_lsu_i),
    .data_valid_i(data_valid_i),
    .dest_reg_i(dest_reg_i),
    .data_out_o(data_out_o),
    .dest_reg_o(dest_reg_o),
    .write_enable_o(write_enable_o)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns clock period

  // Task to add instruction
  task add_load_instruction(input [3:0] opcode, input [15:0] addr, input [15:0] pc, input [2:0] dest);
    begin
      @(posedge clk);
      opcode_lsu_i = opcode;
      address_lsu_i = addr;
      pc_lsu_i = pc;
      dest_reg_i = dest;
      ext_add_valid_i = 1;
      @(posedge clk);
      ext_add_valid_i = 0;
    end
  endtask

  // Task to send memory data
  task send_data_response(input [15:0] addr, input [15:0] data);
    begin
      @(posedge clk);
      address_lsu_i = addr;
      data_lsu_i = data;
      data_valid_i = 1;
      @(posedge clk);
      data_valid_i = 0;
    end
  endtask

  // Simulation
  initial begin
    // Init
    rst = 1;
    opcode_lsu_i = 0;
    address_lsu_i = 0;
    pc_lsu_i = 0;
    ext_add_valid_i = 0;
    data_lsu_i = 0;
    data_valid_i = 0;
    dest_reg_i = 0;

    // Reset system
    #20;
    rst = 0;

    // Add 3 load instructions
    add_load_instruction(4'b1010, 16'h1234, 16'hAAAA, 3'b101); // Entry 1
    add_load_instruction(4'b1010, 16'h5678, 16'hBBBB, 3'b110); // Entry 2
    add_load_instruction(4'b1010, 16'h9ABC, 16'hCCCC, 3'b111); // Entry 3

    // Simulate memory returning data (non-sequential order)
    #30;
    send_data_response(16'h5678, 16'hBEEF); // Match Entry 2

    #30;
    send_data_response(16'h1234, 16'hDEAD); // Match Entry 1

    #30;
    send_data_response(16'h9ABC, 16'hCAFE); // Match Entry 3

    #20;

    // Observe all outputs
    $display("Final Output -> Data: %h, Dest: %d, WE: %b", data_out_o, dest_reg_o, write_enable_o);

    #20;
    $finish;
  end

endmodule
