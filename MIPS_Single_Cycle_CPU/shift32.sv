//32 bit shifter module

module shift32 (						// shifter
  output logic 		[31:0]		RES,
  input uwire		[31:0]		D,
  input uwire		[4:0]		SHAMT,
  input uwire					RIGHT,
  input uwire					ARITH);
  
  always_comb begin
    case ({RIGHT, ARITH})
      2'b00:	RES = D << SHAMT;		//shift left
      2'b10:	RES = D >> SHAMT;		// shift right logical
      2'b11:	RES = D >>> SHAMT;		// shift right arith
      default: RES = D << SHAMT;		// shift left   
    endcase  
  end
endmodule
