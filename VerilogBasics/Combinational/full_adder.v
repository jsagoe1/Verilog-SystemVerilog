
module full_adder(
  output logic sum, carry,
  input uwire a, b, cin);
  
  always @(a, b, cin)
    begin
      sum = a ^ b ^ c;
      carry = (a&b) | (cin & (a^b))
    end
  
endmodule


// full adder test bench
//
module test_fa ();
  logic a, b, cin;
  logic carry, sum;
  
  full_adder f1(a, b, cin, sum, carry);
  
  initial begin
    a = 0;
    b = 0;
    cin = 0;
    #100 $stop;
  end
  
  always begin
    #5; a = $random; b = $random;
  end
  
  initial 
    begin
      $display ("    a/    b/   cin/   sum/   carry/");
      $monitor ("%2d, %d/    %d/     %d/     %d/   %d/",$time, a, b, cin, sum, carry);
    end
  
endmodule
