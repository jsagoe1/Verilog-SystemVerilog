//32-bits MIPS ALU DESIGN 
/*
Perform the following operations
------------------------------------------------------------
1. ADD (addition) for instructions of add, addi, lw, and sw;
2. SUB (subtraction) for instructions of sub, beq, and bne;
3. AND (bitwise logical and) for instructions of and and andi;
4. OR  (bitwise logical or) for instructions of or and ori;
5. XOR (bitwise logical exclusive or) for instructions of xor and xori;
6. LUI (load upper immediate) for lui instruction;
7. SLL (shift left logical) for sll instruction;
8. SRL (shift right logical) for srl instruction;
9. SRA (shift right arithmetic) for sra instruction;

ALU_CONTROL OPCODE
-------------------
ALU[3:0]		OPERATION
-------------------------
x000 			ADD
x100 			SUB
x001 			AND
x101 			OR
x010 			XOR
x110 			LUI
0011 			SLL
0111 			SRL
1111 			SRA
*/

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



module addsub32 (						// adder subtractor
  output logic 		[31:0] 		RES,
  input uwire		[31:0]		A,
  input uwire		[31:0]		B,
  input uwire 					SUB);
  
  assign RES = SUB? (A-B) : (A+B);
  
endmodule

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

module mux2 (							// 2 input MUX
  output logic 		[31:0]		DOUT,
  input uwire		[31:0]		DI_0,
  input uwire		[31:0]		DI_1,
  input uwire 					SEL);
  
  assign DOUT = SEL? DI_1 : DI_0;
endmodule

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
