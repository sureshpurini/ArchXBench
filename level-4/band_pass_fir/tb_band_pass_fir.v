`timescale 1ns/1ps

module tb_bandpass_fir;
  parameter DATA_W  = 16;
  parameter TAP_CNT = 31;
  parameter GAIN_W  = 4;

  // Clock and reset
  reg clk = 0, rst;
  always #5 clk = ~clk;

  // DUT I/O
  reg                     valid_in;
  reg  [DATA_W-1:0]       data_in;
  wire                    valid_out;
  wire [DATA_W+GAIN_W-1:0] data_out;

  // Instantiate DUT
  bandpass_fir #(
    .DATA_W(DATA_W),
    .TAP_CNT(TAP_CNT),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk(clk), .rst(rst),
    .valid_in(valid_in), .data_in(data_in),
    .valid_out(valid_out), .data_out(data_out)
  );

  // File I/O
  integer infile, outfile, code, idx, N, flush_cnt;
  reg [DATA_W-1:0] samples [0:65535];

  initial begin
    // Reset sequence
    rst = 1; valid_in = 0; data_in = 0;
    #20 rst = 0;

    // Read stimuli.json
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli.json");
      $finish;
    idx = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile, "%d", samples[idx]);
      if (code == 1) idx = idx + 1;
      else           code = $fgetc(infile);
    end
    $fclose(infile);
    N = idx;

    // Open output file
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // Drive input stream and capture outputs
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      data_in  = samples[idx];
      if (valid_out) begin
        $fwrite(outfile, "  %0d", data_out);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end

    // Stop driving new samples
    @(posedge clk);
    valid_in = 0;

    // Flush pipeline (up to TAP_CNT pending outputs)
    for (flush_cnt = 0; flush_cnt < TAP_CNT; flush_cnt = flush_cnt + 1) begin
      @(posedge clk);
      if (valid_out) begin
        $fwrite(outfile, "  %0d", data_out);
        if (flush_cnt < TAP_CNT-1)
          $fwrite(outfile, ",\n");
        else
          $fwrite(outfile, "\n");
      end
    end

    // Close JSON array and finish
    @(posedge clk);
    $fwrite(outfile, "]\n");
    $fclose(outfile);
    $display("[PASS] bandpass_fir test completed");
    $finish;
  end
endmodule
