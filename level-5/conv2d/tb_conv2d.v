`timescale 1ns/1ps

module tb_conv2d;
  parameter DATA_W      = 8;
  parameter IMG_WIDTH   = 64;
  parameter GAIN_W      = 4;

  reg                     clk, rst;
  reg                     valid_in;
  reg  [DATA_W-1:0]       pixel_in;
  wire                    valid_out;
  wire [DATA_W+GAIN_W-1:0] pixel_out;

  // DUT
  conv2d #(
    .DATA_W(DATA_W),
    .IMG_WIDTH(IMG_WIDTH),
    .KERNEL_SIZE(3),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk(clk), .rst(rst),
    .valid_in(valid_in), .pixel_in(pixel_in),
    .valid_out(valid_out), .pixel_out(pixel_out)
  );

  // JSON I/O
  integer infile, outfile, code;
  reg [31:0] stimuli [0:65535];
  integer N, idx;

  // clock
  initial clk = 0; always #5 clk = ~clk;

  initial begin
    // reset
    rst      = 1; valid_in = 0; pixel_in = 0;
    #20 rst  = 0;

    // load flat pixel array
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] Cannot open inputs/stimuli.json"); $finish;
    end
    N = 0;
    while (!$feof(infile)) begin
      code = $fscanf(infile,"%d",stimuli[N]);
      if (code == 1) N = N + 1;
      else         code = $fgetc(infile);
    end
    $fclose(infile);

    // open output JSON
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile,"[\n");

    // feed and capture
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in <= 1;
      pixel_in <= stimuli[idx][DATA_W-1:0];

      if (valid_out) begin
        $fwrite(outfile,"  %0d", pixel_out);
        if (idx < N-1) $fwrite(outfile,",\n");
        $display("[INFO] out[%0d] = %0d", idx, pixel_out);
      end
    end

    @(posedge clk);
    $fwrite(outfile,"\n]\n");
    $fclose(outfile);

    $display("[PASS] conv2d test completed");
    $finish;
  end
endmodule
