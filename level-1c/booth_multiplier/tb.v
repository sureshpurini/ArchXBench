`timescale 1ns/1ps

module tb_booth_multiplier;
    // Parameters
    parameter N = 8;
    
    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg signed [N-1:0] A;
    reg signed [N-1:0] B;
    wire signed [2*N-1:0] product;
    wire ready;
    reg signed [2*N-1:0] expected_product;
    
    // Instantiate the DUT
    booth_multiplier #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .product(product),
        .ready(ready)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test procedure
    initial begin
        // Setup VCD file for waveform
        $dumpfile("booth_multiplier_test.vcd");
        $dumpvars(0, tb_booth_multiplier);
        
        $display("Starting test for N=%0d (signed %0d-bit multiplier)", N, N);
        $display("-----------------------------------------------------------");
        $display("      A      |      B      |  Expected   |   Actual    | Pass/Fail");
        $display("-----------------------------------------------------------");
        
        // Initial reset
        rst = 1;
        start = 0;
        A = 0;
        B = 0;
        #15;
        rst = 0;
        #10;
        
        // Test case 1: 0 * 0 = 0
        A = 0;
        B = 0;
        expected_product = 0;
        run_test();
        
        // Test case 2: 5 * 0 = 0
        A = 5;
        B = 0;
        expected_product = 0;
        run_test();
        
        // Test case 3: 0 * 5 = 0
        A = 0;
        B = 5;
        expected_product = 0;
        run_test();
        
        // Test case 4: 1 * 1 = 1
        A = 1;
        B = 1;
        expected_product = 1;
        run_test();
        
        // Test case 5: (-1) * (-1) = 1
        A = -1;
        B = -1;
        expected_product = 1;
        run_test();
        
        // Test case 6: 127 * 1 = 127 (max positive * 1)
        A = 127;
        B = 1;
        expected_product = 127;
        run_test();
        
        // Test case 7: 1 * (-128) = -128 (1 * min negative)
        A = 1;
        B = -128;
        expected_product = -128;
        run_test();
        
        // Test case 8: 127 * (-128) = -16256 (max positive * min negative)
        A = 127;
        B = -128;
        expected_product = 127 * (-128);
        run_test();
        
        // Test case 9: (-128) * (-128) = 16384 (min negative * min negative)
        A = -128;
        B = -128;
        expected_product = 16384;
        run_test();
        
        // Test case 10: 50 * (-50) = -2500
        A = 50;
        B = -50;
        expected_product = -2500;
        run_test();
        
        // Random test cases
        $display("\nTesting random values:");
        $display("-----------------------------------------------------------");
        for (integer i = 0; i < 20; i = i + 1) begin
            A = $random;
            B = $random;
            expected_product = A * B;
            run_test();
        end
        
        $display("\nTest completed!");
        $finish;
    end
    
    // Helper task to run a single test
    task run_test;
        begin
            @(negedge clk);
            start = 1;
            @(negedge clk);
            start = 0;
            
            // Wait for multiplication to complete
            wait(ready == 1);
            @(negedge clk);
            
            // Verify and display results
            verify();
            
            // Small delay before next test
            #20;
        end
    endtask
    
    // Helper task to verify and display results
    task verify;
        begin
            $display("  %10d  |  %10d  |  %10d  |  %10d  | %s", 
                    A, 
                    B,
                    expected_product, 
                    product,
                    (product == expected_product) ? "PASS" : "FAIL");
            
            if (product != expected_product) begin
                $display("ERROR: Mismatch detected for A = %0d, B = %0d", A, B);
                $display("       Expected: %0d, Got: %0d", expected_product, product);
            end
        end
    endtask
    
endmodule