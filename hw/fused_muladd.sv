// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Philippe Sauter <phsauter@ethz.ch>
//
// Fused multiply-add unit
// integrates two add-ops into CSA tree of multiplier
// intended to improve synthesis results of fpnew_fma
// Future: use library of arithmetic units automatically in Yosys (working on it)
// ONLY WORKS FOR PRECISION_BITS=53!


// library of arithmetic units prefix and-or trees
module PrefixAndOr #(
	parameter int width = 8, // word width
	parameter int speed = 2  // performance parameter
) (
	input  logic [width-1:0] GI,  // gen./prop. in
	input  logic [width-1:0] PI,  // gen./prop. in
	output logic [width-1:0] GO,  // gen./prop. out
	output logic [width-1:0] PO   // gen./prop. out
);

	// Constants
	localparam int n = width;  // prefix structure width
	localparam int m = $clog2(width);  // prefix structure depth

	// Sklansky parallel-prefix carry-lookahead structure
	if (speed == 2) begin : fastPrefix
		logic [(m+1)*n-1:0] GT, PT;  // gen./prop. temp
			assign GT[n-1:0] = GI;
			assign PT[n-1:0] = PI;
			for (genvar l = 1; l <= m; l++) begin : levels
				for (genvar k = 0; k < 2 ** (m - l); k++) begin : groups
					for (genvar i = 0; i < 2 ** (l - 1); i++) begin : bits
						// pass prop and gen to following nodes
						if ((k * 2 ** l + i) < n) begin : white
							assign GT[l*n+k*2**l+i] = GT[(l-1)*n+k*2**l+i];
							assign PT[l*n+k*2**l+i] = PT[(l-1)*n+k*2**l+i];
						end
						// calculate new propagate and generate
						if ((k * 2 ** l + 2 ** (l - 1) + i) < n) begin : black
							assign GT[l*n + k*2**l + 2**(l-1) + i] = 
												GT[(l-1)*n + k*2**l + 2**(l-1) + i]
											  | (  PT[(l-1)*n + k*2**l + 2**(l-1) + i]
												 & GT[(l-1)*n + k*2**l + 2**(l-1) - 1] );
							assign PT[l*n + k*2**l + 2**(l-1) + i] = 
													PT[(l-1)*n + k*2**l + 2**(l-1) + i]
												  & PT[(l-1)*n + k*2**l + 2**(l-1) - 1];
						end
					end
				end
			end
			assign GO = GT[(m+1)*n-1 : m*n];
			assign PO = PT[(m+1)*n-1 : m*n];
	end

	// Brent-Kung parallel-prefix carry-lookahead structure
	if (speed == 1) begin : mediumPrefix
		logic [(2*m)*n -1:0] GT, PT;  // gen./prop. temp
		assign GT[n-1:0] = GI;
		assign PT[n-1:0] = PI;

		for (genvar l = 1; l <= m; l++) begin : levels1
			for (genvar k = 0; k < 2**(m-l); k++) begin : groups
				for (genvar i = 0; i < 2**l -1; i++) begin : bits
					if ((k* 2**l +i) < n) begin : white
						assign GT[l*n + k* 2**l +i] = GT[(l-1)*n + k* 2**l +i];
						assign PT[l*n + k* 2**l +i] = PT[(l-1)*n + k* 2**l +i];
					end // white
				end // bits
				if ((k* 2**l + 2**l -1) < n) begin : black
					assign GT[l*n + k* 2**l + 2**l -1] =
								GT[(l-1)*n + k* 2**l + 2**l - 1] |
							  | (  PT[(l-1)*n + k* 2**l + 2**l     -1] 
							     & GT[(l-1)*n + k* 2**l + 2**(l-1) -1]);
					assign PT[l*n + k* 2**l + 2**l -1] =
								PT[(l-1)*n + k*2**l + 2**l     -1] 
							  & PT[(l-1)*n + k*2**l + 2**(l-1) -1];
				end // black
			end
		end // level1
		for (genvar l = m +1; l < 2*m; l++) begin : levels2
			for (genvar i = 0; i < 2**(2*m -l); i++) begin : bits
				if (i < n) begin : white
					assign GT[l*n +i] = GT[(l-1)*n +i];
					assign PT[l*n +i] = PT[(l-1)*n +i];
				end // white
			end // bits
			for (genvar k = 1; k < 2**(l-m); k++) begin : groups
				if (l < 2*m -1) begin : empty
					for (genvar i = 0; i < 2**(2*m -l -1) -1; i++) begin : bits
						if ((k* 2**(2*m -l) +i) < n) begin : white
							assign GT[l*n + k* 2**(2*m -l) +i] = GT[(l-1)*n + k* 2**(2*m -l) +i];
							assign PT[l*n + k* 2**(2*m -l) +i] = PT[(l-1)*n + k* 2**(2*m -l) +i];
						end // white
					end
				end // empty
				if ((k* 2**(2*m -l) + 2**(2*m -l -1) -1) < n) begin : black
					assign GT[l*n + k* 2**(2*m -l) + 2**(2*m -l-1) -1] = 
								GT[(l-1)*n + k* 2**(2*m-l) + 2**(2*m -l-1) -1]
							  | (  PT[(l-1)*n + k* 2**(2*m-l) + 2**(2*m-l-1) -1] 
								 & GT[(l-1)*n + k* 2**(2*m-l) -1] );
					assign PT[l*n + k* 2**(2*m -l) + 2**(2*m -l-1) -1] = 
								PT[(l-1)*n + k* 2**(2*m -l) + 2**(2*m -l-1) -1]
							  & PT[(l-1)*n + k* 2**(2*m -l) -1];
				end // black
				for (genvar i = 2**(2*m -l-1); i < 2**(2*m -l); i++) begin : bits
					if ((k* 2**(2*m -l) +i) < n) begin : white
						assign GT[l*n + k* 2**(2*m -l) +i] = GT[(l-1)*n + k* 2**(2*m -l) +i];
						assign PT[l*n + k* 2**(2*m -l) +i] = PT[(l-1)*n + k* 2**(2*m -l) +i];
					end // white
				end
			end
		end // level2
		assign GO = GT[2*m*n -1 : (2*m -1) * n];
		assign PO = PT[2*m*n -1 : (2*m -1) * n];
	end  // Serial-prefix carry-lookahead structure
	else if (speed == 0) begin : slowPrefix
		logic [n-1:0] GT, PT;  // gen./prop. temp
		assign GT[0] = GI[0];
		assign PT[0] = PI[0];
		
		for (genvar i = 1; i < n; i++) begin : bits
			assign GT[i] = GI[i] | (PI[i] & GT[i-1]);
			assign PT[i] = PI[i] & PT[i-1];
		end
		assign GO = GT;
		assign PO = PT;
	end

endmodule


// library of arithmetic units adder
module Add #(
	parameter int width = 8, // word width
	parameter int speed = 2  // performance parameter
) (
	input  logic [width-1:0] A,  // operands
	input  logic [width-1:0] B,
	output logic [width-1:0] S   // sum
);

	// Function: Binary adder using parallel-prefix carry-lookahead logic.

	logic [width-1:0] GI, PI;  // prefix gen./prop. in
	logic [width-1:0] GO, PO;  // prefix gen./prop. out
	logic [width-1:0] PT;  // adder propagate temp

	// Internal signals for unsigned operands
	logic [width-1:0] Auns, Buns, Suns;

	// default ripple-carry adder as slow implementation
	if (speed == 0) begin
		// type conversion: std_logic_vector -> unsigned
		assign Auns = A;
		assign Buns = B;

		// addition
		assign Suns = Auns + Buns;

		// type conversion: unsigned -> std_logic_vector
		assign S = Suns;
	end else begin
		// parallel-prefix adders as medium and fast implementations

		// calculate prefix input generate/propagate signals
		assign GI = A & B;
		assign PI = A | B;
		// calculate adder propagate signals (PT = A xor B)
		assign PT = ~GI & PI;

		// calculate prefix output generate/propagate signals
		PrefixAndOr #(
			.width(width),
			.speed(speed)
		) prefix (
			.GI(GI),
			.PI(PI),
			.GO(GO),
			.PO(PO)
		);

		// calculate sum bits
		assign S = PT ^ {GO[width-2:0], 1'b0};
	end
endmodule


// carry-save-add (full-adder) cell
module csa_cell(
	input  logic a_i,
	input  logic b_i,
	input  logic c_i,

	output logic s_o, // sum
	output logic c_o  // carry
);
	logic prop;
	assign prop = a_i ^ b_i;

	assign s_o  = prop ^ c_i;
	assign c_o  = prop ? c_i : a_i;
endmodule


// 3:2 compressor of WIDTH bits (with integrated carry shift)
module csa_slice #(
	parameter int unsigned WIDTH=164
) (
	input  logic [WIDTH-1:0] b_i,
	input  logic [WIDTH-1:0] a_i,
	input  logic [WIDTH-1:0] c_i,

	output logic [WIDTH-1:0] s_o, // sum
	output logic [WIDTH-1:0] c_o  // carry (shifted)
);
	logic [WIDTH-1:0] carry;

	for (genvar i=0; i<WIDTH; i++) begin
		csa_cell csa (
			.a_i(a_i[i]),
			.b_i(b_i[i]),
			.c_i(c_i[i]),
			.s_o(s_o[i]),
			.c_o(carry[i])
		);
	end
	assign c_o = (carry << 1);

endmodule

// CSA Wallace tree
module csa_tree #(
	parameter  int unsigned WIDTH=164,
	localparam int unsigned OPERANDS=31
) (
	input  logic [OPERANDS-1:0][WIDTH-1:0] op_i, 	// summands
	output logic               [WIDTH-1:0] sum_o,	// sum
	output logic               [WIDTH-1:0] carry_o	// carry (shifted)
);

	logic [28:0][WIDTH-1:0] cry; // carry
	logic [28:0][WIDTH-1:0] sum;

	// layer 1
	csa_slice #(WIDTH) i_csa00 (.a_i(op_i[0]),  .b_i(op_i[1]),  .c_i(op_i[2]),  .s_o(sum[0]),  .c_o(cry[0]) );
	csa_slice #(WIDTH) i_csa01 (.a_i(op_i[3]),  .b_i(op_i[4]),  .c_i(op_i[5]),  .s_o(sum[1]),  .c_o(cry[1]) );
	csa_slice #(WIDTH) i_csa02 (.a_i(op_i[6]),  .b_i(op_i[7]),  .c_i(op_i[8]),  .s_o(sum[2]),  .c_o(cry[2]) );
	csa_slice #(WIDTH) i_csa03 (.a_i(op_i[9]),  .b_i(op_i[10]), .c_i(op_i[11]), .s_o(sum[3]),  .c_o(cry[3]) );
	csa_slice #(WIDTH) i_csa04 (.a_i(op_i[12]), .b_i(op_i[13]), .c_i(op_i[14]), .s_o(sum[4]),  .c_o(cry[4]) );
	csa_slice #(WIDTH) i_csa05 (.a_i(op_i[15]), .b_i(op_i[16]), .c_i(op_i[17]), .s_o(sum[5]),  .c_o(cry[5]) );
	csa_slice #(WIDTH) i_csa06 (.a_i(op_i[18]), .b_i(op_i[19]), .c_i(op_i[20]), .s_o(sum[6]),  .c_o(cry[6]) );
	csa_slice #(WIDTH) i_csa07 (.a_i(op_i[21]), .b_i(op_i[22]), .c_i(op_i[23]), .s_o(sum[7]),  .c_o(cry[7]) );
	csa_slice #(WIDTH) i_csa08 (.a_i(op_i[24]), .b_i(op_i[25]), .c_i(op_i[26]), .s_o(sum[8]),  .c_o(cry[8]) );
	csa_slice #(WIDTH) i_csa09 (.a_i(op_i[27]), .b_i(op_i[28]), .c_i(op_i[29]), .s_o(sum[9]),  .c_o(cry[9]) );
																				// op[30]
	// layer 2
	csa_slice #(WIDTH) i_csa10 (.a_i(sum[0]),   .b_i(cry[0]),  .c_i(sum[1]),    .s_o(sum[10]), .c_o(cry[10]) );
	csa_slice #(WIDTH) i_csa11 (.a_i(cry[1]),   .b_i(sum[2]),  .c_i(cry[2]),    .s_o(sum[11]), .c_o(cry[11]) );
	csa_slice #(WIDTH) i_csa12 (.a_i(sum[3]),   .b_i(cry[3]),  .c_i(sum[4]),    .s_o(sum[12]), .c_o(cry[12]) );
	csa_slice #(WIDTH) i_csa13 (.a_i(cry[4]),   .b_i(sum[5]),  .c_i(cry[5]),    .s_o(sum[13]), .c_o(cry[13]) );
	csa_slice #(WIDTH) i_csa14 (.a_i(sum[6]),   .b_i(cry[6]),  .c_i(sum[7]),    .s_o(sum[14]), .c_o(cry[14]) );
	csa_slice #(WIDTH) i_csa15 (.a_i(cry[7]),   .b_i(sum[8]),  .c_i(cry[8]),    .s_o(sum[15]), .c_o(cry[15]) );
	csa_slice #(WIDTH) i_csa16 (.a_i(sum[9]),   .b_i(cry[9]),  .c_i(op_i[30]),  .s_o(sum[16]), .c_o(cry[16]) );
	// layer 3
	csa_slice #(WIDTH) i_csa17 (.a_i(sum[10]),  .b_i(cry[10]), .c_i(sum[11]),   .s_o(sum[17]), .c_o(cry[17]) );
	csa_slice #(WIDTH) i_csa18 (.a_i(cry[11]),  .b_i(sum[12]), .c_i(cry[12]),   .s_o(sum[18]), .c_o(cry[18]) );
	csa_slice #(WIDTH) i_csa19 (.a_i(sum[13]),  .b_i(cry[13]), .c_i(sum[14]),   .s_o(sum[19]), .c_o(cry[19]) );
	csa_slice #(WIDTH) i_csa20 (.a_i(cry[14]),  .b_i(sum[15]), .c_i(cry[15]),   .s_o(sum[20]), .c_o(cry[20]) );
																				// sum[16], cry[16]
	// layer 4 
	csa_slice #(WIDTH) i_csa21 (.a_i(sum[17]),  .b_i(cry[17]), .c_i(sum[18]),   .s_o(sum[21]), .c_o(cry[21]) );
	csa_slice #(WIDTH) i_csa22 (.a_i(cry[18]),  .b_i(sum[19]), .c_i(cry[19]),   .s_o(sum[22]), .c_o(cry[22]) );
	csa_slice #(WIDTH) i_csa23 (.a_i(sum[20]),  .b_i(cry[20]), .c_i(sum[16]),   .s_o(sum[23]), .c_o(cry[23]) );
																				// cry[16]
	// layer 5
	csa_slice #(WIDTH) i_csa24 (.a_i(sum[21]),  .b_i(cry[21]), .c_i(sum[22]),   .s_o(sum[24]), .c_o(cry[24]) );
	csa_slice #(WIDTH) i_csa25 (.a_i(cry[22]),  .b_i(sum[23]), .c_i(cry[23]),   .s_o(sum[25]), .c_o(cry[25]) );
																				// cry[16]
	// layer 6 
	csa_slice #(WIDTH) i_csa26 (.a_i(sum[24]),  .b_i(cry[24]), .c_i(sum[25]),   .s_o(sum[26]), .c_o(cry[26]) );
																				// cry[16], cry[25]
	// layer 7
	csa_slice #(WIDTH) i_csa27 (.a_i(cry[25]),  .b_i(sum[26]), .c_i(cry[16]),   .s_o(sum[27]), .c_o(cry[27]) );
	// layer 8
	csa_slice #(WIDTH) i_csa28 (.a_i(cry[26]),  .b_i(sum[27]), .c_i(cry[27]),   .s_o(sum[28]), .c_o(cry[28]) );
  
	assign carry_o = cry[28];
	assign sum_o   = sum[28];
endmodule


// ONLY WORKS FOR PRECISION_BITS=53! -> MUL_WIDTH=54
module fused_multiply_add #(
	localparam int unsigned MUL_WIDTH = 54,
	localparam int unsigned OUT_WIDTH = 164,

  	localparam int unsigned NUM_PP = $floor(MUL_WIDTH / 2 +1)
) (
	input  logic [MUL_WIDTH-1:0] multiplier_i, // remember: assign product_shifted = (ma * mb) << 2; -> ( (ma<<1) * (mb<<1) )
	input  logic [MUL_WIDTH-1:0] multiplicand_i,

	input  logic [OUT_WIDTH-1:0] addend1_i,
	input  logic [OUT_WIDTH-1:0] addend2_i,

	output logic [OUT_WIDTH-1:0] result_o
);

logic [  1+MUL_WIDTH-1:0] mul, mul_compl; // +1, set to 0 for forced unsigned-ness of operands
logic [2+1+MUL_WIDTH-1:0] multiplier_ext; // +2, set to 0 for unsigned-ness of last PP
logic [NUM_PP-1:0]     	  sign_bits;
logic [NUM_PP-1:0][2:0]   booth_codes; // each PP derived from (b_{i-1}, b_i, b_{i+1})

logic [NUM_PP-1:0][3+1+MUL_WIDTH -1:0] partial_prod;
logic [NUM_PP-1:0][  2*MUL_WIDTH -1:0] pp_shifted;

logic [3+NUM_PP-1:0][OUT_WIDTH-1:0] summands;
logic               [OUT_WIDTH-1:0] csa_sum;
logic               [OUT_WIDTH-1:0] csa_carry;

always @(*) begin
	summands = '0;
	partial_prod = '0;
	pp_shifted = '0;

	// the first bit to look at is mulipl[0] so we need to create a 'neighbor' below
	// the last bit of mulipl must be fully considered -> repeat sign bit (here unsigned mul so '0)
	multiplier_ext = {2'b00, multiplier_i, 1'b0};

	mul = multiplicand_i;

	// Modified Booth 2 encoding
	// twos compl of multiplicand is achieved by bitwise compl of current operand
	// and the +1 is added to the next PP to save an adder
	// the last PP can't be negative due to the unsigned nature (sign extend of multipl is always 0)
	for (int i = 0; i < NUM_PP; i++) begin     // jump 2-bit forward
		booth_codes[i] = multiplier_ext[(2*i)+:3]; // look at middle-bit and its neighbors
		unique case(booth_codes[i]) 
			3'b000, 3'b111: begin partial_prod[i] = '0;            sign_bits[i] = 1'b0; end //  0M
			3'b001, 3'b010: begin partial_prod[i] = mul;           sign_bits[i] = 1'b0; end // +1M
			3'b011:         begin partial_prod[i] = {mul, 1'b0};   sign_bits[i] = 1'b0; end // +2M
			3'b100:         begin partial_prod[i] = ~{mul, 1'b0};  sign_bits[i] = 1'b1; end // -2M
			3'b101, 3'b110: begin partial_prod[i] = ~mul;          sign_bits[i] = 1'b1; end // -1M
		endcase

		// shift PPs into place
		if (i == 0) begin // the first PP is slightly special because of the added LSB bit
			partial_prod[i][3+1+MUL_WIDTH-1-:3] = {~sign_bits[i], sign_bits[i], sign_bits[i]};
			pp_shifted[i] = partial_prod[i] << (2*i);
		end else begin
			// the last one has no 2'b01 at MSB (cut off at assignment to shifted)
			partial_prod[i][3+1+MUL_WIDTH-1-:3] = {1'b0, 1'b1, ~sign_bits[i]};
			// if previous was negative, add a +1 to complete the twos compl
			pp_shifted[i] = {partial_prod[i], 1'b0, sign_bits[i-1]} << (2*(i-1)); 
		end

		summands[i] = pp_shifted[i];
	end
	// the multiplier leaves a single 1 just outside its width, 
	// I don't have time to investigate the booth architecture
	// so I just substract the overflowed value again (does not increase CSA tree depth)
	summands[NUM_PP]   = -(1'b1 << (2*MUL_WIDTH));
	summands[NUM_PP+1] = addend1_i;
	summands[NUM_PP+2] = addend2_i;
	
end
  
// relying on synthesis to remove unnecessary CSAs
csa_tree #(
.WIDTH(OUT_WIDTH)
) i_csa_tree (
.op_i(summands),
.sum_o(csa_sum),
.carry_o(csa_carry)
);


Add #(
.width ( OUT_WIDTH ), // word width
.speed ( 2 )  // performance parameter
) i_cpa (
	.A( csa_sum ),  // operands
	.B( csa_carry ),
	.S( result_o )   // sum
);

// final ripple-carry-adder
// assign result_o = csa_sum + csa_carry; 
	
endmodule
