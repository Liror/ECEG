// eceg.h: Implementation of parameterized EllipticCurve ElGamal cryptosystem
// https://crypto.stackexchange.com/questions/9987/elgamal-with-elliptic-curves
// https://github.com/n-elhamawy/ueca-based-eceg

/////////////
// Headers //
/////////////

#include <cstdint>

//////////////////////
// Class definition //
//////////////////////

template<class T>
class eceg {
	public:
		// Basic functions
		eceg(uint32_t bitlength, T p, T A, T B)
		{
			this->bitlength = bitlength;
			this->p = p;
			this->A = A;
			this->B = B;
		}
		~eceg() { }

		// Encryption module (as copied from Verilog)
		void encrypt(T k, T Px, T Py, T Yx, T Yy, T Mx, T My, T& C1x, T& C1y, T& C2x, T& C2y)
		{
			T Cx = 0, Cy = 0;
			T Cpx = 0, Cpy = 0;
			T Dx = 0, Dy = 0;
			PointMultiplier(k, Px, Py, Cx, Cy);
			PointMultiplier(k, Yx, Yy, Cpx, Cpy);
			PointAdder(Cpx, Cpy, Mx, My, Dx, Dy);
			C1x = Cx;
			C1y = Cy;
			C2x = Dx;
			C2y = Dy;
		}

		// Decryption Module (as copied from Verilog)
		void decrypt(T secretKey, T C1x, T C1y, T C2x, T C2y, T& Mx, T& My)
		{
			T Cpx = 0, Cpy = 0;
			PointMultiplier(secretKey, C1x, C1y, Cpx, Cpy);
			PointSubtraction(C2x, C2y, Cpx, Cpy, Mx, My);
		}
		
		// Point Multiplier (as copied from Verilog with minor modifications)
		void PointMultiplier(T n, T Qx, T Qy, T& Rx, T& Ry)
		{
			T tmpX = 0, tmpY = 0;
			for(uint32_t i=this->bitlength; i>0; --i) {
				T tmp1X = 0, tmp1Y = 0;
				PointAdder(tmpX, tmpY, tmpX, tmpY, tmp1X, tmp1Y);
				if((n >> (i-1)) & 1) {
					T tmp2X = 0, tmp2Y = 0;
					PointAdder(tmp1X, tmp1Y, Qx, Qy, tmp2X, tmp2Y);
					tmpX = tmp2X;
					tmpY = tmp2Y;
				}
				else {
					tmpX = tmp1X;
					tmpY = tmp1Y;
				}
			}
			Rx = tmpX;
			Ry = tmpY;
		}
		
		// Point Adder (as copied from Verilog with modifications)
		void PointAdder(T Px, T Py, T Qx, T Qy, T& Rx, T& Ry)
		{
			T invQx = 0, invQy = 0;
			PointInversion(Qx, Qy, invQx, invQy);
			if(Px == 0 && Py == 0) {
				Rx = Qx;
				Ry = Qy;
			}
			else if(Qx == 0 && Qy == 0) {
				Rx = Px;
				Ry = Py;
			}
			else if(Px == invQx && Py == invQy) {
				Rx = 0;
				Ry = 0;
			}
			else {
				T lambda = (Px != Qx || Py != Qy) ? mod_div(mod_sub(Qy, Py), mod_sub(Qx, Px))
				         : mod_div(mod_add(mod_mul(3, mod_mul(Px, Px)), this->A), mod_mul(2, Py));
				Rx = mod_sub(mod_sub(mod_mul(lambda, lambda), Px), Qx);
				Ry = mod_sub(mod_mul(lambda, mod_sub(Px, Rx)), Py);
			}
		}

		// Point Subtractor (as copied from Verilog)
		void PointSubtraction(T Px, T Py, T Qx, T Qy, T& Rx, T& Ry)
		{
			T invQx = 0, invQy = 0;
			PointInversion(Qx, Qy, invQx, invQy);
			PointAdder(Px, Py, invQx, invQy, Rx, Ry);
		}

		// Point Inversion (as copied from Verilog)
		void PointInversion(T Qx, T Qy, T& Rx, T& Ry)
		{
			Rx = Qx;
			Ry = this->p - Qy;
		}

	private:
		// Private curve variables
		T p;
		T A, B;
		uint32_t bitlength;
		
		// Helperfunction - Modular addition (modified from Verilog)
		T mod_add(T a, T b) {
			return ((a + b) >= this->p || (a + b) < a) ? a + b - this->p : a + b;
		}
		
		// Helperfunction - Modular subtraction (modified from Verilog)
		T mod_sub(T a, T b) {
			return mod_add(a, this->p - b);
		}
		
		// Helperfunction - Modular multiplication (as copied from Verilog with modifications)
		// ==> Rework using Montgomery multiplication instead of Double and Add?
		T mod_mul(T a, T b) {
			T tmp = 0;
			for(uint32_t i=this->bitlength; i>0; --i) {
				T tmp1 = mod_add(tmp, tmp);
				if((a >> (i-1)) & 1)
					tmp = mod_add(tmp1, b);
				else
					tmp = tmp1;
			}
			return tmp;
		}
		
		// Helperfunction - Modular division (modified from Verilog)
		T mod_div(T a, T b) {
			return mod_mul(a, mod_inv(b));
		}
		
		// Helperfunction - Inversion (extended euclidian algorithm)
		// ==> Needs multiplier & divisor module without modulus in Verilog
		T mod_inv(T a) {
			T t = 0, newt = 1;
			T r = this->p, newr = a;

			while(newr != 0) {
				T quot = r / newr;
				T tmp = t - quot*newt;
				t = newt;
				newt = tmp;
				tmp = r - quot*newr;
				r = newr;
				newr = tmp;
			}

			if(r > 1)
				throw "Number is not invertible, this is impossible in a prime-ring!";
			else if(t < 0 || t >= this->p)
				t += this->p;
			return t;
		}
};
