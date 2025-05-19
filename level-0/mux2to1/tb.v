`timescale 1ns/1ps
module tb_mux_2to1;
    reg sel, in0, in1;
    wire out;
    integer pass_count = 0, fail_count = 0;
    
    mux_2to1 dut (.sel(sel), .in0(in0), .in1(in1), .out(out));
    
    task check_result;
        input expected;
        begin
            if (out === expected) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] sel=%b, in0=%b, in1=%b → out=%b (Expected: %b)", 
                         sel, in0, in1, out, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 2:1 MUX ===");
        for (int i = 0; i < 8; i++) begin
            {sel, in0, in1} = i;
            #10;
            check_result(sel ? in1 : in0);
        end
        
        sel = 1'bx; in0 = 0; in1 = 1;
        #10;
        if (out === 1'bx) pass_count++;
        else begin
            $display("[FAIL] sel=X → out=%b (Expected: X)", out);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"mux_2to1\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $fatal(1, "Tests failed!");
        $finish;
    end
endmodule
