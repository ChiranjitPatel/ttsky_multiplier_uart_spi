/*
2-bit UT Vedic multiplier
*/
module i2bit_mul(
	a, 
	b, 
	p
);

	input 	[1:0]	a, b;
	output 	[3:0]	p;
	
	assign p[0] = a[0] & b[0];
	assign p[1] = (a[1] & b[0]) ^ (a[0] & b[1]);
	assign p[2] = (a[0] & b[1] & a[1] & b[0]) ^ (a[1] & b[1]);
	assign p[3] = (a[0] & a[1] & b[0] & b[1]);
endmodule