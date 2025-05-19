`timescale 1ns/1ps
module tb_demux_1to4;
    reg in;
    reg [1:0] sel;
    wire out0, out1, out2, out3;
    integer pass_count = 0, fail_count = 0;
    
    demux_1to4 dut (
        .in(in),
        .sel(sel),
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3)
    );
    
    task check_result;
        input expected_out0, expected_out1, expected_out2, expected_out3;
        begin
            if ((out0 === expected_out0) && 
                (out1 === expected_out1) && 
                (out2 === expected_out2) && 
                (out3 === expected_out3)) begin
                pass_count++;
            end else begin
                $display("[FAIL] in=%b, sel=%b → out=%b%b%b%b (Expected: %b%b%b%b)",
                         in, sel, out0, out1, out2, out3, 
                         expected_out0, expected_out1, expected_out2, expected_out3);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 1:4 DEMUX ===");
        in = 1;  // Test with input=1 (outputs should mirror sel)
        for (int s = 0; s < 4; s++) begin
            sel = s;
            #10;
            case (sel)
                2'b00: check_result(1, 0, 0, 0);
                2'b01: check_result(0, 1, 0, 0);
                2'b10: check_result(0, 0, 1, 0);
                2'b11: check_result(0, 0, 0, 1);
            endcase
        end
        
        // Test input=0 (all outputs should be 0)
        in = 0;
        for (int s = 0; s < 4; s++) begin
            sel = s;
            #10;
            check_result(0, 0, 0, 0);
        end
        
        // X-propagation test
        sel = 2'bx; in = 1;
        #10;
        if (out0 === 1'bx && out1 === 1'bx && out2 === 1'bx && out3 === 1'bx) pass_count++;
        else begin
            $display("[FAIL] sel=X → out=%b%b%b%b (Expected: XXXX)", out0, out1, out2, out3);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"demux_1to4\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
