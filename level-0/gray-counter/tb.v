`timescale 1ns/1ps
module tb_gray_counter_4bit;
    reg clk, rst;
    wire [3:0] gray_count;
    integer pass_count = 0, fail_count = 0;
    
    gray_counter_4bit dut (.clk(clk), .rst(rst), .gray_count(gray_count));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    function automatic int count_ones;
        input [3:0] val;
        count_ones = val[0] + val[1] + val[2] + val[3];
    endfunction
    
    task check_gray_property;
        input [3:0] prev;
        begin
            @(negedge clk);
            if (count_ones(prev ^ gray_count) <= 1) pass_count++;
            else begin
                $display("[FAIL] Gray violation: %b → %b", prev, gray_count);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 4-bit Gray Code Counter ===");
        
        // Test reset
        rst = 1; #20;
        if (gray_count === 4'b0000) pass_count++;
        else begin
            $display("[FAIL] Reset: Expected 0000, Got %b", gray_count);
            fail_count++;
        end
        rst = 0;
        
        // Verify Gray code property for 16 cycles
        repeat(16) begin
            check_gray_property(gray_count);
            @(posedge clk);
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"gray_counter_4bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
