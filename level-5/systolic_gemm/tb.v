`include "systolic_matrix_mult.v"

module testbench;
    reg clk, rst;
    reg [31:0] a_west0, a_west1, a_west2, a_west3;
    reg [31:0] b_north0, b_north1, b_north2, b_north3;
    wire done;
    wire [63:0] result0, result1, result2, result3,
                result4, result5, result6, result7,
                result8, result9, result10, result11,
                result12, result13, result14, result15;

    systolic_matrix_mult uut(
        .a_west0(a_west0), .a_west1(a_west1), .a_west2(a_west2), .a_west3(a_west3),
        .b_north0(b_north0), .b_north1(b_north1), .b_north2(b_north2), .b_north3(b_north3),
        .clk(clk), .rst(rst), .done(done),
        .result0(result0), .result1(result1), .result2(result2), .result3(result3),
        .result4(result4), .result5(result5), .result6(result6), .result7(result7),
        .result8(result8), .result9(result9), .result10(result10), .result11(result11),
        .result12(result12), .result13(result13), .result14(result14), .result15(result15)
    );

    // Matrix A = [0 1 2 3; 4 5 6 7; 8 9 10 11; 12 13 14 15]
    // Matrix B = [0 1 2 3; 4 5 6 7; 8 9 10 11; 12 13 14 15]
    
    // West input sequences - Matrix A fed row by row with systolic timing
    initial begin
        #3  a_west0 <= 32'd1;   // A[0][0]
        #10 a_west0 <= 32'd2;   // A[0][1]
        #10 a_west0 <= 32'd3;   // A[0][2]
        #10 a_west0 <= 32'd4;   // A[0][3]
        #10 a_west0 <= 32'd0;
        #10 a_west0 <= 32'd0;
        #10 a_west0 <= 32'd0;
    end

    initial begin
        #3  a_west1 <= 32'd0;
        #10 a_west1 <= 32'd5;   // A[1][0]
        #10 a_west1 <= 32'd6;   // A[1][1]
        #10 a_west1 <= 32'd7;   // A[1][2]
        #10 a_west1 <= 32'd8;   // A[1][3]
        #10 a_west1 <= 32'd0;
        #10 a_west1 <= 32'd0;
    end

    initial begin
        #3  a_west2 <= 32'd0;
        #10 a_west2 <= 32'd0;
        #10 a_west2 <= 32'd9;   // A[2][0]
        #10 a_west2 <= 32'd10;   // A[2][1]
        #10 a_west2 <= 32'd11;  // A[2][2]
        #10 a_west2 <= 32'd12;  // A[2][3]
        #10 a_west2 <= 32'd0;
    end

    initial begin
        #3  a_west3 <= 32'd0;
        #10 a_west3 <= 32'd0;
        #10 a_west3 <= 32'd0;
        #10 a_west3 <= 32'd13;  // A[3][0]
        #10 a_west3 <= 32'd14;  // A[3][1]
        #10 a_west3 <= 32'd15;  // A[3][2]
        #10 a_west3 <= 32'd16;  // A[3][3]
    end

    // North input sequences - Matrix B fed column by column with systolic timing
    initial begin
        #3  b_north0 <= 32'd1;   // B[0][0]
        #10 b_north0 <= 32'd5;   // B[1][0]
        #10 b_north0 <= 32'd9;   // B[2][0]
        #10 b_north0 <= 32'd13;  // B[3][0]
        #10 b_north0 <= 32'd0;
        #10 b_north0 <= 32'd0;
        #10 b_north0 <= 32'd0;
    end

    initial begin
        #3  b_north1 <= 32'd0;
        #10 b_north1 <= 32'd2;   // B[0][1]
        #10 b_north1 <= 32'd6;   // B[1][1]
        #10 b_north1 <= 32'd10;   // B[2][1]
        #10 b_north1 <= 32'd14;  // B[3][1]
        #10 b_north1 <= 32'd0;
        #10 b_north1 <= 32'd0;
    end

    initial begin
        #3  b_north2 <= 32'd0;
        #10 b_north2 <= 32'd0;
        #10 b_north2 <= 32'd3;   // B[0][2]
        #10 b_north2 <= 32'd7;   // B[1][2]
        #10 b_north2 <= 32'd11;  // B[2][2]
        #10 b_north2 <= 32'd15;  // B[3][2]
        #10 b_north2 <= 32'd0;
    end

    initial begin
        #3  b_north3 <= 32'd0;
        #10 b_north3 <= 32'd0;
        #10 b_north3 <= 32'd0;
        #10 b_north3 <= 32'd4;   // B[0][3]
        #10 b_north3 <= 32'd8;   // B[1][3]
        #10 b_north3 <= 32'd12;  // B[2][3]
        #10 b_north3 <= 32'd16;  // B[3][3]
    end

    // Reset sequence
    initial begin
        rst <= 1;
        #3 rst <= 0;
    end

    // Clock generation (extended for two tests)
    initial begin
        clk <= 0;
        repeat(50)  // Extended for two test cases
            #5 clk <= ~clk;
    end

    // Second test case inputs - A × I (Identity matrix)
    // West inputs remain the same (Matrix A)
    initial begin
        #120 a_west0 <= 32'd0;   // A[0][0] - second test
        #10  a_west0 <= 32'd1;   // A[0][1]
        #10  a_west0 <= 32'd2;   // A[0][2]
        #10  a_west0 <= 32'd3;   // A[0][3]
        #10  a_west0 <= 32'd0;
        #10  a_west0 <= 32'd0;
        #10  a_west0 <= 32'd0;
    end

    initial begin
        #120 a_west1 <= 32'd0;
        #10  a_west1 <= 32'd4;   // A[1][0]
        #10  a_west1 <= 32'd5;   // A[1][1]
        #10  a_west1 <= 32'd6;   // A[1][2]
        #10  a_west1 <= 32'd7;   // A[1][3]
        #10  a_west1 <= 32'd0;
        #10  a_west1 <= 32'd0;
    end

    initial begin
        #120 a_west2 <= 32'd0;
        #10  a_west2 <= 32'd0;
        #10  a_west2 <= 32'd8;   // A[2][0]
        #10  a_west2 <= 32'd9;   // A[2][1]
        #10  a_west2 <= 32'd10;  // A[2][2]
        #10  a_west2 <= 32'd11;  // A[2][3]
        #10  a_west2 <= 32'd0;
    end

    initial begin
        #120 a_west3 <= 32'd0;
        #10  a_west3 <= 32'd0;
        #10  a_west3 <= 32'd0;
        #10  a_west3 <= 32'd12;  // A[3][0]
        #10  a_west3 <= 32'd13;  // A[3][1]
        #10  a_west3 <= 32'd14;  // A[3][2]
        #10  a_west3 <= 32'd15;  // A[3][3]
    end

    // North input sequences for Identity matrix I
    initial begin
        #120 b_north0 <= 32'd1;   // I[0][0] = 1
        #10  b_north0 <= 32'd0;   // I[1][0] = 0
        #10  b_north0 <= 32'd0;   // I[2][0] = 0
        #10  b_north0 <= 32'd0;   // I[3][0] = 0
        #10  b_north0 <= 32'd0;
        #10  b_north0 <= 32'd0;
        #10  b_north0 <= 32'd0;
    end

    initial begin
        #120 b_north1 <= 32'd0;
        #10  b_north1 <= 32'd0;   // I[0][1] = 0
        #10  b_north1 <= 32'd1;   // I[1][1] = 1
        #10  b_north1 <= 32'd0;   // I[2][1] = 0
        #10  b_north1 <= 32'd0;   // I[3][1] = 0
        #10  b_north1 <= 32'd0;
        #10  b_north1 <= 32'd0;
    end

    initial begin
        #120 b_north2 <= 32'd0;
        #10  b_north2 <= 32'd0;
        #10  b_north2 <= 32'd0;   // I[0][2] = 0
        #10  b_north2 <= 32'd0;   // I[1][2] = 0
        #10  b_north2 <= 32'd1;   // I[2][2] = 1
        #10  b_north2 <= 32'd0;   // I[3][2] = 0
        #10  b_north2 <= 32'd0;
    end

    initial begin
        #120 b_north3 <= 32'd0;
        #10  b_north3 <= 32'd0;
        #10  b_north3 <= 32'd0;
        #10  b_north3 <= 32'd0;   // I[0][3] = 0
        #10  b_north3 <= 32'd0;   // I[1][3] = 0
        #10  b_north3 <= 32'd0;   // I[2][3] = 0
        #10  b_north3 <= 32'd1;   // I[3][3] = 1
    end

    // Display results after simulation completes
    initial begin
        #100; // Wait for all computations to complete
        
        $display("\n=== TEST CASE 1: 4x4 Matrix Multiplication A × A ===");
        $display("\nMatrix A:");
        $display("[ 1  2  3  4]");
        $display("[ 5  6  7  8]");
        $display("[ 9 10 11 12]");
        $display("[13 14 15 16]");
        
        $display("\nMatrix A (same as above):");
        $display("[ 1  2  3  4]");
        $display("[ 5  6  7  8]");
        $display("[ 9 10 11 12]");
        $display("[13 14 15 16]");
        
        $display("\nResult Matrix C = A × A:");
        $display("[%4d %4d %4d %4d]", result0, result1, result2, result3);
        $display("[%4d %4d %4d %4d]", result4, result5, result6, result7);
        $display("[%4d %4d %4d %4d]", result8, result9, result10, result11);
        $display("[%4d %4d %4d %4d]", result12, result13, result14, result15);
        
        $display("\nExpected Result A × A:");
        $display("[ 90 100 110 120]");
        $display("[202 228 254 280]");
        $display("[314 356 398 440]");
        $display("[426 484 542 600]");
        
        $display("\nDone signal: %b", done);
        
        // Reset for second test case
        #10 rst <= 1;
        #10 rst <= 0;
        
        // Wait for second test to complete
        #100;
        
        $display("\n=== TEST CASE 2: 4x4 Matrix Multiplication A × I ===");
        $display("\nMatrix A:");
        $display("[ 0  1  2  3]");
        $display("[ 4  5  6  7]");
        $display("[ 8  9 10 11]");
        $display("[12 13 14 15]");
        
        $display("\nMatrix I (Identity):");
        $display("[ 1  0  0  0]");
        $display("[ 0  1  0  0]");
        $display("[ 0  0  1  0]");
        $display("[ 0  0  0  1]");
        
        $display("\nResult Matrix C = A × I:");
        $display("[%4d %4d %4d %4d]", result0, result1, result2, result3);
        $display("[%4d %4d %4d %4d]", result4, result5, result6, result7);
        $display("[%4d %4d %4d %4d]", result8, result9, result10, result11);
        $display("[%4d %4d %4d %4d]", result12, result13, result14, result15);
        
        $display("\nExpected Result A × I (should equal A):");
        $display("[ 0  1  2  3]");
        $display("[ 4  5  6  7]");
        $display("[ 8  9 10 11]");
        $display("[12 13 14 15]");
        
        $display("\nDone signal: %b", done);
        $display("All tests completed at time: %0t", $time);
        
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time: %0t | Done: %b | C[0][0]: %0d", $time, done, result0);
    end

endmodule