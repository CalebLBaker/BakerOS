# Boot sector for Buttaire
# Load's kernel from disk into memory,
# Switches from real mode to long mode,
# and passes off execution to the kernel

.org 0x0
.code16

#define KERNEL_OFFSET 0x500
#define KERNEL_SIZE 7
#define AX_VAL 0x0207

.globl _start
_start:

	# Set up stack
	movw $0x9000, %bp
	movw %bp, %sp

	# Load kernel
	movw $KERNEL_OFFSET, %bx

# load dh sectors from drive dl into es:bx

	# ah indicates the function for the interupt (2 for read)
	# al is the number of sectors to read
	movw $AX_VAL, %ax

	# ch is the cylinder number (0)
	# cl is the sector number (0x02 is the first available sector)
	movw $0x0002, %cx

	# dh is the head number (0)
	# dl is the drive number (0x80 for hard drive)
	xorb %dh, %dh

	# BIOS interrupt
	int $0x13
	jc disk_error

	# Make sure the correct number of sectors were read
	cmpb $KERNEL_SIZE, %al
	jne sectors_error


# Switch to protected mode
switch_to_pm:
	cli		# disable interrupts

	lgdt (gdt_descriptor) 	# load the GDT descriptor

	# Set 32 bit mode in cr0
	movl %cr0, %eax
	orb $0x1, %al
	movl %eax, %cr0
	jmpl $0x8,$init_pm


# Print an error message if a disk read error occured
disk_error:
	movw $DISK_ERROR, %bx
	movb %ah, %dh
	call print
	int $0x10
	movw %dx, %bx
	call printHex
loop:
	jmp loop

# Print an error message if the wrong number of sectors
# were read.
sectors_error:
	movw $SECTORS_ERROR, %bx
	call print
	jmp loop


#include "print.S"
#include "32bitGDT.S"

.code32
init_pm:
	# update the segment registers
	movw $DATA_SEG, %ax
	movw %ax, %ds
	movw %ax, %ss
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs

	# update the stack
	movl $0x90000, %ebp
	movl %ebp, %esp


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

	call KERNEL_OFFSET



DISK_ERROR:
	.asciz "Disk read error\n\r"
SECTORS_ERROR:
	.asciz "Wrong num of sectors read"

# 0xaa55 as last 2 bytes signals to BIOS
# that this is the boot sector
.org 0x1fe
.word 0xaa55
