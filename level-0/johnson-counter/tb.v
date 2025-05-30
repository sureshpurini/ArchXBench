`timescale 1ns/1ps

module tb_johnson_counter4;
  // DUT interface
  reg         clk;
  reg         rst;
  wire [3:0]  q;

  // Instantiate the Johnson counter
  johnson_counter4 dut (
    .clk(clk),
    .rst(rst),
    .q(q)
  );

  // Clock generation: 10 ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Expected 8‐state sequence
  reg [3:0] expected [7:0];
  initial begin
    expected[0] = 4'b0000;
    expected[1] = 4'b0001;
    expected[2] = 4'b0011;
    expected[3] = 4'b0111;
    expected[4] = 4'b1111;
    expected[5] = 4'b1110;
    expected[6] = 4'b1100;
    expected[7] = 4'b1000;
  end

  integer i;
  initial begin
    // Synchronous reset: hold high for two clock edges
    rst = 1;
    @(posedge clk);
    @(posedge clk);
    rst = 0;

    // Run 16 cycles (two full 8‐state loops)
    for (i = 0; i < 16; i = i + 1) begin
      @(posedge clk);
      if (q !== expected[i % 8]) begin
        $display("ERROR @ cycle %0d: got %b, expected %b", i, q, expected[i % 8]);
      end else begin
        $display("Cycle %0d: q = %b OK", i, q);
      end
    end

    $display("Testbench complete.");
    $finish;
  end

endmodule
