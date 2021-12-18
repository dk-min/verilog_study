module D_FF (
    output q, qbar,
    input d,
    input clk,
    input reset
);

wire cbar, s, sbar, r, rbar;

assign cbar = ~reset; // reset = clear

assign sbar = ~(rbar & s);
assign s = ~(sbar & ~clk & cbar);
assign r = ~(s & ~clk & rbar);
assign rbar = ~(r & cbar & d);

assign q = ~(s & qbar);
assign qbar = ~(q & cbar & r);
    
endmodule