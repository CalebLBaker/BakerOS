[bits 16]

; Prints the data in the buffer pointed to by bx
; Parameters:
;	bx is the address of the buffer to be printed
; Clobbered:
;	ax		0x0e00
;	bx		Address of null terminator at end of buffer
print:
	mov ah, 0x0e
	mov al, [bx]
	cmp al, 0
	je printEnd
printRecurse:
	int 0x10
	inc bx
	mov al, [bx]
	cmp al, 0
	jne printRecurse
printEnd:
	ret
	

; Prints the data in the bx register as a hexidecimal number
; Parameters:
;	bx: the value to be printed
; Clobbered:
;	ax		ASCII value for least signficant hex digit ORed with 0x0e00
printHex:
	mov ah, 0x0e
	mov al, bh
	shr al, 4
	call printHexDigit
	mov al, bh
	and al, 0x0f
	call printHexDigit
	mov al, bl
	shr al, 4
	call printHexDigit
	mov al, bl
	and al, 0x0f
	call printHexDigit
	ret


; Prints the value in the al register as a hexidecimal digit
; Parameters:
;	ah: 0x0e
;	al:	the value to be printed
; Clobbered:
;	al		ASCII value for the printed digit
printHexDigit:
	cmp al, 9
	jg letter
	add al, '0'
	int 0x10
	ret
letter:
	add al, 55
	int 0x10
	ret


; Prints a new line character
; Clobbered:
;	ax
newLine:
	mov ax, 0x0e0a
	int 0x10
	mov al, 0xd
	int 0x10
	ret
