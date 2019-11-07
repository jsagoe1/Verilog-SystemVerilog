//32 bit alu unit

module alu32 (
  output logic 		[31:0]		RES,								//result
  output logic					Z,									//zero flag
  input uwire		[31:0]		A,									//operand A
  input	uwire		[31:0]		B,									//operand B
  input uwire		[3:0]		ALUC);								//opcode control
  
  logic 			[31:0]		AandB, AorB, AxorB, B_lui;
  logic				[31:0]		ANDorOR, XORorLUI, SHOUT, ADDorSUB;
  
  assign AandB = A & B;
  assign AorB  = A | B;
  assign AxorB = A ^ B;
  assign B_lui = {B[15:0], 16'd0};
  
  assign Z = (RES == 0);
  
  mux2 andormux  (.DOUT			(ANDorOR),
                  .DI_0			(AandB),
                  .DI_1			(AorB),
                  .SEL			(ALUC[2]));
  
  mux2 xorluimux (.DOUT			(XORorLUI),
                  .DI_0			(AxorB),
                  .DI_1			(B_lui),
                  .SEL			(ALUC[2]));
  
  shift32 shifter(.RES			(SHOUT),
                  .D			(B),
                  .SHAMT		(A[4:0]),
                  .RIGHT		(ALUC[2]),
                  .ARITH		(ALUC[3]));
  
  addsub32 adsub (.RES			(ADDorSUB),
                  .A			(A),
                  .B			(B),
                  .SUB			(ALUC[2]));
  
  mux4 opcodemux (.DOUT			(RES),
                  .DI_0			(ADDorSUB),
                  .DI_1			(ANDorOR),
                  .DI_2			(XORorLUI),
                  .DI_3			(SHOUT),
                  .SEL			(ALUC[1:0]));
    
endmodule
