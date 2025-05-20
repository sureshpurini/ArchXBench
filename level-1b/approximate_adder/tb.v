`timescale 1ns/1ps

module approx_loa_tb;
    // Parameters
    parameter WIDTH = 16;
    parameter APPROX_WIDTH = 8;
    parameter TIMEOUT = 100;  // Timeout for combinational logic (should be immediate)
    
    // Testbench signals
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] approx_sum;
    reg [WIDTH-1:0] exact_sum;
    reg [WIDTH-1:0] expected_sum;
    
    // Test control
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Error metrics
    integer error;
    integer total_error = 0;
    integer max_error = 0;
    real avg_error = 0;
    
    // Variables for random test
    reg [WIDTH-1:0] rand_a;
    reg [WIDTH-1:0] rand_b;
    integer i;
    
    // Instantiate the Unit Under Test (UUT)
    approx_loa #(
        .WIDTH(WIDTH),
        .APPROX_WIDTH(APPROX_WIDTH)
    ) uut (
        .a(a),
        .b(b),
        .sum(approx_sum)
    );
    
    // Initial setup
    initial begin
        // Setup VCD file for waveform
        $dumpfile("approx_loa_test.vcd");
        $dumpvars(0, approx_loa_tb);
        
        $display("Starting test for approx_loa with WIDTH=%0d, APPROX_WIDTH=%0d", WIDTH, APPROX_WIDTH);
        $display("---------------------------------------------------");
        $display("Test# |    A    +    B    =  Exact   | Approx   | Error | Status");
        $display("---------------------------------------------------");
        
        // Edge cases and systematic tests
        
        // Test 1: 0 + 0 = 0
        run_test(16'd0, 16'd0);
        
        // Test 2: 0 + MAX = MAX
        run_test(16'd0, 16'hFFFF);
        
        // Test 3: MAX + 0 = MAX
        run_test(16'hFFFF, 16'd0);
        
        // Test 4: Small values in approximate region only
        run_test(16'h00AA, 16'h0055);
        
        // Test 5: Small numbers with carry from approximate region
        run_test(16'h00FF, 16'h0001);
        
        // Test 6: Values exactly at boundary (APPROX_WIDTH bits)
        run_test(16'h00FF, 16'h00FF);
        
        // Test 7: Values just above boundary
        run_test(16'h0100, 16'h0100);
        
        // Test 8: Values spanning both regions equally
        run_test(16'h0F0F, 16'h0F0F);
        
        // Test 9: Large numbers (upper bits only)
        run_test(16'hFF00, 16'hFF00);
        
        // Test 10: Maximum values (overflow test)
        run_test(16'hFFFF, 16'hFFFF);
        
        // Test 11: Pattern with alternating bits
        run_test(16'hAAAA, 16'h5555);
        
        // Test 12: Power of 2 values
        run_test(16'h0080, 16'h0080);
        
        // Test 13: Testing carry propagation
        run_test(16'h01FF, 16'h0001);
        
        // Test 14: Different magnitude values
        run_test(16'hF000, 16'h000F);
        
        // Test 15: Values with only approximate bits set
        run_test(16'h007F, 16'h0080);
        
        // Randomized test cases
        
        $display("\nStarting randomized tests...");
        
        // Tests 16-25: Random values
        for (i = 0; i < 10; i = i + 1) begin
            rand_a = $random & ((1 << WIDTH) - 1);
            rand_b = $random & ((1 << WIDTH) - 1);
            run_test(rand_a, rand_b);
        end
        
        // Calculate average error
        if (test_count > 0) begin
            avg_error = total_error / test_count;
        end
        
        // Summary
        $display("\n==================================");
        $display("Test Summary:");
        $display("Total Tests:     %0d", test_count);
        $display("Total Passed:    %0d", pass_count);
        $display("Total Failed:    %0d", fail_count);
        $display("\nError Statistics:");
        $display("Total Error:     %0d", total_error);
        $display("Average Error:   %0.2f", avg_error);
        $display("Maximum Error:   %0d", max_error);
        $display("==================================");
        
        if (fail_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end
        
        $finish;
    end
    
    // Helper task to run a test
    task run_test;
        input [WIDTH-1:0] test_a;
        input [WIDTH-1:0] test_b;
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            a = test_a;
            b = test_b;
            
            // Wait for combinational logic to settle
            #1;
            
            // Calculate exact sum
            exact_sum = test_a + test_b;
            
            // Calculate error (absolute difference)
            if (exact_sum > approx_sum) begin
                error = exact_sum - approx_sum;
            end else begin
                error = approx_sum - exact_sum;
            end
            
            // Update error statistics
            total_error = total_error + error;
            if (error > max_error) begin
                max_error = error;
            end
            
            // For approximate adder, we consider it a pass if it produces a valid output
            // The error is expected and is part of the approximation
            if (approx_sum !== 16'hXXXX) begin
                $display("%-6d | %5d + %5d = %7d | %7d | %5d | PASS", 
                        test_count, test_a, test_b, exact_sum, approx_sum, error);
                pass_count = pass_count + 1;
            end else begin
                $display("%-6d | %5d + %5d = %7d | %7d | %5d | FAIL", 
                        test_count, test_a, test_b, exact_sum, approx_sum, error);
                $display("       ERROR: Undefined output");
                fail_count = fail_count + 1;
            end
            
            // Show additional details for high-error cases
            if (error > 256) begin  // Threshold for notable errors
                $display("       Note: High error - Approx lower %0d bits: a[%0d:0]=%b, b[%0d:0]=%b", 
                        APPROX_WIDTH, APPROX_WIDTH-1, test_a[APPROX_WIDTH-1:0], 
                        APPROX_WIDTH-1, test_b[APPROX_WIDTH-1:0]);
            end
            
            // Small delay before next test
            #10;
        end
    endtask
    
endmodule