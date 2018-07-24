# $@ = target file
# $< = first dependency
# $^ = all dependencies

C_SOURCES = $(wildcard kernel/*.c)

# Assembly sources listed manually to exclude kernelEntry.S
ASM_SOURCES = kernel/screen.S kernel/isr.S

HEADERS =$(wildcard kernel/*.h)

C_OBJ = ${C_SOURCES:.c=.o}
ASM_OBJ = ${ASM_SOURCES:.S=.o}
OBJ = ${C_OBJ} ${ASM_OBJ}

CC = gcc
CFLAGS = -g -fno-stack-protector
ASMFLAGS = -g

buttaire.bin: boot/boot.bin kernel/kernel.bin
	cat $^ > $@


# kernelEntry.o listed separately to guarantee that it is listed first

kernel/kernel.bin: kernel/kernelEntry.o ${OBJ}
	ld -o $@ -Ttext 0x500 $^ --oformat binary

kernel/kernel.elf: kernel/kernelEntry.o ${OBJ}
	ld -o $@ -Ttext 0x500 $^


# Rule to disassemble the kernel - may be useful to debug
kernel/kernel.dis: kernel/kernel.bin
	ndisasm -b 64 $< > $@

boot/boot.bin: boot/boot.s
	nasm $< -f bin -o $@

%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -ffreestanding -c $< -o $@

%.o: %.S ${HEADERS}
	${CC} ${ASMFLAGS} -ffreestanding -c $< -o $@

all: run

run: buttaire.bin
	qemu-system-x86_64 -fda $<

debug: buttaire.bin kernel/kernel.elf
	qemu-system-x86_64 -s -fda buttaire.bin &
	gdb -ex "target remote localhost:1234" -ex "symbol-file kernel/kernel.elf"

clean:
	rm -f boot/*.bin *.bin kernel/*.bin kernel/*.o kernel/*.dis kernel/*.elf
