`timescale 1ns/1ps
module tb_decoder_2to4;
    reg [1:0] in;
    reg enable;
    wire [3:0] out;
    integer pass_count = 0, fail_count = 0;
    
    decoder_2to4 dut (.in(in), .enable(enable), .out(out));
    
    task check_result;
        input [3:0] expected_out;
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
        $display("=== Testing 2:4 Decoder ===");
        
        // Test with enable=1
        enable = 1;
        in = 2'b00; #10; check_result(4'b0001);
        in = 2'b01; #10; check_result(4'b0010);
        in = 2'b10; #10; check_result(4'b0100);
        in = 2'b11; #10; check_result(4'b1000);
        
        // Test with enable=0
        enable = 0;
        in = 2'b00; #10; check_result(4'b0000);
        in = 2'b11; #10; check_result(4'b0000);
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"decoder_2to4\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
