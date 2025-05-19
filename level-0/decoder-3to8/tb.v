module decoder_3to8 (
    input wire [2:0] in,
    input wire enable,
    output wire [7:0] out
);
    // Uses two 2:4 decoders for hierarchical design
    wire [3:0] stage_out;
    
    decoder_2to4 stage0 (
        .in(in[1:0]),
        .enable(enable & ~in[2]),
        .out(stage_out)
    );
    
    decoder_2to4 stage1 (
        .in(in[1:0]),
        .enable(enable & in[2]),
        .out(out[7:4])
    );
    
    assign out[3:0] = stage_out;
endmodule
