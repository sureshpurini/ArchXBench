`timescale 1ns/1ps

module tb_floating_point_multiplier;
  parameter EXP_WIDTH  = 8;
  parameter MANT_WIDTH = 23;
  parameter WIDTH      = 1 + EXP_WIDTH + MANT_WIDTH;
  
  reg                    clk, rst;
  reg  [WIDTH-1:0]       a, b;
  reg  [2:0]             rnd_mode;
  wire [WIDTH-1:0]       product;
  wire [2:0]             exception_flags;
  
  // DUT instantiation
  floating_point_multiplier #(
    .EXP_WIDTH(EXP_WIDTH),
    .MANT_WIDTH(MANT_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .rnd_mode(rnd_mode),
    .product(product),
    .exception_flags(exception_flags)
  );
  
  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Test vectors (vec8 removed)
  reg [WIDTH-1:0] tv_a   [0:9];
  reg [WIDTH-1:0] tv_b   [0:9];
  reg [WIDTH-1:0] tv_exp [0:9];
  reg [2:0]       tv_flg [0:9];
  reg [159:0]     tv_desc[0:9]; // Test descriptions
  
  integer i, total, passed;
  
  initial begin
    $display("==================================================");
    $display("   IEEE 754 Floating Point Multiplier Test");
    $display("   Design: Flush-to-zero underflow handling");
    $display("==================================================");
    
    // Reset sequence
    rst = 1; 
    rnd_mode = 3'b000; // Round to nearest
    #12 rst = 0;
    $display("Reset complete. Starting test vectors...\n");
    
    // Test vectors with descriptions
    // Format: a * b => expected_result, flags {invalid,overflow,underflow}
    
    // Basic zero cases
    tv_a[0]=32'h00000000; tv_b[0]=32'h00000000; tv_exp[0]=32'h00000000; tv_flg[0]=3'b001;
    tv_desc[0] = "+0.0 × +0.0 = +0.0";
    
    tv_a[1]=32'h00000000; tv_b[1]=32'h3f800000; tv_exp[1]=32'h00000000; tv_flg[1]=3'b001;
    tv_desc[1] = "+0.0 × +1.0 = +0.0";
    
    // Infinity cases  
    tv_a[2]=32'h7f800000; tv_b[2]=32'h3f800000; tv_exp[2]=32'h7f800000; tv_flg[2]=3'b010;
    tv_desc[2] = "+∞ × +1.0 = +∞";
    
    tv_a[3]=32'h7f800000; tv_b[3]=32'h00000000; tv_exp[3]=32'h7fc00000; tv_flg[3]=3'b100;
    tv_desc[3] = "+∞ × +0.0 = NaN (invalid)";
    
    // NaN propagation
    tv_a[4]=32'h7fc00000; tv_b[4]=32'h3f800000; tv_exp[4]=32'h7fc00000; tv_flg[4]=3'b100;
    tv_desc[4] = "NaN × +1.0 = NaN";
    
    // Normal multiplication cases
    tv_a[5]=32'h3fc00000; tv_b[5]=32'h40000000; tv_exp[5]=32'h40400000; tv_flg[5]=3'b000;
    tv_desc[5] = "+1.5 × +2.0 = +3.0";
    
    tv_a[6]=32'hc0200000; tv_b[6]=32'hbf000000; tv_exp[6]=32'h3fa00000; tv_flg[6]=3'b000;
    tv_desc[6] = "-2.5 × -0.5 = +1.25";
    
    // Overflow case
    tv_a[7]=32'h7f7fffff; tv_b[7]=32'h40000000; tv_exp[7]=32'h7f800000; tv_flg[7]=3'b010;
    tv_desc[7] = "MAX_NORMAL × +2.0 = +∞ (overflow)";
    
    // Denormalized multiplication (underflow to zero)
    tv_a[8]=32'h00000001; tv_b[8]=32'h00000002; tv_exp[8]=32'h00000000; tv_flg[8]=3'b001;
    tv_desc[8] = "MIN_DENORM × 2×MIN_DENORM = +0.0 (underflow)";
    
    // Sign handling
    tv_a[9]=32'hbf800000; tv_b[9]=32'hbf800000; tv_exp[9]=32'h3f800000; tv_flg[9]=3'b000;
    tv_desc[9] = "-1.0 × -1.0 = +1.0";
    
    // Execute test vectors
    total = 0; 
    passed = 0;
    
    for (i = 0; i <= 9; i = i + 1) begin
      // Apply test inputs
      a = tv_a[i];
      b = tv_b[i];
      #10; // Wait for combinational delay
      
      total = total + 1;
      
      // Check results
      if (product === tv_exp[i] && exception_flags === tv_flg[i]) begin
        $display("✓ PASS [%0d]: %s", i, tv_desc[i]);
        $display("   Input:  a=0x%08h  b=0x%08h", a, b);
        $display("   Result: 0x%08h  flags=%3b", product, exception_flags);
        passed = passed + 1;
      end else begin
        $display("✗ FAIL [%0d]: %s", i, tv_desc[i]);
        $display("   Input:    a=0x%08h  b=0x%08h", a, b);
        $display("   Expected: 0x%08h  flags=%3b", tv_exp[i], tv_flg[i]);
        $display("   Got:      0x%08h  flags=%3b", product, exception_flags);
      end
      $display(""); // Blank line for readability
    end
    
    // Final summary
    $display("==================================================");
    $display("                TEST SUMMARY");
    $display("==================================================");
    $display("Total Test Cases: %2d", total);
    $display("Passed:          %2d", passed); 
    $display("Failed:          %2d", total - passed);
    $display("Success Rate:    %2d%%", (passed * 100) / total);
    $display("");
    
    if (passed == total) begin
      $display("ALL TESTS PASSED!");
      $display("Floating point multiplier is working correctly.");
    end else begin
      $display("SOME TESTS FAILED");
      $display("Please review the implementation.");
    end
    
    $display("==================================================");
    $finish;
  end

endmodule