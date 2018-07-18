[bits 16]

; load dh sectors from dirve dl into es:bx
; Parameters:
;	dh is the number of sectors to read
;	dl is the drive to read from
; Clobbered:
disk_load:
	push dx

	; ah indicates the function for the interupt (2 for read)
	; al is the number of sectors to read (2)
	mov ah, 0x02
	mov al, dh

	; ch is the cylinder number (0)
	; cl is the sector number (0x02 is the first available sector)
	mov cx, 0x0002

	; dh is the head number (0)
	; dl is the drive number (0x80 for hard drive)
	mov dh, 0x00

	; BIOS interrupt
	int 0x13
	jc disk_error

	; Make sure the correct number of sectors were read
	pop dx
	cmp al, dh
	jne sectors_error

	ret

loop:
	jmp loop


disk_error:
	mov bx, DISK_ERROR
	mov dh, ah
	call print
	call newLine
	mov bx, dx
	call printHex
	jmp loop


sectors_error:
	mov bx, SECTORS_ERROR
	call print
	jmp loop

%include "print.s"

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0

