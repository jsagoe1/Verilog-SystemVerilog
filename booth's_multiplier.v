module booth_multiplier #(int w = 8)
  (output logic signed 	[2*w-1:0]	prod,
   output logic 					ready,
   input uwire signed 	[w-1:0] 	mc, mp,
   input uwire 						clk, start);
  
  logic [w-1:0] 					A, Q, M;
  logic 							Q_1;
  logic [3:0] 						count;
  
  logic [w-1:0] 					sum, difference;
  
  always_ff @(posedge clk) begin
    if (start) begin
      A <= {w{1'b0}};
      M <= mc;
      Q <= mp;
      Q_1 <= 1'b0;
      count <= 4'b0;
    end
    
    else begin
      case ({Q[0], Q_1})
        2'b0_1 : {A, Q, Q_1} <= {sum[w-1], sum, Q};
        2'b1_0 : {A, Q, Q_1} <= {difference[w-1], difference, Q};
        default: {A, Q, Q_1} <= {A[w-1], A, Q};
      endcase
      count <= count + 1'b1;
    end
  end
  
  alu adder (sum, A, M, 1'b0);
  alu subtracter (difference, A, ~M, 1'b1);
  
  assign prod = ready? {A, Q} : 0;
  assign ready = (count == w);
  
endmodule


//The following is an alu.
//It is an adder, but capable of subtraction:
//Recall that subtraction means adding the two's complement--
//a - b = a + (-b) = a + (inverted b + 1)
//The 1 will be coming in as cin (carry-in)
module alu #(int w = 4) 
  (output logic [w-1:0] out,
   input uwire [w-1:0]  a, b,
   input uwire cin);
  
  assign out = a + b + cin;
endmodule



module test;
  localparam int w = 4;
  
  logic signed [w-1:0] mc, mp;
  logic signed [2*w-1:0]		prod;
  logic 						clock, start, ready;
  
  booth_multiplier #(w) b0 (.prod(prod),
                            .ready(ready),
                            .mc(mc),
                            .mp(mp),
                            .clk(clock),
                            .start(start));
  
  initial begin
    clock = 0;
    start = 0;
    mc = -7;
    mp = 3;
    # 5 start = 1;
    # 5 start = 0;
    #50 $finish;
  end
  
  always
    #2 clock = ~clock;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  
endmodule
  
  
