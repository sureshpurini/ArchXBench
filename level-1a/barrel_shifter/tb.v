`timescale 1ns/1ps
module tb_barrel_shifter;
    parameter n = 16;
    parameter m = $clog2(n);

    reg  [n-1:0] data;
    reg  [m-1:0] shamt;
    reg          dir;
    reg          arith;
    wire [n-1:0] out;

    // Local variable to hold the expected result (matching n bits)
    reg [n-1:0] expected;
    
    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    // Instantiate the DUT (Device Under Test)
    barrel_shifter #(.n(n), .m(m)) dut (
        .data(data),
        .shamt(shamt),
        .dir(dir),
        .arith(arith),
        .out(out)
    );

    initial begin
        $display("Starting Barrel Shifter Testbench with 50 test cases...");

        // Run 50 test cases (edge cases + random inputs)
        for (i = 0; i < 50; i = i + 1) begin
            // First 6 iterations: predefined edge cases
            if (i < 6) begin
                case (i)
                    0: begin 
                        // Left shift: no shift (edge: shamt = 0)
                        data  = 16'hA5A5; 
                        shamt = 4'd0;  
                        dir   = 1'b0; 
                        arith = 1'b0; 
                    end
                    1: begin 
                        // Left shift: maximum shift amount
                        data  = 16'hA5A5; 
                        shamt = 4'd15; 
                        dir   = 1'b0; 
                        arith = 1'b0; 
                    end
                    2: begin 
                        // Right logical shift: no shift (edge: shamt = 0)
                        data  = 16'hA5A5; 
                        shamt = 4'd0;  
                        dir   = 1'b1; 
                        arith = 1'b0; 
                    end
                    3: begin 
                        // Right logical shift: maximum shift amount
                        data  = 16'hA5A5; 
                        shamt = 4'd15; 
                        dir   = 1'b1; 
                        arith = 1'b0; 
                    end
                    4: begin 
                        // Right arithmetic shift (positive number) at maximum shift
                        data  = 16'h1A2B; 
                        shamt = 4'd15; 
                        dir   = 1'b1; 
                        arith = 1'b1; 
                    end
                    5: begin 
                        // Right arithmetic shift (negative number) at maximum shift
                        data  = 16'hF0F0; 
                        shamt = 4'd15; 
                        dir   = 1'b1; 
                        arith = 1'b1; 
                    end
                    default: begin
                        data  = 16'h0000; 
                        shamt = 4'd0;  
                        dir   = 1'b0; 
                        arith = 1'b0; 
                    end
                endcase
            end
            else begin
                // Remaining test cases: generate random inputs.
                // $random yields a 32-bit value, but assignment to [n-1:0] truncates to 16 bits.
                data  = $random;
                shamt = $random % 16;  // force shamt into the range 0 to 15
                dir   = $random % 2;
                arith = $random % 2;
            end

            // Wait for the combinational logic to settle
            #10;

            // Compute expected output:
            if (dir == 1'b0) begin
                // Left shift: vacant bits are zero-filled.
                expected = data << shamt;
            end else begin
                if (arith)
                    // For arithmetic right shift, use $signed; note the cast to n bits.
                    expected = $signed(data) >>> shamt;
                else
                    expected = data >> shamt;
            end

            // Small delay to ensure the expected value is computed
            #1;

            // Compare the DUT output with the expected result.
            if (out === expected) begin
                $display("[PASS] Test Case %0d: data=%h, shamt=%d, dir=%b, arith=%b, out=%h", i, data, shamt, dir, arith, out);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test Case %0d: data=%h, shamt=%d, dir=%b, arith=%b, Expected=%h, Got=%h", i, data, shamt, dir, arith, expected, out);
                fail_count = fail_count + 1;
            end
        end

        // Display overall summary
        $display("Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        $finish;
    end

endmodule
