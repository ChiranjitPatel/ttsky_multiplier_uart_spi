// 4-bit UT veridc multiplier
module i4bit_mul(
	a, 
	b, 
	s
);

	input 	[3:0] a;
	input 	[3:0] b;
	output 	[7:0] s;
	
	wire [20:0]w;
	
	i2bit_mul N1 (a[1:0], b[1:0], w[3:0]);
	i2bit_mul N2 (a[3:2], b[1:0], w[7:4]);
	i2bit_mul N3 (a[1:0], b[3:2], w[11:8]);
	i2bit_mul N4 (a[3:2], b[3:2], w[15:12]);
	
	assign s[1:0] = w[1:0];
	
	csa_1_4bit C1 (w[11:8], w[7:4], w[3:2], w[20:16]);
	csa_2_4bit C2 (w[15:12], w[20:18], s[7:4]);
	
	assign s[3:2] = w[17:16];
	
endmodule
