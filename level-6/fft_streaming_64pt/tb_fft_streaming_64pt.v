// tb_fft64_streaming.v
`timescale 1ns/1ps

module tb_fft64_streaming;
  // Parameters
  parameter DATA_W  = 16;
  parameter POINTS  = 64;
  parameter GROWTH  = 4;
  localparam OUT_W  = DATA_W + GROWTH;
  localparam STAGES = $clog2(POINTS);

  // Clock & reset
  reg                    clk      = 0;
  reg                    rst;
  always #5 clk = ~clk;

  // DUT I/O
  reg  signed [DATA_W-1:0] real_in, imag_in;
  reg                    valid_in, last_in;
  wire signed [OUT_W-1:0] real_out, imag_out;
  wire                   valid_out, last_out, done;

  // Instantiate FFT-64 streaming pipelined DUT
  fft64_streaming #(
    .DATA_W(DATA_W),
    .POINTS(POINTS),
    .GROWTH(GROWTH)
  ) dut (
    .clk      (clk),
    .rst      (rst),
    .real_in  (real_in),
    .imag_in  (imag_in),
    .valid_in (valid_in),
    .last_in  (last_in),
    .real_out (real_out),
    .imag_out (imag_out),
    .valid_out(valid_out),
    .last_out (last_out),
    .done     (done)
  );

  // File I/O
  integer infile, outfile, code, idx, flush_cnt;
  reg signed [DATA_W-1:0] real_samples [0:POINTS-1];
  reg signed [DATA_W-1:0] imag_samples [0:POINTS-1];

  initial begin
    // reset sequence
    rst      = 1;
    valid_in = 0;
    last_in  = 0;
    real_in  = 0;
    imag_in  = 0;
    #20 rst = 0;

    // read stimulus file: each line "real imag"
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli_hex.json");
      $finish;
    end
    idx = 0;
    while (!$feof(infile) && idx < POINTS) begin
      code = $fscanf(infile, "%d %d\n", real_samples[idx], imag_samples[idx]);
      if (code == 2) begin
        idx = idx + 1;
      end else begin
        code = $fgetc(infile);
      end
    end
    $fclose(infile);

    // open output file
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // drive samples into DUT
    for (idx = 0; idx < POINTS; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      last_in  = (idx == POINTS-1);
      real_in  = real_samples[idx];
      imag_in  = imag_samples[idx];

      if (valid_out) begin
        $fwrite(outfile, "  {\"real\": %0d, \"imag\": %0d}", real_out, imag_out);
        if (!(last_out && idx==POINTS-1)) $fwrite(outfile, ",\n");
        else                              $fwrite(outfile, "\n");
      end
    end

    // flush the pipeline
    @(posedge clk);
    valid_in = 0; last_in = 0;
    for (flush_cnt = 0; flush_cnt < STAGES; flush_cnt = flush_cnt + 1) begin
      @(posedge clk);
      if (valid_out) begin
        $fwrite(outfile, "  {\"real\": %0d, \"imag\": %0d}", real_out, imag_out);
        if (!last_out) $fwrite(outfile, ",\n");
        else           $fwrite(outfile, "\n");
      end
    end

    // finish up
    @(posedge clk);
    $fwrite(outfile, "]\n");
    $fclose(outfile);
    $display("[PASS] fft64_streaming test completed");
    $finish;
  end
endmodule
