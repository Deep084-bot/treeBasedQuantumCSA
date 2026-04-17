`timescale 1ns / 1ps
// top_csa_tree_nexys.v  (updated for 7-segment display output)
//
// Nexys A7 board wrapper for the 4-input 4-bit pipelined CSA tree.
//
// Switch mapping:
//   SW[3:0]   -> A
//   SW[7:4]   -> B
//   SW[11:8]  -> C
//   SW[15:12] -> D
//
// Output:
//   7-segment display shows the decimal result (0-60)
//     - rightmost digit (AN[0]) = units
//     - second digit    (AN[1]) = tens  (blank when result < 10)
//   LED[5:0]  still shows the raw 6-bit binary result (bonus debug aid)
//   LED[15:6] held low

module top_csa_tree_nexys (
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,    // active-low reset button
    input  wire [15:0] SW,

    // 7-segment display
    output wire [7:0]  AN,            // anode select, active-low
    output wire [6:0]  SEG,           // segments {g,f,e,d,c,b,a}, active-low
    output wire        DP,            // decimal point (always off)

    // LEDs (binary result, useful for debug)
    output wire [15:0] LED
);

    wire rst = ~CPU_RESETN;  // active-low button -> active-high reset

    // ------------------------------------------------------------------
    // Pipelined CSA core
    // ------------------------------------------------------------------
    wire [5:0] result;

    top_csa_tree u_top_csa_tree (
        .clk   (CLK100MHZ),
        .rst   (rst),
        .A     (SW[3:0]),
        .B     (SW[7:4]),
        .C     (SW[11:8]),
        .D     (SW[15:12]),
        .result(result)
    );

    // ------------------------------------------------------------------
    // 7-segment display driver
    // ------------------------------------------------------------------
    seg7_driver u_seg7 (
        .clk  (CLK100MHZ),
        .rst  (rst),
        .value(result),
        .AN   (AN),
        .SEG  (SEG),
        .DP   (DP)
    );

    // ------------------------------------------------------------------
    // LEDs: raw binary on LED[5:0] for quick debug verification
    // ------------------------------------------------------------------
    assign LED[5:0]  = result;
    assign LED[15:6] = 10'b0;

endmodule