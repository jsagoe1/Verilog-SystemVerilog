//32 bit adder/subtractor

module addsub32 (						// adder subtractor
  output logic 		[31:0] 		RES,
  input uwire		[31:0]		A,
  input uwire		[31:0]		B,
  input uwire 					SUB);
  
  assign RES = SUB? (A-B) : (A+B);
  
endmodule
