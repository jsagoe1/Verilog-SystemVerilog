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

//testbench

module test_mult ();
  
  localparam int n = 4;
  
  logic [(2*n)-1:0] prod;
  logic [n-1:0] cand, plier;
  
  mult_comb #(n) m1 (prod, cand, plier);
  
  initial begin
    plier = 0; cand  = 0;
    #30 $finish;
  end
  
  initial begin
    #3 plier = 4'd5; cand = 4'd6;
    #3 plier = 4'd7; cand = 4'd9;
    #3 plier = 4'd8; cand = 4'd4;
    #3 plier = 4'd3; cand = 4'd8;
  end
  
  initial begin 
    $display (" plier plierhex cand candhex prod       prodhex");
    $monitor (" %b    %h      %b    %h    %b   %d", plier,plier,cand,cand,prod,prod);
  end
 
  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1);
    end
  
endmodule
