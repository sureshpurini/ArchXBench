`timescale 1ns/1ps

module tb_highpass_fir;
  parameter DATA_W  = 16;
  parameter TAP_CNT = 31;
  parameter GAIN_W  = 4;

  integer N;  // number of samples

  reg                    clk = 0;
  reg                    rst;
  reg                    valid_in;
  reg  [DATA_W-1:0]      data_in;
  wire                   valid_out;
  wire [DATA_W+GAIN_W-1:0] data_out;

  // DUT instantiation
  highpass_fir #(
    .DATA_W(DATA_W),
    .TAP_CNT(TAP_CNT),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk(clk), .rst(rst),
    .valid_in(valid_in), .data_in(data_in),
    .valid_out(valid_out), .data_out(data_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // I/O variables
  integer infile, outfile, code, idx, flush_cnt;
  reg [DATA_W-1:0] samples [0:65535];

  initial begin
    // Reset
    rst       = 1;
    valid_in  = 0;
    data_in   = 0;
    #20 rst   = 0;

    // Read input stimuli
    infile = $fopen("inputs/stimuli.json", "r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli.json");
      $finish;
    end
    idx = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile, "%d", samples[idx]);
      if (code == 1)
        idx = idx + 1;
      else
        code = $fgetc(infile);
    end
    $fclose(infile);
    N = idx;

    // Open DUT output file
    outfile = $fopen("outputs/dut_output.json", "w");
    $fwrite(outfile, "[\n");

    // Stream input samples and capture valid outputs
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      data_in  = samples[idx];
      if (valid_out) begin
        $fwrite(outfile, "  %0d", data_out);
        $fwrite(outfile, (idx < N-1) ? ",\n" : "\n");
      end
    end

    // Stop feeding new samples
    @(posedge clk);
    valid_in = 0;

    // Flush pipeline outputs
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

    // Close JSON array and file
    $fwrite(outfile, "]\n");
    $fclose(outfile);
    $display("[PASS] highpass_fir test completed (flushed outputs)");
    $finish;
  end
endmodule
