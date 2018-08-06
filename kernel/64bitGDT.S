#ifndef GDT_64
#define GDT_64


GDT64:

#define Null 0
	.word 0xffff				# Limit (low)
	.word 0					# Base (low)
	.byte 0					# Base (middle)
	.byte 0					# Access
	.byte 1					# Granularity
	.byte 0					# Base (high)

#define Code 8
	.word 0					# Limit (low)
	.word 0					# Base (low)
	.byte 0					# Base (middle)
	.byte 0b10011010			# Access (exec/read).
	.byte 0b10101111			# Granularity, 64 bit flag, limit19:16
	.byte 0					# Base (high)

#define Data 0x10
	.word 0					# Limit (low)
	.word 0					# Base (low)
	.byte 0					# Base (middle)
	.byte 0b10010010			# Access (read/write)
	.byte 0b00000000			# Granularity
	.byte 0					# Base (high)

.Pointer:				# GDT pointer
	.word 0x17			# Limit
	.quad GDT64				# Base


#endif
