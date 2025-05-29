`timescale 1ns / 1ps

module tb_pipelined_cla_32bit();
    reg         clk;
    reg         rst;
    reg [31:0]  A;
    reg [31:0]  B;
    reg         cin;
    wire [31:0] sum;
    wire        cout;
    
    // Instantiate the Device Under Test (DUT)
    pipelined_cla_32bit dut(
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    // Clock generation: 10 ns period (5 ns half cycle)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------------------
    // Testcase storage
    // ---------------------------------------------------------------------
    integer i;
    localparam NUM_TESTS = 50;
    
    // Arrays to hold test stimulus and expected results.
    // expected value is computed as 33-bit number {carry, sum}
    reg [31:0] test_A [0:NUM_TESTS-1];
    reg [31:0] test_B [0:NUM_TESTS-1];
    reg        test_cin [0:NUM_TESTS-1];
    reg [32:0] expected [0:NUM_TESTS-1];
    
    integer pass_count, fail_count;

    // ---------------------------------------------------------------------
    // Testbench stimulus and checking
    // ---------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;
        
        // Apply reset
        rst = 1;
        A   = 32'd0;
        B   = 32'd0;
        cin = 0;
        repeat(2) @(negedge clk);
        rst = 0;
        
        // Set up fixed edge cases for first 10 tests:
        // Test 0: 0 + 0, cin = 0
        test_A[0]   = 32'd0;
        test_B[0]   = 32'd0;
        test_cin[0] = 0;
        
        // Test 1: 0 + 0, cin = 1
        test_A[1]   = 32'd0;
        test_B[1]   = 32'd0;
        test_cin[1] = 1;
        
        // Test 2: 0 + 0xFFFFFFFF, cin = 0
        test_A[2]   = 32'd0;
        test_B[2]   = 32'hffffffff;
        test_cin[2] = 0;
        
        // Test 3: 0xFFFFFFFF + 0, cin = 0
        test_A[3]   = 32'hffffffff;
        test_B[3]   = 32'd0;
        test_cin[3] = 0;
        
        // Test 4: 0xFFFFFFFF + 0xFFFFFFFF, cin = 0
        test_A[4]   = 32'hffffffff;
        test_B[4]   = 32'hffffffff;
        test_cin[4] = 0;
        
        // Test 5: 0xFFFFFFFF + 0xFFFFFFFF, cin = 1
        test_A[5]   = 32'hffffffff;
        test_B[5]   = 32'hffffffff;
        test_cin[5] = 1;
        
        // Test 6: 1 + 1, cin = 0
        test_A[6]   = 32'd1;
        test_B[6]   = 32'd1;
        test_cin[6] = 0;
        
        // Test 7: 1 + 1, cin = 1
        test_A[7]   = 32'd1;
        test_B[7]   = 32'd1;
        test_cin[7] = 1;
        
        // Test 8: 0x80000000 + 0x80000000, cin = 0   (check high-bit carry)
        test_A[8]   = 32'h80000000;
        test_B[8]   = 32'h80000000;
        test_cin[8] = 0;
        
        // Test 9: 0x7FFFFFFF + 1, cin = 0
        test_A[9]   = 32'h7fffffff;
        test_B[9]   = 32'd1;
        test_cin[9] = 0;
        
        // Generate random tests for the remaining 40 cases:
        for (i = 10; i < NUM_TESTS; i = i + 1) begin
            test_A[i]   = $random;
            test_B[i]   = $random;
            test_cin[i] = $random % 2;
        end
        
        // Precompute expected results for each test case.
        // The addition is done in 33 bits so that the MSB is the final carry.
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            expected[i] = {1'b0, test_A[i]} + {1'b0, test_B[i]} + test_cin[i];
        end

        // -----------------------------------------------------------------
        // Feed test inputs each clock cycle and check results after 4 cycles.
        // Because the pipelined design has a latency of 4 cycles, when driving
        // test case i, the output corresponds to test case i-4.
        // -----------------------------------------------------------------
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            @(negedge clk);
            A   <= test_A[i];
            B   <= test_B[i];
            cin <= test_cin[i];
            if (i >= 4) begin
                // Check the output for test case (i-4)
                if ({cout, sum} === expected[i-4]) begin
                    $display("[PASS] Test %0d: A=%h, B=%h, cin=%b", 
                             i-4, test_A[i-4], test_B[i-4], test_cin[i-4]);
                    pass_count = pass_count + 1;
                end else begin
                    $display("[FAIL] Test %0d: A=%h, B=%h, cin=%b -> Expected {cout,sum}=%h, Got {cout,sum}=%h",
                             i-4, test_A[i-4], test_B[i-4], test_cin[i-4],
                             expected[i-4], {cout, sum});
                    fail_count = fail_count + 1;
                end
            end
        end
        
        // After all test inputs have been applied, wait an additional 4 cycles
        // to check the final 4 test results from the pipeline.
        for (i = NUM_TESTS; i < NUM_TESTS + 4; i = i + 1) begin
            @(negedge clk);
            if ({cout, sum} === expected[i-4]) begin
                $display("[PASS] Test %0d: A=%h, B=%h, cin=%b", 
                         i-4, test_A[i-4], test_B[i-4], test_cin[i-4]);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: A=%h, B=%h, cin=%b -> Expected {cout,sum}=%h, Got {cout,sum}=%h",
                         i-4, test_A[i-4], test_B[i-4], test_cin[i-4],
                         expected[i-4], {cout, sum});
                fail_count = fail_count + 1;
            end
        end
        
        // Final summary
        $display("-----------------------------------------------------");
        $display("Total Passed: %0d, Total Failed: %0d", pass_count, fail_count);
        $finish;
    end
endmodule
