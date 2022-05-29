//////////////////////////////////////////////////////////////////////
// Author:      Jasper Min
//////////////////////////////////////////////////////////////////////
// Description: This file contains the UART Configuration Register.  
//              This register is able to contorl enable, CLK_PER_BIT,
//              and read status, etc using APB3 Bus.
//              
// 
// Parameters:  Set Parameter CLKS_PER_BIT as follows:
//              CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
//              Example: 25 MHz Clock, 115200 baud UART
//              (25000000)/(115200) = 217
//////////////////////////////////////////////////////////////////////////////

module UART_REG
(
	 input                 	PCLK,
	 input					PRESETn,
	 input      [31:0]     	PADDR,
	 input                 	PWRITE,
	 input                 	PSEL,
	 input                 	PENABLE,
	 input      [31:0]     	PWDATA,
	 output reg [31:0]     	PRDATA
 );

wire TXE, RXNE; // TXT : Transmit data register empty, RXNE : Read data register not empty


reg [31:00] status = 32'hff; // read only
reg [07:00] TDR;    //Trasmit Data Register
reg [07:00] RDR;    //Receive Data Register
reg [31:00] CPB; // CLKS_PER_BIT

wire write	= PSEL & PENABLE & PWRITE;
wire read 	= PSEL & ~PWRITE;

// always@(*) begin	
// 	status[7] <= TXE;	
// 	status[5] <= RXNE;	
// end

always@(posedge PCLK or negedge PRESETn) begin
	if(!PRESETn) begin
		TDR		<= 0;
		RDR		<= 0;
		PRDATA 	<= 0;
	end
	else begin
		if(write) begin
			case(PADDR[3:0])
			4'h4 : TDR 	<= PWDATA[7:0];
			4'hc : CPB 	<= PWDATA;
			endcase
		end
		if(read) begin
			case(PADDR[3:0])
			4'h0 : PRDATA 	<= status;
			4'h4 : PRDATA 	<= {24'h0, TDR};
			4'h8 : PRDATA 	<= {24'h0, RDR};
			4'hc : PRDATA 	<= CPB;
			default : PRDATA <= 0;
			endcase
		end
		else
			PRDATA <= 0;

	end
end


endmodule // UART_RX
