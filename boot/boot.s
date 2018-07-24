; Boot sector for Buttaire
; Load's kernel from disk into memory,
; Switches from real mode to long mode,
; and passes off execution to the kernel


[org 0x7c00]
[bits 16]
KERNEL_OFFSET equ 0x500
KERNEL_SIZE equ 7

	; Set up stack
	mov bp, 0x9000
	mov sp, bp

	; Load kernel
	mov bx, KERNEL_OFFSET

; load dh sectors from drive dl into es:bx

	; ah indicates the function for the interupt (2 for read)
	; al is the number of sectors to read (2)
	mov ax, 0x0200 + KERNEL_SIZE

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
	cmp al, KERNEL_SIZE
	jne sectors_error


; Kernel entry for Buttaire
; Switches the processor from real mode to long mode


; Switch to protected mode
switch_to_pm:
	cli		; disable interrupts

	lgdt [gdt_descriptor]	; load the GDT descriptor

	; Set 32 bit mode in cr0
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:init_pm


; Print an error message if a disk read error occured
disk_error:
	mov bx, DISK_ERROR
	mov dh, ah
	call print
	int 0x10
	mov bx, dx
	call printHex
	jmp $

; Print an error message if the wrong number of sectors
; were read.
sectors_error:
	mov bx, SECTORS_ERROR
	call print
	jmp $


%include "boot/print.s"
%include "boot/32bitGDT.s"

[bits 32]
init_pm:
	; update the segment registers
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; update the stack
;	mov ebp, 0x90000
;	mov esp, ebp


; Enter long mode
enterLongMode:

	; Check if CPUID is supported

	; Copy flags into eax and ecx via stack
	pushfd
	pop eax
	mov ecx, eax

	; Flip ID bit
	xor eax, 0x200000

	; Copy eax to flags
	push eax
	popfd

	; Copy flags back to eax
	pushfd
	pop eax

	; Restore flags from old version
	push ecx
	popfd

	; Compare eax and ecx
	xor eax, ecx
	jz .NoCPUID
	
	; Check if long mode is supported;;;;;;;;;;;;;;;;
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .NoLongMode
	mov eax, 0x80000001
	cpuid
	test edx, 0x20000000
	jz .NoLongMode

	; Set up paging;;;;;;;;;;;;;;;;;;;;;;

	mov eax, cr0
	and eax, 0x7fffffff
	mov cr0, eax

	; Clear 16 KB
	mov edi, 0x1000
	mov cr3, edi
	xor eax, eax
	mov ecx, 0x1000
	rep stosd
	mov edi, cr3

	; Set up some pages
	; PML4T - 0x1000
	; PDPT - 0x2000
	; PDT - 0x3000
	; PT - 0x4000
	mov DWORD [edi], 0x2003
	add edi, 0x1000
	mov DWORD [edi], 0x3003
	add edi, 0x1000
	mov DWORD [edi], 0x4003
	add edi, 0x1000

	; identity map the first two MB
	mov ebx, 0x00000003
	mov ecx, 0x200
.SetEntry:
	mov DWORD [edi], ebx
	add ebx, 0x1000
	add edi, 8
	loop .SetEntry

	; enable PAE-paging
	mov eax, cr4
	or eax, 0x20	; Set the PAE bit
	mov cr4, eax

	; Enter long mode;;;;;;;;;;;;;;;;;;
	mov ecx, 0xC0000080	; Set ecx to the EFER MSR
	rdmsr				; Read from model-specific register
	or eax, 0x100		; Set LM bit
	wrmsr				; Write to the model-specific register

	mov eax, cr0
	or eax, 0x80000000	; Set the page and protected mode bits
	mov cr0, eax

	lgdt [GDT64.Pointer]
	jmp GDT64.Code:Realm64

; TODO: Do something other than freeze if long mode isn't supported.
.NoLongMode:
.NoCPUID:
	jmp $

%include "boot/64bitGDT.s"

[bits 64]

Realm64:
	cli				; Clear the interrupt flag.

	; Set us segment registers
	mov ax, GDT64.Data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	; Update stack
	mov rbp, 0x90000
	mov rsp, rbp

	call KERNEL_OFFSET




DISK_ERROR: db "Disk read error", 0xa, 0xd, 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0

; 0xaa55 as last 2 bytes signals to BIOS
; that this is the boot sector
times 510-($-$$) db 0
dw 0xaa55
