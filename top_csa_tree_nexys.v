`timescale 1ns / 1ps
// Nexys A7 board wrapper for the 4-input 4-bit pipelined CSA tree.
//
// Switch mapping:
//   SW[3:0]   -> A
//   SW[7:4]   -> B
//   SW[11:8]  -> C
//   SW[15:12] -> D
//
// Clock:
//   CLK100MHZ (pin E3, 100 MHz on-board oscillator) drives the pipeline.
//
// Output:
//   LED[5:0]  displays the 6-bit result (max = 60).
//   LED[15:6] held low (unused).
//
// Pipeline latency: 2 cycles (~20 ns at 100 MHz) -- invisible to the eye.

module top_csa_tree_nexys (
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,    // active-low reset button on Nexys A7
    input  wire [15:0] SW,
    output wire [15:0] LED
);

    // Active-high synchronous reset (invert the active-low button)
    wire rst = ~CPU_RESETN;

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

    // Drive the lower 6 LEDs with the result; turn off the rest
    assign LED[5:0]  = result;
    assign LED[15:6] = 10'b0;

endmodule