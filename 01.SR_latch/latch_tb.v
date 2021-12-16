module top;

wire q, q_bar;
reg set, reset;

SR_latch m1(.q(q), .q_bar(q_bar), .set_bar(~set), .reset_bar(~reset));

initial begin
    $dumpfile("latch.vcd");
    $dumpvars(0, m1);
end

initial begin
    $monitor($time, " set = %b, reset= %b, q= %b\n", set, reset, q);
    set = 0; reset = 0;
    #5 reset = 1;
    #5 reset = 0;
    #5 set = 1;
end

endmodule