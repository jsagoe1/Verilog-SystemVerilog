//32	bit	floating	point	to	integer	converter
/*
special	cases:

				sign	exp			frac		output	
-----------------------------------------------

+InF:			0		all 1's		all 0's		0x7F800000
-InF:			1		all 1's		all 0's		0xFF800000
NaN:			x		all 1's		!=0			0x00000000

denormalized:			all 0's		!=0			0x00000000
zero:					all 0's		all 0's		0x00000000

*/

module	f2i_32	(
	output	logic	[31:0]	d,		//integer
	output	logic		p_lost,		//precision lost
	output	logic		denorm,		//denormalized
	output	logic		invalid,	//inf,	NaN, out of range
	input	uwire	[31:0]	a);		//floating point repr
	
	
endmodule
