`timescale 1ns/1ps

module tb_bandpass_fir;
  parameter TAP_CNT = 31;

  // Clock & reset
  reg        clk = 0;
  reg        rst;
  reg        valid_in;
  reg [31:0] data_in;
  wire       valid_out;
  wire [31:0] data_out;

  // Coefficients array (31-tap bandpass FIR: 0.8–3 kHz, Fs=50 kHz)
  reg [31:0] coeffs [0:TAP_CNT-1];
  integer j;

  // Instantiate DUT
  fp_bandpass_fir #(
    .TAP_CNT(TAP_CNT)
  ) dut (
    .clk       (clk),
    .rst       (rst),
    .valid_in  (valid_in),
    .data_in   (data_in),
    .valid_out (valid_out),
    .data_out  (data_out)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // File I/O and sample storage
  integer infile, outfile, code, idx, N;
  reg [31:0] samples [0:65535];

  initial begin
    // --- Initialize coefficients ---
    coeffs[ 0] = 32'hbb306eeb; // -0.002692
    coeffs[ 1] = 32'hbb75b0a5; // -0.003749
    coeffs[ 2] = 32'hbbbb295a; // -0.005712
    coeffs[ 3] = 32'hbc0bd069; // -0.008534
    coeffs[ 4] = 32'hbc3f59f2; // -0.011679
    coeffs[ 5] = 32'hbc6787ee; // -0.014132
    coeffs[ 6] = 32'hbc6e9b06; // -0.014563
    coeffs[ 7] = 32'hbc3ecbfc; // -0.011645
    coeffs[ 8] = 32'hbb90d9b1; // -0.004420
    coeffs[ 9] = 32'h3bf10411; //  0.007355
    coeffs[10] = 32'h3cbc752e; //  0.023005
    coeffs[11] = 32'h3d27a476; //  0.040928
    coeffs[12] = 32'h3d70effe; //  0.058823
    coeffs[13] = 32'h3d97bf5e; //  0.074095
    coeffs[14] = 32'h3dacccb2; //  0.084375
    coeffs[15] = 32'h3db43958; //  0.088000
    coeffs[16] = 32'h3dacccb2; //  0.084375
    coeffs[17] = 32'h3d97bf5e; //  0.074095
    coeffs[18] = 32'h3d70effe; //  0.058823
    coeffs[19] = 32'h3d27a476; //  0.040928
    coeffs[20] = 32'h3cbc752e; //  0.023005
    coeffs[21] = 32'h3bf10411; //  0.007355
    coeffs[22] = 32'hbb90d9b1; // -0.004420
    coeffs[23] = 32'hbc3ecbfc; // -0.011645
    coeffs[24] = 32'hbc6e9b06; // -0.014563
    coeffs[25] = 32'hbc6787ee; // -0.014132
    coeffs[26] = 32'hbc3f59f2; // -0.011679
    coeffs[27] = 32'hbc0bd069; // -0.008534
    coeffs[28] = 32'hbbbb295a; // -0.005712
    coeffs[29] = 32'hbb75b0a5; // -0.003749
    coeffs[30] = 32'hbb306eeb; // -0.002692

    // Load coefficients into DUT
    for (j = 0; j < TAP_CNT; j = j + 1) begin
      dut.coeffs[j] = coeffs[j];
    end

    // --- Reset and start ---
    rst      = 1;
    valid_in = 0;
    data_in  = 32'h00000000;
    #20 rst  = 0;

    // --- Load input stimuli ---
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli.json");
      $finish;
    end

    idx = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile, "%h", samples[idx]);
      if (code == 1)
        idx = idx + 1;
      else
        code = $fgetc(infile);
    end
    $fclose(infile);
    N = idx;

    // --- Open output ---
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // --- Drive through DUT and capture ---
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      data_in  = samples[idx];
      if (valid_out) begin
        $fwrite(outfile, "  \"%h\"", data_out);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end

    // --- Flush pipeline ---
    @(posedge clk);
    valid_in = 0;
    for (idx = 0; idx < TAP_CNT; idx = idx + 1) begin
      @(posedge clk);
      if (valid_out) begin
        $fwrite(outfile, "  \"%h\"", data_out);
        if (idx < TAP_CNT-1) $fwrite(outfile, ",\n");
        else                 $fwrite(outfile, "\n");
      end
    end

    // --- Close and finish ---
    $fwrite(outfile, "]\n");
    $fclose(outfile);
    $display("[PASS] BPF floating-point test complete");
    $finish;
  end
endmodule
