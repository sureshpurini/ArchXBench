`timescale 1ns/1ps

module shift_add_mult_tb;
    // Test parameters
    parameter WIDTH = 16;
    parameter PARALLEL_OPS = 4;
    parameter SIGNED = 1;
    
    // Calculate expected cycles
    localparam NUM_CYCLES = WIDTH / PARALLEL_OPS;
    
    // DUT signals
    reg clk;
    reg rst;
    reg start;
    reg valid_in;
    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    reg signed_mode;
    wire [2*WIDTH-1:0] result;
    wire valid_out;
    wire done;
    wire busy;
    
    // Testbench variables
    reg [2*WIDTH-1:0] expected_result;
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Instantiate DUT
    shift_add_mult #(
        .WIDTH(WIDTH),
        .PARALLEL_OPS(PARALLEL_OPS),
        .SIGNED(SIGNED)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .valid_in(valid_in),
        .A(A),
        .B(B),
        .signed_mode(signed_mode),
        .result(result),
        .valid_out(valid_out),
        .done(done),
        .busy(busy)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test task
    task test_multiplication;
        input [WIDTH-1:0] a_val;
        input [WIDTH-1:0] b_val;
        input signed_test;
        input [2*WIDTH-1:0] expected;
        integer wait_count;
        integer actual_cycles;
        reg test_complete;
        
        begin
            test_count = test_count + 1;
            test_complete = 0;
            actual_cycles = 0;
            
            // Apply inputs at negedge to ensure clean timing
            @(negedge clk);
            A = a_val;
            B = b_val;
            signed_mode = signed_test;
            expected_result = expected;
            valid_in = 1'b1;
            start = 1'b1;
            
            // Wait for posedge to capture
            @(posedge clk);
            #1; // Small delay after posedge
            
            // Clear start at negedge
            @(negedge clk);
            start = 1'b0;
            valid_in = 1'b0;
            
            // Wait for completion and count cycles
            wait_count = 0;
            while (!test_complete && wait_count < (NUM_CYCLES + 5)) begin
                @(posedge clk);
                #1; // Small delay to ensure signal has propagated
                
                if (busy && !done) begin
                    actual_cycles = actual_cycles + 1;
                end
                
                if (done) begin
                    // Check result when done is asserted
                    if (result == expected_result) begin
                        $display("Test %3d PASSED: %0d x %0d = %0d (mode=%s, cycles=%0d)", 
                                test_count, 
                                signed_test ? $signed(a_val) : a_val,
                                signed_test ? $signed(b_val) : b_val,
                                signed_test ? $signed(result) : result,
                                signed_test ? "signed" : "unsigned",
                                actual_cycles);
                        pass_count = pass_count + 1;
                    end else begin
                        $display("Test %3d FAILED: %0d x %0d = %0d, expected %0d (mode=%s, cycles=%0d)", 
                                test_count,
                                signed_test ? $signed(a_val) : a_val,
                                signed_test ? $signed(b_val) : b_val,
                                signed_test ? $signed(result) : result,
                                signed_test ? $signed(expected_result) : expected_result,
                                signed_test ? "signed" : "unsigned",
                                actual_cycles);
                        fail_count = fail_count + 1;
                    end
                    test_complete = 1;
                end
                
                wait_count = wait_count + 1;
            end
            
            if (!test_complete) begin
                $display("Test %3d TIMEOUT: A=%0d, B=%0d", test_count, a_val, b_val);
                fail_count = fail_count + 1;
            end
            
            // Wait for system to settle and done to clear
            repeat(3) @(posedge clk);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Setup waveform dump
        $dumpfile("shift_add_mult_tb.vcd");
        $dumpvars(0, shift_add_mult_tb);
        
        // Initialize all signals
        rst = 1;
        start = 0;
        valid_in = 0;
        A = 0;
        B = 0;
        signed_mode = 0;
        
        // Print test configuration
        $display("\n===== Shift-Add Multiplier Test =====");
        $display("Configuration:");
        $display("  WIDTH = %0d", WIDTH);
        $display("  PARALLEL_OPS = %0d", PARALLEL_OPS);
        $display("  SIGNED = %0d", SIGNED);
        $display("  Expected cycles = %0d", NUM_CYCLES);
        $display("=====================================\n");
        
        // Wait a bit before reset
        #50;
        
        // Reset at negedge for clean timing
        @(negedge clk);
        rst = 0;
        
        // Wait for system to stabilize
        repeat(5) @(posedge clk);
        
        // Unsigned tests - adjust values based on WIDTH
        $display("\n--- Unsigned Multiplication Tests ---");
        test_multiplication({WIDTH{1'b0}}, {WIDTH{1'b0}}, 0, {2*WIDTH{1'b0}});  // 0 x 0
        test_multiplication({{(WIDTH-1){1'b0}}, 1'b1}, {{(WIDTH-1){1'b0}}, 1'b1}, 0, 
                          {{(2*WIDTH-1){1'b0}}, 1'b1});  // 1 x 1
        test_multiplication({{(WIDTH-4){1'b0}}, 4'b1010}, {{(WIDTH-3){1'b0}}, 3'b101}, 0, 
                          {{(2*WIDTH-7){1'b0}}, 7'b0110010});  // 10 x 5 = 50
        
        // Scale test values based on WIDTH
        if (WIDTH == 8) begin
            test_multiplication(8'd127, 8'd2, 0, 16'd254);      // Mid x 2
            test_multiplication(8'd100, 8'd2, 0, 16'd200);      // 100 x 2
            test_multiplication(8'd255, 8'd1, 0, 16'd255);      // Max x 1
        end else if (WIDTH == 16) begin
            test_multiplication(16'd255, 16'd255, 0, 32'd65025);   // 255 x 255
            test_multiplication(16'd1000, 16'd100, 0, 32'd100000); // 1000 x 100
            test_multiplication(16'd65535, 16'd2, 0, 32'd131070);  // Max x 2
        end else if (WIDTH == 32) begin
            test_multiplication(32'd65535, 32'd65535, 0, 64'd4294836225);     // 65535 x 65535
            test_multiplication(32'd1000000, 32'd1000, 0, 64'd1000000000);    // 1M x 1K
            test_multiplication(32'hFFFFFFFF, 32'd2, 0, 64'h1FFFFFFFE);       // Max x 2
        end
        
        // Signed tests
        if (SIGNED) begin
            $display("\n--- Signed Multiplication Tests ---");
            test_multiplication({WIDTH{1'b0}}, {WIDTH{1'b0}}, 1, {2*WIDTH{1'b0}});  // 0 x 0
            test_multiplication({{(WIDTH-1){1'b0}}, 1'b1}, {{(WIDTH-1){1'b0}}, 1'b1}, 1, 
                              {{(2*WIDTH-1){1'b0}}, 1'b1});  // 1 x 1
            test_multiplication({WIDTH{1'b1}}, {{(WIDTH-1){1'b0}}, 1'b1}, 1, 
                              {2*WIDTH{1'b1}});  // -1 x 1
            test_multiplication({WIDTH{1'b1}}, {WIDTH{1'b1}}, 1, 
                              {{(2*WIDTH-1){1'b0}}, 1'b1});  // -1 x -1
            
            if (WIDTH == 8) begin
                test_multiplication(8'h7F, 8'h02, 1, 16'h00FE);    // 127 x 2
                test_multiplication(8'h80, 8'h02, 1, 16'hFF00);    // -128 x 2
            end else if (WIDTH == 16) begin
                test_multiplication(16'h000A, 16'hFFFB, 1, 32'hFFFFFFCE); // 10 x -5
                test_multiplication(16'h7FFF, 16'h0002, 1, 32'h0000FFFE); // 32767 x 2
                test_multiplication(16'h8000, 16'h0002, 1, 32'hFFFF0000); // -32768 x 2
            end else if (WIDTH == 32) begin
                test_multiplication(32'h00000064, 32'hFFFFFF9C, 1, 64'hFFFFFFFFFFFFD8F0); // 100 x -100
                test_multiplication(32'h7FFFFFFF, 32'h00000002, 1, 64'h00000000FFFFFFFE); // Max pos x 2
                test_multiplication(32'h80000000, 32'h00000002, 1, 64'hFFFFFFFF00000000); // Max neg x 2
            end
        end
        
        // Edge cases - use appropriate patterns for WIDTH
        $display("\n--- Edge Case Tests ---");
        // Max value for current WIDTH
        if (WIDTH == 8) begin
            test_multiplication(8'd255, 8'd1, 0, 16'd255);       // Max x 1
            test_multiplication(8'd255, 8'd255, 0, 16'd65025);   // Max x Max
        end else if (WIDTH == 16) begin
            test_multiplication(16'hAAAA, 16'h5555, 0, 32'h38E31C72);  // Alternating bits
            test_multiplication(16'hFFFF, 16'hFFFF, 0, 32'hFFFE0001);  // Max x Max
        end else if (WIDTH == 32) begin
            test_multiplication(32'h80000000, 32'h00000001, 0, 64'h0000000080000000);  // MSB set x 1
            test_multiplication(32'hFFFFFFFF, 32'hFFFFFFFF, 0, 64'hFFFFFFFE00000001);  // Max x Max
        end
        
        // Random tests
        $display("\n--- Random Tests ---");
        for (integer i = 0; i < 10; i = i + 1) begin
            reg [WIDTH-1:0] rand_a, rand_b;
            reg [2*WIDTH-1:0] expected_unsigned, expected_signed;
            
            // Use appropriate random values for WIDTH
            if (WIDTH == 8) begin
                rand_a = $random & 8'hFF;
                rand_b = $random & 8'hFF;
            end else if (WIDTH == 16) begin
                rand_a = $random & 16'hFFFF;
                rand_b = $random & 16'hFFFF;
            end else begin
                rand_a = $random;
                rand_b = $random;
            end
            
            // Calculate expected results
            expected_unsigned = rand_a * rand_b;
            expected_signed = $signed(rand_a) * $signed(rand_b);
            
            test_multiplication(rand_a, rand_b, 0, expected_unsigned);
            if (SIGNED) begin
                test_multiplication(rand_a, rand_b, 1, expected_signed);
            end
        end
        
        // Summary
        $display("\n===== Test Summary =====");
        $display("Total tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("Success rate: %0.1f%%", 100.0 * pass_count / test_count);
        $display("Cycles per operation: %0d", NUM_CYCLES);
        $display("=======================\n");
        
        $finish;
    end
    
    // Overall timeout
    initial begin
        #2000000;  // 2ms timeout
        $display("ERROR: Overall testbench timeout!");
        $finish;
    end

endmodule