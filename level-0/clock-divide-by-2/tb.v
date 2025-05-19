`timescale 1ns/1ps

module clock_div2_tb;
    // Testbench signals
    reg clk;
    reg rst;
    wire clk_out;

    // Instantiate the clock_div2 module
    clock_div2 uut (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_out)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer cycle;
    reg expected;
    integer errors;

    // Test procedure
    initial begin
        // Initialize
        rst = 1'b1;
        #15;       // Hold reset for one and a half cycles
        rst = 1'b0;

        expected = 1;
        cycle = 0;
        errors = 0;

        // Run for 20 input clock cycles
        repeat (20) @(posedge clk) begin
            cycle = cycle + 1;
            expected = ~expected;
            if (clk_out !== expected) begin
                $display("Mismatch at cycle %0d: expected %b, got %b at time %0t", cycle, expected, clk_out, $time);
                errors = errors + 1;
            end else begin
                $display("Cycle %0d PASS: clk_out = %b", cycle, clk_out);
            end
        end

        if (errors == 0)
            $display("clock_div2_test: PASS - All cycles matched expected toggles");
        else
            $display("clock_div2_test: FAIL - %0d mismatches found", errors);

        $finish;
    end

endmodule
