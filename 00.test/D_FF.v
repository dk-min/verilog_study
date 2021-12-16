module D_FF (
    output reg q,
    input d,
    input clk,
    input reset
);

always @(posedge reset or negedge clk) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
    
endmodule