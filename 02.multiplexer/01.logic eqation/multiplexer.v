// 4 in 1 multiplexer
module multiplexer (
    input i0, i1, i2, i3,
    output out,
    input s0, s1
);

assign out = (~s1 & ~s0 & i0) | (~s1 & s0 & i1) |  (s1 & ~s0 & i2) |  (s1 & s0 & i3);

endmodule