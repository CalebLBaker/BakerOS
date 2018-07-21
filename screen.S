#define VIDEO_ADDRESS 0xb8000
#define CURSOR_HIGH_BYTE 0xe
#define CURSOR_LOW_BYTE 0xf
#define SCREEN_CTRL 0x3d4
#define SCREEN_DATA 0x3d5
#define WHITE_ON_BLACK 0xf
#define BLACK_SCREEN 0x0f200f200f200f20
#define MAX_ROWS 25
#define MAX_COLS 80
#define ROW_WIDTH 160
#define SCREEN_SIZE_DIV_FOUR
#define NEW_LINE 0xa

.section .text


# Print a string at a given row and column
# Parameters
#	rdi		The address of the string to print
#	rsi		The row to print to
#	rdx		The column to print to
# Return value
#	rax		New cursor position
.globl printAt
.type printAt, @function

printAt:
	movq $MAX_COLS, %rax
	mulq %rsi
	leaq VIDEO_ADDRESS(%rdx,%rax,), %rax
	jmp printEnter
	


# Print a string to a given address in video memory
# Parameters
#	rdi		The address of the string to print
#	rsi		The address in video memory to print the string to
# Return value
#	rax		New cursor position
.globl printTargeted
.type printTargeted, @function

printTargeted:
	movq %rsi, %rax
	jmp printEnter
	


# Print a string to the current cursor position
# Parameters
#	rdi		The address of the string to print
# Return value
#	rax		New cursor position
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
	incq %rdi
	movb (%rdi), %cl
	cmpb $0, %cl
	jne printRecurse
printEnd:
	subq $VIDEO_ADDRESS, %rax
	shrq $1, %rax
	movq %rax, %rdi
	jmp setCursorPosition

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


	
# Print a character at a given row and column
# Parameters
#	dil		The character to print
#	rsi		The row to print to
#	rdx		The column to print to
# Return value
#	rax		Video memory address character was printed to
.globl printCharAt
.type printCharAt, @function

printCharAt:
	cmpb NEW_LINE, %dil
	je return
	movb $WHITE_ON_BLACK, %ch
	movb %dil, %cl
	movq $MAX_COLS, %rax
	mulq %rsi
	leaq VIDEO_ADDRESS(%rdx,%rax,), %rax
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
.globl printAt
.type printAt, @function

printCharColorAt:
	cmpb NEW_LINE, %dil
	je return
	movq $MAX_COLS, %rax
	mulq %rsi
	leaq VIDEO_ADDRESS(%rdx,%rax,), %rax
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
	jmp setCursorPosition



# Clear the screen
# Return value
#	rax		Character / color code for empty screen
.globl clearScreen
.type clearScreen, @function

clearScreen:
	movl $VIDEO_ADDRESS, %edi
	movq $BLACK_SCREEN, %rax
	movq $500, %rcx
	rep stosq
	movq $0, %rdi
	jmp setCursorPosition



# Get the position of the cursor
# Return value
#	rax		Position of cursor
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
	movb $WHITE_ON_BLACK, %dh
	movb %dil, %dl
	call getCursorPosition
	leaq VIDEO_ADDRESS(,%rax,2), %rcx
	movw %dx, (%rcx)
	leaq 1(%rax), %rdi
#	jmp setCursorPosition



# Set the position of the cursor
# Parameters
#	rdi		New position for the cursor
# Return value
#	al		Least significant byte of new cursor position
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
.globl getCursorRowCol
.type getCursorRowCol, @function

getCursorRowCol:
	call getCursorPosition
	movb $MAX_COLS, %cl
	divb %cl
	ret
