// tb_lowpass_fir_fp.v
`timescale 1ns/1ps

module tb_lowpass_fir_fp;
  parameter TAP_CNT = 31;
  integer N, idx, code, infile, outfile;
  reg clk = 0;
  reg rst;
  reg valid_in;
  reg [31:0] data_in;
  wire valid_out;
  wire [31:0] data_out;

  // instantiate your floating-point LPF
  fp_lowpass_fir #(.TAP_CNT(TAP_CNT)) dut (
    .clk       (clk),
    .rst       (rst),
    .valid_in  (valid_in),
    .data_in   (data_in),
    .valid_out (valid_out),
    .data_out  (data_out)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // read stimuli_fp.json (hex IEEE-754 words) and write lowpass_out_fp.json
  reg [31:0] samples [0:65535];
  initial begin
    rst = 1; valid_in = 0; data_in = 32'h0;
    #20 rst = 0;

    infile = $fopen("inputs/stimuli_fp.json","r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli_fp.json"); $finish;
    end

    idx = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile, "%h", samples[idx]);
      if (code == 1) idx = idx + 1;
      else $fgetc(infile);
    end
    N = idx;
    $fclose(infile);

    outfile = $fopen("outputs/lowpass_out_fp.json","w");
    $fwrite(outfile,"[\n");
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1; data_in = samples[idx];
      if (valid_out) begin
        $fwrite(outfile, "  \"%h\"", data_out);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end
    @(posedge clk);
    $fwrite(outfile,"\n]\n");
    $fclose(outfile);
    $display("[PASS] LPF floating-point test complete");
    $finish;
  end
endmodule
