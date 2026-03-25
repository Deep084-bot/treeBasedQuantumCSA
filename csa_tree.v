`timescale 1ns / 1ps

// Tree-based CSA network for six 8-bit operands.
// It returns two 16-bit operands for final carry-propagation addition:
// final_sum_operand + final_carry_operand
module csa_tree (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [7:0] C,
    input  wire [7:0] D,
    input  wire [7:0] E,
    input  wire [7:0] F,

    // Stage visibility for debug/clarity
    output wire [7:0] stage1_sum,
    output wire [7:0] stage1_carry,
    output wire [7:0] stage2_sum,
    output wire [7:0] stage2_carry,

    output wire [15:0] final_sum_operand,
    output wire [15:0] final_carry_operand
);
    // Stage 1: Compress (A, B, C)
    csa #(.WIDTH(8)) csa_stage1 (
        .in1  (A),
        .in2  (B),
        .in3  (C),
        .sum  (stage1_sum),
        .carry(stage1_carry)
    );

    // Stage 2: Compress (D, E, F)
    csa #(.WIDTH(8)) csa_stage2 (
        .in1  (D),
        .in2  (E),
        .in3  (F),
        .sum  (stage2_sum),
        .carry(stage2_carry)
    );

    // Align to include shifted carry terms.
    wire [9:0] op1_s1;
    wire [9:0] op2_c1_shift;
    wire [9:0] op3_s2;
    wire [9:0] op4_c2_shift;

    assign op1_s1      = {2'b00, stage1_sum};
    assign op2_c1_shift = {1'b0, stage1_carry, 1'b0};
    assign op3_s2      = {2'b00, stage2_sum};
    assign op4_c2_shift = {1'b0, stage2_carry, 1'b0};

    // Stage 3: Compress first three aligned operands.
    wire [9:0] stage3_sum;
    wire [9:0] stage3_carry;

    csa #(.WIDTH(10)) csa_stage3 (
        .in1  (op1_s1),
        .in2  (op2_c1_shift),
        .in3  (op3_s2),
        .sum  (stage3_sum),
        .carry(stage3_carry)
    );

    // Stage 4: Compress stage3 result with remaining operand.
    wire [10:0] stage3_sum_ext;
    wire [10:0] stage3_carry_shift;
    wire [10:0] op4_c2_shift_ext;

    wire [10:0] stage4_sum;
    wire [10:0] stage4_carry;

    assign stage3_sum_ext    = {1'b0, stage3_sum};
    assign stage3_carry_shift = {stage3_carry, 1'b0};
    assign op4_c2_shift_ext  = {1'b0, op4_c2_shift};

    csa #(.WIDTH(11)) csa_stage4 (
        .in1  (stage3_sum_ext),
        .in2  (stage3_carry_shift),
        .in3  (op4_c2_shift_ext),
        .sum  (stage4_sum),
        .carry(stage4_carry)
    );

    // Operands for final carry-propagation adder.
    assign final_sum_operand   = {5'b00000, stage4_sum};
    assign final_carry_operand = {4'b0000, stage4_carry, 1'b0};
endmodule
