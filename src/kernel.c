#include <stdbool.h>
#include "isr.h"
#include "vga.h"

void main() {
	idt_gate idt[IDT_ENTRIES];
	idt_register idtr;
	isr_install(idt, &idtr);
	clearScreen();
	print("Welcome to Buttaire.");
	while (true) {}
}
