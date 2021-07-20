`include "parameters.vh"

// Top level module for ECEG cryptosystem and test
module Top(output [`DATAWIDTH-1:0] test, output wire check);

	// Temporary variables for module chaining
	wire [`DATAWIDTH - 1 : 0] Yx;
	wire [`DATAWIDTH - 1 : 0] Yy;
	wire [`DATAWIDTH - 1 : 0] C1x;
	wire [`DATAWIDTH - 1 : 0] C1y;
	wire [`DATAWIDTH - 1 : 0] C2x;
	wire [`DATAWIDTH - 1 : 0] C2y;
	wire [`DATAWIDTH - 1 : 0] Mx;
	wire [`DATAWIDTH - 1 : 0] My;
	
	// Preparation of public key Y = secretKey*P from parameters
	PointMultiplier mulmodule_pubkey( .n(`secretKey), .Qx(`Px), .Qy(`Py), .Rx_out(Yx), .Ry_out(Yy) );
	
	// Encryption module
	Encrypt encryptionmodule(
		.k(`k),
		.Px(`Px),
		.Py(`Py),
		.Yx(Yx),
		.Yy(Yy),
		.Mx_in(`Mx0),
		.My_in(`My0),
		.C1x_out(C1x),
		.C1y_out(C1y),
		.C2x_out(C2x),
		.C2y_out(C2y)
	);
	
	// Decryption module
	Decrypt decryptionmodule(
		.secretKey(`secretKey),
		.C1x_in(C1x),
		.C1y_in(C1y),
		.C2x_in(C2x),
		.C2y_in(C2y),
		.Mx_out(Mx),
		.My_out(My)
	);
	
	// Comparisson for working cryptosystem
	assign check = (Mx == `Mx0) && (My == `My0);
	assign test = Mx;
	
endmodule
