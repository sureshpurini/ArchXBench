`timescale 1ns/1ps

module tb_qgemm;

  parameter VLEN = 8;
  parameter K = 64;
  parameter FP_W = 32;
  parameter SCALE_W = 16;
  parameter QBW = 8;
  parameter ACC_W = 32;

  localparam A_WIDTH = VLEN*K*FP_W;
  localparam B_WIDTH = K*VLEN*FP_W;
  localparam C_WIDTH = VLEN*VLEN*FP_W;

  reg clk, rst, start;
  reg [A_WIDTH-1:0] A_fp;
  reg [B_WIDTH-1:0] B_fp;
  reg [SCALE_W-1:0] scale_A, scale_B;
  reg [QBW-1:0] zp_A, zp_B;
  wire [C_WIDTH-1:0] C_fp;
  wire done;

  qgemm #(
    .VLEN(VLEN), .K(K), .FP_W(FP_W), .SCALE_W(SCALE_W),
    .QBW(QBW), .ACC_W(ACC_W)
  ) dut (
    .clk(clk), .rst(rst), .start(start),
    .A_fp(A_fp), .B_fp(B_fp),
    .scale_A(scale_A), .scale_B(scale_B),
    .zp_A(zp_A), .zp_B(zp_B),
    .C_fp(C_fp), .done(done)
  );

  reg [31:0] float_mem [0:(VLEN*K + K*VLEN)-1];
  reg [15:0] mem_params [0:3];
  integer i, fout;

  always #5 clk = ~clk;

  initial begin
    $readmemh("tb_float.mem", float_mem);
    $readmemh("tb_params.mem", mem_params);

    A_fp = 0;
    for (i = 0; i < VLEN*K; i = i + 1)
      A_fp = {A_fp, float_mem[i]};

    B_fp = 0;
    for (i = 0; i < K*VLEN; i = i + 1)
      B_fp = {B_fp, float_mem[i + VLEN*K]};

    zp_A    = mem_params[0][7:0];
    zp_B    = mem_params[1][7:0];
    scale_A = mem_params[2];
    scale_B = mem_params[3];

    clk = 0; rst = 1; start = 0;
    #20 rst = 0;
    #10 start = 1;
    #10 start = 0;

    wait (done);

    fout = $fopen("outputs/dut_output.json", "w");
    $fwrite(fout, "{\n  \"C\": [\n");
    for (i = 0; i < VLEN*VLEN; i = i + 1)
      $fwrite(fout, "    %0d%s\n", C_fp[i*FP_W +: FP_W], (i == VLEN*VLEN-1) ? "" : ",");
    $fwrite(fout, "  ]\n}\n");
    $fclose(fout);

    $display("[TB] Simulation done.");
    $finish;
  end

endmodule
