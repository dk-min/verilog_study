module top;

reg a, b, c_in;
wire sum, cout;

fulladder f1(a, b, c_in, sum, c_out);

initial begin
    $dumpfile("fulladder.vcd");
    $dumpvars(0, f1);
end

initial begin
    $monitor($time, " a = %b,  b = %b,  c_in = %b, sum = %b, c_out = %b", a, b, c_in, sum, c_out);
    a = 0; b = 0; c_in = 0;
    #5
    a = 1; b = 0; c_in = 0;
    
    #5
    a = 1; b = 1; c_in = 0;
    
    #5
    a = 0; b = 0; c_in = 1;
    
    #5
    a = 1; b = 0; c_in = 1;
    
    #5
    a = 0; b = 1; c_in = 1;
    
    #5
    a = 1; b = 1; c_in = 1;
    
    #5
    $finish;
end

endmodule