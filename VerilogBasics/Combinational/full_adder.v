
// Code your design here
module full_adder
  (
    sum,
   	carry,
   	a,
   	b,
   	cin
  	);
  
  input a;
  input b;
  input cin;
  output sum;
  output carry;
  
  always @(a, b, cin)
    begin
      sum = a ^ b ^ c;
      carry = (a&b) | (cin & (a^b))
    end
  
endmodule


