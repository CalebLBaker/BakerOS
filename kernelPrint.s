.section .text


# Print a string to a given address in video memory
# Parameters
#	rdi		The address of the string to print
#	rsi		The address in video memory to print the string to
.globl printTargeted
.type printTargeted, @function
printTargeted:
	movq %rsi, %rax
	jmp printEnter
	


# Print a string to the current cursor position
# Parameters
#	rdi		The address of the string to print
# Return value
#	rax		New address of cursor
.globl print
.type print, @function
print:

	# Load high byte of cursor position into VGA register
	movq $0xe, %rax
	movw $0x3d4, %dx
	out %al, %dx

	# Copy VGA register to cl
	incw %dx
	in %dx, %al
	movb %al, %cl

	# Load low byte of cursor position into VGA register
	movb $0xf, %al
	decw %dx
	out %al, %dx

	# Copy VGA register to al
	incw %dx
	in %dx, %al

	# Set eax to cursor address
	movb %cl, %ah
	shll $1, %eax
	addl $0xb8000, %eax

printEnter:
	movb $0x0f, %ch	# White on black
	movb (%rdi), %cl
	cmpb $0, %cl
	je printEnd

printRecurse:
	movw %cx,  (%rax)
	incq %rdi
	addq $2, %rax
	movb (%rdi), %cl
	cmpb $0, %cl
	jne printRecurse
printEnd:
	ret

