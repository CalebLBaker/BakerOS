# Kernel entry for Buttaire
# Calls C code

.extern main
.section .text

	call main
	hlt
