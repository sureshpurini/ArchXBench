// Testbench for 16-bit Pipelined Wallace Tree Multiplier
// This testbench performs comprehensive testing of the wallace_tree_mult module

`timescale 1ns/1ps

module tb_wallace_tree_mult_pipe();
    // Parameters
    parameter WIDTH = 16;
    parameter PIPELINED = 1;
    
    // Test signals
    reg clk;
    reg rst;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg valid_in;
    wire [2*WIDTH-1:0] product;
    wire valid_out;
    wire done;
    
    // Expected result for verification
    reg [2*WIDTH-1:0] expected_result;
    
    // Instantiate the Pipelined Wallace Tree multiplier
    wallace_tree_mult #(
        .WIDTH(WIDTH),
        .PIPELINED(PIPELINED)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .valid_in(valid_in),
        .product(product),
        .valid_out(valid_out),
        .done(done)
    );
    
    // Test case counter and error counter
    integer test_count = 0;
    integer error_count = 0;
    
    // Clock generation
    always #5 clk = ~clk;  // 10ns period (100MHz)
    
    // Verification task
    task verify_result;
        input [31:0] a_val; // Use 32-bit to accommodate both 16 and 32-bit tests
        input [31:0] b_val;
        reg [WIDTH-1:0] a_test, b_test;
        begin
            // Truncate inputs to actual width
            a_test = a_val[WIDTH-1:0];
            b_test = b_val[WIDTH-1:0];
            
            // Apply inputs at posedge
            @(posedge clk);
            a = a_test;
            b = b_test;
            valid_in = 1'b1;
            expected_result = a_test * b_test;
            
            // Wait one cycle and clear valid_in
            @(posedge clk);
            valid_in = 1'b0;
            
            // Wait for valid_out to be asserted
            while (!valid_out) begin
                @(posedge clk);
            end
            
            // Check result when valid_out is high
            #1; // Small delay for signal settling
            test_count = test_count + 1;
            
            if (product !== expected_result) begin
                $display("ERROR at test %0d: a=%0d, b=%0d, Expected product=%0d, Got product=%0d", 
                         test_count, a_test, b_test, expected_result, product);
                error_count = error_count + 1;
            end else begin
                $display("Test %0d PASSED: a=%0d, b=%0d, product=%0d", 
                         test_count, a_test, b_test, product);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        a = 0;
        b = 0;
        valid_in = 0;
        
        $display("Starting Pipelined Wallace Tree Multiplier Testbench...");
        $display("Configuration:");
        $display("  WIDTH = %0d", WIDTH);
        $display("  PIPELINED = %0d", PIPELINED);
        $display("=====================================\n");
        
        // Apply reset for several cycles
        repeat(5) @(posedge clk);
        rst = 0;
        repeat(2) @(posedge clk);
        
        // Test Case 1: Both inputs zero
        verify_result(32'd0, 32'd0);
        
        // Test Case 2: One input zero
        verify_result(32'd0, 32'd123);
        verify_result(32'd45, 32'd0);
        
        // Test Case 3: Both inputs one
        verify_result(32'd1, 32'd1);
        
        // Test Case 4: Powers of 2
        verify_result(32'd1, 32'd2);
        verify_result(32'd2, 32'd4);
        verify_result(32'd4, 32'd8);
        verify_result(32'd8, 32'd16);
        verify_result(32'd16, 32'd32);
        verify_result(32'd32, 32'd64);
        verify_result(32'd64, 32'd128);
        
        // Test Case 5: Maximum value tests (WIDTH-dependent)
        if (WIDTH == 16) begin
            verify_result(32'd65535, 32'd1);
            verify_result(32'd1, 32'd65535);
            verify_result(32'd65535, 32'd65535);
            verify_result(32'd255, 32'd255);   // 255 x 255
            verify_result(32'd1000, 32'd100);  // 1000 x 100
            verify_result(32'd32767, 32'd2);   // Mid-range x 2
        end else if (WIDTH == 32) begin
            verify_result(32'hFFFFFFFF, 32'd1);
            verify_result(32'd1, 32'hFFFFFFFF);
            verify_result(32'd65535, 32'd65535);        // 65535 x 65535
            verify_result(32'd1000000, 32'd1000);       // 1M x 1K
            verify_result(32'h80000000, 32'd1);         // MSB set x 1
            verify_result(32'h7FFFFFFF, 32'd2);         // Max signed x 2
        end
        
        // Test Case 6: Random value tests (15 random test cases)
        repeat (15) begin
            reg [31:0] rand_a, rand_b;
            
            // Generate random values appropriate for WIDTH
            if (WIDTH == 16) begin
                rand_a = $random & 32'h0000FFFF;
                rand_b = $random & 32'h0000FFFF;
            end else if (WIDTH == 32) begin
                rand_a = $random;
                rand_b = $random;
            end
            
            verify_result(rand_a, rand_b);
        end
        
        // Test Case 7: Sequential values (WIDTH-dependent)
        if (WIDTH == 16) begin
            verify_result(32'd10, 32'd10);
            verify_result(32'd25, 32'd25);
            verify_result(32'd50, 32'd50);
            verify_result(32'd75, 32'd75);
            verify_result(32'd100, 32'd100);
            verify_result(32'd125, 32'd125);
            verify_result(32'd150, 32'd150);
            verify_result(32'd175, 32'd175);
            verify_result(32'd200, 32'd200);
            verify_result(32'd225, 32'd225);
            verify_result(32'd250, 32'd250);
        end else if (WIDTH == 32) begin
            verify_result(32'd1000, 32'd1000);
            verify_result(32'd2500, 32'd2500);
            verify_result(32'd5000, 32'd5000);
            verify_result(32'd7500, 32'd7500);
            verify_result(32'd10000, 32'd10000);
            verify_result(32'd12500, 32'd12500);
            verify_result(32'd15000, 32'd15000);
            verify_result(32'd17500, 32'd17500);
            verify_result(32'd20000, 32'd20000);
            verify_result(32'd22500, 32'd22500);
            verify_result(32'd25000, 32'd25000);
        end
        
        // Test Case 8: Prime numbers (WIDTH-dependent)
        if (WIDTH == 16) begin
            verify_result(32'd2, 32'd3);
            verify_result(32'd5, 32'd7);
            verify_result(32'd11, 32'd13);
            verify_result(32'd17, 32'd19);
            verify_result(32'd23, 32'd29);
            verify_result(32'd31, 32'd37);
            verify_result(32'd41, 32'd43);
            verify_result(32'd47, 32'd53);
        end else if (WIDTH == 32) begin
            verify_result(32'd101, 32'd103);
            verify_result(32'd107, 32'd109);
            verify_result(32'd113, 32'd127);
            verify_result(32'd131, 32'd137);
            verify_result(32'd139, 32'd149);
            verify_result(32'd151, 32'd157);
            verify_result(32'd163, 32'd167);
            verify_result(32'd173, 32'd179);
        end
        
        // Test Case 9: Edge cases (WIDTH-dependent)
        if (WIDTH == 16) begin
            verify_result(32'hAAAA, 32'h5555);  // Alternating bits
            verify_result(32'hFF00, 32'h00FF);  // Complementary patterns
            verify_result(32'h8000, 32'h8000);  // MSB set
        end else if (WIDTH == 32) begin
            verify_result(32'hAAAAAAAA, 32'h55555555);  // Alternating bits
            verify_result(32'hFFFF0000, 32'h0000FFFF);  // Complementary patterns
            verify_result(32'h80000000, 32'h80000000);  // MSB set
            verify_result(32'hFFFFFFFF, 32'hFFFFFFFF);  // All ones
        end
        
        // Print summary
        $display("\n=== Testbench Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed Tests: %0d", test_count - error_count);
        $display("Failed Tests: %0d", error_count);
        
        if (error_count == 0)
            $display("All tests PASSED! The Pipelined Wallace Tree Multiplier is working correctly.");
        else
            $display("Some tests FAILED. The Pipelined Wallace Tree Multiplier needs debugging.");
        
        $finish;
    end
    
    // Generate waveform file for visualization
    initial begin
        $dumpfile("wallace_tree_mult_pipe_tb.vcd");
        $dumpvars(0, tb_wallace_tree_mult_pipe);
    end
    
endmodule