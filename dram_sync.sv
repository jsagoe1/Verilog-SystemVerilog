module dram_seq #(int m = 8, int n = 1024)
  (output logic [m-1:0] 		  data_out,
   input logic [$clog2(n)-1:0] 	addr,		//2^k = n --> k = $clog2(n)
   input logic 					      clk,
   input logic 					      re);
  
  //memory array
  logic [m-1:0] mem[n-1:0];
  
  always_ff @(posedge clk)
    if (re)
      data_out = mem[addr];
  
endmodule
