`timescale 1ns / 1ps

// 1-bit full adder built from basic logic gates.
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire axb;
    wire ab;
    wire ac;
    wire bc;

    xor (axb, a, b);
    xor (sum, axb, cin);

    and (ab, a, b);
    and (ac, a, cin);
    and (bc, b, cin);
    or  (cout, ab, ac, bc);
endmodule
