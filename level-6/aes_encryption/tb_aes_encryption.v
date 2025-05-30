`timescale 1ns/1ps

module tb_aes_encryption;
  parameter NUMV = 8;

  // clock, reset, and hand-shake
  reg         clk   = 0;
  reg         rst;
  reg         start;
  reg         valid_in;

  // DUT I/O
  reg   [127:0] data_in;
  reg   [127:0] key_in;
  wire  [127:0] data_out;
  wire          valid_out;
  wire          done;

  // Instantiate the pipelined AES-128 encryptor
  aes128_pipeline #(
    .PIPELINED     (1),
    .UNROLL        (1),
    .INLINE_KEY_EXP(1)
  ) dut (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .mode      (1'b0),       // encryption
    .data_in   (data_in),
    .key_in    (key_in),
    .valid_in  (valid_in),
    .data_out  (data_out),
    .valid_out (valid_out),
    .done      (done)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // test vectors
  reg [127:0] plaintexts [0:NUMV-1];
  reg [127:0] keys       [0:NUMV-1];
  integer     idx, infile, outfile, code;

  initial begin
    // reset sequence
    rst      = 1;
    valid_in = 0;
    start    = 0;
    #20      rst = 0;

    // load exactly NUMV words from each .hex file
    $readmemh("inputs/plaintexts.hex", plaintexts, 0, NUMV-1);
    $readmemh("inputs/keys.hex",         keys,       0, NUMV-1);

    // prepare JSON output
    outfile = $fopen("outputs/dut_output.json", "w");
    $fwrite(outfile, "[\n");

    // drive each vector, wait for done, and write result
    for (idx = 0; idx < NUMV; idx = idx + 1) begin
      @(posedge clk);
      data_in   = plaintexts[idx];
      key_in    = keys[idx];
      valid_in  = 1;
      start     = 1;

      @(posedge clk);
      valid_in  = 0;
      start     = 0;

      // wait for encryption to finish
      wait (done);

      // hex-format the 128-bit output into the JSON array
      $fwrite(outfile, "  \"%032x\"", data_out);
      if (idx < NUMV-1)
        $fwrite(outfile, ",\n");
      else
        $fwrite(outfile, "\n");
    end

    // close JSON array
    $fwrite(outfile, "]\n");
    $fclose(outfile);

    $display("[PASS] AES-128 encryption vectors done");
    $finish;
  end
endmodule
