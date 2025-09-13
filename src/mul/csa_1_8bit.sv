module csa_1_8bit(
	ia,
	ib,
	ic,
	ot
	);

input [7:0]ia;
input [7:0]ib;
input [3:0]ic;
output [8:0]ot;

wire [14:0]wc;
wire [6:0]ws;

fa fa_1(ia[0],ib[0],ic[0],wc[0],ot[0]);
fa fa_2(ia[1],ib[1],ic[1],wc[1],ws[0]);
fa fa_3(ia[2],ib[2],ic[2],wc[2],ws[1]);
fa fa_4(ia[3],ib[3],ic[3],wc[3],ws[2]);
ha ha_1(ia[4],ib[4],      wc[4],ws[3]);
ha ha_2(ia[5],ib[5],      wc[5],ws[4]);
ha ha_3(ia[6],ib[6],      wc[6],ws[5]);
ha ha_4(ia[7],ib[7],      wc[14],ws[6]);

ha ha_5(wc[0],  ws[0],      wc[7], ot[1]);
fa fa_5(wc[7],  wc[1],ws[1],wc[8], ot[2]);
fa fa_6(wc[8],  wc[2],ws[2],wc[9], ot[3]);
fa fa_7(wc[9],  wc[3],ws[3],wc[10],ot[4]);
fa fa_8(wc[10], wc[4],ws[4],wc[11],ot[5]);
fa fa_9(wc[11], wc[5],ws[5],wc[12],ot[6]);
fa fa_10(wc[12],wc[6],ws[6],wc[13], ot[7]);

assign ot[8] = wc[13] ^ wc[14];

endmodule