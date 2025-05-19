`timescale 1ns/1ps
module tb_sipo_8bit;
    reg clk, rst, sin;
    wire [7:0] pout;
    integer pass_count = 0, fail_count = 0;
    
    sipo_8bit dut (.clk(clk), .rst(rst), .sin(sin), .pout(pout));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task check_result;
        input [7:0] expected;
        begin
            @(negedge clk); // Wait for stable output
            if (pout === expected) begin
                pass_count++;
            end else begin
                $display("[FAIL] Expected=%b, Got=%b", expected, pout);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 8-bit SIPO ===");
        
        // Reset
        rst = 1; sin = 0;
        #10; rst = 0;
        
        // Shift in 10101001 (LSB first)
        sin = 1; #10; // Bit 0
        sin = 0; #10; // Bit 1
        sin = 1; #10; // Bit 2
        sin = 0; #10; // Bit 3
        sin = 1; #10; // Bit 4
        sin = 0; #10; // Bit 5
        sin = 1; #10; // Bit 6
        sin = 1; #10; // Bit 7

        // Verify parallel output
        check_result(8'b10101011); 
        sin = 0; #10;
        check_result(8'b01010110);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"sipo_8bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
