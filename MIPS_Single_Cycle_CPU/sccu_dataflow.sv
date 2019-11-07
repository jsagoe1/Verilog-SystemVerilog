//singlecycle control unit data flow

module sccu_dataflow ( 						// control unit
  output logic [3:0] 	aluc, 				// alu operation control
  output logic [1:0] 	pcsrc, 				// select pc source
  output logic 			wreg, 				// write regfile
  output logic 			regrt, 				// dest reg number is rt
  output logic 			m2reg, 				// instruction is an lw
  output logic 			shift, 				// instruction is a shift
  output logic 			aluimm, 			// alu input b is an i32
  output logic 			jal, 				// instruction is a jal
  output logic 			sext, 				// is sign extension
  output logic 			wmem, 				// write data memory
  input logic [5:0] 	op, func,			// op, func
  input logic 			z); 				// alu zero tag
  
  // decode instructions
  //-----------------------------------------------------------------
  
  logic rtype; 
  logic i_add; 
  logic i_sub; 
  logic i_and; 
  logic i_or;  
  logic i_xor; 
  logic i_sll; 
  logic i_srl; 
  logic i_sra; 
  logic i_jr;  
  logic i_addi;
			   
  logic i_andi;
  logic i_ori; 
  logic i_xori;
  logic i_lw;  
  logic i_sw;  
  logic i_beq; 
  logic i_bne; 
  logic i_lui; 
  logic i_j;   
  logic i_jal;  
  
  assign rtype = (op == 0); 														// r format
  assign i_add = rtype & func[5] & (~func[4]) & (~func[3]) & (~func[2]) & (~func[1]) & (~func[0]);
  assign i_sub = rtype & func[5] & (~func[4]) & (~func[3]) & (~func[2]) & func[1] & (~func[0]);
  assign i_and = rtype & func[5] & (~func[4]) & (~func[3]) & (func[2]) & (~func[1]) & (~func[0]);
  assign i_or = rtype & func[5] & (~func[4]) & (~func[3]) & func[2] & (~func[1]) & func[0];
  assign i_xor = rtype & func[5]& (~func[4]) & (~func[3]) & func[2]& func[1] & (~func[0]);
  assign i_sll = rtype & (~func[5]) & (~func[4]) & (~func[3]) & (~func[2]) &(~func[1]) &(~func[0]);
  assign i_srl = rtype & (~func[5]) & (~func[4]) & (~func[3])& (~func[2]) & func[1] &(~func[0]);
  assign i_sra = rtype & (~func[5]) & (~func[4])& (~func[3]) & (~func[2]) & func[1] & func[0];
  assign i_jr = rtype & (~func[5]) & (~func[4]) & func[3] & (~func[2]) & (~func[1]) & (~func[0]);
  assign i_addi = (~op[5]) & (~op[4]) & op[3] & (~op[2]) & (~op[1]) & (~op[0]); // i format
  
  assign i_andi = (~op[5]) & (~op[4]) & op[3] & op[2] &(~op[1]) & (~op[0]);
  assign i_ori = (~op[5]) & (~op[4]) & op[3] & op[2] & (~op[1]) & op[0];
  assign i_xori = (~op[5]) & (~op[4]) & op[3]& op[2] & op[1] & (~op[0]);
  assign i_lw = op[5]&(~op[4]) & (~op[3]) & (~op[2]) & op[1] & op[0];
  assign i_sw = op[5] & (~op[4]) & op[3] & (~op[2]) & op[1]& op[0];
  assign i_beq = (~op[5]) & (~op[4]) & (~op[3]) & op[2] & (~op[1]) & (~op[0]);
  assign i_bne = (~op[5]) & (~op[4]) & (~op[3]) & op[2] & (~op[1]) & op[0];
  assign i_lui = (~op[5]) & (~op[4]) & op[3] & op[2] & op[1] & op[0];
  assign i_j = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & op[1] & (~op[0]); 							// j format
  assign i_jal = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & op[1]& op[0];
  
  // generate control signals
  //----------------------------------------------------------------------
  
  assign regrt = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui;
  assign jal = i_jal;
  assign m2reg = i_lw;
  assign wmem = i_sw;
  assign aluc[3] = i_sra; // refer to alu.v for aluc
  assign aluc[2] = i_sub | i_or | i_srl | i_sra | i_ori | i_lui;
  assign aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori | i_beq |  i_bne | i_lui;
  assign aluc[0] = i_and | i_or | i_sll | i_srl | i_sra | i_andi | i_ori;
  assign shift = i_sll | i_srl | i_sra;
  assign aluimm = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_sw;
  assign sext = i_addi | i_lw | i_sw | i_beq | i_bne;
  assign pcsrc[1]= i_jr | i_j | i_jal;
  assign pcsrc[0]= i_beq & z | i_bne &~z | i_j | i_jal;
  assign wreg = i_add | i_sub | i_and | i_or | i_xor | i_sll |  i_srl | i_sra | i_addi | i_andi | i_ori | i_xori |  i_lw | i_lui | i_jal;
endmodule
