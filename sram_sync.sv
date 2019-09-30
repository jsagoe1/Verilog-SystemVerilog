/* n x M-bit (1K by 8 in this case) sram module
with synchronuos write and asynchronuos read
with write_enable,
	read_enable,
    data_in,
    data_out,
    address_input,
*/

module sram_seq#(int m = 8, int n = 1024)
  (output logic [m-1:0] 		data_out,
   input logic [m-1:0] 			data_in,
   input logic [$clog2(n)-1:0] 	addr,		//2^k = n --> k = $clog2(n)
   input logic clk,
   input logic we,
   input logic re);
  
  //memory array
  logic [m-1:0] mem[n-1:0];
  
  
  always_ff @(posedge clk) 				//synchronuos write
    begin
      if (we)
        mem[addr] <= data_in;
    end
  
  always_comb							// asynchronuos read
    if(re)
      data_out = mem[addr];

endmodule


   
    
