module top;

reg i0, i1, i2, i3;
wire out;
reg s0, s1;

multiplexer m1(.i0(i0), .i1(i1), .i2(i2), .i3(i3), .out(out), .s0(s0), .s1(s1));

initial begin
    $dumpfile("muxgen.vcd");
    $dumpvars(0, m1);
end

initial begin
    s0 = 0; s1 = 0; i0 = 1; i1 = 0; i2 = 0; i3 = 0;
    $monitor($time, " s0 = %b, s1 = %b, OUT = %b", s0, s1, out);
    #1
    s0 = 1; s1 = 0;
    #1
    i0 = 0; i1 = 1;
    #1
    s0 = 0; s1 = 1;
    #1
    i1 = 0; i2 = 1;
    #1
    s0 = 1; s1 = 1;
    #1
    i2 = 0; i3 = 1;
    #1
    s0 = 0; s1 = 0;
    #1
    i3 = 0; i1 = 1;

end

endmodule