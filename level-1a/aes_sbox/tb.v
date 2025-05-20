// tb_aes_sbox.v
// Testbench for the AES S-Box module that applies all 256 test cases.
// Each test prints a message in the format:
//    [PASS] Input: <byte_in>, Output: <byte_out>
//    [FAIL] Input: <byte_in>: Expected <expected_value>, Got: <byte_out>
// At the end, a summary of PASS and FAIL counts is printed.

`timescale 1ns/1ps
module tb_aes_sbox;

  reg  [7:0] byte_in;
  wire [7:0] byte_out;

  // Instantiate the DUT with parameter IMPL. Change to "LOGIC" for logic-optimized version.
  aes_sbox #(.IMPL("LUT")) uut (
    .byte_in(byte_in),
    .byte_out(byte_out)
  );

  // Array to store expected S-Box outputs.
  reg [7:0] expected [0:255];
  integer i;
  integer pass_count, fail_count;

  initial begin
    // Initialize the expected AES S-Box values.
    expected[8'h00] = 8'h63;  expected[8'h01] = 8'h7c;
    expected[8'h02] = 8'h77;  expected[8'h03] = 8'h7b;
    expected[8'h04] = 8'hf2;  expected[8'h05] = 8'h6b;
    expected[8'h06] = 8'h6f;  expected[8'h07] = 8'hc5;
    expected[8'h08] = 8'h30;  expected[8'h09] = 8'h01;
    expected[8'h0A] = 8'h67;  expected[8'h0B] = 8'h2b;
    expected[8'h0C] = 8'hfe;  expected[8'h0D] = 8'hd7;
    expected[8'h0E] = 8'hab;  expected[8'h0F] = 8'h76;
    expected[8'h10] = 8'hca;  expected[8'h11] = 8'h82;
    expected[8'h12] = 8'hc9;  expected[8'h13] = 8'h7d;
    expected[8'h14] = 8'hfa;  expected[8'h15] = 8'h59;
    expected[8'h16] = 8'h47;  expected[8'h17] = 8'hf0;
    expected[8'h18] = 8'had;  expected[8'h19] = 8'hd4;
    expected[8'h1A] = 8'ha2;  expected[8'h1B] = 8'haf;
    expected[8'h1C] = 8'h9c;  expected[8'h1D] = 8'ha4;
    expected[8'h1E] = 8'h72;  expected[8'h1F] = 8'hc0;
    expected[8'h20] = 8'hb7;  expected[8'h21] = 8'hfd;
    expected[8'h22] = 8'h93;  expected[8'h23] = 8'h26;
    expected[8'h24] = 8'h36;  expected[8'h25] = 8'h3f;
    expected[8'h26] = 8'hf7;  expected[8'h27] = 8'hcc;
    expected[8'h28] = 8'h34;  expected[8'h29] = 8'ha5;
    expected[8'h2A] = 8'he5;  expected[8'h2B] = 8'hf1;
    expected[8'h2C] = 8'h71;  expected[8'h2D] = 8'hd8;
    expected[8'h2E] = 8'h31;  expected[8'h2F] = 8'h15;
    expected[8'h30] = 8'h04;  expected[8'h31] = 8'hc7;
    expected[8'h32] = 8'h23;  expected[8'h33] = 8'hc3;
    expected[8'h34] = 8'h18;  expected[8'h35] = 8'h96;
    expected[8'h36] = 8'h05;  expected[8'h37] = 8'h9a;
    expected[8'h38] = 8'h07;  expected[8'h39] = 8'h12;
    expected[8'h3A] = 8'h80;  expected[8'h3B] = 8'he2;
    expected[8'h3C] = 8'heb;  expected[8'h3D] = 8'h27;
    expected[8'h3E] = 8'hb2;  expected[8'h3F] = 8'h75;
    expected[8'h40] = 8'h09;  expected[8'h41] = 8'h83;
    expected[8'h42] = 8'h2c;  expected[8'h43] = 8'h1a;
    expected[8'h44] = 8'h1b;  expected[8'h45] = 8'h6e;
    expected[8'h46] = 8'h5a;  expected[8'h47] = 8'ha0;
    expected[8'h48] = 8'h52;  expected[8'h49] = 8'h3b;
    expected[8'h4A] = 8'hd6;  expected[8'h4B] = 8'hb3;
    expected[8'h4C] = 8'h29;  expected[8'h4D] = 8'he3;
    expected[8'h4E] = 8'h2f;  expected[8'h4F] = 8'h84;
    expected[8'h50] = 8'h53;  expected[8'h51] = 8'hd1;
    expected[8'h52] = 8'h00;  expected[8'h53] = 8'hed;
    expected[8'h54] = 8'h20;  expected[8'h55] = 8'hfc;
    expected[8'h56] = 8'hb1;  expected[8'h57] = 8'h5b;
    expected[8'h58] = 8'h6a;  expected[8'h59] = 8'hcb;
    expected[8'h5A] = 8'hbe;  expected[8'h5B] = 8'h39;
    expected[8'h5C] = 8'h4a;  expected[8'h5D] = 8'h4c;
    expected[8'h5E] = 8'h58;  expected[8'h5F] = 8'hcf;
    expected[8'h60] = 8'hd0;  expected[8'h61] = 8'hef;
    expected[8'h62] = 8'haa;  expected[8'h63] = 8'hfb;
    expected[8'h64] = 8'h43;  expected[8'h65] = 8'h4d;
    expected[8'h66] = 8'h33;  expected[8'h67] = 8'h85;
    expected[8'h68] = 8'h45;  expected[8'h69] = 8'hf9;
    expected[8'h6A] = 8'h02;  expected[8'h6B] = 8'h7f;
    expected[8'h6C] = 8'h50;  expected[8'h6D] = 8'h3c;
    expected[8'h6E] = 8'h9f;  expected[8'h6F] = 8'ha8;
    expected[8'h70] = 8'h51;  expected[8'h71] = 8'ha3;
    expected[8'h72] = 8'h40;  expected[8'h73] = 8'h8f;
    expected[8'h74] = 8'h92;  expected[8'h75] = 8'h9d;
    expected[8'h76] = 8'h38;  expected[8'h77] = 8'hf5;
    expected[8'h78] = 8'hbc;  expected[8'h79] = 8'hb6;
    expected[8'h7A] = 8'hda;  expected[8'h7B] = 8'h21;
    expected[8'h7C] = 8'h10;  expected[8'h7D] = 8'hff;
    expected[8'h7E] = 8'hf3;  expected[8'h7F] = 8'hd2;
    expected[8'h80] = 8'hcd;  expected[8'h81] = 8'h0c;
    expected[8'h82] = 8'h13;  expected[8'h83] = 8'hec;
    expected[8'h84] = 8'h5f;  expected[8'h85] = 8'h97;
    expected[8'h86] = 8'h44;  expected[8'h87] = 8'h17;
    expected[8'h88] = 8'hc4;  expected[8'h89] = 8'ha7;
    expected[8'h8A] = 8'h7e;  expected[8'h8B] = 8'h3d;
    expected[8'h8C] = 8'h64;  expected[8'h8D] = 8'h5d;
    expected[8'h8E] = 8'h19;  expected[8'h8F] = 8'h73;
    expected[8'h90] = 8'h60;  expected[8'h91] = 8'h81;
    expected[8'h92] = 8'h4f;  expected[8'h93] = 8'hdc;
    expected[8'h94] = 8'h22;  expected[8'h95] = 8'h2a;
    expected[8'h96] = 8'h90;  expected[8'h97] = 8'h88;
    expected[8'h98] = 8'h46;  expected[8'h99] = 8'hee;
    expected[8'h9A] = 8'hb8;  expected[8'h9B] = 8'h14;
    expected[8'h9C] = 8'hde;  expected[8'h9D] = 8'h5e;
    expected[8'h9E] = 8'h0b;  expected[8'h9F] = 8'hdb;
    expected[8'hA0] = 8'he0;  expected[8'hA1] = 8'h32;
    expected[8'hA2] = 8'h3a;  expected[8'hA3] = 8'h0a;
    expected[8'hA4] = 8'h49;  expected[8'hA5] = 8'h06;
    expected[8'hA6] = 8'h24;  expected[8'hA7] = 8'h5c;
    expected[8'hA8] = 8'hc2;  expected[8'hA9] = 8'hd3;
    expected[8'hAA] = 8'hac;  expected[8'hAB] = 8'h62;
    expected[8'hAC] = 8'h91;  expected[8'hAD] = 8'h95;
    expected[8'hAE] = 8'he4;  expected[8'hAF] = 8'h79;
    expected[8'hB0] = 8'he7;  expected[8'hB1] = 8'hc8;
    expected[8'hB2] = 8'h37;  expected[8'hB3] = 8'h6d;
    expected[8'hB4] = 8'h8d;  expected[8'hB5] = 8'hd5;
    expected[8'hB6] = 8'h4e;  expected[8'hB7] = 8'ha9;
    expected[8'hB8] = 8'h6c;  expected[8'hB9] = 8'h56;
    expected[8'hBA] = 8'hf4;  expected[8'hBB] = 8'hea;
    expected[8'hBC] = 8'h65;  expected[8'hBD] = 8'h7a;
    expected[8'hBE] = 8'hae;  expected[8'hBF] = 8'h08;
    expected[8'hC0] = 8'hba;  expected[8'hC1] = 8'h78;
    expected[8'hC2] = 8'h25;  expected[8'hC3] = 8'h2e;
    expected[8'hC4] = 8'h1c;  expected[8'hC5] = 8'ha6;
    expected[8'hC6] = 8'hb4;  expected[8'hC7] = 8'hc6;
    expected[8'hC8] = 8'he8;  expected[8'hC9] = 8'hdd;
    expected[8'hCA] = 8'h74;  expected[8'hCB] = 8'h1f;
    expected[8'hCC] = 8'h4b;  expected[8'hCD] = 8'hbd;
    expected[8'hCE] = 8'h8b;  expected[8'hCF] = 8'h8a;
    expected[8'hD0] = 8'h70;  expected[8'hD1] = 8'h3e;
    expected[8'hD2] = 8'hb5;  expected[8'hD3] = 8'h66;
    expected[8'hD4] = 8'h48;  expected[8'hD5] = 8'h03;
    expected[8'hD6] = 8'hf6;  expected[8'hD7] = 8'h0e;
    expected[8'hD8] = 8'h61;  expected[8'hD9] = 8'h35;
    expected[8'hDA] = 8'h57;  expected[8'hDB] = 8'hb9;
    expected[8'hDC] = 8'h86;  expected[8'hDD] = 8'hc1;
    expected[8'hDE] = 8'h1d;  expected[8'hDF] = 8'h9e;
    expected[8'hE0] = 8'he1;  expected[8'hE1] = 8'hf8;
    expected[8'hE2] = 8'h98;  expected[8'hE3] = 8'h11;
    expected[8'hE4] = 8'h69;  expected[8'hE5] = 8'hd9;
    expected[8'hE6] = 8'h8e;  expected[8'hE7] = 8'h94;
    expected[8'hE8] = 8'h9b;  expected[8'hE9] = 8'h1e;
    expected[8'hEA] = 8'h87;  expected[8'hEB] = 8'he9;
    expected[8'hEC] = 8'hce;  expected[8'hED] = 8'h55;
    expected[8'hEE] = 8'h28;  expected[8'hEF] = 8'hdf;
    expected[8'hF0] = 8'h8c;  expected[8'hF1] = 8'ha1;
    expected[8'hF2] = 8'h89;  expected[8'hF3] = 8'h0d;
    expected[8'hF4] = 8'hbf;  expected[8'hF5] = 8'he6;
    expected[8'hF6] = 8'h42;  expected[8'hF7] = 8'h68;
    expected[8'hF8] = 8'h41;  expected[8'hF9] = 8'h99;
    expected[8'hFA] = 8'h2d;  expected[8'hFB] = 8'h0f;
    expected[8'hFC] = 8'hb0;  expected[8'hFD] = 8'h54;
    expected[8'hFE] = 8'hbb;  expected[8'hFF] = 8'h16;

    pass_count = 0;
    fail_count = 0;

    // Apply all 256 test vectors sequentially.
    for (i = 0; i < 256; i = i + 1) begin
      byte_in = i[7:0];
      #1; // Wait for combinational logic to settle.
      if (byte_out === expected[i]) begin
        $display("[PASS] Input: %h, Output: %h", byte_in, byte_out);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] Input: %h, Expected: %h, Got: %h", byte_in, expected[i], byte_out);
        fail_count = fail_count + 1;
      end
    end

    $display("TEST SUMMARY: %0d PASS, %0d FAIL", pass_count, fail_count);
    $finish;
  end

endmodule
