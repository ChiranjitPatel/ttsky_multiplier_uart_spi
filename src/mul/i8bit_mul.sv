// 8-bit UT veridc multiplier
module i8bit_mul(
	mul_ip_A, 
	mul_ip_B, 
	// prod
	prod_low,
	prod_high
);

	input 	[7:0] mul_ip_A;
	input 	[7:0] mul_ip_B;
	// output 	[15:0] prod;
	output 	[7:0] prod_low;
	output 	[7:0] prod_high;
	
	wire [40:0]w;
	
	i4bit_mul N1 (mul_ip_A[3:0], mul_ip_B[3:0], w[7:0]);
	i4bit_mul N2 (mul_ip_A[7:4], mul_ip_B[3:0], w[15:8]);
	i4bit_mul N3 (mul_ip_A[3:0], mul_ip_B[7:4], w[23:16]);
	i4bit_mul N4 (mul_ip_A[7:4], mul_ip_B[7:4], w[31:24]);
	
	assign prod_low[3:0] = w[3:0];
	
	csa_1_8bit C1 (w[23:16], w[15:8] , w[7:4], w[40:32]);
	assign prod_low[7:4] = w[35:32];
	csa_2_8bit C2 (w[31:24], w[40:36], prod_high[7:0]);
	
endmodule
