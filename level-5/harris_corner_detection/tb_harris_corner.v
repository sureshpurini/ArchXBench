`timescale 1ns/1ps

module tb_harris_corner;
  // parameters must match the DUT
  parameter PIXEL_W   = 8;
  parameter IMG_WIDTH = 256;
  parameter IMG_HEIGHT= 256;
  parameter GRAD_W    = 16;
  parameter RESP_W    = 32;
  parameter K_W       = 8;
  localparam N        = IMG_WIDTH * IMG_HEIGHT;

  // clock & reset
  reg                    clk      = 0;
  reg                    rst;
  always #5 clk = ~clk;

  // inputs to DUT
  reg  [PIXEL_W-1:0]     pixel_in;
  reg                    valid_in;
  reg  [RESP_W-1:0]      threshold;
  reg  [K_W-1:0]         k_param;

  // outputs from DUT
  wire                   is_corner;
  wire                   valid_out;

  // instantiate DUT
  harris_corner #(
    .IMG_WIDTH (IMG_WIDTH),
    .IMG_HEIGHT(IMG_HEIGHT),
    .PIXEL_W   (PIXEL_W),
    .GRAD_W    (GRAD_W),
    .RESP_W    (RESP_W),
    .K_W       (K_W)
  ) dut (
    .clk        (clk),
    .rst        (rst),
    .pixel_in   (pixel_in),
    .valid_in   (valid_in),
    .threshold  (threshold),
    .k_param    (k_param),
    .is_corner  (is_corner),
    .valid_out  (valid_out)
  );

  // file I/O
  integer infile, outfile, code;
  reg [PIXEL_W-1:0] img   [0:N-1];
  integer idx;

  initial begin
    // initial reset & constants
    rst       = 1;
    valid_in  = 0;
    pixel_in  = 0;
    threshold = 32'd1000;  // example threshold; adjust as needed
    k_param   = 8'd5;      // example Harris k value
    #20 rst   = 0;

    // read input image pixels
    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] cannot open inputs/stimuli.json");
      $finish;
    end
    idx = 0;
    while (!$feof(infile) && idx < N) begin
      code = $fscanf(infile, "%d", img[idx]);
      if (code == 1) idx = idx + 1;
      else            $fgetc(infile);
    end
    $fclose(infile);

    // open output file
    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // stream pixels through DUT
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      pixel_in = img[idx];
      if (valid_out) begin
        $fwrite(outfile, "  %0d", is_corner);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end

    // finish up
    @(posedge clk);
    $fwrite(outfile, "\n]\n");
    $fclose(outfile);
    $display("[PASS] harris_corner test completed");
    $finish;
  end
endmodule
