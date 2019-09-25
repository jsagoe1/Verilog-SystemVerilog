//n-bit simple microprocessor (performs load, move, add and sub) 
//inputs:	clock, w, 
//			6-bit function input F consisting of 2bits instruction, 2bit operand1, 2bit operand2
//			n-bit data input, ext_data
//outputs:	done,
//			n-bit bus_data (data present on the internal bus)


module cpu_n #(int n = 4)
  (output wire [n-1:0] bus_data, //bus_data declared as wire to be driven by multiple drivers
   output logic [n:0] aluout,    //output from alu
   output logic done, overflow,  //done signal and overflow signal in case sum overflows
   input uwire [n-1:0] data,     //input data to bus
   input uwire reset, w, clock,
   input uwire [1:0] F,Rx,Ry,    //different components of function
   
   //below not going to be part of output pins in design. 
   //Just there to monitor internal values
   output logic [n-1:0] Amon,Gmon,
   output logic Goutmon, clearmon, Ainmon, Ginmon,
   output logic [1:0] countmon,
   output logic [1:6]  Funcmon, 
   output logic [0:3] Rinmon, Routmon, Tmon, Imon, Xmon, Ymon,
   output logic Externmon);
  // up to this point 
  
  
  logic [0:3] Rin, Rout;   //data registers input enable and output enable to data bus
  logic [n:0] sum;       // output of adder/subtractor unit
  logic clear, AddSub, Extern, Ain, Gin, Gout, FRin; //control signals
  logic [1:0] count;   //counter output 2bits
  logic [0:3] T, I, Xreg, Y;   //decoder outputs
  logic [n-1:0] R0,  R1, R2, R3, A, G;  //register outputs
  logic [1:6] Func, Func_Reg;   //function input and function reg output
  
  //below can be delated once they their declarations have been removed
  //from above
  assign Externmon = Extern;
  assign Gmon = G;
  assign Ainmon = Ain;
  assign Ginmon = Gin;
  assign Amon = A;
  assign Goutmon = Gout; 
  assign Rinmon = Rin;
  assign Routmon = Rout;
  assign Tmon = T;
  assign Imon = I;
  assign Xmon = Xreg;
  assign Ymon = Y;
  assign clearmon = clear;
  assign countmon  = count;
  assign Funcmon = Func_Reg;
  //up to this point
      
  upcounter_n #(2) counter(count, clear, clock);  //2bit counter connected to 2to4 decoder
  decnto2n #(2) decT (T, count, 1'b1);
   
  assign clear = reset | done | (~w & T[0]);  // clear for counter
  assign Func = {F, Rx, Ry};				   // 6 bits of function internal register; see heading for details
  assign FRin = w & T[0];                     // enable for function register
   
  reg_n #(6) functionreg (Func_Reg, Func, FRin, clock); //function register connected to three 2to4decoders
  decnto2n #(2) decI (I, Func_Reg[1:2], 1'b1);			//instrunction decoder
  decnto2n #(2) decX (Xreg, Func_Reg[3:4], 1'b1);		//first operand select decoder
  decnto2n #(2) decY (Y, Func_Reg[5:6], 1'b1);			//second operand select decoder
   
  assign Extern = I[0] & T[1];
  assign done = ((I[0] | I[1]) & T[1]) | ((I[2] | I[3]) & T[3]);
  assign Ain = (I[2] | I[3]) & T[1];
  assign Gin = (I[2] | I[3]) & T[2];
  assign Gout = (I[2] | I[3]) & T[3];
  assign AddSub = I[3]; 
  
   
   //Reg Enable Control below
  always @(I, T, Xreg, Y) 
    begin
     for (int k = 0; k < 4; k = k+1)
       begin
         Rin[k] = ((I[0] | I[1]) & T[1] & Xreg[k]) | ((I[2] | I[3]) & T[3] & Xreg[k]);
         Rout[k] = (I[1] & T[1] & Y[k]) | ((I[2] | I[3]) & ((T[1] & Xreg[k]) | (T[2] & Y[k])));
       end
    end

   //instantiate registers R0 to R3
  reg_n #(n) reg0 (R0, bus_data, Rin[0], clock);
  reg_n #(n) reg1 (R1, bus_data, Rin[1], clock);
  reg_n #(n) reg2 (R2, bus_data, Rin[2], clock);
  reg_n #(n) reg3 (R3, bus_data, Rin[3], clock);
   
  //Adder/Subtractor Registers
  reg_n #(n) regA (A, bus_data, Ain, clock);  //for storing first input
  reg_n #(n) regG (G, sum[n-1:0], Gin, clock);//for storing output from adder/subtractor unit
   
   //tristate buffers   
  tri_n #(n) tri_ext (bus_data, data, Extern);
  tri_n #(n) tri_0 (bus_data, R0, Rout[0]);
  tri_n #(n) tri_1 (bus_data, R1, Rout[1]);
  tri_n #(n) tri_2 (bus_data, R2, Rout[2]);
  tri_n #(n) tri_3 (bus_data, R3, Rout[3]);
  tri_n #(n) triG (bus_data, G, Gout);
   
   //ALU design
   //takes in two inputs
   //one input from reg A and the other from data_bus
   always @ (AddSub, A, bus_data) 
     begin
       sum = AddSub ? ({1'b0, A} - {1'b0,bus_data}) : ({1'b0, A} + {1'b0,bus_data});
     end
  
  assign overflow = Gout? sum[n]:0; //same as below
  assign aluout = Gout? sum:0;      //only displayed when alu output register output buffer is enabled
  
endmodule
   
   

module upcounter_n #(int n = 2)   //counter for timing the steps of operation
  (output logic [n-1:0] q,
   input uwire clear, clock);
  
  always @(posedge clock) 
    begin 
      if (clear)
        q<=0;
      else
        q++;
    end
endmodule


module decnto2n #(int n = 2)    // decoder for decoding function and time steps
  (output logic [0:((2**n)-1)] q,
   input uwire [n-1:0] x,
   input en);
  
  always @(x, en) 
    begin
      for (int i  = 0; i < (2**n); i++) begin
        if (x == i && en==1)
          q[i] = 1;
        else
            q[i] = 0;
      end
    end
endmodule


module reg_n #(int n = 4)   //n-bit register
  (output logic [n-1:0] q,
   input logic [n-1:0] data_in,
   input logic en, clock);
   
  always @(posedge clock)
    if (en)
       q <= data_in;
  
endmodule

module tri_n #(int n = 2)    //n-bit tristate buffer
  (output logic [n-1:0] data_out,
   input uwire [n-1:0] data_in,
   input uwire en);
  
  assign data_out = (en==1)? data_in:'bz;
  
endmodule
