`timescale 1ns / 1ps

// Parameterized ripple-carry adder used for the final carry propagation.
module final_adder #(
    parameter WIDTH = 16
) (
    input  wire [WIDTH-1:0] x,
    input  wire [WIDTH-1:0] y,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);
    wire [WIDTH:0] c;
    assign c[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_rca_bits
            full_adder fa_i (
                .a   (x[i]),
                .b   (y[i]),
                .cin (c[i]),
                .sum (sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate

    assign cout = c[WIDTH];
endmodule
