`timescale 1ns / 1ps

// Nexys A7 board wrapper.
// - A maps to SW[7:0]
// - B maps to SW[15:8]
// - C, D, E, F use internal test patterns selected by buttons.
//   This keeps the required top_csa_tree interface unchanged.
module top_csa_tree_nexys (
    input  wire [15:0] SW,
    input  wire        BTNU,
    input  wire        BTND,
    input  wire        BTNL,
    input  wire        BTNR,
    output wire [15:0] LED
);
    wire [7:0] A;
    wire [7:0] B;
    wire [7:0] C;
    wire [7:0] D;
    wire [7:0] E;
    wire [7:0] F;

    assign A = SW[7:0];
    assign B = SW[15:8];

    // Default internal values can be overridden by button presses.
    assign C = BTNU ? 8'hFF : 8'h0F;
    assign D = BTND ? 8'h55 : 8'h33;
    assign E = BTNL ? 8'hAA : 8'h11;
    assign F = BTNR ? 8'h80 : 8'h22;

    top_csa_tree u_top_csa_tree (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .E(E),
        .F(F),
        .result(LED)
    );
endmodule
