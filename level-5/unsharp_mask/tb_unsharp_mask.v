`timescale 1ns/1ps

module tb_unsharp_mask;
  parameter PIXEL_W=8, IMG_WIDTH=256, IMG_HEIGHT=256, GAIN_W=8;
  localparam N = IMG_WIDTH*IMG_HEIGHT;

  reg                    clk = 0, rst;
  reg  [PIXEL_W-1:0]     pixel_in;
  reg                    valid_in;
  reg  [GAIN_W-1:0]      gain;
  wire [PIXEL_W-1:0]     pixel_out;
  wire                   valid_out;

  // DUT
  unsharp_mask #(
    .IMG_WIDTH(IMG_WIDTH),
    .IMG_HEIGHT(IMG_HEIGHT),
    .PIXEL_W(PIXEL_W),
    .GAIN_W(GAIN_W)
  ) dut (
    .clk(clk), .rst(rst),
    .pixel_in(pixel_in), .valid_in(valid_in), .gain(gain),
    .pixel_out(pixel_out), .valid_out(valid_out)
  );

  // clock gen
  always #5 clk = ~clk;

  // memory for input image
  integer infile, outfile, code;
  reg [PIXEL_W-1:0] img [0:N-1];
  integer idx;

  initial begin
    rst = 1; valid_in = 0; pixel_in = 0; gain = 8'd2;
    #20 rst = 0;

    infile = $fopen("inputs/stimuli.json","r");
    if (infile == 0) begin
      $display("[FAIL] cannot open inputs/stimuli.json");
      $finish;
    end
    idx = 0;
    while (!$feof(infile) && idx < N) begin
      code = $fscanf(infile, "%d", img[idx]);
      if (code == 1) idx = idx + 1;
      else code = $fgetc(infile);
    end
    $fclose(infile);

    outfile = $fopen("outputs/dut_output.json","w");
    $fwrite(outfile, "[\n");

    // stream pixels
    for (idx = 0; idx < N; idx = idx + 1) begin
      @(posedge clk);
      valid_in = 1;
      pixel_in = img[idx];
      if (valid_out) begin
        $fwrite(outfile, "  %0d", pixel_out);
        if (idx < N-1) $fwrite(outfile, ",\n");
      end
    end

    @(posedge clk);
    $fwrite(outfile, "\n]\n");
    $fclose(outfile);
    $display("[PASS] unsharp_mask completed");
    $finish;
  end
endmodule
