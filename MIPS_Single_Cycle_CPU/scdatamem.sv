//single cycle data memory

module scdatamem (							    // data memory, ram
  output logic [31:0] 		dataout,			// dataout from memory
  input uwire 				clk,
  input uwire 				we, 				//write enable
  input uwire [31:0]		datain,				// datain to memory
  input uwire [31:0] 		addr);				// ram address
  
  logic [31:0] ram [0:31]; 						// ram cells: 32 words * 32 bits
  
  assign dataout = ram[addr[6:2]]; 				// use word address to read ram
  
  always_ff @(posedge clk)
    if (we)
      ram[addr[6:2]] = datain; 					// use word address to write ram
  
  initial begin // initialize memory
    for (int i = 0; i < 32; i = i + 1)
      ram[i] = 0;
        
  // ram[word_addr] = data 						// (byte_addr) item in data array
    ram[5'h14] = 32'h000000a3; 					// (50) data[0] 0 + A3 = A3
    ram[5'h15] = 32'h00000027; 					// (54) data[1] a3 + 27 = ca
    ram[5'h16] = 32'h00000079; 					// (58) data[2] ca + 79 = 143
    ram[5'h17] = 32'h00000115; 					// (5c) data[3] 143 + 115 = 258
  // ram[5’h18] should be 0x00000258, the sum stored by sw instruction
  end
endmodule
