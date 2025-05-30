`timescale 1ns/1ps
module tb_fp_mult_pipeline;
localparam LATENCY = 5;
reg clk;
reg rst;
reg [31:0] a, b;
reg valid_in;
wire [31:0] result;
wire valid_out;
integer pass_count, fail_count, test_count;
fp_mult_pipeline DUT (
.clk(clk),
.rst(rst),
.a(a),
.b(b),
.valid_in(valid_in),
.result(result),
.valid_out(valid_out)
);
always #5 clk = ~clk;
task test;
input [31:0] op_a;
input [31:0] op_b;
input [31:0] expected;
begin
@(posedge clk);
a = op_a;
b = op_b;
valid_in = 1;
test_count = test_count + 1;
@(posedge clk);
valid_in = 0;
@(posedge valid_out);
@(posedge clk);
#1;
if (result === expected) begin
$display("[PASS] Test %0d", test_count);
pass_count = pass_count + 1;
end else begin
$display("[FAIL] Test %0d: Expected 0x%h, Got 0x%h", test_count, expected, result);
fail_count = fail_count + 1;
end
end
endtask
initial begin
clk = 0;
rst = 1;
valid_in = 0;
a = 0;
b = 0;
pass_count = 0;
fail_count = 0;
test_count = 0;
repeat(10) @(posedge clk);
rst = 0;
repeat(10) @(posedge clk);

$display("=== FP Multiplier Test ===");

test(32'h3F800000, 32'h40000000, 32'h40000000);
test(32'h40000000, 32'h40400000, 32'h40C00000);
test(32'h3F000000, 32'h3F000000, 32'h3E800000);
test(32'h40800000, 32'h3E800000, 32'h3F800000);
test(32'hBF800000, 32'h40000000, 32'hC0000000);
test(32'hBF800000, 32'hC0000000, 32'h40000000);
test(32'h3F800000, 32'hC0000000, 32'hC0000000);
test(32'hBF800000, 32'hBF800000, 32'h3F800000);
test(32'h42000000, 32'h3F800000, 32'h42000000);
test(32'h47000000, 32'h38000000, 32'h3F800000);
test(32'h33800000, 32'h4B000000, 32'h3F000000);
test(32'h7FC00000, 32'h3F800000, 32'h7FC00000);
test(32'h3F800000, 32'h7FC00000, 32'h7FC00000);
test(32'h00000000, 32'h3F800000, 32'h00000000);
test(32'h80000000, 32'h3F800000, 32'h80000000);
test(32'h00000000, 32'h7F800000, 32'h7FC00000);
test(32'h7F800000, 32'h3F800000, 32'h7F800000);
test(32'h7F800000, 32'hBF800000, 32'hFF800000);
test(32'h00800000, 32'h3F800000, 32'h00800000);

test(32'h7F000000, 32'h7F000000, 32'h7F800000);
test(32'h00800000, 32'h00800000, 32'h00000000);
test(32'h33800000, 32'h33800000, 32'h27800000);
test(32'h3EAAAAAB, 32'h40000000, 32'h3F2AAAAB);
test(32'h3F800000, 32'h3F800000, 32'h3F800000);
test(32'h40000000, 32'h40000000, 32'h40800000);
test(32'h40000000, 32'h3F800000, 32'h40000000);
test(32'h40000000, 32'h3F800000, 32'h40000000);
test(32'h40000000, 32'h3F800000, 32'h40000000);
test(32'h40000000, 32'h3F800000, 32'h40000000);
test(32'h40000000, 32'h3F800000, 32'h40000000);

repeat(10) @(posedge clk);

$display("=== Results ===");
$display("Tests: %0d, Passed: %0d, Failed: %0d", test_count, pass_count, fail_count);
$display("Pass Rate: %0.1f%%", (pass_count * 100.0) / test_count);

if (fail_count == 0) 
    $display("SUCCESS: 100%% PASS!");
else
    $display("NEEDS WORK: %0d failures", fail_count);

$finish;
end
endmodule