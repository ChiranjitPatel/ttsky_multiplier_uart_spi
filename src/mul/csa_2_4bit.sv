module csa_2_4bit(
	ib,
	ia,
	ot
	);
	
	input [3:0]ib;
	input [2:0]ia;
	output [4:0]ot;
	
	wire [4:0]wc;
	wire [1:0]ws;

	ha half_1(ia[0],ib[0],wc[0],ot[0]);
	ha half_2(ia[1],ib[1],wc[1],ws[0]);
	ha half_3(ia[2],ib[2],wc[2],ws[1]);

	ha half_4(wc[0],ws[0],wc[3],ot[1]);
	fa full_1(wc[3],wc[1],ws[1],wc[4],ot[2]);
	fa full_2(wc[4],wc[2],ib[3],ot[4],ot[3]);

endmodule