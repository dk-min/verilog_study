// 4 in 1 multiplexer
module multiplexer (
    input i0, i1, i2, i3,
    output out,
    input s0, s1
);

assign out = s1 ? (s0 ? i3 : i2) : (s0 ? i1 : i0);

endmodule