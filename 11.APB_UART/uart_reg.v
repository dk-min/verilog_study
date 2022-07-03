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
    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 PCLK CLK" *)
    // Supported parameters: ASSOCIATED_CLKEN, ASSOCIATED_RESET, ASSOCIATED_ASYNC_RESET, ASSOCIATED_BUSIF, CLK_DOMAIN, PHASE, FREQ_HZ
    // Most of these parameters are optional.  However, when using AXI, at least one clock must be associated to the AXI interface.
    // Use the axi interface name for ASSOCIATED_BUSIF, if there are multiple interfaces, separate each name by ':'
    // Use the port name for ASSOCIATED_RESET.
    // Output clocks will require FREQ_HZ to be set (note the value is in HZ and an integer is expected).
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET PRESETn, FREQ_HZ 50000000" *)
    input PCLK, //  (required)
    // Declare the attributes above the port declaration
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PRESETn RST" *)
    // Supported parameter: POLARITY {ACTIVE_LOW, ACTIVE_HIGH}
    // Normally active low is assumed.  Use this parameter to force the level
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input PRESETn, //  (required)
	(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PADDR" *)
    input      [31:0]     	PADDR,
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSEL" *)
   input PSEL, // Slave Select (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PENABLE" *)
   input PENABLE, // Enable (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWRITE" *)
   input PWRITE, // Write Control (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWDATA" *)
   input [31:0] PWDATA, // Write Data (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PREADY" *)
   output PREADY, // Slave Ready (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PRDATA" *)
   output reg [31:0] PRDATA, // Read Data (required)
   (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSLVERR" *)
   output PSLVERR, // Slave Error Response (required)
   // Declare the attributes above the port declaration
   (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 irqreq INTERRUPT" *)
   // Supported parameter: SENSITIVITY { LEVEL_HIGH, LEVEL_LOW, EDGE_RISING, EDGE_FALLING }
   // Normally LEVEL_HIGH is assumed.  Use this parameter to force the level
   (* X_INTERFACE_PARAMETER = "SENSITIVITY EDGE_RISING" *)
   output irqreq 
 );

wire TXE, RXNE; // TXT : Transmit data register empty, RXNE : Read data register not empty

  // Testbench uses a 50 MHz clock
  // Want to interface to 115200 baud UART
  // 50000000 / 115200 = 434 Clocks Per Bit.
  localparam c_CLOCK_PERIOD_NS = 20;
  localparam c_CLKS_PER_BIT    = 434;

reg [31:00] status = 32'h00; // read only
reg [07:00] TDR;    //Trasmit Data Register
// reg [31:00] CPB = c_CLKS_PER_BIT; // CLKS_PER_BIT

wire write	= PSEL & PENABLE & PWRITE;
wire read 	= PSEL & ~PWRITE;

wire w_RX_DV;
wire [07:00] w_RX_Byte;

wire w_TX_Active, w_UART_Line;
wire w_TX_Serial, w_Tx_Done;

reg busy = 1'b0;


assign PSLVERR = 1'b0;
// always@(*) begin	
// 	status[7] <= TXE;	
// 	status[5] <= RXNE;
// end

assign TXE = status[7] & status[0] & !busy;
assign irqreq = status[5];
assign PREADY = (PADDR[11:00] == 12'h4) ? !busy : 1'b1;
// assign PREADY = ~busy;
 

always@(posedge PCLK) begin
	if(~PRESETn) begin
	    PRDATA 	  <= 0;
		status        <= 0;
	end
	if(write) begin
		case(PADDR[11:0])
		12'h0 : status[0] 	<= PWDATA[0];
		12'h4 : begin
				TDR 		<= PWDATA[7:0];
				status[7]	<= 1'b1;
		end
		// 4'hc : CPB 	<= PWDATA;
		endcase
	end
	if(read) begin
		case(PADDR[11:0])
		12'h0 : PRDATA 	<= status;
		12'h4 : PRDATA 	<= {24'h0, TDR};
		12'h8 : begin
			PRDATA 	<= {24'h0, w_RX_Byte};
			status[5] 	<= 1'b0;
		end
		// 4'hc : PRDATA 	<= CPB;
		default : PRDATA <= 0;
		endcase
	end
	if(TXE) begin
		status[7] 	<= 1'b0;
        busy        <= 1'b1;
	end
	if (w_RX_DV) begin
	       status[5] 	<= 1'b1;
	end
	if (w_Tx_Done) begin
	       busy		<= 1'b0;
	end
end

  UART_RX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst
    (
     .i_Rst_L(PRESETn),
	 .i_Clock(PCLK),
     .i_RX_Serial(w_UART_Line),
     .o_RX_DV(w_RX_DV),
     .o_RX_Byte(w_RX_Byte)
     );
	 
  UART_TX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst
    (
     .i_Rst_L(PRESETn),
     .i_Clock(PCLK),
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
