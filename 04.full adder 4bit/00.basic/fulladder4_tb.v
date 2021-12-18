module top;

reg [3:0] a, b; 
reg c_in;
wire [3:0] sum;
wire cout;

fulladder4 f1(a, b, c_in, sum, c_out);

initial begin
    $dumpfile("4bit_fulladder.vcd");
    $dumpvars(0, f1);
end

initial begin
    $monitor($time, " a = %b,  b = %b,  c_in = %b, sum = %b, c_out = %b", a, b, c_in, sum, c_out);
    a = 4'd0; b = 4'd0; c_in = 1'b0;
    
    #5
    a = 4'd3; b = 4'd4; c_in = 0;
    
    #5
    a = 4'd2; b = 4'd5; c_in = 0;
    
    #5
    a = 4'd9; b = 4'd9; c_in = 0;
    
    #5
    a = 4'd10; b = 4'd15; c_in = 0;
    
    #5
    a = 4'd10; b = 4'd5; c_in = 1;
    
    #5
    $finish;
end

endmodule