`include "parameters.vh"

// Encrypts a message point on the elliptic curve into two points
module Encrypt(
	input [`DATAWIDTH - 1 : 0] k,
	input [`DATAWIDTH - 1 : 0] Px,
	input [`DATAWIDTH - 1 : 0] Py,
	input [`DATAWIDTH - 1 : 0] Yx,
	input [`DATAWIDTH - 1 : 0] Yy,
	input [`DATAWIDTH - 1 : 0] Mx_in,
	input [`DATAWIDTH - 1 : 0] My_in,
	output [`DATAWIDTH - 1 : 0] C1x_out,
	output [`DATAWIDTH - 1 : 0] C1y_out,
	output [`DATAWIDTH - 1 : 0] C2x_out,
	output [`DATAWIDTH - 1 : 0] C2y_out
	);
	
	// Temporary point variables for module chaining
	wire [`DATAWIDTH - 1 : 0] Cx;
	wire [`DATAWIDTH - 1 : 0] Cy;
	wire [`DATAWIDTH - 1 : 0] Cpx;
	wire [`DATAWIDTH - 1 : 0] Cpy;
	wire [`DATAWIDTH - 1 : 0] Dx;
	wire [`DATAWIDTH - 1 : 0] Dy;
	
	// Encryption operations on elliptic curve
	PointMultiplier mulmoduleA( .n(k), .Qx(Px), .Qy(Py), .Rx_out(Cx), .Ry_out(Cy) );
	PointMultiplier mulmoduleB( .n(k), .Qx(Yx), .Qy(Yy), .Rx_out(Cpx), .Ry_out(Cpy) );
	PointAdder addmodule( .Px(Cpx), .Py(Cpy), .Qx(Mx_in), .Qy(My_in), .Rx_out(Dx), .Ry_out(Dy) );
	
	// Final point assignment
	assign C1x_out = Cx;
	assign C1y_out = Cy;
	assign C2x_out = Dx;
	assign C2y_out = Dy;
	
endmodule
