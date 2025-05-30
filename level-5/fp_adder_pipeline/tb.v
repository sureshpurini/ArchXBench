`timescale 1ns/1ps
module tb_fp_adder_pipeline_corrected;
reg clk;
reg rst;
reg [31:0] a;
reg [31:0] b;
reg add_sub;
reg valid_in;
wire [31:0] result;
wire valid_out;
integer pass_count;
integer fail_count;
integer test_count;
fp_adder_pipeline #(
.LATENCY(5)
) DUT (
.clk(clk),
.rst(rst),
.a(a),
.b(b),
.add_sub(add_sub),
.valid_in(valid_in),
.result(result),
.valid_out(valid_out)
);
always begin
#5 clk = ~clk;
end
task send_test;
input [31:0] operand_a;
input [31:0] operand_b;
input operation;
input [31:0] expected;
input [200:0] test_name;
begin
@(posedge clk);
a = operand_a;
b = operand_b;
add_sub = operation;
valid_in = 1;
test_count = test_count + 1;
$display("Test %0d: %s", test_count, test_name);
@(posedge clk);
valid_in = 0;
    @(posedge valid_out);
    @(posedge clk);
    #1;
    
    if (result === expected) begin
        $display("[PASS] Expected: 0x%h, Got: 0x%h", expected, result);
        pass_count = pass_count + 1;
    end else begin
        $display("[FAIL] Expected: 0x%h, Got: 0x%h", expected, result);
        fail_count = fail_count + 1;
    end
    $display("");
end
endtask
initial begin
clk = 0;
rst = 1;
valid_in = 0;
a = 0;
b = 0;
add_sub = 0;
pass_count = 0;
fail_count = 0;
test_count = 0;
repeat(10) @(posedge clk);
rst = 0;
repeat(10) @(posedge clk);

$display("=== CORRECTED IEEE-754 FP Adder Test Suite ===");
$display("(Fixed incorrect expected values from original testbench)");
$display("");

// All the same tests, but with CORRECT expected values
send_test(32'h3F800000, 32'h40000000, 0, 32'h40400000, "Basic: 1.0 + 2.0 = 3.0");
send_test(32'h40400000, 32'h3F800000, 1, 32'h40000000, "Basic: 3.0 - 1.0 = 2.0");
send_test(32'h40B00000, 32'h40100000, 1, 32'h40500000, "Alignment: 5.5 - 2.25 = 3.25");

// CORRECTED: 32.0 + 1.0 = 33.0 should be 0x42040000, not 0x42800000
send_test(32'h42000000, 32'h3F800000, 0, 32'h42040000, "CORRECTED: 32.0 + 1.0 = 33.0");

send_test(32'h3F800000, 32'h33800000, 0, 32'h3F800000, "Large diff: 1.0 + tiny ≈ 1.0");
send_test(32'h3F800000, 32'hBF800000, 0, 32'h00000000, "Cancellation: 1.0 + (-1.0) = 0.0");
send_test(32'hBF800000, 32'hBF800000, 0, 32'hC0000000, "Negative: (-1.0) + (-1.0) = -2.0");
send_test(32'h3F800000, 32'hBF800000, 1, 32'h40000000, "Sub negative: 1.0 - (-1.0) = 2.0");
send_test(32'h3F7FFFFF, 32'h34000000, 0, 32'h3F800000, "Normalize: almost_1 + small = 1.0");
send_test(32'h40000000, 32'h40000000, 1, 32'h00000000, "Normalize: 2.0 - 2.0 = 0.0");

// CORRECTED: 1/3 + 1/3 = 2/3 should be 0x3F2AAAAB, not 0x3F555555
send_test(32'h3EAAAAAB, 32'h3EAAAAAB, 0, 32'h3F2AAAAB, "CORRECTED: 1/3 + 1/3 = 2/3");

send_test(32'h3F800000, 32'h00000000, 0, 32'h3F800000, "Zero: 1.0 + 0.0 = 1.0");
send_test(32'h00000000, 32'h40000000, 0, 32'h40000000, "Zero: 0.0 + 2.0 = 2.0");

// CORRECTED: -0.0 + 0.0 = +0.0, not -0.0 (IEEE-754 standard)
send_test(32'h80000000, 32'h00000000, 0, 32'h00000000, "CORRECTED: -0.0 + 0.0 = +0.0");

send_test(32'h3F800000, 32'h3F000000, 0, 32'h3FC00000, "Equal exp: 1.0 + 0.5 = 1.5");
send_test(32'h40000000, 32'h3F800000, 0, 32'h40400000, "Equal exp: 2.0 + 1.0 = 3.0");
send_test(32'h7F000000, 32'h7F000000, 0, 32'h7F800000, "Overflow: large + large = +inf");
send_test(32'hFF000000, 32'hFF000000, 0, 32'hFF800000, "Overflow: -large + -large = -inf");
send_test(32'h00800000, 32'h80800000, 0, 32'h00000000, "Underflow: tiny - tiny = 0");
send_test(32'h7F800000, 32'h3F800000, 0, 32'h7F800000, "INF prop: +inf + 1.0 = +inf");
send_test(32'hFF800000, 32'h3F800000, 0, 32'hFF800000, "INF prop: -inf + 1.0 = -inf");
send_test(32'h7F800000, 32'hFF800000, 0, 32'h7FC00000, "NaN gen: +inf + (-inf) = NaN");
send_test(32'h7FC00000, 32'h3F800000, 0, 32'h7FC00000, "NaN prop: NaN + 1.0 = NaN");

repeat(20) @(posedge clk);

$display("=== CORRECTED Test Results ===");
$display("Total Tests: %0d", test_count);
$display("Passed: %0d", pass_count);
$display("Failed: %0d", fail_count);
$display("Pass Rate: %0.1f%%", (pass_count * 100.0) / test_count);

if (fail_count == 0) begin
    $display("SUCCESS: Your FP adder implementation is CORRECT!");
    $display("The original testbench had incorrect expected values.");
end else begin
    $display("Issues found: %0d tests failed", fail_count);
end

$finish;
end
endmodule