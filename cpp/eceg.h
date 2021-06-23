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
		eceg(uint32_t bitlength, uint32_t fibonacci, T p, T A, T B)
		{
			this->bitlength = bitlength;
			this->fibonacci = fibonacci;
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
		
		// Point Adder (as copied from Verilog)
		void PointAdder(T Px, T Py, T Qx, T Qy, T& Rx, T& Ry)
		{
			T invQx=0, invQy=0;
			PointInversion(Qx, Qy, invQx, invQy);

			T lam_sub1=0, lam_sub2=0, lam_mul1=0, lam_mul2=0, lam_mul3, lam_add=0, lambda=0;
			ModSub(Qy, Py, lam_sub1);
			ModSub(Qx, Px, lam_sub2);
			ModMul(Px, Px, lam_mul1);
			ModMul(3, lam_mul1, lam_mul2);
			ModAdd(lam_mul2, this->A, lam_add);
			ModMul(2, Py, lam_mul3);
			T div_opA = (Px != Qx || Py != Qy) ? lam_sub1 : lam_add;
			T div_opB = (Px != Qx || Py != Qy) ? lam_sub2 : lam_mul3;
			ModDiv(div_opA, div_opB, lambda);

			T out_mul1=0, out_mul2=0, out_sub1=0, out_sub2=0, out_sub3=0, out_sub4=0;
			ModMul(lambda, lambda, out_mul1);
			ModSub(out_mul1, Px, out_sub1);
			ModSub(out_sub1, Qx, out_sub2);
			Rx = (Px == 0 && Py == 0) ? Qx
			   : (Qx == 0 && Qy == 0) ? Px
			   : (Px == invQx && Py == (invQy)) ? 0
			   : out_sub2;
			ModSub(Px, Rx, out_sub3);
			ModMul(lambda, out_sub3, out_mul2);
			ModSub(out_mul2, Py, out_sub4);
			Ry = (Px == 0 && Py == 0) ? Qy
			   : (Qx == 0 && Qy == 0) ? Py
			   : (Px == invQx && Py == (invQy)) ? 0
			   : out_sub4;
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
		uint32_t fibonacci;
		
		// Helperfunction - Modular addition (as copied from Verilog with minor modifications)
		void ModAdd(T a, T b, T& r)
		{
			T tmp = a + b - this->p;
			r = ((a + b) < this->p && (a + b) >= a) ? tmp + this->p : tmp;
		}
		
		// Helperfunction - Modular subtraction (as copied from Verilog with minor modifications)
		void ModSub(T a, T b, T& r)
		{
			T tmp = a - b;
			r = (b > a) ? tmp + this->p : tmp;
		}
		
		// Helperfunction - Modular multiplication (as copied from Verilog with modifications)
		void ModMul(T a, T b, T& r)
		{
			T tmp = 0, tmp3 = 0;
			for(uint32_t i=this->bitlength; i>0; --i) {
				T tmp1 = (tmp << 1) - this->p;
				T tmp2 = ((tmp+tmp) < this->p && (tmp+tmp) >= tmp) ? tmp1 + this->p : tmp1;
				ModAdd(tmp2, b, tmp3);
				if((a >> (i-1)) & 1)
					tmp = tmp3;
				else
					tmp = tmp2;
			}
			r = tmp;
		}
		
		// Helperfunction - Modular division (as copied from Verilog)
		void ModDiv(T a, T b, T& r)
		{
			T inv = 0;
			ModInv(b, inv);
			ModMul(a, inv, r);
		}
		
		// Helperfunction - Inversion (extended euclidian algorithm) (as copied from Verilog with minor modifications)
		void ModInv(T a, T& r)
		{
			T t=0, newt=1, quot=0, unused=0, tmp1=0, tmp2=0;
			T s = this->p, news = a;
			for(uint32_t i=0; i<this->fibonacci; ++i) {
				Divide(s, news, quot, unused);
				Multiply(quot, newt, tmp1);
				Multiply(quot, news, tmp2);
				tmp1 = t - tmp1;
				tmp2 = s - tmp2;
				t = (news == 0) ? t : newt;
				newt = (news == 0) ? newt : tmp1;
				s = (news == 0) ? s : news;
				news = (news == 0) ? news : tmp2;
			}
			r = (t < 0 || t >= this->p) ? t + this->p : t;
		}

		// Helperfunction - scalar multiplication (as modified from Verilog)
		// IMPORTANT: for loop must run through all bits of the datatype T, not just the used ones!
		void Multiply(T a, T b, T& r)
		{
			T tmp = (b & 1) ? a : 0;
			for(uint32_t i=1; i<sizeof(T)*8; ++i)
				tmp += ((b>>i) & 1) ? (a << i) : 0;
			r = tmp;
		}

		// Helperfunction - scalar division (as copied from Verilog)
		void Divide(T a, T b, T& q, T& r)
		{
			T tmpR1 = 0, tmpR2 = 0, tmpQ = 0;
			for(uint32_t i=this->bitlength; i>0; --i) {
				tmpR1 = (tmpR2<<1) | ((a>>i)&1);
				tmpR2 = tmpR1 >= b ? tmpR1 - b : tmpR1;
				tmpQ |= (tmpR1 >= b ? 1 : 0) << i;
			}
			tmpR1 = (tmpR2<<1) | ((a>>0)&1);
			tmpR2 = tmpR1 >= b ? tmpR1 - b : tmpR1;
			tmpQ |= (tmpR1 >= b ? 1 : 0) << 0;
			q = (b==0) ? 0 : tmpQ;
			r = (b==0) ? 0 : tmpR2;
		}

};
