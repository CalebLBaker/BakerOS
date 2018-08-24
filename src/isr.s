.set KERNEL_DS, 0x10
.set ERROR_CODE, 0x52
.set INTERRUPT_NUMBER, 0x4A
.set IDT_GATE_SIZE, 0x10
.set IDT_SIZE, 0xFFFF


.extern isr_handler
.extern set_idt_gate

.section .data
panic_message:
	.asciz "Unhandled Exception"


.section .text

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


panic:
	movq $panic_message, %rdi
	call print
freeze:
	hlt
	jmp freeze

# 0:	Divide By Zero Exception
.globl isr0
.type isr0, @function
isr0:
	cli
	jmp panic

# 1:	Debug Exception
.globl isr1
.type isr1, @function
isr1:
	cli
	jmp panic

# 2:	Non Maskable Interrupt Exception
.globl isr2
.type isr2, @function
isr2:
	cli
	jmp panic

# 3:	Int 3 Exception
.globl isr3
.type isr3, @function
isr3:
	cli
	jmp panic

# 4:	INTO Exception
.globl isr4
.type isr4, @function
isr4:
	cli
	jmp panic

# 5:	Out of Bounds Exception
.globl isr5
.type isr5, @function
isr5:
	cli
	jmp panic

# 6:	Invalid Opcode Exception
.globl isr6
.type isr6, @function
isr6:
	cli
	jmp panic

# 7:	Coprocessor Not Available Exception
.globl isr7
.type isr7, @function
isr7:
	cli
	jmp panic

# 8:	Double Fault Exception (With Error Code!)
.globl isr8
.type isr8, @function
isr8:
	cli
	jmp panic

# 9:	Coprocessor Segment Overrun Exception
.globl isr9
.type isr9, @function
isr9:
	cli
	jmp panic

# 10:	Bad TSS Exception (With Error Code!)
.globl isr10
.type isr10, @function
isr10:
	cli
	jmp panic

# 11:	Segment Not Present Exception (With Error Code!)
.globl isr11
.type isr11, @function
isr11:
	cli
	jmp panic

# 12:	Stack Fault Exception (With Error Code!)
.globl isr12
.type isr12, @function
isr12:
	cli
	jmp panic

# 13:	General Protection Fault Exception (with Error Code!)
.globl isr13
.type isr13, @function
isr13:
	cli
	jmp panic

# 14:	Page Fault Exception (With Error Code!)
.globl isr14
.type isr14, @function
isr14:
	cli
	jmp panic

# 15:	Reserved Exception
.globl isr15
.type isr15, @function
isr15:
	cli
	jmp panic

# 16:	Floating Point Exception
.globl isr16
.type isr16, @function
isr16:
	cli
	jmp panic

# 17:	Alignment Check Exception
.globl isr17
.type isr17, @function
isr17:
	cli
	jmp panic

# 18:	Machine Check Exception
.globl isr18
.type isr18, @function
isr18:
	cli
	jmp panic

# 19:	Reserved
.globl isr19
.type isr19, @function
isr19:
	cli
	jmp panic

# 20:	Reserved
.globl isr20
.type isr20, @function
isr20:
	cli
	jmp panic

# 21:	Reserved
.globl isr21
.type isr21, @function
isr21:
	cli
	jmp panic

# 22:	Reserved
.globl isr22
.type isr22, @function
isr22:
	cli
	jmp panic

# 23:	Reserved
.globl isr23
.type isr23, @function
isr23:
	cli
	jmp panic

# 24:	Reserved
.globl isr24
.type isr24, @function
isr24:
	cli
	jmp panic

# 25:	Reserved
.globl isr25
.type isr25, @function
isr25:
	cli
	jmp panic

# 26:	Reserved
.globl isr26
.type isr26, @function
isr26:
	cli
	jmp panic

# 27:	Reserved
.globl isr27
.type isr27, @function
isr27:
	cli
	jmp panic

# 28:	Reserved
.globl isr28
.type isr28, @function
isr28:
	cli
	jmp panic

# 29:	Reserved
.globl isr29
.type isr29, @function
isr29:
	cli
	jmp panic

# 30:	Reserved
.globl isr30
.type isr30, @function
isr30:
	cli
	jmp panic

# 31:	Reserved
.globl isr31
.type isr31, @function
isr31:
	cli
	jmp panic

