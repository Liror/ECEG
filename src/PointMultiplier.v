`include "parameters.vh"

// Multiplies a point on the elliptic curve with a scalar
module PointMultiplier(
	input [`DATAWIDTH - 1 : 0] n,
	input [`DATAWIDTH - 1 : 0] Qx,
	input [`DATAWIDTH - 1 : 0] Qy,
	output [`DATAWIDTH - 1 : 0] Rx_out,
	output [`DATAWIDTH - 1 : 0] Ry_out
	);
	
	// Temporary variables for Double-and-Add cascade
	genvar i;
	wire [`DATAWIDTH - 1 : 0] Qx_arr [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] Qy_arr [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp1X_arr [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp1Y_arr [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp2X_arr [0:`DATAWIDTH];
	wire [`DATAWIDTH - 1 : 0] tmp2Y_arr [0:`DATAWIDTH];
	
	// Point at infinity as default
	assign Qx_arr[`DATAWIDTH] = `DATAWIDTH'b0;
	assign Qy_arr[`DATAWIDTH] = `DATAWIDTH'b0;
	
	// Unrolled Double-and-Add cascade
	generate
		for(i=`DATAWIDTH; i>0; i=i-1) begin : gen_loop
			PointAdder addmoduleA( .Px(Qx_arr[i]), .Py(Qy_arr[i]), .Qx(Qx_arr[i]), .Qy(Qy_arr[i]), .Rx_out(tmp1X_arr[i]), .Ry_out(tmp1Y_arr[i]) );
			PointAdder addmoduleB( .Px(tmp1X_arr[i]), .Py(tmp1Y_arr[i]), .Qx(Qx), .Qy(Qy), .Rx_out(tmp2X_arr[i]), .Ry_out(tmp2Y_arr[i]) );
			assign Qx_arr[i-1] = n[i-1] ? tmp2X_arr[i] : tmp1X_arr[i];
			assign Qy_arr[i-1] = n[i-1] ? tmp2Y_arr[i] : tmp1Y_arr[i];
		end
	endgenerate
	
	// Final values are multiplication result
	assign Rx_out = Qx_arr[0];
	assign Ry_out = Qy_arr[0];
	
endmodule
