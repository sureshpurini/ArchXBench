`timescale 1ns/1ps
module tb_bit_manip_unit;

    parameter N = 16;
    parameter M = $clog2(N);
    localparam HALF = N/2;

    reg  [N-1:0] data;
    reg  [N-1:0] data2;
    reg  [1:0]   op_code;
    reg  [M-1:0] shift_amt;
    reg  [N-1:0] mask_val;
    wire [N-1:0] out;
    wire [N-1:0] out2;

    // Local variables for expected results.
    reg [N-1:0] exp1;
    reg [N-1:0] exp2;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    // Instantiate the DUT
    bit_manip_unit #(.N(N), .M(M)) dut (
        .data(data),
        .data2(data2),
        .op_code(op_code),
        .shift_amt(shift_amt),
        .mask_val(mask_val),
        .out(out),
        .out2(out2)
    );

    initial begin
        $display("Starting Bit Manipulation Unit Testbench with 50 test cases...");

        // Run 50 test cases (a mix of predetermined edge cases and random inputs)
        for (i = 0; i < 50; i = i + 1) begin

            // First 8 test cases: Predefined edge and specific cases.
            if (i < 8) begin
                case (i)
                    0: begin // Rotate: no rotation (shift_amt = 0)
                        op_code   = 2'b00;
                        data      = 16'hA5A5;
                        shift_amt = 0;
                        data2     = 16'h0;     // Not used in rotate.
                        mask_val  = 16'h0;     // Not used in rotate.
                    end
                    1: begin // Rotate: maximum rotation (shift_amt = 15)
                        op_code   = 2'b00;
                        data      = 16'hA5A5;
                        shift_amt = 15;
                        data2     = 16'h0;
                        mask_val  = 16'h0;
                    end
                    2: begin // Mask: using all ones mask (should pass data unchanged)
                        op_code   = 2'b01;
                        data      = 16'hA5A5;
                        mask_val  = 16'hFFFF;
                        shift_amt = 0;
                        data2     = 16'h0;
                    end
                    3: begin // Mask: using zero mask (output should be 0)
                        op_code   = 2'b01;
                        data      = 16'hA5A5;
                        mask_val  = 16'h0000;
                        shift_amt = 0;
                        data2     = 16'h0;
                    end
                    4: begin // Pack: combine lower halves of two patterns
                        op_code   = 2'b10;
                        data      = 16'h1234; // Lower half = 0x34
                        data2     = 16'hABCD; // Lower half = 0xCD
                        shift_amt = 0;
                        mask_val  = 16'h0;
                    end
                    5: begin // Unpack: split a known pattern into two halves
                        op_code   = 2'b11;
                        data      = 16'hDEAD; // Expected: out = 16'hDE, out2 = 16'hAD (for 16-bit word split into 8:8)
                        shift_amt = 0;
                        mask_val  = 16'h0;
                        data2     = 16'h0;
                    end
                    6: begin // Rotate: with a mid-range rotation value
                        op_code   = 2'b00;
                        data      = 16'hFFFF;
                        shift_amt = 4;
                        data2     = 16'h0;
                        mask_val  = 16'h0;
                    end
                    7: begin // Pack: another specific pack operation
                        op_code   = 2'b10;
                        data      = 16'h0F0F;
                        data2     = 16'hF0F0;
                        shift_amt = 0;
                        mask_val  = 16'h0;
                    end
                    default: begin
                        op_code   = 2'b00;
                        data      = 16'h0;
                        data2     = 16'h0;
                        shift_amt = 0;
                        mask_val  = 16'h0;
                    end
                endcase
            end else begin
                // Test cases 8 to 49: use random inputs
                op_code   = $random % 4;         // Random op code (0 to 3)
                data      = $random;
                data2     = $random;
                shift_amt = $random % (1 << M);   // Keep shift_amt in range 0 to 2^M-1.
                mask_val  = $random;
            end

            // Wait a little for combinational logic to settle
            #10;

            // Calculate expected outputs based on the selected op_code.
            case (op_code)
                2'b00: begin // Rotate (rotate left)
                    exp1 = (data << shift_amt) | (data >> (N - shift_amt));
                    exp2 = 0;
                end

                2'b01: begin // Mask operation
                    exp1 = data & mask_val;
                    exp2 = 0;
                end

                2'b10: begin // Pack operation: combine lower halves of data and data2.
                    exp1 = { data[HALF-1:0], data2[HALF-1:0] };
                    exp2 = 0;
                end

                2'b11: begin // Unpack operation: split data into two halves.
                    exp1 = data[N-1:HALF];
                    exp2 = data[HALF-1:0];
                end

                default: begin
                    exp1 = 0;
                    exp2 = 0;
                end
            endcase

            #1; // Extra small delay for expected values

            // Compare DUT outputs with expected values.
            if ((out === exp1) && (out2 === exp2)) begin
                $display("[PASS] Test Case %0d: op=%b, data=%h, data2=%h, shift_amt=%d, mask_val=%h, out=%h, out2=%h", 
                         i, op_code, data, data2, shift_amt, mask_val, out, out2);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test Case %0d: op=%b, data=%h, data2=%h, shift_amt=%d, mask_val=%h, Expected: out=%h, out2=%h, Got: out=%h, out2=%h", 
                         i, op_code, data, data2, shift_amt, mask_val, exp1, exp2, out, out2);
                fail_count = fail_count + 1;
            end
        end

        // Print summary information.
        $display("Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        $finish;
    end

endmodule
