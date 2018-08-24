#ifndef IDT_H
#define IDT_H

#include <stdint.h>
#define IDT_ENTRIES 0x100

typedef struct {
	uint16_t low_offset;	// offset bits 0..15
	uint16_t selector;	// Code segment selector
	uint8_t ist;			// Interrupt stack table offset
	uint8_t type_attr;
	uint16_t mid_offset;	// offset bits 16..31
	uint32_t high_offset;	// offset bits 32..63
	uint32_t zero;		// reserved
} __attribute__((packed)) idt_gate;

void set_idt_gate(idt_gate *idt, uint64_t handler);

typedef struct {
	uint16_t limit;
	uint64_t base;
} __attribute__((packed)) idt_register;


#endif
