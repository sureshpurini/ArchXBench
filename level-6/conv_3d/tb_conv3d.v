`timescale 1ns/1ps

module tb_conv3d;

  // Parameters matching DUT
  parameter K1 = 3, K2 = 3, K3 = 3;
  parameter D  = 8, H  = 64, W  = 64;
  parameter DATA_W = 8;

  // Compute total number of input voxels
  localparam N     = D * H * W;
  localparam OUT_W = DATA_W + 4;  // DATA_W + LOG_KW 

  // Testbench signals
  reg                      clk, rst, valid_in, last_in;
  reg  [DATA_W-1:0]        voxel_in;
  reg  [K1*K2*K3*DATA_W-1:0] kernel;
  wire [OUT_W-1:0]         voxel_out;

  // Memory for loading input volume
  reg [7:0] input_volume [0:N-1];
  integer i, fout;

  // Instantiate DUT
  conv3d #(
    .K1(K1), .K2(K2), .K3(K3),
    .D(D),  .H(H),  .W(W),
    .DATA_W(DATA_W)
  ) dut (
    .clk(clk),
    .rst(rst),
    .voxel_in(voxel_in),
    .valid_in(valid_in),
    .kernel(kernel),
    .last_in(last_in),
    .voxel_out(voxel_out),
    .valid_out(),  // not used in dummy DUT
    .done()        // not used
  );

  // Generate clock (10 ns period)
  always #5 clk = ~clk;

  initial begin
    // Load input volume from memory file
    $readmemh("tb_input.mem", input_volume);

    // Initialize signals
    clk      = 0;
    rst      = 1;
    valid_in = 0;
    last_in  = 0;
    kernel   = 0;  // dummy kernel

    #20 rst = 0;

    // Ensure outputs directory exists (via Makefile’s run target)

    // Open output JSON file
    fout = $fopen("outputs/dut_output.json", "w");
    $fwrite(fout, "{\n  \"C\": [\n");

    // Stream inputs and capture outputs
    for (i = 0; i < N; i = i + 1) begin
      @(negedge clk);
      voxel_in = input_volume[i];
      valid_in = 1;
      last_in  = (i == N-1);
      @(posedge clk);
      // write this cycle's output
      $fwrite(fout, "    %0d%s\n",
              voxel_out,
              (i == N-1) ? "" : ",");
    end

    // Close JSON array and file
    $fwrite(fout, "  ]\n}\n");
    $fclose(fout);

    $display("[TB] Simulation complete, outputs/dut_output.json written.");
    #10 $finish;
  end

endmodule
