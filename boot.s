; Boot sector for BakerOS
; Load's kernel from disk into memory
; and then immediately passes off execution
; to kernel


[org 0x7c00]
[bits 16]
KERNEL_OFFSET equ 0x500

	; Set up stack
	mov bp, 0x9000
	mov sp, bp

	; Load kernel
	mov bx, KERNEL_OFFSET
	mov dh, 2
	call disk_load

	call KERNEL_OFFSET

%include "diskRead.s"

; 0xaa55 as last 2 bytes signals to BIOS
; that this is the boot sector
times 510-($-$$) db 0
dw 0xaa55
