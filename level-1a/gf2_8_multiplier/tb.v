`timescale 1ns/1ps

module tb_gf256_mult_benchmark;

    // DUT interface
    reg  [7:0] a, b;
    wire [7:0] result_gen, result_const;

    // Instantiate DUTs
    gf256_mult #(.MODE("GENERIC"  )) dut_gen   (.a(a), .b(b), .result(result_gen));
    gf256_mult #(.MODE("AES_CONST")) dut_const (.a(a), .b(b), .result(result_const));

    // Reference GF(2⁸) multiplication (same as DUT’s generic function)
    function [7:0] ref_gf_mult;
        input [7:0] a, b;
        integer i;
        reg [7:0] p, tmp;
        begin
            p   = 8'd0;
            tmp = a;
            for (i = 0; i < 8; i = i + 1) begin
                if (b[i]) p = p ^ tmp;
                tmp = {tmp[6:0],1'b0} ^ (8'h1B & {8{tmp[7]}});
            end
            ref_gf_mult = p;
        end
    endfunction

    // AES MixColumns constants
    localparam integer NC = 7;
    reg [7:0] consts [0:NC-1];
    initial begin
        consts[0] = 8'h01;
        consts[1] = 8'h02;
        consts[2] = 8'h03;
        consts[3] = 8'h09;
        consts[4] = 8'h0B;
        consts[5] = 8'h0D;
        consts[6] = 8'h0E;
    end

    integer i, k, rnd;
    integer pass0, fail0;
    integer pass_const, fail_const;
    integer pass_gen, fail_gen;

    initial begin
        pass0 = 0; fail0 = 0;
        pass_const = 0; fail_const = 0;
        pass_gen = 0; fail_gen = 0;

        //----------------------------------------
        // Phase 0: Identity & zero checks
        //----------------------------------------
        $display("=== Phase 0: Identity & Zero Cases ===");
        // a × 0 == 0
        b = 8'h00;  
        for (i = 0; i < 4; i = i + 1) begin
            a = i*8'h3F;  // try a=0, 0x3F, 0x7E, 0xBD
            #1;
            if (result_gen !== 8'h00) begin
                $display("[0-FAIL] a=%02h×0 !=0 (got %02h)", a, result_gen);
                fail0 = fail0 + 1;
            end else pass0 = pass0 + 1;
        end
        // 0 × b == 0
        a = 8'h00;
        for (i = 0; i < 4; i = i + 1) begin
            b = i*8'h3F;
            #1;
            if (result_gen !== 8'h00) begin
                $display("[0-FAIL] 0×b=%02h !=0 (got %02h)", b, result_gen);
                fail0 = fail0 + 1;
            end else pass0 = pass0 + 1;
        end
        // a × 1 == a
        b = 8'h01;
        for (i = 0; i < 4; i = i + 1) begin
            a = i*8'h55;  // try a=0,0x55,0xAA,0xFF
            #1;
            if (result_const !== a) begin
                $display("[ID-FAIL] a=%02h×1 !=a (got %02h)", a, result_const);
                fail0 = fail0 + 1;
            end else pass0 = pass0 + 1;
        end

        //----------------------------------------
        // Phase 1: Exhaustive AES_CONST mode
        //----------------------------------------
        $display("=== Phase 1: Exhaustive AES_CONST Mode ===");
        for (k = 0; k < NC; k = k + 1) begin
            b = consts[k];
            for (i = 0; i < 16; i = i + 1) begin
                a = i[7:0];
                #1;
                if (result_const === ref_gf_mult(a, b)) pass_const = pass_const + 1;
                else begin
                    $display("[C-FAIL] a=%02h, b=%02h: exp=%02h got=%02h",
                             a, b, ref_gf_mult(a,b), result_const);
                    fail_const = fail_const + 1;
                end
            end
        end

        //----------------------------------------
        // Phase 2: Random-sample GENERIC mode
        //----------------------------------------
        $display("=== Phase 2: Random GENERIC Mode ===");
        for (rnd = 0; rnd < 256; rnd = rnd + 1) begin
            a = $urandom_range(0,255);
            b = $urandom_range(0,255);
            #1;
            if (result_gen === ref_gf_mult(a, b)) pass_gen = pass_gen + 1;
            else begin
                $display("[G-FAIL] a=%02h, b=%02h: exp=%02h got=%02h",
                         a, b, ref_gf_mult(a,b), result_gen);
                fail_gen = fail_gen + 1;
            end
        end

        $display("--------------------------------------------------");
        $display("Phase0 (identity/zero):  %0d passed, %0d failed", pass0,   fail0);
        $display("AES_CONST exhaustive:    %0d passed, %0d failed", pass_const, fail_const);
        $display("GENERIC random(1024):    %0d passed, %0d failed", pass_gen,   fail_gen);
        $display("--------------------------------------------------");
        if (fail0+fail_const+fail_gen == 0)
            $display(">>>PASSED ALL TESTS <<<");
        else
            $display(">>>DETECTED FAILURES <<<");
        $finish;
    end

endmodule
