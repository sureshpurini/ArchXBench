`timescale 1ns/1ps

module tb_conv1d;
    parameter DATA_W      = 8;
    parameter KERNEL_SIZE = 5;
    parameter GAIN_W      = 4;

    // DUT I/O
    reg                         clk, rst;
    reg                         valid_in;
    reg  [DATA_W-1:0]           data_in;
    wire                        valid_out;
    wire [DATA_W+GAIN_W-1:0]    data_out;

    // instantiate DUT
    conv1d #(
        .DATA_W(DATA_W),
        .KERNEL_SIZE(KERNEL_SIZE),
        .GAIN_W(GAIN_W)
    ) dut (
        .clk(clk), .rst(rst),
        .valid_in(valid_in), .data_in(data_in),
        .valid_out(valid_out), .data_out(data_out)
    );

    // JSON file I/O
    integer infile, outfile, code;
    reg [31:0] stimuli [0:4095];
    integer N, idx;

    // 100 MHz clock
    initial clk = 0; always #5 clk = ~clk;

    initial begin
        // reset
        rst      = 1;
        valid_in = 0;
        data_in  = 0;
        #20 rst  = 0;

        // load stimuli.json
        infile = $fopen("inputs/stimuli.json","r");
        if (infile == 0) begin
            $display("[FAIL] Cannot open inputs/stimuli.json");
            $finish;
        end

        N = 0;
        while (!$feof(infile)) begin
            code = $fscanf(infile, " %d", stimuli[N]);
            if (code == 1) begin
                N = N + 1;
            end else begin
                // skip non-integer characters
                code = $fgetc(infile);
            end
        end
        $fclose(infile);

        // open output file
        outfile = $fopen("outputs/dut_output.json","w");
        $fwrite(outfile, "[\n");

        // drive inputs & capture outputs
        for (idx = 0; idx < N; idx = idx + 1) begin
            @(posedge clk);
            valid_in <= 1;
            data_in  <= stimuli[idx][DATA_W-1:0];

            if (valid_out) begin
                $fwrite(outfile, "  %0d", data_out);
                if (idx < N-1) $fwrite(outfile, ",\n");
                $display("[INFO] out[%0d] = %0d", idx, data_out);
            end
        end

        // finish JSON array
        @(posedge clk);
        $fwrite(outfile, "\n]\n");
        $fclose(outfile);

        $display("[PASS] conv1d test completed");
        $finish;
    end
endmodule
