void memcpy(void *src, void *dest, unsigned long long size) {
	long long *bigSrc = (long long*)src;
	long long *bigDest = (long long*)dest;
	long long numLongs = size / 8;
	unsigned char numBytes = size % 8;
	for (unsigned long long i = 0; i < numLongs; i++) {
		bigDest[i] = bigSrc[i];
	}
	char *srcBytes = (char*)(bigSrc + numLongs);
	char *destBytes = (char*)(bigDest + numLongs);
	for (unsigned char i = 0; i < numBytes; i++) {
		destBytes[i] = srcBytes[i];
	}
}
