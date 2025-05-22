// File: tb/tb_aes128_encrypt.v
`timescale 1ns/1ps
module tb_aes128_encrypt;
  parameter NUMV = 8;

  reg         clk = 0, rst;
  reg         start, valid_in;
  reg  [127:0] data_in, key_in;
  wire [127:0] data_out;
  wire        valid_out, done;

  // Instantiate DUT
  aes128_pipeline #(
    .PIPELINED(1),
    .UNROLL(1),
    .INLINE_KEY_EXP(1)
  ) dut (
    .clk(clk), .rst(rst),
    .start(start), .mode(1'b0),
    .data_in(data_in), .key_in(key_in),
    .valid_in(valid_in),
    .data_out(data_out),
    .valid_out(valid_out),
    .done(done)
  );

  // Clock
  always #5 clk = ~clk;

  // Test vectors
  reg [127:0] plaintexts [0:NUMV-1];
  reg [127:0] keys       [0:NUMV-1];
  integer    idx, infile, outfile, code;

  initial begin
    rst = 1; valid_in = 0; start = 0;
    #20 rst = 0;

    // load hex‐formatted vectors (one per line, no 0x)
    $readmemh("inputs/plaintexts.hex", plaintexts);
    $readmemh("inputs/keys.hex",         keys);

    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // drive inputs
    for (idx = 0; idx < NUMV; idx = idx + 1) begin
      @(posedge clk);
      data_in  <= plaintexts[idx];
      key_in   <= keys[idx];
      valid_in <= 1;
      start    <= 1;
      @(posedge clk);
      valid_in <= 0;
      start    <= 0;
      // wait for done
      wait (done);
      $fwrite(outfile, "  \"%032x\"", data_out);
      if (idx < NUMV-1) $fwrite(outfile, ",\n");
    end

    $fwrite(outfile, "\n]\n");
    $fclose(outfile);
    $display("[PASS] AES‐128 encryption vectors done");
    $finish;
  end
endmodule
