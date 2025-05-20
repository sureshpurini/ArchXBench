`timescale 1ns/1ps

module tb_restoring_div_benchmark;
  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------
  parameter WIDTH      = 16;
  parameter NUM_RANDOM = 100;

  //--------------------------------------------------------------------------
  // DUT I/Os
  //--------------------------------------------------------------------------
  reg                   clk, rst;
  reg                   valid_in, start;
  reg  [WIDTH-1:0]      dividend, divisor;
  wire [WIDTH-1:0]      quotient, remainder;
  wire                  valid_out, done;

  // Instantiate the divider under test
  restoring_div #(WIDTH) dut (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .valid_in  (valid_in),
    .dividend  (dividend),
    .divisor   (divisor),
    .quotient  (quotient),
    .remainder (remainder),
    .valid_out (valid_out),
    .done      (done)
  );

  //--------------------------------------------------------------------------
  // Testbench bookkeeping
  //--------------------------------------------------------------------------
  integer pass_count = 0, fail_count = 0;
  integer i;

  //--------------------------------------------------------------------------
  // Clock generator: 10 ns period
  //--------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  //--------------------------------------------------------------------------
  // Task: perform one division test
  //--------------------------------------------------------------------------
  task run_test;
    input  [WIDTH-1:0] dvd;
    input  [WIDTH-1:0] dvs;
    input  integer     idx;
    input  [8*32:1]    label; // up to 32-char description
    reg    [WIDTH-1:0] exp_q, exp_r;
    begin
      exp_q = dvd / dvs;
      exp_r = dvd % dvs;

      // Apply inputs for exactly one cycle
      @(posedge clk);
      valid_in = 1; start = 1;
      dividend = dvd; divisor = dvs;
      @(posedge clk);
      valid_in = 0; start = 0;

      // Wait for done & sample
      wait (done);
      @(posedge clk);

      // Check results
      if (quotient === exp_q && remainder === exp_r) begin
        pass_count = pass_count + 1;
        $display("[PASS] %s[%0d]: %0d / %0d = Q=%0d R=%0d",
                 label, idx, dvd, dvs, quotient, remainder);
      end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] %s[%0d]: %0d / %0d → Expected Q=%0d R=%0d, Got Q=%0d R=%0d",
                 label, idx, dvd, dvs, exp_q, exp_r, quotient, remainder);
      end

      // Small gap before next test
      @(posedge clk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Main test sequence
  //--------------------------------------------------------------------------
  initial begin
    // Initialize & reset
    rst      = 1;
    valid_in = 0;
    start    = 0;
    dividend = 0;
    divisor  = 0;
    #20 rst  = 0;

    // -- Static corner‐case vectors --
    run_test(16'd0,     16'd7,    0, "Zero dividend < divisor");
    run_test(16'd100,   16'd3,    1, "Small values");
    run_test(16'd12345, 16'd123,  2, "Medium values");
    run_test(16'd65535, 16'd255,  3, "Max‐width operands");
    run_test(16'd500,   16'd500,  4, "Equal operands");
    run_test(16'd9999,  16'd1,    5, "Divisor = 1");

    // -- Back‐to‐back operations --
    run_test(16'd2000,  16'd37,   6, "Back2Back #1");
    run_test(16'd1234,  16'd56,   7, "Back2Back #2");

    // -- Randomized stress tests (exclude divisor=0) --
    for (i = 0; i < NUM_RANDOM; i = i + 1) begin
      reg [WIDTH-1:0] rdvd, rdvs;
      rdvd = $random;                // 32-bit random, will be truncated
      rdvs = $random;
      rdvs = rdvs[WIDTH-1:0];        // mask
      if (rdvs == 0) rdvs = 1;       // avoid divide‐by‐zero
      run_test(rdvd, rdvs, 8 + i, "Random");
    end

    // Final summary
    $display("\n== Benchmark complete: %0d passed, %0d failed ==", pass_count, fail_count);
    $finish;
  end

endmodule
