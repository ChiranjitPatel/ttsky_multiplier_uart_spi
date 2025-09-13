module csa_2_8bit(
	ia,
	ib,
	ot
	);

input [7:0]ia;
input [4:0]ib;
output [7:0]ot;

wire [10:0]wc;
wire [3:0]ws;

ha ha_1(ia[0],ib[0],wc[0],ot[0]);
ha ha_2(ia[1],ib[1],wc[1],ws[0]);
ha ha_3(ia[2],ib[2],wc[2],ws[1]);
ha ha_4(ia[3],ib[3],wc[3],ws[2]);
ha ha_5(ia[4],ib[4],wc[4],ws[3]);

ha ha_6(wc[0],ws[0],wc[5],ot[1]);
fa fa_4(wc[5],wc[1],ws[1],wc[6],ot[2]);
fa fa_5(wc[6],wc[2],ws[2],wc[7],ot[3]);
fa fa_6(wc[7],wc[3],ws[3],wc[8],ot[4]);
fa fa_7(wc[8],wc[4],ia[5],wc[9],ot[5]);
ha ha_8(wc[9],ia[6],wc[10],ot[6]);
assign ot[7] = wc[10]^ia[7];

endmodule