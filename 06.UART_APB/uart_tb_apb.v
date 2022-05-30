//////////////////////////////////////////////////////////////////////
// Author:      Jasper Min
//////////////////////////////////////////////////////////////////////
// Description: This file designed for UART APB Testbench.  
//              
//              
// 
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module uart_tb_apb;

reg   PCLK;
reg   PRESETn;
reg   [31:00] PADDR;
reg   PWRITE;
reg   PSEL;
reg   PENABLE;
reg   [31:00] PWDATA;
wire  [31:00] PRDATA;
wire  PREADY;
wire  irqreq;

reg [31:00] tmp_r;
reg [31:00] tmp_w = 'hffff;

`include "Test.v"

initial begin
  PRESETn = 0;
  PCLK = 0; 
  #10ns;
  PRESETn = 1;
  forever begin
    PCLK = ~PCLK; #5ns;
  end
end

initial begin
  $display("TEST CALL");
  Test;
  $finish();
end

UART_REG duv
(
	  .PCLK(PCLK),
    .PRESETn(PRESETn),
	  .PADDR(PADDR),
	  .PWRITE(PWRITE),
	  .PSEL(PSEL),
	  .PENABLE(PENABLE),
	  .PWDATA(PWDATA),
	  .PRDATA(PRDATA),
	  .PREADY(PREADY),
    .irqreq(irqreq)
 );

  
initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule