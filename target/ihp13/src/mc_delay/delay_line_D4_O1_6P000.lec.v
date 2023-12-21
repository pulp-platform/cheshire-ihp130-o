module delay_line_D4_O1_6P000 (
    clk_i,
    clk_o,
    delay_i ,
	 VDD, 
	 VSS);
 input clk_i;
 output [0:0] clk_o;
 input [3:0] delay_i;
 inout VDD;
 inout VSS;

 wire clk_l1m0o0;
 wire clk_l1m1o0;
 wire clk_l2m0o0;
 wire clk_l2m1o0;
 wire clk_l2m2o0;
 wire clk_l2m3o0;
 wire clk_l3m0o0;
 wire clk_l3m1o0;
 wire clk_l3m2o0;
 wire clk_l3m3o0;
 wire clk_l3m4o0;
 wire clk_l3m5o0;
 wire clk_l3m6o0;
 wire clk_l3m7o0;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net28;
 wire net29;
 wire net30;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net39;
 wire net41;
 wire net42;
 wire net44;
 wire net45;
 wire net49;
 wire net50;
 wire net52;
 wire net53;
 wire net54;
 wire net55;
 wire net57;
 wire net58;
 wire net59;
 wire net60;
 wire net64;
 wire net66;
 wire net67;
 wire net69;
 wire net70;
 wire net71;
 wire net72;
 wire net74;
 wire net75;

 sg13g2_mux2_2 i_mx_l0m0o0 (
    .A0(clk_l1m0o0),
    .A1(net30),
    .S(delay_i[0]),
    .X(clk_o[0]), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l1m0o0 (
    .A0(clk_l2m0o0),
    .A1(clk_l2m1o0),
    .S(delay_i[1]),
    .X(clk_l1m0o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l1m1o0 (
    .A0(net35),
    .A1(net55),
    .S(delay_i[1]),
    .X(clk_l1m1o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l2m0o0 (
    .A0(clk_l3m0o0),
    .A1(clk_l3m1o0),
    .S(delay_i[2]),
    .X(clk_l2m0o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l2m1o0 (
    .A0(net8),
    .A1(net17),
    .S(delay_i[2]),
    .X(clk_l2m1o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l2m2o0 (
    .A0(net33),
    .A1(net42),
    .S(delay_i[2]),
    .X(clk_l2m2o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l2m3o0 (
    .A0(net60),
    .A1(net72),
    .S(delay_i[2]),
    .X(clk_l2m3o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m0o0 (
    .A0(clk_i),
    .A1(net1),
    .S(delay_i[3]),
    .X(clk_l3m0o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m1o0 (
    .A0(net2),
    .A1(net4),
    .S(delay_i[3]),
    .X(clk_l3m1o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m2o0 (
    .A0(net7),
    .A1(net14),
    .S(delay_i[3]),
    .X(clk_l3m2o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m3o0 (
    .A0(net19),
    .A1(net24),
    .S(delay_i[3]),
    .X(clk_l3m3o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m4o0 (
    .A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m4o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m5o0 (
    .A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m5o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m6o0 (
    .A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m6o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_mux2_1 i_mx_l3m7o0 (
    .A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m7o0), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold1 (
    .A(clk_i),
    .X(net1), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold2 (
    .A(net3),
    .X(net2), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold3 (
    .A(clk_i),
    .X(net3), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold4 (
    .A(net5),
    .X(net4), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold5 (
    .A(net6),
    .X(net5), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd2_1 hold6 (
    .A(clk_i),
    .X(net6), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold7 (
    .A(net10),
    .X(net7), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold8 (
    .A(clk_l3m2o0),
    .X(net8), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold10 (
    .A(net11),
    .X(net10), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold11 (
    .A(clk_i),
    .X(net11), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold12 (
    .A(net13),
    .X(net12), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold13 (
    .A(net15),
    .X(net13), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold14 (
    .A(net12),
    .X(net14), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd2_1 hold15 (
    .A(clk_i),
    .X(net15), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold16 (
    .A(net18),
    .X(net16), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold17 (
    .A(net20),
    .X(net17), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold18 (
    .A(net21),
    .X(net18), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold19 (
    .A(net16),
    .X(net19), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold20 (
    .A(clk_l3m3o0),
    .X(net20), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd2_1 hold21 (
    .A(clk_i),
    .X(net21), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold22 (
    .A(net23),
    .X(net22), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold23 (
    .A(net25),
    .X(net23), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold24 (
    .A(net22),
    .X(net24), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold25 (
    .A(clk_i),
    .X(net25), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold28 (
    .A(net32),
    .X(net28), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold29 (
    .A(net34),
    .X(net29), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold30 (
    .A(clk_l1m1o0),
    .X(net30), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold32 (
    .A(clk_l3m4o0),
    .X(net32), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold33 (
    .A(net28),
    .X(net33), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold34 (
    .A(clk_l2m2o0),
    .X(net34), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold35 (
    .A(net29),
    .X(net35), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold39 (
    .A(net45),
    .X(net39), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold41 (
    .A(net44),
    .X(net41), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold42 (
    .A(net39),
    .X(net42), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold44 (
    .A(clk_l3m5o0),
    .X(net44), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold45 (
    .A(net41),
    .X(net45), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold49 (
    .A(net58),
    .X(net49), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold50 (
    .A(net54),
    .X(net50), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold52 (
    .A(net57),
    .X(net52), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold53 (
    .A(net59),
    .X(net53), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold54 (
    .A(clk_l2m3o0),
    .X(net54), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold55 (
    .A(net50),
    .X(net55), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold57 (
    .A(clk_l3m6o0),
    .X(net57), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold58 (
    .A(net52),
    .X(net58), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold59 (
    .A(net49),
    .X(net59), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold60 (
    .A(net53),
    .X(net60), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold64 (
    .A(net70),
    .X(net64), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold66 (
    .A(net75),
    .X(net66), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold67 (
    .A(net71),
    .X(net67), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold69 (
    .A(net74),
    .X(net69), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold70 (
    .A(net66),
    .X(net70), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold71 (
    .A(net64),
    .X(net71), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold72 (
    .A(net67),
    .X(net72), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold74 (
    .A(clk_l3m7o0),
    .X(net74), 
    .VSS(VSS), 
    .VDD(VDD));
 sg13g2_dlygate4sd3_1 hold75 (
    .A(net69),
    .X(net75), 
    .VSS(VSS), 
    .VDD(VDD));
endmodule
