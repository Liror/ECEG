`include "parameters.vh"

// Scalar multiplication helper module
module Multiply(
	input [`DATAWIDTH : 0] a,
	input [`DATAWIDTH : 0] b,
	output [`DATAWIDTH : 0] r
	);

	assign r = a * b;

endmodule

// Scalar division helper module
module Divide(
	input [`DATAWIDTH : 0] a,
	input [`DATAWIDTH : 0] b,
	output [`DATAWIDTH : 0] r
	);

	assign r = a / b;

endmodule
