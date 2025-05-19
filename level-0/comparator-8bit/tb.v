`timescale 1ns/1ps
module tb_comparator_8bit;
    reg [7:0] a, b;
    wire eq, gt, lt;
    integer pass_count = 0, fail_count = 0;
    
    comparator_8bit dut (.a(a), .b(b), .eq(eq), .gt(gt), .lt(lt));
    
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
        $display("=== Testing 8-bit Comparator ===");
        
        // Test equality
        a = 8'b01010101; b = 8'b01010101; #10; check_result(1'b1, 1'b0, 1'b0);
        
        // Test upper bits greater
        a = 8'b10100000; b = 8'b01100000; #10; check_result(1'b0, 1'b1, 1'b0);
        
        // Test lower bits greater (upper equal)
        a = 8'b00001010; b = 8'b00000110; #10; check_result(1'b0, 1'b1, 1'b0);
        
        // Test less than
        a = 8'b00010001; b = 8'b00100010; #10; check_result(1'b0, 1'b0, 1'b1);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"comparator_8bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
