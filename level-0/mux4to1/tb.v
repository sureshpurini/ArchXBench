`timescale 1ns/1ps
module tb_mux_4to1;
    reg [1:0] sel;
    reg [3:0] in;
    wire out;
    integer pass_count = 0, fail_count = 0;
    
    mux_4to1 dut (.sel(sel), .in(in), .out(out));
    
    task check_result;
        input expected;
        begin
            if (out === expected) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] sel=%b, in=%b → out=%b (Expected: %b)", 
                         sel, in, out, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 4:1 MUX ===");
        
        // Test all input combinations
        for (int s = 0; s < 4; s++) begin
            sel = s;
            for (int i = 0; i < 16; i++) begin
                in = i;
                #10;
                check_result(in[sel]);
            end
        end
        
        // Test X propagation
        sel = 2'bx; in = 4'b1010;
        #10;
        if (out === 1'bx) pass_count++;
        else begin
            $display("[FAIL] sel=X → out=%b (Expected: X)", out);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"mux_4to1\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $fatal(1, "Tests failed!");
        $finish;
    end
endmodule
