; Kernel entry for BakerOS
; Switches the processor from real mode to long mode


; Announce that the kernel has been loaded
[bits 16]
	mov bx, MESSAGE
	call print
	call newLine

; Switch to protected mode
switch_to_pm:
	cli		; disable interrupts

	lgdt [gdt_descriptor]	; load the GDT descriptor

	; Set 32 bit mode in cr0
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:init_pm

%include "print.s"
%include "32bitGDT.s"

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
	mov ebp, 0x90000
	mov esp, ebp

	call enterLongMode

%include "64bitGDT.s"

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

[bits 64]
[extern main]

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

	; Call C code
	call main
	jmp $

MESSAGE: db "Entered kernel", 0
