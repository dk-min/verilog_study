module fulladder4 (
    input [3:0] a, b, 
    input c_in,
    output [3:0] sum, 
    output c_out
);

assign {c_out, sum} = a + b + c_in;

endmodule