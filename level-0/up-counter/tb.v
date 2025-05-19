`timescale 1ns/1ps
module tb_binary_up_counter_4bit;
    reg clk, rst;
    wire [3:0] count;
    integer pass_count = 0, fail_count = 0;
    
    binary_up_counter_4bit dut (.clk(clk), .rst(rst), .count(count));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task check_result;
        input [3:0] expected;
        begin
            @(negedge clk);
            if (count === expected) pass_count++;
            else begin
                $display("[FAIL] Expected=%b, Got=%b", expected, count);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 4-bit Binary Up Counter ===");
        
        // Test reset
        rst = 1; #20;
        check_result(4'b0000);
        rst = 0;
        
        // Test counting sequence
        check_result(4'b0001);
        check_result(4'b0010);
        check_result(4'b0011);
        
        // Fast-forward to rollover
        repeat(13) @(posedge clk);
        check_result(4'b0000);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"binary_up_counter_4bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
