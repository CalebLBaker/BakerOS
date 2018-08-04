#ifndef PRINT_S
#define PRINT_S


.code16

# Prints the data in the buffer pointed to by bx
# Parameters:
#	bx is the address of the buffer to be printed
# Clobbered:
#	ax		0x0e00
#	bx		Address of null terminator at end of buffer
print:
	movb $0x0e, %ah
	movb (%bx), %al
	cmpb %al, 0
	je printEnd
printRecurse:
	int $0x10
	incw %bx
	movb (%bx), %al
	cmpb $0, %al
	jne printRecurse
printEnd:
	ret
	

# Prints the data in the bx register as a hexidecimal number
# Parameters:
#	bx: the value to be printed
# Clobbered:
#	ax		ASCII value for least signficant hex digit ORed with 0x0e00
printHex:
	movb $0x0e, %ah
	movb %bh, %al
	shrb $4, %al
	call printHexDigit
	movb %bh, %al
	andb $0x0f, %al
	call printHexDigit
	movb %bl, %al
	shrb $4, %al
	call printHexDigit
	movb %bl, %al
	andb $0x0f, %al
	call printHexDigit
	ret


# Prints the value in the al register as a hexidecimal digit
# Parameters:
#	ah: 0x0e
#	al:	the value to be printed
# Clobbered:
#	al		ASCII value for the printed digit
printHexDigit:
	cmpb $9, %al
	jg letter
	addb $0x30, %al
	int $0x10
	ret
letter:
	addb $55, %al
	int $0x10
	ret


# Prints a new line character
# Clobbered:
#	ax
newLine:
	movw $0x0e0a, %ax
	int $0x10
	movb $0xd, %al
	int $0x10
	ret


#endif
