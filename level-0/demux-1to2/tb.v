`timescale 1ns/1ps
module tb_demux_1to2;
    reg in, sel;
    wire out0, out1;
    integer pass_count = 0, fail_count = 0;
    
    demux_1to2 dut (.in(in), .sel(sel), .out0(out0), .out1(out1));
    
    task check_result;
        input expected_out0, expected_out1;
        begin
            if ((out0 === expected_out0) && (out1 === expected_out1)) begin
                pass_count++;
            end else begin
                $display("[FAIL] in=%b, sel=%b → out0=%b, out1=%b (Expected: out0=%b, out1=%b)",
                         in, sel, out0, out1, expected_out0, expected_out1);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 1:2 DEMUX ===");
        for (int i = 0; i < 4; i++) begin
            {in, sel} = i;
            #10;
            check_result(
                sel ? 1'b0 : in,  // Expected out0
                sel ? in : 1'b0   // Expected out1
            );
        end
        
        // X-propagation test
        sel = 1'bx; in = 1;
        #10;
        if (out0 === 1'bx && out1 === 1'bx) pass_count++;
        else begin
            $display("[FAIL] sel=X → out0=%b, out1=%b (Expected: X, X)", out0, out1);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"demux_1to2\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
