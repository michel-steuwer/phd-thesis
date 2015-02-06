/*
 * SIMD-oriented Fast Mersenne-Twister (SFMT) with Box-Muller Transformation
 *
 * SIMD-oriented Fast Mersenne Twister:
 * http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/SFMT/index.html
 * http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/ARTICLES/sfmt.pdf
 *
 * Box-Muller Transformation:
 * http://mathworld.wolfram.com/Box-MullerTransformation.html
 */

/* Special parameters for the linear recursive function. */
#define SHIFT_A 8u
#define SHIFT_B 11u
#define SHIFT_C 8u
#define SHIFT_D 18u

/* Masks represent 128-bit constant of the linear transformation B. */
#define MASK_X 0xbffffff6u
#define MASK_Y 0xbffaffffu
#define MASK_Z 0xddfecb7fu
#define MASK_W 0xdfffffefu

/* Parameter for initialization. */
#define INIT_SHIFT 30u
#define INIT_MULTIPLIER 1812433253u

/* Right shifts given in by shift bits. */
void right_shift128(uint4 in, uint shift, uint4 *out) {
	uint4 tmp = in << (32u - shift);
	*out = (in >> shift) | (uint4)(tmp.y, tmp.z, tmp.w, 0);
}

/* Left shifts given in by shift bits. */
void left_shift128(uint4 in, uint shift, uint4 *out) {
	uint4 tmp = in >> (32u - shift);
	*out = (in << shift) | (uint4)(0, tmp.x, tmp.y, tmp.z);
}

/* Fills variable out with a uniform distributed uint4 */
void fill_uniform_uint4(uint4 *out, uint4 first, uint4 mid, uint4 sec_last, uint4 last) {
	uint4 a, b;

	left_shift128(first, SHIFT_A, &a);
	right_shift128(sec_last, SHIFT_C, &b);

	a ^= first;
	a ^= (mid >> (uint4)(SHIFT_B)) & (uint4)(MASK_X, MASK_Y, MASK_Z, MASK_W);
	a ^= b;
	b = last << (uint4)(SHIFT_D);
	*out = a ^ b;
}

/* Generates an initialization value. */
uint4 generate_init_value_uint4(uint4 s, uint n) {
	return (uint4)(INIT_MULTIPLIER) * (s ^ (s >> (uint4)(INIT_SHIFT))) + (uint4)(n);
}

/* Converts the given uint4 into a standard uniform distributed float4. */
float4 convert_uniform_real(uint4 number) {
	return (convert_float4(number) + 1.0f)  / (UINT_MAX  + 1.0f);
}

/* Transforms the given values into a gaussian (standard normally) distributed float4. */ 
float4 generate_gaussian_real(float4 real) {
	float2 r, phi;

	r 	= sqrt((-2.0f) * log((float2)real.odd));
	phi = 2.0f * M_PI_F * (float2)real.even;

	return (float4)(r * cos(phi), r * sin(phi));
}

/* 
 * Generates 128-bit random numbers,
 * transforms each into 4 32-bit standard normally distributed random numbers.
 */
Seed128 generateGaussianRands(
		Seed128 seed, 				// input 128-bit seed
		__global float4 *numbers, 	// output: matrix with 32-bit random numbers
		uint numbers_column_count,	// matrix dimension
		int m)						// multiplier
{
	int i, pos;
	float4 real;
	// The state array represents the LFSR.
	uint4 state[STATE_SIZE];

	// Initialization of the state array.
	state[0] = (uint4)(seed.x, seed.y, seed.z, seed.w);
	for(i = 1; i < m; ++i)
		state[i] = generate_init_value_uint4(state[i - 1], i);
	// The shift operations of the LFSR.
	for(i = 0; i < m; ++i) { // Simultaneous substitution is simulated.
		fill_uniform_uint4(&state[i],
				state[i], 					// first element
				state[(i + 2) % m], 		// element greater 1 lower n
				state[(i + m - 2) % m], 	// second last element
				state[(i + m - 1) % m]); 	// last element
	}
	// Transformation and write back.
	pos = m * get_global_id(0);
	for(i = 0; i < m; ++i) {
		real = convert_uniform_real(state[i]);
		numbers[pos + i] = generate_gaussian_real(real);
	}

	seed.x = state[m - 1].x;
	seed.y = state[m - 1].y;
	seed.z = state[m - 1].z;
	seed.w = state[m - 1].w;
	return seed;
}

