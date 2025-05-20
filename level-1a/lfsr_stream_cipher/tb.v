`timescale 1ns/1ps
module tb_lfsr_stream_cipher;

    // Parameters
    parameter N = 8;
    parameter LFSR_POLY = 8'b10001110;  // Should match the DUT polynomial

    // Testbench signals
    reg clk;
    reg rst;
    reg enable;
    reg [N-1:0] seed;
    wire lfsr_out;
    wire [N-1:0] state;

    // Expected state for comparison
    reg [N-1:0] expected_state;
    reg expected_out;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;
    integer cycle_count = 50;

    // Instantiate the DUT
    lfsr_stream_cipher #(.N(N), .LFSR_POLY(LFSR_POLY)) dut (
        .clk(clk),
        .rst(rst),
        .seed(seed),
        .enable(enable),
        .lfsr_out(lfsr_out),
        .state(state)
    );

    // Clock generation: 10 time unit period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Function to compute feedback given the current state
    function automatic bit compute_feedback;
        input [N-1:0] state_val;
        integer j;
        reg fb;
        begin
            fb = 0;
            for (j = 0; j < N; j = j + 1)
                if (LFSR_POLY[j])
                    fb = fb ^ state_val[j];
            compute_feedback = fb;
        end
    endfunction

    // Test procedure: apply reset, set seed and then verify for cycle_count cycles
    initial begin
        $display("Starting LFSR Stream Cipher Testbench...");

        // Set a non-zero seed value; here we choose a fixed value for reproducibility.
        seed   = 8'hA5;
        rst    = 1;
        enable = 0;
        expected_state = 0;  // Not used until reset is de-asserted

        // Hold reset for a couple of cycles
        #12;
        rst = 0;
        enable = 1;

        // After reset the DUT loads seed, so we set expected_state accordingly
        expected_state = seed;
        @(posedge clk);  // Wait one clock cycle after reset

        // Run the LFSR for a total of cycle_count clock cycles
        for (i = 0; i < cycle_count; i = i + 1) begin
            @(posedge clk);
            if (enable) begin
                // Compute the new expected state by shifting and inserting feedback at MSB
                expected_state = { compute_feedback(expected_state), expected_state[N-1:1] };
            end
            // Determine expected output: defined as the LSB of the new expected state
            expected_out = expected_state[0];

            // Check for correctness (and ensure state is never all zeros)
            if ((state === expected_state) && (lfsr_out === expected_out) && (state != 0)) begin
                $display("[PASS] Cycle %0d: state = %h, lfsr_out = %b", i, state, lfsr_out);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Cycle %0d: Expected state = %h, got state = %h; Expected lfsr_out = %b, got lfsr_out = %b", 
                         i, expected_state, state, expected_out, lfsr_out);
                fail_count = fail_count + 1;
            end
        end

        $display("Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        $finish;
    end

endmodule
