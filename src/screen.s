.set VIDEO_ADDRESS, 0xB8000
.set SECOND_ROW, 0xB80A0
.set CURSOR_HIGH_BYTE, 0xE
.set CURSOR_LOW_BYTE, 0xF
.set SCREEN_CTRL, 0x3D4
.set SCREEN_DATA, 0x3D5
.set WHITE_ON_BLACK, 0xF
.set BLACK_SCREEN, 0x0f200f200f200f20
.set MAX_ROWS, 25
.set MAX_COLS, 80
.set ROW_WIDTH, 160
.set SCREEN_SIZE_DIV_FOUR, 500
.set NEW_LINE, 0xA
.set VIDEO_END, 0xB8FA0
.set VIDEO_MEMORY_SIZE, 3840
.set CURSOR_END, 2000
.set LAST_ROW, 0xB8F00
.set NUM_COLS_DIV_FOUR, 20

.extern memcpy
.section .text


# Print a string at a given row and column
# Parameters
#	rdi		The address of the string to print
#	rsi		The row to print to
#	rdx		The column to print to
# Return value
#	al		Least significant byte of new cursor position
.globl printAt
.type printAt, @function

printAt:
	movq $ROW_WIDTH, %rax
	movq %rdx, %r8
	mulq %rsi
	leaq VIDEO_ADDRESS(%rax,%r8,2), %rax
	jmp printEnter
	


# Print a string to a given address in video memory
# Parameters
#	rdi		The address of the string to print
#	rsi		The address in video memory to print the string to
# Return value
#	al		Least significant byte of new cursor position
.globl printTargeted
.type printTargeted, @function

printTargeted:
	movq %rsi, %rax
	jmp printEnter
	


# Print a string to the current cursor position
# Parameters
#	rdi		The address of the string to print
# Return value
#	al		Least significant byte of new cursor position
.globl print
.type print, @function

print:
	call getCursorPosition
	leaq VIDEO_ADDRESS(,%rax,2), %rax

printEnter:
	movb $WHITE_ON_BLACK, %ch
	movb (%rdi), %cl
	cmpb $0, %cl
	je printEnd

printRecurse:
	cmpb $NEW_LINE, %cl
	je newLine
	movw %cx, (%rax)
	addq $2, %rax
printResume:
	cmpq $VIDEO_END, %rax
	jge stringScroll
backFromScroll:
	incq %rdi
	movb (%rdi), %cl
	cmpb $0, %cl
	jne printRecurse
printEnd:
	subq $VIDEO_ADDRESS, %rax
	shrq $1, %rax
	movq %rax, %rdi
	jmp setCursorPosition

stringScroll:
	# need to preserve rdi, rax
	pushq %rdi
	pushq %rax
	call scroll
	popq %rax
	popq %rdi
	movb $WHITE_ON_BLACK, %ch
	subq $ROW_WIDTH, %rax
	jmp backFromScroll

newLine:
	subl $VIDEO_ADDRESS, %eax	# Get offset from start of video memory
	movq %rax, %rsi				# Store offset to register s
	movw $ROW_WIDTH, %dx		# Load row width (n bytes) to register d
	divb %dl					# Set ah to the column position
	shrw $8, %ax				# Set register a to cursor column position
	subw %ax, %si				# Set register s to start of current line
	addw %dx, %si				# Set register s to start of next line
	leaq VIDEO_ADDRESS(%rsi), %rax	# Load address into register a
	jmp printResume



# Scroll the screen one line
# Return value
#	rax		Character and color code for empty screen
.globl scroll
.type scroll, @function

scroll:
	movq $SECOND_ROW, %rdi
	movq $VIDEO_MEMORY_SIZE, %rdx
	movq $VIDEO_ADDRESS, %rsi
	call memcpy
	movl $LAST_ROW, %edi
	movq $BLACK_SCREEN, %rax
	movq $NUM_COLS_DIV_FOUR, %rcx
	rep stosq
	ret


	
# Print a character at a given row and column
# Parameters
#	dil		The character to print
#	rsi		The row to print to
#	rdx		The column to print to
# Return value
#	rax		Video memory address character was printed to
# Clobbers
#	rax, cx, edx, dil, rsi, r8
.globl printCharAt
.type printCharAt, @function

printCharAt:
	cmpb NEW_LINE, %dil
	je return
	movb $WHITE_ON_BLACK, %ch
	movb %dil, %cl
	movq $ROW_WIDTH, %rax
	movq %rdx, %r8
	mulq %rsi
	leaq VIDEO_ADDRESS(%rax,%r8,2), %rax
	movw %cx, (%rax)
return:
	ret



# Print a character at a given row and column
# Parameters
#	di		The character and color code to print
#	rsi		The row to print to
#	rdx		The column to print to
# Return value
#	rax		Video memory address character was printed to
# Clobbers
#	rax, edx, dil, rsi, r8
.globl printCharColorAt
.type printCharColorAt, @function

printCharColorAt:
	cmpb NEW_LINE, %dil
	je return
	movq $ROW_WIDTH, %rax
	movq %rdx, %r8
	mulq %rsi
	leaq VIDEO_ADDRESS(%rax,%r8,2), %rax
	movw %di, (%rax)
	ret



# Print a character with color
# Parameters
#	di		The character and color to be printed
# Return value
#	al		The least significant byte of the cursor position
.globl printCharColor
.type printCharColor, @function

printCharColor:
	cmpb $NEW_LINE, %dil
	je printNewLine
	call getCursorPosition
	leaq VIDEO_ADDRESS(,%rax,2), %rcx
	movw %di, (%rcx)
	leaq 1(%rax), %rdi
	cmpq $CURSOR_END, %rdi
	jl setCursorPosition

charScroll:
	pushq %rdi
	call scroll
	popq %rdi
	subq $MAX_COLS, %rdi
	jmp setCursorPosition



# Advance the cursor to the next line
# Return value
#	al		Least significant byte of new cursor position
.globl printNewLine
.type printNewLine, @function

printNewLine:
	call getCursorPosition
	movw %ax, %di
	movw $MAX_COLS, %cx
	divb %cl
	shrw $8, %ax
	subw %ax, %di
	addw %cx, %di
	cmpq $CURSOR_END, %rdi
	jge charScroll
	jmp setCursorPosition



# Clear the screen
# Return value
#	rax		Character / color code for empty screen
# Clobbers
#	rax, rcx, dx, edi, rdi
.globl clearScreen
.type clearScreen, @function

clearScreen:
	movl $VIDEO_ADDRESS, %edi
	movq $BLACK_SCREEN, %rax
	movq $SCREEN_SIZE_DIV_FOUR, %rcx
	rep stosq
	movq $0, %rdi
	jmp setCursorPosition



# Get the position of the cursor
# Return value
#	rax		Position of cursor
# Clobbers
#	rax, cl, dx
.globl getCursorPosition
.type getCursorPosition, @function

getCursorPosition:
	# Load high byte of cursor position into VGA register
	movq $CURSOR_HIGH_BYTE, %rax
	movw $SCREEN_CTRL, %dx
	out %al, %dx

	# Copy VGA register to cl
	incw %dx
	in %dx, %al
	movb %al, %cl

	# Load low byte of cursor position into VGA register
	movb $CURSOR_LOW_BYTE, %al
	decw %dx
	out %al, %dx

	# Copy VGA register to al
	incw %dx
	in %dx, %al

	# Set eax to cursor address
	movb %cl, %ah
	ret



# Set the cursor position by row and column
# Parameters
#	rdi		New row for cursor
#	rsi		New column for cursor
# Return value
#	al		Least significant byte of new cursor position
# Clobbers
#	rax, edx, rdi
.globl setCursorRowCol
.type setCursorRowCol, @function

setCursorRowCol:
	movq $MAX_COLS, %rax
	mulq %rdi
	leaq (%rsi,%rax,), %rdi

 	jmp setCursorPosition



# Print a character to the current cursor position
# Parameters
#	dil		The character to be printed
# Return value
#	al		The least significant byte of cursor position
.globl printChar
.type printChar, @function

printChar:
	cmpb $NEW_LINE, %dil
	je printNewLine
	call getCursorPosition
	movb $WHITE_ON_BLACK, %dh
	movb %dil, %dl
	leaq VIDEO_ADDRESS(,%rax,2), %rcx
	movw %dx, (%rcx)
	leaq 1(%rax), %rdi
	cmpq $CURSOR_END, %rdi
	jge charScroll
#	jmp setCursorPosition



# Set the position of the cursor
# Parameters
#	di		New position for the cursor
# Return value
#	al		Least significant byte of new cursor position
# Clobbers
#	al, dx
.globl setCursorPosition
.type setCursorPosition, @function

setCursorPosition:
	movb $CURSOR_HIGH_BYTE, %al
	movw $SCREEN_CTRL, %dx
	out %al, %dx

	movw $SCREEN_DATA, %dx
	movw %di, %ax
	movb %ah, %al
	out %al, %dx

	movb $CURSOR_LOW_BYTE, %al
	movw $SCREEN_CTRL, %dx
	out %al, %dx

	movw $SCREEN_DATA, %dx
	movb %dil, %al
	out %al, %dx
	ret



# Get a row number from a cursor position
# Parameters
#	di		A cursor position
# Return value
#	al		Row number for the rdi position
#	ah		Column number for the rdi position
# Clobbers
#	ax, cl
.globl rowFromPosition
.type rowFromPosition, @function

rowFromPosition:
	movw %di, %ax
	movb $MAX_COLS, %cl
	divb %cl
	ret



# Get a column number from a cursor position
# Parameters
#	di		A cursor position
# Return value
#	al		Column number for the rdi position
# Clobbers
#	ax, cl
.globl colFromPosition
.type colFromPosition, @function

colFromPosition:
	movw %di, %ax
	movb $MAX_COLS, %cl
	divb %cl
	movb %ah, %al
	ret



# Get the row and column numbers of the cursor
# Return value
#	al		Row number of the cursor
#	ah		Column number of the cursor
# Clobbers
#	ax, cl, dx
.globl getCursorRowCol
.type getCursorRowCol, @function

getCursorRowCol:
	call getCursorPosition
	movb $MAX_COLS, %cl
	divb %cl
	ret

