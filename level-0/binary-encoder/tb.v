`timescale 1ns/1ps
module tb_binary_encoder_8to3;
    reg [7:0] in;
    wire [2:0] out;
    integer pass_count = 0, fail_count = 0;
    
    binary_encoder_8to3 dut (.in(in), .out(out));
    
    task check_result;
        input [2:0] expected_out;
        begin
            if (out === expected_out) begin
                pass_count++;
            end else begin
                $display("[FAIL] in=%b → out=%b (Expected: %b)", in, out, expected_out);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 8:3 Binary Encoder ===");
        
        // Test one-hot inputs
        in = 8'b00000001; #10; check_result(3'b000);
        in = 8'b00000010; #10; check_result(3'b001);
        in = 8'b00000100; #10; check_result(3'b010);
        in = 8'b00001000; #10; check_result(3'b011);
        in = 8'b00010000; #10; check_result(3'b100);
        in = 8'b00100000; #10; check_result(3'b101);
        in = 8'b01000000; #10; check_result(3'b110);
        in = 8'b10000000; #10; check_result(3'b111);
        
        // Test invalid inputs (multiple bits set)
        in = 8'b00000011; #10; check_result(3'b000); // Default case
        in = 8'b00100100; #10; check_result(3'b000); // Default case
        
        // X-propagation test
        in = 8'bxxxxxxx1; #10;
        if (out === 3'bxxx) pass_count++;
        else begin
            $display("[FAIL] in=xxxxxxx1 → out=%b (Expected: xxx)", out);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"binary_encoder_8to3\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
