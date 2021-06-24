`timescale 1ns / 1ps
`include "parameters.vh"

//////////////////////////////////////////////////////////////////////////////////
// Company: University of Stuttgart
// Engineer: Lukas Rauch
// 
// Create Date: 06/24/2021 12:58:11 PM
// Design Name: ECEG
// Module Name: simulation
// Project Name: Elliptic Curve ElGamal cryptosystem
// Description: Testbench to verify that decrypt(encrypt(M))=M
// Dependencies: unrolled ECEG cryptosystem
// 
//////////////////////////////////////////////////////////////////////////////////

module simulation();
wire [`DATAWIDTH-1:0] M;
wire check;

    // Instance of cryptosystem for test
    Top crypto(.test(M), .check(check));

    // Simulation values
    initial begin
        #1000; // wait for 1000 time steps
        $finish;
    end
    
endmodule
