`timescale 1ns/1ps

module testbench;

    parameter DATA_WIDTH = 32;
    parameter FRAC = 16;
    parameter CLK_PERIOD = 10;
    
    // Test vector arrays for 50 cases
    reg [DATA_WIDTH-1:0] a11_arr [0:49];
    reg [DATA_WIDTH-1:0] a12_arr [0:49];
    reg [DATA_WIDTH-1:0] a21_arr [0:49];
    reg [DATA_WIDTH-1:0] a22_arr [0:49];
    reg [DATA_WIDTH-1:0] b1_arr  [0:49];
    reg [DATA_WIDTH-1:0] b2_arr  [0:49];
    reg [DATA_WIDTH-1:0] x1_init_arr [0:49];
    reg [DATA_WIDTH-1:0] x2_init_arr [0:49];
    reg [DATA_WIDTH-1:0] exp_x1_arr [0:49];
    reg [DATA_WIDTH-1:0] exp_x2_arr [0:49];

    // Epsilon threshold for pass/fail (for example, 0.01)
    reg [DATA_WIDTH-1:0] epsilon;
    
    // DUT input signals
    reg clk;
    reg rst;
    reg start;
    reg [DATA_WIDTH-1:0] a11_s, a12_s, a21_s, a22_s;
    reg [DATA_WIDTH-1:0] b1_s, b2_s, x1_init_s, x2_init_s;
    
    // DUT outputs
    wire [DATA_WIDTH-1:0] x1, x2;
    wire ready;
    
    gauss_seidel_2x2_solver #(.DATA_WIDTH(DATA_WIDTH), .FRAC(FRAC)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a11(a11_s),
        .a12(a12_s),
        .a21(a21_s),
        .a22(a22_s),
        .b1(b1_s),
        .b2(b2_s),
        .x1_init(x1_init_s),
        .x2_init(x2_init_s),
        .x1(x1),
        .x2(x2),
        .ready(ready)
    );
    
    integer i;
    real real_x1, real_x2, real_exp_x1, real_exp_x2, err1, err2;
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Fixed-point to real conversion function
    function real fixed_to_real;
        input [DATA_WIDTH-1:0] fixed;
        begin
            fixed_to_real = fixed / (2.0**FRAC);
        end
    endfunction

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        epsilon = (1 << FRAC)/100;  // 0.01 in fixed-point
        #(CLK_PERIOD*2);
        rst = 0;
        
        // --- Initialize 50 test cases ---
        // At least 8 edge cases (cases 0 to 7)
        // Conversion: value = real_value * (2^FRAC)
        
        // Case 0: Diagonal, zero off-diagonals
        a11_arr[0] = 2 * (1<<FRAC);
        a12_arr[0] = 0;
        b1_arr[0]  = 4 * (1<<FRAC);
        a21_arr[0] = 0;
        a22_arr[0] = 3 * (1<<FRAC);
        b2_arr[0]  = 3 * (1<<FRAC);
        x1_init_arr[0] = 0;
        x2_init_arr[0] = 0;
        exp_x1_arr[0] = 2 * (1<<FRAC);
        exp_x2_arr[0] = 1 * (1<<FRAC);

        // Case 1: Simple nonzero off-diagonals
        a11_arr[1] = 2 * (1<<FRAC);
        a12_arr[1] = 1 * (1<<FRAC);
        b1_arr[1]  = 5 * (1<<FRAC);
        a21_arr[1] = 1 * (1<<FRAC);
        a22_arr[1] = 3 * (1<<FRAC);
        b2_arr[1]  = 7 * (1<<FRAC);
        x1_init_arr[1] = 0;
        x2_init_arr[1] = 0;
        exp_x1_arr[1] = 1.6 * (1<<FRAC);
        exp_x2_arr[1] = 1.8 * (1<<FRAC);
        
        // Case 2: Poor initial guess
        a11_arr[2] = 4 * (1<<FRAC);
        a12_arr[2] = 1 * (1<<FRAC);
        b1_arr[2]  = 9 * (1<<FRAC);
        a21_arr[2] = 1 * (1<<FRAC);
        a22_arr[2] = 5 * (1<<FRAC);
        b2_arr[2]  = 8 * (1<<FRAC);
        x1_init_arr[2] = 3 * (1<<FRAC);
        x2_init_arr[2] = 3 * (1<<FRAC);
        exp_x1_arr[2] = 2.0 * (1<<FRAC);
        exp_x2_arr[2] = 1.2 * (1<<FRAC);
        
        // Case 3: High off-diagonals (challenging convergence)
        a11_arr[3] = 3 * (1<<FRAC);
        a12_arr[3] = 2.5 * (1<<FRAC);
        b1_arr[3]  = 10 * (1<<FRAC);
        a21_arr[3] = 2.5 * (1<<FRAC);
        a22_arr[3] = 4 * (1<<FRAC);
        b2_arr[3]  = 11 * (1<<FRAC);
        x1_init_arr[3] = 1 * (1<<FRAC);
        x2_init_arr[3] = 1 * (1<<FRAC);
        exp_x1_arr[3] = 1.5 * (1<<FRAC);
        exp_x2_arr[3] = 1.8 * (1<<FRAC);
        
        // Case 4: Nearly singular matrix (edge case)
        a11_arr[4] = 0.1 * (1<<FRAC);
        a12_arr[4] = 1 * (1<<FRAC);
        b1_arr[4]  = 1 * (1<<FRAC);
        a21_arr[4] = 1 * (1<<FRAC);
        a22_arr[4] = 2 * (1<<FRAC);
        b2_arr[4]  = 3 * (1<<FRAC);
        x1_init_arr[4] = 0;
        x2_init_arr[4] = 0;
        exp_x1_arr[4] = 0.5 * (1<<FRAC);
        exp_x2_arr[4] = 1 * (1<<FRAC);
        
        // Case 5: Diagonally dominant with large values
        a11_arr[5] = 100 * (1<<FRAC);
        a12_arr[5] = 1 * (1<<FRAC);
        b1_arr[5]  = 201 * (1<<FRAC);
        a21_arr[5] = 1 * (1<<FRAC);
        a22_arr[5] = 150 * (1<<FRAC);
        b2_arr[5]  = 151 * (1<<FRAC);
        x1_init_arr[5] = 0;
        x2_init_arr[5] = 0;
        exp_x1_arr[5] = 2 * (1<<FRAC);
        exp_x2_arr[5] = 1 * (1<<FRAC);
        
        // Case 6: Negative coefficients (edge case)
        a11_arr[6] = 3 * (1<<FRAC);
        a12_arr[6] = (-1) * (1<<FRAC);
        b1_arr[6]  = 4 * (1<<FRAC);
        a21_arr[6] = (-1) * (1<<FRAC);
        a22_arr[6] = 3 * (1<<FRAC);
        b2_arr[6]  = 2 * (1<<FRAC);
        x1_init_arr[6] = 0;
        x2_init_arr[6] = 0;
        exp_x1_arr[6] = 1.5 * (1<<FRAC);
        exp_x2_arr[6] = 0.5 * (1<<FRAC);
        
        // Case 7: Very small differences required (edge case)
        a11_arr[7] = 5 * (1<<FRAC);
        a12_arr[7] = 0.2 * (1<<FRAC);
        b1_arr[7]  = 10 * (1<<FRAC);
        a21_arr[7] = 0.2 * (1<<FRAC);
        a22_arr[7] = 4 * (1<<FRAC);
        b2_arr[7]  = 8 * (1<<FRAC);
        x1_init_arr[7] = 0;
        x2_init_arr[7] = 0;
        exp_x1_arr[7] = 2 * (1<<FRAC);
        exp_x2_arr[7] = 1.5 * (1<<FRAC);
        
        // Cases 8 to 49: generic pattern
        for(i = 8; i < 50; i = i + 1) begin
            a11_arr[i] = 2 * (1<<FRAC);
            a12_arr[i] = 0;
            b1_arr[i]  = 4 * (1<<FRAC);
            a21_arr[i] = 0;
            a22_arr[i] = 3 * (1<<FRAC);
            b2_arr[i]  = 3 * (1<<FRAC);
            x1_init_arr[i] = 0;
            x2_init_arr[i] = 0;
            exp_x1_arr[i] = 2 * (1<<FRAC);
            exp_x2_arr[i] = 1 * (1<<FRAC);
        end
        
        // Run each test case one by one:
        for(i = 0; i < 50; i = i + 1) begin
            a11_s     = a11_arr[i];
            a12_s     = a12_arr[i];
            a21_s     = a21_arr[i];
            a22_s     = a22_arr[i];
            b1_s      = b1_arr[i];
            b2_s      = b2_arr[i];
            x1_init_s = x1_init_arr[i];
            x2_init_s = x2_init_arr[i];
            
            start = 1;
            #(CLK_PERIOD);
            start = 0;
            
            wait(ready == 1);
            #(CLK_PERIOD);
            
            real_x1 = fixed_to_real(x1);
            real_x2 = fixed_to_real(x2);
            real_exp_x1 = fixed_to_real(exp_x1_arr[i]);
            real_exp_x2 = fixed_to_real(exp_x2_arr[i]);
            err1 = (real_x1 > real_exp_x1) ? real_x1 - real_exp_x1 : real_exp_x1 - real_x1;
            err2 = (real_x2 > real_exp_x2) ? real_x2 - real_exp_x2 : real_exp_x2 - real_x2;
            
            if((err1 < fixed_to_real(epsilon)) && (err2 < fixed_to_real(epsilon)))
                $display("Case %0d: PASS | Expected: (%0f, %0f) Calculated: (%0f, %0f) Errors: (%0f, %0f)", 
                     i, real_exp_x1, real_exp_x2, real_x1, real_x2, err1, err2);
            else
                $display("Case %0d: FAIL | Expected: (%0f, %0f) Calculated: (%0f, %0f) Errors: (%0f, %0f)", 
                     i, real_exp_x1, real_exp_x2, real_x1, real_x2, err1, err2);
            
            rst = 1;
            #(CLK_PERIOD);
            rst = 0;
            #(CLK_PERIOD);
        end
        
        $display("Simulation complete.");
        $finish;
    end
endmodule