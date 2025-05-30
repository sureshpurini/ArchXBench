`timescale 1ns/1ps
module tb_decoder_3to8;
    reg [2:0] in;
    reg enable;
    wire [7:0] out;
    integer pass_count = 0, fail_count = 0;
    
    decoder3to8 dut (.in(in), .enable(enable), .out(out));
    
    task check_result;
        input [7:0] expected_out;
        begin
            if (out === expected_out) begin
                pass_count++;
            end else begin
                $display("[FAIL] in=%b, enable=%b → out=%b (Expected: %b)",
                         in, enable, out, expected_out);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 3:8 Decoder ===");
        
        // Test with enable=1
        enable = 1;
        for (int i = 0; i < 8; i++) begin
            in = i;
            #10;
            check_result(1 << i);
        end
        
        // Test with enable=0
        enable = 0;
        in = 3'b000; #10; check_result(8'b00000000);
        in = 3'b111; #10; check_result(8'b00000000);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"decoder_3to8\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
