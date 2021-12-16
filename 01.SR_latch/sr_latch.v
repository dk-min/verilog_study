module SR_latch (
    output q,
    output q_bar,
    input set_bar,
    input reset_bar
);

nand n1(q, set_bar, q_bar);
nand n2(q_bar, reset_bar, q);

endmodule