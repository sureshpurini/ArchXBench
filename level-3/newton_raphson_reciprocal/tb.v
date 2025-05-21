`timescale 1ns/1ps
//////////////////////////////////////////////////////////////
// Testbench for reciprocal_newton_raphson_fixedpoint
// Generates 50 test cases, including at least 8 edge cases.
// This testbench treats the DUT numbers as fixed-point fractions where
// the real value = X / (1<<M). Hence, the reciprocal in real is (1 / (X/(1<<M))).
// The testbench computes expected reciprocals, converts the DUT output to real,
// and prints the error and pass/fail based on an epsilon threshold.
//////////////////////////////////////////////////////////////

module tb_reciprocal_newton_raphson_fixedpoint;

  // Parameter values (should match DUT)
  parameter N = 16;
  parameter M = 8;
  parameter ITERATIONS = 4;

  reg clk;
  reg rst;
  reg start;
  reg [N-1:0] X;
  wire [N-1:0] reciprocal_result;
  wire ready;

  // Instantiate DUT
  reciprocal_newton_raphson_fixedpoint #(.N(N), .M(M), .ITERATIONS(ITERATIONS)) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .X(X),
    .reciprocal_result(reciprocal_result),
    .ready(ready)
  );

  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Task to run a test and compare fixed-point reciprocals (using fraction representation)
  task run_test(input integer test_num, input [N-1:0] x_in);
    real input_real;
    real expected_real, computed_real, error;
    real epsilon;
    begin
      // Reset DUT before test
      rst = 1; start = 0;
      #10; rst = 0;
      @(posedge clk);
      
      X = x_in;
      start = 1;
      @(posedge clk);
      start = 0;
      
      // Wait until computation is complete
      wait(ready == 1);
      
      if(x_in == 0) begin
         $display("Test %0d: X = %d (represents 0 in real) -> Reciprocal is undefined", test_num, x_in);
      end else begin
         input_real = x_in / (1.0 * (1 << M));
         expected_real = 1.0 / input_real;
         computed_real = reciprocal_result / (1.0 * (1 << M));
         error = (expected_real > computed_real) ? (expected_real - computed_real) : (computed_real - expected_real);
         epsilon = 0.05; // error threshold in real units

         $display("Test %0d: X = %d, Expected Real = %f, Calculated Real = %f, Error = %f --> %s",
                  test_num, x_in, expected_real, computed_real, error, (error <= epsilon) ? "PASS" : "FAIL");
      end
      #10;
    end
  endtask

  // Generate 50 test cases, including at least 8 edge cases.
  integer i;
  reg [N-1:0] test_values[0:49];
  initial begin
    // Define edge cases:
    test_values[0] = 0;                  // Zero
    test_values[1] = 1;                  // Minimum nonzero (represents 1/256)
    test_values[2] = (1 << (M-1));       // Lower bound of normalized range: 128 represents 0.5
    test_values[3] = (1 << (M-1)) + 1;
    test_values[4] = (1 << M) - 1;       // 255 represents ~0.996
    test_values[5] = (1 << M);           // 256 represents 1.0
    test_values[6] = (1 << M) + 10;      // 266 represents ~1.039
    test_values[7] = {N{1'b1}} - 10;     // High value near maximum
    test_values[8] = (1 << (M-1)) - 1;     // 127 represents ~0.496
    test_values[9] = 123;
    // Fill remaining tests with random nonzero numbers
    for(i = 10; i < 50; i = i + 1) begin
      test_values[i] = ($random % ((1 << N) - 1)) + 1;
    end

    #20;
    for(i = 0; i < 50; i = i + 1) begin
      run_test(i, test_values[i]);
    end

    $display("All tests completed.");
    $finish;
  end

endmodule