module mux2 (							// 2 input MUX
  output logic 		[31:0]		DOUT,
  input uwire		[31:0]		DI_0,
  input uwire		[31:0]		DI_1,
  input uwire 					SEL);
  
  assign DOUT = SEL? DI_1 : DI_0;
endmodule
