#define F(x, y, z)	bitselect((z), (y), (x))
#define G(x, y, z)	bitselect((y), (x), (z))
#define H(x, y, z)	(((x) ^ (y)) ^ (z))
#define H2(x, y, z)	((x) ^ ((y) ^ (z)))
#define I(x, y, z)	((y) ^ ((x) | ~(z)))

#define STEP(f, a, b, c, d, x, t, s)	  \
  (a) += f((b), (c), (d)) + (x) + (t); \
  (a) = rotate((a), (uint)(s)); \
  (a) += (b)

union Hash {
  unsigned char bytes[16];
  unsigned int ints[4];
  unsigned long longs[2];
  uint4 vector;
};
typedef union Hash Hash;

inline void md5(unsigned int * hash, const unsigned int * input) {
  hash[0] = 0x67452301;
  hash[1] = 0xefcdab89;
  hash[2] = 0x98badcfe;
  hash[3] = 0x10325476;

  /* Round 1 */
  STEP(F, hash[0], hash[1], hash[2], hash[3], input[0], 0xd76aa478, 7);
  STEP(F, hash[3], hash[0], hash[1], hash[2], input[1], 0xe8c7b756, 12);
  STEP(F, hash[2], hash[3], hash[0], hash[1], input[2], 0x242070db, 17);
  STEP(F, hash[1], hash[2], hash[3], hash[0], input[3], 0xc1bdceee, 22);
  STEP(F, hash[0], hash[1], hash[2], hash[3], input[4], 0xf57c0faf, 7);
  STEP(F, hash[3], hash[0], hash[1], hash[2], input[5], 0x4787c62a, 12);
  STEP(F, hash[2], hash[3], hash[0], hash[1], input[6], 0xa8304613, 17);
  STEP(F, hash[1], hash[2], hash[3], hash[0], input[7], 0xfd469501, 22);
  STEP(F, hash[0], hash[1], hash[2], hash[3], input[8], 0x698098d8, 7);
  STEP(F, hash[3], hash[0], hash[1], hash[2], input[9], 0x8b44f7af, 12);
  STEP(F, hash[2], hash[3], hash[0], hash[1], input[10], 0xffff5bb1, 17);
  STEP(F, hash[1], hash[2], hash[3], hash[0], input[11], 0x895cd7be, 22);
  STEP(F, hash[0], hash[1], hash[2], hash[3], input[12], 0x6b901122, 7);
  STEP(F, hash[3], hash[0], hash[1], hash[2], input[13], 0xfd987193, 12);
  STEP(F, hash[2], hash[3], hash[0], hash[1], input[14], 0xa679438e, 17);
  STEP(F, hash[1], hash[2], hash[3], hash[0], input[15], 0x49b40821, 22);

  /* Round 2 */
  STEP(G, hash[0], hash[1], hash[2], hash[3], input[1], 0xf61e2562, 5);
  STEP(G, hash[3], hash[0], hash[1], hash[2], input[6], 0xc040b340, 9);
  STEP(G, hash[2], hash[3], hash[0], hash[1], input[11], 0x265e5a51, 14);
  STEP(G, hash[1], hash[2], hash[3], hash[0], input[0], 0xe9b6c7aa, 20);
  STEP(G, hash[0], hash[1], hash[2], hash[3], input[5], 0xd62f105d, 5);
  STEP(G, hash[3], hash[0], hash[1], hash[2], input[10], 0x02441453, 9);
  STEP(G, hash[2], hash[3], hash[0], hash[1], input[15], 0xd8a1e681, 14);
  STEP(G, hash[1], hash[2], hash[3], hash[0], input[4], 0xe7d3fbc8, 20);
  STEP(G, hash[0], hash[1], hash[2], hash[3], input[9], 0x21e1cde6, 5);
  STEP(G, hash[3], hash[0], hash[1], hash[2], input[14], 0xc33707d6, 9);
  STEP(G, hash[2], hash[3], hash[0], hash[1], input[3], 0xf4d50d87, 14);
  STEP(G, hash[1], hash[2], hash[3], hash[0], input[8], 0x455a14ed, 20);
  STEP(G, hash[0], hash[1], hash[2], hash[3], input[13], 0xa9e3e905, 5);
  STEP(G, hash[3], hash[0], hash[1], hash[2], input[2], 0xfcefa3f8, 9);
  STEP(G, hash[2], hash[3], hash[0], hash[1], input[7], 0x676f02d9, 14);
  STEP(G, hash[1], hash[2], hash[3], hash[0], input[12], 0x8d2a4c8a, 20);

  /* Round 3 */
  STEP(H, hash[0], hash[1], hash[2], hash[3], input[5], 0xfffa3942, 4);
  STEP(H2, hash[3], hash[0], hash[1], hash[2], input[8], 0x8771f681, 11);
  STEP(H, hash[2], hash[3], hash[0], hash[1], input[11], 0x6d9d6122, 16);
  STEP(H2, hash[1], hash[2], hash[3], hash[0], input[14], 0xfde5380c, 23);
  STEP(H, hash[0], hash[1], hash[2], hash[3], input[1], 0xa4beea44, 4);
  STEP(H2, hash[3], hash[0], hash[1], hash[2], input[4], 0x4bdecfa9, 11);
  STEP(H, hash[2], hash[3], hash[0], hash[1], input[7], 0xf6bb4b60, 16);
  STEP(H2, hash[1], hash[2], hash[3], hash[0], input[10], 0xbebfbc70, 23);
  STEP(H, hash[0], hash[1], hash[2], hash[3], input[13], 0x289b7ec6, 4);
  STEP(H2, hash[3], hash[0], hash[1], hash[2], input[0], 0xeaa127fa, 11);
  STEP(H, hash[2], hash[3], hash[0], hash[1], input[3], 0xd4ef3085, 16);
  STEP(H2, hash[1], hash[2], hash[3], hash[0], input[6], 0x04881d05, 23);
  STEP(H, hash[0], hash[1], hash[2], hash[3], input[9], 0xd9d4d039, 4);
  STEP(H2, hash[3], hash[0], hash[1], hash[2], input[12], 0xe6db99e5, 11);
  STEP(H, hash[2], hash[3], hash[0], hash[1], input[15], 0x1fa27cf8, 16);
  STEP(H2, hash[1], hash[2], hash[3], hash[0], input[2], 0xc4ac5665, 23);

  /* Round 4 */
  STEP(I, hash[0], hash[1], hash[2], hash[3], input[0], 0xf4292244, 6);
  STEP(I, hash[3], hash[0], hash[1], hash[2], input[7], 0x432aff97, 10);
  STEP(I, hash[2], hash[3], hash[0], hash[1], input[14], 0xab9423a7, 15);
  STEP(I, hash[1], hash[2], hash[3], hash[0], input[5], 0xfc93a039, 21);
  STEP(I, hash[0], hash[1], hash[2], hash[3], input[12], 0x655b59c3, 6);
  STEP(I, hash[3], hash[0], hash[1], hash[2], input[3], 0x8f0ccc92, 10);
  STEP(I, hash[2], hash[3], hash[0], hash[1], input[10], 0xffeff47d, 15);
  STEP(I, hash[1], hash[2], hash[3], hash[0], input[1], 0x85845dd1, 21);
  STEP(I, hash[0], hash[1], hash[2], hash[3], input[8], 0x6fa87e4f, 6);
  STEP(I, hash[3], hash[0], hash[1], hash[2], input[15], 0xfe2ce6e0, 10);
  STEP(I, hash[2], hash[3], hash[0], hash[1], input[6], 0xa3014314, 15);
  STEP(I, hash[1], hash[2], hash[3], hash[0], input[13], 0x4e0811a1, 21);
  STEP(I, hash[0], hash[1], hash[2], hash[3], input[4], 0xf7537e82, 6);
  STEP(I, hash[3], hash[0], hash[1], hash[2], input[11], 0xbd3af235, 10);
  STEP(I, hash[2], hash[3], hash[0], hash[1], input[2], 0x2ad7d2bb, 15);
  STEP(I, hash[1], hash[2], hash[3], hash[0], input[9], 0xeb86d391, 21);

  hash[0] += 0x67452301;
  hash[1] += 0xefcdab89;
  hash[2] += 0x98badcfe;
  hash[3] += 0x10325476;
}

//______________________________________________________________________________
// Find the hash for a limited number of targets
//
// Defines:
// CONST_BEGIN {:d} # The index of where the variable part begins
// CONST_END {:d} # The index past of where the variable part ends
// CONST_BASE64_BEGIN {:d} # The index where to base64 encode from (salt length)
// CONST_LENGTH {:d} # The length of the payload (salt + value)
// CONST_LENGTH_ON_CPU {:d} # Decimal places the iterations are substituting
// CONST_TARGET_COUNT {:d} # The number of items in the targets array
//
// targets: Target hashes
// output: Matched values
//______________________________________________________________________________
__kernel void crack(constant Hash * targets,
    global unsigned int * output,
    private const unsigned int prefix) {
  unsigned int index = get_global_id(0);

  // Buffer for the hash
  Hash hash;

  // Zero initialize
  Value value = {};

#ifdef CONST_LENGTH_ON_CPU
  prepare(index, prefix, &value);
#else
  prepare(index, &value);
#endif

  // %%PREFIX%%

#ifdef CONST_BASE64_BEGIN
  // %%XOR%%
  to_base64(&value);
#endif

  // Inject size
  value.longs[7] = CONST_LENGTH << 3;

  // Inject padding
  value.bytes[CONST_LENGTH] = 0x80;

  // Actually cracking
  md5(hash.ints, value.ints);

#if CONST_TARGET_COUNT < 32
#pragma unroll
  for (int i = 0; i < CONST_TARGET_COUNT; i++) {
    if (hash.longs[0] == targets[i].longs[0] && hash.longs[1] == targets[i].longs[1]) {
      output[i << 1] = index;
      output[(i << 1) + 1] = prefix;
      return;
    }
  }
#else
  unsigned int i = 0;
  while (i < CONST_TARGET_COUNT) {
    if (hash.longs[1] == targets[i].longs[1]) {
      if (hash.longs[0] == targets[i].longs[0]) {
        output[i << 1] = index;
        output[(i << 1) + 1] = prefix;
        return;
      } else {
        i = hash.longs[0] < targets[i].longs[0]
          ? (i << 1) + 1
          : (i << 1) + 2;
      }
    } else {
      i = hash.longs[1] < targets[i].longs[1]
        ? (i << 1) + 1
        : (i << 1) + 2;
    }
  }
#endif //#if CONST_TARGET_COUNT
}
