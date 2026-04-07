`timescale 1ns / 1ps
// Self-checking testbench for the pipelined 4-input 4-bit CSA tree.
//
// The DUT has a 2-cycle pipeline latency, so we:
//   1. Apply inputs for one clock.
//   2. Wait 2 more clocks to let the result propagate.
//   3. Check the output.
//
// Expected value is computed with {2'b0, tX} zero-extensions to avoid
// implicit 4-bit overflow in the addition expression.

module testbench;

    // Clock period
    parameter CLK_PERIOD = 10; // 10 ns = 100 MHz

    reg        clk;
    reg        rst;
    reg  [3:0] A, B, C, D;
    wire [5:0] result;

    // Overflow-safe expected (max = 4*15 = 60, fits in 6 bits)
    reg  [5:0] expected;

    // Error counter
    integer errors;

    // DUT
    top_csa_tree dut (
        .clk   (clk),
        .rst   (rst),
        .A     (A),
        .B     (B),
        .C     (C),
        .D     (D),
        .result(result)
    );

    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task: apply inputs, advance pipeline, check output
    task run_case;
        input [3:0] tA, tB, tC, tD;
        begin
            // Apply inputs on rising edge
            @(posedge clk);
            A = tA; B = tB; C = tC; D = tD;

            // Wait 2 pipeline stages to flush result
            @(posedge clk);
            @(posedge clk);
            #1; // small delta after clock edge for stable sampling

            // Compute expected with zero-extended operands (no 4-bit wrap)
            expected = {2'b00, tA} + {2'b00, tB} + {2'b00, tC} + {2'b00, tD};

            if (result !== expected) begin
                $display("FAIL at t=%0t: A=%0d B=%0d C=%0d D=%0d | result=%0d expected=%0d",
                         $time, tA, tB, tC, tD, result, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: A=%0d B=%0d C=%0d D=%0d | result=%0d", tA, tB, tC, tD, result);
            end
        end
    endtask

    initial begin
        errors = 0;

        // Reset for 4 cycles
        rst = 1; A = 0; B = 0; C = 0; D = 0;
        repeat (4) @(posedge clk);
        rst = 0;

        // ── Basic cases ──────────────────────────────────────
        run_case(4'd0,  4'd0,  4'd0,  4'd0);   // all zeros
        run_case(4'd1,  4'd2,  4'd3,  4'd4);   // small values  -> 10
        run_case(4'd5,  4'd5,  4'd5,  4'd5);   // equal values  -> 20

        // ── Edge / stress cases ──────────────────────────────
        run_case(4'd15, 4'd0,  4'd0,  4'd0);   // one max        -> 15
        run_case(4'd15, 4'd15, 4'd15, 4'd15);  // all max        -> 60
        run_case(4'd8,  4'd4,  4'd2,  4'd1);   // powers of 2    -> 15
        run_case(4'd7,  4'd9,  4'd3,  4'd11);  // mixed          -> 30
        run_case(4'd15, 4'd1,  4'd0,  4'd0);   // near-max       -> 16

        // ── Reset mid-stream check ───────────────────────────
        @(posedge clk); rst = 1;
        @(posedge clk); @(posedge clk); @(posedge clk);
        rst = 0;
        run_case(4'd6,  4'd6,  4'd6,  4'd6);   // after reset -> 24

        // ── Done ─────────────────────────────────────────────
        @(posedge clk);
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule