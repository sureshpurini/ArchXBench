`timescale 1ns/1ps

module up_counter8_tb;
    reg clk;
    reg rst;
    wire [7:0] count;
    
    // Instantiate the Unit Under Test (UUT)
    up_counter8 uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );
    
    // Clock generation
    always #5 clk = ~clk;  // 10ns period (100MHz)
    
    // Test variables
    integer i;
    reg test_passed;
    reg [7:0] expected;
    
    // Test sequence
    initial begin
        // Initialize testbench signals
        clk = 0;
        rst = 1;
        test_passed = 1;
        
        // Display header
        $display("Time\t Reset\t Count\t\t Expected\t Status");
        $display("----- \t ----- \t ----- \t -------- \t ------");
        
        // Apply reset for 2 clock cycles
        repeat(2) @(posedge clk);
        
        // Verify reset state
        if (count !== 8'h00) begin
            $display("%0t\t %b\t %h\t\t %h\t\t FAIL - Incorrect reset state", 
                     $time, rst, count, 8'h00);
            test_passed = 0;
        end else begin
            $display("%0t\t %b\t %h\t\t %h\t\t PASS", 
                     $time, rst, count, 8'h00);
        end
        
        // Release reset
        rst = 0;
        
        // Test first 16 values (0-15)
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);  // Wait for rising edge
            #1;  // Small delay to let signals settle
            
            expected = i + 1;  // After reset, we expect 1, 2, 3, etc.
            
            if (count !== expected) begin
                $display("%0t\t %b\t %h\t\t %h\t\t FAIL", 
                         $time, rst, count, expected);
                test_passed = 0;
            end else begin
                $display("%0t\t %b\t %h\t\t %h\t\t PASS", 
                         $time, rst, count, expected);
            end
        end
        
        // Fast-forward to test values near rollover
        // We're at value 16 now, need to get to 254 (238 more cycles)
        repeat(238) @(posedge clk);
        
        // Now we should be at value 254
        expected = 8'hFD;  // 254
        if (count !== expected) begin
            $display("%0t\t %b\t %h\t\t %h\t\t FAIL - Fast-forward incorrect", 
                     $time, rst, count, expected);
            test_passed = 0;
        end else begin
            $display("%0t\t %b\t %h\t\t %h\t\t PASS", 
                     $time, rst, count, expected);
        end
        
        // Test the rollover sequence (254 -> 255 -> 0 -> 1)
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge clk);  // Wait for rising edge
            #1;  // Small delay to let signals settle
            
            // Calculate expected value around the rollover
            case (i)
                0: expected = 8'hFF;  // 255
                1: expected = 8'h00;  // 0 (rollover)
                2: expected = 8'h01;  // 1
            endcase
            
            if (count !== expected) begin
                $display("%0t\t %b\t %h\t\t %h\t\t FAIL - Issue at rollover", 
                         $time, rst, count, expected);
                test_passed = 0;
            end else begin
                $display("%0t\t %b\t %h\t\t %h\t\t PASS", 
                         $time, rst, count, expected);
            end
        end
        
        // Apply reset again and verify reset state
        rst = 1;
        @(posedge clk);  // Wait for rising edge
        #1;  // Small delay to let signals settle
        
        if (count !== 8'h00) begin
            $display("%0t\t %b\t %h\t\t %h\t\t FAIL - Reset not working", 
                     $time, rst, count, 8'h00);
            test_passed = 0;
        end else begin
            $display("%0t\t %b\t %h\t\t %h\t\t PASS", 
                     $time, rst, count, 8'h00);
        end
        
        // Test results summary
        if (test_passed)
            $display("\nTEST PASSED: 8-bit up counter working as expected");
        else
            $display("\nTEST FAILED: Errors detected in 8-bit up counter operation");
        
        // End simulation
        #10;
        $finish;
    end
    
endmodule
