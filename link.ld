KERNEL_LMA = 0x0;
KERNEL_VMA = 0x0;
ENTRY(_start)
SECTIONS {
	. = KERNEL_LMA;

	.bootstrap : {
		src/bootstrap.o (.text)
	}

	. += KERNEL_VMA;

	.text : AT(ADDR(.text) - KERNEL_VMA) {
		_code = .;
		*(EXCLUDE_FILE(src/bootstrap.o) .text)
		*(.rodata*)
		. = ALIGN(0x1000);
	}

	.data : AT(ADDR(.data) - KERNEL_VMA) {
		_data = .;
		*(.data)
		. = ALIGN(0x1000);
	}

	.eh_frame : AT(ADDR(.eh_frame) - KERNEL_VMA) {
		_ehframe = .;
		*(.eh_frame)
		. = ALIGN(0x1000);
	}

	.bss : AT(ADDR(.bss) - KERNEL_VMA) {
		_bss = .;
		*(.bss)
		*(COMMON)
		. = ALIGN(0x1000);
	}

	_end = .;

	/DISCARD/ : {
		*(.comment)
	}
}
