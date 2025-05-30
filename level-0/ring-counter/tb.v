`timescale 1ns/1ps

module tb_ring_counter4;
  // Clock and reset
  reg        clk = 0;
  reg        rst;
  wire [3:0] q;

  // Instantiate DUT
  ring_counter4 dut (
    .clk(clk),
    .rst(rst),
    .q(q)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // Expected one-hot sequence
  reg [3:0] expected [0:3];
  integer   idx;
  integer   errors;

  initial begin
    // Initialize expected states
    expected[0] = 4'b0001;
    expected[1] = 4'b0010;
    expected[2] = 4'b0100;
    expected[3] = 4'b1000;
    errors      = 0;

    // Apply synchronous reset
    rst = 1;
    #12;       // hold reset through at least one rising edge
    rst = 0;

    // Test 8 clock cycles (two full loops)
    for (idx = 0; idx < 8; idx = idx + 1) begin
      @(posedge clk);
      if (q !== expected[idx % 4]) begin
        $display("[FAIL] Cycle %0d: q=%b, expected %b", idx, q, expected[idx % 4]);
        errors = errors + 1;
      end else begin
        $display("[PASS] Cycle %0d: q=%b", idx, q);
      end
    end

    if (errors == 0)
      $display("All tests passed.");
    else
      $display("%0d error(s) detected.", errors);

    $finish;
  end
endmodule
