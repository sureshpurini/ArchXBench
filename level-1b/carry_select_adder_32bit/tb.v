// tb_carry_select_adder_32bit.v
`timescale 1ns/1ps

module tb_carry_select_adder_32bit;
    // DUT ports
    reg  [31:0] A, B;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    // Instantiate the DUT
    carry_select_adder_32bit dut (
        .A   (A),
        .B   (B),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    // -------------------------
    // Benchmark parameters
    // -------------------------
    parameter N_PATTERN = 16;
    parameter N_RANDOM  = 32;

    // Pattern vectors
    reg [31:0] testA [0:N_PATTERN-1];
    reg [31:0] testB [0:N_PATTERN-1];
    reg        testCin [0:N_PATTERN-1];

    // Internal for checking
    integer     i, j;
    integer     pass_count = 0, fail_count = 0;
    reg [32:0]  full;            // 33-bit to capture carry
    reg [31:0]  expected_sum;
    reg         expected_cout;

    initial begin
        // 1) Initialize the 16 corner patterns
        testA[ 0]=32'h00000000; testB[ 0]=32'h00000000; testCin[ 0]=0;
        testA[ 1]=32'h00000000; testB[ 1]=32'h00000000; testCin[ 1]=1;
        testA[ 2]=32'hFFFFFFFF; testB[ 2]=32'h00000000; testCin[ 2]=0;
        testA[ 3]=32'hFFFFFFFF; testB[ 3]=32'h00000000; testCin[ 3]=1;
        testA[ 4]=32'hFFFFFFFF; testB[ 4]=32'hFFFFFFFF; testCin[ 4]=0;
        testA[ 5]=32'hFFFFFFFF; testB[ 5]=32'hFFFFFFFF; testCin[ 5]=1;
        testA[ 6]=32'h80000000; testB[ 6]=32'h80000000; testCin[ 6]=0;
        testA[ 7]=32'h80000000; testB[ 7]=32'h80000000; testCin[ 7]=1;
        testA[ 8]=32'hAAAAAAAA; testB[ 8]=32'h55555555; testCin[ 8]=0;
        testA[ 9]=32'hAAAAAAAA; testB[ 9]=32'h55555555; testCin[ 9]=1;
        testA[10]=32'h0F0F0F0F; testB[10]=32'hF0F0F0F0; testCin[10]=0;
        testA[11]=32'h0F0F0F0F; testB[11]=32'hF0F0F0F0; testCin[11]=1;
        testA[12]=32'h12345678; testB[12]=32'h87654321; testCin[12]=0;
        testA[13]=32'h89ABCDEF; testB[13]=32'h01234567; testCin[13]=1;
        testA[14]=32'h0000FFFF; testB[14]=32'hFFFF0000; testCin[14]=0;
        testA[15]=32'h0000FFFF; testB[15]=32'hFFFF0000; testCin[15]=1;

        $display("\n--- Running %0d pattern vectors ---", N_PATTERN);
        for (i = 0; i < N_PATTERN; i = i + 1) begin
            A   = testA[i];
            B   = testB[i];
            cin = testCin[i];
            #1;
            full          = A + B + cin;
            expected_sum  = full[31:0];
            expected_cout = full[32];

            if ({cout, sum} === {expected_cout, expected_sum}) begin
                $display("[PASS] Pattern %0d: A=0x%08h B=0x%08h cin=%b → sum=0x%08h, cout=%b",
                         i, A, B, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Pattern %0d: A=0x%08h B=0x%08h cin=%b → Expected sum=0x%08h, cout=%b; Got sum=0x%08h, cout=%b",
                         i, A, B, cin, expected_sum, expected_cout, sum, cout);
                fail_count = fail_count + 1;
            end
        end

        $display("\n--- Running %0d random vectors ---", N_RANDOM);
        for (j = 0; j < N_RANDOM; j = j + 1) begin
            A   = $urandom;
            B   = $urandom;
            cin = $urandom % 2;
            #1;
            full          = A + B + cin;
            expected_sum  = full[31:0];
            expected_cout = full[32];

            if ({cout, sum} === {expected_cout, expected_sum}) begin
                $display("[PASS] Random %04d: A=0x%08h B=0x%08h cin=%b → sum=0x%08h, cout=%b",
                         j, A, B, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Random %04d: A=0x%08h B=0x%08h cin=%b → Expected sum=0x%08h, cout=%b; Got sum=0x%08h, cout=%b",
                         j, A, B, cin, expected_sum, expected_cout, sum, cout);
                fail_count = fail_count + 1;
            end
        end

        // Final summary
        $display("\n=== Benchmark Complete: Pass = %0d, Failed = %0d ===\n", pass_count, fail_count);
        $finish;
    end

endmodule
