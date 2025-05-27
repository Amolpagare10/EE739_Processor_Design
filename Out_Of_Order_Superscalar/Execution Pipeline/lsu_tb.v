`timescale 1ns/1ps

module lsu_tb;

  // Inputs
  reg clk, rst;
  reg [2:0] ra_lsu_i, rb_lsu_i;
  reg [15:0] imm_lsu_i;
  reg [3:0] opcode_lsu_i;
  reg [15:0] pc_lsu_i;
  reg [2:0] dest_reg_i;
  reg [15:0] regfile_data_ra;

  // Outputs
  wire [15:0] data_out_o;
  wire [2:0] dest_reg_o;
  wire write_enable_o;

  // Instantiate DUT
  lsu dut (
    .clk(clk),
    .rst(rst),
    .ra_lsu_i(ra_lsu_i),
    .rb_lsu_i(rb_lsu_i),
    .imm_lsu_i(imm_lsu_i),
    .opcode_lsu_i(opcode_lsu_i),
    .pc_lsu_i(pc_lsu_i),
    .regfile_data_ra(regfile_data_ra),
    .dest_reg_i(dest_reg_i),
    .data_out_o(data_out_o),
    .dest_reg_o(dest_reg_o),
    .write_enable_o(write_enable_o)
  );

  // Clock Generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period

  initial begin
    // Initialize
    rst = 1;
    ra_lsu_i = 3'b000;
    rb_lsu_i = 3'b000;
    imm_lsu_i = 16'd0;
    opcode_lsu_i = 4'b0000;
    pc_lsu_i = 16'd0;
    dest_reg_i = 3'b000;
    regfile_data_ra = 16'd0;

    #20;
    rst = 0;

    // ---- Issue First Lw ----
    #20;
    ra_lsu_i = 3'b001;
    regfile_data_ra = 16'd10; // Assume reg[ra] = 10
    imm_lsu_i = 16'd5;        // effective address = 15
    opcode_lsu_i = 4'b0100;   // Lw
    pc_lsu_i = 16'hA001;
    dest_reg_i = 3'b010;

    // ---- Issue Second Lw ----
    #40;
    ra_lsu_i = 3'b010;
    regfile_data_ra = 16'd20;
    imm_lsu_i = 16'd4;        // effective address = 24
    opcode_lsu_i = 4'b0100;   // Lw
    pc_lsu_i = 16'hA002;
    dest_reg_i = 3'b011;

    // ---- Issue LLI ----
    #40;
    ra_lsu_i = 3'b000;        // not used for LLI
    imm_lsu_i = 16'd23;     // immediate value to be interpreted
    opcode_lsu_i = 4'b0011;   // LLI
    pc_lsu_i = 16'hA003;
    dest_reg_i = 3'b100;

    // Wait for pipeline to progress
    #100;

    $display("Final outputs:");
    $display("Time: %0t | Data: %h | Dest: %d | WE: %b", $time, data_out_o, dest_reg_o, write_enable_o);

    #50;
    $finish;
  end

endmodule
