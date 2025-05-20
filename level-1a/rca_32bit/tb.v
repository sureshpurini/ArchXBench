`timescale 1ns/1ps

module tb_rca_32bit;
    // DUT interface
    reg  [31:0] a, b;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    // Expected outputs for random tests
    reg  [31:0] exp_sum;
    reg         exp_cout;

    // Clock & pass/fail counters
    reg        clk;
    integer    pass_count, fail_count;
    integer    i;

    // Instantiate the 32-bit RCA
    rca_32bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // 10 ns clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD dump for waveform inspection
    initial begin
        $dumpfile("rca_32bit.vcd");
        $dumpvars(0, tb_rca_32bit);
    end

    // Task for directed tests
    task check;
        input [31:0] expected_sum;
        input        expected_cout;
        input [127:0] label;
    begin
        @(negedge clk);
        if (sum === expected_sum && cout === expected_cout) begin
            $display("[PASS] %s", label);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] %s: Expected sum=0x%08h, cout=%b; Got sum=0x%08h, cout=%b", 
                     label, expected_sum, expected_cout, sum, cout);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        // --- Directed integer test vectors ---
        a = 32'h00000000; b = 32'h00000000; cin = 1'b0;
        check(32'h00000000, 1'b0, "0x00000000 + 0x00000000 -> 0x00000000");

        a = 32'h00000000; b = 32'h80000000; cin = 1'b0;
        check(32'h80000000, 1'b0, "0x00000000 + 0x80000000 -> 0x80000000");

        a = 32'h00000001; b = 32'h00000001; cin = 1'b0;
        check(32'h00000002, 1'b0, "0x00000001 + 0x00000001 -> 0x00000002");

        a = 32'h00800000; b = 32'h007FFFFF; cin = 1'b0;
        check(32'h00FFFFFF, 1'b0, "0x00800000 + 0x007FFFFF -> 0x00FFFFFF");

        a = 32'h3FC00000; b = 32'h40080000; cin = 1'b0;
        check(32'h7FC80000, 1'b0, "0x3FC00000 + 0x40080000 -> 0x7FC80000");

        a = 32'h3F800000; b = 32'h00000001; cin = 1'b0;
        check(32'h3F800001, 1'b0, "0x3F800000 + 0x00000001 -> 0x3F800001");

        a = 32'h7F7FFFFF; b = 32'h7F7FFFFF; cin = 1'b0;
        check(32'hFEFFFFFE, 1'b0, "0x7F7FFFFF + 0x7F7FFFFF -> 0xFEFFFFFE");

        a = 32'h7F7FFFFF; b = 32'h00800000; cin = 1'b0;
        check(32'h7FFFFFFF, 1'b0, "0x7F7FFFFF + 0x00800000 -> 0x7FFFFFFF");

        a = 32'h7F800000; b = 32'h3F800000; cin = 1'b0;
        check(32'hBF000000, 1'b0, "0x7F800000 + 0x3F800000 -> 0xBF000000");

        a = 32'h7F800000; b = 32'h7F800000; cin = 1'b0;
        check(32'hFF000000, 1'b0, "0x7F800000 + 0x7F800000 -> 0xFF000000");

        a = 32'h7F800000; b = 32'hFF800000; cin = 1'b0;
        check(32'h7F000000, 1'b1, "0x7F800000 + 0xFF800000 -> 0x7F000000 (carry-out)");

        a = 32'h7FC00000; b = 32'h3F800000; cin = 1'b0;
        check(32'hBF400000, 1'b0, "0x7FC00000 + 0x3F800000 -> 0xBF400000");

        a = 32'h7FC00000; b = 32'h7FC00000; cin = 1'b0;
        check(32'hFF800000, 1'b0, "0x7FC00000 + 0x7FC00000 -> 0xFF800000");

        a = 32'h3F800000; b = 32'hBF800000; cin = 1'b0;
        check(32'hFF000000, 1'b0, "0x3F800000 + 0xBF800000 -> 0xFF000000");

        a = 32'hBFC00000; b = 32'hC0080000; cin = 1'b0;
        check(32'h7FC80000, 1'b1, "0xBFC00000 + 0xC0080000 -> 0x7FC80000 (carry-out)");

        // --- Three cin=1 corner cases ---
        a = 32'hFFFFFFFF; b = 32'h00000000; cin = 1'b1;
        check(32'h00000000, 1'b1, "0xFFFFFFFF + 0x00000000, cin=1 -> carry-out");

        a = 32'h7FFFFFFF; b = 32'h00000001; cin = 1'b1;
        check(32'h80000001, 1'b0, "0x7FFFFFFF + 0x00000001, cin=1 -> 0x80000001");

        a = 32'h80000000; b = 32'h80000000; cin = 1'b1;
        check(32'h00000001, 1'b1, "0x80000000 + 0x80000000, cin=1 -> carry-out");

        // --- 100 Randomized Vectors ---
        for (i = 0; i < 100; i = i + 1) begin
            a   = $urandom;
            b   = $urandom;
            cin = $urandom % 2;
            @(negedge clk);
            exp_sum  = a + b + cin;
            exp_cout = (({1'b0,a} + {1'b0,b} + cin) >> 32);
            if (sum === exp_sum && cout === exp_cout) begin
                $display("[PASS] RANDOM[%0d]: a=0x%08h b=0x%08h cin=%b", i, a, b, cin);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] RANDOM[%0d]: a=0x%08h b=0x%08h cin=%b; Expected sum=0x%08h, cout=%b; Got sum=0x%08h, cout=%b",
                         i, a, b, cin, exp_sum, exp_cout, sum, cout);
                fail_count = fail_count + 1;
            end
        end

        // Summary
        #10;
        $display("=== Test Summary: %0d Passed, %0d Failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
