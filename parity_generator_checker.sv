// parity generator
// generates parity bit for an input

module parity_gen_and_check #(int n=8)(output logic

module parity_gen #(int n=4)(output logic [n:0] d_out,
                             input uwire [n-1:0] d_in,
                             input uwire p_type);
  
  // generates p_bit 1 or 0 depending on parity type
  // parity type, p_type: 0-->odd, 1-->even
  
  logic count, p_bit;
  
  always_comb begin
    count = 1;
    for (int i=0; i<n; i++) begin
      if (d_in[i])
        count = ~count;
    end
    if (p_type)
      p_bit = ~count;
    else
      p_bit = count;
  end
  
  assign d_out = {p_bit, d_in};
  
endmodule


module parity_check #(int n=5)(output logic err,
                               output logic [n-2:0] d_out,
                               input logic [n-1:0] d_in,
                               input logic p_type);
  
  logic count;
  
  always_comb begin
    count = 1;
    for (int i=0; i<n-1; i++) begin
      if (d_in[i])
        count = ~count;
    end
    if (p_type)
      err = count;
    else
      err = ~count;
  end
  
  assign d_out = d_in[n-2:0];
  
  
endmodule
  
  
  
  
  
  
  
  
  
  
  
  
