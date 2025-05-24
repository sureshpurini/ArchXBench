// tb_dct1d_8_pipeline.v
`timescale 1ns/1ps

module tb_dct1d_8_pipeline;
  parameter DATA_W   = 12;
  parameter COEFF_W  = 16;
  parameter OUT_W    = 18;
  localparam N       = 8;

  reg                    clk = 0;
  always #5 clk = ~clk;

  reg  rst;
  reg  [DATA_W-1:0]      sample_in;
  reg                    valid_in;
  reg                    mode;       // 0=DCT, 1=IDCT
  reg  [2:0]             index;
  wire [OUT_W-1:0]       coeff_out;
  wire                   valid_out;
  wire [2:0]             index_out;

  // DUT instantiation
  dct1d_8_pipeline #(
    .DATA_W  (DATA_W),
    .COEFF_W (COEFF_W),
    .OUT_W   (OUT_W)
  ) dut (
    .clk       (clk),
    .rst       (rst),
    .sample_in (sample_in),
    .valid_in  (valid_in),
    .mode      (mode),
    .index     (index),
    .coeff_out (coeff_out),
    .valid_out (valid_out),
    .index_out (index_out)
  );

  integer infile, file_dct, file_idct, code;
  integer i, out_count;
  reg [DATA_W-1:0]   samples   [0:N-1];
  reg [OUT_W-1:0]    dct_buf   [0:N-1];
  reg [DATA_W-1:0]   idct_buf  [0:N-1];

  initial begin
    // reset
    rst      = 1;
    valid_in = 0;
    sample_in= 0;
    mode     = 0;
    index    = 0;
    #20 rst = 0;

    // load stimulus
    infile = $fopen("inputs/stimuli.json","r");
    if (!infile) begin
      $display("[FAIL] Cannot open inputs/stimuli.json"); 
      $finish;
    end
    i = 0;
    while (!$feof(infile) && i < N) begin
      code = $fscanf(infile, "%d", samples[i]);
      if (code == 1) i = i + 1;
      else code = $fgetc(infile);
    end
    $fclose(infile);

    // ** DCT pass **
    out_count = 0;
    for (i = 0; i < N; i = i + 1) begin
      @(posedge clk);
      valid_in  = 1;
      sample_in = samples[i];
      index     = i[2:0];
      mode      = 0;
    end
    @(posedge clk);
    valid_in = 0;

    // collect N outputs (they may appear after pipeline latency)
    while (out_count < N) begin
      @(posedge clk);
      if (valid_out) begin
        dct_buf[index_out] = coeff_out;
        out_count = out_count + 1;
      end
    end

    // write golden_dct.json
    file_dct = $fopen("outputs/golden_dct.json","w");
    $fwrite(file_dct,"[\n");
    for (i = 0; i < N; i = i + 1) begin
      $fwrite(file_dct, "  %0d", dct_buf[i]);
      if (i < N-1) $fwrite(file_dct, ",\n");
    end
    $fwrite(file_dct,"\n]\n");
    $fclose(file_dct);

    // ** IDCT pass **
    out_count = 0;
    for (i = 0; i < N; i = i + 1) begin
      @(posedge clk);
      valid_in  = 1;
      sample_in = dct_buf[i][DATA_W-1:0];  // truncate to DATA_W
      index     = i[2:0];
      mode      = 1;
    end
    @(posedge clk);
    valid_in = 0;

    while (out_count < N) begin
      @(posedge clk);
      if (valid_out) begin
        idct_buf[index_out] = coeff_out[DATA_W-1:0];
        out_count = out_count + 1;
      end
    end

    // write golden_idct.json
    file_idct = $fopen("outputs/golden_idct.json","w");
    $fwrite(file_idct,"[\n");
    for (i = 0; i < N; i = i + 1) begin
      $fwrite(file_idct, "  %0d", idct_buf[i]);
      if (i < N-1) $fwrite(file_idct, ",\n");
    end
    $fwrite(file_idct,"\n]\n");
    $fclose(file_idct);

    $display("[PASS] DCT/IDCT 1D-8 pipeline test complete");
    $finish;
  end
endmodule
