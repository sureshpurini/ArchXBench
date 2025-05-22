module conv3d #(
    parameter K1 = 3,
    parameter K2 = 3,
    parameter K3 = 3,
    parameter D = 8,
    parameter H = 64,
    parameter W = 64,
    parameter DATA_W = 8
)(
    input clk,
    input rst,
    input [DATA_W-1:0] voxel_in,
    input valid_in,
    input [K1*K2*K3*DATA_W-1:0] kernel,
    input last_in,
    output reg [DATA_W+4-1:0] voxel_out,
    output reg valid_out,
    output reg done
);

    reg [31:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            valid_out <= 0;
            voxel_out <= 0;
            done <= 0;
        end else if (valid_in) begin
            counter <= counter + 1;
            valid_out <= 1;
            voxel_out <= voxel_in + counter[7:0];
            done <= last_in;
        end else begin
            valid_out <= 0;
            done <= 0;
        end
    end

endmodule
