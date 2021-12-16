// 4 in 1 multiplexer
module multiplexer (
    input i0, i1, i2, i3,
    output out,
    input s0, s1
);

wire y0, y1, y2, y3;
wire s0n, s1n;

not n1(s0n, s0);
not n2(s1n, s1);

and a1(y0, i0, s1n, s0n);
and a2(y1, i1, s1n, s0);
and a3(y2, i2, s1, s0n);
and a4(y3, i3, s1, s0);

or o(out, y0, y1, y2, y3);

endmodule