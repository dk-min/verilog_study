module T_FF (
    output q,
    input clk,
    input reset
);

wire d;

D_FF dff0(.q(q), .d(d), .clk(clk), .reset(reset));
not n1(d, q);

endmodule