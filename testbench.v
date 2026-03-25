`timescale 1ns / 1ps

module testbench;
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [7:0] C;
    reg  [7:0] D;
    reg  [7:0] E;
    reg  [7:0] F;
    wire [15:0] result;

    // Expected value for self-checking.
    reg  [15:0] expected;

    top_csa_tree dut (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .E(E),
        .F(F),
        .result(result)
    );

    task run_case;
        input [7:0] tA;
        input [7:0] tB;
        input [7:0] tC;
        input [7:0] tD;
        input [7:0] tE;
        input [7:0] tF;
        begin
            A = tA;
            B = tB;
            C = tC;
            D = tD;
            E = tE;
            F = tF;
            #10;

            expected = tA + tB + tC + tD + tE + tF;

            if (result !== expected) begin
                $display("FAIL: A=%0d B=%0d C=%0d D=%0d E=%0d F=%0d | result=%0d expected=%0d",
                         tA, tB, tC, tD, tE, tF, result, expected);
            end else begin
                $display("PASS: A=%0d B=%0d C=%0d D=%0d E=%0d F=%0d | result=%0d",
                         tA, tB, tC, tD, tE, tF, result);
            end
        end
    endtask

    initial begin
        // Basic checks
        run_case(8'd0,   8'd0,   8'd0,   8'd0,   8'd0,   8'd0);
        run_case(8'd1,   8'd2,   8'd3,   8'd4,   8'd5,   8'd6);
        run_case(8'd10,  8'd20,  8'd30,  8'd40,  8'd50,  8'd60);

        // Edge and stress checks
        run_case(8'd255, 8'd0,   8'd0,   8'd0,   8'd0,   8'd0);
        run_case(8'd255, 8'd255, 8'd255, 8'd255, 8'd255, 8'd255);
        run_case(8'd128, 8'd64,  8'd32,  8'd16,  8'd8,   8'd4);
        run_case(8'd7,   8'd19,  8'd33,  8'd47,  8'd59,  8'd71);

        #10;
        $finish;
    end
endmodule
