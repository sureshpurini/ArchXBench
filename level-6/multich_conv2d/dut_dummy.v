module multich_conv2d #(
    parameter CIN = 3,
    parameter COUT = 8,
    parameter K = 3,
    parameter H = 64,
    parameter W = 64,
    parameter DATA_W = 8,
    parameter BIAS_W = 16,
    parameter OUT_W = 16
)(
    input clk, rst,
    input [DATA_W-1:0] pixel_in,
    input valid_in,
    input last_in,
    input [COUT*CIN*K*K*DATA_W-1:0] kernel,
    input [COUT*BIAS_W-1:0] bias,
    output reg [OUT_W-1:0] pixel_out,
    output reg valid_out,
    output reg done
);

    reg [31:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            valid_out <= 0;
            pixel_out <= 0;
            done <= 0;
        end else if (valid_in) begin
            counter <= counter + 1;
            valid_out <= 1;
            pixel_out <= pixel_in + counter[7:0];
            done <= last_in;
        end else begin
            valid_out <= 0;
            done <= 0;
        end
    end

endmodule
