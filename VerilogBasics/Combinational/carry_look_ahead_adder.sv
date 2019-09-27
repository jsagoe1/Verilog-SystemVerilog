// n-bit carry-look-ahead adder

module CLA_adder #(int n = 4)(output logic [n-1:0] sum,
                        output logic cout,
                        input uwire [n-1:0] a, b,
                        input logic cin);
  
  logic [n-1:-1] carry;
  logic [n-1:0] dummy_carry;
  logic [n-1:0] p;
  logic [n-1:0]g;
  
  assign carry[-1] = cin;
  assign cout = carry[n-1];

  for (genvar i=0; i<n; i++)
    begin
      //instantiate full_adder modules
      full_adder f0(sum[i], dummy_carry[i], a[i], b[i], carry[i-1]); //use dummy carry to keep FA carry_out 
      
  	  //carry generators and propagators
      assign g[i] = a[i] & b[i];
      assign p[i] = a[i] ^ b[i];
      assign carry[i] = g[i] + (p[i] & carry[i-1]);
    end
  
endmodule
  
//full adder module
module full_adder  (output logic sum,
   					output logic carry_out,
   					input uwire a, b, carry_in);
  
  assign {carry_out, sum} = a + b + carry_in;
endmodule
  
  
  
  
  // n-bit carry-look-ahead adder test_bench
module CLA_adder_test #(int n=4);   // you can change the n paramter here for other bits
  logic [n-1:0] sum;
  logic cout;
  logic [n-1:0] a, b;
  logic cin;
  logic [n:0] correct;
  
  assign correct = a + b;  //just to track correct output 
    
  CLA_adder #(n) c0(sum, cout, a, b, cin);
  
  logic [n:0] out;
  assign out = {cout, sum};
  
  initial begin
    a = 0; b = 0; cin = 0;
    #100 $finish;
  end
  
  always begin
    #20 a = $random%n; b = $random%n;
  end
  
  initial begin
    $display("  \\a               \\b              \\out         \\correct");
    $monitor("%b(%d)\t%b(%d)\t%b(%d)\t%b(%d)", a, a, b, b, out, out, correct, correct);
  end
  
endmodule
  
