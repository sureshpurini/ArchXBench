// tb_cla_8bit.v
`timescale 1ns/1ps
module tb_cla_8bit;

    // Inputs
    reg [7:0] A;
    reg [7:0] B;
    reg       Cin;

    // Outputs
    wire [7:0] Sum;
    wire       Cout;
    
    // Counters for test summary
    integer pass_count;
    integer fail_count;

    // Instantiate the Device Under Test (DUT)
    cla_8bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );
    
    // Task to check the result
    task check(input [7:0] expectedSum, input expectedCout, input [127:0] label);
    begin
        #1; // Allow a small delay for combinational outputs to settle
        if ((Sum === expectedSum) && (Cout === expectedCout)) begin
            $display("[PASS] %s", label);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] %s: Expected Sum = %h, Cout = %b; Got Sum = %h, Cout = %b",
                      label, expectedSum, expectedCout, Sum, Cout);
            fail_count = fail_count + 1;
        end
    end
    endtask

    // Apply test vectors
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Test Case 1: 0 + 0 + 0 = 0 with no carry
        A = 8'h00; B = 8'h00; Cin = 0;
        #5;
        check(8'h00, 0, "0 + 0 + 0");

        // Test Case 2: 1 + 1 + 0 = 2 with no carry
        A = 8'h01; B = 8'h01; Cin = 0;
        #5;
        check(8'h02, 0, "1 + 1 + 0");

        // Test Case 3: 15 + 15 + 0 = 30 with no carry
        A = 8'h0F; B = 8'h0F; Cin = 0;
        #5;
        check(8'h1E, 0, "15 + 15 + 0");

        // Test Case 4: 255 + 1 + 0 = 256 => Sum = 0, Cout = 1 (overflow)
        A = 8'hFF; B = 8'h01; Cin = 0;
        #5;
        check(8'h00, 1, "255 + 1 + 0");

        // Test Case 5: 100 + 28 + 1 = 129 => 8'h81 with no carry-out
        A = 8'h64; B = 8'h1C; Cin = 1;
        #5;
        check(8'h81, 0, "100 + 28 + 1");

        // Test Case 6: 200 + 100 + 1 = 301 => 301 - 256 = 45 (0x2D) with carry out (301 > 255)
        A = 8'd200; B = 8'd100; Cin = 1;
        #5;
        check(8'h2D, 1, "200 + 100 + 1");

        #5;
        // Display final summary
        $display("-------------------------------------------------");
        $display("Test Summary: PASS = %0d, FAILED = %0d", pass_count, fail_count);
        $finish;
    end

endmodule
