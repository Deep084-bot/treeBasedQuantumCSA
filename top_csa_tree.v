`timescale 1ns / 1ps
// Top module: four 4-bit inputs compressed by a CSA tree,
// then resolved by a 6-bit ripple-carry final adder.
//
// Pipeline structure (2 stages):
//   Stage 1 register: captures CSA tree outputs after combinational reduction.
//   Stage 2 register: captures the final adder result.
//
// Latency: 2 clock cycles.
// Throughput: 1 result per clock once pipeline is full.

module top_csa_tree (
    input  wire       clk,
    input  wire       rst,      // synchronous active-high reset

    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] C,
    input  wire [3:0] D,

    output reg  [5:0] result    // max sum = 4*15 = 60, fits in 6 bits
);

    // ------------------------------------------------------------------
    // Combinational CSA tree
    // ------------------------------------------------------------------
    wire [3:0] stage1_sum;
    wire [3:0] stage1_carry;
    wire [5:0] csa_sum_operand;
    wire [5:0] csa_carry_operand;

    csa_tree u_csa_tree (
        .A                  (A),
        .B                  (B),
        .C                  (C),
        .D                  (D),
        .stage1_sum         (stage1_sum),
        .stage1_carry       (stage1_carry),
        .final_sum_operand  (csa_sum_operand),
        .final_carry_operand(csa_carry_operand)
    );

    // ------------------------------------------------------------------
    // Pipeline Stage 1 register: hold CSA outputs
    // ------------------------------------------------------------------
    reg [5:0] p1_sum;
    reg [5:0] p1_carry;

    always @(posedge clk) begin
        if (rst) begin
            p1_sum   <= 6'b0;
            p1_carry <= 6'b0;
        end else begin
            p1_sum   <= csa_sum_operand;
            p1_carry <= csa_carry_operand;
        end
    end

    // ------------------------------------------------------------------
    // Final carry-propagate adder (combinational, feeds stage 2 reg)
    // ------------------------------------------------------------------
    wire [5:0] adder_result;
    wire       adder_cout;       // overflow guard; max=60 so never set

    final_adder #(.WIDTH(6)) u_final_adder (
        .x   (p1_sum),
        .y   (p1_carry),
        .sum (adder_result),
        .cout(adder_cout)        // tied off; kept for lint cleanliness
    );

    // ------------------------------------------------------------------
    // Pipeline Stage 2 register: hold final result
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            result <= 6'b0;
        else
            result <= adder_result;
    end

endmodule