`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_bka_32bit
// Description: Testbench for the 32-bit Brent-Kung Adder.
//  - Drives the adder with several test cases.
//  - Prints a consistent output format indicating [PASS] or [FAIL] with details.
//  - Displays a final summary of pass/fail counts.
//////////////////////////////////////////////////////////////////////////////////
module tb_bka_32bit;

    // Inputs for DUT
    reg [31:0] A;
    reg [31:0] B;
    reg        Cin;
    
    // Outputs from DUT
    wire [31:0] Sum;
    wire        Cout;
    
    // Instantiate the Device Under Test (DUT)
    bka_32bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );
    
    // Variables for test result tracking
    integer pass_count = 0, fail_count = 0;
    reg [32:0] expected; // 33-bit expected result (including carry-out)
    
    // Task to run a single test case.
    task run_test;
        input [31:0] ta, tb;
        input tcin;
        begin
            A = ta;
            B = tb;
            Cin = tcin;
            #10; // Wait for combinational signals to settle.
            expected = ta + tb + tcin;
            if ({Cout, Sum} === expected) begin
                $display("[PASS] A = 0x%h, B = 0x%h, Cin = %b, Sum = 0x%h, Cout = %b", ta, tb, tcin, Sum, Cout);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] A = 0x%h, B = 0x%h, Cin = %b: Expected 0x%h, Got 0x%h", ta, tb, tcin, expected, {Cout, Sum});
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // Test sequence
    initial begin
        $display("Starting 32-bit Brent-Kung Adder Tests...");
        
        // Test vector 1: 0 + 0, Cin=0
        run_test(32'h00000000, 32'h00000000, 1'b0);
        // Test vector 2: 0 + 0, Cin=1
        run_test(32'h00000000, 32'h00000000, 1'b1);
        // Test vector 3: Overflow: max value + 1
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0);
        // Test vector 4: Random numbers
        run_test(32'h12345678, 32'h87654321, 1'b0);
        // Test vector 5: Patterned numbers
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0);
        // Test vector 6: Edge case with Cin=1
        run_test(32'h7FFFFFFF, 32'h00000001, 1'b1);
        
        #10;
        $display("==================================================");
        $display("Test Summary: Passed = %0d, Failed = %0d", pass_count, fail_count);
        $display("==================================================");
        $finish;
    end

endmodule
