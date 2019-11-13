module singleCycleComp32 (										// single cycle computer 
  output logic [31:0] 	pc,										//program counter
  output logic [31:0] 	inst,									// instruction from inst reg
  output logic [31:0] 	aluout,										// output of alu
  output logic [31:0] 	memout,										// data memory output
  input uwire		  	clk, clrn);									// clock and reset
  
  logic [31:0] 			data;										// data to data memmory
  logic 				wmem;										// write enable for data memory
  
  sccpu cpu (.clk		(clk),										//cpu
             .clrn		(clrn),
             .inst		(inst), 
             .pc		(pc),
             .wmem		(wmem),
             .alu		(aluout),
             .data		(data),
             .mem		(memout));
  
  scinstmem imem (													// instruction memory
    		.a			(pc),
    		.inst		(inst));
  
  scdatamem dmem (													// data memory
            .clk		(clk),
            .dataout	(memout),
            .datain		(data),
            .addr		(aluout),
            .we			(wmem));
  
endmodule
