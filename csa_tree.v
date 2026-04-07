`timescale 1ns / 1ps
// Tree-based CSA network for FOUR 4-bit operands.
//
// Reduction plan (4 inputs -> 2 operands for final CPA):
//
//   Stage 1:  A + B + C  -->  s1[3:0], c1[3:0]   (c1 is weight-1 shifted)
//   Stage 2:  D + s1 + (c1<<1)  -->  s2[4:0], c2[4:0]  (c2 weight-1 shifted)
//
// After stage 2 we have two vectors s2 and c2 whose weighted sum equals
// A+B+C+D exactly.  The final carry-propagate adder resolves them.
//
// Output width: ceil(log2(4 * 15)) + 1 = 6 bits  (max sum = 60)
//
// Exposed stage visibility wires are kept for debug / simulation probing.

module csa_tree (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] C,
    input  wire [3:0] D,

    // Stage visibility (handy for simulation)
    output wire [3:0] stage1_sum,
    output wire [3:0] stage1_carry,

    // Final two operands fed to the carry-propagate adder.
    // Both are 6 bits wide to cover the full result range.
    output wire [5:0] final_sum_operand,
    output wire [5:0] final_carry_operand
);

    // ------------------------------------------------------------------
    // Stage 1: compress A, B, C
    //   s1 = A XOR B XOR C  (bit-weight 1)
    //   c1 = majority(A,B,C) (bit-weight 2, i.e. needs <<1 before adding)
    // ------------------------------------------------------------------
    csa #(.WIDTH(4)) csa_stage1 (
        .in1  (A),
        .in2  (B),
        .in3  (C),
        .sum  (stage1_sum),
        .carry(stage1_carry)
    );

    // ------------------------------------------------------------------
    // Stage 2: compress D, s1, (c1<<1)
    //
    // c1 has bit-weight 2, so we present it shifted left by 1.
    // Together with D (weight 1) and s1 (weight 1) the CSA produces:
    //   s2 (weight 1)  and  c2 (weight 2, needs <<1 before adding)
    //
    // Width of this CSA is 5 bits to accommodate the shifted carry input.
    // ------------------------------------------------------------------
    wire [4:0] in2_stage2 = {1'b0, stage1_sum};          // D zero-extended
    wire [4:0] in3_stage2 = {1'b0, D};                   // s1 zero-extended
    wire [4:0] in4_stage2 = {stage1_carry, 1'b0};        // c1 << 1  (correct single shift)

    wire [4:0] stage2_sum;
    wire [4:0] stage2_carry;

    csa #(.WIDTH(5)) csa_stage2 (
        .in1  (in2_stage2),
        .in2  (in3_stage2),
        .in3  (in4_stage2),
        .sum  (stage2_sum),
        .carry(stage2_carry)
    );

    // ------------------------------------------------------------------
    // Package outputs for the final carry-propagate adder.
    // stage2_carry has bit-weight 2 (needs <<1).
    // Both operands are zero-extended to 6 bits.
    // ------------------------------------------------------------------
    assign final_sum_operand   = {1'b0, stage2_sum};           // [5:0]
    assign final_carry_operand = {stage2_carry, 1'b0};         // carry << 1, [5:0]

endmodule