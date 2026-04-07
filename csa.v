`timescale 1ns / 1ps
// Carry Save Adder (CSA): compresses three WIDTH-bit inputs into
// sum and carry vectors. Numeric relation:
//   in1 + in2 + in3 = sum + (carry << 1)
// Default WIDTH changed to 4 for the 4-input 4-bit design.
module csa #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    output wire [WIDTH-1:0] sum,
    output wire [WIDTH-1:0] carry
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_csa_bits
            full_adder fa_i (
                .a   (in1[i]),
                .b   (in2[i]),
                .cin (in3[i]),
                .sum (sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate
endmodule