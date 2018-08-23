#include <stdint.h>
#include "string.h"


void memcpy(void *dest, void *src, size_t size) {
	uint64_t *bigSrc = (uint64_t*)src;
	uint64_t *bigDest = (uint64_t*)dest;
	uint64_t numLongs = size / 8;
	uint8_t numBytes = size % 8;
	for (uint64_t i = 0; i < numLongs; i++) {
		bigDest[i] = bigSrc[i];
	}
	uint8_t *srcBytes = (uint8_t*)(bigSrc + numLongs);
	uint8_t *destBytes = (uint8_t*)(bigDest + numLongs);
	for (uint8_t i = 0; i < numBytes; i++) {
		destBytes[i] = srcBytes[i];
	}
}


void memmove(void *dest, void *src, size_t size) {
	uint64_t *bigSrc = (uint64_t*)src;
	uint64_t *bigDest = (uint64_t*)dest;
	uint64_t numLongs = size / 8;
	uint8_t numBytes = size % 8;
	uint8_t *srcBytes = (uint8_t*)(bigSrc + numLongs);
	uint8_t *destBytes = (uint8_t*)(bigDest + numLongs);
	if (src > dest) {
		for (uint64_t i = 0; i < numLongs; i++) {
			bigDest[i] = bigSrc[i];
		}
		for (uint8_t i = 0; i < numBytes; i++) {
			destBytes[i] = srcBytes[i];
		}
	}
	else {
		for (int8_t i = numBytes - 1; i >= 0; i--) {
			destBytes[i] = srcBytes[i];
		}
		for (int64_t i = numLongs - 1; i >= 0; i--) {
			bigDest[i] = bigSrc[i];
		}
	}
}
