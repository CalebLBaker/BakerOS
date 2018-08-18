#ifndef IDT_H
#define IDT_H

#include "types.h"
#define IDT_ENTRIES 0x100

typedef struct {
	uint16 low_offset;	// offset bits 0..15
	uint16 selector;	// Code segment selector
	uint8 ist;			// Interrupt stack table offset
	uint8 type_attr;
	uint16 mid_offset;	// offset bits 16..31
	uint32 high_offset;	// offset bits 32..63
	uint32 zero;		// reserved
} __attribute__((packed)) idt_gate;

void isr_handler(uint64 intNum, uint64 errorCode);

void set_idt_gate(idt_gate *idt, uint64 handler);

typedef struct {
	uint16 limit;
	uint64 base;
} __attribute__((packed)) idt_register;

idt_gate idt[IDT_ENTRIES];

#endif
