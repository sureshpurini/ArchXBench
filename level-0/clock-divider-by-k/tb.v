`timescale 1ns/1ps
module clock_divider_tb;
    parameter N = 8;
    reg clk;
    reg rst;
    reg [N-1:0] div_val;
    wire clk_out;

    // Instantiate DUT
    clock_divider #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .div_val(div_val),
        .clk_out(clk_out)
    );

    // Clock generation: 10ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer i;
    integer errors;
    integer cycle;
    reg expected;
    reg [N-1:0] k;
    reg [N-1:0] half;
    reg [31:0] count;
    parameter TEST_PERIODS = 4;
    integer total_cycles;

    initial begin
        // Reset
        rst = 1'b1;
        #12;
        rst = 1'b0;

        // Test for 5 random divider values
        for (i = 0; i < 5; i = i + 1) begin
            k = $urandom_range(1,10);
            if (k < 2) begin
                $display("Skipping invalid div_val=%0d", k);
            end else begin
                div_val = k;
                half = k >> 1;
                expected = 0;
                count = 0;
                errors = 0;
                cycle = 0;
                total_cycles = k * TEST_PERIODS;

                $display("\nTesting div_val=%0d for %0d cycles", k, total_cycles);
                @(posedge clk);
                repeat (total_cycles) @(posedge clk) begin
                    cycle = cycle + 1;
                    if (count == (half - 1)) begin
                        count = 0;
                        expected = ~expected;
                    end else begin
                        count = count + 1;
                    end
                    if (clk_out !== expected) begin
                        $display("Mismatch div_val=%0d at cycle %0d: exp=%b got=%b", k, cycle, expected, clk_out);
                        errors = errors + 1;
                    end
                end

                if (errors == 0)
                    $display("div_val=%0d PASS", k);
                else
                    $display("div_val=%0d FAIL with %0d errors", k, errors);
            end
        end
        $finish;
    end
endmodule
