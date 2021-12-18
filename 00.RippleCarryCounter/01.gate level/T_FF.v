module T_FF (
    output q,
    input clk,
    input reset
);


D_FF dff0(.q(q), .d(~q), .clk(clk), .reset(reset));
//qbar isn't connected.

endmodule