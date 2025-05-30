`timescale 1ns/1ps
module tb_gray_counter8;
    reg clk, rst;
    wire [7:0] count;
    integer pass_count = 0, fail_count = 0;
    
    gray_counter8 dut (.clk(clk), .rst(rst), .count(count));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    function automatic int count_ones;
        input [7:0] val;
        begin
            count_ones = 0;
            for (int i = 0; i < 8; i = i + 1)
                count_ones = count_ones + val[i];
        end
    endfunction
    
    task check_gray_property;
        input [7:0] prev;
        begin
            @(negedge clk);
            if (count_ones(prev ^ count) <= 1) pass_count++;
            else begin
                $display("[FAIL] Gray violation: %b → %b", prev, count);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 8-bit Gray Code Counter ===");
        
        // Test reset
        rst = 1; #20;
        if (count === 8'b0000_0000) pass_count++;
        else begin
            $display("[FAIL] Reset: Expected 00000000, Got %b", count);
            fail_count++;
        end
        rst = 0;
        
        // Verify Gray code property for 32 cycles (partial test)
        repeat(32) begin
            reg [7:0] prev_count = count;
            @(posedge clk);
            check_gray_property(prev_count);
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"gray_counter8\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
