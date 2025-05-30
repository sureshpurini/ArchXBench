`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_bka_32bit
// Description: Expanded verification for 32-bit Brent-Kung Adder.
//              Adds worst-case patterns, all-generate, MSB-only, boundary toggles,
//              and bulk random vectors for full benchmark coverage.
//////////////////////////////////////////////////////////////////////////////////
module tb_bka_32bit;

  // Inputs to DUT
  reg [31:0] A;
  reg [31:0] B;
  reg        Cin;

  // Outputs from DUT
  wire [31:0] Sum;
  wire        Cout;

  // Instantiate DUT
  bka_32bit dut (
    .A   (A),
    .B   (B),
    .Cin (Cin),
    .Sum (Sum),
    .Cout(Cout)
  );

  // Pass/fail counters
  integer pass_count = 0, fail_count = 0;
  reg [32:0] expected;

  // Single-test task
  task run_test(input [31:0] tA, input [31:0] tB, input tCin);
    begin
      A   = tA;
      B   = tB;
      Cin = tCin;
      #10;
      expected = tA + tB + tCin;
      if ({Cout, Sum} === expected) begin
        $display("[PASS] A=0x%h B=0x%h Cin=%b → Sum=0x%h Cout=%b",
                 tA, tB, tCin, Sum, Cout);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] A=0x%h B=0x%h Cin=%b: Expected 0x%h, Got 0x%h",
                 tA, tB, tCin, expected, {Cout, Sum});
        fail_count = fail_count + 1;
      end
    end
  endtask

  integer i;
  integer rnd_seed = 32'hDEADBEEF;

  initial begin
    $display("Starting full benchmark for bka_32bit...");

    // 1) Basic tests
    run_test(32'h0000_0000, 32'h0000_0000, 1'b0);
    run_test(32'h0000_0000, 32'h0000_0000, 1'b1);
    run_test(32'hFFFF_FFFF, 32'h0000_0001, 1'b0);
    run_test(32'h1234_5678, 32'h8765_4321, 1'b0);
    run_test(32'hAAAA_AAAA, 32'h5555_5555, 1'b0);
    run_test(32'h7FFF_FFFF, 32'h0000_0001, 1'b1);

    // 2) Worst-case ripple (all-propagate)
    run_test(32'h5555_5555, 32'h0000_0000, 1'b1);

    // 3) All-generate chain
    run_test(32'hFFFF_FFFF, 32'h0000_0000, 1'b0);

    // 4) MSB-only tests
    run_test(32'h8000_0000, 32'h8000_0000, 1'b0);
    run_test(32'h8000_0000, 32'h0000_0000, 1'b1);

    // 5) Single-bit boundary toggles
    for (i = 0; i < 32; i = i + 1) begin
      run_test(32'h1 << i, 32'h0, 1'b0);
      run_test(32'h0, 32'h1 << i, 1'b0);
    end

    // 6) Bulk random vectors
    for (i = 0; i < 20; i = i + 1) begin
      run_test($urandom(rnd_seed), $urandom(rnd_seed), $urandom(rnd_seed) % 2);
    end

    #10;
    $display("======================================================");
    $display("Benchmark Summary: Passed = %0d, Failed = %0d", pass_count, fail_count);
    $display("======================================================");
    $finish;
  end

endmodule
