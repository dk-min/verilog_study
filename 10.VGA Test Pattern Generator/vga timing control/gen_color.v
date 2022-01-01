`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/01 14:50:18
// Design Name: 
// Module Name: gen_color
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gen_color(
    input clk,
    input resetn,
    output reg [23:0] pixel,
    output hsync_out,
    output vsync_out,
    output pVDE // Video Data Valid
    );

    wire [10:0] counter;

    hvsync_generator hvsync(
      .clk(clk),
      .resetn(resetn),
      .vga_h_sync(hsync_out),
      .vga_v_sync(vsync_out),
      .counterX(counter),
      //.counterY(CounterY),
      .inDisplayArea(pVDE)
    );

    always @(*) begin
        if(counter < 427)
            pixel <= 24'h0000ff;
        else if(counter < 853)
            pixel <= 24'h00ff00;
        else if(counter < 1280)
            pixel <= 24'hff0000;
        else
            pixel <= 24'h000000;
    end


endmodule
