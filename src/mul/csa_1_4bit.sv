module csa_1_4bit(
	ia,
	ib,
	ic,
	ot
	);

input [3:0]ia;
input [3:0]ib;
input [1:0]ic;
output [4:0]ot;

wire [6:0]wc;
wire [2:0]ws;

fa fa_1(ia[0],ib[0],ic[0],wc[0],ot[0]);
fa fa_2(ia[1],ib[1],ic[1],wc[1],ws[0]);
ha ha_1(ia[2],ib[2],wc[2],ws[1]);
ha ha_2(ia[3],ib[3],wc[3],ws[2]);

ha ha_3(wc[0],ws[0],wc[4],ot[1]);
fa fa_3(wc[1],ws[1],wc[4],wc[5],ot[2]);
fa fa_4(wc[2],ws[2],wc[5],wc[6],ot[3]);
assign ot[4] = wc[3]^wc[6];

endmodule