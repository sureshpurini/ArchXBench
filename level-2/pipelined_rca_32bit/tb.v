`timescale 1ns/1ps
module tb_pipelined_rca_32bit;
    parameter N = 32;
    parameter TESTS = 50;
    
    reg clk;
    reg rst;
    reg [N-1:0] A;
    reg [N-1:0] B;
    reg cin;
    wire [N-1:0] sum;
    wire cout;
    
    integer testnum;
    integer pass_count = 0, fail_count = 0;
    reg [N:0] expected; // 33-bit expected result
    
    // Instantiate the pipelined 32-bit RCA.
    pipelined_rca_32bit uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    // Clock generation: period of 10 ns.
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize reset.
        rst = 1;
        A = 0; B = 0; cin = 0;
        #15;
        rst = 0;
        #10;
        
        // Run 50 test cases.
        for (testnum = 0; testnum < TESTS; testnum = testnum + 1) begin
            // First 10 tests: fixed (edge) cases.
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
                // Remaining tests: use random values.
                A = $random;
                B = $random;
                cin = $random % 2;
            end
            
            // Compute expected full result as a 33-bit value
            expected = {1'b0, A} + {1'b0, B} + cin;
            
            // Wait 4 clock cycles to account for pipeline latency.
            repeat (4) @(posedge clk);
            
            // Now compare output.
            if ((sum === expected[31:0]) && (cout === expected[32]))
                begin
                    $display("[PASS] Test %0d: A=%h, B=%h, cin=%b, sum=%h, cout=%b", testnum, A, B, cin, sum, cout);
                    pass_count = pass_count + 1;
                end
            else begin
                    $display("[FAIL] Test %0d: A=%h, B=%h, cin=%b, Expected sum=%h, cout=%b, Got sum=%h, cout=%b", 
                             testnum, A, B, cin, expected[31:0], expected[32], sum, cout);
                    fail_count = fail_count + 1;
            end
            // Pause a few cycles before next test.
            #10;
        end
        
        $display("Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        $finish;
    end

endmodule
