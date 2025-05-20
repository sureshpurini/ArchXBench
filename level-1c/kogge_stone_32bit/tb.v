// tb_ksa_32bit.v
// Testbench for the 32-bit Kogge-Stone Adder (ksa_32bit)
// Drives a series of test vectors and prints pass/fail messages.

`timescale 1ns/1ps

module tb_ksa_32bit;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg        Cin;

    // Outputs
    wire [31:0] Sum;
    wire        Cout;

    // Instantiate the DUT
    ksa_32bit dut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Counters for pass/fail tracking
    integer pass_count = 0;
    integer fail_count = 0;

    // Task to perform a single test case
    task run_test;
        input [31:0] test_A;
        input [31:0] test_B;
        input        test_Cin;
        input [31:0] expected_Sum;
        input        expected_Cout;
        input [127:0] test_label; // for descriptive label
        begin
            A = test_A;
            B = test_B;
            Cin = test_Cin;
            #10; // wait for the combinational logic to settle

            if ((Sum === expected_Sum) && (Cout === expected_Cout))
            begin
                $display("[PASS] %s", test_label);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[FAIL] %s: Expected Sum = 0x%h, Cout = %b; Got Sum = 0x%h, Cout = %b",
                         test_label, expected_Sum, expected_Cout, Sum, Cout);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("Starting 32-bit Kogge-Stone Adder Testbench...");

        // Test 1: 0 + 0, Cin = 0
        run_test(32'h00000000, 32'h00000000, 1'b0, 32'h00000000, 1'b0, "0 + 0, Cin=0");

        // Test 2: 0xFFFFFFFF + 0x00000001, Cin = 0 -> Expected overflow: sum = 0x00000000, Cout = 1
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0, 32'h00000000, 1'b1, "0xFFFFFFFF + 0x00000001, Cin=0");

        // Test 3: 0xAAAAAAAA + 0x55555555, Cin = 0 -> sum = 0xFFFFFFFF, Cout = 0
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0, 32'hFFFFFFFF, 1'b0, "0xAAAAAAAA + 0x55555555, Cin=0");

        // Test 4: 0x12345678 + 0x87654321, Cin = 1 -> Expected: sum = 0x9999999A, Cout = 0
        run_test(32'h12345678, 32'h87654321, 1'b1, 32'h9999999A, 1'b0, "0x12345678 + 0x87654321, Cin=1");

        // Test 5: 0xFFFFFFFF + 0xFFFFFFFF, Cin = 1 -> Expected: sum = 0xFFFFFFFF, Cout = 1
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b1, 32'hFFFFFFFF, 1'b1, "0xFFFFFFFF + 0xFFFFFFFF, Cin=1");

        $display("---------------------------------------------------");
        $display("Testbench Summary: PASS = %0d, FAIL = %0d", pass_count, fail_count);
        $display("---------------------------------------------------");

        $finish;
    end

endmodule
