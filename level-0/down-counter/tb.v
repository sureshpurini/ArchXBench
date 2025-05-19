`timescale 1ns/1ps
module tb_loadable_down_counter_8bit;
    reg clk, rst, load, enable;
    reg [7:0] data_in;
    wire [7:0] count;
    wire tc;
    integer pass_count = 0, fail_count = 0;
    
    loadable_down_counter_8bit dut (
        .clk(clk), .rst(rst),
        .load(load), .enable(enable),
        .data_in(data_in), .count(count), .tc(tc)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task check_result;
        input [7:0] expected_count;
        input expected_tc;
        begin
            @(negedge clk);
            if (count === expected_count && tc === expected_tc) pass_count++;
            else begin
                $display("[FAIL] Expected=%b (tc=%b), Got=%b (tc=%b)",
                         expected_count, expected_tc, count, tc);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 8-bit Loadable Down Counter ===");
        
        // Test reset
        rst = 1; enable = 0; load = 0; #20;
        check_result(8'b00000000, 1'b1);
        rst = 0;
        
        // Test load
        data_in = 8'b00000101; load = 1; #10;
        load = 0; enable = 1;
        check_result(8'b00000101, 1'b0);
        
        // Test countdown
        check_result(8'b00000100, 1'b0);
        check_result(8'b00000011, 1'b0);
        
        // Test terminal count
        repeat(3) @(posedge clk);
        check_result(8'b00000000, 1'b1);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"loadable_down_counter_8bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
