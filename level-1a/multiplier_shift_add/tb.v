`timescale 1ns/1ps

module tb_shift_add_mult;
    // Parameters
    parameter WIDTH = 16;
    parameter TIMEOUT = 1000; // Timeout in clock cycles
    
    // Testbench signals
    reg                clk;
    reg                rst;
    reg                start;
    reg                valid_in;
    reg  [WIDTH-1:0]   a;
    reg  [WIDTH-1:0]   b;
    wire [2*WIDTH-1:0] product;
    wire               valid_out;
    wire               done;
    
    // Expected result
    reg [2*WIDTH-1:0] expected_product;
    
    // Test control
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    integer timeout_count;
    
    // Variables for random test
    reg [WIDTH-1:0] rand_a;
    reg [WIDTH-1:0] rand_b;
    reg [2*WIDTH-1:0] exp_prod;
    integer i;
    
    // Instantiate the Device Under Test (DUT)
    shift_add_mult #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .valid_in(valid_in),
        .a(a),
        .b(b),
        .product(product),
        .valid_out(valid_out),
        .done(done)
    );
    
    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initial setup
    initial begin
        // Setup VCD file for waveform
        $dumpfile("shift_add_mult_test.vcd");
        $dumpvars(0, tb_shift_add_mult);
        
        $display("Starting test for shift_add_mult with WIDTH=%0d", WIDTH);
        $display("---------------------------------------------------");
        $display("Test#  |    A    x    B    =  Expected   |  Actual    | Status");
        $display("---------------------------------------------------");
        
        // Initial reset
        rst = 1;
        start = 0;
        valid_in = 0;
        a = 0;
        b = 0;
        #20;
        rst = 0;
        #10;
        
        // Add debug
        $display("Initial state - done=%b, valid_out=%b, busy=%b, count=%0d", 
                 done, valid_out, dut.busy, dut.count);
        
        // Edge cases and systematic tests
        
        // Test 1: 0 x 0 = 0
        run_test(16'd0, 16'd0, 32'd0);
        
        // Test 2: 0 x any = 0
        run_test(16'd0, 16'd12345, 32'd0);
        
        // Test 3: any x 0 = 0
        run_test(16'd5678, 16'd0, 32'd0);
        
        // Test 4: 1 x 1 = 1
        run_test(16'd1, 16'd1, 32'd1);
        
        // Test 5: 1 x any = any
        run_test(16'd1, 16'd1234, 32'd1234);
        
        // Test 6: any x 1 = any
        run_test(16'd5678, 16'd1, 32'd5678);
        
        // Test 7: MAX x 1 = MAX
        run_test(16'hFFFF, 16'd1, 32'd65535);
        
        // Test 8: 1 x MAX = MAX
        run_test(16'd1, 16'hFFFF, 32'd65535);
        
        // Test 9: MAX x MAX = MAX*MAX (overflow case)
        run_test(16'hFFFF, 16'hFFFF, 32'hFFFE0001);
        
        // Test 10: Powers of 2
        run_test(16'd2, 16'd8, 32'd16);
        
        // Test 11: Powers of 2 (larger)
        run_test(16'd256, 16'd256, 32'd65536);
        
        // Test 12: Prime numbers
        run_test(16'd7, 16'd11, 32'd77);
        
        // Test 13: Small values
        run_test(16'd3, 16'd4, 32'd12);
        
        // Test 14: Medium values
        run_test(16'd123, 16'd456, 32'd56088);
        
        // Test 15: Large values near max
        run_test(16'd32768, 16'd2, 32'd65536);
        
        // Randomized test cases
        
        // Generate seed for reproducible random tests
        $display("\nStarting randomized tests...");
        
        // Tests 16-25: Random values
        for (i = 0; i < 10; i = i + 1) begin
            rand_a = $random % (1 << WIDTH);
            rand_b = $random % (1 << WIDTH);
            exp_prod = rand_a * rand_b;
            run_test(rand_a, rand_b, exp_prod);
        end
        
        // Summary
        $display("\n==================================");
        $display("Test Summary:");
        $display("Total Tests:  %0d", test_count);
        $display("Total Passed: %0d", pass_count);
        $display("Total Failed: %0d", fail_count);
        $display("==================================");
        
        if (fail_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end
        
        $finish;
    end
    
    task run_test;
        input [WIDTH-1:0] test_a;
        input [WIDTH-1:0] test_b;
        input [2*WIDTH-1:0] expected;
        reg done_detected;
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            a = test_a;
            b = test_b;
            expected_product = expected;
            
            $display("Starting test %0d: %0d x %0d", test_count, test_a, test_b);
            
            // Start multiplication
            @(posedge clk);
            start = 1;
            valid_in = 1;
            @(posedge clk);
            $display("After start: busy=%b, count=%0d", dut.busy, dut.count);
            start = 0;
            valid_in = 0;
            
            // Wait for completion with timeout
            timeout_count = 0;
            done_detected = 0;
            while (!done_detected && timeout_count < TIMEOUT) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;
                
                // Check if done is asserted
                if (done) begin
                    $display("Done asserted at cycle %0d", timeout_count);
                    done_detected = 1;
                end
                
                if (timeout_count % 10 == 0) begin
                    $display("Waiting... cycle %0d, done=%b, busy=%b", timeout_count, done, dut.busy);
                end
            end
            
            if (timeout_count >= TIMEOUT) begin
                $display("%-6d | %5d x %5d = %10d | TIMEOUT    | FAIL", 
                        test_count, test_a, test_b, expected_product);
                $display("       ERROR: Test timed out after %0d cycles", TIMEOUT);
                $display("       Final state: done=%b, busy=%b, count=%0d", done, dut.busy, dut.count);
                fail_count = fail_count + 1;
            end else begin
                // Wait one more cycle to read the product after done is asserted
                @(posedge clk);
                
                // Verify result
                if (product == expected_product) begin
                    $display("%-6d | %5d x %5d = %10d | %10d | PASS", 
                            test_count, test_a, test_b, expected_product, product);
                    pass_count = pass_count + 1;
                end else begin
                    $display("%-6d | %5d x %5d = %10d | %10d | FAIL", 
                            test_count, test_a, test_b, expected_product, product);
                    $display("       ERROR: Expected %0d, Got %0d", expected_product, product);
                    fail_count = fail_count + 1;
                end
            end
            
            // Small delay before next test
            #10;
        end
    endtask
    
endmodule