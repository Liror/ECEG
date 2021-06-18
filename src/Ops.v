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
	output [`DATAWIDTH : 0] r
	);

	
	
	
	
	
	
	
	// TBD: Implement one-cycle integer division algorithm
	// [idea like written division?]
	
	
	
	
	
	
	
	
	
	
	// Temporary -> use Megafunction
	assign r = a / b;

endmodule
