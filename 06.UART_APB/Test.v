task Test;
begin
    @(posedge PRESETn);
    @(posedge PCLK);
    @(posedge PCLK);
    // APB_WRITE(32'h0, 32'h1111); 
    APB_WRITE(32'h4, 32'h55);       // tdr 0x55 8bit 
    APB_WRITE(32'h0, 32'h1);        // enable
    APB_WRITE(32'h8, 32'h3333);     // meaning nothing
    // APB_WRITE(32'hc, 32'h4444); 
    @(posedge irqreq);
    APB_READ(32'h0, tmp_r);
    $display("status reg \t %08x", tmp_r);
    APB_READ(32'h4, tmp_r);
    $display("TDR reg \t %08x", tmp_r);
    APB_READ(32'h8, tmp_r);
    $display("RDR reg \t %08x", tmp_r);
    APB_READ(32'h0, tmp_r);
    $display("status reg \t %08x", tmp_r);
    
    APB_WRITE(32'h4, 32'haa);       // tdr 0xaa 8bit 
    @(posedge irqreq);
    APB_READ(32'h0, tmp_r);
    $display("status reg \t %08x", tmp_r);
    APB_READ(32'h4, tmp_r);
    $display("TDR reg \t %08x", tmp_r);
    APB_READ(32'h8, tmp_r);
    $display("RDR reg \t %08x", tmp_r);
    APB_READ(32'h0, tmp_r);
    $display("status reg \t %08x", tmp_r);
    // APB_READ(32'hc, tmp_r);
    // $display("CPB reg \t %08x", tmp_r);
    #10ns;
end
endtask

task APB_WRITE(input [31:00] addr, input [31:00] wdata);
begin
    @(posedge PCLK);
    PADDR   <= addr;
    PWDATA  <= wdata;
    PSEL    <= 1;
    PWRITE  <= 1;
    @(posedge PCLK);
    PENABLE <= 1;
    while(!PREADY)       @(posedge PCLK);
    @(posedge PCLK);
    PSEL    <= 0;
    PENABLE <= 0;
    end
endtask

task APB_READ(input [31:00] addr, output [31:00] rdata);
begin
    @(posedge PCLK);
    PADDR   <= addr;
    PSEL    <= 1;
    PWRITE  <= 0;
    @(posedge PCLK);
    PENABLE <= 1;
    while(!PREADY)        @(posedge PCLK);
    @(posedge PCLK);    
    rdata   = PRDATA;
    PSEL    <= 0;
    PENABLE <= 0;
    end
endtask