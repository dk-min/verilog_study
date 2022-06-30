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
	 output reg [31:0]     	PRDATA,
	 output      	     	PREADY,
	 output					irqreq
 );

wire TXE, RXNE; // TXT : Transmit data register empty, RXNE : Read data register not empty

  // Testbench uses a 100 MHz clock
  // Want to interface to 115200 baud UART
  // 100000000 / 115200 = 217 Clocks Per Bit.
  localparam c_CLOCK_PERIOD_NS = 10;
  localparam c_CLKS_PER_BIT    = 868;


reg [31:00] status = 32'h00; // read only
reg [07:00] TDR;    //Trasmit Data Register
reg [07:00] RDR;    //Receive Data Register
// reg [31:00] CPB = c_CLKS_PER_BIT; // CLKS_PER_BIT

wire write	= PSEL & PENABLE & PWRITE;
wire read 	= PSEL & ~PWRITE;

wire w_RX_DV;
wire [07:00] w_RX_Byte;

wire w_TX_Active, w_UART_Line;
wire w_TX_Serial, w_Tx_Done;

reg busy = 1'b0;

// always@(*) begin	
// 	status[7] <= TXE;	
// 	status[5] <= RXNE;
// end

assign TXE = status[7] & status[0] & !busy;
assign irqreq = status[5];
assign PREADY = (PADDR[03:00] == 4'h4) ? !busy : 1'b1;
// assign PREADY = ~busy;
always@(posedge PCLK) begin
    if(!PRESETn) begin
        TDR        <= 0;
        RDR        <= 0;
        PRDATA     <= 0;
    end
	if(write) begin
		case(PADDR[3:0])
		4'h0 : status[0] 	<= PWDATA[0];
		4'h4 : begin
				TDR 		<= PWDATA[7:0];
				status[7]	<= 1'b1;
		end
		// 4'hc : CPB 	<= PWDATA;
		endcase
	end
	if(read) begin
		case(PADDR[3:0])
		4'h0 : PRDATA 	<= status;
		4'h4 : PRDATA 	<= {24'h0, TDR};
		4'h8 : begin
			PRDATA 	<= {24'h0, RDR};
			status[5] 	<= 1'b0;
		end
		// 4'hc : PRDATA 	<= CPB;
		default : PRDATA <= 0;
    	endcase
	end
	else
		PRDATA 		<= 0;
	if(TXE) begin
		status[7] 	<= 1'b0;
		busy 		<= 1'b1;
	end
	if(w_RX_DV) begin
	   		status[5] 	<= 1'b1;
            RDR         <= w_RX_Byte;
	end
	if(w_Tx_Done) begin
	   busy		<= 1'b0;
	end
end

  UART_RX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst
    (
	 .i_Clock(PCLK),
     .i_RX_Serial(w_UART_Line),
     .o_RX_DV(w_RX_DV),
     .o_RX_Byte(w_RX_Byte)
     );
	 
  UART_TX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst
    (.i_Clock(PCLK),
     .i_TX_DV(TXE),
     .i_TX_Byte(TDR),
     .o_TX_Active(w_TX_Active),
     .o_TX_Serial(w_TX_Serial),
     .o_TX_Done(w_Tx_Done)
     );

// Keeps the UART Receive input high (default) when
// UART transmitter is not active
assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;


endmodule // UART_RX
