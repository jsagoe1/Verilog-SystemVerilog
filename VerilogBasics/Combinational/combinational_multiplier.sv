module mult_comb #(int n = 16)
  (output logic [(2*n)-1:0] prod,
   input uwire [n-1:0] cand, plier);
    
  always @ (cand, plier)
    begin
      prod = 0;
      for (int i = 0; i<n; i++)
          if (plier[i])
            prod = prod + (cand << i);
    end
  
endmodule
