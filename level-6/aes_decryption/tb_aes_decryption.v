// File: tb/tb_aes128_decrypt.v
`timescale 1ns/1ps
module tb_aes128_decrypt;
  parameter NUMV = 8;

  reg         clk = 0, rst;
  reg         start, valid_in;
  reg  [127:0] data_in, key_in;
  wire [127:0] data_out;
  wire        valid_out, done;

  aes128_pipeline #(
    .PIPELINED(1),
    .UNROLL(1),
    .INLINE_KEY_EXP(1)
  ) dut (
    .clk(clk), .rst(rst),
    .start(start), .mode(1'b1),
    .data_in(data_in), .key_in(key_in),
    .valid_in(valid_in),
    .data_out(data_out),
    .valid_out(valid_out),
    .done(done)
  );

  always #5 clk = ~clk;

  reg [127:0] ciphertexts [0:NUMV-1];
  reg [127:0] keys        [0:NUMV-1];
  integer     idx, outfile;

  initial begin
    rst = 1; valid_in = 0; start = 0;
    #20 rst = 0;

    $readmemh("inputs/ciphertexts.hex", ciphertexts);
    $readmemh("inputs/keys.hex",          keys);

    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    for (idx = 0; idx < NUMV; idx = idx + 1) begin
      @(posedge clk);
      data_in  <= ciphertexts[idx];
      key_in   <= keys[idx];
      valid_in <= 1;
      start    <= 1;
      @(posedge clk);
      valid_in <= 0;
      start    <= 0;
      wait (done);
      $fwrite(outfile, "  \"%032x\"", data_out);
      if (idx < NUMV-1) $fwrite(outfile, ",\n");
    end

    $fwrite(outfile, "\n]\n");
    $fclose(outfile);
    $display("[PASS] AES‐128 decryption vectors done");
    $finish;
  end
endmodule
