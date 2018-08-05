# Kernel entry for Buttaire
# Calls C code
.code32
.extern main
.section .text

# Enter long mode
enterLongMode:

	# Check if CPUID is supported

	# Copy flags into eax and ecx via stack
	pushfl
	popl %eax
	movl %eax, %ecx

	# Flip ID bit
	xorl $0x200000, %eax

	# Copy eax to flags
	pushl %eax
	popfl

	# Copy flags back to eax
	pushfl
	popl %eax

	# Restore flags from old version
	pushl %ecx
	popfl

	# Compare eax and ecx
	xorl %eax, %ecx
	jz .NoCPUID
	
	# Check if long mode is supported
	movl $0x80000000, %eax
	cpuid
	cmpl $0x80000001, %eax
	jb .NoLongMode
	movl $0x80000001, %eax
	cpuid
	testl $0x20000000, %edx
	jz .NoLongMode

	# Set up paging######################

	movl %cr0, %eax
	andl $0x7fffffff, %eax
	movl %eax, %cr0

	# Clear 16 KB
	movl $0x1000, %edi
	movl %edi, %cr3
	xorl %eax, %eax
	mov $0x1000, %ecx
	rep stosl
	movl %cr3, %edi

	# Set up some pages
	# PML4T - 0x1000
	# PDPT - 0x2000
	# PDT - 0x3000
	# PT - 0x4000
	movl $0x2003, (%edi)
	addl $0x1000, %edi
	movl $0x3003, (%edi)
	addl $0x1000, %edi
	movl $0x4003, (%edi)
	addl $0x1000, %edi

	# identity map the first two MB
	movl $0x00000003, %ebx
	movl $0x200, %ecx
.SetEntry:
	movl %ebx, (%edi)
	addl $0x1000, %ebx
	addl $8, %edi
	loop .SetEntry

	# enable PAE-paging
	movl %cr4, %eax
	orl $0x20, %eax	# Set the PAE bit
	movl %eax, %cr4

	# Enter long mode
	movl $0xC0000080, %ecx	# Set ecx to the EFER MSR
	rdmsr					# Read from model-specific register
	orl $0x100, %eax		# Set LM bit
	wrmsr					# Write to the model-specific register

	movl %cr0, %eax
	orl $0x80000000, %eax	# Set the page and protected mode bits
	movl %eax, %cr0

	lgdt .Pointer
	jmp $8,$Realm64

# TODO: Do something other than freeze if long mode isn't supported.
.NoLongMode:
.NoCPUID:
	jmp .NoCPUID

#include "64bitGDT.S"

.code64
Realm64:
	cli				# Clear the interrupt flag.

	# Set us segment registers
	movw $Data, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss

	# Update stack
	movq $0x90000, %rbp
	movq %rbp, %rsp

# Call C code
	call main
kernel_exit:
	jmp kernel_exit
