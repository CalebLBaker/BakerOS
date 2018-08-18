/* Constants */
.set MAGIC, 0xE85250D6
/*.set MAGIC, 0x1BADB002*/
.set FLAGS, 0
.set HEADER_LENGTH, 0x10
.set CHECKSUM, 0x17ADAF1A
.set CPUID_BIT, 0x200000
.set CPUID_HIGHEST_FUNC, 0x80000000
.set CPUID_PROCESSOR_INFO, 0x80000001
.set CPUID_LONG_MODE, 0x20000000
.set PAGING_BIT, 0x80000000
.set NO_PAGING_BIT, 0x7FFFFFFF
.set PAGE_TABLE_START, 0x1000
.set PAGE_TABLE_SIZE, 0x1000 /* Combined size of all page tables divided by 4 */
.set PAGE_SIZE, 0x1000 /* Size of a memory page. Also the size of a single page table */
.set PAE_BIT, 0x20
.set EFER_MSR, 0xC0000080 /* Extended Feature Enable Register Model Specific Register */
.set LONG_MODE, 0x100

/* Address of first table of a type OR'd with 3
   (3 indicates present and readable) */
.set PDPT, 0x2003	/* Page Directory Pointer Table */
.set PDT, 0x3003	/* Page Directory Table */
.set PT, 0x4003		/* Page Table */

/* These parameter will identity map the first 2 Megabytes */
.set MEM_START, 3		/* Address (OR'd with 3) of first mapped physical memory */
.set NUM_PAGES, 0x200	/* Number of memory pages */

.section .text
.code32

/* Multiboot header */
multiboot_header:
	.long MAGIC
	.long FLAGS
	.long HEADER_LENGTH
	.long CHECKSUM

	/* Null tag to terminate list of tags */
	.word 0
	.word 0
	.long 8

gdt:
	/* Null descriptor */
	.set null, 0
	.word 0xFFFF	/* Limit (low) */
	.word 0			/* Base (low) */
	.byte 0			/* Base (middle) */
	.byte 0			/* Access */
	.byte 1			/* Granularity */
	.byte 0			/* Base (high)

	/* Code Segment */
	.set code, 8
	.word 0			/* Limit (low) */
	.word 0			/* Base (low) */
	.byte 0			/* Base (middle */
	.byte 0x9A		/* Access (execute/read) */
	.byte 0xAF		/* Granulariy, 64 bit flag, limit19:16 */
	.byte 0			/* Base (high) */

	/* Data Segment */
	.set data, 0x10
	.word 0			/* Limit (low) */
	.word 0			/* Base (low) */
	.byte 0			/* Base (middle) */
	.byte 0x92		/* Access (read/write) */
	.byte 0			/* Granularity */
	.byte 0			/* Base (high) */

gdt_pointer:
	.word 0x17		/* Limit */
	.quad gdt		/* Base */



/* Code entry point */
.globl _start
_start:

	/* Check if long mode is supported */

	/* Check if CPUID is supported */

	/* Copy flags to eax */
	pushfl
	popl %eax

	movl %eax, %ecx			/* Copy flags to ecx */
	xorl $CPUID_BIT, %eax   /* Flip id bit */

	/* Copy eax to flags */
	pushl %eax
	popfl

	/* Copy flags to eax */
	pushfl
	popl %eax

	/* Restore flags */
	pushl %ecx
	popfl

	/* Compare old and new flags to check if cpuid is supported */
	xorl %ecx, %eax
	jz noCpuid

	/* Check if long mode is supported */

	/* Check if extended cpuid is supported */
	movl $CPUID_HIGHEST_FUNC, %eax
	cpuid
	cmpl $CPUID_PROCESSOR_INFO, %eax
	jb noLongMode

	/* Check if long mode is supported */
	movl $CPUID_PROCESSOR_INFO, %eax
	cpuid
	testl $CPUID_LONG_MODE, %edx
	jz noLongMode


	/* Set up paging */

	/* Disable old paging */
	movl %cr0, %eax
	andl $NO_PAGING_BIT, %eax
	movl %eax, %cr0

	/* Clear page tables */
	movl $PAGE_TABLE_START, %edi	/* Set destination */
	movl %edi, %cr3					/* Set cr3 to page table start */
	xorl %eax, %eax					/* clear eax */
	movl $PAGE_TABLE_SIZE, %ecx		/* Set number of iterations */
	rep stosl						/* Set memory */
	movl %cr3, %edi					/* Reset destination */

	/* Populate first entry of each table */
	movl $PDPT, (%edi)
	addl $PAGE_SIZE, %edi
	movl $PDT, (%edi)
	addl $PAGE_SIZE, %edi
	movl $PT, (%edi)

	/* Map virtual to physical memory using the first page table */
	addl $PAGE_SIZE, %edi
	movl $MEM_START, %ebx
	movl $NUM_PAGES, %ecx
setEntry:
	movl %ebx, (%edi)
	addl $PAGE_SIZE, %ebx	/* Address of next page */
	addl $8, %edi			/* Address of next entry */
	loop setEntry
	
	/* Enable PAE paging */
	movl %cr4, %eax
	orl $PAE_BIT, %eax
	movl %eax, %cr4

	/* Switch to long mode */
	movl $EFER_MSR, %ecx
	rdmsr
	orl $LONG_MODE, %eax
	wrmsr

	/* Enable Paging */
	movl %cr0, %eax
	orl $PAGING_BIT, %eax
	movl %eax, %cr0

	/* Switch to 64 bit mode */
	lgdt gdt_pointer
	jmp $code,$longEntry

noLongMode:
noCpuid:
	jmp noCpuid

/* Long mode code */
.code64
longEntry:

	cli	/* Clear interrupt flag */

	/* Set up segment registers */
	movw $data, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss
	call main
freeze:
	hlt
	jmp freeze
