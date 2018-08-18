#include <stdbool.h>
#include "isr.h"
#include "screen.h"

void main() {
#ifdef ISR
	idt_gate idt[IDT_ENTRIES];
	idt_register idtr;
	isr_install(idt, &idtr);
#endif
	clearScreen();
	print("Welcome to Buttaire.\n");
	while (true) {}
}
