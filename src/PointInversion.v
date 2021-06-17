`include "parameters.vh"

// Inverts a point on the elliptic curve
module PointInversion(
	input [`DATAWIDTH - 1 : 0] Qx,
	input [`DATAWIDTH - 1 : 0] Qy,
	output [`DATAWIDTH - 1 : 0] Rx_out,
	output [`DATAWIDTH - 1 : 0] Ry_out
	);
	
	// Inverted point is mirrored at the x-axis
	assign Rx_out = Qx;
	assign Ry_out = `p - Qy; // -Qy MOD p
	
endmodule
