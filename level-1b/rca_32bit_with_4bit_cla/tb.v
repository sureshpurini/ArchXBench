`timescale 1ns/1ps
module tb_rca_32bit_4bit_cla;
    parameter N = 32;
    parameter TESTS = 50;
    
    reg [N-1:0] A;
    reg [N-1:0] B;
    reg cin;
    wire [N-1:0] sum;
    wire cout;
    
    // Instantiate the 32-bit adder.
    rca_32bit_4bit_cla uut (
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    integer testnum;
    integer pass_count = 0, fail_count = 0;
    reg [N-1:0] expected_sum;
    reg expected_cout;
    reg [32:0] temp;  // 33-bit variable for computing full addition.
    
    initial begin
        #5; // Wait for initialization.
        for (testnum = 0; testnum < TESTS; testnum = testnum + 1) begin
            // Use fixed edge cases for the first 10 tests:
            if (testnum == 0) begin
                A = 32'h00000000; B = 32'h00000000; cin = 0;
            end else if (testnum == 1) begin
                A = 32'hFFFFFFFF; B = 32'h00000000; cin = 0;
            end else if (testnum == 2) begin
                A = 32'h00000000; B = 32'hFFFFFFFF; cin = 0;
            end else if (testnum == 3) begin
                A = 32'h00000001; B = 32'h00000001; cin = 0;
            end else if (testnum == 4) begin
                A = 32'h00000001; B = 32'h00000001; cin = 1;
            end else if (testnum == 5) begin
                A = 32'h7FFFFFFF; B = 32'h00000000; cin = 0;
            end else if (testnum == 6) begin
                A = 32'h7FFFFFFF; B = 32'h7FFFFFFF; cin = 0;
            end else if (testnum == 7) begin
                A = 32'h80000000; B = 32'h80000000; cin = 0;
            end else if (testnum == 8) begin
                A = 32'hAAAAAAAA; B = 32'h55555555; cin = 0;
            end else if (testnum == 9) begin
                A = 32'h12345678; B = 32'h87654321; cin = 1;
            end else begin
                // For remaining tests, assign random values.
                A = $random;
                B = $random;
                cin = $random % 2;
            end
            
            #5;  // Allow time for the combinational adder to settle.
            temp = {1'b0, A} + {1'b0, B} + cin;
            expected_sum = temp[31:0];
            expected_cout = temp[32];
            
            if ((sum === expected_sum) && (cout === expected_cout)) begin
                $display("[PASS] Test %0d: A=%h, B=%h, cin=%b, sum=%h, cout=%b", 
                         testnum, A, B, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: A=%h, B=%h, cin=%b, Expected sum=%h, cout=%b, Got sum=%h, cout=%b", 
                         testnum, A, B, cin, expected_sum, expected_cout, sum, cout);
                fail_count = fail_count + 1;
            end
            #10;
        end
        $display("Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        $finish;
    end

endmodule
