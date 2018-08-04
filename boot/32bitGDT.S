#ifndef GDT_32
#define GET_32


# GDT starts with null 8 bytes
gdt_start:
	.long 0x0
	.long 0x0

gdt_code:
	.word 0xffff		# segment length bits 0-15
	.word 0x0			# segment base bits 0-15
	.byte 0x0			# segment base bits 16-23
	.byte 0b10011010	# flags (8 bits)
	.byte 0b11001111	# flags (4 bits) + segment length bits 16-19
	.byte 0x0			# segment base bits 24-31

# length and base identical to code segment
# flags different
gdt_data:
	.word 0xffff
	.word 0x0
	.byte 0x0
	.byte 0b10010010
	.byte 0b11001111
	.byte 0x0

gdt_end:

gdt_descriptor:
	.word 0x18	# size
	.long gdt_start					# address

#define CODE_SEG 8
#define DATA_SEG 0x10


#endif
