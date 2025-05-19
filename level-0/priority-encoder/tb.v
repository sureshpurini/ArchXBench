`timescale 1ns/1ps
module tb_priority_encoder_4to2;
    reg [3:0] in;
    wire [1:0] out;
    wire valid;
    integer pass_count = 0, fail_count = 0;
    
    priority_encoder_4to2 dut (.in(in), .out(out), .valid(valid));
    
    task check_result;
        input [1:0] expected_out;
        input expected_valid;
        begin
            if ((out === expected_out) && (valid === expected_valid)) begin
                pass_count++;
            end else begin
                $display("[FAIL] in=%b → out=%b, valid=%b (Expected: out=%b, valid=%b)",
                         in, out, valid, expected_out, expected_valid);
                fail_count++;
            end
        end
    endtask
    
    initial begin
        $display("=== Testing 4:2 Priority Encoder ===");
        
        // Test cases (priority order: in[3] > in[2] > in[1] > in[0])
        in = 4'b1000; #10; check_result(2'b11, 1'b1);
        in = 4'b0100; #10; check_result(2'b10, 1'b1);
        in = 4'b0010; #10; check_result(2'b01, 1'b1);
        in = 4'b0001; #10; check_result(2'b00, 1'b1);
        in = 4'b0000; #10; check_result(2'b00, 1'b0);
        in = 4'b1100; #10; check_result(2'b11, 1'b1); // Highest priority
        
        // X-propagation test
        in = 4'bxxxx; #10;
        if (out === 2'bxx && valid === 1'bx) pass_count++;
        else begin
            $display("[FAIL] in=xxxx → out=%b, valid=%b (Expected: xx, x)", out, valid);
            fail_count++;
        end
        
        $display("\n=== Test Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
        $display("{\"module\": \"priority_encoder_4to2\", \"passed\": %0d, \"failed\": %0d}", pass_count, fail_count);
        
        if (fail_count > 0) $finish(1);
        $finish;
    end
endmodule
