`include "parameters.vh"

// Scalar multiplication helper module
module Multiply(
	input [`DATAWIDTH : 0] a,
	input [`DATAWIDTH : 0] b,
	output [`DATAWIDTH : 0] r
	);
	
	// Temporary variables for cascade
	genvar i;
	wire [`DATAWIDTH : 0] tmp [0:`DATAWIDTH];
	assign tmp[0] = b[0] ? a[`DATAWIDTH:0] : `DATAWIDTH'b0;

	// Multiply by shifting and adding cascade
	generate
		for(i=1; i<=`DATAWIDTH; i=i+1) begin : multiply_loop
			assign tmp[i] = tmp[i-1] + (b[i] ? (a << i) : `DATAWIDTH'b0);
		end
	endgenerate
	assign r = tmp[`DATAWIDTH];
endmodule

// Scalar division helper module
module Divide(
	input [`DATAWIDTH : 0] a,
	input [`DATAWIDTH : 0] b,
	output [`DATAWIDTH : 0] q,
	output [`DATAWIDTH : 0] r
	);

	// Temporary variables for cascade
	genvar i;
	wire [`DATAWIDTH : 0] tmpQ;
	wire [`DATAWIDTH : 0] tmpR1 [0:`DATAWIDTH];
	wire [`DATAWIDTH : 0] tmpR2 [0:`DATAWIDTH+1];
	assign tmpR2[`DATAWIDTH+1] = 0;
	
	// Integer long division cascade
	generate
		for(i=`DATAWIDTH; i>=0; i=i-1) begin : division_loop
			assign tmpR1[i] = { tmpR2[i+1][`DATAWIDTH-1:0], a[i:i] };
			assign tmpR2[i] = tmpR1[i] >= b ? tmpR1[i] - b : tmpR1[i];
			assign tmpQ[i:i] = tmpR1[i] >= b ? 1'b1 : 1'b0;
		end
	endgenerate
	
	// Quotient and remainder assignment
	assign q = (b == 0) ? `DATAWIDTH'b0 : tmpQ;
	assign r = (b == 0) ? `DATAWIDTH'b0 : tmpR2[0];

endmodule
