module fulladder (
    input a, b, c_in,
    output sum, c_out
);

wire s1, s2, c1;
xor(s1, a, b);
and(c1, a, b);
and(s2, s1, c_in);

//output
xor(sum, s1, c_in);
xor(c_out, s2, c1);

endmodule