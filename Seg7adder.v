`timescale 1ns / 1ps
// seg7_driver.v
// Displays a 6-bit value (0-60) as two decimal digits on the
// Nexys A7 multiplexed 7-segment display.
//
// The Nexys A7 has 8 digit positions sharing one set of 7 segment lines.
// Each digit is selected by driving its AN (anode) line LOW (active-low).
// Segments are also active-low (0 = segment ON).
//
// We use the rightmost two digits:
//   AN[0] = units digit  (rightmost)
//   AN[1] = tens digit
//   AN[7:2] = off (driven HIGH)
//
// Segment encoding (active-low, standard a-g):
//
//      aaa
//     f   b
//     f   b
//      ggg
//     e   c
//     e   c
//      ddd  (dp = decimal point, unused)
//
// seg = {g, f, e, d, c, b, a}  -- bit 6 = g, bit 0 = a
//
// Multiplexing rate: 100 MHz / 2^17 = ~763 Hz per digit
// (fast enough to look steady, slow enough to be glitch-free)

module seg7_driver (
    input  wire       clk,
    input  wire       rst,
    input  wire [5:0] value,      // 0-60

    // Nexys A7 seven-segment interface
    output reg  [7:0] AN,         // anode select, active-low (1 = off)
    output reg  [6:0] SEG,        // segments {g,f,e,d,c,b,a}, active-low
    output wire       DP          // decimal point (always off)
);

    assign DP = 1'b1;  // decimal point off

    // ------------------------------------------------------------------
    // Divide 100 MHz down to a ~763 Hz digit-select tick
    // 17-bit counter: 2^17 = 131072 cycles at 100MHz = 1.31ms per digit
    // ------------------------------------------------------------------
    reg [16:0] clk_div;
    always @(posedge clk) begin
        if (rst) clk_div <= 0;
        else     clk_div <= clk_div + 1;
    end

    wire digit_sel = clk_div[16];  // 0 = show units, 1 = show tens

    // ------------------------------------------------------------------
    // BCD split: tens and units
    // value is 0-60, so tens is 0-6 and units is 0-9.
    // We use a simple subtraction chain (no divider needed for 0-60).
    // ------------------------------------------------------------------
    reg [3:0] tens;
    reg [3:0] units;

    always @(*) begin
        if      (value >= 60) begin tens = 4'd6; units = value - 6'd60; end
        else if (value >= 50) begin tens = 4'd5; units = value - 6'd50; end
        else if (value >= 40) begin tens = 4'd4; units = value - 6'd40; end
        else if (value >= 30) begin tens = 4'd3; units = value - 6'd30; end
        else if (value >= 20) begin tens = 4'd2; units = value - 6'd20; end
        else if (value >= 10) begin tens = 4'd1; units = value - 6'd10; end
        else                  begin tens = 4'd0; units = value[3:0];    end
    end

    // ------------------------------------------------------------------
    // BCD to 7-segment decoder (active-low segments, {g,f,e,d,c,b,a})
    // ------------------------------------------------------------------
    function [6:0] bcd_to_seg;
        input [3:0] bcd;
        case (bcd)
            4'd0: bcd_to_seg = 7'b100_0000;  // 0: a,b,c,d,e,f on
            4'd1: bcd_to_seg = 7'b111_1001;  // 1: b,c on
            4'd2: bcd_to_seg = 7'b010_0100;  // 2: a,b,d,e,g on
            4'd3: bcd_to_seg = 7'b011_0000;  // 3: a,b,c,d,g on
            4'd4: bcd_to_seg = 7'b001_1001;  // 4: b,c,f,g on
            4'd5: bcd_to_seg = 7'b001_0010;  // 5: a,c,d,f,g on
            4'd6: bcd_to_seg = 7'b000_0010;  // 6: a,c,d,e,f,g on
            4'd7: bcd_to_seg = 7'b111_1000;  // 7: a,b,c on
            4'd8: bcd_to_seg = 7'b000_0000;  // 8: all on
            4'd9: bcd_to_seg = 7'b001_0000;  // 9: a,b,c,d,f,g on
            default: bcd_to_seg = 7'b111_1111; // off
        endcase
    endfunction

    // ------------------------------------------------------------------
    // Multiplexer: alternate between tens and units digit
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            AN  <= 8'b1111_1111;
            SEG <= 7'b111_1111;
        end else begin
            if (digit_sel == 1'b0) begin
                // Show units digit on AN[0]
                AN  <= 8'b1111_1110;
                SEG <= bcd_to_seg(units);
            end else begin
                // Show tens digit on AN[1]
                // If tens = 0 and value < 10, blank the tens digit
                if (tens == 4'd0)
                    AN <= 8'b1111_1111;   // blank (leading zero suppression)
                else
                    AN <= 8'b1111_1101;
                SEG <= bcd_to_seg(tens);
            end
        end
    end

endmodule