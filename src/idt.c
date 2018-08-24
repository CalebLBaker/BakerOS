#include "idt.h"
#include "vga.h"

#define KERNEL_CS 0x08
#define INTERRUPT_GATE 0x8e


void set_idt_gate(idt_gate *entry, uint64_t handler) {
	entry->low_offset = handler & 0xffff;
	entry->selector = KERNEL_CS;
	entry->ist = 0;
	entry->type_attr = INTERRUPT_GATE;
	entry->mid_offset = handler & 0xffff0000;
	entry->high_offset = handler & 0xffffffff00000000;
	entry->zero = 0;
}

