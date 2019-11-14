//32	bit	floating	point	to	integer	converter
/*
special	cases:

	sign	exp		frac		output	
-----------------------------------------------

+InF:	0	all 1's		all 0's		0x7F800000
-InF:	1	all 1's		all 0's		0xFF800000
NaN:	x	all 1's		!=0		0x00000000

denormalized:	all 0's		!=0		0x00000000
zero:		all 0's		all 0's		0x00000000

*/

module	f2i_32	(
	output	logic	[31:0]	d,		//integer
	output	logic		p_lost,		//precision lost
	output	logic		denorm,		//denormalized
	output	logic		invalid,	//inf,	NaN, out of range
	input	uwire	[31:0]	a);		//floating point repr
	
	//internal signals
	wire	hidden_bit	=	|(a[30:23]);		//hidden_bit = (exp == 0)
	wire	frac_is_not_0	=	|(a[22:0]);		//if frac is 0 or not
	
	assign	denorm	=	~hidden_bit & frac_is_not_0;	//if denormalized
	
	wire	is_zero	=	~hidden_bit & ~frac_is_not_0;	//if zero
	wire	sign	=	a[31];				//sign	bit
	
	wire	[8:0]	shift_right_bits	=	9'd158	- {1'b0, a[30:23]};		//127 + 31, 9th	bit if too large
	wire	[55:0]	frac0			=	{hidden_bit,	a[22:0], 32'h0};	//32+24	= 56 bits
	wire	[55:0]	f_abs			=	($signed(shift_right_bits) > 9'd32)?	//shift
							(frac0 >> 6'd32) : (frac0 >> shift_right_bits);
							//shift right by 32 : shift right by shift amount
	
	wire		lost_bits	=	|f_abs[23:0];	//if != 0, p_lost = 1
	wire	[31:0]	int32		=	sign?		//neg or pos
						~f_abs[55:24] + 32'd1 : f_abs[55:24];
						//find	2's comp : positive
	always	@* begin
		if (denorm) begin		//if denormalized
			p_lost	=	1;
			invalid	=	0;
			d	=	32'd0;
		end
	
		else begin			//not	denormalized
			if (shift_right_bits[8]) begin	//too	big
				p_lost	=	0;
				invalid	=	1;
				d	=	32'h80000000;
		end
	
		else	begin	//shift_right
			if (shift_right_bits[7:0] > 8'h1f)	begin	//too small if shift by more than 32
				if (is_zero)	
					p_lost	=	0;
				else
					p_lost	=	1;
				invalid	=	0;
				d	=	32'h00000000;
			end
			else	begin
				if (sign != int32[31])	begin	//out of range
					p_lost	=	0;
					invalid	=	1;
					d	=	32'h80000000;
				end
				else	begin	//normal case
					if	(lost_bits)
						p_lost	=	1;
					else
						p_lost	=	0;
					invalid	=	0;
					d	=	int32;
				end
			end
		end
	end
endmodule
