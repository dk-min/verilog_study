`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/01 14:50:18
// Design Name: 
// Module Name: hvsync_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module is designed for 720p application 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hvsync_generator(
    input clk,
    input resetn,
    output vga_h_sync,
    output vga_v_sync,
    output reg inDisplayArea,
    output reg [10:0] counterX,
    output reg [9:0] counterY
    );

    reg vga_HS, vga_VS;

    wire counterXmaxed = (counterX == 1650); // 1280 + 110 + 40 + 220
    wire counterYmaxed = (counterY == 750); // 720 + 5 + 5 + 20

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counterX <= 0;
        end
        else begin
            if(counterXmaxed)
                counterX <= 0;
            else
                counterX <= counterX + 1;
        end
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counterY <= 0;
        end
        else begin
            if(counterXmaxed) begin
                if (counterYmaxed)
                    counterY <= 0; 
                else
                    counterY <= counterY + 1;
            end
        end
    end

    always @(posedge clk)
    begin
        inDisplayArea <= (counterX < 1280) && (counterY < 720);
    end

    always @(posedge clk)
    begin
        vga_HS = !((counterX > 1280 + 110) && (counterX < 1280 + 110 + 40));
        vga_VS = !((counterY > 720 + 5) && (counterY < 1280 + 110 + 5 + 5));
    end

    assign vga_h_sync = ~vga_HS;
    assign vga_v_sync = ~vga_VS;

endmodule
