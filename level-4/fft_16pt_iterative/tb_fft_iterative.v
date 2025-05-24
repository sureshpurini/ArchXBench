`timescale 1ns/1ps

module tb_fft16_iterative;
  parameter N      = 16;
  parameter DATA_W = 12;
  parameter GAIN_W = 4;

  // Clock & control
  reg clk = 0;
  reg rst;
  reg start;
  reg mode; // 0 = FFT, 1 = IFFT

  // I/O arrays (unpacked)
  reg  signed [DATA_W-1:0] data_real_in [0:N-1];
  reg  signed [DATA_W-1:0] data_imag_in [0:N-1];
  wire signed [DATA_W+GAIN_W-1:0] data_real_out [0:N-1];
  wire signed [DATA_W+GAIN_W-1:0] data_imag_out [0:N-1];
  wire done;

  // DUT instantiation
  fft16_iterative #(
    .N(N),
    .DATA_W(DATA_W),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .mode(mode),
    .data_real_in(data_real_in),
    .data_imag_in(data_imag_in),
    .data_real_out(data_real_out),
    .data_imag_out(data_imag_out),
    .done(done)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // Storage for stimulus and golden reference
  integer stim_f, gold_f, code, idx, i;
  integer stim_mem   [0:2*N-1];
  integer golden_mem [0:4*N-1];

  initial begin
    // Reset pulse
    rst   = 1;
    start = 0;
    mode  = 0;
    #20   rst = 0;

    // Load stimulus (real[0..15], imag[0..15])
    stim_f = $fopen("inputs/stimuli.json", "r");
    if (!stim_f) $fatal("[FAIL] Couldn't open inputs/stimuli.json");
    idx = 0;
    while (!$feof(stim_f)) begin
      code = $fscanf(stim_f, "%d", stim_mem[idx]);
      if (code == 1) idx = idx + 1;
      else                code = $fgetc(stim_f);
    end
    $fclose(stim_f);
    if (idx != 2*N) $fatal("[FAIL] Expected %0d stimulus values, got %0d", 2*N, idx);

    // Assign into DUT input arrays
    for (i = 0; i < N; i = i + 1) begin
      data_real_in[i] = stim_mem[i];
      data_imag_in[i] = stim_mem[N + i];
    end

    // Load golden outputs (fft_real[0..15], fft_imag[0..15],
    //                       ifft_real[0..15], ifft_imag[0..15])
    gold_f = $fopen("inputs/golden_output.json", "r");
    if (!gold_f) $fatal("[FAIL] Couldn't open inputs/golden_output.json");
    idx = 0;
    while (!$feof(gold_f)) begin
      code = $fscanf(gold_f, "%d", golden_mem[idx]);
      if (code == 1) idx = idx + 1;
      else             code = $fgetc(gold_f);
    end
    $fclose(gold_f);
    if (idx != 4*N) $fatal(
      "[FAIL] Expected %0d golden values, got %0d", 4*N, idx
    );

    // --- FFT mode ---
    mode = 0;
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    wait (done);

    // Check FFT outputs against golden_mem[0..2*N-1]
    for (i = 0; i < N; i = i + 1) begin
      if (data_real_out[i] !== golden_mem[i]) $fatal(
        "FFT real[%0d]: got %0d, expected %0d",
         i, data_real_out[i], golden_mem[i]
      );
      if (data_imag_out[i] !== golden_mem[N + i]) $fatal(
        "FFT imag[%0d]: got %0d, expected %0d",
         i, data_imag_out[i], golden_mem[N + i]
      );
    end

    // --- IFFT mode (feed FFT outputs back) ---
    for (i = 0; i < N; i = i + 1) begin
      data_real_in[i] = data_real_out[i];
      data_imag_in[i] = data_imag_out[i];
    end

    mode = 1;
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    wait (done);

    // Check IFFT outputs against golden_mem[2*N..4*N-1]
    for (i = 0; i < N; i = i + 1) begin
      if (data_real_out[i] !== golden_mem[2*N + i]) $fatal(
        "IFFT real[%0d]: got %0d, expected %0d",
         i, data_real_out[i], golden_mem[2*N + i]
      );
      if (data_imag_out[i] !== golden_mem[3*N + i]) $fatal(
        "IFFT imag[%0d]: got %0d, expected %0d",
         i, data_imag_out[i], golden_mem[3*N + i]
      );
    end

    $display("[PASS] fft16_iterative");
    $finish;
  end
endmodule
