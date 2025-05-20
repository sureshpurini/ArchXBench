module shift_add_mult #(
    parameter WIDTH = 16,
    parameter PARALLEL_OPS = 1,
    parameter SIGNED = 1
) (
    input clk,
    input rst,
    input start,
    input valid_in,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input signed_mode,
    output reg [2*WIDTH-1:0] result,
    output reg valid_out,
    output reg done,
    output reg busy
);

    // Derived parameters
    localparam NUM_CYCLES = WIDTH / PARALLEL_OPS;
    localparam CYCLE_BITS = $clog2(NUM_CYCLES + 1);
    
    // State machine states
    localparam IDLE = 2'b00;
    localparam MULTIPLY = 2'b01;
    localparam FINISH = 2'b10;
    
    // Internal registers
    reg [1:0] state;
    reg [CYCLE_BITS-1:0] cycle_count;
    reg [2*WIDTH-1:0] accumulator;
    reg [WIDTH-1:0] multiplicand_reg;
    reg [WIDTH-1:0] multiplier_reg;
    reg result_negative;
    
    // Process multiple bits in parallel
    integer i;
    reg [2*WIDTH-1:0] partial_sum;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            result <= {2*WIDTH{1'b0}};
            valid_out <= 1'b0;
            done <= 1'b0;
            busy <= 1'b0;
            cycle_count <= {CYCLE_BITS{1'b0}};
            accumulator <= {2*WIDTH{1'b0}};
            multiplicand_reg <= {WIDTH{1'b0}};
            multiplier_reg <= {WIDTH{1'b0}};
            result_negative <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    valid_out <= 1'b0;
                    
                    if (start && valid_in) begin
                        busy <= 1'b1;
                        accumulator <= {2*WIDTH{1'b0}};
                        cycle_count <= {CYCLE_BITS{1'b0}};
                        
                        // Handle signed/unsigned operations
                        if (SIGNED && signed_mode) begin
                            // Calculate result sign
                            result_negative <= A[WIDTH-1] ^ B[WIDTH-1];
                            
                            // Convert to absolute values
                            multiplicand_reg <= A[WIDTH-1] ? (~A + 1'b1) : A;
                            multiplier_reg <= B[WIDTH-1] ? (~B + 1'b1) : B;
                        end else begin
                            // Unsigned operation
                            result_negative <= 1'b0;
                            multiplicand_reg <= A;
                            multiplier_reg <= B;
                        end
                        
                        state <= MULTIPLY;
                    end
                end
                
                MULTIPLY: begin
                    // Process PARALLEL_OPS bits per cycle
                    partial_sum = {2*WIDTH{1'b0}};
                    
                    for (i = 0; i < PARALLEL_OPS; i = i + 1) begin
                        // Check if we're still within valid bit range
                        if (cycle_count * PARALLEL_OPS + i < WIDTH) begin
                            // If multiplier bit is 1, add shifted multiplicand
                            if (multiplier_reg[cycle_count * PARALLEL_OPS + i]) begin
                                partial_sum = partial_sum + ({{WIDTH{1'b0}}, multiplicand_reg} << (cycle_count * PARALLEL_OPS + i));
                            end
                        end
                    end
                    
                    // Add partial sum to accumulator
                    accumulator <= accumulator + partial_sum;
                    
                    // Check if we've processed all bits
                    if (cycle_count == NUM_CYCLES - 1) begin
                        state <= FINISH;
                    end else begin
                        cycle_count <= cycle_count + 1'b1;
                    end
                end
                
                FINISH: begin
                    // Apply sign correction if needed
                    if (result_negative) begin
                        result <= ~accumulator + 1'b1;
                    end else begin
                        result <= accumulator;
                    end
                    
                    valid_out <= 1'b1;
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule