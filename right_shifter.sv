module right_shifter_behavorial #(n = 8, amt = 3)
   (output logic [n-1:0] d_out,
    input uwire [n-1:0] d_in);
  
   assign d_out = d_in >> amt;
endmodule

module right_shifter_iter #(n = 8, amt = 3)
   (output logic [n-1:0] d_out,
    input uwire [n-1:0] d_in);
  
  always_comb
    begin
      for (int i = 0; i < (n-amt); i++)
        d_out[i] = d_in[i+amt];
      
      d_out[n-1:(n-amt)] = 0;
    end
endmodule
