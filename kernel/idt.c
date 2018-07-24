#include "idt.h"
#include "screen.h"

#define KERNEL_CS 0x08
#define INTERRUPT_GATE 0x8e


void set_idt_gate(idt_gate *entry, uint64 handler) {
	entry->low_offset = handler & 0xffff;
	entry->selector = KERNEL_CS;
	entry->ist = 0;
	entry->type_attr = INTERRUPT_GATE;
	entry->mid_offset = handler & 0xffff0000;
	entry->high_offset = handler & 0xffffffff00000000;
	entry->zero = 0;
}


void isr_handler(uint64 intNum, uint64 errorCode) {
	const char *exception_messages[32] = {
		"Division By Zero",
		"Debug",
		"Non Maskable Interrupt",
		"Breakpoint",
		"Into Detected Overflow",
		"Out of Bounds",
		"Invalid Opcode",
		"No Coprocessor",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Bad TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection Fault",
		"Page Fault",
		"Unknown Interrupt",
		"Coprocessor Fault",
		"Alignment Check",
		"Machine Check",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved",
		"Reserved"
	};
	char *message = "Received Interrupt:   \n";
	message[20] = (intNum / 10) + '0';
	message[21] = (intNum % 10) + '0';
	print(message);
	print(exception_messages[intNum]);
	printNewLine();
}
