// testbench.v
// This testbench applies 50 test cases (including 8 edge cases) for the newton_raphson_poly_fixedpoint module.
// It uses a behavioral Newton-Raphson solver (in real arithmetic) to compute the expected fixed-point root.
// Additionally, it evaluates the polynomial at the calculated root to verify convergence.
// Results are displayed along with error metrics and a pass/fail message based on an epsilon threshold.

`timescale 1ns/1ps

module testbench;
    parameter WIDTH = 16;
    parameter FRAC  = 8;
    parameter MAX_ITER = 50;

    // Epsilon threshold for comparing fixed point results.
    // For instance, EPSILON = 8 (8/2^FRAC ≈ 0.03125 in real numbers).
    parameter signed [WIDTH-1:0] EPSILON = 8;

    // DUT inputs and outputs.
    reg clk;
    reg rst;
    reg start;
    reg signed [WIDTH-1:0] x_init;
    reg signed [WIDTH-1:0] coeff0, coeff1, coeff2, coeff3;
    wire signed [WIDTH-1:0] root;
    wire ready;
    wire valid;

    // Instantiate the DUT.
    newton_raphson_poly_fixedpoint #(
        .WIDTH(WIDTH), 
        .FRAC(FRAC), 
        .MAX_ITER(MAX_ITER)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_init(x_init),
        .coeff0(coeff0),
        .coeff1(coeff1),
        .coeff2(coeff2),
        .coeff3(coeff3),
        .root(root),
        .ready(ready),
        .valid(valid)
    );

    // Clock generation: 10ns period.
    always #5 clk = ~clk;

    // Convert between real and fixed-point.
    function automatic integer to_fixed;
        input real r;
        begin
            to_fixed = r * (1 << FRAC);
        end
    endfunction

    function automatic real to_real;
        input integer fixed_val;
        begin
            to_real = fixed_val / (1.0 * (1 << FRAC));
        end
    endfunction

    // Behavioral Newton-Raphson solver using real arithmetic.
    // p(x)=a0+a1*x+a2*x^2+a3*x^3, p'(x)=a1+2*a2*x+3*a3*x^2.
    function automatic real expected_root;
        input real a0, a1, a2, a3, x0;
        integer i;
        real x, p, p_prime;
        begin
            x = x0;
            for(i = 0; i < 50; i = i + 1) begin
                p = a0 + a1*x + a2*x*x + a3*x*x*x;
                p_prime = a1 + 2.0*a2*x + 3.0*a3*x*x;
                if(p_prime != 0.0)
                    x = x - (p / p_prime);
            end
            expected_root = x;
        end
    endfunction

    // Instead of structs, use arrays to store test parameters.
    real test_a0 [0:49];
    real test_a1 [0:49];
    real test_a2 [0:49];
    real test_a3 [0:49];
    real test_x0 [0:49];
    // test_edge flag: 1 indicates an edge case.
    integer test_edge [0:49];

    integer i;
    real exp_root, calc_root, root_err, fx, fx_err;

    // Initialize test cases.
    initial begin
        // Test cases 0-9: General tests.
        test_a0[0] = 1.0; test_a1[0] = -3.0; test_a2[0] = 2.0; test_a3[0] = 0.0; test_x0[0] = 1.5; test_edge[0] = 0;
        test_a0[1] = 0.0; test_a1[1] = 1.0; test_a2[1] = -6.0; test_a3[1] = 2.0; test_x0[1] = 3.0; test_edge[1] = 0;
        test_a0[2] = 2.0; test_a1[2] = -4.0; test_a2[2] = 1.0; test_a3[2] = 0.5; test_x0[2] = 0.5; test_edge[2] = 0;
        test_a0[3] = -1.0; test_a1[3] = 2.0; test_a2[3] = -1.0; test_a3[3] = 0.2; test_x0[3] = -0.5; test_edge[3] = 0;
        test_a0[4] = 1.0; test_a1[4] = -1.0; test_a2[4] = 1.0; test_a3[4] = -1.0; test_x0[4] = 2.0; test_edge[4] = 0;
        test_a0[5] = 0.5; test_a1[5] = 0.5; test_a2[5] = 0.5; test_a3[5] = 0.5; test_x0[5] = 1.0; test_edge[5] = 0;
        test_a0[6] = 10.0; test_a1[6] = -15.0; test_a2[6] = 6.0; test_a3[6] = 0.0; test_x0[6] = 2.0; test_edge[6] = 0;
        test_a0[7] = 3.0; test_a1[7] = -2.0; test_a2[7] = 1.0; test_a3[7] = -0.5; test_x0[7] = 0.5; test_edge[7] = 0;
        test_a0[8] = 1.0; test_a1[8] =  1.0; test_a2[8] = 1.0; test_a3[8] =  1.0; test_x0[8] = 1.0; test_edge[8] = 0;
        test_a0[9] = 5.0; test_a1[9] = -10.0; test_a2[9] = 5.0; test_a3[9] = -1.0; test_x0[9] = 1.0; test_edge[9] = 0;
        
        // Edge cases: indices 10-17.
        test_a0[10] = 0.0; test_a1[10] = 0.0; test_a2[10] = 0.0; test_a3[10] = 0.0; test_x0[10] = 0.0; test_edge[10] = 1;    // All coefficients zero.
        test_a0[11] = 0.0; test_a1[11] = 0.0; test_a2[11] = 0.0; test_a3[11] = 0.0; test_x0[11] = 1.0; test_edge[11] = 1;    // Zero polynomial.
        test_a0[12] = 0.0; test_a1[12] = 0.0; test_a2[12] = 1.0; test_a3[12] = 0.0; test_x0[12] = 0.0; test_edge[12] = 1;    // p(x)= x^2.
        test_a0[13] = 1.0; test_a1[13] = 0.0; test_a2[13] = 0.0; test_a3[13] = 0.0; test_x0[13] = 3.0; test_edge[13] = 1;    // p(x)= 1 (constant).
        test_a0[14] = 0.0; test_a1[14] = 1.0; test_a2[14] = 0.0; test_a3[14] = 0.0; test_x0[14] = -2.0; test_edge[14] = 1;   // Linear: p(x)=x.
        test_a0[15] = -2.0; test_a1[15] = 4.0; test_a2[15] = -2.0; test_a3[15] = 0.0; test_x0[15] = 2.0; test_edge[15] = 1;  // Perfect square.
        test_a0[16] = 1.0; test_a1[16] = -3.0; test_a2[16] = 3.0; test_a3[16] = -1.0; test_x0[16] = 1.0; test_edge[16] = 1;  // Triple root: (1-x)^3.
        test_a0[17] = 1.0; test_a1[17] = 0.0; test_a2[17] = -1.0; test_a3[17] = 0.0; test_x0[17] = 1.0; test_edge[17] = 1;  // p(x)=1-x^2.
        
        // Test cases 18-49: Additional tests with varying parameters.
        for (i = 18; i < 50; i = i + 1) begin
            test_a0[i] = ((i % 5) + 1); 
            test_a1[i] = (((i+1) % 5) - 2);
            test_a2[i] = (((i+2) % 5) - 2);
            test_a3[i] = (((i+3) % 5) - 2);
            test_x0[i] = 1.0 + (i / 10.0);
            test_edge[i] = 0;
        end
    end

    // Test runner.
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        #12; 
        rst = 0;
        
        for(i = 0; i < 50; i = i + 1) begin
            // Set inputs using fixed-point conversion.
            coeff0 = to_fixed(test_a0[i]);
            coeff1 = to_fixed(test_a1[i]);
            coeff2 = to_fixed(test_a2[i]);
            coeff3 = to_fixed(test_a3[i]);
            x_init = to_fixed(test_x0[i]);
            
            // Compute expected root (using real arithmetic).
            exp_root = expected_root(test_a0[i], test_a1[i], test_a2[i], test_a3[i], test_x0[i]);
            
            // Issue start pulse.
            start = 1;
            #10;
            start = 0;
            
            // Wait until DUT is ready.
            wait (ready == 1);
            #5;
            
            // Convert DUT result to a real number.
            calc_root = to_real(root);
            // Compute absolute error between expected and calculated roots.
            if (calc_root > exp_root)
                root_err = calc_root - exp_root;
            else
                root_err = exp_root - calc_root;
                
            // Evaluate the polynomial at the calculated root.
            fx = test_a0[i] + test_a1[i]*calc_root + test_a2[i]*calc_root*calc_root + test_a3[i]*calc_root*calc_root*calc_root;
            if(fx < 0) 
                fx_err = -fx;
            else
                fx_err = fx;
            
            // Display results.
            $display("------------------------------------------------------------");
            $display("Test case #%0d%s", i, (test_edge[i] ? " (EDGE CASE)" : ""));
            $display("Coefficients: a0=%f, a1=%f, a2=%f, a3=%f", test_a0[i], test_a1[i], test_a2[i], test_a3[i]);
            $display("Initial guess: %f", test_x0[i]);
            $display("Expected root: %f (fixed: %0d)", exp_root, to_fixed(exp_root));
            $display("Calculated root: %f (fixed: %0d)", calc_root, root);
            $display("Root error: %f", root_err);
            if(root_err <= to_real(EPSILON))
                $display("Root Comparison: PASS (error = %f <= epsilon = %f)", root_err, to_real(EPSILON));
            else
                $display("Root Comparison: FAIL (error = %f > epsilon = %f)", root_err, to_real(EPSILON));
            
            $display("f(calculated_root) = %f", fx);
            if(fx_err <= to_real(EPSILON))
                $display("Polynomial Verification: PASS (|f(x)| = %f <= epsilon = %f)\n", fx_err, to_real(EPSILON));
            else
                $display("Polynomial Verification: FAIL (|f(x)| = %f > epsilon = %f)\n", fx_err, to_real(EPSILON));
            
            #20;
            // Reset DUT between tests.
            rst = 1; #10; rst = 0; #10;
        end
        
        $display("All test cases completed.");
        $finish;
    end

endmodule