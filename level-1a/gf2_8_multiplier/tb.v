// tb_gf256_mult.v
// Testbench for the GF(2⁸) multiplier (gf256_mult)
//
// The testbench drives key functional cases and compares the hardware
// result with a reference implementation computed in Verilog. The results
// are printed in a consistent format, and a summary of pass/fail counts is provided.

`timescale 1ns/1ps

module tb_gf256_mult;

    // Testbench signals
    reg  [7:0] a;
    reg  [7:0] b;
    wire [7:0] result;

    // Instantiate the DUT using the generic mode.
    // You can switch MODE to "AES_CONST" to test the optimized constant paths.
    gf256_mult #(.MODE("GENERIC")) dut (
        .a(a),
        .b(b),
        .result(result)
    );

    //----------------------------------------------------------------------
    // Reference GF multiplication function
    // Implements the same iterative multiplication as in the DUT.
    //----------------------------------------------------------------------
    function [7:0] ref_gf_mult;
        input [7:0] a;
        input [7:0] b;
        integer i;
        reg [7:0] p;
        reg [7:0] temp;
        begin
            p = 8'd0;
            temp = a;
            for(i = 0; i < 8; i = i + 1) begin
                if(b[i])
                    p = p ^ temp;
                // xtime: multiply by 2 with reduction using 0x1B.
                temp = {temp[6:0], 1'b0} ^ (8'h1B & {8{temp[7]}});
            end
            ref_gf_mult = p;
        end
    endfunction

    //----------------------------------------------------------------------
    // Testbench variables for counting passes/fails.
    //----------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    //----------------------------------------------------------------------
    // Test stimulus
    //----------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;
        
        // Test case 1:
        // a = 0x57, b = 0x02  (Expected: xtime(0x57) = 0xAE)
        a = 8'h57; b = 8'h02;
        #10;
        if(result === ref_gf_mult(a, b)) begin
            $display("[PASS] Test1: 0x57 * 0x02 = %h", result);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test1: 0x57 * 0x02: Expected %h, Got %h", ref_gf_mult(a, b), result);
            fail_count = fail_count + 1;
        end

        // Test case 2:
        // a = 0x83, b = 0x03  (Expected: xtime(0x83) XOR 0x83 = 0x9E)
        a = 8'h83; b = 8'h03;
        #10;
        if(result === ref_gf_mult(a, b)) begin
            $display("[PASS] Test2: 0x83 * 0x03 = %h", result);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test2: 0x83 * 0x03: Expected %h, Got %h", ref_gf_mult(a, b), result);
            fail_count = fail_count + 1;
        end

        // Test case 3:
        // a = 0xFF, b = 0x02  (Expected: xtime(0xFF) = 0xE5)
        a = 8'hFF; b = 8'h02;
        #10;
        if(result === ref_gf_mult(a, b)) begin
            $display("[PASS] Test3: 0xFF * 0x02 = %h", result);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test3: 0xFF * 0x02: Expected %h, Got %h", ref_gf_mult(a, b), result);
            fail_count = fail_count + 1;
        end

        // Test case 4:
        // a = 0x57, b = 0x03  (Expected: xtime(0x57) XOR 0x57 = 0xF9)
        a = 8'h57; b = 8'h03;
        #10;
        if(result === ref_gf_mult(a, b)) begin
            $display("[PASS] Test4: 0x57 * 0x03 = %h", result);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test4: 0x57 * 0x03: Expected %h, Got %h", ref_gf_mult(a, b), result);
            fail_count = fail_count + 1;
        end

        // Test case 5 (generic test):
        // a = 0x57, b = 0x8E (an arbitrary multiplier not specially optimized)
        a = 8'h57; b = 8'h8E;
        #10;
        if(result === ref_gf_mult(a, b)) begin
            $display("[PASS] Test5: 0x57 * 0x8E = %h", result);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test5: 0x57 * 0x8E: Expected %h, Got %h", ref_gf_mult(a, b), result);
            fail_count = fail_count + 1;
        end

        // Final summary
        $display("--------------------------------------------------");
        $display("Test Summary: %d Passed, %d Failed.", pass_count, fail_count);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
