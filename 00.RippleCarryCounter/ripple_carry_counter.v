module ripple_carry_counter(
    output [3:0] q,
    input clk,
    input reset
);

T_FF tff0(.q(q[0]),.clk(clk),.reset(reset));
T_FF tff1(.q(q[1]),.clk(q[0]),.reset(reset));
T_FF tff2(.q(q[2]),.clk(q[1]),.reset(reset));
T_FF tff3(.q(q[3]),.clk(q[2]),.reset(reset));

endmodule