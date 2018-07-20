; Kernel entry for Buttaire
; Calls C code

[bits 64]
[extern main]

Realm64:
	; Call C code
	call main
	jmp $
