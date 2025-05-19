`timescale 1ns/1ps
module tb_siso_8bit;
    reg clk, rst, sin;
    wire sout;
    integer pass_count = 0, fail_count = 0;
    
    siso_8bit dut (.clk(clk), .rst(rst), .sin(sin), .sout(sout));
    
    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task check_result;
        input expected;
        integer cycle;
        begin
            
            @(negedge clk); // Wait for stable output
            
            if (sout === expected) begin
                pass_count++;
            end else begin
                $display("[FAIL] Expected=%b, Got=%b", expected, sout);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 8-bit SISO ===");
        
        // Reset
        rst = 1; sin = 0;
        #10; rst = 0;
        
        // Test data stream (LSB first)
        sin = 1; #10; // Bit 0
        sin = 0; #10; // Bit 1
        sin = 1; #10; // Bit 2
        sin = 0; #10; // Bit 3
        sin = 1; #10; // Bit 4
        sin = 0; #10; // Bit 5
        sin = 1; #10; // Bit 6
        sin = 1; #10; // Bit 7
        
        // Verify output (should be 10101001)
        check_result(1); // First bit out (1)
        check_result(0); // Second bit out (0)
        check_result(1); // Third bit out (1)
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"siso_8bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
