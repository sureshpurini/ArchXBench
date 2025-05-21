// gradient_descent_poly_tb.v
// Testbench for gradient_descent_poly.v module.
// Generates 50 test cases (including at least 8 edge cases).
// The testbench converts fixed‑point numbers (Q8) to real values and computes the expected result using real arithmetic,
// then compares them against the output of the hardware module.
// The output displays the test case inputs, expected value, calculated value, error, and PASS/FAIL result.

`timescale 1ns/1ps

module gradient_descent_poly_tb;

  // Parameters matching the design.
  parameter N = 16;
  parameter M = 8;
  parameter MAX_ITER = 10;
  parameter NUM_CASES = 50;
  
  // Clock period.
  parameter CLK_PERIOD = 10;

  reg clk;
  reg rst;
  reg start;
  reg signed [N-1:0] in_x;
  reg signed [N-1:0] alpha;
  reg signed [N-1:0] a;
  reg signed [N-1:0] b;

  wire signed [N-1:0] x_next;
  wire ready;

  // Instantiate the DUT.
  gradient_descent_poly #(.N(N), .M(M), .MAX_ITER(MAX_ITER))
      dut (
          .clk(clk),
          .rst(rst),
          .start(start),
          .x(in_x),
          .alpha(alpha),
          .a(a),
          .b(b),
          .x_next(x_next),
          .ready(ready)
      );

  // Clock generation.
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Test case arrays.
  reg signed [N-1:0] test_x      [0:NUM_CASES-1];
  reg signed [N-1:0] test_alpha  [0:NUM_CASES-1];
  reg signed [N-1:0] test_a      [0:NUM_CASES-1];
  reg signed [N-1:0] test_b      [0:NUM_CASES-1];

  // Epsilon for error threshold.
  real epsilon;

  // Function to convert fixed‑point number to real.
  function real fixed2real;
    input signed [N-1:0] fixed;
    begin
      fixed2real = fixed / (2.0 ** M);
    end
  endfunction

  // Function to compute the expected value after MAX_ITER iterations
  // using real-number arithmetic:
  //   x_next = x - alpha * ( (2*a*x) + b )
  // Note: In fixed‑point arithmetic the multiplication of a and x is scaled by 2^M.
  function real compute_expected;
    input real x0;
    input real r_alpha;
    input real r_a;
    input real r_b;
    integer iter;
    real x_temp;
    begin
      x_temp = x0;
      for (iter = 0; iter < MAX_ITER; iter = iter + 1) begin
        x_temp = x_temp - r_alpha * ((2 * r_a * x_temp) + r_b);
      end
      compute_expected = x_temp;
    end
  endfunction

  integer i;
  real real_x, real_alpha, real_a, real_b;
  real expected_val;
  real calc_val;
  real error;

  initial begin
    epsilon = 0.05;  // Precision threshold.

    // Initialize test case arrays.
    // First 8 test cases are edge cases.
    // Test 0: All zeros.
    test_x[0]     = 16'd0;
    test_alpha[0] = 16'd0;
    test_a[0]     = 16'd0;
    test_b[0]     = 16'd0;
    
    // Test 1: Unity values with positive and negative.
    test_x[1]     = 16'd256;  // 1.0 in fixed‑point.
    test_alpha[1] = 16'd256;  // 1.0.
    test_a[1]     = 16'd256;  // 1.0.
    test_b[1]     = -16'd256; // -1.0.

    // Test 2: Negative initial x.
    test_x[2]     = -16'd256; // -1.0.
    test_alpha[2] = 16'd256;   // 1.0.
    test_a[2]     = 16'd256;   // 1.0.
    test_b[2]     = 16'd256;   // 1.0.

    // Test 3: Arbitrary values.
    test_x[3]     = 16'd100;
    test_alpha[3] = 16'd50;
    test_a[3]     = 16'd300;
    test_b[3]     = 16'd100;

    // Test 4: Maximum positive x.
    test_x[4]     = 16'd32767;
    test_alpha[4] = 16'd256;
    test_a[4]     = 16'd256;
    test_b[4]     = 16'd0;

    // Test 5: Maximum negative x.
    test_x[5]     = -16'd32768;
    test_alpha[5] = 16'd256;
    test_a[5]     = 16'd256;
    test_b[5]     = 16'd0;

    // Test 6: a = 0 edge case (flat derivative).
    test_x[6]     = 16'd256;   // 1.0.
    test_alpha[6] = 16'd256;   // 1.0.
    test_a[6]     = 16'd0;     // 0.0.
    test_b[6]     = 16'd256;   // 1.0.

    // Test 7: Very small alpha.
    test_x[7]     = 16'd256;   // 1.0.
    test_alpha[7] = 16'd1;     // ~0.0039.
    test_a[7]     = 16'd256;   // 1.0.
    test_b[7]     = 16'd0;     // 0.0.

    // For remaining test cases 8 to 49, generate patterned test values.
    for (i = 8; i < NUM_CASES; i = i + 1) begin
      test_x[i]     = i * 20;              // Increasing initial value.
      test_alpha[i] = 16'd256 + i;         // Slight variation in alpha (~1.0 plus small offset).
      test_a[i]     = 16'd256 - i;         // Slight decrease from 1.0.
      // Alternate between positive and negative b.
      if (i % 2)
        test_b[i]   = 16'd128;           // Approximately 0.5 in fixed‑point.
      else
        test_b[i]   = -16'd128;          // Approximately -0.5.
    end

    // Allow time for initialization.
    #(CLK_PERIOD);

    // Begin testing cases.
    for (i = 0; i < NUM_CASES; i = i + 1) begin
      rst = 1;
      start = 0;
      #(CLK_PERIOD);
      rst = 0;
      #(CLK_PERIOD);

      // Apply test vector.
      in_x   = test_x[i];
      alpha  = test_alpha[i];
      a      = test_a[i];
      b      = test_b[i];

      // Convert fixed‑point values to real.
      real_x     = fixed2real(in_x);
      real_alpha = fixed2real(alpha);
      real_a     = fixed2real(a);
      real_b     = fixed2real(b);
      
      expected_val = compute_expected(real_x, real_alpha, real_a, real_b);

      // Start computation.
      start = 1;
      #(CLK_PERIOD);
      start = 0;

      // Wait for the module to assert ready.
      wait (ready == 1);
      #(CLK_PERIOD);

      // Convert module output to real.
      calc_val = fixed2real(x_next);

      // Compute absolute error.
      error = (expected_val > calc_val) ? (expected_val - calc_val) : (calc_val - expected_val);

      // Display results.
      $display("Test case %0d: ", i);
      $display("  Inputs: x=%f, alpha=%f, a=%f, b=%f", real_x, real_alpha, real_a, real_b);
      $display("  Expected x_next = %f", expected_val);
      $display("  Calculated x_next = %f", calc_val);
      $display("  Error = %f --> %s", error, (error < epsilon) ? "PASS" : "FAIL");
      $display("------------------------------------------------------");
      #(CLK_PERIOD*2);
    end

    $display("Testing completed.");
    $stop;
  end

endmodule