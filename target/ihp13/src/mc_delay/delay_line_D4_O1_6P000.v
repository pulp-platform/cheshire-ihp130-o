module delay_line_D4_O1_6P000 (clk_i,
    clk_o,
    delay_i);
 input clk_i;
 output [0:0] clk_o;
 input [3:0] delay_i;

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

 sg13g2_mux2_2 i_mx_l0m0o0 (.A0(clk_l1m0o0),
    .A1(net30),
    .S(delay_i[0]),
    .X(clk_o[0]));
 sg13g2_mux2_1 i_mx_l1m0o0 (.A0(clk_l2m0o0),
    .A1(clk_l2m1o0),
    .S(delay_i[1]),
    .X(clk_l1m0o0));
 sg13g2_mux2_1 i_mx_l1m1o0 (.A0(net35),
    .A1(net55),
    .S(delay_i[1]),
    .X(clk_l1m1o0));
 sg13g2_mux2_1 i_mx_l2m0o0 (.A0(clk_l3m0o0),
    .A1(clk_l3m1o0),
    .S(delay_i[2]),
    .X(clk_l2m0o0));
 sg13g2_mux2_1 i_mx_l2m1o0 (.A0(net8),
    .A1(net17),
    .S(delay_i[2]),
    .X(clk_l2m1o0));
 sg13g2_mux2_1 i_mx_l2m2o0 (.A0(net33),
    .A1(net42),
    .S(delay_i[2]),
    .X(clk_l2m2o0));
 sg13g2_mux2_1 i_mx_l2m3o0 (.A0(net60),
    .A1(net72),
    .S(delay_i[2]),
    .X(clk_l2m3o0));
 sg13g2_mux2_1 i_mx_l3m0o0 (.A0(clk_i),
    .A1(net1),
    .S(delay_i[3]),
    .X(clk_l3m0o0));
 sg13g2_mux2_1 i_mx_l3m1o0 (.A0(net2),
    .A1(net4),
    .S(delay_i[3]),
    .X(clk_l3m1o0));
 sg13g2_mux2_1 i_mx_l3m2o0 (.A0(net7),
    .A1(net14),
    .S(delay_i[3]),
    .X(clk_l3m2o0));
 sg13g2_mux2_1 i_mx_l3m3o0 (.A0(net19),
    .A1(net24),
    .S(delay_i[3]),
    .X(clk_l3m3o0));
 sg13g2_mux2_1 i_mx_l3m4o0 (.A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m4o0));
 sg13g2_mux2_1 i_mx_l3m5o0 (.A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m5o0));
 sg13g2_mux2_1 i_mx_l3m6o0 (.A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m6o0));
 sg13g2_mux2_1 i_mx_l3m7o0 (.A0(clk_i),
    .A1(clk_i),
    .S(delay_i[3]),
    .X(clk_l3m7o0));
 sg13g2_dlygate4sd3_1 hold1 (.A(clk_i),
    .X(net1));
 sg13g2_dlygate4sd3_1 hold2 (.A(net3),
    .X(net2));
 sg13g2_dlygate4sd3_1 hold3 (.A(clk_i),
    .X(net3));
 sg13g2_dlygate4sd3_1 hold4 (.A(net5),
    .X(net4));
 sg13g2_dlygate4sd3_1 hold5 (.A(net6),
    .X(net5));
 sg13g2_dlygate4sd2_1 hold6 (.A(clk_i),
    .X(net6));
 sg13g2_dlygate4sd3_1 hold7 (.A(net10),
    .X(net7));
 sg13g2_dlygate4sd3_1 hold8 (.A(clk_l3m2o0),
    .X(net8));
 sg13g2_dlygate4sd3_1 hold10 (.A(net11),
    .X(net10));
 sg13g2_dlygate4sd3_1 hold11 (.A(clk_i),
    .X(net11));
 sg13g2_dlygate4sd3_1 hold12 (.A(net13),
    .X(net12));
 sg13g2_dlygate4sd3_1 hold13 (.A(net15),
    .X(net13));
 sg13g2_dlygate4sd3_1 hold14 (.A(net12),
    .X(net14));
 sg13g2_dlygate4sd2_1 hold15 (.A(clk_i),
    .X(net15));
 sg13g2_dlygate4sd3_1 hold16 (.A(net18),
    .X(net16));
 sg13g2_dlygate4sd3_1 hold17 (.A(net20),
    .X(net17));
 sg13g2_dlygate4sd3_1 hold18 (.A(net21),
    .X(net18));
 sg13g2_dlygate4sd3_1 hold19 (.A(net16),
    .X(net19));
 sg13g2_dlygate4sd3_1 hold20 (.A(clk_l3m3o0),
    .X(net20));
 sg13g2_dlygate4sd2_1 hold21 (.A(clk_i),
    .X(net21));
 sg13g2_dlygate4sd3_1 hold22 (.A(net23),
    .X(net22));
 sg13g2_dlygate4sd3_1 hold23 (.A(net25),
    .X(net23));
 sg13g2_dlygate4sd3_1 hold24 (.A(net22),
    .X(net24));
 sg13g2_dlygate4sd3_1 hold25 (.A(clk_i),
    .X(net25));
 sg13g2_dlygate4sd3_1 hold28 (.A(net32),
    .X(net28));
 sg13g2_dlygate4sd3_1 hold29 (.A(net34),
    .X(net29));
 sg13g2_dlygate4sd3_1 hold30 (.A(clk_l1m1o0),
    .X(net30));
 sg13g2_dlygate4sd3_1 hold32 (.A(clk_l3m4o0),
    .X(net32));
 sg13g2_dlygate4sd3_1 hold33 (.A(net28),
    .X(net33));
 sg13g2_dlygate4sd3_1 hold34 (.A(clk_l2m2o0),
    .X(net34));
 sg13g2_dlygate4sd3_1 hold35 (.A(net29),
    .X(net35));
 sg13g2_dlygate4sd3_1 hold39 (.A(net45),
    .X(net39));
 sg13g2_dlygate4sd3_1 hold41 (.A(net44),
    .X(net41));
 sg13g2_dlygate4sd3_1 hold42 (.A(net39),
    .X(net42));
 sg13g2_dlygate4sd3_1 hold44 (.A(clk_l3m5o0),
    .X(net44));
 sg13g2_dlygate4sd3_1 hold45 (.A(net41),
    .X(net45));
 sg13g2_dlygate4sd3_1 hold49 (.A(net58),
    .X(net49));
 sg13g2_dlygate4sd3_1 hold50 (.A(net54),
    .X(net50));
 sg13g2_dlygate4sd3_1 hold52 (.A(net57),
    .X(net52));
 sg13g2_dlygate4sd3_1 hold53 (.A(net59),
    .X(net53));
 sg13g2_dlygate4sd3_1 hold54 (.A(clk_l2m3o0),
    .X(net54));
 sg13g2_dlygate4sd3_1 hold55 (.A(net50),
    .X(net55));
 sg13g2_dlygate4sd3_1 hold57 (.A(clk_l3m6o0),
    .X(net57));
 sg13g2_dlygate4sd3_1 hold58 (.A(net52),
    .X(net58));
 sg13g2_dlygate4sd3_1 hold59 (.A(net49),
    .X(net59));
 sg13g2_dlygate4sd3_1 hold60 (.A(net53),
    .X(net60));
 sg13g2_dlygate4sd3_1 hold64 (.A(net70),
    .X(net64));
 sg13g2_dlygate4sd3_1 hold66 (.A(net75),
    .X(net66));
 sg13g2_dlygate4sd3_1 hold67 (.A(net71),
    .X(net67));
 sg13g2_dlygate4sd3_1 hold69 (.A(net74),
    .X(net69));
 sg13g2_dlygate4sd3_1 hold70 (.A(net66),
    .X(net70));
 sg13g2_dlygate4sd3_1 hold71 (.A(net64),
    .X(net71));
 sg13g2_dlygate4sd3_1 hold72 (.A(net67),
    .X(net72));
 sg13g2_dlygate4sd3_1 hold74 (.A(clk_l3m7o0),
    .X(net74));
 sg13g2_dlygate4sd3_1 hold75 (.A(net69),
    .X(net75));
 sg13g2_fill_2 FILLER_0_0_0 ();
 sg13g2_fill_4 FILLER_0_0_13 ();
 sg13g2_fill_1 FILLER_0_0_27 ();
 sg13g2_fill_8 FILLER_0_0_56 ();
 sg13g2_fill_4 FILLER_0_1_0 ();
 sg13g2_fill_4 FILLER_0_1_42 ();
 sg13g2_fill_2 FILLER_0_1_46 ();
 sg13g2_fill_1 FILLER_0_1_48 ();
 sg13g2_fill_2 FILLER_0_1_67 ();
 sg13g2_fill_4 FILLER_0_1_79 ();
 sg13g2_fill_2 FILLER_0_2_0 ();
 sg13g2_fill_4 FILLER_0_2_30 ();
 sg13g2_fill_1 FILLER_0_2_34 ();
 sg13g2_fill_8 FILLER_0_2_45 ();
 sg13g2_fill_2 FILLER_0_2_71 ();
 sg13g2_fill_1 FILLER_0_2_73 ();
 sg13g2_fill_2 FILLER_0_3_0 ();
 sg13g2_fill_1 FILLER_0_3_2 ();
 sg13g2_fill_1 FILLER_0_3_11 ();
 sg13g2_fill_8 FILLER_0_3_30 ();
 sg13g2_fill_4 FILLER_0_3_57 ();
 sg13g2_fill_2 FILLER_0_3_61 ();
 sg13g2_fill_1 FILLER_0_3_63 ();
 sg13g2_fill_4 FILLER_0_4_0 ();
 sg13g2_fill_2 FILLER_0_4_4 ();
 sg13g2_fill_1 FILLER_0_4_6 ();
 sg13g2_fill_4 FILLER_0_4_35 ();
 sg13g2_fill_4 FILLER_0_4_76 ();
 sg13g2_fill_2 FILLER_0_4_80 ();
 sg13g2_fill_1 FILLER_0_4_82 ();
 sg13g2_fill_4 FILLER_0_5_0 ();
 sg13g2_fill_4 FILLER_0_5_76 ();
 sg13g2_fill_2 FILLER_0_5_80 ();
 sg13g2_fill_1 FILLER_0_5_82 ();
 sg13g2_fill_4 FILLER_0_6_0 ();
 sg13g2_fill_4 FILLER_0_6_30 ();
 sg13g2_fill_1 FILLER_0_6_34 ();
 sg13g2_fill_2 FILLER_0_6_44 ();
 sg13g2_fill_1 FILLER_0_6_46 ();
 sg13g2_fill_2 FILLER_0_6_56 ();
 sg13g2_fill_1 FILLER_0_6_67 ();
 sg13g2_fill_4 FILLER_0_6_77 ();
 sg13g2_fill_2 FILLER_0_6_81 ();
 sg13g2_fill_8 FILLER_0_7_0 ();
 sg13g2_fill_2 FILLER_0_7_17 ();
 sg13g2_fill_1 FILLER_0_7_19 ();
 sg13g2_fill_4 FILLER_0_7_49 ();
 sg13g2_fill_2 FILLER_0_7_53 ();
 sg13g2_fill_1 FILLER_0_7_73 ();
 sg13g2_fill_4 FILLER_0_8_0 ();
 sg13g2_fill_2 FILLER_0_8_4 ();
 sg13g2_fill_8 FILLER_0_8_33 ();
 sg13g2_fill_8 FILLER_0_8_41 ();
 sg13g2_fill_4 FILLER_0_8_49 ();
 sg13g2_fill_2 FILLER_0_8_53 ();
 sg13g2_fill_1 FILLER_0_8_55 ();
 sg13g2_fill_4 FILLER_0_9_0 ();
 sg13g2_fill_4 FILLER_0_9_12 ();
 sg13g2_fill_1 FILLER_0_9_16 ();
 sg13g2_fill_8 FILLER_0_9_26 ();
 sg13g2_fill_8 FILLER_0_9_34 ();
 sg13g2_fill_8 FILLER_0_9_42 ();
 sg13g2_fill_4 FILLER_0_9_50 ();
 sg13g2_fill_2 FILLER_0_9_54 ();
 sg13g2_fill_8 FILLER_0_10_0 ();
 sg13g2_fill_8 FILLER_0_10_8 ();
 sg13g2_fill_8 FILLER_0_10_16 ();
 sg13g2_fill_8 FILLER_0_10_24 ();
 sg13g2_fill_8 FILLER_0_10_32 ();
 sg13g2_fill_8 FILLER_0_10_40 ();
 sg13g2_fill_8 FILLER_0_10_48 ();
 sg13g2_fill_8 FILLER_0_10_56 ();
 sg13g2_fill_1 FILLER_0_10_64 ();
endmodule
