module test;
  
  logic clk, clrn;
  logic [1:0] pcsrcmon;
  logic [31:0] inst, pc, memout, alu;
  
  singleCycleComp32 comp (.pc		(pc),
                          .inst		(inst),
                          .aluout	(alu), 
                          .memout	(memout),
                          .clk		(clk),
                          .clrn		(clrn));
  
  always 
    #5 clk = ~clk;
  
  initial begin
    clk = 0;
    clrn = 0;
    #6 clrn = 1;
    
    #60 $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
endmodule
