`timescale 1ns/1ps

module tb_multich_conv2d;

  parameter CIN = 3, COUT = 8, K = 3, H = 64, W = 64;
  parameter DATA_W = 8, BIAS_W = 16, OUT_W = 16;

  localparam N = CIN*H*W;
  reg clk, rst, valid_in, last_in;
  reg [DATA_W-1:0] pixel_in;
  reg [COUT*CIN*K*K*DATA_W-1:0] kernel;
  reg [COUT*BIAS_W-1:0] bias;
  wire [OUT_W-1:0] pixel_out;
  wire valid_out, done;

  reg [7:0] input_image [0:N-1];
  integer i, fout;

  multich_conv2d dut (
    .clk(clk), .rst(rst),
    .pixel_in(pixel_in),
    .valid_in(valid_in),
    .last_in(last_in),
    .kernel(kernel),
    .bias(bias),
    .pixel_out(pixel_out),
    .valid_out(valid_out),
    .done(done)
  );

  always #5 clk = ~clk;

  initial begin
    $readmemh("tb_input.mem", input_image);
    clk = 0; rst = 1; valid_in = 0; last_in = 0;
    kernel = 0; bias = 0;

    #20 rst = 0;

    for (i = 0; i < N; i = i + 1) begin
      @(negedge clk);
      pixel_in = input_image[i];
      valid_in = 1;
      last_in = (i == N-1);
    end

    @(negedge clk); valid_in = 0; last_in = 0;

    fout = $fopen("outputs/dut_output.json", "w");
    $fwrite(fout, "{\n  \"C\": [\n");

    while (!done) begin
      @(negedge clk);
      if (valid_out)
        $fwrite(fout, "    %0d,\n", pixel_out);
    end
    @(negedge clk);
    if (valid_out) $fwrite(fout, "    %0d\n", pixel_out);
    $fwrite(fout, "  ]\n}\n");
    $fclose(fout);
    $finish;
  end
endmodule
