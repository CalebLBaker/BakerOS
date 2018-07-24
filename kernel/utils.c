#include "utils.h"


void memcpy(void *src, void *dest, uint64 size) {
	uint64 *bigSrc = (uint64*)src;
	uint64 *bigDest = (uint64*)dest;
	uint64 numLongs = size / 8;
	uint8 numBytes = size % 8;
	for (uint64 i = 0; i < numLongs; i++) {
		bigDest[i] = bigSrc[i];
	}
	uint8 *srcBytes = (uint8*)(bigSrc + numLongs);
	uint8 *destBytes = (uint8*)(bigDest + numLongs);
	for (uint8 i = 0; i < numBytes; i++) {
		destBytes[i] = srcBytes[i];
	}
}
