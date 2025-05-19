`timescale 1ns/1ps
module tb_comparator_4bit;
    reg [3:0] a, b;
    wire eq, gt, lt;
    integer pass_count = 0, fail_count = 0;
    
    comparator_4bit dut (.a(a), .b(b), .eq(eq), .gt(gt), .lt(lt));
    
    task check_result;
        input expected_eq, expected_gt, expected_lt;
        begin
            if ((eq === expected_eq) && 
                (gt === expected_gt) && 
                (lt === expected_lt)) begin
                pass_count++;
            end else begin
                $display("[FAIL] a=%b, b=%b → eq=%b, gt=%b, lt=%b (Expected: eq=%b, gt=%b, lt=%b)",
                         a, b, eq, gt, lt, expected_eq, expected_gt, expected_lt);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 4-bit Comparator ===");
        
        // Test equality
        a = 4'b0101; b = 4'b0101; #10; check_result(1'b1, 1'b0, 1'b0);
        
        // Test greater than
        a = 4'b1010; b = 4'b0110; #10; check_result(1'b0, 1'b1, 1'b0);
        
        // Test less than
        a = 4'b0011; b = 4'b0111; #10; check_result(1'b0, 1'b0, 1'b1);
        
        // Corner cases
        a = 4'b0000; b = 4'b1111; #10; check_result(1'b0, 1'b0, 1'b1);
        a = 4'b1111; b = 4'b0000; #10; check_result(1'b0, 1'b1, 1'b0);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"comparator_4bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
