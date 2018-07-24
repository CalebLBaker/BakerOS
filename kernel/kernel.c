#include "isr.h"
#include "screen.h"

void main() {
	idt_gate idt[IDT_ENTRIES];
	idt_register idtr;
	isr_install(idt, &idtr);
	clearScreen();
	print("Successfully entered 64 bit kernel.\n$");
}
