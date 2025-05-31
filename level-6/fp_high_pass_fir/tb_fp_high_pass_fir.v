`timescale 1ns/1ps

module tb_highpass_fir;
  parameter TAP_CNT = 31;

  // Clock & reset
  reg        clk = 0;
  reg        rst;
  reg        valid_in;
  reg [31:0] data_in;
  wire       valid_out;
  wire [31:0] data_out;

  // Highpass coefficients (5 kHz cutoff, Fs=50 kHz)
  reg [31:0] coeffs [0:TAP_CNT-1];
  integer j;

  // Instantiate DUT
  fp_highpass_fir #(
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

  // I/O storage
  integer infile, outfile, code, idx, N;
  reg [31:0] samples [0:65535];

  initial begin
    // Initialize taps
    coeffs[ 0] = 32'ha1381601;
    coeffs[ 1] = 32'hba9dbdb2;
    coeffs[ 2] = 32'hbb36c8a9;
    coeffs[ 3] = 32'hbb8ac191;
    coeffs[ 4] = 32'hbb816a82;
    coeffs[ 5] = 32'h22325551;
    coeffs[ 6] = 32'h3c07824b;
    coeffs[ 7] = 32'h3c987e0d;
    coeffs[ 8] = 32'h3cd058cf;
    coeffs[ 9] = 32'h3cae415b;
    coeffs[10] = 32'ha2dd7a7a;
    coeffs[11] = 32'hbd226db2;
    coeffs[12] = 32'hbdbc821d;
    coeffs[13] = 32'hbe14d580;
    coeffs[14] = 32'hbe3da98f;
    coeffs[15] = 32'h3f4ccccd;
    coeffs[16] = 32'hbe3da98f;
    coeffs[17] = 32'hbe14d580;
    coeffs[18] = 32'hbdbc821d;
    coeffs[19] = 32'hbd226db2;
    coeffs[20] = 32'ha2dd7a7a;
    coeffs[21] = 32'h3cae415b;
    coeffs[22] = 32'h3cd058cf;
    coeffs[23] = 32'h3c987e0d;
    coeffs[24] = 32'h3c07824b;
    coeffs[25] = 32'h22325551;
    coeffs[26] = 32'hbb816a82;
    coeffs[27] = 32'hbb8ac191;
    coeffs[28] = 32'hbb36c8a9;
    coeffs[29] = 32'hba9dbdb2;
    coeffs[30] = 32'ha1381601;

    // Load taps into DUT
    for (j = 0; j < TAP_CNT; j = j + 1)
      dut.coeffs[j] = coeffs[j];

    // Reset
    rst      = 1;
    valid_in = 0;
    data_in  = 0;
    #20 rst  = 0;

    // Read stimuli
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin $display("[FAIL] No stimuli"); $finish; end
    idx = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile, "%h", samples[idx]);
      if (code == 1) idx = idx + 1;
      else            code = $fgetc(infile);
    end
    $fclose(infile);
    N = idx;

    // Open output
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // Drive & capture
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1; data_in = samples[idx];
      if (valid_out) begin
        $fwrite(outfile, "  \"%h\"", data_out);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end

    // Flush
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

    // Finish
    $fwrite(outfile, "]\n");
    $fclose(outfile);
    $display("[PASS] Highpass FIR test complete");
    $finish;
  end
endmodule