`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/10 02:33:50
// Design Name: color generator
// Module Name: gen_color
// Project Name: test color verilog
// Target Devices: pynq z2
// Tool Versions: 2018.2
// Description: This moudule can be adapted in 720p  
//              i_ready, o_valid,o_start, o_last are in Axi bus
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define linesize 1280
`define framesize 1280*720
module gen_color(
    input clk,
    input resetn,
    input i_ready,
    output reg [23:0] color, // 8/8/8 bit color
    output reg o_valid,
    output reg o_start,
    output reg o_last
    );

    reg [1:0] state;

    localparam  IDLE = 'd0,
                SEND_DATA = 'd1,
                END_LINE = 'd2;

    integer line_counter, frame_data;

    always @(*) begin
        if (line_counter < 427) 
            color <= 24'h0000ff;
        else if(line_counter < 853)
            color <= 24'h00ff00;
        else
            color <= 24'hff0000;
    end

    always @(posedge clk) begin
        if(!resetn)
        begin
            state <= IDLE;
            o_valid <= 0;
            o_start <= 0;
            o_last <= 0;
            line_counter <= 0;
            frame_data <= 0;
        end
        case (state)
            IDLE : begin
                o_start <= 1;
                o_valid <= 1;
                state <= SEND_DATA;
            end
            SEND_DATA : begin
                if(i_ready)
                begin
                    o_start <= 0;
                    frame_data <= frame_data + 1;
                    line_counter <= line_counter + 1;    
                end
                if(line_counter == `linesize - 2)
                begin
                    line_counter <= 0;
                    state <= END_LINE;
                    o_last <= 1;
                end
            end
            END_LINE : begin
                if(i_ready)
                begin
                    o_last <= 0;
                    line_counter <= 0;
                    frame_data <= frame_data + 1;
                end
                if (frame_data == `framesize - 1) begin
                    state <= IDLE;
                    o_valid <= 0;
                    frame_data <= 0;
                end
                else
                begin
                    state <= SEND_DATA;                   
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

endmodule
