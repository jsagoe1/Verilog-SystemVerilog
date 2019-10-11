module mux_n #(int w = 8, n = 4)
  (output logic [w-1:0] d_out,
   input uwire [w-1:0] d_in [0: n-1],
   input uwire [$clog2(n)-1:0] sel);
  
  assign d_out = d_in[sel];
  
endmodule
