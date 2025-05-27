`timescale 1ns / 1ps

module alu_tb;

  // Inputs
  reg rst;
  reg complement_bit;
  reg [2:0] op;
  reg [15:0] a, b;
  reg cin;

  // Outputs
  wire [15:0] s;
  wire comp_o;
  wire c_o, z_o;

  // Instantiate the ALU
  alu uut (
    .rst(rst),
    .complement_bit(complement_bit),
    .op(op),
    .a(a),
    .b(b),
    .cin(cin),
    .s(s),
    .comp_o(comp_o),
    .c_o(c_o),
    .z_o(z_o)
  );

  initial begin
      rst = 1;
      complement_bit = 0; cin = 0; op = 3'b000; a = 16'h0000; b = 16'h0000;
      #10;
      rst =0;
    $display("Time\tOP\tCompBit\tCin\tA\t\tB\t\tS\t\tComp_o\tC_o\tZ_o");

    // Test Addition without complement
    complement_bit = 0; cin = 0; op = 3'b000; a = 16'h0005; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test Addition with complement
    complement_bit = 1; cin = 1; op = 3'b000; a = 16'h0005; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test NAND without complement
    complement_bit = 0; op = 3'b001; a = 16'hFFFF; b = 16'h0F0F;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test NAND with complement
    complement_bit = 1; op = 3'b001; a = 16'hFFFF; b = 16'h0F0F;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test Subtraction
    complement_bit = 0; op = 3'b010; a = 16'h0005; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test Less Than
    op = 3'b011; a = 16'h0002; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test Less Than or Equal
    op = 3'b100; a = 16'h0003; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    // Test Less Than or Equal (false)
    op = 3'b100; a = 16'h0004; b = 16'h0003;
    #10 $display("%g\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b", $time, op, complement_bit, cin, a, b, s, comp_o, c_o, z_o);

    $stop;
  end

endmodule
