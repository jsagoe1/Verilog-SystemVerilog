//parameterized barrel or logarithmic right shifter


module barrel_shiftern #(int n=4, iter=$clog2(n))(output logic [n-1:0] d_out,   // iter is number of  n-bit 2-input muxen needed
                                                  output logic [n-1:0] outmonitor[0:iter],
                                                  input uwire [n-1:0] d_in,
                                                  input uwire [$clog2(n)-1:0] sh_amt);
  
  logic [n-1:0] out[0:iter];                      // n-bit out[0], out[1], .....up to out[iter+1] 
  
  for(genvar i=1; i<(iter+1); i++) begin          // using genvar to instantiate 2-input muxen
    
    localparam int catw = 2**(i-1);								// no of 0 bits eg if i = 3, catw=4 ===> 2'b0000
    
    //cat_left and _right to be concatenated in generate block
    logic [catw-1:0] cat_left;
    logic [n-1:catw] cat_right;
  
    assign cat_right = out[i-1][n-1:catw];        // right of concatenation  eg. if (i = 3, n=16), cat_right = out[15:4]
    assign cat_left  = {catw{1'b0}};              // left of concatenation eg. if (i=3, n=16), cat_left = 4'b0 = 0000
    
    mux2n #(n) m0(.d_out(out[i]),
                  .a0(out[i-1]),
                  .a1({cat_left, cat_right}),  		// concatenation (eg. if (i=3 and n=16) == {2'b0000, out[2][15:4]}
                  .sel(sh_amt[i-1]));
  end
  
  assign outmonitor = out;
  assign out[0] = d_in;								//first mux to modue input
  assign d_out = out[iter];							//last mux to module output
    
endmodule


module mux2n #(int n=4)(output logic [n-1:0] d_out,
                       input uwire [n-1:0] a0, a1,
                       input uwire sel);
  
  assign d_out = sel? a1 : a0;
  
endmodule
