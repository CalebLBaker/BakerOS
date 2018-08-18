#define KERNEL_DS 0x10
#define ERROR_CODE 0x52
#define INTERRUPT_NUMBER 0x4a
#define IDT_GATE_SIZE 0x10
#define IDT_SIZE 0xfff


.extern isr_handler
.extern set_idt_gate


.section .text

#ifdef ISR

# Initialize and load the Interrupt descriptor table
# Parameters
#	rdi		Address of idt
#	rsi		Address of idt register
.globl isr_install
.type isr_install, @function

isr_install:

	# Initialize idt register and save address to stack
	movw $IDT_SIZE, (%rsi)
	movq %rdi, 2(%rsi)
	pushq %rsi

	# Initialize idt
	movq $isr0, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr1, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr2, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr3, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr4, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr5, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr6, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr7, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr8, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr9, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr10, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr11, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr12, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr13, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr14, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr15, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr16, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr17, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr18, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr19, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr20, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr21, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr22, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr23, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr24, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr25, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr26, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr27, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr28, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr29, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr30, %rsi
	call set_idt_gate

	addq $IDT_GATE_SIZE, %rdi
	movq $isr31, %rsi
	call set_idt_gate

	# Retrieve idt register address from stack and load idt
	popq %rsi
	lidtq (%rsi)
	ret


isr_common_stub:

	# Save CPU state
	pushq %r10
	pushq %r11
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %rax
	movw %ds, %ax
	pushw %ax

	# Do segment stuff
	movw $KERNEL_DS, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs

	# Call handler
	movq INTERRUPT_NUMBER(%rsp), %rdi
	movq ERROR_CODE(%rsp), %rsi
	call isr_handler

	# Restore segment registers
	popw %ax
	movw %ax, %ds
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs

	# Restore clobbered registers
	popq %rax
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	popq %r11
	popq %r10

	# Remove interrupt number and error code from stack
	addq $0x10, %rsp

	# Re-enable interrups and return
	sti
	iretq


# 0:	Divide By Zero Exception
.globl isr0
.type isr0, @function
isr0:
	cli
	pushq $0
	pushq $0
	jmp isr_common_stub

# 1:	Debug Exception
.globl isr1
.type isr1, @function
isr1:
	cli
	pushq $0
	pushq $1
	jmp isr_common_stub

# 2:	Non Maskable Interrupt Exception
.globl isr2
.type isr2, @function
isr2:
	cli
	pushq $0
	pushq $2
	jmp isr_common_stub

# 3:	Int 3 Exception
.globl isr3
.type isr3, @function
isr3:
	cli
	pushq $0
	pushq $3
	jmp isr_common_stub

# 4:	INTO Exception
.globl isr4
.type isr4, @function
isr4:
	cli
	pushq $0
	pushq $4
	jmp isr_common_stub

# 5:	Out of Bounds Exception
.globl isr5
.type isr5, @function
isr5:
	cli
	pushq $0
	pushq $5
	jmp isr_common_stub

# 6:	Invalid Opcode Exception
.globl isr6
.type isr6, @function
isr6:
	cli
	pushq $0
	pushq $6
	jmp isr_common_stub

# 7:	Coprocessor Not Available Exception
.globl isr7
.type isr7, @function
isr7:
	cli
	pushq $0
	pushq $7
	jmp isr_common_stub

# 8:	Double Fault Exception (With Error Code!)
.globl isr8
.type isr8, @function
isr8:
	cli
	pushq $8
	jmp isr_common_stub

# 9:	Coprocessor Segment Overrun Exception
.globl isr9
.type isr9, @function
isr9:
	cli
	pushq $0
	pushq $9
	jmp isr_common_stub

# 10:	Bad TSS Exception (With Error Code!)
.globl isr10
.type isr10, @function
isr10:
	cli
	pushq $10
	jmp isr_common_stub

# 11:	Segment Not Present Exception (With Error Code!)
.globl isr11
.type isr11, @function
isr11:
	cli
	pushq $11
	jmp isr_common_stub

# 12:	Stack Fault Exception (With Error Code!)
.globl isr12
.type isr12, @function
isr12:
	cli
	pushq $12
	jmp isr_common_stub

# 13:	General Protection Fault Exception (with Error Code!)
.globl isr13
.type isr13, @function
isr13:
	cli
	pushq $13
	jmp isr_common_stub

# 14:	Page Fault Exception (With Error Code!)
.globl isr14
.type isr14, @function
isr14:
	cli
	pushq $14
	jmp isr_common_stub

# 15:	Reserved Exception
.globl isr15
.type isr15, @function
isr15:
	cli
	pushq $0
	pushq $15
	jmp isr_common_stub

# 16:	Floating Point Exception
.globl isr16
.type isr16, @function
isr16:
	cli
	pushq $0
	pushq $16
	jmp isr_common_stub

# 17:	Alignment Check Exception
.globl isr17
.type isr17, @function
isr17:
	cli
	pushq $0
	pushq $17
	jmp isr_common_stub

# 18:	Machine Check Exception
.globl isr18
.type isr18, @function
isr18:
	cli
	pushq $0
	pushq $18
	jmp isr_common_stub

# 19:	Reserved
.globl isr19
.type isr19, @function
isr19:
	cli
	pushq $0
	pushq $19
	jmp isr_common_stub

# 20:	Reserved
.globl isr20
.type isr20, @function
isr20:
	cli
	pushq $0
	pushq $20
	jmp isr_common_stub

# 21:	Reserved
.globl isr21
.type isr21, @function
isr21:
	cli
	pushq $0
	pushq $21
	jmp isr_common_stub

# 22:	Reserved
.globl isr22
.type isr22, @function
isr22:
	cli
	pushq $0
	pushq $22
	jmp isr_common_stub

# 23:	Reserved
.globl isr23
.type isr23, @function
isr23:
	cli
	pushq $0
	pushq $23
	jmp isr_common_stub

# 24:	Reserved
.globl isr24
.type isr24, @function
isr24:
	cli
	pushq $0
	pushq $24
	jmp isr_common_stub

# 25:	Reserved
.globl isr25
.type isr25, @function
isr25:
	cli
	pushq $0
	pushq $25
	jmp isr_common_stub

# 26:	Reserved
.globl isr26
.type isr26, @function
isr26:
	cli
	pushq $0
	pushq $26
	jmp isr_common_stub

# 27:	Reserved
.globl isr27
.type isr27, @function
isr27:
	cli
	pushq $0
	pushq $27
	jmp isr_common_stub

# 28:	Reserved
.globl isr28
.type isr28, @function
isr28:
	cli
	pushq $0
	pushq $28
	jmp isr_common_stub

# 29:	Reserved
.globl isr29
.type isr29, @function
isr29:
	cli
	pushq $0
	pushq $29
	jmp isr_common_stub

# 30:	Reserved
.globl isr30
.type isr30, @function
isr30:
	cli
	pushq $0
	pushq $30
	jmp isr_common_stub

# 31:	Reserved
.globl isr31
.type isr31, @function
isr31:
	cli
	pushq $0
	pushq $31
	jmp isr_common_stub

#endif
