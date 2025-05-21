`timescale 1ns/1ps
module tb;
  
  parameter N = 16;
  parameter M = 8;
  parameter ITER_MAX = 10;
  
  reg clk;
  reg rst;
  reg start;
  reg [N-1:0] X;
  wire [N-1:0] sqrt_result;
  wire ready;
  
  // Instantiate the design under test.
  sqrt_newton_raphson_fixedpoint #(.N(N), .M(M), .ITER_MAX(ITER_MAX)) uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .X(X),
    .sqrt_result(sqrt_result),
    .ready(ready)
  );
  
  // Clock generation: 10 ns period.
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Array of test cases (50 cases). 
  // At least the following are edge cases: 0, 1, 2, 256 (1.0), 1024 (4.0), 4095, maximum (16'hFFFF) and one more (e.g., 16).
  integer i;
  reg [N-1:0] test_inputs [0:49];
  
  real real_input;
  real expected;
  real computed;
  real error;
  real epsilon = 0.01; // Error threshold for pass/fail
  
  initial begin
    // Initialize test cases.
    test_inputs[0] = 0;            // Edge: 0.0
    test_inputs[1] = 1;            // Edge: smallest non-zero value
    test_inputs[2] = 16;           // Edge/typical value
    test_inputs[3] = 64;           // typical value
    test_inputs[4] = 100;          // typical value
    test_inputs[5] = 256;          // Edge: exactly 1.0 (256/256)
    test_inputs[6] = 300;          // typical value >1.0
    test_inputs[7] = 1024;         // Edge: exactly 4.0 (1024/256)
    test_inputs[8] = 4095;         // Edge: near a round number
    // Fill remaining test cases with pseudo-random patterned values.
    for(i = 9; i < 50; i = i + 1) begin
      test_inputs[i] = (i * 123) % 65536;
    end
    // Additional specific edge cases.
    test_inputs[10] = 2;           // near-zero edge
    test_inputs[11] = 16'hFFFF;      // maximum for 16-bit
    
    // Global reset
    rst = 1;
    start = 0;
    X = 0;
    #20;
    rst = 0;
    
    // Iterate through each test case.
    for (i = 0; i < 50; i = i + 1) begin
      X = test_inputs[i];
      // Provide a start pulse.
      #10;
      start = 1;
      #10;
      start = 0;
      // Wait for calculation to complete.
      wait(ready);
      #10;
      // Convert fixed-point numbers to real (scale = 2^M).
      real_input = X / (1.0 * (1 << M));
      computed = sqrt_result / (1.0 * (1 << M));
      expected = $sqrt(real_input);
      error = (computed > expected) ? (computed - expected) : (expected - computed);
      
      if (error <= epsilon)
        $display("Test %0d: PASS. Input=%0d (%.4f), Expected sqrt=%.4f, Computed sqrt=%.4f, Error=%.4f", 
                  i, X, real_input, expected, computed, error);
      else
        $display("Test %0d: FAIL. Input=%0d (%.4f), Expected sqrt=%.4f, Computed sqrt=%.4f, Error=%.4f", 
                  i, X, real_input, expected, computed, error);
      // Delay before next test: reset the module by pulsing rst.
      #20;
      rst = 1;
      #10;
      rst = 0;
      #10;
    end
    
    $finish;
  end

endmodule