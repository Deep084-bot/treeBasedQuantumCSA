`timescale 1ns / 1ps

// Top module: six 8-bit inputs compressed by CSA tree,
// then resolved by a 16-bit ripple-carry final adder.
module top_csa_tree (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [7:0] C,
    input  wire [7:0] D,
    input  wire [7:0] E,
    input  wire [7:0] F,
    output wire [15:0] result
);
    // Intermediate visibility from CSA tree.
    wire [7:0] stage1_sum;
    wire [7:0] stage1_carry;
    wire [7:0] stage2_sum;
    wire [7:0] stage2_carry;

    wire [15:0] final_sum_operand;
    wire [15:0] final_carry_operand;
    wire        final_cout;

    csa_tree u_csa_tree (
        .A                 (A),
        .B                 (B),
        .C                 (C),
        .D                 (D),
        .E                 (E),
        .F                 (F),
        .stage1_sum        (stage1_sum),
        .stage1_carry      (stage1_carry),
        .stage2_sum        (stage2_sum),
        .stage2_carry      (stage2_carry),
        .final_sum_operand (final_sum_operand),
        .final_carry_operand(final_carry_operand)
    );

    final_adder #(.WIDTH(16)) u_final_adder (
        .x   (final_sum_operand),
        .y   (final_carry_operand),
        .sum (result),
        .cout(final_cout)
    );
endmodule
