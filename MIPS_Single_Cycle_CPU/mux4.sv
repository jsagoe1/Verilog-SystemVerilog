module mux4 (
  output logic 		[31:0]		DOUT,
  input uwire		[31:0]		DI_0,
  input uwire		[31:0]		DI_1,
  input uwire		[31:0]		DI_2,
  input uwire		[31:0]		DI_3,
  input uwire 		[1:0]		SEL);
  
  always_comb begin
    case (SEL)
      0: DOUT = DI_0;
      1: DOUT = DI_1;
      2: DOUT = DI_2;
      3: DOUT = DI_3;
    endcase
  end
  
endmodule
