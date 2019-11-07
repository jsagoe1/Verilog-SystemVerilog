//single cycle cpu

module sccpu (
  output logic [31:0] 	pc, 		// program counter
  output logic [31:0] 	alu, 		// alu output
  output logic [31:0] 	data, 		// data to data memory
  output logic 			wmem, 		// write data memory
  input uwire [31:0] 	inst, 		// inst from inst memory
  input uwire [31:0] 	mem, 		// data from data memory
  input uwire 		clk,clrn); 		// clock and reset
  
  // instruction fields
  //------------------------------------
 
  
  logic [5:0] op; 			// op
  logic [4:0] rs; 			// rs
  logic [4:0] rt; 			// rt
  logic [4:0] rd; 			// rd
  logic [5:0] func; 			// func
  logic [15:0] imm; 			// immediate
  logic [25:0] addr; 			// address
  
  assign op = inst[31:26];
  assign rs = inst[25:21];
  assign rt = inst[20:16];
  assign rd = inst[15:11];
  assign func = inst[5:0];
  assign imm = inst[15:0];
  assign addr = inst[25:0];
  
  
  // control signals
  //-------------------------------------------
  
  logic [3:0] aluc; 						// alu operation control
  logic [1:0] pcsrc; 						// select pc source
  logic wreg; 								// write regfile
  logic regrt; 								// dest reg number is rt
  logic m2reg; 								// instruction is an lw
  logic shift; 								// instruction is a shift
  logic aluimm; 							// alu input b is an i32
  logic jal; 								// instruction is a jal
  logic sext; 								// is sign extension
  
  // datapath logic
  //----------------------------------------------------
  logic [31:0] p4; 							// pc+4
  logic [31:0] bpc; 						// branch target address
  logic [31:0] npc; 						// next pc
  logic [31:0] qa; 							// regfile output port a
  logic [31:0] qb; 							// regfile output port b
  logic [31:0] alua; 						// alu input a
  logic [31:0] alub; 						// alu input b
  logic [31:0] wd; 							// regfile write port data
  logic [31:0] r; 							// alu out or mem
  logic [31:0] sa ;								
  logic [15:0] s16;								
  logic [31:0] i32;								
  logic [31:0] dis;								
  logic [31:0] jpc;								
  logic [4:0] reg_dest; 					// rs or rt
  logic [4:0] wn; 							// regfile write reg #
  logic z; 									// alu, zero tag
  
  assign  sa = {27'b0,inst[10:6]}; 			// shift amount
  assign  s16 = {16{sext & inst[15]}}; 		// 16-bit signs
  assign  i32 = {s16,imm}; 					// 32-bit immediate
  assign  dis = {s16[13:0],imm,2'b00}; 		// word distance
  assign  jpc = {p4[31:28],addr,2'b00};		// jump target address
  assign wn = reg_dest | {5{jal}}; 			// regfile write reg #
  
  // control unit
  //--------------------------------------------------------
  sccu_dataflow cu (aluc, pcsrc, wreg, regrt, 
                    m2reg, shift, aluimm, jal, 
                    sext, wmem, op, func, z);
  
  // datapath
  //-------------------------------------------------------
  
  // pc register
  //-------------------------------
  always_ff @(posedge clk) begin
    if (clrn == 0) 
      pc <= 0;
    else
      pc <= npc;
  end
  
  assign p4 = pc + 4;							// next pc
  assign pbc = p4 + dis;						// branch target address
  
  mux2 alu_a (.DOUT		(alua),	 				// alu input a
              .DI_0		(qa),
              .DI_1		(sa),
              .SEL		(shift));
  
  mux2 alu_b (.DOUT		(alub),	 				// alu input b
              .DI_0		(qb),
              .DI_1		(i32),
              .SEL		(aluimm));
  
  mux2 alu_m (.DI_0		(alu),					// alu out or mem
              .DI_1		(mem),
              .SEL		(m2reg),
              .DOUT		(r)); 		
  
  mux2 link (.DI_0(r), 
             .DI_1(p4), 
             .SEL(jal), 
             .DOUT(wd)); 						// r or p4
  
  assign reg_dest = regrt? rt : rd;
  
  mux4 nextpc(.DI_0(p4), 
              .DI_1(bpc), 
              .DI_2(qa), 
              .DI_3(jpc), 
              .SEL(pcsrc), 
              .DOUT(npc)); 						// next pc
  
  regfile rf (.rna(rs), .rnb(rt), .d(wd),
              .wn(wn), .we(wreg), .clk(clk),
              .clrn(clrn), .qa(qa), .qb(qb)); 	// register file
  
  alu32 alunit (alu, z, alua, alub, aluc); 		// alu
  
  assign data = qb; 							// regfile output port b
endmodule
