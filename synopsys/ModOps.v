`include "parameters.vh"

// Scalar addition modulo p helper module
module ModAdd(
	input [`DATAWIDTH - 1 : 0] a,
	input [`DATAWIDTH - 1 : 0] b,
	output [`DATAWIDTH - 1 : 0] r
	);

	// Addition and modulo if necessary
	wire [`DATAWIDTH : 0] tmp;
	assign tmp = a + b - `p;
	assign r = tmp[`DATAWIDTH] ? (tmp[`DATAWIDTH-1:0] + `p) : tmp[`DATAWIDTH-1:0];

endmodule

// Scalar subtraction modulo p helper module
module ModSub(
	input [`DATAWIDTH - 1 : 0] a,
	input [`DATAWIDTH - 1 : 0] b,
	output [`DATAWIDTH - 1 : 0] r
	);

	// Subtraction and modulo if necessary
	wire [`DATAWIDTH : 0] tmp;
	assign tmp = {1'b0, a} - {1'b0, b};
	assign r = tmp[`DATAWIDTH] ? (tmp[`DATAWIDTH-1:0] + `p) : tmp[`DATAWIDTH-1:0];

endmodule

// Scalar multiplication modulo p helper module
module ModMul(
	input [`DATAWIDTH - 1 : 0] a,
	input [`DATAWIDTH - 1 : 0] b,
	output [`DATAWIDTH - 1 : 0] r
	);

	// Temporary variables for cascade
	wire [`DATAWIDTH - 1 : 0] tmp [0:`DATAWIDTH];
	wire [`DATAWIDTH : 0] tmp1 [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp2 [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp3 [0:`DATAWIDTH];
	genvar i;
		
	// Using Double-and-Add cascade for scalar multiplication
	assign tmp[`DATAWIDTH] = `DATAWIDTH'b0;
	generate
		for(i=`DATAWIDTH; i>0; i=i-1) begin : ModMul_loop
			assign tmp1[i] = {tmp[i], 1'b0} - `p;
			assign tmp2[i] = tmp1[i][`DATAWIDTH] ? (tmp1[i][`DATAWIDTH-1:0] + `p) : tmp1[i][`DATAWIDTH-1:0];
			ModAdd adder_mulB( .a(tmp2[i]), .b(b), .r(tmp3[i]) );
			assign tmp[i-1] = a[i-1] ? tmp3[i] : tmp2[i];
		end
	endgenerate
	assign r = tmp[0];

endmodule

// Scalar division modulo p helper module
module ModDiv(
	input [`DATAWIDTH - 1 : 0] a,
	input [`DATAWIDTH - 1 : 0] b,
	output [`DATAWIDTH - 1 : 0] r
	);
	
	// Division as inversion and multiplication
	wire [`DATAWIDTH - 1 : 0] inv;
	ModMul multiplier_div( .a(a), .b(inv), .r(r) );
	ModInv inverter_div( .a(b), .r(inv) );

endmodule

// Scalar inversion modulo p helper module
module ModInv(
	input [`DATAWIDTH - 1 : 0] a,
	output [`DATAWIDTH - 1 : 0] r
	);
	
	// Temporary variables for algorithm loop
	wire [`DATAWIDTH : 0] t [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] newt [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] s [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] news [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] quot [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] tmp1 [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] tmp2 [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] unused [0:`FIBONACCI];
	wire [`DATAWIDTH : 0] result;
	genvar i;
	
	// Initial conditions for algorithm loop
	assign t[0] = 0;
	assign newt[0] = 1;
	assign s[0] = {1'b0, `p};
	assign news[0] = { 1'b0, a};
	
	// Extended euclidian algorithm
	// Generate enough loop-cycles up to the first Fibonacci number > 2^DATAWIDTH
	// This ensures proper termination of the algorithm
	generate
		for(i=0; i<`FIBONACCI; i=i+1) begin : ModInv_loop
			Divide scalar_div( .a(s[i]), .b(news[i]), .q(quot[i]), .r(unused[i]) );
			Multiply scalar_mulA( .a(quot[i]), .b(newt[i]), .r(tmp1[i]) );
			Multiply scalar_mulB( .a(quot[i]), .b(news[i]), .r(tmp2[i]) );
			assign t[i+1] = (news[i] == `DATAWIDTH'b0) ? t[i] : newt[i];
			assign newt[i+1] = (news[i] == `DATAWIDTH'b0) ? newt[i] : (t[i] - tmp1[i]);
			assign s[i+1] = (news[i] == `DATAWIDTH'b0) ? s[i] : news[i];
			assign news[i+1] = (news[i] == `DATAWIDTH'b0) ? news[i] : (s[i] - tmp2[i]);
		end
	endgenerate
	
	// Possibly modulo adjust result
	assign result = t[`FIBONACCI];
	assign r = result[`DATAWIDTH] ? result[`DATAWIDTH-1:0] + `p : result[`DATAWIDTH-1:0];
	
endmodule
