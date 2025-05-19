`timescale 1ns/1ps
module tb_piso_8bit;
    reg clk, rst, load;
    reg [7:0] pin;
    wire sout;
    integer pass_count = 0, fail_count = 0;
    
    piso_8bit dut (.clk(clk), .rst(rst), .load(load), .pin(pin), .sout(sout));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task check_result;
        input expected;
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
        $display("=== Testing 8-bit PISO ===");
        
        // Reset
        rst = 1; load = 0; pin = 8'b0;
        #10; rst = 0;
        
        // Load data
        pin = 8'b10101001;
        load = 1; #10;
        load = 0;
        
        // Verify serial output (MSB first)
        check_result(1);
        check_result(0);
        check_result(1);
        check_result(0);
        check_result(1);
        check_result(0);
        check_result(0);
        check_result(1);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"piso_8bit\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
