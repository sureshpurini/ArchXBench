`timescale 1ns/1ps

module tb_ksa_32bit;

  reg  [31:0] A, B;
  reg         Cin;
  wire [31:0] Sum;
  wire        Cout;

  integer pass_count = 0, fail_count = 0;
  integer i, j, k;
  integer a, b, c;

  // DUT
  ksa_32bit dut (
    .A(A), .B(B), .Cin(Cin),
    .Sum(Sum), .Cout(Cout)
  );

  // Reference computation (33-bit result)
  function [32:0] expected_add;
    input [31:0] A, B;
    input        Cin;
    begin
      expected_add = A + B + Cin;
    end
  endfunction

  task check;
    input [31:0] test_A, test_B;
    input        test_Cin;
    input [127:0] label;
    reg   [32:0] expected;
    begin
      A = test_A;
      B = test_B;
      Cin = test_Cin;
      #1;
      expected = expected_add(test_A, test_B, test_Cin);
      if ({Cout, Sum} === expected) begin
        $display("[PASS] %s", label);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] %s: Expected Sum = 0x%08x, Cout = %b | Got Sum = 0x%08x, Cout = %b",
                  label, expected[31:0], expected[32], Sum, Cout);
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    $display("======== Running 32-bit Kogge-Stone Adder Benchmark Testbench ========");

    // === Directed Tests ===
    check(32'h00000000, 32'h00000000, 1'b0, "Zero + Zero, Cin=0");
    check(32'hFFFFFFFF, 32'h00000001, 1'b0, "Max + 1, Cin=0");
    check(32'hAAAAAAAA, 32'h55555555, 1'b0, "Alternating bits");
    check(32'h12345678, 32'h87654321, 1'b1, "Random + Cin=1");
    check(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b1, "Max + Max + Cin=1");

    // === Exhaustive 4-bit LSB Check ===
    for (a = 0; a < 16; a = a + 1) begin
      for (b = 0; b < 16; b = b + 1) begin
        for (c = 0; c <= 1; c = c + 1) begin
          check(a, b, c, "EXHAUSTIVE LSB test");
        end
      end
    end

    // === Random Tests ===
    for (i = 0; i < 100; i = i + 1) begin
      A = $random;
      B = $random;
      Cin = $random % 2;
      check(A, B, Cin, "Random test");
    end

    $display("=======================================================================");
    $display("PASS = %0d, FAIL = %0d", pass_count, fail_count);
    $display("=======================================================================");
    $finish;
  end

endmodule
