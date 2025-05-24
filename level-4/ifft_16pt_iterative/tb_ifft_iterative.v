`timescale 1ns/1ps

module tb_ifft16;
  parameter N        = 16;
  parameter DATA_W   = 12;
  parameter COEFF_W  = 16;
  parameter GAIN_W   = 4;

  // clocks and control
  reg                       clk = 0;
  reg                       rst = 1;
  reg                       start;
  reg                       mode;       // 0 = FFT, 1 = IFFT

  // input / output arrays
  reg  signed [DATA_W-1:0]             data_real_in  [0:N-1];
  reg  signed [DATA_W-1:0]             data_imag_in  [0:N-1];
  wire signed [DATA_W+GAIN_W-1:0]      data_real_out [0:N-1];
  wire signed [DATA_W+GAIN_W-1:0]      data_imag_out [0:N-1];
  wire                                  done;

  // Instantiate DUT
  fft16_iterative #(
    .N(N),
    .DATA_W(DATA_W),
    .COEFF_W(COEFF_W),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk          (clk),
    .rst          (rst),
    .start        (start),
    .mode         (mode),
    .data_real_in (data_real_in),
    .data_imag_in (data_imag_in),
    .data_real_out(data_real_out),
    .data_imag_out(data_imag_out),
    .done         (done)
  );

  // toggle clock
  always #5 clk = ~clk;

  integer infile, outfile, code, idx;

  initial begin
    // reset
    #10 rst = 0;
    mode = 1;      // IFFT mode
    start = 0;

    // read inputs from stimuli.json (assumes pairs of decimal ints per line)
    infile = $fopen("inputs/stimuli.json", "r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli.json");
      $finish;
    end

    idx = 0;
    while (!$feof(infile) && idx < N) begin
      code = $fscanf(infile, "%d %d", data_real_in[idx], data_imag_in[idx]);
      if (code == 2) begin
        idx = idx + 1;
      end else begin
        // skip any non-integer characters
        $fgetc(infile);
      end
    end
    $fclose(infile);

    // apply start pulse
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    // wait for done
    wait (done);

    // dump outputs to JSON
    outfile = $fopen("outputs/dut_ifft_output.json", "w");
    if (outfile == 0) begin
      $display("[FAIL] Cannot open outputs/dut_ifft_output.json");
      $finish;
    end

    $fwrite(outfile, "[\n");
    for (idx = 0; idx < N; idx = idx + 1) begin
      $fwrite(outfile, "  {\"real\": %0d, \"imag\": %0d}", 
              data_real_out[idx], data_imag_out[idx]);
      if (idx < N-1)
        $fwrite(outfile, ",\n");
      else
        $fwrite(outfile, "\n");
    end
    $fwrite(outfile, "]\n");
    $fclose(outfile);

    $display("[PASS] IFFT16 test completed");
    $finish;
  end

endmodule
