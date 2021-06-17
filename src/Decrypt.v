`include "parameters.vh"

// Decrypts two corresponding points on the elliptic curve into a message point
module Decrypt(
	input [`DATAWIDTH - 1 : 0] secretKey,
	input [`DATAWIDTH - 1 : 0] C1x_in,
	input [`DATAWIDTH - 1 : 0] C1y_in,
	input [`DATAWIDTH - 1 : 0] C2x_in,
	input [`DATAWIDTH - 1 : 0] C2y_in,
	output [`DATAWIDTH - 1 : 0] Mx_out,
	output [`DATAWIDTH - 1 : 0] My_out
	);
	
	// Temporary variables for module chaining
	wire [`DATAWIDTH - 1 : 0] Cpx;
	wire [`DATAWIDTH - 1 : 0] Cpy;
	wire [`DATAWIDTH - 1 : 0] Mx;
	wire [`DATAWIDTH - 1 : 0] My;
	
	// Decryption operations on elliptic curve
	PointMultiplier mulmodule_dec( .n(secretKey), .Qx(C1x_in), .Qy(C1y_in), .Rx_out(Cpx), .Ry_out(Cpy) );
	PointSubtraction submodule_dec( .Px(C2x_in), .Py(C2y_in), .Qx(Cpx), .Qy(Cpy), .Rx_out(Mx), .Ry_out(My) );
	
	// Final point assignment
	assign Mx_out = Mx;
	assign My_out = My;
	
endmodule
