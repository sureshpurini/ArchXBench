module const_div_tb;
    // Parameters
    parameter WIDTH = 16;
    parameter DIVISOR = 10;
    parameter MUL_CONST = 6554;    // Precomputed for 2^16 / 10
    parameter SHIFT_CONST = 16;
    
    // Testbench signals
    reg [WIDTH-1:0] numerator;
    wire [WIDTH-1:0] quotient;
    reg [WIDTH-1:0] expected_quotient;
    
    // Instantiate the DUT
    const_div #(
        .WIDTH(WIDTH),
        .DIVISOR(DIVISOR),
        .MUL_CONST(MUL_CONST),
        .SHIFT_CONST(SHIFT_CONST)
    ) dut (
        .numerator(numerator),
        .quotient(quotient)
    );
    
    // Verification
    initial begin
        // Setup VCD file for waveform
        $dumpfile("const_div_test.vcd");
        $dumpvars(0, const_div_tb);
        
        $display("Starting test for WIDTH=%0d, DIVISOR=%0d", WIDTH, DIVISOR);
        $display("MUL_CONST=%0d, SHIFT_CONST=%0d", MUL_CONST, SHIFT_CONST);
        $display("---------------------------------------------------");
        $display("  Numerator  |  Expected Q  |  Actual Q  |  Pass/Fail");
        $display("---------------------------------------------------");
        
        // Test case 1: 0 / DIVISOR = 0
        numerator = 0;
        expected_quotient = 0;
        #10;
        verify();
        
        // Test case 2: DIVISOR / DIVISOR = 1
        numerator = DIVISOR;
        expected_quotient = 1;
        #10;
        verify();
        
        // Test case 3: DIVISOR-1 / DIVISOR = 0
        numerator = DIVISOR - 1;
        expected_quotient = 0;
        #10;
        verify();
        
        // Test case 4: 2*DIVISOR / DIVISOR = 2
        numerator = 2 * DIVISOR;
        expected_quotient = 2;
        #10;
        verify();
        
        // Test case 5: Random value
        numerator = 42;
        expected_quotient = 42 / DIVISOR;
        #10;
        verify();
        
        // Test case 6: Large value
        numerator = 1000;
        expected_quotient = 1000 / DIVISOR;
        #10;
        verify();
        
        // Test case 7: MAX_VALUE
        numerator = (1 << WIDTH) - 1;
        expected_quotient = ((1 << WIDTH) - 1) / DIVISOR;
        #10;
        verify();
        
        // Test multiple consecutive values
        $display("\nTesting consecutive values:");
        $display("---------------------------------------------------");
        for (integer i = 50; i < 70; i = i + 1) begin
            numerator = i;
            expected_quotient = i / DIVISOR;
            #10;
            verify();
        end
        
        $display("\nTest completed!");
        $finish;
    end
    
    // Helper task to verify and display results
    task verify;
        begin
            $display("  %10d  |  %10d  |  %10d  |  %s", 
                    numerator, 
                    expected_quotient, 
                    quotient,
                    (quotient == expected_quotient) ? "PASS" : "FAIL");
            
            if (quotient != expected_quotient) begin
                $display("ERROR: Mismatch detected at numerator = %0d", numerator);
                $display("       Expected: %0d, Got: %0d", expected_quotient, quotient);
            end
        end
    endtask
    
endmodule