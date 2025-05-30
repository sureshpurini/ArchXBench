`timescale 1ns/1ps

module tb_fft_16pt_iterative;
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

  // Instantiate DUT
  fft16_iterative #(
    .N(N),
    .DATA_W(DATA_W),
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

  // 100 MHz clock
  always #5 clk = ~clk;

  // File handles & memories
  integer real_f, imag_f, gold_f, out_f, dummy;
  integer code, idx, i;
  integer stim_mem   [0:2*N-1];
  integer golden_mem [0:4*N-1];

  initial begin
  // Reset
  rst   = 1;
  start = 0;
  mode  = 0;
  #20   rst = 0;

    // ——— Load REAL samples ———
    real_f = $fopen("inputs/stimuli-real.json","r");
    if (real_f == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli-real.json");
      $finish;
    end

    for (i = 0; i < N; i = i + 1) begin
      // keep scanning until we actually get one integer
      do begin
        code = $fscanf(real_f, "%d", data_real_in[i]);
        if (code != 1) dummy = $fgetc(real_f);
      end while (code != 1);
    end
    $fclose(real_f);

    // ——— Load IMAG samples ———
    imag_f = $fopen("inputs/stimuli-imag.json","r");
    if (imag_f == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli-imag.json");
      $finish;
    end

    for (i = 0; i < N; i = i + 1) begin
      do begin
        code = $fscanf(imag_f, "%d", data_imag_in[i]);
        if (code != 1) dummy = $fgetc(imag_f);
      end while (code != 1);
    end
    $fclose(imag_f);

    // (Optional) verify load
    $display("Loaded REAL:");
    for (i = 0; i < N; i = i + 1)
      $display("  [%0d] = %0d", i, data_real_in[i]);
    $display("Loaded IMAG:");
    for (i = 0; i < N; i = i + 1)
      $display("  [%0d] = %0d", i, data_imag_in[i]);
  // … then your existing FFT drive/dump logic follows …  


    // Feed stimulus into DUT inputs
    for (i = 0; i < N; i = i + 1) begin
      data_real_in[i] = stim_mem[i];
      data_imag_in[i] = stim_mem[N + i];
    end

    // --- FFT mode ---
    mode = 0;
    @(posedge clk) start = 1;
    @(posedge clk) start = 0;
    wait (done);

    // Dump DUT outputs into JSON
    out_f = $fopen("outputs/dut_output.json","w");
    $fwrite(out_f, "{\n");
    // real array
    $fwrite(out_f, "  \"real\": [\n");
    for (i = 0; i < N; i = i + 1) begin
      $fwrite(out_f, "    %0d", data_real_out[i]);
      if (i < N-1) $fwrite(out_f, ",\n");
      else         $fwrite(out_f, "\n");
    end
    $fwrite(out_f, "  ],\n");
    // imag array
    $fwrite(out_f, "  \"imag\": [\n");
    for (i = 0; i < N; i = i + 1) begin
      $fwrite(out_f, "    %0d", data_imag_out[i]);
      if (i < N-1) $fwrite(out_f, ",\n");
      else         $fwrite(out_f, "\n");
    end
    $fwrite(out_f, "  ]\n");
    $fwrite(out_f, "}\n");
    $fclose(out_f);

    $display("[INFO] DUT output written to outputs/dut_output.json");

    // (Optional) continue with golden‐comparison and IFFT below...
    // ----------------------------------------------------------
    // Load golden outputs, check FFT & IFFT, etc.
    // ----------------------------------------------------------

    $finish;
  end
endmodule
