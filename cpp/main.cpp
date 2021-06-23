// main.cpp: Testbench file for EllipticCurve ElGamal cryptosystem

// Parameters for Elliptic Curve with 15 bits
#define _DATAWIDTH 15
#define _FIBONACCI 24
#define _p 32003
#define _A 18786
#define _B 12857
#define _Px 16533
#define _Py 31897
#define _Mx0 16775
#define _My0 20887
#define _secretKey 23413
#define _k 15321

// Headers
#include <cstdio>
#include "eceg.h"

// Datatype for elliptic cirve handling
// Must support the following operations:
// + - * / = >> & == >= != (cast from uint32_t)
// Also needs to be one bit wider than _DATAWIDTH
typedef uint32_t __DATATYPE__;

// Main testbench
int main(int argc, char* argv[])
{
	// Create cryptosystem
	eceg<__DATATYPE__> crypto(_DATAWIDTH, _FIBONACCI, _p, _A, _B);
	
	// Prepare variables
	__DATATYPE__ Yx = 0, Yy = 0;
	__DATATYPE__ C1x = 0, C1y = 0;
	__DATATYPE__ C2x = 0, C2y = 0;
	__DATATYPE__ Mx = 0, My = 0;

	// Compute public key Y as Y=secretKey*P
	crypto.PointMultiplier(_secretKey, _Px, _Py, Yx, Yy);

	// Use k, P & Y to encrypt message M0 to C1 & C2
	crypto.encrypt(_k, _Px, _Py, Yx, Yy, _Mx0, _My0, C1x, C1y, C2x, C2y);

	// Use secretKey, C1 & C2 to decrypt to message M
	crypto.decrypt(_secretKey, C1x, C1y, C2x, C2y, Mx, My);

	// Compare original message M0 with decrypted message M
	if(Mx == _Mx0 && My == _My0)
		printf("success!\n");
	else
		printf("fail!\n");
	return 0;
}
