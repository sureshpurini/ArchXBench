// Testbench for 8-bit Wallace Tree Multiplier
// This testbench performs comprehensive testing of the wallace_tree_mult module

`timescale 1ns/1ps

module tb_wallace_tree_mult();
    // Parameters
    parameter WIDTH = 8;
    
    // Test signals
    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    wire [2*WIDTH-1:0] Y;
    
    // Expected result for verification
    reg [2*WIDTH-1:0] expected_result;
    
    // Instantiate the Wallace tree multiplier
    wallace_tree_mult DUT (
        .A(A),
        .B(B),
        .Y(Y)
    );
    
    // Test case counter and error counter
    integer test_count = 0;
    integer error_count = 0;
    
    // Verification task
    task verify_result;
        input [WIDTH-1:0] a_val;
        input [WIDTH-1:0] b_val;
        begin
            A = a_val;
            B = b_val;
            expected_result = a_val * b_val;
            
            // Allow time for computation
            #10;
            
            // Increment test counter
            test_count = test_count + 1;
            
            // Check result
            if (Y !== expected_result) begin
                $display("ERROR at test %0d: A=%0d, B=%0d, Expected Y=%0d, Got Y=%0d", 
                         test_count, A, B, expected_result, Y);
                error_count = error_count + 1;
            end else begin
                $display("Test %0d PASSED: A=%0d, B=%0d, Y=%0d", 
                         test_count, A, B, Y);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("Starting Wallace Tree Multiplier Testbench...");
        
        // Test Case 1: Both inputs zero
        verify_result(8'd0, 8'd0);
        
        // Test Case 2: One input zero
        verify_result(8'd0, 8'd123);
        verify_result(8'd45, 8'd0);
        
        // Test Case 3: Both inputs one
        verify_result(8'd1, 8'd1);
        
        // Test Case 4: Powers of 2
        verify_result(8'd1, 8'd2);
        verify_result(8'd2, 8'd4);
        verify_result(8'd4, 8'd8);
        verify_result(8'd8, 8'd16);
        verify_result(8'd16, 8'd32);
        verify_result(8'd32, 8'd64);
        verify_result(8'd64, 8'd128);
        
        // Test Case 5: Maximum value tests
        verify_result(8'd255, 8'd1);
        verify_result(8'd1, 8'd255);
        verify_result(8'd255, 8'd255);
        
        // Test Case 6: Boundary values
        verify_result(8'd127, 8'd127);  // Middle value
        verify_result(8'd128, 8'd128);  // 2^7
        verify_result(8'd254, 8'd254);  // Near maximum
        
        // Test Case 7: Random value tests (15 random test cases)
        repeat (15) begin
            verify_result($random & 8'hFF, $random & 8'hFF);
        end
        
        // Test Case 8: Sequential values
        verify_result(8'd10, 8'd10);
        verify_result(8'd25, 8'd25);
        verify_result(8'd50, 8'd50);
        verify_result(8'd75, 8'd75);
        verify_result(8'd100, 8'd100);
        verify_result(8'd125, 8'd125);
        verify_result(8'd150, 8'd150);
        verify_result(8'd175, 8'd175);
        verify_result(8'd200, 8'd200);
        verify_result(8'd225, 8'd225);
        verify_result(8'd250, 8'd250);
        
        // Test Case 9: Prime numbers
        verify_result(8'd2, 8'd3);
        verify_result(8'd5, 8'd7);
        verify_result(8'd11, 8'd13);
        verify_result(8'd17, 8'd19);
        verify_result(8'd23, 8'd29);
        verify_result(8'd31, 8'd37);
        verify_result(8'd41, 8'd43);
        verify_result(8'd47, 8'd53);
        
        // Test Case 10: Mixed bit patterns
        verify_result(8'b10101010, 8'b01010101);  // Alternating bits
        verify_result(8'b11110000, 8'b00001111);  // Half-half pattern
        verify_result(8'b11001100, 8'b00110011);  // Alternating pairs
        verify_result(8'b11111111, 8'b10000001);  // All ones × min with MSB set
        
        // Print summary
        $display("\n=== Testbench Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed Tests: %0d", test_count - error_count);
        $display("Failed Tests: %0d", error_count);
        
        if (error_count == 0)
            $display("All tests PASSED! The Wallace Tree Multiplier is working correctly.");
        else
            $display("Some tests FAILED. The Wallace Tree Multiplier needs debugging.");
        
        $finish;
    end
    
endmodule