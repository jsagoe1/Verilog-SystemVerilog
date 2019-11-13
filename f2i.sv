module f2i (
  output logic	[31:0]	d,											//integer
  output logic			p_lost,										//precision lost
  output logic			denorm,										//denormalized
  output logic			invalid,									//inf, NaN, out of range
  input uwire	[31:0]	a);											//floating point repr
  
  //internal signals
  logic					hidden_bit = |(a[30:23]); 					//hidden_bit
  logic					frac_is_not_0 = |(a[22:0]); 				//if fractional part is 0 or not
  
  assign				denorm = ~hidden_bit & frac_is_not_0;   	//if denormalized
  
  logic 				is_zero = ~hidden_bit & ~frac_is_not_0;   	//if zero
  logic					sign = a[31];								//sign bit
  logic			[8:0]	shift_right_bits = 9'd158 - {1'b0, a[30:23]};	//127 + 31
  logic 		[55:0]	frac0 = {hidden_bit, a[22:0], 32'h0};   	//32+24 = 56 bits
  logic			[55:0]  f_abs = ($signed(shift_right_bits) > 9'd32)? 
  								(frac0 >> 6'd32) : (frac0 >> shift_right_bits);
  logic					lost_bits = |f_abs[23:0];					//if !=0, p_lost = 1
  logic			[31:0]	int32 = sign? 
  								~f_abs[55:24] + 32'd1 : f_abs[55:24];
  always @ * begin
    if (denorm) begin												//denormalized
      p_lost = 1;
      invalid = 0;
      d = 32'd0;
    end
    else begin														//not denormalized
      if (shift_right_bits[8]) begin								//too big
        p_lost = 0;
        invalid = 1;
        d = 32'h80000000;
      end
      else begin													//shift_right
        if (shift_right_bits[7:0] > 8'h1f) begin					//too small
          if (is_zero) 	p_lost = 0;
          else 			p_lost = 1;
          invalid = 0;
          d = 32'h00000000;
        end
        else begin
          if (sign != int32[31]) begin 								//out of range
            p_lost = 0;
            invalid = 1;
            d = 32'h80000000;
          end
          else begin												//normal case
            if (lost_bits)	p_lost = 1;
            else			p_lost = 0;
            invalid = 0;
            d = int32;
          end
        end
      end
    end
  end 
endmodule
