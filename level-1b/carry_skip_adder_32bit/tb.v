// carry_skip_adder_32bit_tb.v
`timescale 1ns/1ps

module carry_skip_adder_32bit_tb;
    // DUT I/O
    reg  [31:0] A;
    reg  [31:0] B;
    reg         cin;
    wire [31:0] sum;
    wire        cout;
    reg         clk;

    // Counters
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    carry_skip_adder_32bit dut (
        .A   (A),
        .B   (B),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        pass_count = 0;
        fail_count = 0;
    end
    always #5 clk = ~clk;

    // Self-checking test task:
    // ta, tb, expected_sum, cin, expected_cout, label
    task run_test;
        input  [31:0] ta;
        input  [31:0] tb;
        input  [31:0] exp_s;
        input         tcin;
        input         exp_co;
        input  [255:0] label;
        begin
            A   = ta;
            B   = tb;
            cin = tcin;
            @(negedge clk);
            #1;
            if (sum === exp_s && cout === exp_co) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s", label);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %s: Expected sum=0x%08X, cout=%b; Got sum=0x%08X, cout=%b",
                         label, exp_s, exp_co, sum, cout);
            end
        end
    endtask

    // Drive all the tests
    initial begin
        // Basic corners & patterns (cin=0 and 1)
        run_test(32'h00000000, 32'h00000000, 32'h00000000, 1'b0, 1'b0, "0 + 0, cin=0");
        run_test(32'h00000000, 32'h00000000, 32'h00000001, 1'b1, 1'b0, "0 + 0, cin=1");
        run_test(32'hFFFFFFFF, 32'h00000001, 32'h00000000, 1'b0, 1'b1, "all-1 + 1");
        run_test(32'h80000000, 32'h80000000, 32'h00000000, 1'b0, 1'b1, "sign-bit + sign-bit");
        run_test(32'h0F0F0F0F, 32'h01010101, 32'h10101010, 1'b0, 1'b0, "pattern add");
        run_test(32'h11111111, 32'hEEEEEEEE, 32'hFFFFFFFF, 1'b0, 1'b0, "no skip in blocks");
        run_test(32'h0FFFFFFF, 32'h10000000, 32'h1FFFFFFF, 1'b0, 1'b0, "cross-block boundary");
        run_test(32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, 1'b0, 1'b0, "alternating bits");
        run_test(32'h12345678, 32'h87654321, 32'h99999999, 1'b0, 1'b0, "random1, cin=0");
        run_test(32'hDEADBEEF, 32'h01020304, 32'hDFAFC1F3, 1'b0, 1'b0, "random2, cin=0");

        // Explicit skip-logic coverage (cin=1, B=0 so sum = A+1)
        run_test(32'h0000000F, 32'h00000000, 32'h00000010, 1'b1, 1'b0, "single-block skip");
        run_test(32'h000000FF, 32'h00000000, 32'h00000100, 1'b1, 1'b0, "two-block skip");
        run_test(32'h00FFFFFF, 32'h00000000, 32'h01000000, 1'b1, 1'b0, "three-block skip");
        run_test(32'hFFFFFFFF, 32'h00000000, 32'h00000000, 1'b1, 1'b1, "full-width skip");

        // Patterns with cin=1
        run_test(32'h12345678, 32'h87654321, 32'h9999999A, 1'b1, 1'b0, "random1, cin=1");
        run_test(32'h0F0F0F0F, 32'h01010101, 32'h10101011, 1'b1, 1'b0, "pattern, cin=1");

        // Wrap up
        @(negedge clk);
        #1;
        $display("\n[INFO] Test Summary: Pass = %0d, Failed = %0d",
                 pass_count, fail_count);
        $finish;
    end

endmodule
