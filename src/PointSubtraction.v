`include "parameters.vh"

// Subtracts one point from another on the elliptic curve
module PointSubtraction(
	input [`DATAWIDTH - 1 : 0] Px,
	input [`DATAWIDTH - 1 : 0] Py,
	input [`DATAWIDTH - 1 : 0] Qx,
	input [`DATAWIDTH - 1 : 0] Qy,
	output [`DATAWIDTH - 1 : 0] Rx_out,
	output [`DATAWIDTH - 1 : 0] Ry_out
	);
	
	// Temporary variables for point inversion
	wire [`DATAWIDTH - 1 : 0] invQx;
	wire [`DATAWIDTH - 1 : 0] invQy;
	
	// Subtraction equals Addition of inverted point
	PointAdder addmodule( .Px(Px), .Py(Py), .Qx(invQx), .Qy(invQy), .Rx_out(Rx_out), .Ry_out(Ry_out) );
	PointInversion invmodule( .Qx(Qx), .Qy(Qy), .Rx_out(invQx), .Ry_out(invQy) );

endmodule
