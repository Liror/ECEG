`include "parameters.vh"

// Adds two points on the elliptic curve
module PointAdder(
	input [`DATAWIDTH - 1 : 0] Px,
	input [`DATAWIDTH - 1 : 0] Py,
	input [`DATAWIDTH - 1 : 0] Qx,
	input [`DATAWIDTH - 1 : 0] Qy,
	output [`DATAWIDTH - 1 : 0] Rx_out,
	output [`DATAWIDTH - 1 : 0] Ry_out
	);
	
	// Temporary variables for addition
	wire [`DATAWIDTH - 1 : 0] invQx;
	wire [`DATAWIDTH - 1 : 0] invQy;
	wire [`DATAWIDTH - 1 : 0] lambda;
	
	// Inversion to check for mirrored points
	PointInversion invmodule( .Qx(Qx), .Qy(Qy), .Rx_out(invQx), .Ry_out(invQy) );
	
	// Calculate slope between points
	wire [`DATAWIDTH - 1 : 0] lam_sub1, lam_sub2, lam_div1, lam_div2, lam_mul1, lam_mul2, lam_mul3, lam_add;
	ModSub submodule1( .a(Qy), .b(Py), .r(lam_sub1) );
	ModSub submodule2( .a(Qx), .b(Px), .r(lam_sub2) );
	ModDiv divisor1( .a(lam_sub1), .b(lam_sub2), .r(lam_div1) );
	ModMul multiplier1( .a(Px), .b(Px), .r(lam_mul1) );
	ModMul multiplier2( .a(`DATAWIDTH'd3), .b(lam_mul1), .r(lam_mul2) );
	ModAdd adder1( .a(lam_mul2), .b(`A), .r(lam_add) );
	ModMul multiplier3( .a(`DATAWIDTH'd2), .b(Py), .r(lam_mul3) );
	ModDiv divisor2( .a(lam_add), .b(lam_mul3), .r(lam_div2) );
	assign lambda = (Px != Qx || Py != Qy) ? lam_div1 : lam_div2;
					  
	// Calculate new point coordinates
	wire [`DATAWIDTH - 1 : 0] out_sub1, out_sub2, out_sub3, out_sub4, out_mul1, out_mul2;
	ModMul multiplier4( .a(lambda), .b(lambda), .r(out_mul1) );
	ModSub submodule3( .a(out_mul1), .b(Px), .r(out_sub1) );
	ModSub submodule4( .a(out_sub1), .b(Qx), .r(out_sub2) );
	ModSub submodule5( .a(Px), .b(Rx_out), .r(out_sub3) );
	ModMul multiplier5( .a(lambda), .b(out_sub3), .r(out_mul2) );
	ModSub submodule6( .a(out_mul2), .b(Py), .r(out_sub4) );
	assign Rx_out = (Px == `DATAWIDTH'b0 && Py == `DATAWIDTH'b0) ? Qx
	              : (Qx == `DATAWIDTH'b0 && Qy == `DATAWIDTH'b0) ? Px
	              : (Px == invQx && Py == (invQy)) ? `DATAWIDTH'b0
	              : out_sub2;
	assign Ry_out = (Px == `DATAWIDTH'b0 && Py == `DATAWIDTH'b0) ? Qy
	              : (Qx == `DATAWIDTH'b0 && Qy == `DATAWIDTH'b0) ? Py
	              : (Px == invQx && Py == (invQy)) ? `DATAWIDTH'b0
	              : out_sub4;
	
endmodule
